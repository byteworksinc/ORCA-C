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
   c_ind: iclist;			{vars that can be changed by indirect stores}
   maxLoc: integer;			{max local label number used by compiler}
   memberOp: icptr;			{operation found by Member}
   optimizations: array[pcodes] of integer; {starting indexes into peeptable}
   peepTablesInitialized: boolean;	{have the peephole tables been initialized?}
   rescan: boolean;			{redo the optimization pass?}

{-- External unsigned math routines; imported from Expression.pas --}

function udiv (x,y: longint): longint; extern;

function umod (x,y: longint): longint; extern;

function umul (x,y: longint): longint; extern;

{---------------------------------------------------------------}

function CodesMatch (op1, op2: icptr; exact: boolean): boolean;

{ Check to see if the trees op1 and op2 are equivalent		}
{								}
{ parameters:							}
{    op1, op2 - trees to check					}
{    exact - is an exact match of operands required?		}
{								}
{ Returns: True if trees are equivalent, else false.		}


   function LongStrCmp (s1, s2: longStringPtr): boolean;

   { Are the strings s1 amd s2 equal?				}
   {								}
   { parameters:						}
   {    s1, s2 - strings to compare				}
   {								}
   { Returns: True if the strings are equal, else false		}

   label 1;

   var
      i: integer;			{loop/index variable}

   begin {LongStrCmp}
   LongStrCmp := false;
   if s1^.length = s2^.length then begin
      for i := 1 to s1^.length do
         if s1^.str[i] <> s2^.str[i] then
            goto 1;
      LongStrCmp := true;
      end; {if}
1:
   end; {LongStrCmp}


   function OpsEqual (op1, op2: icptr): boolean;

   { See if the operands are equal				}
   {								}
   { parameters:						}
   {    op1, op2 - operations to check				}
   {								}
   { Returns: True if the operands are equivalent, else		}
   {    false.							}

   var
      result: boolean;			{temp result}

   begin {OpsEqual}
   result := false;
   case op1^.opcode of
      pc_cup, pc_cui, pc_tl1, pc_bno:
         {this rule prevents optimizations from removing sensitive operations}
         ;

      pc_adi, pc_adl, pc_adr, pc_and, pc_lnd, pc_bnd, pc_bal, pc_bor,
      pc_blr, pc_bxr, pc_blx, pc_equ, pc_neq, pc_ior, pc_lor, pc_mpi,
      pc_umi, pc_mpl, pc_uml, pc_mpr: begin
         if op1^.left = op2^.left then
            if op1^.right = op2^.right then
               result := true;
         if not result then
            if op1^.left = op2^.right then
               if op1^.right = op2^.left then
                  result := true;
         if not result then
            if not exact then
               if CodesMatch(op1^.left, op2^.left, false) then
                  if CodesMatch(op1^.right, op2^.right, false) then
                     result := true;
         if not result then
            if not exact then
               if CodesMatch(op1^.left, op2^.right, false) then
                  if CodesMatch(op1^.right, op2^.left, false) then
                     result := true;
         end;

      otherwise: begin
         if op1^.left = op2^.left then
            if op1^.right = op2^.right then
               result := true;
         if not result then
            if not exact then
               if CodesMatch(op1^.left, op2^.left, false) then
                  if CodesMatch(op1^.right, op2^.right, false) then
                     result := true;
         end;                 
      end; {case}
   OpsEqual := result;
   end; {OpsEqual}


begin {CodesMatch}
CodesMatch := false;
if op1 = op2 then
   CodesMatch := true
else if (op1 <> nil) and (op2 <> nil) then
   if op1^.opcode = op2^.opcode then
      if op1^.q = op2^.q then
         if op1^.r = op2^.r then
            if op1^.s = op2^.s then
               if op1^.lab^ = op2^.lab^ then
                  if OpsEqual(op1, op2) then
                     if op1^.optype = op2^.optype then
                        case op1^.optype of
                           cgByte, cgUByte, cgWord, cgUWord:
                              if op1^.opnd = op2^.opnd then
                                 if op1^.llab = op2^.llab then
                                    if op1^.slab = op2^.slab then
                                       CodesMatch := true;
                           cgLong, cgULong:
                              if op1^.lval = op2^.lval then
                                 CodesMatch := true;
                           cgReal, cgDouble, cgComp, cgExtended:
                              if op1^.rval = op2^.rval then
                                 CodesMatch := true;
                           cgString:
                              CodesMatch := LongStrCmp(op1^.str, op2^.str);
                           cgVoid, ccPointer:
                              if op1^.pval = op2^.pval then
                                 CodesMatch := LongStrCmp(op1^.str, op2^.str);
                           end; {case}
end; {CodesMatch}

{- Peephole Optimization ---------------------------------------}

function Base (val: longint): integer;

{ Assuming val is a power of 2, find ln(val) base 2		}
{								}
{ parameters:							}
{    val - value for which to find the base			}
{								}
{ Returns: ln(val), base 2					}

var
   i: integer;                    	{base counter}

begin {Base}
i := 0;
while not odd(val) do begin
   val := val >> 1;
   i := i+1;
   end; {while}
Base := i;
end; {Base}


procedure BinOps (var op1, op2: icptr);

{ Make sure the operands are of the same type			}
{								}
{ parameters:							}
{    op1, op2: two pc_ldc operands				}

var
   opt1, opt2: baseTypeEnum;		{temp operand types}

begin {BinOps}
opt1 := op1^.optype;
opt2 := op2^.optype;
if opt1 = cgByte then begin
   op1^.optype := cgWord;
   opt1 := cgWord;
   end {if}
else if opt1 = cgUByte then begin
   op1^.optype := cgUWord;
   opt1 := cgUWord;
   end {else if}
else if opt1 in [cgReal, cgDouble, cgComp] then begin
   op1^.optype := cgExtended;
   opt1 := cgExtended;
   end; {else if}
if opt2 = cgByte then begin
   op2^.optype := cgWord;
   opt2 := cgWord;
   end {if}
else if opt2 = cgUByte then begin
   op2^.optype := cgUWord;
   opt2 := cgUWord;
   end {else if}
else if opt2 in [cgReal, cgDouble, cgComp] then begin
   op2^.optype := cgExtended;
   opt2 := cgExtended;
   end; {else if}

if opt1 <> opt2 then begin
   case opt1 of
      cgWord:
         case opt2 of
            cgUWord:
               op1^.optype := cgUWord;
            cgLong, cgULong: begin
               op1^.lval := op1^.q;
               op1^.optype := opt2;
               end;
            cgExtended: begin
               op1^.rval := op1^.q;
               op1^.optype := cgExtended;
               end;
            otherwise: ;
            end; {case}
      cgUWord:
         case opt2 of
            cgWord:
               op2^.optype := cgUWord;
            cgLong, cgULong: begin
               op1^.lval := ord4(op1^.q) & $0000FFFF;
               op1^.optype := opt2;
               end;
            cgExtended: begin
               op1^.rval := ord4(op1^.q) & $0000FFFF;
               op1^.optype := cgExtended;
               end;
            otherwise: ;     
            end; {case}
      cgLong:
         case opt2 of
            cgWord: begin
               op2^.lval := op2^.q;
               op2^.optype := cgLong;
               end;
            cgUWord: begin
               op2^.lval := ord4(op2^.q) & $0000FFFF;
               op2^.optype := cgLong;
               end;
            cgULong:
               op1^.optype := cgULong;
            cgExtended: begin
               op1^.rval := op1^.lval;
               op1^.optype := cgExtended;
               end;
            otherwise: ;
            end; {case}
      cgULong:
         case opt2 of
            cgWord: begin
               op2^.lval := op2^.q;
               op2^.optype := cgLong;
               end;
            cgUWord: begin
               op2^.lval := ord4(op2^.q) & $0000FFFF;
               op2^.optype := cgLong;
               end;
            cgLong:
               op2^.optype := cgULong;
            cgExtended: begin
               op1^.rval := op1^.lval;
               if op1^.rval < 0.0 then
                  op1^.rval := 4294967296.0 + op1^.rval;
               op1^.optype := cgExtended;
               end;
            otherwise: ;
            end; {case}
      cgExtended: begin
         case opt2 of
            cgWord:
               op2^.rval := op2^.q;
            cgUWord:
               op2^.rval := ord4(op2^.q) & $0000FFFF;
            cgLong:
               op2^.rval := op2^.lval;
            cgULong: begin
               op2^.rval := op2^.lval;
               if op2^.rval < 0.0 then
                  op2^.rval := 4294967296.0 + op2^.rval;
               end;
            otherwise: ;
            end; {case}
         op2^.optype := cgExtended;
         end;
      otherwise: ;
      end; {case}
   end; {if}
end; {BinOps}


procedure CheckLabels;

{ remove unused dc_lab labels					}

var
   lop: icptr;				{predecessor of op}
   op: icptr;				{used to trace the opcode list}


   function Used (lab: integer): boolean;

   { see if a label is used					}
   {								}
   { parameters:						}
   {    lab - label number to check				}
   {								}
   { Returns: True if the label is used, else false.		}

   var
      found: boolean;			{was the label found?}
      op: icptr;			{used to trace the opcode list}
   
   begin {Used}
   found := false;
   op := DAGhead;
   while (not found) and (op <> nil) do begin
      if op^.opcode in [pc_add, pc_fjp, pc_tjp, pc_ujp] then
         found := op^.q = lab
      else if op^.opcode = pc_nat then
         found := true;
      op := op^.next;
      end; {while}
   Used := found;
   end; {Used}


begin {CheckLabels}
op := DAGhead;
while op^.next <> nil do begin
   lop := op;
   op := op^.next;
   if op^.opcode = dc_lab then
      if not Used(op^.q) then begin
         lop^.next := op^.next;
         op := lop;
         rescan := true;
         end; {if}
   end; {while}
end; {CheckLabels}


procedure RemoveDeadCode (op: icptr);

{ remove dead code following an unconditional branch		}
{								}
{ parameters:							}
{    op - unconditional branch opcode				}

begin {RemoveDeadCode}
while not (op^.next^.opcode in [dc_lab, dc_enp, dc_cns, dc_glb,
   dc_dst, dc_str, dc_pin, pc_ent, dc_loc, dc_prm, dc_sym]) do begin
   op^.next := op^.next^.next;
   rescan := true;
   end; {while}
end; {RemoveDeadCode}


function NoFunctions (op: icptr): boolean;

{ are there any function calls?					}
{								}
{ parameters:							}
{    op - operation tree to search				}
{								}
{ returns: True if there are no pc_cup or pc_cui operations	}
{    in the tree, else false.					}

begin {NoFunctions}
if op = nil then
   NoFunctions := true
else if op^.opcode in [pc_cup,pc_cui,pc_tl1] then
   NoFunctions := false
else
   NoFunctions := NoFunctions(op^.left) or NoFunctions(op^.right);
end; {NoFunctions}


function OneBit (val: longint): boolean;

{ See if there is exactly one bit set in val			}
{								}
{ parameters:							}
{    val - value to check					}
{								}
{ Returns: True if exactly one bit is set, else false		}

begin {OneBit}
if val = 0 then
   OneBit := false
else begin
   while not odd(val) do
      val := val >> 1;
   OneBit := val = 1;
   end; {else}
end; {OneBit}


procedure PeepHoleOptimization (var opv: icptr);

{ do peephole optimization on a list of opcodes			}
{								}
{ parameters:							}
{    opv - pointer to the first opcode				}
{								}
{ Notes:							}
{    1.	Many optimizations assume the children have already	}
{	been optimized.  In particular, many optimizations	}
{	depend on pc_ldc operands being on a specific side of	}
{	a child's expression tree.  (e.g. pc_fjp and pc_equ)	}

var
   done: boolean;			{optimization done test}
   doit: boolean;			{should we do the optimization?}
   lq, lval: longint;			{temps for long calculations}
   op2,op3: icptr;			{temp opcodes}
   op: icptr;				{copy of op (for efficiency)}
   opcode: pcodes;			{temp opcode}
   optype: baseTypeEnum;		{temp optype}
   q: integer;				{temp for integer calculations}
   rval: double;			{temp for real calculations}

   fromtype, totype, firstType: record	{for converting numbers to optypes}
      case boolean of
         true:  (i: integer);
         false: (optype: baseTypeEnum);
      end;


   function SideEffects (op: icptr): boolean;

   { Check a tree for operations that have side effects	}
   {								}
   { parameters:						}
   {    op - tree to check					}

   var
      result: boolean;		{temp result}

   begin {SideEffects}
   if (op = nil) or volatile then
      SideEffects := false
   else if op^.opcode in
      [pc_mov,pc_cbf,pc_cop,pc_cpi,pc_cpo,pc_gil,pc_gli,pc_gdl,
       pc_gld,pc_iil,pc_ili,pc_idl,pc_ild,pc_lil,pc_lli,pc_ldl,
       pc_lld,pc_sbf,pc_sro,pc_sto,pc_str,pc_cui,pc_cup,pc_tl1] then
      SideEffects := true
   else
      SideEffects := SideEffects(op^.left) or SideEffects(op^.right);
   end; {SideEffects}


   procedure JumpOptimizations (op: icptr; newOpcode: pcodes);

   { handle common code for jump optimizations			}
   {								}
   { parameters:						}
   {    op - jump opcode					}
   {    newOpcode - opcode to use if the jump sense is reversed	}

   var
      done: boolean;			{optimization done test}
      topcode: pcodes;			{temp opcode}

   begin {JumpOptimizations}
   topcode := op^.left^.opcode;
   if topcode = pc_not then begin
      op^.left := op^.left^.left;
      op^.opcode := newOpcode;
      PeepHoleOptimization(opv);
      end {else if}
   else if topcode in [pc_neq,pc_equ] then begin
      with op^.left^.right^ do
         if opcode = pc_ldc then
            if optype in [cgByte,cgUByte,cgWord,cgUWord] then
               if q = 0 then begin
                  op^.left := op^.left^.left;
                  if topcode = pc_equ then
                     op^.opcode := newOpcode;
                  end; {if}
      end; {else if}
   if op^.next^.opcode = dc_lab then
      if op^.next^.q = op^.q then
         if not SideEffects(op^.left) then begin
            rescan := true;
            opv := op^.next;
            end; {else if}
   end; {JumpOptimizations}


   procedure RealStoreOptimizations (op, opl: icptr);

   { do strength reductions associated with stores of reals	}
   {								}
   { parameters:						}
   {    op - real store to optimize				}
   {    opl - load operand for the store operation		}

   var
      disp: 0..9;			{disp to the word to change}
      same: boolean;			{are the operands the same?}
      op2: icptr;			{new opcode}
      opt: icptr;			{temp opcode}

      cnvrl: record			{for stuffing a real in a long space}
	 case boolean of
            true:  (lval: longint);
            false: (rval: real);
	 end;

   begin {RealStoreOptimizations}
   if opl^.opcode = pc_ngr then begin
      same := false;
      with opl^.left^ do
         if op^.opcode = pc_sro then begin
            if opcode = pc_ldo then
               if q = op^.q then
                  if optype = op^.optype then
                     if lab^ = op^.lab^ then
                        same := true;
            end {if}
         else {if op^.opcode = pc_str then}
            if opcode = pc_lod then
               if q = op^.q then
                  if r = op^.r then
                     if optype = op^.optype then
                        same := true;
      if same then begin
         case op^.optype of
            cgReal: disp := 3;
            cgDouble: disp := 7;
            cgExtended: disp := 9;
            cgComp: disp := 11;
            end; {case}
         opl^.left^.optype := cgWord;
         opl^.left^.q := opl^.left^.q + disp;
         op^.optype := cgWord;
         op^.q := op^.q + disp;
         op2 := pointer(Calloc(sizeof(intermediate_code)));
         op2^.opcode := pc_ldc;
         op2^.optype := cgWord;
         op2^.q := $0080;
         opl^.right := op2;
         opl^.opcode := pc_bxr;
         end {if}
      else if op^.optype = cgReal then begin
         opt := opl^.left;
         if opt^.opcode in [pc_ind,pc_ldo,pc_lod] then
            if opt^.optype = cgReal then begin
               opt^.optype := cgLong;
               op^.optype := cgLong;
               op2 := pointer(Calloc(sizeof(intermediate_code)));
               op2^.opcode := pc_ldc;
               op2^.optype := cgLong;
               op2^.lval := $80000000;
	       opl^.right := op2;
               opl^.opcode := pc_blx;
               end; {if}
         end; {else if}
      end {if}
   else if op^.optype = cgReal then begin
      if opl^.opcode = pc_ldc then begin
         cnvrl.rval := opl^.rval;
         opl^.lval := cnvrl.lval;
         opl^.optype := cgLong;
         op^.optype := cgLong;
         end {if}
      else if opl^.opcode in [pc_ind,pc_ldo,pc_lod] then
         if opl^.optype = cgReal then begin
            opl^.optype := cgLong;
            op^.optype := cgLong;
            end; {if}
      end; {if}
   end; {RealStoreOptimizations}


   procedure ReplaceLoads (ldop, stop, tree: icptr);

   { Replace any pc_lod operations in tree that load from the	}
   { location stored to by the pc_str operation stop by ldop	}
   {								}
   { parameters:						}
   {    ldop - operation to replace the pc_lods with		}
   {    stop - pc_str operation					}
   {    tree - tree to check for pc_lod operations		}
   {								}
   { Notes: ldop must be an instruction, not a tree		}

   begin {ReplaceLoads}
   if tree^.left <> nil then
      ReplaceLoads(ldop, stop, tree^.left);
   if tree^.right <> nil then
      ReplaceLoads(ldop, stop, tree^.right);
   if tree^.opcode = pc_lod then
      if tree^.optype = stop^.optype then
         if tree^.q = stop^.q then
            if tree^.r = stop^.r then
               tree^ := ldop^;
   end; {ReplaceLoads}


   procedure ReverseChildren (op: icptr);

   { reverse the children of a node				}
   {								}
   { parameters:						}
   {    op - node for which to reverse the children		}

   var
      opt: icptr;			{temp opcode pointer}

   begin {ReverseChildren}
   opt := op^.right;
   op^.right := op^.left;
   op^.left := opt;
   end; {ReverseChildren}


   procedure ZeroIntermediateCode (op: icptr);

   { Set all fields in the record to 0, nil, etc.		}
   {								}
   { Parameters:						}
   {    op - intermediate code record to clear			}

   begin {ZeroIntermediateCode}
   op^.q := 0;
   op^.r := 0;
   op^.s := 0;
   op^.lab := nil;
   op^.next := nil;
   op^.left := nil;
   op^.right := nil;
   op^.optype := cgWord;
   op^.opnd := 0;
   op^.llab := 0;
   op^.slab := 0;
   end; {ZeroIntermediateCode}


begin {PeepHoleOptimization}
{if printSymbols then begin write('Optimize: '); WriteCode(opv); end; {debug}
op := opv;				{copy for efficiency}
if op^.left <> nil then			{optimize the children}
   PeepHoleOptimization(op^.left);
if op^.right <> nil then
   PeepHoleOptimization(op^.right);
case op^.opcode of			{check for optimizations of this node}
   pc_add: begin			{pc_add}
      if op^.next^.opcode <> pc_add then
         RemoveDeadCode(op);
      end; {case pc_add}

   pc_adi: begin			{pc_adi}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         op^.left^.q := op^.left^.q + op^.right^.q;
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            q := op^.right^.q;
            if q = 0 then
               opv := op^.left
            else if q > 0 then begin
               op^.opcode := pc_inc;
               op^.q := q;
               op^.right := nil;
               end {else if}
            else {if q < 0 then} begin
               op^.opcode := pc_dec;
               op^.q := -q;
               op^.right := nil;
               end; {else if}
            end {if}
         else if CodesMatch(op^.left, op^.right, false) then begin
            if NoFunctions(op^.left) then begin
               ZeroIntermediateCode(op^.right);
               with op^.right^ do begin
                  opcode := pc_ldc;
                  q := 1;
                  optype := cgWord;
                  end; {with}
               op^.opcode := pc_shl;
               PeepHoleOptimization(opv);
               end; {if}
            end {else if}
         else if op^.left^.opcode in [pc_inc,pc_dec] then begin
            if op^.right^.opcode in [pc_inc,pc_dec] then begin
               op2 := op^.left;
               if op2^.opcode = pc_inc then
                  q := op2^.q
               else
                  q := -op2^.q;
               if op^.right^.opcode = pc_inc then
                  q := q + op^.right^.q
               else
                  q := q - op^.right^.q;
               if q >= 0 then begin
                  op2^.opcode := pc_inc;
                  op2^.q := q;
                  end {if}
               else begin
                  op2^.opcode := pc_dec;
                  op2^.q := -q;
                  end; {else}
               op^.left := op^.left^.left;
               op^.right := op^.right^.left;
               op2^.left := op;
               opv := op2;
               PeepHoleOptimization(opv);
               end; {if}
            end; {else if}
         end; {else}
      end; {case pc_adi}

   pc_adl: begin			{pc_adl}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         op^.left^.lval := op^.left^.lval + op^.right^.lval;
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            lval := op^.right^.lval;
            if lval = 0 then
               opv := op^.left
            else if (lval >= 0) and (lval <= maxint) then begin
               op^.opcode := pc_inc;
               op^.optype := cgLong;
               op^.q := ord(lval);
               op^.right := nil;
               end {else if}
            else if (lval > -maxint) and (lval < 0) then begin
               op^.opcode := pc_dec;
               op^.optype := cgLong;
               op^.q := -ord(lval); 
               op^.right := nil;
               end; {else if}
            end {if}
         else if CodesMatch(op^.left, op^.right, false) then
            if NoFunctions(op^.left) then begin
               ZeroIntermediateCode(op^.right);
               with op^.right^ do begin
                  opcode := pc_ldc;
                  lval := 1;
                  optype := cgLong;
                  end; {with}
               op^.opcode := pc_sll;
               end; {if}
         if op^.right^.opcode in [pc_lao,pc_lda,pc_ixa] then
            ReverseChildren(op);
         if op^.left^.opcode in [pc_lao,pc_lda,pc_ixa] then
            if op^.right^.opcode = pc_sll then begin
               if op^.right^.right^.opcode = pc_ldc then
                  if (op^.right^.right^.lval & $FFFF8000) = 0 then
                     if op^.right^.left^.opcode = pc_cnv then begin
                	fromtype.i := (op^.right^.left^.q & $00F0) >> 4;
                	if fromType.optype in [cgByte,cgUByte,cgWord,cgUWord] then
                           begin
                           if fromType.optype = cgByte then
                              op^.right^.left^.q := $02
                           else if fromType.optype = cgUByte then
                              op^.right^.left^.q := $13
                           else
                              op^.right^.left := op^.right^.left^.left;
                           with op^.right^.right^ do begin
                              lq := lval;
                              lval := 0;
                              q := long(lq).lsw;
                              optype := cgUWord;
                              end; {with}
                           op^.right^.opcode := pc_shl;
                           op^.opcode := pc_ixa;
                           PeepHoleOptimization(opv);
                           end; {if}
                	end; {if}
               end {if}
            else if op^.right^.opcode = pc_cnv then begin
               fromtype.i := (op^.right^.q & $00F0) >> 4;
               if fromtype.optype in [cgByte,cgUByte,cgWord,cgUWord] then begin
                  if fromType.optype = cgByte then
                     op^.right^.q := $02
                  else if fromType.optype = cgUByte then
                     op^.right^.q := $13
                  else
                     op^.right := op^.right^.left;
                  op^.opcode := pc_ixa;
                  PeepHoleOptimization(opv);
                  end; {if}
               end; {else if}
         end; {else}
      end; {case pc_adl}

   pc_adr: begin			{pc_adr}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         op^.left^.rval := op^.left^.rval + op^.right^.rval;
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            if op^.right^.rval = 0.0 then
               opv := op^.left;
            end; {if}
         end; {else}   
      end; {case pc_adr}

   pc_and: begin			{pc_and}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            op^.left^.q := ord((op^.left^.q <> 0) and (op^.right^.q <> 0));
            opv := op^.left;
            end {if}
         else begin
            if op^.right^.q = 0 then 
               if not SideEffects(op^.left) then 
                  opv := op^.right;
            end {else}
         end {if}
      else if op^.left^.opcode = pc_ldc then
         if op^.left^.q = 0 then
            opv := op^.left;
      end; {case pc_and}

   pc_bal: begin			{pc_bal}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.lval := op^.left^.lval & op^.right^.lval;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.lval = 0 then
            opv := op^.right
         else if op^.right^.lval = -1 then
            opv := op^.left;
         end; {else if}
      end; {case pc_bal}

   pc_blr: begin			{pc_blr}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.lval := op^.left^.lval | op^.right^.lval;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.lval = -1 then
            opv := op^.right
         else if op^.right^.lval = 0 then
            opv := op^.left;
         end; {else if}
      end; {case pc_blr}

   pc_blx: begin			{pc_blx}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.lval := op^.left^.lval ! op^.right^.lval;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.lval = 0 then
            opv := op^.left
         else if op^.right^.lval = -1 then begin
            op^.opcode := pc_bnl;
            op^.right := nil;
            end; {else if}
         end; {else if}
      end; {case pc_blx}

   pc_bnd: begin			{pc_bnd}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.q := op^.left^.q & op^.right^.q;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.q = 0 then
            opv := op^.right
         else if op^.right^.q = -1 then
            opv := op^.left;
         end; {else if}
      end; {case pc_bnd}

   pc_bnl: begin			{pc_bnl}
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.lval := op^.left^.lval ! $FFFFFFFF;
         opv := op^.left;
         end; {if}
      end; {case pc_bnl}

   pc_bno: begin			{pc_bno}
      if op^.left^.opcode = pc_str then
         if op^.left^.left^.opcode in [pc_lda,pc_lao] then begin
            ReplaceLoads(op^.left^.left, op^.left, op^.right);
            opv := op^.right;
            end; {if}
      end; {case pc_bno}

   pc_bnt: begin			{pc_bnt}
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.q := op^.left^.q ! $FFFF;
         opv := op^.left;
         end; {if}
      end; {case pc_bnt}

   pc_bor: begin			{pc_bor}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.q := op^.left^.q | op^.right^.q;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.q = -1 then
            opv := op^.right
         else if op^.right^.q = 0 then
            opv := op^.left;
         end; {else if}
      end; {case pc_bor}

   pc_bxr: begin			{pc_bxr}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.q := op^.left^.q ! op^.right^.q;
         opv := op^.left;
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.q = 0 then
            opv := op^.left
         else if op^.right^.q = -1 then begin
            op^.opcode := pc_bnt;
            op^.right := nil;
            end; {else if}
         end; {else if}
      end; {case pc_bxr}

   pc_cnv: begin			{pc_cnv}
      fromtype.i := (op^.q & $00F0) >> 4;
      totype.i := op^.q & $000F;
      if op^.left^.opcode = pc_ldc then begin
	 case fromtype.optype of
            cgByte,cgWord:
               case totype.optype of
        	  cgByte,cgUByte,cgWord,cgUWord: ;
        	  cgLong,cgULong: begin
                     lval := op^.left^.q;
                     op^.left^.q := 0;
                     op^.left^.lval := lval;
                     end;
        	  cgReal,cgDouble,cgComp,cgExtended: begin
                     rval := op^.left^.q;
                     op^.left^.q := 0;
                     op^.left^.rval := rval;
                     end;
                  otherwise: ;
        	  end; {case}                             
            cgUByte,cgUWord:
               case totype.optype of
        	  cgByte,cgUByte,cgWord,cgUWord: ;
        	  cgLong,cgULong: begin
                     lval := ord4(op^.left^.q) & $0000FFFF;
                     op^.left^.q := 0;
                     op^.left^.lval := lval;
                     end;
        	  cgReal,cgDouble,cgComp,cgExtended: begin
                     rval := ord4(op^.left^.q) & $0000FFFF;
                     op^.left^.q := 0;
                     op^.left^.rval := rval;
                     end;
                  otherwise: ;
        	  end; {case}                             
            cgLong:
               case totype.optype of
        	  cgByte,cgUByte,cgWord,cgUWord: begin
                     q := long(op^.left^.lval).lsw;                
                     op^.left^.lval := 0;
                     op^.left^.q := q;
                     end;
        	  cgLong, cgULong: ;
        	  cgReal,cgDouble,cgComp,cgExtended: begin
                     rval := op^.left^.lval;
                     op^.left^.lval := 0;
                     op^.left^.rval := rval;
                     end;
                  otherwise: ;
        	  end; {case}
            cgULong:
               case totype.optype of
        	  cgByte,cgUByte,cgWord,cgUWord: begin
                     q := long(op^.left^.lval).lsw;
                     op^.left^.lval := 0;
                     op^.left^.q := q;
                     end;
        	  cgLong, cgULong: ;
        	  cgReal,cgDouble,cgComp,cgExtended: begin
                     lval := op^.left^.lval;
                     op^.left^.lval := 0;
                     if lval >= 0 then
                        rval := lval
                     else
                        rval := (lval & $7FFFFFFF) + 2147483648.0;
                     op^.left^.rval := rval;
                     end;
                  otherwise: ;
        	  end; {case}
            cgReal,cgDouble,cgComp,cgExtended: begin
               rval := op^.left^.rval;
               case totype.optype of
        	  cgByte: begin
                     if rval < -128.0 then
                        q := -128
                     else if rval > 127.0 then
                        q := 127
                     else
                        q := trunc(rval);
                     op^.left^.rval := 0.0;
                     op^.left^.q := q;
                     end;
        	  cgUByte: begin
                     if rval < 0.0 then
                        q := 0
                     else if rval > 255.0 then
                        q := 255
                     else
                        q := trunc(rval);
                     op^.left^.rval := 0.0;
                     op^.left^.q := q;
                     end;
        	  cgWord: begin
                     if rval < -32768.0 then
                        lval := -32768
                     else if rval > 32767.0 then
                        lval := 32767
                     else
                        lval := trunc(rval);
                     op^.left^.rval := 0.0;
                     op^.left^.q := long(lval).lsw;
                     end;
        	  cgUWord: begin
                     if rval < 0.0 then
                        lval := 0
                     else if rval > 65535.0 then
                        lval := 65535
                     else begin
                        rval := trunc4(rval);
                        lval := round4(rval);
                        end; {else}
                     op^.left^.rval := 0.0;
                     op^.left^.q := long(lval).lsw;
                     end;
        	  cgLong,cgULong: begin
                     rval := op^.left^.rval;
                     if totype.optype = cgULong then begin
                        if rval < 0 then
                           rval := 0
                        else if rval > 2147483647.0 then
                           rval := rval - 4294967296.0
                        end; {if}
                     if rval < -2147483648.0 then
                        lval := $80000000
                     else if rval > 2147483647.0 then
                        lval := 2147483647
                     else begin
                        rval := trunc4(rval);
                        lval := round4(rval);
                        end; {else}
                     op^.left^.rval := 0.0;
                     op^.left^.lval := lval;
                     end;
        	  cgReal,cgDouble,cgComp,cgExtended: ;
                  otherwise: ;
                  end;
               end; {case}        
            otherwise: ;
            end; {case}
         if fromtype.optype in
            [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgReal,cgDouble,
            cgComp,cgExtended] then
            if totype.optype in
               [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgReal,cgDouble,
               cgComp,cgExtended] then begin
               op^.left^.optype := totype.optype;
               opv := op^.left;
               end; {if}
         end {if}
      else if op^.left^.opcode = pc_cnv then begin
         doit := false;
         firsttype.i := (op^.q & $00F0) >> 4;
         if fromType.optype in [cgReal,cgDouble,cgComp,cgExtended] then begin
            if toType.optype in [cgReal,cgDouble,cgComp,cgExtended] then
               doit := true;
            end {if}
         else begin
            if firstType.optype in [cgByte,cgWord,cgLong] then
               if fromType.optype in [cgByte,cgWord,cgLong] then
                  if toType.optype in [cgByte,cgWord,cgLong] then
                     doit := true;
            if firstType.optype in [cgUByte,cgUWord,cgULong] then
               if fromType.optype in [cgUByte,cgUWord,cgULong] then
                  if toType.optype in [cgUByte,cgUWord,cgLong] then
                     doit := true;
            if TypeSize(firstType.optype) = TypeSize(fromType.optype) then
               if TypeSize(firstType.optype) = TypeSize(toType.optype) then
                  doit := true;
            end; {else}
         if doit then begin
            op^.q := (op^.left^.q & $00F0) | (op^.q & $000F);
            op^.left := op^.left^.left;
            PeepHoleOptimization(opv);
            end; {if}
         end {else if}
      else if op^.left^.opcode in [pc_lod,pc_ldo,pc_ind] then begin
         if fromtype.optype in [cgWord,cgUWord] then
            if totype.optype in [cgByte,cgUByte,cgWord,cgUWord] then begin
               op^.left^.optype := totype.optype;
               opv := op^.left;
               end; {if}
         if fromtype.optype in [cgLong,cgULong] then
            if totype.optype in [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong]
               then begin
               op^.left^.optype := totype.optype;
               opv := op^.left;
               end; {if}
         end {else if}
      else if op^.q in [$40,$41,$50,$51] then begin
         {any long type to byte type}
         with op^.left^ do
            if opcode = pc_bal then
               if right^.opcode = pc_ldc then
                  if right^.lval = 255 then begin
                     op^.left := op^.left^.left;
                     PeepHoleOptimization(opv);
                     end; {if}
         with op^.left^ do    
            if opcode in [pc_slr,pc_vsr] then
               if right^.opcode = pc_ldc then
                  if left^.opcode in [pc_lod,pc_ldo,pc_ind] then begin
                     lq := right^.lval;
                     if long(lq).msw = 0 then
                        if long(lq).lsw in [8,16,24] then begin
                           lq := lq div 8;
                           left^.q := left^.q + long(lq).lsw;
                           op^.left := left;
                	   PeepHoleOptimization(opv);
                	   end; {if}
                     end; {if}
         end; {else if}                     
      end; {case pc_cnv}

   pc_dec: begin			{pc_dec}
      if op^.q = 0 then
         opv := op^.left
      else begin
	 opcode := op^.left^.opcode;
	 if opcode = pc_dec then begin
            if ord4(op^.left^.q) + ord4(op^.q) < ord4(maxint) then begin
               op^.q := op^.q + op^.left^.q;
               op^.left := op^.left^.left;
               end; {if}
            end {if}
	 else if opcode = pc_inc then begin
            q := op^.q - op^.left^.q;
            if q < 0 then begin
               q := -q;
               op^.opcode := pc_inc;
               end; {if}
            op^.q := q;
            op^.left := op^.left^.left;
            PeepHoleOptimization(opv);
            end {else if}
         else if opcode = pc_ldc then begin
            if op^.optype in [cgLong, cgULong] then begin
               op^.left^.lval := op^.left^.lval - op^.q;
               opv := op^.left;
               end {if}
            else if op^.optype in [cgUByte, cgByte, cgUWord, cgWord] then begin
               op^.left^.q := op^.left^.q - op^.q;
               opv := op^.left;
               end; {else if}
            end; {else if}
         end; {else}
      end; {case pc_dec}

   pc_dvi: begin			{pc_dvi}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            if op^.right^.q <> 0 then begin
               op^.left^.q := op^.left^.q div op^.right^.q;
               opv := op^.left;
               end; {if}
            end {if}
         else if op^.right^.q = 1 then
            opv := op^.left;
         end; {if}
      end; {case pc_dvi}

   pc_dvl: begin			{pc_dvl}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            if op^.right^.lval <> 0 then begin
               op^.left^.lval := op^.left^.lval div op^.right^.lval;
               opv := op^.left;
               end; {if}
            end {if}
         else if op^.right^.lval = 1 then
            opv := op^.left;
         end; {if}
      end; {case pc_dvl}

   pc_dvr: begin			{pc_dvr}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            if op^.right^.rval <> 0.0 then begin
               op^.left^.rval := op^.left^.rval/op^.right^.rval;
               opv := op^.left;
               end; {if}
            end {if}
         else if op^.right^.rval = 1.0 then
            opv := op^.left;
         end; {if}
      end; {case pc_dvr}

   pc_equ: begin			{pc_equ}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.right^.opcode = pc_ldc then begin
	 if op^.left^.opcode = pc_ldc then begin
            BinOps(op^.left, op^.right);
            case op^.left^.optype of
               cgByte,cgUByte,cgWord,cgUWord: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.q = op^.right^.q);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgLong,cgULong: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.lval = op^.right^.lval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgReal,cgDouble,cgComp,cgExtended: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.rval = op^.right^.rval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgVoid,ccPointer: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.pval = op^.right^.pval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               end; {case}
            end {if}
         else if op^.right^.optype in [cgByte, cgUByte, cgWord, cgUWord] then begin
            if op^.right^.q <> 0 then
               if op^.left^.opcode in
         	  [pc_and,pc_ior,pc_neq,pc_equ,pc_geq,pc_leq,pc_les,pc_grt]
                  then begin
                  opv := op^.left;
                  opv^.next := op^.next;
                  end; {if}
            end {else if}
         else if op^.right^.optype in [cgLong, cgULong] then begin
            if op^.right^.lval <> 0 then
               if op^.left^.opcode in
         	  [pc_and,pc_ior,pc_neq,pc_equ,pc_geq,pc_leq,pc_les,pc_grt]
                  then begin
                  opv := op^.left;
                  opv^.next := op^.next;
                  end; {if}
            end; {else if}
         end; {if}                      
      end; {case pc_equ}

   pc_fjp: begin			{pc_fjp}
      opcode := op^.left^.opcode;
      if opcode = pc_ldc then begin
         if op^.left^.optype in [cgByte, cgUByte, cgWord, cgUWord] then begin
            if op^.left^.q <> 0 then begin
               opv := op^.next;
               rescan := true;
               end {if}
            else begin
               op^.opcode := pc_ujp;
               op^.left := nil;
               PeepHoleOptimization(opv);
               end; {else}
            end {if}
         end {if}
      else if opcode = pc_and then begin
         op2 := op^.left;
         op2^.next := op^.next;
         op^.next := op2;
         op^.left := op2^.left;
         op2^.left := op2^.right;
         op2^.right := nil;
         op2^.opcode := pc_fjp;
         op2^.q := op^.q;
         PeepHoleOptimization(opv);
         end {else if}
      else if opcode = pc_ior then begin
         op2 := op^.left;
         op2^.next := op^.next;
         op^.next := op2;
         op^.left := op2^.left;
         op2^.left := op2^.right;
         op2^.right := nil;
         op2^.opcode := pc_fjp;
         op2^.q := op^.q;
         op^.opcode := pc_tjp;
         op3 := pointer(Calloc(sizeof(intermediate_code)));
         op3^.opcode := dc_lab;
         op3^.optype := cgWord;
         op3^.q := GenLabel;
         op3^.next := op2^.next;
         op2^.next := op3;
         op^.q := op3^.q;
         PeepHoleOptimization(opv);
         end {else if}
      else
         JumpOptimizations(op, pc_tjp);
      end; {case pc_fjp}

   pc_inc: begin			{pc_inc}
      if op^.q = 0 then
         opv := op^.left
      else begin
	 opcode := op^.left^.opcode;
	 if opcode = pc_inc then begin
            if ord4(op^.left^.q) + ord4(op^.q) < ord4(maxint) then begin
               op^.q := op^.q + op^.left^.q;
               op^.left := op^.left^.left;
               end; {if}
            end {if}
	 else if opcode = pc_dec then begin
            q := op^.q - op^.left^.q;
            if q < 0 then begin
               q := -q;
               op^.opcode := pc_dec;
               end; {if}
            op^.q := q;
            op^.left := op^.left^.left;
            PeepHoleOptimization(opv);
            end {else if}
         else if opcode = pc_ldc then begin
            if op^.optype in [cgLong, cgULong] then begin
               op^.left^.lval := op^.left^.lval + op^.q;
               opv := op^.left;
               end {if}
            else if op^.optype in [cgUByte, cgByte, cgUWord, cgWord] then begin
               op^.left^.q := op^.left^.q + op^.q;
               opv := op^.left;
               end; {else if}
            end {else if}
         else if opcode in [pc_lao,pc_lda] then begin
            op^.left^.q := op^.left^.q + op^.q;
            opv := op^.left;
            end; {else if}
         end; {else}
      end; {case pc_inc}

   pc_ind: begin			{pc_ind}
      opcode := op^.left^.opcode;
      if opcode = pc_lda then begin
         op^.left^.opcode := pc_lod;
         op^.left^.optype := op^.optype;
         op^.left^.q := op^.left^.q + op^.q;
         opv := op^.left;
         end {if}
      else if opcode = pc_lao then begin
         op^.left^.opcode := pc_ldo;
         op^.left^.optype := op^.optype;
         op^.left^.q := op^.left^.q + op^.q;
         opv := op^.left;
         end; {else if}
      end; {case pc_ind}

   pc_ior: begin			{pc_ior}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            op^.left^.q := ord((op^.left^.q <> 0) or (op^.right^.q <> 0));
            opv := op^.left;
            end {if}
         else begin
            if op^.right^.q <> 0 then begin
               if not SideEffects(op^.left) then begin
                  op^.right^.q := 1;
                  opv := op^.right;
                  end; {if}
               end {if}
            else
               op^.opcode := pc_neq;
            end {if}
         end {if}
      else if op^.left^.opcode = pc_ldc then
         if op^.left^.q <> 0 then begin
            op^.left^.q := 1;
            opv := op^.left;
            end; {if}
      end; {case pc_ior}

   pc_ixa: begin			{pc_ixa}
      if op^.right^.opcode = pc_ldc then begin
         optype := op^.right^.optype;
         if optype in [cgUByte, cgByte, cgUWord, cgWord] then begin
            lval := op^.right^.q;
            if optype = cgUByte then
               lval := lval & $000000FF
            else if optype = cgUWord then
               lval := lval & $0000FFFF;
            done := false;
            if op^.left^.opcode in [pc_lao, pc_lda] then begin
               lq := op^.left^.q + lval;
               if (lq >= 0) and (lq < maxint) then begin
                  done := true;
                  op^.left^.q := ord(lq);
                  opv := op^.left;
                  end; {if}
               end; {if}
            if not done then begin
               op^.right^.lval := lval;
               op^.right^.optype := cgLong;
               op^.opcode := pc_adl;
               PeepHoleOptimization(opv);
               end; {if}
            end; {if}                   
         end {if}
      else if op^.left^.opcode = pc_lao then begin
         if op^.right^.opcode = pc_inc then begin
            lq := ord4(op^.right^.q) + ord4(op^.left^.q);
            if lq < maxint then begin
               op^.left^.q := ord(lq);
               op^.right := op^.right^.left;
               end; {if}
            PeepHoleOptimization(opv);
            end; {if}
         end {else if}
      else if op^.left^.opcode = pc_ixa then begin
         op2 := op^.left;
         op^.left := op^.left^.left;
         op2^.left := op^.right;
         op2^.opcode := pc_adi;
         op^.right := op2;
         end; {else if}
      end; {case pc_ixa}

   pc_leq: begin			{pc_leq}
      if op^.optype in [cgWord,cgUWord] then
         if op^.right^.opcode = pc_ldc then
            if op^.right^.q < maxint then begin
               op^.right^.q := op^.right^.q + 1;
               op^.opcode := pc_les;
               end; {if}
      end; {case pc_lnm}

   pc_lnd: begin			{pc_lnd}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            op^.left^.q := ord((op^.left^.lval <> 0) and (op^.right^.lval <> 0));
            op^.left^.optype := cgWord;
            opv := op^.left;
            end {if}
         else begin
            if op^.right^.lval = 0 then begin
               if not SideEffects(op^.left) then  begin
                  with op^.right^ do begin
                     lval := 0;
                     optype := cgWord;
                     q := 0;
                     end; {with}
                  opv := op^.right;
                  end; {if}
               end {if}
            else
               op^.opcode := pc_neq;
            end; {if}
         end {if}
      else if op^.left^.opcode = pc_ldc then
         if op^.left^.lval = 0 then begin
            with op^.left^ do begin
               lval := 0;
               optype := cgWord;
               q := 0;
               end; {with}
            opv := op^.left;
            end; {if}
      end; {case pc_lnd}

   pc_lnm: begin			{pc_lnm}
      if op^.next^.opcode = pc_lnm then begin
         opv := op^.next;
         rescan := true;
         end; {if}
      end; {case pc_lnm}

   pc_lor: begin			{pc_lor}
      if op^.right^.opcode = pc_ldc then begin
         if op^.left^.opcode = pc_ldc then begin
            op^.left^.q := ord((op^.left^.lval <> 0) or (op^.right^.lval <> 0));
            optype := cgWord;
            opv := op^.left;
            end {if}
         else begin
            if op^.right^.lval <> 0 then begin
               if not SideEffects(op^.left) then begin
                  op^.right^.lval := 0;
                  op^.right^.q := 1;
                  op^.right^.optype := cgWord;
                  opv := op^.right;
                  end; {if}
               end {if}
            else begin
               op^.opcode := pc_neq;
               op^.optype := cgLong;
               end; {else}
            end; {if}
         end {if}
      else if op^.left^.opcode = pc_ldc then
         if op^.left^.lval <> 0 then begin
            op^.left^.lval := 0;
            op^.left^.q := 1;
            op^.left^.optype := cgWord;
            opv := op^.left;
            end; {if}
      end; {case pc_lor}

   pc_mdl: begin			{pc_mdl}
      if op^.right^.opcode = pc_ldc then 
         if op^.left^.opcode = pc_ldc then 
            if op^.right^.lval <> 0 then begin
               op^.left^.lval := op^.left^.lval mod op^.right^.lval;
               opv := op^.left;
               end; {if}
      end; {case pc_mdl}

   pc_mod: begin			{pc_mod}
      if op^.right^.opcode = pc_ldc then 
         if op^.left^.opcode = pc_ldc then 
            if op^.right^.q <> 0 then begin
               op^.left^.q := op^.left^.q mod op^.right^.q;
               opv := op^.left;
               end; {if}
      end; {case pc_mod}

   pc_mpi, pc_umi: begin		{pc_mpi, pc_umi}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         if op^.opcode = pc_mpi then
            op^.left^.q := op^.left^.q*op^.right^.q
         else {if op^.opcode = pc_umi then} begin
            lval := umul(op^.left^.q & $0000FFFF, op^.right^.q & $0000FFFF);
            op^.left^.q := long(lval).lsw;
            end; {else}
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            q := op^.right^.q;
            if q = 1 then
               opv := op^.left
            else if q = 0 then begin
               if NoFunctions(op^.left) then
                  opv := op^.right;
               end {else if}
            else if (q = -1) and (op^.opcode = pc_mpi) then begin
               op^.opcode := pc_ngi;
               op^.right := nil;
               end {else if}
            else if OneBit(q) then begin
               op^.right^.q := Base(q);
               op^.opcode := pc_shl;
               PeepHoleOptimization(opv);
               end; {else if}
            end; {if}
         end; {else}
      end; {case pc_mpi, pc_umi}

   pc_mpl, pc_uml: begin		{pc_mpl, pc_uml}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         if op^.opcode = pc_mpl then
            op^.left^.lval := op^.left^.lval*op^.right^.lval
         else {if op^.opcode = pc_uml then}
            op^.left^.lval := umul(op^.left^.lval, op^.right^.lval);
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            lval := op^.right^.lval;
            if lval = 1 then
               opv := op^.left
            else if lval = 0 then begin
               if NoFunctions(op^.left) then
                  opv := op^.right;
               end {else if}
            else if (lval = -1) and (op^.opcode = pc_mpl) then begin
               op^.opcode := pc_ngl;
               op^.right := nil;
               end {else if}
            else if OneBit(lval) then begin
               op^.right^.lval := Base(lval);
               op^.opcode := pc_sll;
               end; {else if}
            end; {if}
         end; {else}
      end; {case pc_mpl, pc_uml}

   pc_mpr: begin			{pc_mpr}
      if (op^.right^.opcode = pc_ldc) and (op^.left^.opcode = pc_ldc) then begin
         op^.left^.rval := op^.left^.rval*op^.right^.rval;
         opv := op^.left;
         end {if}
      else begin
         if op^.left^.opcode = pc_ldc then
            ReverseChildren(op);
         if op^.right^.opcode = pc_ldc then begin
            rval := op^.right^.rval;
            if rval = 1.0 then
               opv := op^.left
            else if rval = 0.0 then
               if NoFunctions(op^.left) then
                  opv := op^.right;
            end; {if}
         end; {else}
      end; {case pc_mpr}

   pc_neq: begin			{pc_neq}
      if op^.left^.opcode = pc_ldc then
         ReverseChildren(op);
      if op^.right^.opcode = pc_ldc then begin
	 if op^.left^.opcode = pc_ldc then begin
            BinOps(op^.left, op^.right);
            case op^.left^.optype of
               cgByte,cgUByte,cgWord,cgUWord: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.q <> op^.right^.q);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgLong,cgULong: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.lval <> op^.right^.lval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgReal,cgDouble,cgComp,cgExtended: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.rval <> op^.right^.rval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               cgVoid,ccPointer: begin
        	  op^.opcode := pc_ldc;
        	  op^.q := ord(op^.left^.pval <> op^.right^.pval);
        	  op^.left := nil;
        	  op^.right := nil;
        	  end;
               end; {case}
            end {if}
         else if op^.right^.optype in [cgByte, cgUByte, cgWord, cgUWord] then begin
            if op^.right^.q = 0 then
               if op^.left^.opcode in
         	  [pc_and,pc_ior,pc_neq,pc_equ,pc_geq,pc_leq,pc_les,pc_grt]
                  then begin
                  opv := op^.left;
                  opv^.next := op^.next;
                  end; {if}
            end {else if}
         else if op^.right^.optype in [cgLong, cgULong] then begin
            if op^.right^.lval = 0 then
               if op^.left^.opcode in
         	  [pc_and,pc_ior,pc_neq,pc_equ,pc_geq,pc_leq,pc_les,pc_grt]
                  then begin
                  opv := op^.left;
                  opv^.next := op^.next;
                  end; {if}
            end; {else if}
         end; {if}                      
      end; {case pc_neq}

   pc_ngi: begin			{pc_ngi}
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.q := -op^.left^.q;
         opv := op^.left;
         end; {if}
      end; {case pc_ngi}

   pc_ngl: begin			{pc_ngl}
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.lval := -op^.left^.lval;
         opv := op^.left;
         end; {if}
      end; {case pc_ngl}

   pc_ngr: begin			{pc_ngr}
      if op^.left^.opcode = pc_ldc then begin
         op^.left^.rval := -op^.left^.rval;
         opv := op^.left;
         end; {if}
      end; {case pc_ngr}

   pc_not: begin			{pc_not}
      opcode := op^.left^.opcode;
      if opcode = pc_ldc then begin
         if op^.left^.optype in [cgByte,cgUByte,cgWord,cgUWord] then begin
            op^.left^.q := ord(op^.left^.q = 0);
            opv := op^.left;
            end {if}
         else if op^.left^.optype in [cgLong,cgULong] then begin
            q := ord(op^.left^.lval = 0);
            lval := 0;
            op^.left^.q := q;
            op^.left^.optype := cgWord;
            opv := op^.left;
            end; {else if}
         end {if}
      else if opcode = pc_equ then begin
         op^.left^.opcode := pc_neq;
         opv := op^.left;
         end {else if}
      else if opcode = pc_neq then begin
         op^.left^.opcode := pc_equ;
         opv := op^.left;
         end {else if}
      else if opcode = pc_geq then begin
         op^.left^.opcode := pc_les;
         opv := op^.left;
         end {else if}
      else if opcode = pc_grt then begin
         op^.left^.opcode := pc_leq;
         opv := op^.left;
         end {else if}
      else if opcode = pc_les then begin
         op^.left^.opcode := pc_geq;
         opv := op^.left;
         end {else if}
      else if opcode = pc_leq then begin
         op^.left^.opcode := pc_grt;
         opv := op^.left;
         end; {else if}
      end; {case pc_not}

   pc_pop: begin			{pc_pop}
      if op^.left^.opcode = pc_cnv then
         op^.left := op^.left^.left;
      opcode := op^.left^.opcode;
      if opcode = pc_cop then begin
         op^.left^.opcode := pc_str;
         opv := op^.left;
         opv^.next := op^.next;
         PeepHoleOptimization(opv);
         end {if}            
      else if opcode = pc_cpi then begin
         op^.left^.opcode := pc_sto;
         opv := op^.left;
         opv^.next := op^.next;
         PeepHoleOptimization(opv);
         end {else if}
      else if opcode = pc_cbf then begin
         op^.left^.opcode := pc_sbf;
         opv := op^.left;
         opv^.next := op^.next;
         end {else if}
      else if opcode = pc_cpo then begin
         op^.left^.opcode := pc_sro;
         opv := op^.left;
         opv^.next := op^.next;
         PeepHoleOptimization(opv);
         end {else if}
      else if opcode in [pc_inc,pc_dec] then
         op^.left := op^.left^.left;
      end; {case pc_pop}

   pc_ret: begin			{pc_ret}
      RemoveDeadCode(op);
      end; {case pc_ret}

   pc_sbi: begin			{pc_sbi}
      if op^.left^.opcode = pc_ldc then begin
         if op^.right^.opcode = pc_ldc then begin
            op^.left^.q := op^.left^.q - op^.right^.q;
            opv := op^.left;
            end {if}
         else if op^.left^.q = 0 then begin
            op^.opcode := pc_ngi;
            op^.left := op^.right;
            op^.right := nil;
            end; {else if}
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         q := op^.right^.q;
         if q = 0 then
            opv := op^.left
         else if (q > 0) then begin
            op^.opcode := pc_dec;
            op^.q := q;
            op^.right := nil;
            end {else if}
         else {if q < 0) then} begin
            op^.opcode := pc_inc;
            op^.q := -q;
            op^.right := nil;
            end; {else if}
         end {if}
      else if op^.left^.opcode in [pc_inc,pc_dec] then
         if op^.right^.opcode in [pc_inc,pc_dec] then begin
            op2 := op^.left;
            if op^.left^.opcode = pc_inc then
               q := op^.left^.q
            else
               q := -op^.left^.q;
            if op^.right^.opcode = pc_inc then
               q := q - op^.right^.q
            else
               q := q + op^.right^.q;
            if q >= 0 then begin
               op2^.opcode := pc_inc;
               op2^.q := q;
               end {if}
            else begin
               op2^.opcode := pc_dec;
               op2^.q := -q;
               end; {else}
            op^.left := op^.left^.left;
            op^.right := op^.right^.left;
            op2^.left := op;
            opv := op2;
            PeepHoleOptimization(opv);
            end; {if}
      end; {case pc_sbi}

   pc_sbl: begin			{pc_sbl}
      if op^.left^.opcode = pc_ldc then begin
         if op^.right^.opcode = pc_ldc then begin
            op^.left^.lval := op^.left^.lval - op^.right^.lval;
            opv := op^.left;
            end {if}
         else if op^.left^.lval = 0 then begin
            op^.opcode := pc_ngl;
            op^.left := op^.right;
            op^.right := nil;
            end; {else if}
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         lval := op^.right^.lval;
         if lval = 0 then
            opv := op^.left
         else if (lval > 0) and (lval <= maxint) then begin
            op^.opcode := pc_dec;
            op^.q := ord(lval);
            op^.right := nil;
            op^.optype := cgLong;
            end {else if}
         else if (lval > -maxint) and (lval < 0) then begin
            op^.opcode := pc_inc;
            op^.q := -ord(lval);
            op^.right := nil;
            op^.optype := cgLong;
            end; {else if}       
         end; {if}
      end; {case pc_sbl}

   pc_sbr: begin			{pc_sbr}
      if op^.left^.opcode = pc_ldc then begin
         if op^.right^.opcode = pc_ldc then begin
            op^.left^.rval := op^.left^.rval - op^.right^.rval;
            opv := op^.left;
            end {if}
         else if op^.left^.rval = 0.0 then begin
            op^.opcode := pc_ngr;
            op^.left := op^.right;
            op^.right := nil;
            end; {else if}
         end {if}
      else if op^.right^.opcode = pc_ldc then begin
         if op^.right^.rval = 0.0 then
            opv := op^.left;
         end; {if}
      end; {case pc_sbr}

   pc_shl: begin			{pc_shl}
      if op^.right^.opcode = pc_ldc then begin
         opcode := op^.left^.opcode;
         if opcode = pc_shl then begin
            if op^.left^.right^.opcode = pc_ldc then begin
               op^.right^.q := op^.right^.q + op^.left^.right^.q;
               op^.left := op^.left^.left;
               end; {if}
            end {if}
         else if opcode = pc_inc then begin
            op2 := op^.left;
            op^.left := op2^.left;
            op2^.q := op2^.q << op^.right^.q;
            op2^.left := op;
            opv := op2;
            PeepHoleOptimization(op2^.left);
            end; {else if}
         end; {if}
      end; {case pc_shl}

   pc_sro, pc_str: begin		{pc_sro, pc_str}
      if op^.optype in [cgReal,cgDouble,cgExtended] then
         RealStoreOptimizations(op, op^.left);
      end; {case pc_sro, pc_str}

   pc_sto: begin			{pc_sto}
      if op^.optype in [cgReal,cgDouble,cgExtended] then
         RealStoreOptimizations(op, op^.right);
      if op^.left^.opcode = pc_lao then begin
         op^.q := op^.left^.q;
         op^.lab := op^.left^.lab;
         op^.opcode := pc_sro;
         op^.left := op^.right;
         op^.right := nil;
         end {if}
      else if op^.left^.opcode = pc_lda then begin
         op^.q := op^.left^.q;
         op^.r := op^.left^.r;
         op^.opcode := pc_str;
         op^.left := op^.right;
         op^.right := nil;
         end; {if}
      end; {case pc_sto}

   pc_tjp: begin			{pc_tjp}
      opcode := op^.left^.opcode;
      if opcode = pc_ldc then begin
         if op^.left^.optype in [cgByte, cgUByte, cgWord, cgUWord] then
            if op^.left^.q = 0 then begin
               opv := op^.next;
               rescan := true;
               end {if}
            else begin
               op^.opcode := pc_ujp;
               op^.left := nil;
               PeepHoleOptimization(opv);
               end; {else}
         end {if}
      else if opcode = pc_ior then begin
         op2 := op^.left;
         op2^.next := op^.next;
         op^.next := op2;
         op^.left := op2^.left;
         op2^.left := op2^.right;
         op2^.right := nil;
         op2^.opcode := pc_tjp;
         op2^.q := op^.q;
         PeepHoleOptimization(opv);
         end {else if}
      else if opcode = pc_and then begin
         op2 := op^.left;
         op2^.next := op^.next;
         op^.next := op2;
         op^.left := op2^.left;
         op2^.left := op2^.right;
         op2^.right := nil;
         op2^.opcode := pc_tjp;
         op2^.q := op^.q;
         op^.opcode := pc_fjp;
         op3 := pointer(Calloc(sizeof(intermediate_code)));
         op3^.opcode := dc_lab;
         op3^.optype := cgWord;
         op3^.q := GenLabel;
         op3^.next := op2^.next;
         op2^.next := op3;
         op^.q := op3^.q;
         PeepHoleOptimization(opv);
         end {else if}
      else
         JumpOptimizations(op, pc_fjp);
      end; {case pc_tjp}

   pc_tri: begin			{pc_tri}
      opcode := op^.left^.opcode;
      if opcode = pc_not then begin
         ReverseChildren(op^.right);
         op^.left := op^.left^.left;
         PeepHoleOptimization(opv);
         end {if}
      else if opcode in [pc_equ, pc_neq] then begin
	 with op^.left^.right^ do
            if opcode = pc_ldc then
               if optype in [cgByte,cgUByte,cgWord,cgUWord] then
        	  if q = 0 then begin
                     if op^.left^.opcode = pc_equ then
			ReverseChildren(op^.right);
                     op^.left := op^.left^.left;
                     end; {if}
         end; {else if}
      end; {case pc_tri}

   pc_udi: begin			{pc_udi}
      if op^.right^.opcode = pc_ldc then begin
         q := op^.right^.q;
         if op^.left^.opcode = pc_ldc then begin
            if q <> 0 then begin
               op^.left^.q := ord(udiv(op^.left^.q & $0000FFFF, q & $0000FFFF));
               opv := op^.left;
               end; {if}
            end {if}
         else if q = 1 then
            opv := op^.left
         else if OneBit(q) then begin
            op^.right^.q := Base(q);
            op^.opcode := pc_usr;
            end; {else if}
         end; {if}
      end; {case pc_udi}

   pc_udl: begin			{pc_udl}
      if op^.right^.opcode = pc_ldc then begin
         lq := op^.right^.lval;
         if op^.left^.opcode = pc_ldc then begin
            if lq <> 0 then begin
               op^.left^.lval := udiv(op^.left^.lval, lq);
               opv := op^.left;
               end; {if}
            end {if}
         else if lq = 1 then
            opv := op^.left
         else if OneBit(lq) then begin
            op^.right^.lval := Base(lq);
            op^.opcode := pc_vsr;
            end; {else if}
         end; {if}
      end; {case pc_udl}

   pc_uim: begin			{pc_uim}
      if op^.right^.opcode = pc_ldc then 
         if op^.left^.opcode = pc_ldc then 
            if op^.right^.q <> 0 then begin
               op^.left^.q :=
                  ord(umod(op^.left^.q & $0000FFFF, op^.right^.q & $0000FFFF));
               opv := op^.left;
               end; {if}
      end; {case pc_uim}

   pc_ujp: begin			{pc_ujp}
      RemoveDeadCode(op);
      if op^.next^.opcode = dc_lab then begin
         if op^.q = op^.next^.q then begin
            opv := op^.next;
            rescan := true;
            end {if}
         else if op^.next^.next^.opcode = dc_lab then
            if op^.next^.next^.q = op^.q then begin
               opv := op^.next;
               rescan := true;
               end; {if}
         end; {if}
      end; {case pc_ujp}

   pc_ulm: begin			{pc_ulm}
      if op^.right^.opcode = pc_ldc then 
         if op^.left^.opcode = pc_ldc then 
            if op^.right^.lval <> 0 then begin
               op^.left^.lval := umod(op^.left^.lval, op^.right^.lval);
               opv := op^.left;
               end; {if}
      end; {case pc_ulm}

   otherwise: ;
   end; {case}
end; {PeepHoleOptimization}

{- Common Subexpression Elimination ----------------------------}

function MatchLoc (op1, op2: icptr): boolean;

{ See if two loads, stores or copies refer to the same		}
{ location							}
{								}
{ parameters:							}
{    op1, op2 - operations to check				}
{								}
{ Returns: True if they do, false if they don't.		}

begin {MatchLoc}
MatchLoc := false;
if (op1^.opcode in [pc_str,pc_cop,pc_lod,pc_lli,pc_lil,pc_lld,pc_ldl,pc_lda])
   and (op2^.opcode in [pc_str,pc_cop,pc_lod,pc_lli,pc_lil,pc_lld,pc_ldl,pc_lda]) then begin
   if op1^.r = op2^.r then
      MatchLoc := true;
   end {if}
else if (op1^.opcode in [pc_sro,pc_cpo,pc_ldo,pc_gli,pc_gil,pc_gld,pc_gdl,pc_lao])
   and (op2^.opcode in [pc_sro,pc_cpo,pc_ldo,pc_gli,pc_gil,pc_gld,pc_gdl,pc_lao]) then
   if op1^.lab^ = op2^.lab^ then
      MatchLoc := true;
end; {MatchLoc}                       


function Member (op: icptr; list: iclist): boolean;

{ See if the operand of a load is referenced in a list		}
{								}
{ parameters:							}
{    op - load to check						}
{    list - list to check					}
{								}
{ Returns: True if op is in list, else false.			}
{								}
{ Notes: As a side effect, this subroutine sets memberOp to	}
{    point to any matching member; memberOp is undefined if	}
{    there is no matching member.				}

begin {Member}
Member := false;
while list <> nil do begin
   if MatchLoc(op, list^.op) then begin
      Member := true;
      memberOp := list^.op;
      list := nil;
      end {if}
   else
      list := list^.next;
   end; {while}
end; {Member}


function TypeOf (op: icptr): baseTypeEnum;

{ find the type for the expression tree				}
{								}
{ parameters:							}
{    op - tree for which to find the type			}
{								}
{ Returns: base type						}

begin {TypeOf}
case op^.opcode of
   pc_gil, pc_gli, pc_gdl, pc_gld, pc_iil, pc_ili, pc_idl, pc_ild,
   pc_ldc, pc_ldo, pc_lil, pc_lli, pc_ldl, pc_lld, pc_lod, pc_dec,
   pc_inc, pc_ind, pc_lbf, pc_lbu, pc_cop, pc_cbf, pc_cpi, pc_cpo,
   pc_tri:
      TypeOf := op^.optype;

   pc_lad, pc_lao, pc_lca, pc_lda, pc_psh, pc_ixa:
      TypeOf := cgULong;

   pc_nop, pc_bnt, pc_ngi, pc_not, pc_adi, pc_and, pc_lnd, pc_bnd,
   pc_bor, pc_bxr, pc_dvi, pc_equ, pc_geq, pc_grt, pc_leq, pc_les,
   pc_neq, pc_ior, pc_lor, pc_mod, pc_mpi, pc_sbi, pc_shl, pc_shr:
      TypeOf := cgWord;

   pc_udi, pc_uim, pc_umi, pc_usr:
      TypeOf := cgUWord;
                         
   pc_bnl, pc_ngl, pc_adl, pc_bal, pc_blr, pc_blx, pc_dvl, pc_mdl,
   pc_mpl, pc_sbl, pc_sll, pc_slr:
      TypeOf := cgLong;

   pc_udl, pc_ulm, pc_uml, pc_vsr:
      TypeOf := cgULong;

   pc_ngr, pc_adr, pc_dvr, pc_mpr, pc_sbr:
      TypeOf := cgExtended;

   pc_cnn, pc_cnv:                                        
      TypeOf := baseTypeEnum(op^.q & $000F);

   pc_stk:
      TypeOf := TypeOf(op^.left);

   pc_bno:
      TypeOf := TypeOf(op^.right);

   otherwise: Error(cge1);       
   end; {case}
end; {TypeOf}


procedure CommonSubexpressionElimination;

{ Remove common subexpressions					}

type
   localPtr = ^localRecord;		{list of local temp variables}
   localRecord = record
      next: localPtr;			{next label in list}
      inUse: boolean;			{is this temp already in use?}
      size: integer;			{size of the temp area}
      lab: integer;			{label number}
      end;

var
   bb: blockPtr;			{used to trace basic block lists}
   done: boolean;			{for loop termination tests}
   op: icptr;				{used to trace operation lists, trees}
   lop: icptr;				{predecessor of op}
   temps: localPtr;			{list of temp variables}


   procedure DisposeTemps;

   { dispose of the list of temp variables			}

   var
      tp: localPtr;			{temp pointer}

   begin {DisposeTemps}
   while temps <> nil do begin
      tp := temps;
      temps := tp^.next;
      dispose(tp);
      end; {while}
   end; {DisposeTemps}


   function GetTemp (bb: blockPtr; size: integer): integer;

   { Allocate a temp storage location				}
   {								}
   { parameters:						}
   {    bb - block in which the temp is allocated		}
   {    size - size of the temp					}
   {								}
   { Returns: local label number for the temp			}

   var
      lab: integer;			{label number}
      loc: icptr;			{for dc_loc instruction}
      tp: localPtr;			{used to trace lists, allocate new items}

   begin {GetTemp}
   lab := 0;				{no label found, yet}
   tp := temps;				{try for a temp of the exact size}
   while tp <> nil do begin
      if not tp^.inUse then
         if tp^.size = size then begin
            lab := tp^.lab;
            tp^.inUse := true;
            tp := nil;
            end; {if}
      if tp <> nil then
         tp := tp^.next;
      end; {while}
   if lab = 0 then begin		{try for a larger temp}
      tp := temps;
      while tp <> nil do begin
	 if not tp^.inUse then
            if tp^.size > size then begin
               lab := tp^.lab;
               tp^.inUse := true;
               tp := nil;        
               end; {if}
	 if tp <> nil then
            tp := tp^.next;
	 end; {while}
      end; {if}
   if lab = 0 then begin		{allocate a new temp}
      loc := pointer(Calloc(sizeof(intermediate_code)));
      loc^.opcode := dc_loc;
      loc^.optype := cgWord;
      maxLoc := maxLoc + 1;
      loc^.r := maxLoc;
      lab := maxLoc;
      loc^.q := size;
      if bb^.code = nil then begin
	 loc^.next := nil;
	 bb^.code := loc;
         end {if}
      else begin
	 loc^.next := bb^.code^.next;
	 bb^.code^.next := loc;
         end; {else}
      new(tp);
      tp^.next := temps;
      temps := tp;
      tp^.inUse := true;
      tp^.size := loc^.q;
      tp^.lab := lab;
      end; {if}
   GetTemp := lab;			{return the temp label number}
   end; {GetTemp}


   procedure ResetTemps;

   { Mark all temps as available				}

   var
      tp: localPtr;			{temp pointer}

   begin {ResetTemps}
   tp := temps;
   while tp <> nil do begin
      tp^.inUse := false;
      tp := tp^.next;
      end; {while}
   end; {ResetTemps}


   procedure CheckForBlocks (op: icptr);

   { Scan a tree for blocked instructions			}
   {								}
   { parameters:						}
   {    op - tree to check					}
   {								}
   { Notes: Some code takes less time to execute than saving	}
   {    and storing the intermediate value.  This subroutine	}
   {    identifies such patterns.				}


      function Block (op: icptr): boolean;

      { See if the pattern should be blocked			}
      {								}
      { parameters:						}
      {    op - pattern to check				}
      {								}
      { Returns: True if the pattern should be blocked, else	}
      {    false.						}

      var
         opcode: pcodes;		{temp opcode}

      begin {Block}
      Block := false;
      opcode := op^.opcode;
      if opcode = pc_ixa then begin
         if op^.left^.opcode in [pc_lao,pc_lca,pc_lda] then
            Block := true;
         end {else if}
      else if opcode = pc_shl then begin
         if op^.right^.opcode = pc_ldc then
            if op^.right^.q = 1 then
               if op^.parents <= 3 then
                  Block := true;
         end {else if}
      else if opcode = pc_stk then
         Block := true
      else if opcode = pc_cnv then
         if op^.q & $000F = ord(cgVoid) then
            Block := true;
      end; {Block}


      function Max (a, b: integer): integer;

      { Return the larger of two integers			}
      {								}
      { parameters:						}
      {    a, b - integers to check				}
      {								}
      { Returns: a if a > b, else b				}

      begin {Max}
      if a > b then
         Max := a
      else
         Max := b;
      end; {Max}


   begin {CheckForBlocks}
   if Block(op) then begin
      if op^.left <> nil then		{handle a blocked instruction}
         op^.left^.parents := op^.left^.parents + Max(op^.parents - 1, 0);
      if op^.right <> nil then
         op^.right^.parents := op^.right^.parents + Max(op^.parents - 1, 0);
      op^.parents := 1;
      end; {if}
   if op^.left <> nil then		{check the children}
      CheckForBlocks(op^.left);
   if op^.right <> nil then
      CheckForBlocks(op^.right);
   end; {CheckForBlocks}


   procedure CheckTree (var op: icptr; bb: blockPtr);

   { check the trees used by op for common subexpressions	}
   {								}
   { parameters:						}
   {    op - operation to check					}
   {    bb - start of the current BASIC block			}

   var
      op2: icptr;			{result from Match calls}
      op3: icptr;			{used to trace the codes in a block}


      function Match (var op: icptr; tree: icptr): icptr;

      { Check for matches to op in tree				}
      {								}
      { parameters:						}
      {    op - operation to check				}
      {    tree - tree to examine for matches			}
      {								}
      { Returns: pointer to matching node or nil if none found	}

      var
         op2: icptr;			{result from recursive Match calls}
         kill, start, stop: boolean;	{used by Scan}
         skip: boolean;			{used to see if children should be scanned}


         procedure Combine (var op1, op2: icptr);

         { Op2 is a save or copy of the same value as op1; use a copy	}
         { for op2.							}
         {								}
         { parameters:							}
         {    op1 - first copy or save					}
         {    op2 - copy or save to optimize				}

         var
            op3: icptr;				{work pointer}

         begin {Combine}
         done := false;				{force another labeling pass}
	 op3 := op2;				{remove op2 from the list}
         if op3^.opcode in [pc_str,pc_sro] then begin
            if op3^.opcode = pc_str then
               op3^.opcode := pc_cop
            else
               op3^.opcode := pc_cpo;
            op2 := op3^.next;
            op3^.next := nil;
            end {if}
         else
            op2 := op3^.left;
         op1^.left := op3;			{place in the new location}
         end; {Combine}


         function SameTree (list, op1, op2: icptr): boolean;

         { Are op1 and op2 in the same expression tree?			}
         {								}
         { parameters:							}
         {    list - list of expression trees				}
         {    op1, op2 - operations to check				}


            function InTree (tree, op: icptr): boolean;

            { See if op is in the tree					}
            {								}
            { parameters:						}
            {    tree - expression tree to check			}
            {    op - operatio to look for				}

            begin {InTree}
            if tree = nil then
               InTree := false
            else if tree = op then
               InTree := true
            else
               InTree := InTree(tree^.left, op) or InTree(tree^.right, op);
            end; {InTree}


         begin {SameTree}
         SameTree := false;
         while list <> nil do
            if InTree(list, op1) then begin
               SameTree := InTree(list, op2);
               list := nil;
               end {if}
            else
               list := list^.next;
         end; {SameTree}


         procedure Scan (list, op1, op2: icptr);

         { Check to see if any operation between op1 and op2 kills the	}
         { optimization							}
         {								}
         { parameters:							}
         {    list - instruction stream					}
         {    op1 - starting operation					}
         {    op2 - ending operation					}
         {								}
         { globals:							}
         {    kill - set to true if the optimization must be blocked,	}
         {       or false if it can be performed			}
         {    start - has op1 been found?  (initialize to false)	}
         {    stop - has kill been set?	 (initialize to false)		}

         begin {Scan}
         if not start then			{see if it is time to start}
            if list = op1 then
               start := true;
         if list^.left <> nil then		{scan the children}
            Scan(list^.left, op1, op2);
         if not stop then
            if list^.right <> nil then
               Scan(list^.right, op1, op2);
         if start then				{check for a kill or termination}
            if not stop then
               if list = op2 then begin
        	  kill := false;
        	  stop := true;
        	  end {if}
               else if list^.opcode in [pc_str,pc_sro,pc_cop,pc_cpo,pc_lli,pc_lil,
        	  pc_lld,pc_ldl,pc_gli,pc_gil,pc_gld,pc_gdl] then begin
        	  if MatchLoc(list, op2) then begin
                     kill := true;
                     stop := true;
                     end {if}
        	  end {else if}
               else if list^.opcode in [pc_sto,pc_cpi,pc_iil,pc_ili,pc_idl,pc_ild,
        	  pc_cup,pc_cui,pc_tl1] then
        	  if Member(op1, c_ind) then begin
                     kill := true;
                     stop := true;
                     end; {if}
         if not stop then			{scan forward in the stream}
            if list^.next <> nil then
               Scan(list^.next, op1, op2);
         end; {Scan}


      begin {Match}
      op2 := nil;			{check for an exact match}
      skip := false;
      if CodesMatch(op, tree, true) then begin
         if op = tree then
            op2 := tree
         else begin
            start := false;
            stop := false;
            Scan(bb^.code, tree, op);
            if not kill then
               op2 := tree;
            end; {else}
         end {if}
					{check for stores of a common value}
      else if op^.opcode in [pc_str,pc_sro,pc_cop,pc_cpo] then
         if tree^.opcode in [pc_str,pc_sro,pc_cop,pc_cpo] then
            if op^.left = tree^.left then begin
               start := false;
               stop := false;
               Scan(bb^.code, tree, op);
               if not kill then
                  if not SameTree(bb^.code, op, tree) then
                     if (op^.left^.opcode <> pc_ldc)
                        or ((op^.left^.optype in [cgByte,cgUByte,cgWord,cgUWord])
                           and (op^.left^.q <> 0))
                        or ((op^.left^.optype in [cgLong,cgULong])
                           and (op^.left^.lval <> 0))
                        or (not (op^.left^.optype in [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong]))
                        then begin
                        Combine(tree, op);
                        skip := true;
                        end; {if}
               end; {if}
      if not skip then begin		{check for matches in the children}
         if op2 = nil then
	    if tree^.left <> nil then
               op2 := Match(op, tree^.left);
         if op2 = nil then
            if tree^.right <> nil then
               op2 := Match(op, tree^.right);
         end; {if}
      Match := op2;
      end; {Match}


   begin {CheckTree}
   op^.parents := 0;			{zero the parent counter}
   if op^.left <> nil then		{check the children}
      CheckTree(op^.left, bb);
   if op^.right <> nil then
      CheckTree(op^.right, bb);
   if op^.next = nil then		{look for a match to the current code}
      if not (op^.opcode in [pc_cup,pc_cui,pc_tl1,pc_bno]) then begin
	 op2 := nil;
	 op3 := bb^.code;
	 while (op2 = nil) and (op3 <> nil) do begin
	    op2 := Match(op, op3);
	    if op2 <> nil then
               if op2^.next = nil then begin
        	  op := op2;
        	  bb := nil;
        	  op3 := nil;
        	  end ;{if}
	    if op3 <> nil then
               op3 := op3^.next;
	    end; {while}
	 end; {if}
   end; {CheckTree}


   procedure CountParents (op: icptr);

   { increment the parent counter for all children of this node	}
   {								}
   { parameters:						}
   {    op - node for which to check the children		}

   begin {CountParents}
   if op^.parents = 0 then begin
      if op^.left <> nil then begin
	 CountParents(op^.left);
	 op^.left^.parents := op^.left^.parents + 1;
	 end; {if}
      if op^.right <> nil then begin
	 CountParents(op^.right);
	 op^.right^.parents := op^.right^.parents + 1;
	 end; {if}
      end; {if}
   end; {CountParents}


   procedure CreateTemps (var op: icptr; bb: blockPtr; var lop: icptr);

   { create temps for nodes with multiple parents		}
   {								}
   { parameters:						}
   {    op - node for which to create temps			}
   {    bb - current basic block				}
   {    lop - predecessor to op					}

   var
      children: boolean;		{does this node have children?}
      llab: integer;			{local label number; for temp}
      op2, str: icptr;			{new opcodes}
      optype: baseTypeEnum;		{type of the temp variable}

   begin {CreateTemps}
   children := false;			{create temps for the children}
   if op^.left <> nil then begin
      children := true;
      CreateTemps(op^.left, bb, lop);
      end; {if}
   if op^.right <> nil then begin
      children := true;
      CreateTemps(op^.right, bb, lop);
      end; {if}
   if children then
      if op^.parents > 1 then begin
         optype := TypeOf(op);		{create a temp label}
         llab := GetTemp(bb, TypeSize(optype));
					{make a copy of the duplicated tree}
         op2 := pointer(Calloc(sizeof(intermediate_code)));
         op2^ := op^;
         op^.opcode := pc_lod;		{substitute a load of the temp}
         op^.optype := optype;
         op^.parents := 1;
         op^.r := llab;
         op^.q := 0;
         op^.left := nil;
         op^.right := nil;
					{store the temp result}
         str := pointer(Calloc(sizeof(intermediate_code)));
         str^.opcode := pc_str;
         str^.optype := optype;
         str^.r := llab;
         str^.q := 0;
         str^.left := op2;
         if lop = nil then begin	{insert the store in the basic block}
            str^.next := bb^.code;
            bb^.code := str;
            end {if}
         else begin
            str^.next := lop^.next;
            lop^.next := str;
            end; {else}
         lop := str;
         end; {if}
   end; {CreateTemps}


begin {CommonSubexpressionElimination}
temps := nil;				{no temps allocated, yet}
repeat					{identify common parts}
   done := true;
   bb := DAGblocks;
   while bb <> nil do begin
      Spin;
      op := bb^.code;
      if op <> nil then begin
	 CheckTree(bb^.code, bb);
	 while op^.next <> nil do begin
            CheckTree(op^.next, bb);
            if op^.next <> nil then
	       op := op^.next;
	    end; {while}
	 end; {if}
      bb := bb^.next;
      end; {while}
until done;
bb := DAGblocks;			{count the number of parents}
while bb <> nil do begin
   op := bb^.code;
   Spin;
   while op <> nil do begin
      CountParents(op);
      op := op^.next;
      end; {while}
   bb := bb^.next;
   end; {while}
bb := DAGblocks;			{check for blocked instructions}
while bb <> nil do begin
   op := bb^.code;
   Spin;
   while op <> nil do begin
      CheckForBlocks(op);
      op := op^.next;
      end; {while}
   bb := bb^.next;
   end; {while}
bb := DAGblocks;			{create temps for common subexpressions}
while bb <> nil do begin
   op := bb^.code;
   lop := nil;
   ResetTemps;
   Spin;
   while op <> nil do begin
      CreateTemps(op, bb, lop);
      lop := op;
      op := op^.next;
      end; {while}
   bb := bb^.next;
   end; {while}
DisposeTemps;				{get rid of the temp variable list}
end; {CommonSubexpressionElimination}

{- Loop Optimizations ------------------------------------------}

procedure AddOperation (op: icptr; var lp: iclist);

{ Add an operation to an operation list				}
{								}
{ parameters:							}
{    op - operation to add					}
{    lp - list to add the operation to				}

var
   inList: boolean;			{is op already in the list?}
   llp: iclist;				{work pointer}

begin {AddOperation}
llp := lp;
inList := false;
while llp <> nil do
   if MatchLoc(llp^.op, op) then begin
      inList := true;
      llp := nil;
      end {if}
   else
      llp := llp^.next;
if not inList then begin
   new(llp);
   llp^.next := lp;
   lp := llp;
   llp^.op := op;
   end; {if}
end; {AddOperation}


procedure DisposeBlkList (var blk: blockListPtr);

{ dispose of all entries in the block list			}
{								}
{ parameters:							}
{    blk - list of blocks to dispose of				}

var
   bk1, bk2: blockListPtr;		{work pointers}

begin {DisposeBlkList}
bk1 := blk;
blk := nil;
while bk1 <> nil do begin
   bk2 := bk1;
   bk1 := bk2^.next;
   dispose(bk2);
   end; {while}
end; {DisposeBlkList}


procedure DisposeOpList (var oplist: iclist);

{ dispose of all entries in the list				}
{								}
{ parameters:							}
{    oplist - operation list to dispose of			}

var
   op1, op2: iclist;			{work pointers}

begin {DisposeOpList}
op1 := oplist;
oplist := nil;
while op1 <> nil do begin
   op2 := op1;
   op1 := op2^.next;
   dispose(op2);
   end; {while}
end; {DisposeOpList}


procedure DumpLoopLists;

{ dispose of lists created by ReachingDefinitions and Dominators}

var
   bb: blockPtr;			{used to trace basic block list}
   dom: blockListPtr;			{used to dispose of a dominator}
   
begin {DumpLoopLists}
bb := DAGBlocks;
while bb <> nil do begin
   DisposeOpList(bb^.c_in);		{dump the reaching definition lists}
   DisposeOpList(bb^.c_out);
   DisposeOpList(bb^.c_gen);
   DisposeBlkList(bb^.dom);
   while bb^.dom <> nil do begin	{dump the dominator lists}
      dom := bb^.dom;
      bb^.dom := dom^.next;
      dispose(dom);
      end; {while}
   bb := bb^.next;
   end; {while}
end; {DumpLoopLists}


procedure AddLoads (jp: icptr; var lp: iclist);

{ Add any load addresses from the children of this		}
{ operation							}
{								}
{ parameters:							}
{    jp - operation to check					}
{    lp - list to add the loads to				}

begin {AddLoads}
if jp^.opcode in [pc_lda,pc_lao,pc_lod,pc_lod] then
   AddOperation(jp, lp)
else begin
   if jp^.left <> nil then
      AddLoads(jp^.left, lp);
   if jp^.right <> nil then
      AddLoads(jp^.right, lp);
   end {else}
end; {AddLoads}


procedure FlagIndirectUses;

{ Find all variables that could be changed by an indirect	}
{ access.							}

var
   bb: blockPtr;			{used to trace block list}


   procedure Check (op: icptr; doingInd: boolean);

   { Check op and its children & followers for dangerous	}
   { references							}
   {								}
   { parameters:						}
   {    op - operation to check					}
   {    doingInd - are we doing a pc_ind?  If so, pc_lda's	}
   {       are safe						}

   var
      lDoingInd: boolean;		{local doingInd}

   begin {Check}
   while op <> nil do begin
      if op^.opcode = pc_ind then
         lDoingInd := true
      else
         lDoingInd := doingInd;
      if op^.left <> nil then
         Check(op^.left, lDoingInd);
      if op^.right <> nil then
         Check(op^.right, lDoingInd);
      if op^.opcode in [pc_lao,pc_cpo,pc_ldo,pc_sro,pc_gil,pc_gli,
         pc_gdl,pc_gld] then
         AddOperation(op, c_ind)
      else if op^.opcode = pc_ind then begin
         if op^.left^.opcode = pc_ind then
            AddLoads(op^.left^.left, c_ind);
         end {else if}
      else if op^.opcode = pc_lda then
         if not doingInd then
            AddOperation(op, c_ind);
      op := op^.next;
      end; {while}
   end; {Check}


begin {FlagIndirectUses}
c_ind := nil;
bb := DAGBlocks;
while bb <> nil do begin
   Check(bb^.code, false);
   bb := bb^.next;
   end; {while}
end; {FlagIndirectUses}


procedure DoLoopOptimization;

{ Perform optimizations related to loops and data flow		}

type
   dftptr = ^dftrecord;			{depth first tree edges}
   dftrecord = record
      next: dftptr;
      from, dest: blockPtr;
      end;

var
   backEdge: dftptr;			{list of back edges}
   dft: dftptr;				{depth first tree}
   dft2: dftptr;			{work pointer}


   function DFN (i: integer): blockPtr;

   { find the basic block with dfn index of i			}
   {								}
   { parameters:						}
   {    i - index to look for					}
   {								}
   { Returns: block pointer, or nil if there is none		}

   var
      bb: blockPtr;			{used to trace block list}

   begin {DFN}
   bb := DAGBlocks;
   DFN := nil;
   while bb <> nil do begin
      if bb^.dfn = i then begin
         DFN := bb;
         bb := nil;
         end
      else
         bb := bb^.next;
      end; {while}
   end; {DFN}


   function MemberDFNList (dfn: integer; bl: blockListPtr): boolean;

   { See if dfn is a member of the list bl			}
   {								}
   { parameters:						}
   {    dfn - block number to check				}
   {    bl - list of block numbers to check			}
   {								}
   { Returns: True if dfn is in bl, else false.			}

   begin {MemberDFNList}
   MemberDFNList := false;
   while bl <> nil do
      if bl^.dfn = dfn then begin
         MemberDFNList := true;
         bl := nil;
         end {if}
      else
         bl := bl^.next;
   end; {MemberDFNList}


   function FindDAG (q: integer): blockPtr;

   { Find the DAG containing label q				}
   {								}
   { parameters:						}
   {    q - label to find					}
   {								}
   { Returns: pointer to the proper basic block			}

   var
      bb: blockPtr;			{used to trace basic block list}

   begin {FindDAG}
   bb := DAGBlocks;
   FindDAG := nil;
   while bb <> nil do begin
      if bb^.code^.opcode = dc_lab then
         if bb^.code^.q = q then begin
            FindDAG := bb;
            bb := nil;
            end; {if}
      if bb <> nil then
         bb := bb^.next;
      end; {while}
   end; {FindDAG}


   procedure DepthFirstOrder;

   { Number the DAG for depth first order			}

   var
      bb: blockPtr;			{used to trace basic block lists}
      i: integer;			{dfn index}


      procedure Search (bb: blockPtr);

      { Search this block					}
      {								}
      { parameters:						}
      {    bb - basic block to search				}

      var
         blk: blockPtr;			{work block}
         ndft: dftptr;			{for new tree entries}
         op: icptr;			{used to trace operation list}


         function NotUnconditional: boolean;

         { See if the block ends with something other than an	}
         { unconditional jump					}
         {							}
         { Returns: True if the block ends with something other	}
         {    than pc_ujp or pc_add, else false			}

         var
            op: icptr;			{used to trace the list}

         begin {NotUnconditional}
         NotUnconditional := true;
         op := bb^.code;
         if op <> nil then begin
            while op^.next <> nil do
               op := op^.next;
            if op^.opcode in [pc_add,pc_ujp] then
               NotUnconditional := false;
            end; {if}
         end; {NotUnconditional}


      begin {Search}
      Spin;
      if bb <> nil then
	 if not bb^.visited then begin
	    bb^.visited := true;
            if NotUnconditional then
               if bb^.next <> nil then begin
                  new(ndft);
                  ndft^.next := dft;
                  dft := ndft;
                  ndft^.from := bb;
                  ndft^.dest := bb^.next;
                  Search(bb^.next);
                  end; {if}
	    op := bb^.code;
	    while op <> nil do begin
               if op^.opcode in [pc_ujp, pc_fjp, pc_tjp, pc_add] then begin
                  blk := FindDAG(op^.q);
                  new(ndft);
                  if blk^.visited then begin
                     ndft^.next := backEdge;                        
                     backEdge := ndft;
                     end {if}
                  else begin
                     ndft^.next := dft;
                     dft := ndft;
        	     Search(blk);
                     end; {else}
                  ndft^.from := bb;
                  ndft^.dest := blk;
                  end; {if}
               op := op^.next;
               end; {while}
            bb^.dfn := i;
            i := i-1;
            end; {if}
      end; {Search}


   begin {DepthFirstOrder}
   dft := nil;
   backEdge := nil;
   i := 0;
   bb := DAGblocks;
   while bb <> nil do begin
      bb^.visited := false;
      i := i+1;
      bb := bb^.next;
      end; {while}
   Search(DAGBlocks);
   end; {DepthFirstOrder}


   procedure Dominators;

   { Find a list of dominators for each node			}

   var
      bb: blockPtr;			{used to trace the block list}
      change: boolean;			{for loop termination test}
      i, j: integer;			{loop variables}
      maxdfn, mindfn: integer;		{max and min dfn values used}


      procedure Add (var dom: blockListPtr; dfn: integer);

      { Add dfn to the list of dominators			}
      {								}
      { parameters:						}
      {    dom - dominator list					}
      {    dfn - new dominator number				}

      var
         dp: blockListPtr;		{new node}

      begin {Add}
      new(dp);
      dp^.last := nil;
      dp^.next := dom;
      dom^.last := dp;
      dom := dp;
      dp^.dfn := dfn;
      end; {Add}


      procedure CheckPredecessors (bb: blockPtr; bl: dftptr);

      { Eliminate nodes that don't dominate a predecessor	}
      {								}
      { parameters:						}
      {    bb - block being checked				}
      {    bl - list of edges to check for predecessors		}

      var
         dp: blockListPtr;		{list of dominator numbers}
         tdp: blockListPtr;		{used to remove a dominator entry}

      begin {CheckPredecessors}
      while bl <> nil do begin
         if bl^.dest = bb then begin
            dp := bb^.dom;
            while dp <> nil do
               if dp^.dfn <> bb^.dfn then
                  if not MemberDFNList(dp^.dfn, bl^.from^.dom) then begin
                     change := true;
                     tdp := dp;
                     if tdp^.last = nil then
                        bb^.dom := tdp^.next
                     else
                        tdp^.last^.next := tdp^.next;
                     if tdp^.next <> nil then
                        tdp^.next^.last := tdp^.last;
                     dp := tdp^.next;
                     dispose(tdp);
                     end {if}
                  else
                     dp := dp^.next
               else
                  dp := dp^.next;
            end; {if}
         bl := bl^.next;
         end; {while}
      end; {CheckPredecessors}


   begin {Dominators}
   Spin;
   maxdfn := 0;				{find the largest dfn}
   bb := DAGBlocks;
   while bb <> nil do begin
      if bb^.dfn > maxdfn then
         maxdfn := bb^.dfn;
      bb := bb^.next;
      end; {while}
   Add(DAGBlocks^.dom, DAGBlocks^.dfn);	{the first node is it's own dominator}
   mindfn := DAGBlocks^.dfn;		{assume all other nodes are dominated by every other node}
   for i := mindfn+1 to maxdfn do begin
      bb := DFN(i);
      if bb <> nil then
         for j := mindfn to maxdfn do
            Add(bb^.dom, j);
      end; {for}
   repeat				{iterate to the true set of dominators}
      change := false;
      for i := mindfn+1 to maxdfn do begin
         bb := DFN(i);
         CheckPredecessors(bb, dft);
         CheckPredecessors(bb, backEdge);
         end; {for}
   until not change;
   end; {Dominators}


   procedure ReachingDefinitions;

   { find the list of reaching definitions for each basic block	}

   var
      bb: blockPtr;			{block being scanned}
      change: boolean;			{loop termination test}
      i: integer;			{node index number}
      newIn: iclist;			{list of inputs}


      function Gen (op: icptr): iclist;

      { find a list of generated values				}
      {								}
      { parameters:						}
      {    op - list of intermediate codes to scan		}
      {								}
      { Returns: list of generated definitions			}

      var
         gp: iclist;			{list of generated definitions}
         indFound: boolean;		{has an indirect store been found?}


         procedure Check (ip: icptr);

         { Add any result from ip to gp				}
         {							}
         { parameters:						}
         {    ip - instruction to check				}

         var
            lc_ind: iclist;		{used to trace the c_ind list}

         begin {Check}
         if ip^.left <> nil then
            Check(ip^.left);
         if ip^.right <> nil then
            Check(ip^.right);
         if ip^.opcode in
            [pc_str,pc_sro,pc_cop,pc_cpo,pc_lli,pc_lil,pc_lld,pc_ldl,
             pc_gli,pc_gil,pc_gld,pc_gdl] then
            AddOperation(ip, gp)
         else if ip^.opcode in [pc_mov,pc_sto,pc_cpi,pc_iil,pc_ili,pc_idl,pc_ild] then
            AddLoads(ip, gp);
         if not indFound then
            if ip^.opcode in
               [pc_sto,pc_cpi,pc_iil,pc_ili,pc_idl,pc_ild,pc_cup,pc_cui,pc_tl1]
                then begin
               lc_ind := c_ind;
               while lc_ind <> nil do begin
                  AddOperation(lc_ind^.op, gp);
                  lc_ind := lc_ind^.next;
                  end; {while}
               indFound := true;
               end; {if}
         end; {Check}                                         


      begin {Gen}
      indFound := false;
      gp := nil;
      while op <> nil do begin
         Check(op);
         op := op^.next;
         end; {while}
      Gen := gp;
      end; {Gen}


      function EqualSets (l1, l2: iclist): boolean;

      { See if two sets of stores and copies are equivalent	}
      {								}
      { parameters:						}
      {    l1, l2 - lists of copies and stores			}
      {								}
      { Returns: True if the lists are equivalent, else false	}
      {								}
      { Notes: The members of each list are assumed to be	}
      {    unique within that list.				}

      var
         c1, c2: integer;		{number of elements in the sets}
         l3: iclist;			{used to trace the lists}
         matchFound: boolean;		{was a match found?}

      begin {EqualSets}
      EqualSets := false;		{assume they are not equal}
      c1 := 0;				{count the elements of l1}
      l3 := l1;
      while l3 <> nil do begin
         c1 := c1+1;
         l3 := l3^.next;
         end; {while}
      c2 := 0;				{count the elements of l2}
      l3 := l2;
      while l3 <> nil do begin
         c2 := c2+1;
         l3 := l3^.next;
         end; {while}
      if c1 = c2 then begin		{make sure each member of l1 is in l2}
         EqualSets := true;
         while l1 <> nil do begin
            matchFound := false;
            l3 := l2;
            while l3 <> nil do begin
               if MatchLoc(l1^.op, l3^.op) then begin
                  l3 := nil;
                  matchFound := true;
                  end {if}
               else
                  l3 := l3^.next;
               end; {while}
            if not matchFound then begin
               EqualSets := false;
               l1 := nil;
               end {if}
            else
               l1 := l1^.next;
            end; {while}
         end; {if}
      end; {EqualSets}


      function Union (l1, l2: iclist): iclist;

      { Returns a list that is the union of two input lists	}
      {								}
      { parameters:						}
      {    l1, l2 - lists					}
      {								}
      { Returns: New, dynamically allocated list that includes	}
      {    all of the members in l1 and l2.			}
      {								}
      { Notes:							}
      {    1.  If there are duplicates, the member from l1 is	}
      {        returned.					}
      {    2.  It is assumed that all members of l1 and l2 are	}
      {        unique within their own list.			}
      {    3.  The original lists are not disturbed.		}
      {    4.  The caller is responsible for disposing of the	}
      {        memory used by the list.				}

      var
         lp: iclist;			{new list pointer}
         np: iclist;			{new list member pointer}
         tp: iclist;			{temp list pointer}

      begin {Union}
      lp := nil;
      tp := l1;
      while tp <> nil do begin
         new(np);
         np^.next := lp;
         lp := np;
         np^.op := tp^.op;
         tp := tp^.next;
         end; {while}
      while l2 <> nil do begin
         if not Member(l2^.op, l1) then begin
            new(np);
            np^.next := lp;
            lp := np;
            np^.op := l2^.op;
            end; {if}
         l2 := l2^.next;
         end; {while}
      Union := lp;
      end; {Union}


      function UnionOfPredecessors (bptr: blockPtr): iclist;

      { create a union of the outputs of predecessors to bptr	}
      {								}
      { parameters:						}
      {    bptr - block for which to look for predecessors	}
      {								}
      { Returns: Resulting set					}

      var
         bp: dftptr;			{used to trace edge lists}
         plist: iclist;			{result list}
         tlist: iclist;			{temp result list}

      begin {UnionOfPredecessors}
      plist := nil;
      bp := dft;
      while bp <> nil do begin
         if bp^.dest = bptr then begin
            tlist := Union(plist, bp^.from^.c_out);
            DisposeOpList(plist);
            plist := tlist;
            end; {if}
         bp := bp^.next;
         end; {while}
      bp := backEdge;
      while bp <> nil do begin
         if bp^.dest = bptr then begin
            tlist := Union(plist, bp^.from^.c_out);
            DisposeOpList(plist);
            plist := tlist;
            end; {if}
         bp := bp^.next;
         end; {while}
      UnionOfPredecessors := plist;
      end; {UnionOfPredecessors}


   begin {ReachingDefinitions}
   i := 1;				{initialize the lists}
   repeat
      bb := DFN(i);
      if bb <> nil then begin
         bb^.c_in := nil;
         bb^.c_gen := Gen(bb^.code);
         bb^.c_out := Union(nil, bb^.c_gen);
         end; {if}
      i := i+1;
   until bb = nil;
   repeat				{iterate to a solution}
      change := false;
      i := 1;
      repeat
	 Spin;
         bb := DFN(i);
         if bb <> nil then begin
            newIn := UnionOfPredecessors(bb);
            if not EqualSets(bb^.c_in, newIn) then begin
               {IN[n] := newIn}
               DisposeOpList(bb^.c_in);
               bb^.c_in := newIn;
               newIn := nil;
               {OUT[n] := IN[n] - KILL[n] U GEN[n]}
               DisposeOpList(bb^.c_out);
               bb^.c_out := Union(bb^.c_in, nil);
               change := true;
               end; {if}
            DisposeOpList(newIn);
            end; {if}
         i := i+1;
      until bb = nil;
   until not change;
   end; {ReachingDefinitions}


   procedure LoopInvariantRemoval;

   { Remove all loop invariant computations			}

   type
      loopPtr = ^loopRecord;		{blocks in a list}
      loopRecord = record
	 next: loopPtr;			{next entry}
	 block: blockPtr;		{code block}
         exit: boolean;			{is this a loop exit?}
	 end;

      loopListPtr = ^loopListRecord;	{list of loop lists}
      loopListRecord = record
	 next: loopListPtr;
	 loop: loopPtr;
	 end;

   var
      icount: integer;			{order invariant found}
      loops: loopListPtr;		{list of loops}
      lp: loopPtr;			{used to trace loop lists}
      llp: loopListPtr;			{used to trace the list of loops}



      procedure FindLoops;

      { Create a list of the natural loops			}

      var
         blk: blockPtr;			{target block for a jump}
	 bp: dftptr;			{used to trace the back edges}
         lp, lp2: loopPtr;		{used to reverse the list}
	 llp: loopListPtr;		{loop list header entry}
	 llp2: loopListPtr;		{used to reverse the list}
         op: icptr;			{used to trace the opcode list}


	 procedure Add (block: blockPtr);

	 { Add a block to the current loop list				}
	 {								}
	 { parameters:							}
	 {    block - block to add					}

	 var
            lp: loopPtr;			{new loop entry}

	 begin {Add}
	 new(lp);
	 lp^.next := llp^.loop;
	 llp^.loop := lp;
	 lp^.block := block;
         lp^.exit := false;
	 end; {Add}


         function InLoop (blk: blockPtr; lp: loopPtr): boolean;

         { See if the block is in the loop				}
         {								}
         { parameters:							}
         {    blk - block to check for					}
         {    lp - loop list						}
         {								}
         { Returns: True if blk is in the list, else false		}

         begin {InLoop}
         InLoop := false;
         while lp <> nil do begin
            if lp^.block = blk then begin
               lp := nil;
               InLoop := true;
               end {if}
            else
               lp := lp^.next;
            end; {while}
         end; {InLoop}


	 procedure Insert (block: blockPtr);

	 { Insert a block into the loop list				}
	 {								}
	 { parameters:							}
	 {    block - block to add					}


            procedure AddPredecessors (block: blockPtr; bl: dftptr);

            { add any predecessors to the loop				}
            {								}
            { parameters:						}
            {    block - block for which to check for			}
            {       predecessors					}
            {    bl - list of edges to check				}

            begin {AddPredecessors}
            while bl <> nil do begin
               if bl^.dest = block then
        	  Insert(bl^.from);
               bl := bl^.next;
               end; {while}
            end; {AddPredecessors}


            function InLoop (block: blockPtr; lp: loopPtr): boolean;

            { See if a block is in the loop				}
            {								}
            { parameters:						}
            {    block - block to check					}
            {    lp - list of blocks in the loop			}
            {								}
            { Returns: True if the block is in the loop, else false	}

            begin {InLoop}
            InLoop := false;
            while lp <> nil do
               if lp^.block = block then begin
        	  InLoop := true;
        	  lp := nil;
        	  end {if}
               else
        	  lp := lp^.next;
            end; {InLoop}


	 begin {Insert}
	 if not InLoop(block, llp^.loop) then begin
            Add(block);
            AddPredecessors(block, dft);
            AddPredecessors(block, backEdge);
            end; {if}
	 end; {Insert}


      begin {FindLoops}
      loops := nil;
      bp := backEdge;			{scan the back edges}
      while bp <> nil do begin
	 if MemberDFNList(bp^.dest^.dfn, bp^.from^.dom) then begin
            new(llp);			{create a new loop list entry}
            llp^.next := loops;
            loops := llp;
            llp^.loop := nil;
            Add(bp^.dest);
            Insert(bp^.from);
            lp := llp^.loop;		{reverse the list}
            llp^.loop := nil;
            while lp <> nil do begin
               lp2 := lp;
               lp := lp2^.next;
               lp2^.next := llp^.loop;
               llp^.loop := lp2;
               end; {while}
            lp := llp^.loop;		{mark the exits}
            while lp <> nil do begin
               op := lp^.block^.code;
               while op <> nil do begin
        	  if op^.opcode in [pc_ujp, pc_fjp, pc_tjp, pc_add] then begin
                     blk := FindDAG(op^.q);
                     if not InLoop(blk, llp^.loop) then
                        lp^.exit := true;
                     if op^.opcode in [pc_fjp,pc_tjp] then
                        if not InLoop(lp^.block^.next, llp^.loop) then
                           lp^.exit := true;
                     end; {if}
                  op := op^.next;                        
                  end; {while}
               lp := lp^.next;
               end; {while}
            end; {if}
	 bp := bp^.next;
	 end; {while}
      llp := loops;			{reverse the loop list}
      loops := nil;
      while llp <> nil do begin
	 llp2 := llp;
	 llp := llp2^.next;
	 llp2^.next := loops;
	 loops := llp2;
	 end; {while}
      end; {FindLoops}


      function MarkInvariants (lp: loopPtr): boolean;

      { Make a pass over the opcodes, marking those that are	}
      { invariant.						}
      {								}
      { parameters:						}
      {    lp - loop to scan					}
      {								}
      { Returns: True if any new nodes were marked, else false.	}

      var
         count: integer;		{number of generating blocks}
         indirectStores: boolean;	{does the loop contain indirect stores or function calls?}
         inhibit: boolean;		{inhibit stores?}
         lp2: loopPtr;			{used to trace the loop}
         op: icptr;			{used to trace the instruction list}
         opcode: pcodes;		{op^.opcode; for efficiency}


         procedure Check (op: icptr; olp: loopPtr);

         { See if this node or its children is invariant		}
         {								}
         { parameters:							}
         {    op - node to check					}
         {    olp - loop entry for the block containing the store	}

         var
            invariant: boolean;		{are the operands invariant?}


            function IndirectInhibit (op: icptr): boolean;

            { See if a store should be inhibited due to indirect	}
            { accesses							}
            {								}
            { parameters:						}
            {    op - instruction to check				}
            {								}
            { Returns: True if the instruction should be inhibited,	}
            {    else false.						}

            begin {IndirectInhibit}
            IndirectInhibit := false;
            if indirectStores then
               if Member(op, c_ind) then
                  IndirectInhibit := true;
            end; {IndirectInhibit}


            function NoOtherStoresOrUses (lp, olp: loopPtr; op: icptr): boolean;

            { Check for invalid stores					}
            {								}
            { parameters:						}
            {    lp - loop to check					}
            {    olp - loop entry for the block containing the store	}
            {    op - store to check					}
            {								}
            { Returns: True if the store is valid, false if not.	}
            {								}
            { Notes: Specifically, these two rules are inforced:	}
            {    1. No other stores to the same location appear in the	}
            {       loop.						}
            {    2. All uses of the value in the loop can be reached	}
            {       only by the assign.					}

            var
               lp2: loopPtr;			{used to trace the loop list}
               op2: icptr;			{used to trace code list}


               function SafeLoad (sop, lop: icptr; sbk, lbk: blockPtr): boolean;

               { See if a load is in a safe position			}
               {							}
               { parameters:						}
               {    sop - save opcode that may need to be left in loop	}
               {    lop - load operation that may inhibit the save	}
               {    sbk - block containing the save			}
               {    lbk - block containing the load			}


                  function First (op1, op2, stream: icptr): icptr;

                  { See which operation comes first				}
                  {								}
                  { parmeters:							}
                  {    op1, op2 - instructions to check				}
                  {    stream - start of block containing the instructions	}
                  {								}
                  { Returns: First operation found, or nil if missing		}

                  var
                     op: icptr;				{temp opcode}

                  begin {First}
                  if stream = op1 then
                     First := op1
                  else if stream = op2 then
                     First := op2
                  else begin
                     op := nil;
                     if stream^.left <> nil then
                        op := First(op1, op2, stream^.left);
                     if op = nil then
                        if stream^.right <> nil then
                           op := First(op1, op2, stream^.right);
                     if op = nil then
                        if stream^.next <> nil then
                           op := First(op1, op2, stream^.next);
                     First := op;
                     end; {else}     
                  end; {First}


               begin {SafeLoad}
               if sbk = lbk then
                  SafeLoad := First(sop, lop, sbk^.code) = sop
               else
                  SafeLoad := MemberDFNList(sbk^.dfn, lbk^.dom);
               end; {SafeLoad}


               function MatchStores (op, tree: icptr; opbk, treebk: blockPtr):
                  boolean;

               { Check the tree for stores to the same location as op	}
               {							}
               { parameters:						}
               {    op - store to check for				}
               {    tree - operation tree to check			}
               {    opbk - block containing op				}
               {    treebk - block containing tree			}
               {							}
               { Returns: True if there are matching stores, else false	}

               var
                  result: boolean;		{function result}

               begin {MatchStores}
               result := false;
               if tree^.opcode in [pc_lli,pc_lil,pc_lld,pc_ldl,pc_str,pc_cop,
                  pc_sro,pc_cpo,pc_gli,pc_gil,pc_gld,pc_gdl] then begin
                  if tree <> op then 
                     result := MatchLoc(op, tree);
                  end {if}
               else if tree^.opcode in [pc_ldo,pc_lod] then
                  if MatchLoc(op, tree) then
                     result := not SafeLoad(op, tree, opbk, treebk);
               if not result then
                  if tree^.left <> nil then
                     result := MatchStores(op, tree^.left, opbk, treebk);
               if not result then
                  if tree^.right <> nil then
                     result := MatchStores(op, tree^.right, opbk, treebk);
               MatchStores := result;
               end; {MatchStores}


            begin {NoOtherStoresOrUses}
            NoOtherStoresOrUses := true;
            lp2 := lp;
            while lp2 <> nil do begin
               op2 := lp2^.block^.code;
               while op2 <> nil do
                  if MatchStores(op, op2, olp^.block, lp2^.block) then begin
                     op2 := nil;
                     lp2 := nil;
                     NoOtherStoresOrUses := false;
                     end {if}
                  else
                     op2 := op2^.next;
               if lp2 <> nil then
                  lp2 := lp2^.next;
               end; {while}
            end; {NoOtherStoresOrUses}


            function NumberOfGens (op: icptr; lp: loopPtr): integer;

            { Count the number of nodes that generate op		}
            {								}
            { parameters:						}
            {    op - instruction to check				}
            {    lp - loop to check					}

            var
               count: integer;			{number of generators}

            begin {NumberOfGens}
            count := 0;
            while lp <> nil do begin
               if Member(op, lp^.block^.c_gen) then
                  count := count+1;
               lp := lp^.next;
               end; {while}
            NumberOfGens := count;
            end; {NumberOfGens}


            function PreviousStore (op, list: icptr): boolean;

            { See if the last save was invariant			}
            {								}
            { parameters:						}
            {    op - load operation					}
            {    list - block containing the load			}
            {								}
            { Returns: True if the previous store was invariant, else	}
            {    false.							}

            var
               indop: icptr;			{any indirect operation after strop}
               strop: icptr;			{last matching store before op}


               procedure Check (lop: icptr);

               { Stop if this is lop; save if it is a matching store	}
               {							}
               { parameters:						}
               {    lop - check this operation and it's children	}

               begin {Check}
               if lop^.left <> nil then
                  Check(lop^.left);
               if list <> nil then
                  if lop^.right <> nil then
                     Check(lop^.right);
               if list <> nil then
                  if lop = op then
                     list := nil
                  else if (lop^.opcode in [pc_str,pc_cop,pc_str,pc_cop])
                     and MatchLoc(op, lop) then begin
                     strop := lop;
                     indop := nil;
                     end {else if}
                  else if op^.opcode in
                     [pc_sto,pc_cpi,pc_iil,pc_ili,pc_idl,pc_ild,pc_cup,pc_cui,pc_tl1]
                     then
                     indop := op;
               end; {Check}


               function Inhibit (indop, op: icptr): boolean;

               { See if op should be inhibited due to indirect stores	}
               {							}
               { parameters:						}
               {    indop - inhibiting indirect store or nil		}
               {    op - instruction to check				}

               begin {Inhibit}
               Inhibit := false;
               if indop <> nil then
                  if Member(op, c_ind) then
                     Inhibit := true;
               end; {Inhibit}


            begin {PreviousStore}
            indop := nil;
            strop := nil;
            while list <> nil do begin
               Check(list);
               if list <> nil then
                  list := list^.next;
               end; {while}
            PreviousStore := false;
            if strop <> nil then
               if strop^.parents <> 0 then
                  if not Inhibit(indop, op) then
                     PreviousStore := true;
            end; {PreviousStore}


         begin {Check}
         if op^.parents = 0 then begin
            invariant := true;
            if op^.left <> nil then begin
               Check(op^.left, olp);
               if op^.left^.parents = 0 then
        	  invariant := false;
               end; {if}
            if op^.right <> nil then begin
               Check(op^.right, olp);
               if op^.right^.parents = 0 then
        	  invariant := false;
               end; {if}
            if invariant then begin
               opcode := op^.opcode;
               if opcode in
        	  [pc_adi,pc_adl,pc_adr,pc_and,pc_lnd,pc_bnd,pc_bal,
                   pc_bnt,pc_bnl,pc_bor,pc_blr,pc_bxr,pc_blx,pc_bno,
                   pc_dec,pc_dvi,pc_udi,pc_dvl,pc_udl,pc_dvr,pc_equ,pc_neq,
                   pc_grt,pc_les,pc_geq,pc_leq,pc_inc,pc_ind,pc_ior,pc_lor,
                   pc_ixa,pc_lad,pc_lao,pc_lca,pc_lda,pc_ldc,pc_mod,pc_uim,
                   pc_mdl,pc_ulm,pc_mpi,pc_umi,pc_mpl,pc_uml,pc_mpr,pc_ngi,
                   pc_ngl,pc_ngr,pc_not,pc_pop,pc_sbf,pc_sbi,pc_sbl,pc_sbr,
                   pc_shl,pc_sll,pc_shr,pc_usr,pc_slr,pc_vsr,pc_tri]
                  then begin
        	  op^.parents := icount;
                  icount := icount+1;
                  end {if}
               else if opcode = pc_cnv then begin
        	  if op^.q & $000F <> ord(cgVoid) then begin
        	     op^.parents := icount;
                     icount := icount+1;
                     end; {if}
                  end {else if}
               else if opcode
                  in [pc_sro,pc_sto,pc_str,pc_cop,pc_cpo,pc_cpi,pc_cbf]
                  then begin
                  if not inhibit then
                     if not IndirectInhibit(op) then
                	if NoOtherStoresOrUses(lp, olp, op) then begin
        		   op^.parents := icount;
                	   icount := icount+1;
                	   end; {if}
                  end {else if}
               else if opcode in [pc_ldo,pc_lod] then begin
        	  {invariant if there is an immediately preceeding invariant store}
        	  if PreviousStore(op, lp2^.block^.code) then begin
                     op^.parents := icount;
                     icount := icount+1;
                     end {if}
        	  else if not Member(op, lp2^.block^.c_gen) then begin
                     {invariant if there are no generators in the loop}
                     count := NumberOfGens(op, lp);
                     if count = 0 then begin
                        op^.parents := icount;       
                        icount := icount+1;
                        end {if}
                     else if count = 1 then begin
                	{invariant if there is one generator AND the generator}
                        {is not in the current block AND no reaching          }
                        {definitions for the loop AND generating statement is }
                        {invariant                                            }
                	if memberOp^.parents <> 0 then
                           if not Member(op, lp^.block^.c_in) then begin
                	      op^.parents := icount;
                	      icount := icount+1;
                              end; {if}
                	end; {else if}
                     end; {else}
        	  end {else if}
               end; {if}
            if op^.parents <> 0 then
               MarkInvariants := true;
            end; {if}
         end; {Check}


         function CheckForIndirectStores (lp: loopPtr): boolean;

         { See if there are any indirect stores or function calls in	}
         { the loop							}
         {								}
         { parameters:							}
         {    lp - loop to check					}
         {								}
         { Returns: True if there are indirect stores or function	}
         {    calls, else false.					}


            function CheckOps (op: icptr): boolean;

            { Check this operation list					}
            {								}
            { parameters:						}
            {    op - operation list to check				}
            {								}
            { Returns: True if an indirect store or function call is	}
            {    found, else false.					}

            var
               result: boolean;			{value to return}

            begin {CheckOps}
            result := false;
            while op <> nil do begin
               if op^.opcode in
                  [pc_sto,pc_cpi,pc_iil,pc_ili,pc_idl,pc_ild,pc_cup,pc_cui,
                   pc_tl1,pc_mov]
                  then begin
                  result := true;
                  op := nil;
                  end {if}
               else begin
                  if op^.left <> nil then
                     result := CheckOps(op^.left);
                  if not result then
                     if op^.right <> nil then
                        result := CheckOps(op^.right);
                  if result then
                     op := nil;
                  end; {if}
               if op <> nil then
                  op := op^.next;
               end; {while}
            CheckOps := result;
            end; {CheckOps}


         begin {CheckForIndirectStores}
         CheckForIndirectStores := false;
         while lp <> nil do
            if CheckOps(lp^.block^.code) then begin
               CheckForIndirectStores := true;
               lp := nil;
               end {if}
            else
               lp := lp^.next;
         end; {CheckForIndirectStores}


         function DominatesExits (dfn: integer; lp: loopPtr): boolean;

         { See if this block dominates all loop exits			}
         {								}
         { parameters:							}
         {    dfn - block that must dominate exits			}
         {    lp - loop list						}
         {								}
         { Returns: True if the block dominates all exits, else false.	}

         var
            dom: blockListPtr;			{used to trace dominator list}

         begin {DominatesExits}
         DominatesExits := true;
         while lp <> nil do begin
            if lp^.exit then begin
               dom := lp^.block^.dom;
               while dom <> nil do 
                  if dom^.dfn = dfn then
                     dom := nil
                  else begin
                     dom := dom^.next;
                     if dom = nil then begin
                        lp := nil;
                        DominatesExits := false;
                        end; {if}
                     end; {else}
               end; {if}
            if lp <> nil then
               lp := lp^.next;
            end; {while}
         end; {DominatesExits}


      begin {MarkInvariants}
      MarkInvariants := false;
      lp2 := lp;
      while lp2 <> nil do begin
         inhibit := not DominatesExits(lp2^.block^.dfn, lp);
         indirectStores := CheckForIndirectStores(lp);
         op := lp2^.block^.code;
         while op <> nil do begin
            Check(op, lp2);
            op := op^.next;
            end; {while}
         lp2 := lp2^.next;
         end; {while}
      end; {MarkInvariants}


      procedure RemoveInvariants (llp: loopListPtr);

      { Remove loop invariant calculations			}
      {								}
      { parameters:						}
      {    llp - pointer to the loop entry to process		}

      var
         icount, oldIcount: integer;	{invariant order counters}
         nhp: blockPtr;			{new loop hedaer pointer}
         op1, op2, op3: icptr;		{used to reverse the code list}


         procedure CreateHeader;

         { Create the new loop header					}
         {								}
         { Notes: As a side effect, CreateHeader sets nhp to point to	}
         {    the new loop header.					}

         var
            lp: loopPtr;			{new loop list entry}
            ohp: blockPtr;			{old loop hedaer pointer}

         begin {CreateHeader}
         nhp := pointer(Calloc(sizeof(block)));	{create the new block}
         ohp := llp^.loop^.block;		{insert it in the block list}
         nhp^.last := ohp^.last;
         if nhp^.last <> nil then
            nhp^.last^.next := nhp;
         nhp^.next := ohp;
         ohp^.last := nhp;
	 new(lp);				{add it to the loop list}
	 lp^.next := llp^.loop;
	 llp^.loop := lp;
	 lp^.block := nhp;
         lp^.exit := false;
         end; {CreateHeader}


         function FindInvariant (ic: integer): integer;

         { Find the next invariant calculation				}
         {								}
         { parameters:							}
         {    ic - base count; the new count must exceed this		}
         {								}
         { Returns: count for the invariant record to remove		}

         var
            lp: loopPtr;			{used to trace loop list}
            op: icptr;				{used to trace code list}
            nic: integer;			{lowest count > ic}


            procedure Check (op: icptr);

            { See if op or its children represent a newer invariant	}
            { calculation than the one numbered nic			}
            {								}
            { parameters:						}
            {    op - instruction to check				}
            {								}
            { Notes: Rejecting pc_bno here is rather odd, but it allows	}
            {    expressions _containing_ pc_bno to be removed without	}
            {    messing up pc_tri operations by allowing pc_bno to be	}
            {    removed as the top level of an expression.		}

            begin {Check}
            if op^.parents = 0 then begin
               if op^.left <> nil then
                  Check(op^.left);
               if op^.right <> nil then
                  Check(op^.right);
               end {if}
            else begin
               if op^.parents < nic then
                  if op^.parents > ic then
                     if op^.opcode <> pc_bno then
                        nic := op^.parents;
               end; {else}
            end; {Check}


         begin {FindInvariant}
         nic := maxint;
         lp := llp^.loop;
         while (lp <> nil) and (nic <> ic+1) do begin
            op := lp^.block^.code;
            while op <> nil do begin
               Check(op);
               op := op^.next;
               end; {while}
            lp := lp^.next;
            end; {while}
         FindInvariant := nic;
         end; {FindInvariant}


         procedure RemoveInvariant (ic: integer);

         { Move the invariant calculation to the header			}
         {								}
         { parameters:							}
         {    ic - index number for instruction to remove		}

         var
            done: boolean;			{loop termination test}
            lp: loopPtr;			{used to trace loop list}
            op: icptr;				{used to trace code list}


            procedure Check (op: icptr);

            { See if a child of op is the target instruction to move	}
            { (If so, move it.)						}
            {								}
            { parameters:						}
            {    op - instruction to check				}


               procedure Remove (var op: icptr);

               { Move a calculation to the loop header			}
               {							}
               { parameters:						}
               {    op - invariant calculation to move			}

               var
		  loc, op2, str: icptr;		{new opcodes}
		  optype: baseTypeEnum;		{type of the temp variable}

               begin {Remove}
               if (op^.left <> nil) or (op^.right <> nil) then begin
        	  optype := TypeOf(op);		{create a temp label}
        	  loc := pointer(Calloc(sizeof(intermediate_code)));
        	  loc^.opcode := dc_loc;
        	  loc^.optype := cgWord;
        	  maxLoc := maxLoc + 1;
        	  loc^.r := maxLoc;
        	  loc^.q := TypeSize(optype);
        	  loc^.next := nhp^.code;
        	  nhp^.code := loc;
						{make a copy of the tree}
        	  op2 := pointer(Malloc(sizeof(intermediate_code)));
        	  op2^ := op^;
        	  op^.opcode := pc_lod;		{substitute a load of the temp}
        	  op^.optype := optype;
        	  op^.r := loc^.r;
        	  op^.q := 0;
        	  op^.left := nil;
        	  op^.right := nil;
						{store the temp result}
        	  str := pointer(Calloc(sizeof(intermediate_code)));
        	  str^.opcode := pc_str;
        	  str^.optype := optype;
        	  str^.r := loc^.r;
        	  str^.q := 0;
        	  str^.left := op2;
        	  str^.next := loc^.next;	{insert the store in the basic block}
        	  loc^.next := str;
                  end; {if}
               done := true;
               end; {Remove}


            begin {Check}
            if op^.left <> nil then begin
               if op^.left^.parents = ic then
                  Remove(op^.left);
               if not done then
                  Check(op^.left);
               end; {if}
            if not done then
               if op^.right <> nil then begin
        	  if op^.right^.parents = ic then 
                     Remove(op^.right);
                  if not done then
                     Check(op^.right);
                  end; {if}
            end; {Check}   


            procedure RemoveTop (var op: icptr);

            { Move a top-level instruction to the header		}
            {								}
            { parameters:						}
            {    op - top level instruction to remove			}

            var
               op2: icptr;			{temp operation}

            begin {RemoveTop}
            op2 := op;
            op := op^.next;
            op2^.next := nhp^.code;
            nhp^.code := op2;
            end; {RemoveTop}


         begin {RemoveInvariant}
         lp := llp^.loop;
         done := false;
         while not done do begin
            op := lp^.block^.code;
            if op <> nil then
               if op^.parents = ic then begin
        	  RemoveTop(lp^.block^.code);
        	  done := true;
        	  end {if}
               else begin
        	  Check(op);
        	  while (op^.next <> nil) and (not done) do begin
                     if op^.next^.parents = ic then begin
                	RemoveTop(op^.next);
                	done := true;
                	end {if}
                     else
                	Check(op^.next);
                     if op^.next <> nil then
        		op := op^.next;
        	     end; {while}
        	  end; {else}
            lp := lp^.next;
            if lp = nil then
               done := true;
            end; {while}
         end; {RemoveInvariant}


      begin {RemoveInvariants}
      CreateHeader;			{create a loop header block}
      icount := 0;			{find & remove all invariants}
      repeat
         oldIcount := icount;
         icount := FindInvariant (icount);
         if icount <> maxint then
            RemoveInvariant(icount);
      until icount = maxint;
      op1 := nhp^.code;			{reverse the new code list}
      op2 := nil;
      while op1 <> nil do begin
         op3 := op1;
         op1 := op1^.next;
         op3^.next := op2;
         op2 := op3;
         end; {while}
      nhp^.code := op2;
      end; {RemoveInvariants}


      procedure ZeroParents (lp: loopPtr);

      { Zero the parents field in all nodes			}
      {								}
      { parameters:						}
      {    lp - loop for which to zero the parents		}

      var
         op: icptr;			{used to trace the opcode list}


         procedure Zero (op: icptr);

         { Zero the parents field for this node and its		}
         { children.						}
         {							}
         { parameters:						}
         {    op - node to zero					}

         begin {Zero}
         op^.parents := 0;
         if op^.left <> nil then
            Zero(op^.left);
         if op^.right <> nil then
            Zero(op^.right);
         end; {Zero}

            
      begin {ZeroParents}
      while lp <> nil do begin
         op := lp^.block^.code;
         while op <> nil do begin
            Zero(op);
            op := op^.next;
            end; {while}
         lp := lp^.next;
         end; {while}
      end; {ZeroParents}


   begin {LoopInvariantRemoval}
   Spin;
   FindLoops;				{find a list of natural loops}

   llp := loops;			{scan the loops...}
   icount := 1;
   while llp <> nil do begin
      Spin;
      ZeroParents(llp^.loop);		{set the parents field to zero}
      while MarkInvariants(llp^.loop) do {mark the loop invariant computations}
         ;
      if icount <> 1 then
	 RemoveInvariants(llp);		{remove loop invariant calculations}
      llp := llp^.next;
      end; {while}


   while loops <> nil do begin		{dispose of the loop lists}
      while loops^.loop <> nil do begin
	 lp := loops^.loop;
	 loops^.loop := lp^.next;
	 dispose(lp);
	 end; {while}
      llp := loops;
      loops := llp^.next;
      dispose(llp);
      end; {while}
   end; {LoopInvariantRemoval}
   

begin {DoLoopOptimization}
DepthFirstOrder;			{create the depth first tree}
ReachingDefinitions;			{find reaching definitions}
Dominators;				{find the lists of dominators}
LoopInvariantRemoval;			{remove loop invariant computations}
while dft <> nil do begin		{dispose of the depth first tree}
   dft2 := dft;
   dft := dft2^.next;
   dispose(dft2);
   end; {while}
while backEdge <> nil do begin		{dispose of the back edge list}
   dft2 := backEdge;
   backEdge := dft2^.next;
   dispose(dft2);
   end; {while}
end; {DoLoopOptimization}

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
   if peepHole then			{peephole optimization}
      repeat
         rescan := false;
	 PeepHoleOptimization(DAGhead);
	 op := DAGHead;
	 while op^.next <> nil do begin
	    Spin;
            PeepHoleOptimization(op^.next);
            op := op^.next;
            end; {while}
	 CheckLabels;
      until not rescan;
   BasicBlocks;				{build the basic blocks}
   if commonSubexpression or loopOptimizations then
      if not volatile then
         FlagIndirectUses;		{create a list of all indirect uses}
   if commonSubexpression then		{common sub-expression removal}
      if not volatile then
         CommonSubexpressionElimination;
   if loopOptimizations then		{loop optimizations}
      if not volatile then
         DoLoopOptimization;
{  if printSymbols then			{debug}
{     PrintBlocks(@'DAG: ', DAGblocks);	{debug}
   if commonSubexpression or loopOptimizations then
      if not volatile then
         DisposeOpList(c_ind);		{dispose of indirect use list}
   Gen(DAGblocks);			{generate native code}
   if loopOptimizations then		{dump and dynamic space}
      if not volatile then
         DumpLoopLists;
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
