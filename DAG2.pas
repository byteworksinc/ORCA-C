{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  DAG Creation							}
{                                                               }
{  Places intermediate codes into DAGs and trees.		}
{                                                               }
{---------------------------------------------------------------}

unit DAG;

interface

{$segment 'cg'}

{$LibPrefix '0/obj/'}

uses CCommon, CGI, CGC, Gen;

{---------------------------------------------------------------}

procedure DAG (code: icptr);

{ place an op code in a DAG or tree				}
{                                                               }
{ parameters:                                                   }
{       code - opcode						}

{---------------------------------------------------------------}

implementation

var
   maxLoc: integer;			{max local label number used by compiler}

{-- External unsigned math routines; imported from Expression.pas --}

function udiv (x,y: longint): longint; extern;

function umod (x,y: longint): longint; extern;

function umul (x,y: longint): longint; extern;

{---------------------------------------------------------------}

procedure DAG {code: icptr};

{ place an op code in a DAG or tree				}
{                                                               }
{ parameters:                                                   }
{       code - opcode						}

var
   temp: icptr;				{temp node}


   procedure Generate;

   { generate the code for the current procedure		}

   var
      op: icptr;			{temp opcode pointers}


      procedure BasicBlocks;

      { Break the code up into basic blocks			}

      var
         blast: blockPtr;		{last block pointer}
         bp: blockPtr;			{current block pointer}
         cb: icptr;			{last code in block pointer}
         cp: icptr;			{current code pointer}

      begin {BasicBlocks}
      cp := DAGhead;
      DAGblocks := nil;
      if cp <> nil then begin
         bp := pointer(Calloc(sizeof(block)));
         DAGblocks := bp;
         blast := bp;
         bp^.code := cp;
         cb := cp;
         cp := cp^.next;
         cb^.next := nil;
         while cp <> nil do
					{labels start a new block}
            if cp^.opcode = dc_lab then begin
               Spin;
               bp := pointer(Calloc(sizeof(block)));
               bp^.last := blast;
               blast^.next := bp;
               blast := bp;
               bp^.code := cp;
               cb := cp;
               cp := cp^.next;
               cb^.next := nil;
               end {if}
					{conditionals are followed by a new block}
            else if cp^.opcode in [pc_fjp, pc_tjp, pc_ujp, pc_ret, pc_xjp] then
               begin
               Spin;
               while cp^.next^.opcode = pc_add do begin
                  cb^.next := cp;
        	  cb := cp;
        	  cp := cp^.next;
        	  cb^.next := nil;
                  end; {while}
               cb^.next := cp;
               cb := cp;
               cp := cp^.next;
               cb^.next := nil;
               bp := pointer(Calloc(sizeof(block)));
               bp^.last := blast;
               blast^.next := bp;
               blast := bp;
               bp^.code := cp;
               cb := cp;
               cp := cp^.next;
               cb^.next := nil;
               end {else if}
            else begin			{all other statements get added to a block}
               cb^.next := cp;
               cb := cp;
               cp := cp^.next;
               cb^.next := nil;
               end; {else}
         end; {if}
      end; {BasicBlocks}


   begin {Generate}             
   BasicBlocks;				{build the basic blocks}
   Gen(DAGblocks);			{generate native code}
   DAGhead := nil;			{reset the DAG pointers}
   end; {Generate}


   procedure Push (code: icptr);

   { place a node on the operation stack			}
   {								}
   { parameters:						}
   {    code - node						}

   begin {Push}
   code^.next := DAGhead;
   DAGhead := code;
   end; {Push}


   function Pop: icptr;

   { pop a node from the operation stack			}
   {								}
   { returns: node pointer or nil				}

   var
      node: icptr;			{node poped}
      tn: icptr;			{temp node}

   begin {Pop}
   node := DAGhead;
   if node = nil then
      Error(cge1)
   else begin
      DAGhead := node^.next;
      node^.next := nil;
      end; {else}
   if node^.opcode = dc_loc then begin
      tn := node;
      node := Pop;
      Push(tn);
      end; {if}
   Pop := node;
   end; {Pop}


   procedure Reverse;

   { Reverse the operation stack				}

   var
      list, temp: icptr;		{work pointers}

   begin {Reverse}
   list := nil;
   while DAGhead <> nil do begin
      temp := DAGhead;
      DAGhead := temp^.next;
      temp^.next := list;
      list := temp;
      end; {while}
   DAGhead := list;
   end; {Reverse}


begin {DAG}
case code^.opcode of

   pc_bnt, pc_bnl, pc_cnv, pc_dec, pc_inc, pc_ind, pc_lbf, pc_lbu,
   pc_ngi, pc_ngl, pc_ngr, pc_not, pc_stk, pc_cop, pc_cpo, pc_tl1,
   pc_sro, pc_str, pc_fjp, pc_tjp, pc_xjp, pc_cup, pc_pop, pc_iil,
   pc_ili, pc_idl, pc_ild:
      begin
      code^.left := Pop;
      Push(code);
      end;

   pc_adi, pc_adl, pc_adr, pc_and, pc_lnd, pc_bnd, pc_bal, pc_bno,
   pc_bor, pc_blr, pc_bxr, pc_blx, pc_cbf, pc_cpi, pc_dvi, pc_mov,
   pc_udi, pc_dvl, pc_udl, pc_dvr, pc_equ, pc_geq, pc_grt, pc_leq,
   pc_les, pc_neq, pc_ior, pc_lor, pc_ixa, pc_mod, pc_uim, pc_mdl,
   pc_ulm, pc_mpi, pc_umi, pc_mpl, pc_uml, pc_mpr, pc_psh, pc_sbi,
   pc_sbl, pc_sbr, pc_shl, pc_sll, pc_shr, pc_usr, pc_slr, pc_vsr,
   pc_tri, pc_sbf, pc_sto, pc_cui:
      begin
      code^.right := Pop;
      code^.left := Pop;
      Push(code);
      end;

   pc_gil, pc_gli, pc_gdl, pc_gld, pc_lil, pc_lli, pc_ldl, pc_lld,
   pc_lad, pc_lao, pc_lca, pc_lda, pc_ldc, pc_ldo, pc_lod, pc_nop,
   dc_cns, dc_glb, dc_dst, pc_lnm, pc_nam, pc_nat, dc_lab, pc_add,
   pc_ujp, dc_pin, pc_ent, pc_ret, dc_sym:
      Push(code);

   pc_cnn:
      begin
      code^.opcode := pc_cnv;
      temp := Pop;
      code^.left := Pop;
      Push(code);
      Push(temp);
      end;

   dc_loc: begin
      Push(code);
      if code^.r > maxLoc then
         maxLoc := code^.r;
      end;

   dc_prm: begin
      Push(code);
      if code^.s > maxLoc then
         maxLoc := code^.s;
      end;

   dc_str: begin
      Push(code);
      maxLoc := 0;
      end;

   dc_enp: begin
      Push(code);
      Reverse;
      Generate;
      end;

   otherwise: Error(cge1);		{invalid opcode}
   end; {case}
end; {DAG}

end.
