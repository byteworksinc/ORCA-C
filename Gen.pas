{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Gen								}
{                                                               }
{  Generates native code from intermediate code instructions.	}
{                                                               }
{---------------------------------------------------------------}

unit Gen;

interface

{$segment 'gen'}

{$LibPrefix '0/obj/'}

uses CCommon, CGI, CGC, ObjOut, Native;

{---------------------------------------------------------------}

function LabelToDisp (lab: integer): integer;

{ convert a local label number to a stack frame displacement    }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }


procedure Gen (blk: blockPtr);

{ Generates native code for a list of blocks			}
{                                                               }
{ parameters:                                                   }
{    blk - first of the list of blocks				}

{---------------------------------------------------------------}

implementation

const
                                        {longword/quadword locations}
   A_X          =       1;              {longword only}
   onStack      =       2;
   inPointer    =       4;
   localAddress =       8;
   globalLabel  =      16;
   constant     =      32;
   nowhere      =      64;
   inStackLoc   =     128;

                                        {stack frame locations}
                                        {---------------------}
   returnSize           =       3;      {size of return address}

type
                                        {possible locations for 4 byte values}
   longType = record                    {description of current four byte value}
      preference: integer;              {where you want the value (bitmask)}
      where: integer;                   {where the value is at}
      fixedDisp: boolean;               {is the displacement a fixed value?}
      isLong: boolean;                  {is long addr required for named labs?}
      disp: integer;                    {fixed displacement/local addr}
      lval: longint;                    {value}
      lab: stringPtr;                   {global label name}
      end;
                                        {possible locations for 8 byte values}
                                        {note: these always have fixed disp}
   quadType = record                    {description of current 8 byte value}
      preference: integer;              {where you want the value (single value)}
      where: integer;                   {where the value is at}
      disp: integer;                    {fixed displacement/local addr}
      lval: longlong;                   {value}
      lab: stringPtr;                   {global label name}
      end;

var
   gLong: longType;                     {info about last long value}
   gQuad: quadType;                     {info about last quad value}
   namePushed: boolean;			{has a name been pushed in this proc?}
   skipLoad: boolean;			{skip load for a pc_lli, etc?}
   stackSaveDepth: integer;		{nesting depth of saved stack positions}
   argsSize: integer;			{total size of argument to a function}
   isQuadFunction: boolean;		{is the return type cg(U)Quad?}

                                        {stack frame locations}
                                        {---------------------}
   bankLoc: integer;			{disp in dp where bank reg is stored}
   dworkLoc: integer;			{disp in dp of 4 byte work spage for cg}
   funLoc: integer;			{loc of fn ret value in stack frame}
   localSize: integer;			{local space for current proc}
   parameterSize: integer;		{# bytes of parameters for current proc}
   stackLoc: integer;                   {disp in dp where stack reg is stored}

{---------------------------------------------------------------}

procedure GenTree (op: icptr); forward;


procedure OperA (mop: integer; op: icptr);

{ Do an operation on op that has addr modes equivalent to STA	}
{								}
{ parameters:							}
{    op - node to generate the leaf for				}
{    mop - operation						}

var
   loc: integer;			{stack frame position}
   opcode: pcodes;			{temp storage}

begin {OperA}
opcode := op^.opcode;
case opcode of

   pc_ldo,pc_gil,pc_gli,pc_gdl,pc_gld: begin
      case mop of
         m_cmp_imm: mop := m_cmp_abs;
         m_adc_imm: mop := m_adc_abs;
         m_and_imm: mop := m_and_abs;
         m_ora_imm: mop := m_ora_abs;
         m_sbc_imm: mop := m_sbc_abs;
         m_eor_imm: mop := m_eor_abs;
         otherwise: Error(cge1);
         end; {case}
      if opcode = pc_gil then
         GenNative(m_inc_abs, absolute, op^.q, op^.lab, 0)
      else if opcode = pc_gdl then
         GenNative(m_dec_abs, absolute, op^.q, op^.lab, 0);
      if smallMemoryModel then
         GenNative(mop, absolute, op^.q, op^.lab, 0)
      else
         GenNative(mop+2, longAbs, op^.q, op^.lab, 0);
      if opcode in [pc_gli,pc_gld] then begin
         if mop in [m_sbc_dir,m_cmp_dir] then
            GenImplied(m_php);
         if opcode = pc_gli then
            GenNative(m_inc_abs, absolute, op^.q, op^.lab, 0)
         else {if opcode = pc_gld then}
            GenNative(m_dec_abs, absolute, op^.q, op^.lab, 0);
         if mop in [m_sbc_dir,m_cmp_dir] then
            GenImplied(m_plp);
         end; {else}
      end; {case pc_ldo,pc_gil,pc_gli,pc_gdl,pc_gld}

   pc_lod,pc_lli,pc_lil,pc_lld,pc_ldl: begin
      case mop of
         m_cmp_imm: mop := m_cmp_dir;
         m_adc_imm: mop := m_adc_dir;
         m_and_imm: mop := m_and_dir;
         m_ora_imm: mop := m_ora_dir;
         m_sbc_imm: mop := m_sbc_dir;
         m_eor_imm: mop := m_eor_dir;
         otherwise: Error(cge1);
         end; {case}
      loc := LabelToDisp(op^.r);
      if opcode = pc_lod then
         loc := loc + op^.q;
      if opcode = pc_lil then
         GenNative(m_inc_dir, direct, loc, nil, 0)
      else if opcode = pc_ldl then
         GenNative(m_dec_dir, direct, loc, nil, 0);
      GenNative(mop, direct, loc, nil, 0);
      if opcode in [pc_lli,pc_lld] then begin
         if mop in [m_sbc_dir,m_cmp_dir] then
            GenImplied(m_php);
         if opcode = pc_lli then
            GenNative(m_inc_dir, direct, loc, nil, 0)
         else {if opc = pc_lld then}
            GenNative(m_dec_dir, direct, loc, nil, 0);
         if mop in [m_sbc_dir,m_cmp_dir] then
            GenImplied(m_plp);
         end; {else}
      end; {case pc_lod,pc_lli,pc_lil,pc_lld,pc_ldl}

   pc_ldc:
      GenNative(mop, immediate, op^.q, nil, 0);

   otherwise:
      Error(cge1);
   end; {case}
end; {OperA}


function Complex (op: icptr): boolean;

{ determine if loading the intermediate code involves anything  }
{ but one reg                                                   }
{                                                               }
{ parameters:                                                   }
{    code - intermediate code to check				}
{                                                               }
{ NOTE: for one and two byte values only!!!                     }

begin {Complex}
Complex := true;
if op^.opcode in [pc_ldo,pc_ldc] then
   Complex := false
else if op^.opcode in [pc_gil,pc_gli,pc_gdl,pc_gld] then
   Complex := smallMemoryModel
else if op^.opcode = pc_lod then
   if LabelToDisp(op^.r) + op^.q < 256 then
      Complex := false
else if op^.opcode in [pc_lli,pc_lil,pc_ldl,pc_lld] then
   if LabelToDisp(op^.r) < 256 then
      Complex := false;
if op^.optype in [cgByte,cgUByte] then
   Complex := true;
end; {Complex}


procedure DoOp(op_imm, op_abs, op_dir: integer; icode: icptr; disp: integer);

{ Do an operation.						}
{								}
{ Parameters:							}
{    op_imm,op_abs,op_dir - op codes for the various		}
{       addressing modes					}
{    icode - intermediate code record				}
{    disp - disp past the location (1 or 2)			}

var
   val: integer;                     {value for immediate operations}
   lval: longint;                    {long value for immediate operations}

begin {DoOp}
if icode^.opcode = pc_ldc then begin
   lval := icode^.lval;
   if disp = 0 then
      val := long(lval).lsw
   else
      val := long(lval).msw;
   GenNative(op_imm, immediate, val, nil, 0);
   end {if}
else if icode^.opcode in [pc_lod,pc_str] then
   GenNative(op_dir, direct, LabelToDisp(icode^.r) + icode^.q + disp, nil, 0)
else {if icode^.opcode in [pc_ldo, pc_sro] then}
   GenNative(op_abs, absolute, icode^.q + disp, icode^.lab, 0);
end; {DoOp}


procedure OpOnWordOfQuad (mop: integer; op: icptr; offset: integer);

{ Do an operation that has addr modes equivalent to LDA on the  }
{ subword at specified offset of the location specified by op.  }
{                                                               }
{ The generated code may modify X, and may set Y to offset.     }
{                                                               }
{ parameters:                                                   }
{    mop - machine opcode                                       }
{    op - node to generate the leaf for                         }
{    offset - offset of the word to access (0, 2, 4, or 6)      }

var
   loc: integer;                        {stack frame position}
   val: integer;                        {immediate value}

begin {OpOnWordOfQuad}
case op^.opcode of

   pc_ldo: begin
      case mop of
         m_lda_imm: mop := m_lda_abs;
         m_cmp_imm: mop := m_cmp_abs;
         m_adc_imm: mop := m_adc_abs;
         m_and_imm: mop := m_and_abs;
         m_ora_imm: mop := m_ora_abs;
         m_sbc_imm: mop := m_sbc_abs;
         m_eor_imm: mop := m_eor_abs;
         otherwise: Error(cge1);
         end; {case}
      if smallMemoryModel then
         GenNative(mop, absolute, op^.q+offset, op^.lab, 0)
      else
         GenNative(mop+2, longAbs, op^.q+offset, op^.lab, 0);
      end; {case pc_ldo}

   pc_lod: begin
      case mop of
         m_lda_imm: mop := m_lda_dir;
         m_cmp_imm: mop := m_cmp_dir;
         m_adc_imm: mop := m_adc_dir;
         m_and_imm: mop := m_and_dir;
         m_ora_imm: mop := m_ora_dir;
         m_sbc_imm: mop := m_sbc_dir;
         m_eor_imm: mop := m_eor_dir;
         otherwise: Error(cge1);
         end; {case}
      loc := LabelToDisp(op^.r) + op^.q + offset;
      if loc < 256 then
         GenNative(mop, direct, loc, nil, 0)
      else begin
         GenNative(m_ldx_imm, immediate, loc, nil, 0);
         GenNative(mop+$10, direct, 0, nil, 0);
         end; {else}
      end; {case pc_lod}

   pc_ldc: begin
      case offset of
         0: val := long(op^.qval.lo).lsw;
         2: val := long(op^.qval.lo).msw;
         4: val := long(op^.qval.hi).lsw;
         6: val := long(op^.qval.hi).msw;
         otherwise: Error(cge1);
         end; {case}
      GenNative(mop, immediate, val, nil, 0);
      end; {case pc_ldc}

   pc_ind: begin
      case mop of
         m_lda_imm: mop := m_lda_indl;
         m_cmp_imm: mop := m_cmp_indl;
         m_adc_imm: mop := m_adc_indl;
         m_and_imm: mop := m_and_indl;
         m_ora_imm: mop := m_ora_indl;
         m_sbc_imm: mop := m_sbc_indl;
         m_eor_imm: mop := m_eor_indl;
         otherwise: Error(cge1);
         end; {case}
      if op^.left^.opcode = pc_lod then
         loc := LabelToDisp(op^.left^.r) + op^.left^.q;
      if (op^.left^.opcode <> pc_lod) or (loc > 255) then
         Error(cge1);
      offset := offset + op^.q;
      if offset = 0 then
         GenNative(mop, direct, loc, nil, 0)
      else begin
         GenNative(m_ldy_imm, immediate, offset, nil, 0);
         GenNative(mop+$10, direct, loc, nil, 0);
         end; {else}
      end; {case pc_ind}

   otherwise:
      Error(cge1);
   end; {case}
end; {OpOnWordOfQuad}


function SimpleQuadLoad(op: icptr): boolean;

{ Is op a simple load operation on a cg(U)Quad, which can be    }
{ broken up into word operations handled by OpOnWordOfQuad?     }
{                                                               }
{ parameters:                                                   }
{    op - node to check                                         }

begin {SimpleQuadLoad}
case op^.opcode of
   pc_ldo,pc_lod,pc_ldc:
      SimpleQuadLoad := true;

   pc_ind:
      SimpleQuadLoad :=
         (op^.left^.opcode = pc_lod)
         and (LabelToDisp(op^.left^.r) + op^.left^.q < 256);

   otherwise:
      SimpleQuadLoad := false;
   end; {case}
end; {SimpleQuadLoad}


function SimplestQuadLoad(op: icptr): boolean;

{ Is op a simple load operation on a cg(U)Quad, which can be    }
{ broken up into word operations handled by OpOnWordOfQuad      }
{ and for which those operations will not modify X or Y.        }
{                                                               }
{ parameters:                                                   }
{    op - node to check                                         }

begin {SimplestQuadLoad}
case op^.opcode of
   pc_ldo,pc_ldc:
      SimplestQuadLoad := true;
   
   pc_lod:
      SimplestQuadLoad := LabelToDisp(op^.r) + op^.q < 250;

   pc_ind,otherwise:
      SimplestQuadLoad := false;
   end; {case}
end; {SimplestQuadLoad}


procedure StoreWordOfQuad(offset: integer);

{ Store one word of a quad value to the location specified by   }
{ gQuad.preference.  The word value to store must be in A.      }
{                                                               }
{ The generated code may modify X, and may set Y to offset.     }
{ It does not modify A or the carry flag.                       }
{                                                               }
{ parameters:                                                   }
{    offset - offset of the word to store (0, 2, 4, or 6)       }
{                                                               }
{ Note: If gQuad.preference is onStack, this just generates a   }
{    PHA.  That is suitable if storing a value starting from    }
{    the most significant word, but not in other cases.  For    }
{    other gQuad.preference values, any order is okay.          }

begin {StoreWordOfQuad}
case gQuad.preference of
   localAddress: begin
      if gQuad.disp+offset <= 255 then
         GenNative(m_sta_dir, direct, gQuad.disp+offset, nil, 0)
      else begin
         GenNative(m_ldx_imm, immediate, gQuad.disp+offset, nil, 0);
         GenNative(m_sta_dirX, direct, 0, nil, 0);
         end; {else}
      end;

   globalLabel: begin
      if smallMemoryModel then
         GenNative(m_sta_abs, absolute, gQuad.disp+offset, gQuad.lab, 0)
      else
         GenNative(m_sta_long, longabsolute, gQuad.disp+offset, gQuad.lab, 0);
      end;

   inPointer: begin
      if (gQuad.disp > 255) or (gQuad.disp < 0) then
         Error(cge1);
      if offset = 0 then
         GenNative(m_sta_indl, direct, gQuad.disp, nil, 0)
      else begin
         GenNative(m_ldy_imm, immediate, offset, nil, 0);
         GenNative(m_sta_indly, direct, gQuad.disp, nil, 0);
         end; {else}
      end;

   inStackLoc:
      GenNative(m_sta_s, direct, gQuad.disp+offset, nil, 0);

   onStack:
      GenImplied(m_pha);

   nowhere: ;                           {discard the value}

   otherwise: Error(cge1);
   end; {case}
end; {StoreWordOfQuad}


procedure GetPointer (op: icptr);

{ convert a tree into a usable pointer for indirect		}
{ loads/stores							}
{								}
{ parameters:							}
{    op - pointer tree						}

begin {GetPointer}
gLong.preference := A_X+inPointer+localAddress+globalLabel;
GenTree(op);
if gLong.where = onStack then begin
   GenImplied(m_pla);
   GenImplied(m_plx);
   gLong.where := A_X;
   end; {if}
if gLong.where = A_X then begin
   GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
   GenNative(m_stx_dir, direct, dworkLoc+2, nil, 0);
   gLong.where := inPointer;
   gLong.fixedDisp := true;
   gLong.disp := dworkLoc;
   end; {else if}
end; {GetPointer}


procedure IncAddr (size: integer);

{ add a two byte constant to a four byte value - generally an	}
{ address							}
{                                                               }
{ parameters:                                                   }
{    size - integer to add					}

var
   lab1: integer;                       {branch point}

begin {IncAddr}
if size <> 0 then
   case gLong.where of

      onStack: begin
         lab1 := GenLabel;
         GenImplied(m_pla);
         if size = 1 then begin
            GenImplied(m_ina);
            GenNative(m_bne, relative, lab1, nil, 0);
            end {if}
         else begin
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, size, nil, 0);
            GenNative(m_bcc, relative, lab1, nil, 0);
            end; {else}
         GenImplied(m_plx);
         GenImplied(m_inx);
         GenImplied(m_phx);
         GenLab(lab1);
         GenImplied(m_pha);
         end;

      A_X: begin
         lab1 := GenLabel;
         if size = 1 then begin
            GenImplied(m_ina);
            GenNative(m_bne, relative, lab1, nil, 0);
            end {if}          
         else begin
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, size, nil, 0);
            GenNative(m_bcc, relative, lab1, nil, 0);
            end; {else}
         GenImplied(m_inx);
         GenLab(lab1);
         end;

      inPointer:
         if gLong.fixedDisp then begin
            gLong.fixedDisp := false;
            GenNative(m_ldy_imm, immediate, size, nil, 0);
            end {if}
         else if size <= 4 then begin
            while size <> 0 do begin
               GenImplied(m_iny);
               size := size - 1;
               end; {while}
            end {else if}
         else begin
            GenImplied(m_tya);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, size, nil, 0);
            GenImplied(m_tay);
            end; {else}

      localAddress,globalLabel:
         gLong.disp := gLong.disp+size;

      otherwise:
         Error(cge1);
      end; {case}
end; {IncAddr}


procedure LoadX (op: icptr);

{ Load X with a two byte value					}
{                                                               }
{ parameters:                                                   }
{    op - value to load						}

var
   q, r: integer;
   lab: stringPtr;

begin {LoadX}
q := op^.q;
r := op^.r;
lab := op^.lab;
case op^.opcode of
   pc_lao,pc_lda:
      Error(cge1);
   pc_ldc:
      GenNative(m_ldx_imm, immediate, q, nil, 0);
   pc_ldo:
      GenNative(m_ldx_abs, absolute, q, lab, 0);
   pc_gli: begin
      GenNative(m_ldx_abs, absolute, q, lab, 0);
      GenNative(m_inc_abs, absolute, q, lab, 0);
      end; {if}
   pc_gil: begin
      GenNative(m_inc_abs, absolute, q, lab, 0);
      GenNative(m_ldx_abs, absolute, q, lab, 0);
      end; {if}
   pc_gld: begin
      GenNative(m_ldx_abs, absolute, q, lab, 0);
      GenNative(m_dec_abs, absolute, q, lab, 0);
      end; {if}
   pc_gdl: begin
      GenNative(m_dec_abs, absolute, q, lab, 0);
      GenNative(m_ldx_abs, absolute, q, lab, 0);
      end; {if}
   pc_lod:
      GenNative(m_ldx_dir, direct, LabelToDisp(r) + q, nil, 0);
   pc_lli: begin
      GenNative(m_ldx_dir, direct, LabelToDisp(r), nil, 0);
      GenNative(m_inc_dir, direct, LabelToDisp(r), nil, 0);
      end; {if}
   pc_lil: begin
      GenNative(m_inc_dir, direct, LabelToDisp(r), nil, 0);
      GenNative(m_ldx_dir, direct, LabelToDisp(r), nil, 0);
      end; {if}
   pc_lld: begin
      GenNative(m_ldx_dir, direct, LabelToDisp(r), nil, 0);
      GenNative(m_dec_dir, direct, LabelToDisp(r), nil, 0);
      end; {if}
   pc_ldl: begin
      GenNative(m_dec_dir, direct, LabelToDisp(r), nil, 0);
      GenNative(m_ldx_dir, direct, LabelToDisp(r), nil, 0);
      end; {if}
   otherwise:
      Error(cge1);
   end; {case}
end; {LoadX}


function NeedsCondition (opcode: pcodes): boolean;

{ See if the operation is one that doesn't set the condition	}
{ code reliably							}
{								}
{ Parameters:							}
{    opcodes - operation to check				}
{								}
{ Returns: True if the condition code is not set properly for	}
{    an operand type of cgByte,cgUByte,cgWord,cgUWord, else	}
{    false							}

begin {NeedsCondition}
NeedsCondition := opcode in
   [pc_and,pc_ior,pc_cui,pc_cup,pc_ldl,pc_lil,pc_lld,
    pc_lli,pc_gil,pc_gli,pc_gdl,pc_gld,pc_iil,pc_ili,pc_idl,pc_ild,
    pc_cop,pc_cpo,pc_cpi,pc_dvi,pc_mpi,pc_adi,pc_sbi,pc_mod,pc_bno,
    pc_udi,pc_uim,pc_umi,pc_cnv,pc_rbo,pc_shl,pc_shr,pc_usr,pc_lbf,
    pc_lbu,pc_cbf,pc_tri,pc_sxi];
end; {NeedsCondition}


function SameLoc (load, save: icptr): boolean;

{ See if load and save represent the same location (which must	}
{ be a direct page value or a global label).			}
{								}
{ parameters:							}
{    load - load operation					}
{    save - save operation					}
{								}
{ Returns: True the the same location is used, else false	}

begin {SameLoc}
SameLoc := false;
if save <> nil then begin
   if load^.opcode = pc_lod then begin
      if LabelToDisp(load^.r) + load^.q < 254 then
         if save^.opcode = pc_str then
            if save^.q = load^.q then
               if save^.r = load^.r then
                  SameLoc := true;
      end {if}
   else if smallMemoryModel then
      if load^.opcode = pc_ldo then
         if save^.opcode = pc_sro then
            if load^.lab^ = save^.lab^ then
               if load^.q = save^.q then
                  SameLoc := true;
   end; {if}
end; {SameLoc}


procedure SaveRetValue (optype: baseTypeEnum);

{ save a value returned by a function                           }
{                                                               }
{ parameters:                                                   }
{    optype - function type					}

begin {SaveRetValue}
if optype in [cgLong,cgULong] then begin
   if (A_X & gLong.preference) = 0 then begin
      gLong.where := onStack;
      GenImplied(m_phx);
      GenImplied(m_pha);
      end
   else
      gLong.where := A_X;
   end {if}
else if optype in [cgReal,cgDouble,cgExtended,cgComp] then
   GenCall(8);
end; {SaveRetValue}


procedure GenAdlSbl (op, save: icptr);

{ generate code for pc_adl, pc_sbl				}
{								}
{ parameters:							}
{    op - pc_adl or pc_sbl operation				}
{    save - save location (pc_str or pc_sro) or nil		}

var
   bcc,clc,adc_imm,inc_dir,adc_abs,     {for op-code insensitive code}
      adc_dir,inc_abs,adc_s: integer;
   disp: integer;			{direct page location}
   lab1: integer;                       {label number}
   nd: icptr;				{for swapping left/right children}
   opcode: pcodes;			{temp storage; for efficiency}
   simpleStore: boolean;                {is the store absolute or direct?}
   val: longint;                        {long constant value}


   function Simple (icode: icptr): boolean;

   { See if the intermediate code is simple; i.e., can be       }
   { reached by direct page or absolute addressing.             }

   begin {Simple}
   Simple := false;
   if icode^.opcode = pc_ldc then
      Simple := true
   else if icode^.opcode in [pc_lod,pc_str] then begin
      if LabelToDisp(icode^.r) + icode^.q < 254 then
         Simple := true;
      end {else if}
   else if icode^.opcode in [pc_ldo,pc_sro] then
      Simple := smallMemoryModel;
   end; {Simple}


begin {GenAdlSbl}
{determine where the result goes}
if save <> nil then
   gLong.preference :=
      A_X+onStack+inPointer+localAddress+globalLabel+constant;

{set up the master instructions}
opcode := op^.opcode;
if opcode = pc_adl then begin
   clc := m_clc;
   bcc := m_bcc;
   adc_imm := m_adc_imm;
   adc_abs := m_adc_abs;
   adc_dir := m_adc_dir;
   adc_s   := m_adc_s;
   inc_dir := m_inc_dir;
   inc_abs := m_inc_abs;
   end {if}
else begin
   clc := m_sec;
   bcc := m_bcs;
   adc_imm := m_sbc_imm;
   adc_abs := m_sbc_abs;
   adc_dir := m_sbc_dir;
   adc_s   := m_sbc_s;
   inc_dir := m_dec_dir;
   inc_abs := m_dec_abs;
   end; {else}

{if the lhs is a constant, swap the nodes}
if ((op^.left^.opcode = pc_ldc) and (opcode = pc_adl)) then begin
   nd := op^.left;
   op^.left := op^.right;
   op^.right := nd;
   end; {if}

{handle a constant rhs}
if op^.right^.opcode = pc_ldc then
   val := op^.right^.lval
else
   val := -1;
if SameLoc(op^.left, save) and (long(val).msw = 0) then begin
   lab1 := GenLabel;
   if val = 1 then begin
      if opcode = pc_adl then begin
         DoOp(0, m_inc_abs, m_inc_dir, op^.left, 0);
         GenNative(m_bne, relative, lab1, nil, 0);
         DoOp(0, m_inc_abs, m_inc_dir, op^.left, 2);
         GenLab(lab1);
         end {if}
      else {if opcode = pc_sbl then} begin
         DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
         GenNative(m_beq, relative, lab1, nil, 0);
         DoOp(0, m_dec_abs, m_dec_dir, op^.left, 0);
         GenLab(lab1);
         DoOp(0, m_dec_abs, m_dec_dir, op^.left, 2);
         end; {else}
      end {if}
   else begin {rhs in [2..65535]}
      GenImplied(clc);
      DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
      GenNative(adc_imm, immediate, long(val).lsw, nil, 0);
      DoOp(0, m_sta_abs, m_sta_dir, op^.left, 0);
      GenNative(bcc, relative, lab1, nil, 0);
      if opcode = pc_adl then
         DoOp(0, m_inc_abs, m_inc_dir, op^.left, 2)
      else
         DoOp(0, m_dec_abs, m_dec_dir, op^.left, 2);
      GenLab(lab1);
      end; {else}
   end {if constant rhs}

else begin
   simpleStore := false;
   if save <> nil then
      simpleStore := Simple(save);
   if (opcode = pc_adl) and Simple(op^.left) then begin
      nd := op^.left;
      op^.left := op^.right;
      op^.right := nd;
      end; {if}
   if simpleStore and Simple(op^.right) then begin
      if Simple(op^.left) then begin
         GenImplied(clc);
         DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 0);
         DoOp(0, m_sta_abs, m_sta_dir, save, 0);
         DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 2);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 2);
         DoOp(0, m_sta_abs, m_sta_dir, save, 2);
         end {if}
      else begin
         gLong.preference := A_X;
         GenTree(op^.left);
         GenImplied(clc);
         if gLong.where = onStack then
            GenImplied(m_pla);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 0);
         DoOp(0, m_sta_abs, m_sta_dir, save, 0);
         if gLong.where = onStack then
            GenImplied(m_pla)
         else
            GenImplied(m_txa);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 2);
         DoOp(0, m_sta_abs, m_sta_dir, save, 2);
         end; {else}
      end {if}
   else if (save = nil) and Simple(op^.right) then begin
      gLong.preference := gLong.preference & A_X;
      GenTree(op^.left);
      GenImplied(clc);
      if gLong.where = onStack then begin
         GenImplied(m_pla);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 0);
         GenImplied(m_pha);
         GenNative(m_lda_s, direct, 3, nil, 0);
         DoOp(adc_imm, adc_abs, adc_dir, op^.right, 2);
         GenNative(m_sta_s, direct, 3, nil, 0);
         end {if}
      else begin
	 DoOp(adc_imm, adc_abs, adc_dir, op^.right, 0);
         GenImplied(m_tay);
         GenImplied(m_txa);
	 DoOp(adc_imm, adc_abs, adc_dir, op^.right, 2);
         GenImplied(m_tax);
         GenImplied(m_tya);
         end; {else}
      end {else if}
   else begin {doing it the hard way}
      gLong.preference := onStack;
      GenTree(op^.right);
      gLong.preference := onStack;
      GenTree(op^.left);
      GenImplied(clc);
      GenImplied(m_pla);
      GenNative(adc_s, direct, 3, nil, 0);
      GenNative(m_sta_s, direct, 3, nil, 0);
      GenImplied(m_pla);
      GenNative(adc_s, direct, 3, nil, 0);
      GenNative(m_sta_s, direct, 3, nil, 0);
      if save = nil then
         gLong.where := onStack
      else if save^.opcode = pc_str then begin
         disp := LabelToDisp(save^.r) + save^.q;
         if disp < 254 then begin
            GenImplied(m_pla);
            GenNative(m_sta_dir, direct, disp, nil, 0);
            GenImplied(m_pla);
            GenNative(m_sta_dir, direct, disp+2, nil, 0);
            end {else if}
         else begin
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            GenImplied(m_pla);
            GenNative(m_sta_dirX, direct, 0, nil, 0);
            GenImplied(m_pla);
            GenNative(m_sta_dirX, direct, 2, nil, 0);
            end; {else}
         end {else if}
      else {if save^.opcode = pc_sro then} begin
         GenImplied(m_pla);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, save^.q, save^.lab, 0)
         else
            GenNative(m_sta_long, longabsolute, save^.q, save^.lab, 0);
         GenImplied(m_pla);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, save^.q+2, save^.lab, 0)
         else
            GenNative(m_sta_long, longabsolute, save^.q+2, save^.lab, 0);
         end; {else}                      
      end; {else}
   end; {else}
end; {GenAdlSbl}


procedure GenAdqSbq (op: icptr);

{ generate code for pc_adq, pc_sbq				}
{								}
{ parameters:							}
{    op - pc_adq or pc_sbq operation				}

begin {GenAdqSbq}
if op^.opcode = pc_adq then begin
   if SimpleQuadLoad(op^.left) and SimpleQuadLoad(op^.right) then begin
      gQuad.where := gQuad.preference;
      if gQuad.preference = onStack then begin
         GenImplied(m_tsc);
         GenImplied(m_sec);
         GenNative(m_sbc_imm, immediate, 8, nil, 0);
         GenImplied(m_tcs);
         gQuad.preference := inStackLoc;
         gQuad.disp := 1;
         end; {if}
      GenImplied(m_clc);
      OpOnWordOfQuad(m_lda_imm, op^.left, 0);
      OpOnWordOfQuad(m_adc_imm, op^.right, 0);
      StoreWordOfQuad(0);
      OpOnWordOfQuad(m_lda_imm, op^.left, 2);
      OpOnWordOfQuad(m_adc_imm, op^.right, 2);
      StoreWordOfQuad(2);
      OpOnWordOfQuad(m_lda_imm, op^.left, 4);
      OpOnWordOfQuad(m_adc_imm, op^.right, 4);
      StoreWordOfQuad(4);
      OpOnWordOfQuad(m_lda_imm, op^.left, 6);
      OpOnWordOfQuad(m_adc_imm, op^.right, 6);
      StoreWordOfQuad(6);
      end {if}
   else begin
      gQuad.preference := onStack;
      GenTree(op^.right);
      gQuad.preference := onStack;
      GenTree(op^.left);
      GenImplied(m_clc);
      GenImplied(m_pla);
      GenNative(m_adc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_adc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_adc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_adc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      gQuad.where := onStack;
      end; {else}
   end {if}
else {if op^.opcode = pc_sbq then} begin
   if SimpleQuadLoad(op^.left) and SimpleQuadLoad(op^.right) then begin
      gQuad.where := gQuad.preference;
      if gQuad.preference = onStack then begin
         GenImplied(m_tsc);
         GenImplied(m_sec);
         GenNative(m_sbc_imm, immediate, 8, nil, 0);
         GenImplied(m_tcs);
         gQuad.preference := inStackLoc;
         gQuad.disp := 1;
         end; {if}
      GenImplied(m_sec);
      OpOnWordOfQuad(m_lda_imm, op^.left, 0);
      OpOnWordOfQuad(m_sbc_imm, op^.right, 0);
      StoreWordOfQuad(0);
      OpOnWordOfQuad(m_lda_imm, op^.left, 2);
      OpOnWordOfQuad(m_sbc_imm, op^.right, 2);
      StoreWordOfQuad(2);
      OpOnWordOfQuad(m_lda_imm, op^.left, 4);
      OpOnWordOfQuad(m_sbc_imm, op^.right, 4);
      StoreWordOfQuad(4);
      OpOnWordOfQuad(m_lda_imm, op^.left, 6);
      OpOnWordOfQuad(m_sbc_imm, op^.right, 6);
      StoreWordOfQuad(6);
      end {if}
   else begin
      gQuad.preference := onStack;
      GenTree(op^.right);
      gQuad.preference := onStack;
      GenTree(op^.left);
      GenImplied(m_sec);
      GenImplied(m_pla);
      GenNative(m_sbc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_sbc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_sbc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      GenImplied(m_pla);
      GenNative(m_sbc_s, direct, 7, nil, 0);
      GenNative(m_sta_s, direct, 7, nil, 0);
      gQuad.where := onStack;
      end; {else}
   end; {else}
end; {GenAdqSbq}


procedure GenCkp (op: icptr);

{ generate code for pc_ckp				        }
{								}
{ parameters:							}
{    op - pc_ckp operation				        }

begin {GenCkp}
if op^.left^.opcode in [pc_lda,pc_lad,pc_lca,pc_lao] then
   GenTree(op^.left)
else begin
   gLong.preference := onStack;
   GenTree(op^.left);
   GenCall(98);
   end; {else}
end; {GenCkp}


procedure GenCmp (op: icptr; rOpcode: pcodes; lb: integer);

{ generate code for pc_les, pc_leq, pc_grt or pc_geq		}
{								}
{ parameters:							}
{    op - operation						}
{    rOpcode - Opcode that will use the result of the		}
{       compare.  If the result is used by a tjp or fjp,	}
{       this procedure generated special code and does the	}
{       branch internally.					}
{    lb - For fjp, tjp, this is the label to branch to if	}
{            the condition is satisfied.			}

var
   i: integer;				{loop variable}
   lab1,lab2,lab3,lab4: integer;	{label numbers}
   num: integer;			{constant to compare to}
   simple: boolean;                     {is this a simple case?}
   alwaysFalse: boolean;                {is the comparison always false?}


   procedure Switch;

   { switch the operands					}

   var
      nd: icptr;			{used to switch nodes}

   begin {Switch}
   nd := op^.left;
   op^.left := op^.right;
   op^.right := nd;
   end; {Switch}


   procedure ReverseConditional;
   
   { Change tjp to an equivalent fjp, or vice versa.            }
   {                                                            }
   { Note: assumes opcode is pc_geq or pc_grt.                  }
   
   begin {ReverseConditional}
   if rOpcode in [pc_tjp,pc_fjp] then begin
      if op^.opcode = pc_geq then
         op^.opcode := pc_grt
      else
         op^.opcode := pc_geq;
      if rOpcode = pc_tjp then
         rOpcode := pc_fjp
      else
         rOpcode := pc_tjp;
      Switch;
      end; {if}
   end; {ReverseConditional}


   function SimpleLongOp(op: icptr): boolean;
   
   { Is op an operation on cg(U)Long that can be done using the }
   { addressing modes of CPX?                                   }
   
   begin {SimpleLongOp}
   SimpleLongOp :=
      (op^.opcode = pc_ldc)
      or (op^.opcode = pc_lao)
      or ((op^.opcode = pc_lod) and (LabelToDisp(op^.r) + op^.q <= 253))
      or ((op^.opcode = pc_ldo) and smallMemoryModel);
   end; {SimpleLongOp}


begin {GenCmp}
{To reduce the number of possibilities that must be handled, pc_les  }
{and pc_leq compares are reduced to their equivalent pc_grt and      }
{pc_geq instructions.                                                }
if op^.opcode = pc_les then begin
   Switch;
   op^.opcode := pc_grt;
   end {if}
else if op^.opcode = pc_leq then begin
   Switch;
   op^.opcode := pc_geq;
   end; {else if}

{To take advantage of shortcuts, switch operands if generating    }
{for a tjp or fjp with a constant left operand.                   }
if op^.optype in [cgByte,cgUByte,cgWord,cgUWord] then
   if op^.left^.opcode = pc_ldc then
      ReverseConditional;

{Short cuts are available for single-word operands where the      }
{right operand is a constant.                                     }
if (op^.optype in [cgByte,cgUByte,cgWord,cgUWord]) and
   (op^.right^.opcode = pc_ldc) then begin
   GenTree(op^.left);
   num := op^.right^.q;
   {Convert x > N comparisons to x >= N+1, unless N is max value  }
   {(in which case x > N is always false).                        }
   alwaysFalse := false;
   if op^.opcode = pc_grt then begin
      if ((op^.optype in [cgByte,cgWord]) and (num = 32767))
         or ((op^.optype in [cgUByte,cgUWord]) and (num = -1)) then
         alwaysFalse := true
      else begin
         op^.opcode := pc_geq;
         num := num+1;
         end; {else}
      end; {if}
   lab1 := GenLabel;
   if rOpcode = pc_fjp then begin
      if alwaysFalse then
         GenNative(m_brl, longrelative, lb, nil, 0)
      else if op^.optype in [cgByte,cgWord] then begin
         if NeedsCondition(op^.left^.opcode) then
            GenImpliedForFlags(m_tax);
         if (num >= 0) and (num < 3) then begin
            if num = 0 then
               GenNative(m_bpl, relative, lab1, nil, 0)
            else begin
               lab2 := GenLabel;
               GenNative(m_bmi, relative, lab2, nil, 0);
               if num = 2 then
                  GenImplied(m_lsr_a);
               GenNative(m_bne, relative, lab1, nil, 0);
               GenLabUsedOnce(lab2);
               end; {else}
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end {if (num >= 0) and (num < 3)}
         else begin
            lab2 := GenLabel;
            if num > 0 then
               GenNative(m_bmi, relative, lab1, nil, 0)
            else
               GenNative(m_bpl, relative, lab1, nil, 0);
            GenNative(m_cmp_imm, immediate, num, nil, 0);
            GenNative(m_bcs, relative, lab2, nil, 0);
            if num > 0 then begin
               GenLabUsedOnce(lab1);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               end {if}
            else begin
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               GenLab(lab1);
               end; {else}
            end; {else if}
         end {if}
      else {if optype in [cgUByte,cgUWord] then} begin
         if num <> 0 then begin
            if num in [1,2] then begin
               if num = 1 then
                  GenImpliedForFlags(m_tax)
               else
                  GenImplied(m_lsr_a);
               GenNative(m_bne, relative, lab1, nil, 0);
               end {if}
            else begin
               GenNative(m_cmp_imm, immediate, num, nil, 0);
               GenNative(m_bcs, relative, lab1, nil, 0);
               end; {else}
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end; {if}
         end; {else}
      end {if rOpcode = pc_fjp}
   else if rOpcode = pc_tjp then begin
      if alwaysFalse then
         {nothing to generate}
      else if op^.optype in [cgByte,cgWord] then begin
         if NeedsCondition(op^.left^.opcode) then
            GenImpliedForFlags(m_tax);
         if (num >= 0) and (num < 3) then begin
            GenNative(m_bmi, relative, lab1, nil, 0);
            if num > 0 then begin
               if num = 2 then
                  GenImplied(m_lsr_a);
               GenNative(m_beq, relative, lab1, nil, 0);
               end; {if}
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end {if (num >= 0) and (num < 3)}
         else begin
            lab2 := GenLabel;
            if num > 0 then
               GenNative(m_bmi, relative, lab1, nil, 0)
            else
               GenNative(m_bpl, relative, lab1, nil, 0);
            GenNative(m_cmp_imm, immediate, num, nil, 0);
            GenNative(m_bcc, relative, lab2, nil, 0);
            if num > 0 then begin
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               GenLab(lab1);
               end {if}
            else begin
               GenLabUsedOnce(lab1);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               end; {else}
            end; {else}
         end {if}
      else {if optype in [cgUByte,cgUWord] then} begin
         if num <> 0 then begin
            if num in [1,2] then begin
               if num = 1 then
                  GenImpliedForFlags(m_tax)
               else
                  GenImplied(m_lsr_a);
               GenNative(m_beq, relative, lab1, nil, 0);
               end {if}
            else begin
               GenNative(m_cmp_imm, immediate, num, nil, 0);
               GenNative(m_bcc, relative, lab1, nil, 0);
               end; {else}
            end; {if}
         GenNative(m_brl, longrelative, lb, nil, 0);
         if num <> 0 then
            GenLab(lab1);
         end; {else}
      end {if rOpcode = pc_tjp}
   else if alwaysFalse then
      GenNative(m_lda_imm, immediate, 0, nil, 0)
   else if op^.optype in [cgByte,cgWord] then begin
      lab2 := GenLabel;
      GenNative(m_ldx_imm, immediate, 1, nil, 0);
      GenImplied(m_sec);
      GenNative(m_sbc_imm, immediate, num, nil, 0);
      GenNative(m_bvc, relative, lab1, nil, 0);
      GenImplied(m_ror_a);
      GenLab(lab1);
      GenNative(m_bpl, relative, lab2, nil, 0);
      GenImplied(m_dex);
      GenLab(lab2);
      GenImplied(m_txa);
      end {else if}
   else begin
      GenNative(m_cmp_imm, immediate, num, nil, 0);
      GenNative(m_lda_imm, immediate, 0, nil, 0);
      GenImplied(m_rol_a);
      end; {else if}
   end {if (op^.optype in [cgByte,cgUByte,cgWord,cgUWord]) and
      (op^.right^.opcode = pc_ldc)}

{This section of code handles the cases where the above short     }
{cuts cannot be used.                                             }
else
   case op^.optype of

      cgByte,cgUByte,cgWord,cgUWord: begin
         if ((op^.opcode = pc_grt) and (Complex(op^.left) <= Complex(op^.right)))
            or (Complex(op^.right) and not Complex(op^.left)) then
            ReverseConditional;
         if Complex(op^.right) then begin
            GenTree(op^.right);
            if Complex(op^.left) then begin
               GenImplied(m_pha);
               GenTree(op^.left);
               GenImplied(m_ply);
               GenNative(m_sty_dir, direct, dworkLoc, nil, 0);
               end {if}
            else begin
               GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
               GenTree(op^.left);
               end; {else}
            if not (rOpcode in [pc_fjp,pc_tjp]) then
               GenNative(m_ldx_imm, immediate, 1, nil, 0);
            if op^.optype in [cgByte,cgWord] then begin
               GenImplied(m_sec);
               GenNative(m_sbc_dir, direct, dworkLoc, nil, 0);
               end {if}
            else
               GenNative(m_cmp_dir, direct, dworkLoc, nil, 0);
            end {if}
         else begin
            GenTree(op^.left);
            if not (rOpcode in [pc_fjp,pc_tjp]) then
               GenNative(m_ldx_imm, immediate, 1, nil, 0);
            if op^.optype in [cgByte,cgWord] then begin
               GenImplied(m_sec);
               OperA(m_sbc_imm, op^.right);
               if op^.right^.opcode in [pc_lld,pc_lli,pc_gli,pc_gld] then
                  GenImplied(m_tay);
               end {if}
            else
               OperA(m_cmp_imm, op^.right);
            end; {else}
         if rOpcode = pc_fjp then begin
            lab2 := GenLabel;
            if op^.opcode = pc_grt then begin
               lab3 := GenLabel;
               GenNative(m_beq, relative, lab3, nil, 0);
               end; {if}
            if op^.optype in [cgByte,cgWord] then begin
               lab1 := GenLabel;
               GenNative(m_bvc, relative, lab1, nil, 0);
               GenImplied(m_ror_a);
               GenLab(lab1);
               GenNative(m_bpl, relative, lab2, nil, 0);
               end {if}
            else
               GenNative(m_bcs, relative, lab2, nil, 0);
            if op^.opcode = pc_grt then
               GenLabUsedOnce(lab3);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab2);
            end {if}
         else if rOpcode = pc_tjp then begin
            lab2 := GenLabel;
            if op^.opcode = pc_grt then begin
               lab3 := GenLabel;
               GenNative(m_beq, relative, lab3, nil, 0);
               end; {if}
            if op^.optype in [cgByte,cgWord] then begin
               lab1 := GenLabel;
               GenNative(m_bvc, relative, lab1, nil, 0);
               GenImplied(m_ror_a);
               GenLab(lab1);
               GenNative(m_bmi, relative, lab2, nil, 0);
               end {if}
            else
               GenNative(m_bcc, relative, lab2, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab2);
            if op^.opcode = pc_grt then
               GenLab(lab3);
            end {else if}
         else begin
            lab2 := GenLabel;
            if op^.opcode = pc_grt then begin
               lab3 := GenLabel;
               GenNative(m_beq, relative, lab3, nil, 0);
               end; {if}
            if op^.optype in [cgByte,cgWord] then begin
               lab1 := GenLabel;
               GenNative(m_bvc, relative, lab1, nil, 0);
               GenImplied(m_ror_a);
               GenLab(lab1);
               GenNative(m_bpl, relative, lab2, nil, 0);
               end {if}
            else
               GenNative(m_bcs, relative, lab2, nil, 0);
            if op^.opcode = pc_grt then
               GenLab(lab3);
            GenImplied(m_dex);
            GenLab(lab2);
            GenImplied(m_txa);
            end; {else}
         end; {case optype of cgByte,cgUByte,cgWord,cgUWord}

      cgULong: begin
         lab1 := GenLabel;
         lab2 := GenLabel;
         simple := false;
         if SimpleLongOp(op^.right) then
            simple := true
         else if rOpcode in [pc_fjp,pc_tjp] then
            if SimpleLongOp(op^.left) then begin
               ReverseConditional;
               simple := true;
               end; {if}
         if simple then begin
            if op^.opcode = pc_grt then begin
               if SimpleLongOp(op^.left) then
                  ReverseConditional;
               if op^.opcode = pc_grt then
                  if op^.right^.opcode = pc_ldc then
                     if op^.right^.lval <> $ffffffff then begin
                        op^.right^.lval := op^.right^.lval + 1;
                        op^.opcode := pc_geq;
                        end; {if}
               end; {if}
            gLong.preference := A_X;
            GenTree(op^.left);
            if gLong.where = onStack then begin
               GenImplied(m_pla);
               GenImplied(m_plx);
               end; {if}
            if op^.opcode = pc_grt then
               if not (rOpcode in [pc_fjp,pc_tjp]) then
                  GenNative(m_ldy_imm, immediate, 0, nil, 0);
            with op^.right^ do
               case opcode of
                  pc_ldc: 
                     GenNative(m_cpx_imm, immediate, long(lval).msw, nil, 0);
                  pc_lao:
                     GenNative(m_cpx_imm, immediate, q, lab, shift16);
                  pc_lod:
                     GenNative(m_cpx_dir, direct, LabelToDisp(r)+q+2, nil, 0);
                  pc_ldo:
                     GenNative(m_cpx_abs, absolute, q+2, lab, 0);
                  end; {case}
            GenNative(m_bne, relative, lab1, nil, 0);
            with op^.right^ do
               case opcode of
                  pc_ldc: 
                     GenNative(m_cmp_imm, immediate, long(lval).lsw, nil, 0);
                  pc_lao:
                     GenNative(m_cmp_imm, immediate, q, lab, 0);
                  pc_lod:
                     GenNative(m_cmp_dir, direct, LabelToDisp(r)+q, nil, 0);
                  pc_ldo:
                     GenNative(m_cmp_abs, absolute, q, lab, 0);
                  end; {case}
            GenLab(lab1);
            if rOpcode = pc_fjp then begin
               if op^.opcode = pc_grt then begin
                  lab3 := GenLabel;
                  GenNative(m_beq, relative, lab3, nil, 0);
                  end; {if}
               GenNative(m_bcs, relative, lab2, nil, 0);
               if op^.opcode = pc_grt then
                  GenLabUsedOnce(lab3);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               end {if}
            else if rOpcode = pc_tjp then begin
               if op^.opcode = pc_grt then
                  GenNative(m_beq, relative, lab2, nil, 0);
               GenNative(m_bcc, relative, lab2, nil, 0);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab2);
               end {else if}
            else if op^.opcode = pc_geq then begin
               GenNative(m_lda_imm, immediate, 0, nil, 0);
               GenImplied(m_rol_a);
               end {else if}
            else {if op^.opcode = pc_grt then} begin
               GenNative(m_beq, relative, lab2, nil, 0);
               GenNative(m_bcc, relative, lab2, nil, 0);
               GenImplied(m_iny);
               GenLab(lab2);
               GenImplied(m_tya);
               end; {else}
            end {if}
         else begin
            gLong.preference := onStack;
            GenTree(op^.right);
            gLong.preference := A_X;
            GenTree(op^.left);
            if gLong.where = onStack then begin
               GenImplied(m_ply);
               GenImplied(m_pla);
               end {if}
            else begin
               GenImplied(m_tay);
               GenImplied(m_txa);
               end; {else}
            GenNative(m_ldx_imm, immediate, 1, nil, 0);
            GenNative(m_cmp_s, direct, 3, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_tya);
            GenNative(m_cmp_s, direct, 1, nil, 0);
            GenLab(lab1);
            if op^.opcode = pc_grt then begin
               lab3 := GenLabel;
               GenNative(m_beq, relative, lab3, nil, 0);
               end; {if}
            GenNative(m_bcs, relative, lab2, nil, 0);
            if op^.opcode = pc_grt then
               GenLab(lab3);
            GenImplied(m_dex);
            GenLab(lab2);
            GenImplied(m_pla);
            GenImplied(m_pla);
            GenImplied(m_txa);
            if rOpcode = pc_fjp then begin
               lab4 := GenLabel;
               GenNative(m_bne, relative, lab4, nil, 0);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab4);
               end {if}
            else if rOpcode = pc_tjp then begin
               lab4 := GenLabel;
               GenNative(m_beq, relative, lab4, nil, 0);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab4);
               end; {else if}
            end; {else}
         end;

      cgReal,cgDouble,cgComp,cgExtended: begin
         GenTree(op^.left);
         GenTree(op^.right);
         num := 31;
         if op^.opcode = pc_geq then
            GenCall(32)
         else
            GenCall(31);
         if (rOpcode = pc_fjp) or (rOpcode = pc_tjp) then begin
            lab1 := GenLabel;
            if rOpcode = pc_fjp then
               GenNative(m_bne, relative, lab1, nil, 0)
            else
               GenNative(m_beq, relative, lab1, nil, 0);
            GenNative(m_brl,longrelative,lb,nil,0);
            GenLab(lab1);
            end; {if}
         end; {case optype of cgReal..cgExtended}

      cgLong: begin
         gLong.preference := onStack;
         GenTree(op^.left);
         if op^.opcode = pc_geq then begin
            gLong.preference := A_X;
            GenTree(op^.right);
            if gLong.where = onStack then begin
               GenImplied(m_pla);
               GenImplied(m_plx);
               end; {if}
            num := 30;
            end {if}
         else begin
            gLong.preference := onStack;
            GenTree(op^.right);
            num := 29;
            end; {else}
         GenCall(num);
         if (rOpcode = pc_fjp) or (rOpcode = pc_tjp) then begin
            lab1 := GenLabel;
            if rOpcode = pc_fjp then
               GenNative(m_bne, relative, lab1, nil, 0)
            else
               GenNative(m_beq, relative, lab1, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end; {if}
         end; {case optype of cgLong}

      cgQuad: begin
         if op^.opcode = pc_geq then begin
            gQuad.preference := onStack;
            GenTree(op^.left);
            gQuad.preference := onStack;
            GenTree(op^.right);
            end {if}
         else {if op^.opcode = pc_grt then} begin
            gQuad.preference := onStack;
            GenTree(op^.right);
            gQuad.preference := onStack;
            GenTree(op^.left);
            end; {else}
         GenCall(88);
         if (rOpcode = pc_fjp) or (rOpcode = pc_tjp) then begin
            lab1 := GenLabel;
            if (rOpcode = pc_fjp) <> (op^.opcode = pc_grt) then
               GenNative(m_bcs, relative, lab1, nil, 0)
            else
               GenNative(m_bcc, relative, lab1, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end {if}
         else begin
            if op^.opcode = pc_geq then begin
               GenNative(m_lda_imm, immediate, 0, nil, 0);
               GenImplied(m_rol_a);
               end {if}
            else {if op^.opcode = pc_grt then} begin
               lab1 := GenLabel;
               GenNative(m_lda_imm, immediate, 1, nil, 0);
               GenNative(m_bcc, relative, lab1, nil, 0);
               GenImplied(m_dea);
               GenLab(lab1);
               end; {else}
            end; {else}
         end; {case optype of cgQuad}

      cgUQuad: begin
         simple := 
            SimplestQuadLoad(op^.left) and SimplestQuadLoad(op^.right)
            and not volatile;
         if not simple then begin
            gQuad.preference := onStack;
            GenTree(op^.left);
            gQuad.preference := onStack;
            GenTree(op^.right);
            end; {if}
         if op^.opcode = pc_geq then
            GenNative(m_ldx_imm, immediate, 1, nil, 0)
         else {if op^.opcode = pc_grt then}
            GenNative(m_ldx_imm, immediate, 0, nil, 0);
         lab1 := GenLabel;
         lab2 := GenLabel;
         if simple then begin
            OpOnWordOfQuad(m_lda_imm, op^.left, 6);
            OpOnWordOfQuad(m_cmp_imm, op^.right, 6);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 4);
            OpOnWordOfQuad(m_cmp_imm, op^.right, 4);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 2);
            OpOnWordOfQuad(m_cmp_imm, op^.right, 2);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 0);
            OpOnWordOfQuad(m_cmp_imm, op^.right, 0);
            end {if}
         else begin
            GenNative(m_lda_s, direct, 15, nil, 0);
            GenNative(m_cmp_s, direct, 7, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_lda_s, direct, 13, nil, 0);
            GenNative(m_cmp_s, direct, 5, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_lda_s, direct, 11, nil, 0);
            GenNative(m_cmp_s, direct, 3, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_lda_s, direct, 9, nil, 0);
            GenNative(m_cmp_s, direct, 1, nil, 0);
            end; {else}
         GenLab(lab1);
         if op^.opcode = pc_geq then begin
            GenNative(m_bcs, relative, lab2, nil, 0);
            GenImplied(m_dex);
            end {if}
         else begin {if op^.opcode = pc_grt then}
            GenNative(m_bcc, relative, lab2, nil, 0);
            GenNative(m_beq, relative, lab2, nil, 0);
            GenImplied(m_inx);
            end; {else}
         GenLab(lab2);
         if not simple then begin
            GenImplied(m_tsc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, 16, nil, 0);
            GenImplied(m_tcs);
            end; {if}
         GenImplied(m_txa);
         if rOpcode = pc_fjp then begin
            lab3 := GenLabel;
            GenNative(m_bne, relative, lab3, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab3);
            end {if}
         else if rOpcode = pc_tjp then begin
            lab3 := GenLabel;
            GenNative(m_beq, relative, lab3, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab3);
            end; {else if}
         end; {case optype of cgUQuad}

      otherwise:
         Error(cge1);
      end; {case}
end; {GenCmp}


procedure GenCnv (op: icptr);

{ generate a pc_cnv instruction					}

const                                {note: these constants list all legal }
                                     {      conversions; others are ignored}
   cReal             = $06;
   cDouble           = $07;
   cComp             = $08;
   cExtended         = $09;
   cVoid             = $0B;
   cLong             = $04;
   cULong            = $05;

   byteToWord        = $02;
   byteToUword       = $03;
   byteToLong        = $04;
   byteToUlong       = $05;
   byteToQuad        = $0C;
   byteToUQuad       = $0D;
   byteToReal        = $06;
   byteToDouble      = $07;
   ubyteToLong       = $14;
   ubyteToUlong      = $15;
   ubyteToQuad       = $1C;
   ubyteToUQuad      = $1D;
   ubyteToReal       = $16;
   ubyteToDouble     = $17;
   wordToByte        = $20;
   wordToUByte       = $21;
   wordToLong        = $24;
   wordToUlong       = $25;
   wordToQuad        = $2C;
   wordToUQuad       = $2D;
   wordToReal        = $26;
   wordToDouble      = $27;
   uwordToByte       = $30;
   uwordToUByte      = $31;
   uwordToLong       = $34;
   uwordToUlong      = $35;
   uwordToQuad       = $3C;
   uwordToUQuad      = $3D;
   uwordToReal       = $36;
   uwordToDouble     = $37;
   longTobyte        = $40;
   longToUbyte       = $41;
   longToWord        = $42;
   longToUword       = $43;
   longToQuad        = $4C;
   longToUQuad       = $4D;
   longToReal        = $46;
   longToDouble      = $47;
   longToVoid        = $4B;
   ulongTobyte       = $50;
   ulongToUbyte      = $51;
   ulongToWord       = $52;
   ulongToUword      = $53;
   ulongToQuad       = $5C;
   ulongToUQuad      = $5D;
   ulongToReal       = $56;
   ulongToDouble     = $57;
   ulongToVoid       = $5B;
   realTobyte        = $60;
   realToUbyte       = $61;
   realToWord        = $62;
   realToUword       = $63;
   realToLong        = $64;
   realToUlong       = $65;
   realToQuad        = $6C;
   realToUQuad       = $6D;
   realToVoid        = $6B;
   doubleTobyte      = $70;
   doubleToUbyte     = $71;
   doubleToWord      = $72;
   doubleToUword     = $73;
   doubleToLong      = $74;
   doubleToUlong     = $75;
   doubleToQuad      = $7C;
   doubleToUQuad     = $7D;
   quadToByte        = $C0;
   quadToUByte       = $C1;
   quadToWord        = $C2;
   quadToUword       = $C3;
   quadToLong        = $C4;
   quadToULong       = $C5;
   quadToReal        = $C6;
   quadToDouble      = $C7;
   quadToVoid        = $CB;
   uquadToByte       = $D0;
   uquadToUByte      = $D1;
   uquadToWord       = $D2;
   uquadToUword      = $D3;
   uquadToLong       = $D4;
   uquadToULong      = $D5;
   uquadToReal       = $D6;
   uquadToDouble     = $D7;
   uquadToVoid       = $DB;

var
   toRealType: baseTypeEnum;		{real type converted to}
   lab1: integer;			{used for branches}
   lLong: longType;			{used to reserve gLong}

begin {GenCnv}
lLong := gLong;
gLong.preference := onStack+A_X+constant;
gLong.where := onStack;
if op^.q in [quadToVoid,uQuadToVoid] then
   gQuad.preference := nowhere
else
   gQuad.preference := onStack;
if ((op^.q & $00F0) >> 4) in [cDouble,cExtended,cComp] then begin
   op^.q := (op^.q & $000F) | (cReal * 16);
   end; {if}
if (op^.q & $000F) in [cDouble,cExtended,cComp,cReal] then begin
   toRealType := baseTypeEnum(op^.q & $000F);
   op^.q := (op^.q & $00F0) | cReal;
   end {if}
else
   toRealType := cgVoid;
GenTree(op^.left);
if op^.q in [wordToLong,wordToUlong] then begin
   lab1 := GenLabel;
   GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenImpliedForFlags(m_tay);
   GenNative(m_bpl, relative, lab1, nil, 0);
   GenImplied(m_dex);
   GenLab(lab1);
   if (lLong.preference & A_X) <> 0 then
      gLong.where := A_X
   else begin
      gLong.where := onStack;
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   end {if}
else if op^.q in [byteToLong,byteToUlong] then begin
   lab1 := GenLabel;
   GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenImplied(m_dex);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   if (lLong.preference & A_X) <> 0 then
      gLong.where := A_X
   else begin
      gLong.where := onStack;
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   end {else if}
else if op^.q in [byteToWord,byteToUword] then begin
   lab1 := GenLabel;
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   end {else if}
else if op^.q in [ubyteToLong,ubyteToUlong,uwordToLong,uwordToUlong] then
   begin
   if (lLong.preference & A_X) <> 0 then begin
      gLong.where := A_X;
      GenNative(m_ldx_imm, immediate, 0, nil, 0);
      end {if}
   else begin
      gLong.where := onStack;
      GenNative(m_pea, immediate, 0, nil, 0);
      GenImplied(m_pha);
      end; {else}
   end {else if}
else if op^.q in [wordToUbyte,uwordToUbyte] then
   GenNative(m_and_imm, immediate, $00FF, nil, 0)
else if op^.q in [wordToByte,uwordToByte] then begin
   lab1 := GenLabel;
   GenNative(m_and_imm, immediate, $00FF, nil, 0);
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   end {else if}
else if op^.q in [byteToReal,uByteToReal,wordToReal] then begin
   GenCall(11);
   toRealType := cgExtended;
   end {else if}
else if op^.q = uwordToReal then begin
   GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenCall(12);
   toRealType := cgExtended;
   end {else if}
else if op^.q in [longToUbyte,ulongToUbyte] then begin
   if gLong.where = A_X then
      GenNative(m_and_imm, immediate, $00FF, nil, 0)
   else if gLong.where = constant then
      GenNative(m_lda_imm, immediate, long(gLong.lval).lsw & $00FF, nil, 0)
   else {if gLong.where = onStack then} begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      GenNative(m_and_imm, immediate, $00FF, nil, 0);
      end; {else if}
   end {else if}
else if op^.q in [longToByte,ulongToByte] then begin
   if gLong.where = A_X then
      GenNative(m_and_imm, immediate, $00FF, nil, 0)
   else if gLong.where = constant then
      GenNative(m_lda_imm, immediate, long(gLong.lval).lsw & $00FF, nil, 0)
   else {if gLong.where = onStack then} begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      GenNative(m_and_imm, immediate, $00FF, nil, 0);
      end; {else if}
   lab1 := GenLabel;
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   end {else if}
else if op^.q in [longToWord,longToUword,ulongToWord,ulongToUword] then begin
   {Note: if the result is in A_X, no further action is needed}
   if gLong.where = constant then
      GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0)
   else if gLong.where = onStack then begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      end; {else if}
   end {else if}
else if op^.q in [longToReal,uLongToReal] then begin
   if gLong.where = constant then begin
      GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0);
      GenNative(m_ldx_imm, immediate, long(gLong.lval).msw, nil, 0);
      end {if}
   else if gLong.where = onStack then begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      end; {else if}
   if op^.q = longToReal then
      GenCall(12)
   else
      GenCall(13);
   if toRealType <> cgReal then
      toRealType := cgExtended;
   end {else if}
else if op^.q = realToWord then
   GenCall(14)
else if op^.q = realToUbyte then begin
   GenCall(14);
   GenNative(m_and_imm, immediate, $00FF, nil, 0);
   end {else if}      
else if op^.q = realToByte then begin
   lab1 := GenLabel;
   GenCall(14);
   GenNative(m_and_imm, immediate, $00FF, nil, 0);
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   end {else if}
else if op^.q = realToUword then 
   GenCall(15)
else if op^.q in [realToLong,realToUlong] then begin
   if op^.q & $00FF = 5 then
      GenCall(17)
   else
      GenCall(16);
   if (lLong.preference & A_X) <> 0 then
      gLong.where := A_X
   else begin
      gLong.where := onStack;
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   end {else if}
else if op^.q = realToVoid then begin
   GenImplied(m_tsc);
   GenImplied(m_clc);
   GenNative(m_adc_imm, immediate, 10, nil, 0);
   GenImplied(m_tcs);
   end {else if}
else if op^.q in [longToVoid,ulongToVoid] then begin
   if gLong.where = onStack then begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      gLong.where := A_X;
      end; {if}
   end {else if}
else if op^.q in [ubyteToQuad,ubyteToUQuad,uwordToQuad,uwordToUQuad] then begin
   GenNative(m_ldy_imm, immediate, 0, nil, 0);
   GenImplied(m_phy);
   GenImplied(m_phy);
   GenImplied(m_phy);
   GenImplied(m_pha);
   gQuad.where := onStack;
   end {else if}
else if op^.q in [byteToQuad,byteToUQuad] then begin
   lab1 := GenLabel;
   GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenImplied(m_dex);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   GenImplied(m_phx);
   GenImplied(m_phx);
   GenImplied(m_phx);
   GenImplied(m_pha);
   gQuad.where := onStack;
   end {else if}
else if op^.q in [wordToQuad,wordToUQuad] then begin
   lab1 := GenLabel;
   GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenImpliedForFlags(m_tay);
   GenNative(m_bpl, relative, lab1, nil, 0);
   GenImplied(m_dex);
   GenLab(lab1);
   GenImplied(m_phx);
   GenImplied(m_phx);
   GenImplied(m_phx);
   GenImplied(m_pha);
   gQuad.where := onStack;
   end {else if}
else if op^.q in [ulongToQuad,ulongToUQuad] then begin
   if gLong.where = A_X then begin
      GenNative(m_pea, immediate, 0, nil, 0);
      GenNative(m_pea, immediate, 0, nil, 0);
      GenImplied(m_phx);
      GenImplied(m_pha);
      end {if}
   else if gLong.where = constant then begin
      GenNative(m_pea, immediate, 0, nil, 0);
      GenNative(m_pea, immediate, 0, nil, 0);
      GenNative(m_pea, immediate, long(gLong.lval).msw, nil, 0);
      GenNative(m_pea, immediate, long(gLong.lval).lsw, nil, 0);
      end {else if}
   else {if gLong.where = onStack then} begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      GenNative(m_pea, immediate, 0, nil, 0);
      GenNative(m_pea, immediate, 0, nil, 0);
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   gQuad.where := onStack;
   end {else if}
else if op^.q in [longToQuad,longToUQuad] then begin
   if gLong.where = constant then begin
      if glong.lval < 0 then begin
         GenNative(m_pea, immediate, -1, nil, 0);
         GenNative(m_pea, immediate, -1, nil, 0);
         GenNative(m_pea, immediate, long(gLong.lval).msw, nil, 0);
         GenNative(m_pea, immediate, long(gLong.lval).lsw, nil, 0);
         end {if}
      else begin
         GenNative(m_pea, immediate, 0, nil, 0);
         GenNative(m_pea, immediate, 0, nil, 0);
         GenNative(m_pea, immediate, long(gLong.lval).msw, nil, 0);
         GenNative(m_pea, immediate, long(gLong.lval).lsw, nil, 0);
         end; {else}
      end {if}
   else begin
      GenNative(m_ldy_imm, immediate, 0, nil, 0);
      if gLong.where = onStack then begin
         GenImplied(m_pla);
         GenImplied(m_plx);
         end {if}
      else {if gLong.where = A_X then}
         GenNative(m_cpx_imm, immediate, 0, nil, 0);
      lab1 := GenLabel;
      GenNative(m_bpl, relative, lab1, nil, 0);
      GenImplied(m_dey);
      GenLab(lab1);
      GenImplied(m_phy);
      GenImplied(m_phy);
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   gQuad.where := onStack;
   end {else if}
else if op^.q = realToQuad then begin
   GenCall(89);
   gQuad.where := onStack;
   end {else if}
else if op^.q = realToUQuad then begin
   GenCall(90);
   gQuad.where := onStack;
   end {else if}
else if op^.q in [quadToWord,uquadToWord,quadToUWord,uquadToUWord] then begin
   GenImplied(m_pla);
   GenImplied(m_plx);
   GenImplied(m_plx);
   GenImplied(m_plx);
   end {else if}
else if op^.q in [quadToUByte,uquadToUByte] then begin
   GenImplied(m_pla);
   GenImplied(m_plx);
   GenImplied(m_plx);
   GenImplied(m_plx);
   GenNative(m_and_imm, immediate, $00FF, nil, 0);
   end {else if}
else if op^.q in [quadToByte,uquadToByte] then begin
   GenImplied(m_pla);
   GenImplied(m_plx);
   GenImplied(m_ply);
   GenImplied(m_ply);
   GenNative(m_and_imm, immediate, $00FF, nil, 0);
   lab1 := GenLabel;
   GenNative(m_bit_imm, immediate, $0080, nil, 0);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, $FF00, nil, 0);
   GenLab(lab1);
   end {else if}
else if op^.q in [quadToLong,uquadToLong,quadToULong,uquadToULong] then begin
   GenImplied(m_pla);
   GenImplied(m_plx);
   GenImplied(m_ply);
   GenImplied(m_ply);
   if (lLong.preference & A_X) <> 0 then
      gLong.where := A_X
   else begin
      gLong.where := onStack;
      GenImplied(m_phx);
      GenImplied(m_pha);
      end; {else}
   end {else if}
else if op^.q in [quadToVoid,uquadToVoid] then begin
   if gQuad.where = onStack then begin
      GenImplied(m_tsc);
      GenImplied(m_clc);
      GenNative(m_adc_imm, immediate, 8, nil, 0);
      GenImplied(m_tcs);
      end; {if}
   end {else if}
else if op^.q = quadToReal then
   GenCall(83)
else if op^.q = uquadToReal then
   GenCall(84)
else if (op^.q & $000F) = cVoid then
   {do nothing}
else if (op^.q & $000F) in [cLong,cULong] then
   if (lLong.preference & gLong.where) = 0 then begin
      if gLong.where = constant then begin
         GenNative(m_pea, immediate, long(gLong.lval).msw, nil, 0);
         GenNative(m_pea, immediate, long(gLong.lval).lsw, nil, 0);
         end {if}
      else if gLong.where = A_X then begin
         GenImplied(m_phx);
         GenImplied(m_pha);
         end; {else if}
      gLong.where := onStack;
      end; {if}
if toRealType <> cgVoid then
   case toRealType of
      cgReal:   GenCall(91);
      cgDouble: GenCall(92);
      cgComp:   GenCall(93);
      cgExtended: ;
      end; {case}
end; {GenCnv}


procedure GenEquNeq (op: icptr; opcode: pcodes; lb: integer);

{ generate a pc_equ or pc_neq instruction			}
{								}
{ parameters:							}
{    op - node to generate the compare for			}
{    opcode - Opcode that will use the result of the compare.	}
{       If the result is used by a tjp or fjp, this procedure	}
{        generates special code and does the branch internally.	}
{    lb - For fjp, tjp, this is the label to branch to if	}
{        the condition is satisfied.				}

var
   nd: icptr;				{work node}
   num: integer;			{constant to compare to}
   lab1,lab2,lab3: integer;		{label numbers}
   bne: integer;			{instruction for a pc_equ bne branch}
   beq: integer;			{instruction for a pc_equ beq branch}
   leftOp,rightOp: pcodes;		{opcode codes to left, right}


   procedure DoOr (op: icptr);

   { or the two halves of a four byte value			}
   {								}
   { parameters:						}
   {    operand to or						}

   var
      disp: integer;			{disp of value on stack frame}

   begin {DoOr}
   with op^ do begin
      if opcode = pc_ldo then begin
         if smallMemoryModel then begin
            GenNative(m_lda_abs, absolute, q, lab, 0);
            GenNative(m_ora_abs, absolute, q+2, lab, 0);
            end {if}
         else begin
            GenNative(m_lda_long, longabsolute, q, lab, 0);
            GenNative(m_ora_long, longabsolute, q+2, lab, 0);
            end; {else}
         end {if}
      else begin
         disp := LabelToDisp(r) + q;
         if disp < 254 then begin
            GenNative(m_lda_dir, direct, disp, nil, 0);
            GenNative(m_ora_dir, direct, disp+2, nil, 0);
            end {if}
         else begin
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            GenNative(m_lda_dirX, direct, 0, nil, 0);
            GenNative(m_ora_dirX, direct, 2, nil, 0);
            end; {else}
         end; {else}
      end; {with}
   end; {DoOr}


   procedure DoCmp (op: icPtr);

   { compare a long value in A_X to a local or global scalar	}
   {								}
   { parameters:						}
   {    op - value to compare to				}

   var
      disp: integer;			{disp of value on stack frame}
      lab1: integer;			{label numbers}

   begin {DoCmp}
   lab1 := GenLabel;
   with op^ do begin
      if opcode = pc_ldo then begin
         if smallMemoryModel then begin
            GenNative(m_cmp_abs, absolute, q, lab, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_cpx_abs, absolute, q+2, lab, 0);
            end {if}
         else begin
            GenNative(m_cmp_long, longabsolute, q, lab, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_txa);
            GenNative(m_cmp_long, longabsolute, q+2, lab, 0);
            end; {else}
         end {if}
      else begin
         disp := LabelToDisp(r) + q;	
         if disp < 254 then begin
            GenNative(m_cmp_dir, direct, disp, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_cpx_dir, direct, disp+2, nil, 0);
            end {if}
         else begin
            GenImplied(m_txy);
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            GenNative(m_cmp_dirX, direct, 0, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_tya);
            GenNative(m_cmp_dirX, direct, 2, nil, 0);
            end; {else}
         end; {else}
      GenLab(lab1);
      end; {with}
   end; {DoCmp}


begin {GenEquNeq}
if op^.opcode = pc_equ then begin
   bne := m_bne;
   beq := m_beq;
   end {if}
else begin
   bne := m_beq;
   beq := m_bne;
   end; {else}
if op^.left^.opcode in [pc_lod,pc_ldo] then begin
   nd := op^.left;
   op^.left := op^.right;
   op^.right := nd;
   end; {if}
if op^.left^.opcode = pc_ldc then begin
   nd := op^.left;
   op^.left := op^.right;
   op^.right := nd;
   end; {if}
leftOp := op^.left^.opcode;		{set op codes for fast access}
rightOp := op^.right^.opcode;
if (op^.optype in [cgByte,cgUByte,cgWord,cgUWord]) and
   (rightOp = pc_ldc) then begin
   GenTree(op^.left);
   num := op^.right^.q;
   lab1 := GenLabel;
   if opcode in [pc_fjp,pc_tjp] then begin
      if num = 0 then begin
         if NeedsCondition(leftOp) then
            GenImpliedForFlags(m_tay);
         end {if}
      else if num = 1 then
         GenImplied(m_dea)
      else if num = -1 then
         GenImplied(m_ina)
      else
         GenNative(m_cmp_imm, immediate, num, nil, 0);
      if opcode = pc_fjp then
         GenNative(beq, relative, lab1, nil, 0)
      else
         GenNative(bne, relative, lab1, nil, 0);
      GenNative(m_brl, longrelative, lb, nil, 0);
      GenLab(lab1);
      end {if}
   else begin
      if num <> 0 then
         GenNative(m_eor_imm, immediate, num, nil, 0)
      else if NeedsCondition(leftOp) then
         GenImpliedForFlags(m_tax);
      GenNative(m_beq, relative, lab1, nil, 0);
      if op^.opcode = pc_equ then begin
         GenNative(m_lda_imm, immediate, $ffff, nil, 0);
         GenLab(lab1);
         GenImplied(m_ina);
         end {if}
      else begin
         GenNative(m_lda_imm, immediate, 1, nil, 0);
         GenLab(lab1);
         end; {else} 
      end; {else}
   end {if}
else if (op^.optype in [cgLong,cgULong]) and (leftOp in [pc_ldo,pc_lod])
   and (rightOp = pc_ldc) and (op^.right^.lval = 0) then begin
   if opcode in [pc_fjp,pc_tjp] then begin
      DoOr(op^.left);
      lab1 := GenLabel;
      if opcode = pc_fjp then
         GenNative(beq, relative, lab1, nil, 0)
      else
         GenNative(bne, relative, lab1, nil, 0);
      GenNative(m_brl, longrelative, lb, nil, 0);
      GenLab(lab1);
      end {if}
   else begin
      lab1 := GenLabel;
      DoOr(op^.left);
      GenNative(m_beq, relative, lab1, nil, 0);
      if op^.opcode = pc_equ then begin
         GenNative(m_lda_imm, immediate, $ffff, nil, 0);
         GenLab(lab1);
         GenImplied(m_ina);
         end {if}
      else begin
         GenNative(m_lda_imm, immediate, 1, nil, 0);
         GenLab(lab1);
         end; {else}
      end; {else}
   end {else if}
else if (op^.optype in [cgLong,cgULong]) and (rightOp in [pc_ldo,pc_lod]) then begin
   gLong.preference := A_X;
   GenTree(op^.left);
   if gLong.where = onStack then begin
      GenImplied(m_pla);
      GenImplied(m_plx);
      end; {if}
   if opcode in [pc_fjp,pc_tjp] then begin
      DoCmp(op^.right);
      lab1 := GenLabel;
      if opcode = pc_fjp then
         GenNative(beq, relative, lab1, nil, 0)
      else
         GenNative(bne, relative, lab1, nil, 0);
      GenNative(m_brl, longrelative, lb, nil, 0);
      GenLab(lab1);
      end {if}
   else begin
      lab1 := GenLabel;
      lab2 := GenLabel;
      DoCmp(op^.right);
      GenNative(bne, relative, lab1, nil, 0);
      GenNative(m_lda_imm, immediate, 1, nil, 0);
      GenNative(m_bra, relative, lab2, nil, 0);
      GenLab(lab1);
      GenNative(m_lda_imm, immediate, 0, nil, 0);
      GenLab(lab2);
      end; {else}
   end {else if}
else
   case op^.optype of

      cgByte,cgUByte,cgWord,cgUWord: begin
         if not Complex(op^.left) then
            if Complex(op^.right) then begin
               nd := op^.left;
               op^.left := op^.right;
               op^.right := nd;
               end; {if}
         GenTree(op^.left);
         if Complex(op^.right) or (not (opcode in [pc_fjp,pc_tjp])) then begin
            GenImplied(m_pha);
            GenTree(op^.right);
            GenNative(m_eor_s, direct, 1, nil, 0);
            GenImplied(m_plx);
            GenImplied(m_tax);
            if opcode in [pc_fjp,pc_tjp] then begin
               lab1 := GenLabel;
               if opcode = pc_fjp then
                  GenNative(beq, relative, lab1, nil, 0)
               else
                  GenNative(bne, relative, lab1, nil, 0);
               GenNative(m_brl, longrelative, lb, nil, 0);
               GenLab(lab1);
               end {if}
            else begin
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               if op^.opcode = pc_equ then begin
                  GenNative(m_lda_imm, immediate, $ffff, nil, 0);
                  GenLab(lab1);
                  GenImplied(m_ina);
                  end {if}
               else begin
                  GenNative(m_lda_imm, immediate, 1, nil, 0);
                  GenLab(lab1);
                  end; {else}
               end; {else}
            end {if}
         else begin
            OperA(m_cmp_imm, op^.right);
            lab1 := GenLabel;
            if opcode = pc_fjp then
               GenNative(beq, relative, lab1, nil, 0)
            else
               GenNative(bne, relative, lab1, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end; {else}
         end; {case optype of cgByte,cgUByte,cgWord,cgUWord}

      cgLong,cgULong: begin
         gLong.preference := onStack;
         GenTree(op^.left);
         gLong.preference := A_X;
         GenTree(op^.right);
         if gLong.where = onStack then begin
            GenImplied(m_pla);
            GenImplied(m_plx);
            end; {if}
         GenNative(m_ldy_imm, immediate, 1, nil, 0);
         GenNative(m_cmp_s, direct, 1, nil, 0);
         lab1 := GenLabel;
         GenNative(m_beq, relative, lab1, nil, 0);
         GenImplied(m_dey);
         GenLab(lab1);
         GenImplied(m_txa);
         GenNative(m_cmp_s, direct, 3, nil, 0);
         lab1 := GenLabel;
         GenNative(m_beq, relative, lab1, nil, 0);
         GenNative(m_ldy_imm, immediate, 0, nil, 0);
         GenLab(lab1);
         GenImplied(m_pla);
         GenImplied(m_pla);
         GenImplied(m_tya);
         if opcode in [pc_fjp,pc_tjp] then begin
            lab1 := GenLabel;
            if opcode = pc_fjp then
               GenNative(bne, relative, lab1, nil, 0)
            else
               GenNative(beq, relative, lab1, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end {if}
         else if op^.opcode = pc_neq then
            GenNative(m_eor_imm, immediate, 1, nil, 0);
         end; {case optype of cgLong,cgULong}

      cgReal,cgDouble,cgComp,cgExtended: begin
         GenTree(op^.left);
         GenTree(op^.right);
         GenCall(36);
         if opcode in [pc_fjp,pc_tjp] then begin
            lab1 := GenLabel;
            if opcode = pc_fjp then
               GenNative(bne, relative, lab1, nil, 0)
            else
               GenNative(beq, relative, lab1, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab1);
            end {if}
         else if op^.opcode = pc_neq then
            GenNative(m_eor_imm, immediate, 1, nil, 0);
         end; {case optype of cgReal..cgExtended}

      cgQuad,cgUQuad: begin
         if SimpleQuadLoad(op^.left) and (op^.right^.opcode = pc_ldc)
            and (op^.right^.qval.hi = 0) and (op^.right^.qval.lo = 0) then begin
            lab1 := GenLabel;
            OpOnWordOfQuad(m_lda_imm, op^.left, 0);
            if not volatile then
               GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_ora_imm, op^.left, 2);
            OpOnWordOfQuad(m_ora_imm, op^.left, 4);
            OpOnWordOfQuad(m_ora_imm, op^.left, 6);
            GenLab(lab1);
            end {if}
         else if SimpleQuadLoad(op^.left) and SimpleQuadLoad(op^.right)
            and not volatile then begin
            lab1 := GenLabel;
            OpOnWordOfQuad(m_lda_imm, op^.left, 0);
            OpOnWordOfQuad(m_eor_imm, op^.right, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 2);
            OpOnWordOfQuad(m_eor_imm, op^.right, 2);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 4);
            OpOnWordOfQuad(m_eor_imm, op^.right, 4);
            GenNative(m_bne, relative, lab1, nil, 0);
            OpOnWordOfQuad(m_lda_imm, op^.left, 6);
            OpOnWordOfQuad(m_eor_imm, op^.right, 6);
            GenLab(lab1);
            end {if}
         else begin
            gQuad.preference := onStack;
            GenTree(op^.left);
            gQuad.preference := onStack;
            GenTree(op^.right);

            lab1 := GenLabel;
            lab2 := GenLabel;
            GenImplied(m_pla);
            GenImplied(m_plx);
            GenImplied(m_ply);
            GenNative(m_eor_s, direct, 3, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_txa);
            GenNative(m_eor_s, direct, 5, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_tya);
            GenNative(m_eor_s, direct, 7, nil, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenImplied(m_pla);
            GenNative(m_eor_s, direct, 7, nil, 0);
            GenNative(m_bra, relative, lab2, nil, 0);
            GenLab(lab1);
            GenImplied(m_plx);
            GenLab(lab2);
            GenImplied(m_tax);

            GenImplied(m_tsc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, 8, nil, 0);
            GenImplied(m_tcs);
            
            GenImplied(m_txa);
            end; {else}
         
         if opcode in [pc_fjp,pc_tjp] then begin
            lab3 := GenLabel;
            if opcode = pc_fjp then
               GenNative(beq, relative, lab3, nil, 0)
            else
               GenNative(bne, relative, lab3, nil, 0);
            GenNative(m_brl, longrelative, lb, nil, 0);
            GenLab(lab3);
            end {if}
         else begin
            lab3 := GenLabel;
            GenNative(m_beq, relative, lab3, nil, 0);
            if op^.opcode = pc_equ then begin
               GenNative(m_lda_imm, immediate, $ffff, nil, 0);
               GenLab(lab3);
               GenImplied(m_ina);
               end {if}
            else begin
               GenNative(m_lda_imm, immediate, 1, nil, 0);
               GenLab(lab3);
               end; {else}
            end; {else}
         end; {case optype of cgQuad,cgUQuad}

      otherwise:
         Error(cge1);
      end; {case}
end; {GenEquNeq}


procedure GenGilGliGdlGld (op: icptr);

{ Generate code for a pc_gil, pc_gli, pc_gdl or pc_gld		}

var
   lab1: integer;			{branch point}
   lab: stringPtr;			{op^.lab}
   opcode: pcodes;			{op^.opcode}
   q: integer;				{op^.q}


   procedure DoGIncDec (opcode: pcodes; lab: stringPtr; p, q: integer);

   { Do a decrement or increment on a global four byte value	}
   {								}
   { parameters							}
   {    opcode - operation code					}
   {    lab - label						}
   {    q - disp to value					}
   {    p - number to ind/dec by				}

   var
      lab1: integer;			{branch point}

   begin {DoGIncDec}
   if smallMemoryModel then begin
      if opcode in [pc_gil,pc_gli] then begin
         lab1 := GenLabel;
         if p = 1 then begin
            GenNative(m_inc_abs, absolute, q, lab, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            end {if}
         else begin
            GenImplied(m_clc);
            GenNative(m_lda_abs, absolute, q, lab, 0);
            GenNative(m_adc_imm, immediate, p, nil, 0);
            GenNative(m_sta_abs, absolute, q, lab, 0);
            GenNative(m_bcc, relative, lab1, nil, 0);
            end; {else}
         GenNative(m_inc_abs, absolute, q+2, lab, 0);
         GenLab(lab1);
         end {if}
      else {if opcode in [pc_gdl,pc_gld] then} begin
         lab1 := GenLabel;
         if p = 1 then begin
            GenNative(m_lda_abs, absolute, q, lab, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            GenNative(m_dec_abs, absolute, q+2, lab, 0);
            GenLab(lab1);
            GenNative(m_dec_abs, absolute, q, lab, 0);
            end {if}
         else begin
            GenImplied(m_sec);
            GenNative(m_lda_abs, absolute, q, lab, 0);
            GenNative(m_sbc_imm, immediate, p, nil, 0);
            GenNative(m_sta_abs, absolute, q, lab, 0);
            GenNative(m_bcs, relative, lab1, nil, 0);
            GenNative(m_dec_abs, absolute, q+2, lab, 0);
            GenLab(lab1);
            end; {else}
         end {else}
      end {of smallMemoryModel}
   else begin
      if opcode in [pc_gil,pc_gli] then begin
         lab1 := GenLabel;
         GenImplied(m_clc);
         GenNative(m_lda_long, longabsolute, q, lab, 0);
         GenNative(m_adc_imm, immediate, p, nil, 0);
         GenNative(m_sta_long, longabsolute, q, lab, 0);
         GenNative(m_bcc, relative, lab1, nil, 0);
         GenNative(m_lda_long, longabsolute, q+2, lab, 0);
         GenImplied(m_ina);
         GenNative(m_sta_long, longabsolute, q+2, lab, 0);
         GenLab(lab1);
         end {if}
      else {if opcode in [pc_gdl,pc_gld] then} begin
         lab1 := GenLabel;
         GenImplied(m_sec);
         GenNative(m_lda_long, longabsolute, q, lab, 0);
         GenNative(m_sbc_imm, immediate, p, nil, 0);
         GenNative(m_sta_long, longabsolute, q, lab, 0);
         GenNative(m_bcs, relative, lab1, nil, 0);
         GenNative(m_lda_long, longabsolute, q+2, lab, 0);
         GenImplied(m_dea);
         GenNative(m_sta_long, longabsolute, q+2, lab, 0);
         GenLab(lab1);
         end; {else if}
      end; {else}
   end; {DoGIncDec}


begin {GenGilGliGdlGld}
opcode := op^.opcode;
q := op^.q;
lab := op^.lab;
case op^.optype of
   cgWord, cgUWord: begin
      if opcode = pc_gil then
         GenNative(m_inc_abs, absolute, q, lab, 0)
      else if opcode = pc_gdl then
         GenNative(m_dec_abs, absolute, q, lab, 0);
      if not skipLoad then
         GenNative(m_lda_abs, absolute, q, lab, 0);
      if opcode = pc_gli then
         GenNative(m_inc_abs, absolute, q, lab, 0)
      else if opcode = pc_gld then
         GenNative(m_dec_abs, absolute, q, lab, 0);
      end;

   cgByte, cgUByte: begin
      GenNative(m_sep, immediate, 32, nil, 0);
      if opcode = pc_gil then
         GenNative(m_inc_abs, absolute, q, lab, 0)
      else if opcode = pc_gdl then
         GenNative(m_dec_abs, absolute, q, lab, 0);
      if not skipLoad then
         GenNative(m_lda_abs, absolute, q, lab, 0);
      if opcode = pc_gli then
         GenNative(m_inc_abs, absolute, q, lab, 0)
      else if opcode = pc_gld then
         GenNative(m_dec_abs, absolute, q, lab, 0);
      GenNative(m_rep, immediate, 32, nil, 0);
      if not skipLoad then begin
         GenNative(m_and_imm, immediate, 255, nil, 0);
         if op^.optype = cgByte then begin
            GenNative(m_bit_imm, immediate, $0080, nil, 0);
            lab1 := GenLabel;
            GenNative(m_beq, relative, lab1, nil, 0);
            GenNative(m_ora_imm, immediate, $FF00, nil, 0);
            GenLab(lab1);
            GenNative(m_cmp_imm, immediate, $0000, nil, 0);
            end; {if}
         end; {if}
      end;

   cgLong, cgULong: begin
      if (A_X & gLong.preference) <> 0 then
         gLong.where := A_X
      else
         gLong.where := onStack;
      if opcode in [pc_gil,pc_gdl] then
         DoGIncDec(opcode, lab, op^.r, q);
      if not skipLoad then
         if smallMemoryModel then begin
            GenNative(m_ldx_abs, absolute, q+2, lab, 0);
            GenNative(m_lda_abs, absolute, q, lab, 0);
            if (opcode in [pc_gli,pc_gld]) and (op^.r <> 1) then
               gLong.where := onStack;
            if gLong.where = onStack then begin
               GenImplied(m_phx);
               GenImplied(m_pha);
               end; {if}
            end {if}
         else begin
            if opcode in [pc_gli,pc_gld] then
               gLong.where := onStack;
            GenNative(m_lda_long, longabsolute, q+2, lab, 0);
            if gLong.where = onStack then
               GenImplied(m_pha)
            else
               GenImplied(m_tax);
            GenNative(m_lda_long, longabsolute, q, lab, 0);
            if gLong.where = onStack then
               GenImplied(m_pha);
            end; {else}
      if opcode in [pc_gli,pc_gld] then
         DoGIncDec(opcode, lab, op^.r, q);
      end; {case cgLong,cgULong}

   otherwise:
      Error(cge1);
   end; {case}
end; {GenGilGliGdlGld}


procedure GenIilIliIdlIld (op: icptr);

{ Generate code for a pc_iil, pc_ili, pc_idl or pc_ild		}

var
   lab1: integer;                       {label}
   lSkipLoad: boolean;			{copy of skipLoad}
   opcode: pcodes;			{op^.opcode}
   short: boolean;			{doing a one byte operand?}

begin {GenIilIliIdlIld}
opcode := op^.opcode;
case op^.optype of
   cgByte,cgUByte,cgWord,cgUWord: begin
      short := op^.optype in [cgByte,cgUByte];
      lSkipLoad := skipLoad;
      skipLoad := false;
      GetPointer(op^.left);
      skipLoad := lSkipLoad;
      if gLong.where = inPointer then begin
         if short then
            GenNative(m_sep, immediate, 32, nil, 0);
         if gLong.fixedDisp then
            GenNative(m_lda_indl, direct, gLong.disp, nil, 0)
         else
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
         if opcode in [pc_ili,pc_iil] then
            GenImplied(m_ina)
         else
            GenImplied(m_dea);
         if gLong.fixedDisp then
            GenNative(m_sta_indl, direct, gLong.disp, nil, 0)
         else
            GenNative(m_sta_indly, direct, gLong.disp, nil, 0);
         if not skipLoad then
            if opcode = pc_ili then
               GenImplied(m_dea)
            else if opcode = pc_ild then
               GenImplied(m_ina);
         if short then
            GenNative(m_rep, immediate, 32, nil, 0);
         end {if}
      else if gLong.where = localAddress then begin
         gLong.disp := gLong.disp+op^.q;
         if gLong.fixedDisp then begin
            if short then
               GenNative(m_sep, immediate, 32, nil, 0);
            if (gLong.disp < 256) and (gLong.disp >= 0) then begin
               if (not skipLoad) and (opcode in [pc_ili,pc_ild]) then
                  GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenNative(m_inc_dir, direct, gLong.disp, nil, 0)
               else
                  GenNative(m_dec_dir, direct, gLong.disp, nil, 0);
               if (not skipLoad) and (opcode in [pc_iil,pc_idl]) then
                  GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
               end {if}
            else begin
               GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
               if (not skipLoad) and (opcode in [pc_ili,pc_ild]) then
                  GenNative(m_lda_dirX, direct, 0, nil, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenNative(m_inc_dirX, direct, 0, nil, 0)
               else
                  GenNative(m_dec_dirX, direct, 0, nil, 0);
               if (not skipLoad) and (opcode in [pc_iil,pc_idl]) then
                  GenNative(m_lda_dirX, direct, 0, nil, 0);
               end; {else}
            if short then
               GenNative(m_rep, immediate, 32, nil, 0);
            end
         else begin
            if (gLong.disp > 255) or (gLong.disp < 0) then begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               gLong.disp := 0;
               end; {if}
            if short then
               GenNative(m_sep, immediate, 32, nil, 0);
            if (not skipLoad) and (opcode in [pc_ili,pc_ild]) then
               GenNative(m_lda_dirX, direct, gLong.disp, nil, 0);
            if opcode in [pc_ili,pc_iil] then
               GenNative(m_inc_dirX, direct, gLong.disp, nil, 0)
            else
               GenNative(m_dec_dirX, direct, gLong.disp, nil, 0);
            if (not skipLoad) and (opcode in [pc_iil,pc_idl]) then
               GenNative(m_lda_dirX, direct, gLong.disp, nil, 0);
            if short then
               GenNative(m_rep, immediate, 32, nil, 0);
            end; {else}
         end {else if}
      else {if gLong.where = globalLabel then} begin
         gLong.disp := gLong.disp+op^.q;
         if short then
            GenNative(m_sep, immediate, 32, nil, 0);
         if gLong.fixedDisp then
            if smallMemoryModel then begin
               if (not skipLoad) and (opcode in [pc_ili,pc_ild]) then
                  GenNative(m_lda_abs, absolute, gLong.disp, gLong.lab, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenNative(m_inc_abs, absolute, gLong.disp, gLong.lab, 0)
               else
                  GenNative(m_dec_abs, absolute, gLong.disp, gLong.lab, 0);
               if (not skipLoad) and (opcode in [pc_iil,pc_idl]) then
                  GenNative(m_lda_abs, absolute, gLong.disp, gLong.lab, 0);
               end {if}
            else begin
               GenNative(m_lda_long, longAbs, gLong.disp, gLong.lab, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenImplied(m_ina)
               else
                  GenImplied(m_dea);
               GenNative(m_sta_long, longAbs, gLong.disp, gLong.lab, 0);
               if not skipLoad then
                  if opcode = pc_ili then
                     GenImplied(m_dea)
                  else if opcode = pc_ild then
                     GenImplied(m_ina);
               end {else}
         else
            if smallMemoryModel then begin
               if (not skipLoad) and (opcode in [pc_ili,pc_ild]) then
                  GenNative(m_lda_absX, absolute, gLong.disp, gLong.lab, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenNative(m_inc_absX, absolute, gLong.disp, gLong.lab, 0)
               else
                  GenNative(m_dec_absX, absolute, gLong.disp, gLong.lab, 0);
               if (not skipLoad) and (opcode in [pc_iil,pc_idl]) then
                  GenNative(m_lda_absX, absolute, gLong.disp, gLong.lab, 0);
               end {if}
            else begin
               GenNative(m_lda_longX, longAbs, gLong.disp, gLong.lab, 0);
               if opcode in [pc_ili,pc_iil] then
                  GenImplied(m_ina)
               else
                  GenImplied(m_dea);
               GenNative(m_sta_longX, longAbs, gLong.disp, gLong.lab, 0);
               if not skipLoad then
                  if opcode = pc_ili then
                     GenImplied(m_dea)
                  else if opcode = pc_ild then
                     GenImplied(m_ina);
               end; {else}
         if short then
            GenNative(m_rep, immediate, 32, nil, 0);
         end; {else}
      if not skipLoad then
         if short then begin
            GenNative(m_and_imm, immediate, $00FF, nil, 0);
            if op^.optype = cgByte then begin
               GenNative(m_bit_imm, immediate, $0080, nil, 0);
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               GenNative(m_ora_imm, immediate, $FF00, nil, 0);
               GenLab(lab1);
               end; {if}
            end; {if}
      end; {case cgByte,cgUByte,cgWord,cgUWord}

   otherwise:
      Error(cge1);
   end; {case}
end; {GenIilIliIdlIld}


procedure GenIncDec (op, save: icptr);

{ generate code for pc_inc, pc_dec				}
{								}
{ parameters:							}
{    op - pc_inc or pc_dec operation				}
{    save - save location (pc_str or pc_sro) or nil		}

var
   disp: integer;			{disp in stack frame}
   lab1: integer;			{branch point}
   opcode: pcodes;			{temp storage for op code}
   size: integer;			{number to increment by}
   clc,ina,adc: integer;		{instructions to generate}

begin {GenIncDec}
{set up local variables}
opcode := op^.opcode;
size := op^.q;

if op^.optype in [cgByte,cgUByte,cgWord,cgUWord] then begin
   GenTree(op^.left);
   if opcode = pc_inc then begin
      clc := m_clc;
      ina := m_ina;
      adc := m_adc_imm;
      end {if}
   else begin
      clc := m_sec; 
      ina := m_dea;
      adc := m_sbc_imm;
      end; {else}
   if size = 1 then
      GenImplied(ina)
   else if size = 2 then begin
      GenImplied(ina);
      GenImplied(ina);
      end {else if}
   else if size <> 0 then begin
      GenImplied(clc);
      GenNative(adc, immediate, size, nil, 0);
      end; {else if}
   end {if}
else if op^.optype in [cgLong,cgULong] then begin
   if SameLoc(op^.left, save) then begin
      lab1 := GenLabel;
      if size = 1 then begin
	 if opcode = pc_inc then begin
            DoOp(0, m_inc_abs, m_inc_dir, op^.left, 0);
            GenNative(m_bne, relative, lab1, nil, 0);
            DoOp(0, m_inc_abs, m_inc_dir, op^.left, 2);
            GenLab(lab1);
            end {if}
	 else {if opcode = pc_dec then} begin
	    DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
	    GenNative(m_bne, relative, lab1, nil, 0);
	    DoOp(0, m_dec_abs, m_dec_dir, op^.left, 2);
	    GenLab(lab1);
	    DoOp(0, m_dec_abs, m_dec_dir, op^.left, 0);
            end; {else}
	 end {if}
      else if opcode = pc_inc then begin
	 GenImplied(m_clc);
	 DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
	 GenNative(m_adc_imm, immediate, size, nil, 0);
	 DoOp(0, m_sta_abs, m_sta_dir, op^.left, 0);
	 GenNative(m_bcc, relative, lab1, nil, 0);
         DoOp(0, m_inc_abs, m_inc_dir, op^.left, 2);
	 GenLab(lab1);
	 end {else if}
      else begin
	 GenImplied(m_sec);
	 DoOp(m_lda_imm, m_lda_abs, m_lda_dir, op^.left, 0);
	 GenNative(m_sbc_imm, immediate, size, nil, 0);
	 DoOp(0, m_sta_abs, m_sta_dir, op^.left, 0);
	 GenNative(m_bcs, relative, lab1, nil, 0);
         DoOp(0, m_dec_abs, m_dec_dir, op^.left, 2);
	 GenLab(lab1);
	 end; {else}
      end {if}
   else begin
      if save <> nil then
         gLong.preference := A_X
      else
         gLong.preference := gLong.preference & (A_X | inpointer);
      if opcode = pc_dec then
         gLong.preference := gLong.preference & A_X;
      GenTree(op^.left);
      if opcode = pc_inc then
	 IncAddr(size)
      else begin
	 lab1 := GenLabel;
	 if gLong.where = A_X then begin
            GenImplied(m_sec);
            GenNative(m_sbc_imm, immediate, size, nil, 0);
            GenNative(m_bcs, relative, lab1, nil, 0);
            GenImplied(m_dex);
            end {if}
	 else begin
            GenImplied(m_sec);
            GenNative(m_lda_s, direct, 1, nil, 0);
            GenNative(m_sbc_imm, immediate, size, nil, 0);
            GenNative(m_sta_s, direct, 1, nil, 0);
            GenNative(m_bcs, relative, lab1, nil, 0);
            GenNative(m_lda_s, direct, 3, nil, 0);
            GenImplied(m_dea);
            GenNative(m_sta_s, direct, 3, nil, 0);
            end; {else}
	 GenLab(lab1);
	 end; {else}
      if save <> nil then
         if save^.opcode = pc_str then begin
            disp := LabelToDisp(save^.r) + save^.q;
            if disp < 254 then begin
               if gLong.where = onStack then
                  GenImplied(m_pla);
               GenNative(m_sta_dir, direct, disp, nil, 0);
               if gLong.where = onStack then
                  GenImplied(m_plx);
               GenNative(m_stx_dir, direct, disp+2, nil, 0);
               end {else if}
            else begin
               if gLong.where = A_X then
                  GenImplied(m_txy);
               GenNative(m_ldx_imm, immediate, disp, nil, 0);
               if gLong.where = onStack then
                  GenImplied(m_pla);
               GenNative(m_sta_dirX, direct, 0, nil, 0);
               if gLong.where = onStack then
                  GenImplied(m_pla)
               else
                  GenImplied(m_tya);
               GenNative(m_sta_dirX, direct, 2, nil, 0);
               end; {else}
            end {else if}
	 else {if save^.opcode = pc_sro then} begin
            if gLong.where = onStack then
               GenImplied(m_pla);
            if smallMemoryModel then
               GenNative(m_sta_abs, absolute, save^.q, save^.lab, 0)
            else
               GenNative(m_sta_long, longabsolute, save^.q, save^.lab, 0);
            if smallMemoryModel then begin
               if gLong.where = onStack then
        	  GenImplied(m_plx);
               GenNative(m_stx_abs, absolute, save^.q+2, save^.lab, 0)
               end {if}
            else begin
               if gLong.where = onStack then
        	  GenImplied(m_pla)
               else
        	  GenImplied(m_txa);
               GenNative(m_sta_long, longabsolute, save^.q+2, save^.lab, 0);
               end; {else}
            end; {else}                      
      end; {else}
   end {else if}
else
   Error(cge1);
end; {GenIncDec}


procedure GenInd (op: icptr);

{ Generate code for a pc_ind					}

var
   lab1: integer;			{label}
   lLong: longType;			{requested address type}
   lQuad: quadType;			{requested quad address type}
   optype: baseTypeEnum;		{op^.optype}
   q: integer;				{op^.q}
   volatileByte: boolean;		{is this a volatile byte access?}

begin {GenInd}
optype := op^.optype;
q := op^.q;
case optype of
   cgReal,cgDouble,cgComp,cgExtended: begin
      gLong.preference := onStack;
      GenTree(op^.left);
      if q <> 0 then
         IncAddr(q);
      if optype = cgReal then
         GenCall(21)
      else if optype = cgDouble then
         GenCall(22)
      else if optype = cgComp then
         GenCall(70)
      else if optype = cgExtended then
         GenCall(71);
      end; {case cgReal,cgDouble,cgComp,cgExtended}

   cgLong,cgULong: begin
      lLong := gLong;
      GetPointer(op^.left);
      if gLong.where = inPointer then begin
         if q = 0 then begin
            if gLong.fixedDisp then begin
               GenNative(m_ldy_imm, immediate, 2, nil, 0);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if (A_X & lLong.preference) <> 0 then
                  GenImplied(m_tax)
               else
                  GenImplied(m_pha);
               GenNative(m_lda_indl, direct, gLong.disp, nil, 0);
               end {if}
            else begin
               GenImplied(m_iny);
               GenImplied(m_iny);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if (A_X & lLong.preference) <> 0 then
                  GenImplied(m_tax)
               else
                  GenImplied(m_pha);
               GenImplied(m_dey);
               GenImplied(m_dey);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               end; {else}
            if (A_X & lLong.preference) = 0 then
               GenImplied(m_pha);
            end {if q = 0}
         else begin
            if gLong.fixedDisp then begin
               GenNative(m_ldy_imm, immediate, q+2, nil, 0);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if (A_X & lLong.preference) <> 0 then
                  GenImplied(m_tax)
               else
                  GenImplied(m_pha);
               GenNative(m_ldy_imm, immediate, q, nil, 0);
               end {if}
            else begin
               GenImplied(m_tya);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, q+2, nil, 0);
               GenImplied(m_tay);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if (A_X & lLong.preference) <> 0 then
                  GenImplied(m_tax)
               else
                  GenImplied(m_pha);
               GenImplied(m_dey);
               GenImplied(m_dey);
               end; {else}
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            if (A_X & lLong.preference) = 0 then
               GenImplied(m_pha);
            end; {else}
         end {if glong.where = inPointer}
      else if gLong.where = localAddress then begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if (gLong.disp < 254) and (gLong.disp >= 0) then begin
               GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
               GenNative(m_ldx_dir, direct, gLong.disp+2, nil, 0);
               end {if}
            else begin
               GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
               GenNative(m_lda_dirX, direct, 0, nil, 0);
               GenNative(m_ldy_dirX, direct, 2, nil, 0);
               GenImplied(m_tyx);
               end {else}
         else begin
            if (gLong.disp >= 254) or (gLong.disp < 0) then begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               gLong.disp := 0;
               end; {if}
            GenNative(m_ldy_dirX, direct, gLong.disp+2, nil, 0);
            GenNative(m_lda_dirX, direct, gLong.disp, nil, 0);
            GenImplied(m_tyx);
            end; {else}
         if (A_X & lLong.preference) = 0 then begin
            GenImplied(m_phx);
            GenImplied(m_pha);
            end; {if}
         end {else if gLong.where = localAddress}
      else {if gLong.where = globalLabel then} begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if smallMemoryModel then begin
               GenNative(m_lda_abs, absolute, gLong.disp, gLong.lab, 0);
               GenNative(m_ldx_abs, absolute, gLong.disp+2, gLong.lab, 0);
               end {if}
            else begin
               GenNative(m_lda_long, longAbs, gLong.disp+2, gLong.lab, 0);
               GenImplied(m_tax);
               GenNative(m_lda_long, longAbs, gLong.disp, gLong.lab, 0);
               end {else}
         else
            if smallMemoryModel then begin
               GenNative(m_ldy_absX, absolute, gLong.disp+2, gLong.lab, 0);
               GenNative(m_lda_absX, absolute, gLong.disp, gLong.lab, 0);
               GenImplied(m_tyx);
               end {if}
            else begin
               GenNative(m_lda_longX, longAbs, gLong.disp+2, gLong.lab, 0);
               GenImplied(m_tay);
               GenNative(m_lda_longX, longAbs, gLong.disp, gLong.lab, 0);
               GenImplied(m_tyx);
               end; {else}
         if (A_X & lLong.preference) = 0 then begin
            GenImplied(m_phx);
            GenImplied(m_pha);
            end; {if}
         end; {else}
      if (A_X & lLong.preference) <> 0 then
         gLong.where := A_X
      else
         gLong.where := onStack;
      end; {cgLong,cgULong}

   cgByte,cgUByte,cgWord,cgUWord: begin
      GetPointer(op^.left);
      if gLong.where = inPointer then begin
         volatileByte := (op^.r <> 0) and (optype in [cgByte,cgUByte]);
         if q = 0 then begin
            if volatileByte then
               GenNative(m_sep, immediate, 32, nil, 0);
            if gLong.fixedDisp then
               GenNative(m_lda_indl, direct, gLong.disp, nil, 0)
            else
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            if volatileByte then
               GenNative(m_rep, immediate, 32, nil, 0);
            end {if}
         else
            if gLong.fixedDisp then begin
               if volatileByte then
                  GenNative(m_sep, immediate, 32, nil, 0);
               GenNative(m_ldy_imm, immediate, q, nil, 0);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if volatileByte then
                  GenNative(m_rep, immediate, 32, nil, 0);
               end {if}
            else begin
               GenImplied(m_tya);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, q, nil, 0);
               GenImplied(m_tay);
               if volatileByte then
                  GenNative(m_sep, immediate, 32, nil, 0);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               if volatileByte then
                  GenNative(m_rep, immediate, 32, nil, 0);
               end; {else}
         end {if}
      else if gLong.where = localAddress then begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if (gLong.disp & $FF00) = 0 then
               GenNative(m_lda_dir, direct, gLong.disp, nil, 0)
            else begin
               GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
               GenNative(m_lda_dirX, direct, 0, nil, 0);
               end {else}
         else
            if (gLong.disp & $FF00) = 0 then
               GenNative(m_lda_dirX, direct, gLong.disp, nil, 0)
            else begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               GenNative(m_lda_dirX, direct, 0, nil, 0);
               end {else}
         end {else if}
      else {if gLong.where = globalLabel then} begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if smallMemoryModel then
               GenNative(m_lda_abs, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_lda_long, longAbs, gLong.disp, gLong.lab, 0)
         else
            if smallMemoryModel then
               GenNative(m_lda_absX, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_lda_longX, longAbs, gLong.disp, gLong.lab, 0)
         end; {else}
      if optype in [cgByte,cgUByte] then begin
         GenNative(m_and_imm, immediate, 255, nil, 0);
         if optype = cgByte then begin
            GenNative(m_cmp_imm, immediate, 128, nil, 0);
            lab1 := GenLabel;
            GenNative(m_bcc, relative, lab1, nil, 0);
            GenNative(m_ora_imm, immediate, $FF00, nil, 0);
            GenLab(lab1);
            end; {if}
         end; {if}
      end; {case cgByte,cgUByte,cgWord,cgUWord}

   cgQuad,cgUQuad: begin
      lQuad := gQuad;
      GetPointer(op^.left);
      gQuad := lQuad;
      gQuad.where := gQuad.preference; {unless overridden later}
      if gLong.where = inPointer then begin
         if gLong.fixedDisp then begin
            GenNative(m_ldy_imm, immediate, q+6, nil, 0);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            StoreWordOfQuad(6);
            GenNative(m_ldy_imm, immediate, q+4, nil, 0);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            StoreWordOfQuad(4);
            GenNative(m_ldy_imm, immediate, q+2, nil, 0);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            StoreWordOfQuad(2);
            if q = 0 then
               GenNative(m_lda_indl, direct, gLong.disp, nil, 0)
            else begin
               GenNative(m_ldy_imm, immediate, q, nil, 0);
               GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
               end; {else}
            StoreWordOfQuad(0);
            end {if}
         else begin
            gQuad.where := onStack;
            GenImplied(m_tya);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, q+6, nil, 0);
            GenImplied(m_tay);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            GenImplied(m_pha);
            GenImplied(m_dey);
            GenImplied(m_dey);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            GenImplied(m_pha);
            GenImplied(m_dey);
            GenImplied(m_dey);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            GenImplied(m_pha);
            GenImplied(m_dey);
            GenImplied(m_dey);
            GenNative(m_lda_indly, direct, gLong.disp, nil, 0);
            GenImplied(m_pha);
            end; {else}
         end {if glong.where = inPointer}
      else if gLong.where = localAddress then begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if (gLong.disp < 250) and (gLong.disp >= 0) then begin
               if gQuad.preference = onStack then begin
                  GenNative(m_pei_dir, direct, gLong.disp+6, nil, 0);
                  GenNative(m_pei_dir, direct, gLong.disp+4, nil, 0);
                  GenNative(m_pei_dir, direct, gLong.disp+2, nil, 0);
                  GenNative(m_pei_dir, direct, gLong.disp, nil, 0);
                  end {if}
               else begin
                  GenNative(m_lda_dir, direct, gLong.disp+6, nil, 0);
                  StoreWordOfQuad(6);
                  GenNative(m_lda_dir, direct, gLong.disp+4, nil, 0);
                  StoreWordOfQuad(4);
                  GenNative(m_lda_dir, direct, gLong.disp+2, nil, 0);
                  StoreWordOfQuad(2);
                  GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
                  StoreWordOfQuad(0);
                  end; {else}
               end {if}
            else begin
               gQuad.where := onStack;
               GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
               GenNative(m_lda_dirX, direct, 6, nil, 0);
               GenImplied(m_pha);
               GenNative(m_lda_dirX, direct, 4, nil, 0);
               GenImplied(m_pha);
               GenNative(m_lda_dirX, direct, 2, nil, 0);
               GenImplied(m_pha);
               GenNative(m_lda_dirX, direct, 0, nil, 0);
               GenImplied(m_pha);
               end {else}
         else begin
            gQuad.where := onStack;
            if (gLong.disp >= 250) or (gLong.disp < 0) then begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               gLong.disp := 0;
               end; {if}
            GenNative(m_lda_dirX, direct, gLong.disp+6, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirX, direct, gLong.disp+4, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirX, direct, gLong.disp+2, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirX, direct, gLong.disp, nil, 0);
            GenImplied(m_pha);
            end; {else}
         end {else if gLong.where = localAddress}
      else {if gLong.where = globalLabel then} begin
         gLong.disp := gLong.disp+q;
         if gLong.fixedDisp then
            if smallMemoryModel then begin
               GenNative(m_lda_abs, absolute, gLong.disp+6, gLong.lab, 0);
               StoreWordOfQuad(6);
               GenNative(m_lda_abs, absolute, gLong.disp+4, gLong.lab, 0);
               StoreWordOfQuad(4);
               GenNative(m_lda_abs, absolute, gLong.disp+2, gLong.lab, 0);
               StoreWordOfQuad(2);
               GenNative(m_lda_abs, absolute, gLong.disp, gLong.lab, 0);
               StoreWordOfQuad(0);
               end {if}
            else begin
               GenNative(m_lda_long, longAbs, gLong.disp+6, gLong.lab, 0);
               StoreWordOfQuad(6);
               GenNative(m_lda_long, longAbs, gLong.disp+4, gLong.lab, 0);
               StoreWordOfQuad(4);
               GenNative(m_lda_long, longAbs, gLong.disp+2, gLong.lab, 0);
               StoreWordOfQuad(2);
               GenNative(m_lda_long, longAbs, gLong.disp, gLong.lab, 0);
               StoreWordOfQuad(6);
               end {else}
         else
            if smallMemoryModel then begin
               gQuad.where := onStack;
               GenNative(m_lda_absX, absolute, gLong.disp+6, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_absX, absolute, gLong.disp+4, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_absX, absolute, gLong.disp+2, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_absX, absolute, gLong.disp, gLong.lab, 0);
               GenImplied(m_pha);
               end {if}
            else begin
               gQuad.where := onStack;
               GenNative(m_lda_longX, longAbs, gLong.disp+6, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_longX, longAbs, gLong.disp+4, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_longX, longAbs, gLong.disp+2, gLong.lab, 0);
               GenImplied(m_pha);
               GenNative(m_lda_longX, longAbs, gLong.disp, gLong.lab, 0);
               GenImplied(m_pha);
               end; {else}
         end; {else}
      end; {case cgQuad,cgUQuad}
   otherwise: Error(cge1);
   end; {case}
end; {GenInd}



procedure GenIxa (op: icptr);

{ Generate code for a pc_ixa					}

var
   lab1,lab2: integer;			{branch labels}
   lLong: longType;			{type of address}
   signed: boolean;			{doing signed addition?}
   zero: boolean;			{is the index 0?}


   procedure Index;

   { Get the index size						}

   var
      lLong: longType;			{temp for preserving left node info}

   begin {Index}
   zero := false;
   with op^.right^ do begin
      if opcode = pc_ldc then begin
         if q = 0 then
            zero := true
         else
            GenNative(m_lda_imm, immediate, q, nil, 0);
         end {if}
      else begin
         lLong := gLong;
         GenTree(op^.right);
         gLong := lLong;
         end; {else}      
      end; {with}
   end; {Index}


   function IndexCanBeNegative: boolean;

   { Check if the index value (right argument) of a pc_ixa      }
   { can validly be negative.  Returns false if this is         }
   { precluded by the type of the operation or other available  }
   { information, or if any use of a negative index would be    }
   { undefined behavior.  Otherwise, returns true.              }
   {                                                            }
   { parameters:                                                }
   {    op - pc_ixa operation                                   }

   begin {IndexCanBeNegative}
   IndexCanBeNegative := true;
   if op^.optype in [cgUByte,cgUWord] then
      IndexCanBeNegative := false
   else if (op^.right^.opcode = pc_ldc) and (op^.right^.q >= 0) then
      IndexCanBeNegative := false
   else if (op^.left^.opcode in [pc_lao,pc_lda]) and (op^.left^.q = 0) then
      {Can't index before start of array, so using a negative index would be UB}
      IndexCanBeNegative := false;
   end; {IndexCanBeNegative}


begin {GenIxa}
lLong := gLong;
if smallMemoryModel or (op^.left^.opcode = pc_lda) then begin
   gLong.preference := inPointer+localAddress+globalLabel;
   GenTree(op^.left);
   case gLong.where of

      onStack: begin
         Index;
         if not zero then begin
            GenImplied(m_clc);
            GenNative(m_adc_s, direct, 1, nil, 0);
            GenNative(m_sta_s, direct, 1, nil, 0);
            lab1 := GenLabel;
	    GenNative(m_bcc, relative, lab1, nil, 0);
            GenNative(m_lda_s, direct, 3, nil, 0);
            GenImplied(m_ina);
            GenNative(m_sta_s, direct, 3, nil, 0);
	    GenLab(lab1);
            end; {if}
         end; {case onStack}

      inPointer: begin
         if not gLong.fixedDisp then begin
            if Complex(op^.right) then begin
               GenImplied(m_phy);
               Index;
               if not zero then begin
                  GenImplied(m_clc);
                  GenNative(m_adc_s, direct, 1, nil, 0);
                  GenNative(m_sta_s, direct, 1, nil, 0);
                  end; {if}
               GenImplied(m_ply);
               end {if}
            else begin
               GenImplied(m_tya);
               GenImplied(m_clc);
               OperA(m_adc_imm, op^.right);
               GenImplied(m_tay);
               end; {else}
            end {if}
         else begin
            Index;
            if not zero then begin
               GenImplied(m_tay);
               gLong.fixedDisp := false;
               end; {if}
            end; {else}
         if (inPointer & lLong.preference) = 0 then begin
            if not gLong.fixedDisp then begin
               GenImplied(m_tya);
               GenImplied(m_clc);
               GenNative(m_adc_dir, direct, gLong.disp, nil, 0);
               GenNative(m_ldx_dir, direct, gLong.disp+2, nil, 0);
               lab1 := GenLabel;
               GenNative(m_bcc, relative, lab1, nil, 0);
               GenImplied(m_inx);
               GenLab(lab1);
               end {if}
            else begin
               GenNative(m_ldx_dir, direct, gLong.disp+2, nil, 0);
               GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
               end; {else}
            GenImplied(m_phx);
            GenImplied(m_pha);
            gLong.where := onStack;
            end; {if}
         end; {case inPointer}

      localAddress,globalLabel: begin
         if not gLong.fixedDisp then begin
            if Complex(op^.right) then begin
               GenImplied(m_phx);
               Index;
               if not zero then begin
                  GenImplied(m_clc);
                  GenNative(m_adc_s, direct, 1, nil, 0);
                  GenNative(m_sta_s, direct, 1, nil, 0);
                  end; {if}
               GenImplied(m_plx);
               end {if}
            else begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               OperA(m_adc_imm, op^.right);
               GenImplied(m_tax);
               end; {else}
            end {if}
         else if Complex(op^.right) then begin
            Index;
            if not zero then begin
               GenImplied(m_tax);
               gLong.fixedDisp := false;
               end; {if}
            end {else if}
         else begin
            LoadX(op^.right);
            gLong.fixedDisp := false;
            end; {else}
         if gLong.where = globalLabel then
            if IndexCanBeNegative then begin
               if (gLong.disp >= 0) and (gLong.disp <= 2) then begin
                  while gLong.disp > 0 do begin
                     GenImplied(m_inx);
                     gLong.disp := gLong.disp - 1;
                     end; {while}
                  end {if}
               else begin
                  GenImplied(m_txa);
                  GenImplied(m_clc);
                  GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                  GenImplied(m_tax);
                  gLong.disp := 0;
                  end; {else}
               end; {if}
         if (lLong.preference & gLong.where) = 0 then begin
            if (lLong.preference & inPointer) <> 0 then begin
               if gLong.where = localAddress then begin
        	  if not gLong.fixedDisp then begin
                     GenNative(m_stz_dir, direct, dworkLoc+2, nil, 0);
                     GenImplied(m_phx);
                     GenImplied(m_tdc);
                     GenImplied(m_clc);
                     if gLong.disp <> 0 then
                	GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                     GenNative(m_adc_s, direct, 1, nil, 0);
                     GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
                     GenImplied(m_plx);
                     end {if}
        	  else begin
                     GenNative(m_stz_dir, direct, dworkLoc+2, nil, 0);
                     GenImplied(m_tdc);
                     GenImplied(m_clc);
                     GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                     GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
                     end; {else}
        	  end {if}
               else begin
        	  if not gLong.fixedDisp then begin
                     GenImplied(m_txa);
                     GenImplied(m_clc);
                     GenNative(m_adc_imm, immediate, gLong.disp, gLong.lab, 0);
                     GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
                     GenNative(m_ldx_imm, immediate, gLong.disp, gLong.lab, shift16);
                     lab1 := GenLabel;
                     GenNative(m_bcc, relative, lab1, nil, 0);
                     GenImplied(m_inx);
                     GenLab(lab1);
                     GenNative(m_stx_dir, direct, dworkLoc+2, nil, 0);
                     end {if}
        	  else begin
                     GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, shift16);
                     GenNative(m_sta_dir, direct, dworkLoc+2, nil, 0);
                     GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, 0);
                     GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
                     end; {else}                                               
        	  end; {else}
               gLong.where := inPointer;
               gLong.fixedDisp := true;
               gLong.disp := dworkLoc;
               end {if}
            else begin
               if gLong.where = localAddress then begin
        	  if not gLong.fixedDisp then begin
                     GenNative(m_pea, immediate, 0, nil, 0);
                     GenImplied(m_phx);
                     GenImplied(m_tdc);
                     GenImplied(m_clc);
                     GenNative(m_adc_s, direct, 1, nil, 0);
                     if gLong.disp <> 0 then
                	GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                     GenNative(m_sta_s, direct, 1, nil, 0);
                     end {if}
        	  else begin
                     GenNative(m_pea, immediate, 0, nil, 0);
                     GenImplied(m_tdc);
                     GenImplied(m_clc);
                     GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                     GenImplied(m_pha);
                     end; {else}
        	  end {if}
               else begin
        	  if not gLong.fixedDisp then begin
                     GenImplied(m_txa);
                     GenImplied(m_clc);
                     GenNative(m_adc_imm, immediate, gLong.disp, gLong.lab, 0);
                     GenNative(m_ldx_imm, immediate, gLong.disp, gLong.lab, shift16);
                     lab1 := GenLabel;
                     GenNative(m_bcc, relative, lab1, nil, 0);
                     GenImplied(m_inx);
                     GenLab(lab1);
                     GenImplied(m_phx);
                     GenImplied(m_pha);
                     end {if}
        	  else begin
                     GenNative(m_pea, immediate, gLong.disp, gLong.lab, shift16);
                     GenNative(m_pea, immediate, gLong.disp, gLong.lab, 0);
                     end; {else}
        	  end; {else}
               gLong.where := onStack;
               end; {else}
            end; {if}
         end; {case localAddress,globalLabel}
      otherwise:
         Error(cge1);
      end; {case}
   end {if smallMemoryModel or (op^.left^.opcode = pc_lda)}
else begin
   signed := IndexCanBeNegative;
   if (not signed)
      and ((globalLabel & lLong.preference) <> 0)
      and (op^.left^.opcode = pc_lao) 
      then begin
      if Complex(op^.right) then begin
         GenTree(op^.right);
         GenImplied(m_tax);
         end {if}
      else
         LoadX(op^.right);
      gLong.where := globalLabel;
      gLong.fixedDisp := false;
      gLong.disp := op^.left^.q;
      gLong.lab := op^.left^.lab;
      end {if}
   else begin
      if op^.left^.opcode = pc_lao then begin
         GenTree(op^.right);
         GenNative(m_ldx_imm, immediate, op^.left^.q, op^.left^.lab, shift16);
         if signed then begin
            GenImpliedForFlags(m_tay);
            lab2 := GenLabel;
            GenNative(m_bpl, relative, lab2, nil, 0);
            GenImplied(m_dex);
            GenLab(lab2);
            signed := false;
            end; {if}
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, op^.left^.q, op^.left^.lab, 0);
         end {if}
      else begin
         gLong.preference := onStack;
         GenTree(op^.left);
         GenTree(op^.right);
         if signed then
            GenImplied(m_tay);
         GenImplied(m_clc);
         GenNative(m_adc_s, direct, 1, nil, 0);
         GenImplied(m_plx);
         GenImplied(m_plx);
         end; {else}
      lab1 := GenLabel;
      GenNative(m_bcc, relative, lab1, nil, 0);
      GenImplied(m_inx);
      GenLab(lab1);
      if signed then begin
         GenNative(m_cpy_imm, immediate, $0000, nil, 0);
         lab2 := GenLabel;
         GenNative(m_bpl, relative, lab2, nil, 0);
         GenImplied(m_dex);
         GenLab(lab2);
         end; {if}
      if (A_X & lLong.preference) <> 0 then
         gLong.where := A_X
      else begin
         GenImplied(m_phx);
         GenImplied(m_pha);
         gLong.where := onStack;
         end; {else}
      end; {else}
   end; {else}
end; {GenIxa}


procedure GenLilLliLdlLld (op: icptr);

{ Generate code for a pc_lil, pc_lli, pc_ldl or pc_lld		}

var
   disp: integer;			{load location}
   lab1: integer;			{branch point}
   opcode: pcodes;			{op^.opcode}


   procedure DoXIncDec (op: pcodes; p: integer);

   { Do a decrement or increment on a local four byte value X	}
   { bytes into the stack frame					}
   {								}
   { parameters							}
   {    op - operation code					}
   {    p - number to ind/dec by				}

   var
      lab1: integer;			{branch point}

   begin {DoXIncDec}                                     
   if op in [pc_lil,pc_lli] then begin
      lab1 := GenLabel;
      if p = 1 then begin
	 GenNative(m_inc_dirx, direct, 0, nil, 0);
	 GenNative(m_bne, relative, lab1, nil, 0);
	 end {if}
      else begin
	 GenImplied(m_clc);
	 GenNative(m_lda_dirx, direct, 0, nil, 0);
	 GenNative(m_adc_imm, immediate, p, nil, 0);
	 GenNative(m_sta_dirx, direct, 0, nil, 0);
	 GenNative(m_bcc, relative, lab1, nil, 0);
	 end; {else}
      GenNative(m_inc_dirx, direct, 2, nil, 0);
      GenLab(lab1);
      end {if}
   else {if op in [pc_ldl,pc_lld] then} begin
      lab1 := GenLabel;
      if p = 1 then begin
	 GenNative(m_lda_dirx, direct, 0, nil, 0);
	 GenNative(m_bne, relative, lab1, nil, 0);
	 GenNative(m_dec_dirx, direct, 2, nil, 0);
	 GenLab(lab1);
	 GenNative(m_dec_dirx, direct, 0, nil, 0);
	 end {if}
      else begin
	 GenImplied(m_sec);
	 GenNative(m_lda_dirx, direct, 0, nil, 0);
	 GenNative(m_sbc_imm, immediate, p, nil, 0);
	 GenNative(m_sta_dirx, direct, 0, nil, 0);
	 GenNative(m_bcs, relative, lab1, nil, 0);
	 GenNative(m_dec_dirx, direct, 2, nil, 0);
	 GenLab(lab1);
	 end; {else}
      end; {else}
   end; {DoXIncDec}


   procedure DoLIncDec (op: pcodes; disp, p: integer);

   { Do a decrement or increment on a local four byte value	}
   {								}
   { parameters							}
   {    op - operation code					}
   {    disp - disp in stack frame to value			}
   {    p - number to ind/dec by				}

   var
      lab1: integer;			{branch point}

   begin {DoLIncDec}
   if op in [pc_lil,pc_lli] then begin
      lab1 := GenLabel;
      if p = 1 then begin
	 GenNative(m_inc_dir, direct, disp, nil, 0);
	 GenNative(m_bne, relative, lab1, nil, 0);
	 end {if}
      else begin
	 GenImplied(m_clc);
	 GenNative(m_lda_dir, direct, disp, nil, 0);
	 GenNative(m_adc_imm, immediate, p, nil, 0);
	 GenNative(m_sta_dir, direct, disp, nil, 0);
	 GenNative(m_bcc, relative, lab1, nil, 0);
	 end; {else}
      GenNative(m_inc_dir, direct, disp+2, nil, 0);
      GenLab(lab1);
      end {if}
   else {if op in [pc_ldl,pc_lld] then} begin
      lab1 := GenLabel;
      if p = 1 then begin
	 GenNative(m_lda_dir, direct, disp, nil, 0);
	 GenNative(m_bne, relative, lab1, nil, 0);
	 GenNative(m_dec_dir, direct, disp+2, nil, 0);
	 GenLab(lab1);
	 GenNative(m_dec_dir, direct, disp, nil, 0);
	 end {if}
      else begin
	 GenImplied(m_sec);
	 GenNative(m_lda_dir, direct, disp, nil, 0);
	 GenNative(m_sbc_imm, immediate, p, nil, 0);
	 GenNative(m_sta_dir, direct, disp, nil, 0);
	 GenNative(m_bcs, relative, lab1, nil, 0);
	 GenNative(m_dec_dir, direct, disp+2, nil, 0);
	 GenLab(lab1);
	 end; {else}
      end; {else}
   end; {DoLIncDec}


begin {GenLilLliLdlLld}
disp := LabelToDisp(op^.r);
opcode := op^.opcode;
case op^.optype of
   cgLong, cgULong: begin
      gLong.where := onStack;
      if disp >= 254 then begin
         GenNative(m_ldx_imm, immediate, disp, nil, 0);
         if opcode in [pc_lil,pc_ldl] then
            DoXIncDec(opcode, op^.q);
         if not skipLoad then begin
            GenNative(m_lda_dirx, direct, 2, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirx, direct, 0, nil, 0);
            GenImplied(m_pha);
            end {if}
         else
            gLong.where := A_X;
         if opcode in [pc_lli,pc_lld] then
            DoXIncDec(opcode, op^.q);
         end {if}
      else begin
         if opcode in [pc_lil,pc_ldl] then
            DoLIncDec(opcode, disp, op^.q);
         if not skipLoad then begin
            GenNative(m_pei_dir, direct, disp+2, nil, 0);
            GenNative(m_pei_dir, direct, disp, nil, 0);
            end {if}
         else
            gLong.where := A_X;
         if opcode in [pc_lli,pc_lld] then
            DoLIncDec(opcode, disp, op^.q);
         end; {else}
      end;

   cgByte, cgUByte, cgWord, cgUWord: begin
      if op^.optype in [cgByte,cgUByte] then
         GenNative(m_sep, immediate, 32, nil, 0);
      if disp >= 256 then begin
         GenNative(m_ldx_imm, immediate, disp, nil, 0);
         if opcode = pc_lil then
            GenNative(m_inc_dirx, direct, 0, nil, 0)
         else if opcode = pc_ldl then
            GenNative(m_dec_dirx, direct, 0, nil, 0);
         if not skipLoad then
            GenNative(m_lda_dirx, direct, 0, nil, 0);
         if opcode = pc_lli then
            GenNative(m_inc_dirx, direct, 0, nil, 0)
         else if opcode = pc_lld then
            GenNative(m_dec_dirx, direct, 0, nil, 0);
         end
      else begin
         if opcode = pc_lil then
            GenNative(m_inc_dir, direct, disp, nil, 0)
         else if opcode = pc_ldl then
            GenNative(m_dec_dir, direct, disp, nil, 0);
         if not skipLoad then
            GenNative(m_lda_dir, direct, disp, nil, 0);
         if opcode = pc_lli then
            GenNative(m_inc_dir, direct, disp, nil, 0)
         else if opcode = pc_lld then
            GenNative(m_dec_dir, direct, disp, nil, 0);
         end; {else}
      if op^.optype in [cgByte,cgUByte] then begin
         GenNative(m_rep, immediate, 32, nil, 0);
         if not skipLoad then begin
            GenNative(m_and_imm, immediate, $00FF, nil, 0);
            if op^.optype = cgByte then begin
               GenNative(m_bit_imm, immediate, $0080, nil, 0);
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               GenNative(m_ora_imm, immediate, $FF00, nil, 0);
               GenLab(lab1);
               GenNative(m_cmp_imm, immediate, $0000, nil, 0);
               end; {if}
            end; {if}
         end; {if}
      end;

   otherwise:
      Error(cge1);

   end; {case}
end; {GenLilLliLdlLld}


procedure GenLogic (op: icptr);

{ generate a pc_and, pc_ior, pc_bnd, pc_bor or pc_bxr		}

var
   lab1,lab2,lab3: integer;		{label}
   nd: icptr;				{temp node pointer}
   opcode: pcodes;			{operation code}

begin {GenLogic}
opcode := op^.opcode;
if opcode in [pc_and,pc_ior] then begin
   lab1 := GenLabel;
   GenTree(op^.left);
   GenImpliedForFlags(m_tax);
   lab2 := GenLabel;
   if opcode = pc_and then begin
      GenNative(m_bne, relative, lab2, nil, 0);
      GenNative(m_brl, longrelative, lab1, nil, 0);
      end {if}
   else begin
      lab3 := GenLabel;
      GenNative(m_beq, relative, lab2, nil, 0);
      GenNative(m_brl, longrelative, lab3, nil, 0);
      end; {else}
   GenLab(lab2);
   GenTree(op^.right);
   GenImpliedForFlags(m_tax);
   GenNative(m_beq, relative, lab1, nil, 0);
   if opcode = pc_ior then
      GenLab(lab3);
   GenNative(m_lda_imm, immediate, 1, nil, 0);
   GenLab(lab1);
   end {if}
else begin
   if not Complex(op^.left) then
      if Complex(op^.right) then begin
         nd := op^.left;
         op^.left := op^.right;
         op^.right := nd;
         end; {if}
   GenTree(op^.left);
   if Complex(op^.right) then begin
      GenImplied(m_pha);
      GenTree(op^.right);
      case opcode of
         pc_bnd: GenNative(m_and_s, direct, 1, nil, 0);
         pc_bor: GenNative(m_ora_s, direct, 1, nil, 0);
         pc_bxr: GenNative(m_eor_s, direct, 1, nil, 0);
         otherwise:
            Error(cge1);
         end; {case}
      GenImplied(m_plx);
      GenImplied(m_tax);
      end {if}
   else
      case opcode of
         pc_bnd: OperA(m_and_imm, op^.right);
         pc_bor: OperA(m_ora_imm, op^.right);
         pc_bxr: OperA(m_eor_imm, op^.right);
         otherwise:
            Error(cge1);
         end; {case}
   end; {else}
end; {GenLogic}


procedure GenSroCpo (op: icptr);

{ Generate code for a pc_sro or pc_cpo			}

var
   lab: stringPtr;			{op^.lab}
   lab1: integer;			{branch point}
   lval: longint;			{op^.left^.lval}
   opcode: pcodes;			{op^.opcode}
   optype: baseTypeEnum;		{op^.optype}
   q: integer;				{op^.q}

begin {GenSroCpo} 
opcode := op^.opcode;
optype := op^.optype;
q := op^.q;
lab := op^.lab;
case optype of
   cgByte, cgUByte: begin
      if smallMemoryModel and (op^.left^.opcode = pc_ldc)
         and (op^.left^.q = 0) and (opcode = pc_sro) then begin
         GenNative(m_sep, immediate, 32, nil, 0);
         GenNative(m_stz_abs, absolute, q, lab, 0);
         end {if}
      else begin
         if op^.opcode = pc_sro then
            if op^.left^.opcode = pc_cnv then
               if (op^.left^.q >> 4) in [ord(cgWord),ord(cgUWord)] then
        	  op^.left := op^.left^.left;
         if op^.left^.opcode in [pc_ldc,pc_ldc,pc_lod] then begin
            GenNative(m_sep, immediate, 32, nil, 0);
	    GenTree(op^.left);
            end {if}
         else begin
	    GenTree(op^.left);
            GenNative(m_sep, immediate, 32, nil, 0);
            end; {else}
	 if smallMemoryModel then 
            GenNative(m_sta_abs, absolute, q, lab, 0)
	 else
            GenNative(m_sta_long, longabsolute, q, lab, 0);
         end; {else}
      GenNative(m_rep, immediate, 32, nil, 0);
      end;

   cgWord, cgUWord:
      if smallMemoryModel and (op^.left^.opcode = pc_ldc)
         and (op^.left^.q = 0) and (opcode = pc_sro) then
         GenNative(m_stz_abs, absolute, q, lab, 0)
      else begin
	 GenTree(op^.left);
	 if smallMemoryModel then 
            GenNative(m_sta_abs, absolute, q, lab, 0)
	 else
            GenNative(m_sta_long, longabsolute, q, lab, 0);
         end; {else}
      
   cgReal, cgDouble, cgComp, cgExtended: begin
      GenTree(op^.left);
      GenNative(m_pea, immediate, q, lab, shift16);
      GenNative(m_pea, immediate, q, lab, 0);
      if opcode = pc_sro then begin
         if optype = cgReal then
            GenCall(9)
         else if optype = cgDouble then
            GenCall(10)
         else if optype = cgComp then
            GenCall(66)
         else {if optype = cgExtended then}
            GenCall(67);
         end {if}
      else {if opcode = pc_cpo then} begin
         if optype = cgReal then begin
            GenCall(9);            
            GenNative(m_pea, immediate, q, lab, shift16);
            GenNative(m_pea, immediate, q, lab, 0);
            GenCall(21);
            end {if}
         else if optype = cgDouble then begin
            GenCall(10);
            GenNative(m_pea, immediate, q, lab, shift16);
            GenNative(m_pea, immediate, q, lab, 0);
            GenCall(22);
            end {else if}
         else if optype = cgComp then begin
            GenCall(66);
            GenNative(m_pea, immediate, q, lab, shift16);
            GenNative(m_pea, immediate, q, lab, 0);
            GenCall(70);
            end {else if}
         else {if optype = cgExtended then}
            GenCall(69);
         end; {else}
      end;

   cgLong, cgULong: begin
      if (opcode = pc_sro) and (op^.left^.opcode in [pc_adl,pc_sbl]) then
         GenAdlSbl(op^.left, op)
      else if (opcode = pc_sro) and (op^.left^.opcode in [pc_inc,pc_dec]) then
         GenIncDec(op^.left, op)
      else if smallMemoryModel and (op^.left^.opcode = pc_ldc) then begin
         lval := op^.left^.lval;
         if long(lval).lsw = 0 then
            GenNative(m_stz_abs, absolute, q, lab, 0)
         else begin
            GenNative(m_lda_imm, immediate, long(lval).lsw, nil, 0);
            GenNative(m_sta_abs, absolute, q, lab, 0)
            end; {else}
         if long(lval).msw = 0 then
            GenNative(m_stz_abs, absolute, q+2, lab, 0)
         else begin
            GenNative(m_ldx_imm, immediate, long(lval).msw, nil, 0);
            GenNative(m_stx_abs, absolute, q+2, lab, 0)
            end; {else}
         if op^.opcode = pc_cpo then
            GenTree(op^.left);
         end {if}
      else begin
	 if op^.opcode = pc_sro then
	    gLong.preference := A_X | inPointer | localAddress | globalLabel | constant
	 else
	    gLong.preference := gLong.preference &
	       (A_X | inPointer | localAddress | globalLabel | constant);
	 GenTree(op^.left);
	 case gLong.where of

            A_X: begin
               if smallMemoryModel then begin
        	  GenNative(m_stx_abs, absolute, q+2, lab, 0);
        	  GenNative(m_sta_abs, absolute, q, lab, 0);
        	  end {if}
               else begin
        	  GenNative(m_sta_long, longabsolute, q, lab, 0);
        	  if opcode = pc_cpo then
                     GenImplied(m_pha);
        	  GenImplied(m_txa);
        	  GenNative(m_sta_long, longabsolute, q+2, lab, 0);
        	  if opcode = pc_cpo then
                     GenImplied(m_pla);
        	  end; {else}
               end;

            onStack: begin
               if opcode = pc_sro then
        	  GenImplied(m_pla)
               else {if opcode = pc_cpo then}
        	  GenNative(m_lda_s, direct, 1, nil, 0);
               if smallMemoryModel then
        	  GenNative(m_sta_abs, absolute, q, lab, 0)
               else
        	  GenNative(m_sta_long, longabsolute, q, lab, 0);
               if opcode = pc_sro then
        	  GenImplied(m_pla)
               else {if opcode = pc_cpo then}
        	  GenNative(m_lda_s, direct, 3, nil, 0);
               if smallMemoryModel then
        	  GenNative(m_sta_abs, absolute, q+2, lab, 0)
               else
        	  GenNative(m_sta_long, longabsolute, q+2, lab, 0);
               end;

            inPointer: begin
               GenNative(m_ldx_dir, direct, gLong.disp+2, nil, 0);
               if gLong.fixedDisp then
        	  GenNative(m_lda_dir, direct, gLong.disp, nil, 0)
               else begin
        	  GenImplied(m_tya);
        	  GenImplied(m_clc);
        	  GenNative(m_adc_dir, direct, gLong.disp, nil, 0);
        	  if not smallMemoryModel then begin
                     lab1 := GenLabel;
                     GenNative(m_bcc, relative, lab1, nil, 0);
                     GenImplied(m_inx);
                     GenLab(lab1);
                     end; {if}
        	  end; {else}
               if smallMemoryModel then begin
        	  GenNative(m_stx_abs, absolute, q+2, lab, 0);
        	  GenNative(m_sta_abs, absolute, q, lab, 0);
        	  end {if}
               else begin
        	  GenNative(m_sta_long, longabsolute, q, lab, 0);
        	  if opcode = pc_cpo then
                     GenImplied(m_pha);
        	  GenImplied(m_txa);
        	  GenNative(m_sta_long, longabsolute, q+2, lab, 0);
        	  if opcode = pc_cpo then
                     GenImplied(m_pla);
        	  end; {else}
               gLong.where := A_X;
               end;

            localAddress: begin
               if smallMemoryModel then
        	  GenNative(m_stz_abs, absolute, q+2, lab, 0)
               else begin
        	  GenNative(m_lda_imm, immediate, 0, nil, 0);
        	  GenNative(m_sta_long, longabsolute, q+2, lab, 0);
        	  end; {else}
               GenImplied(m_tdc);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               if not gLong.fixedDisp then begin
        	  GenImplied(m_phx);
        	  GenNative(m_adc_s, direct, 1, nil, 0);
        	  GenImplied(m_plx);
        	  end; {if}
               if smallMemoryModel then
        	  GenNative(m_sta_abs, absolute, q, lab, 0)
               else
        	  GenNative(m_sta_long, longabsolute, q, lab, 0);
               end;

            globalLabel:
               if gLong.fixedDisp then begin
        	  if smallMemoryModel then begin
                     GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, 0);
                     GenNative(m_ldx_imm, immediate, gLong.disp, gLong.lab, shift16);
                     GenNative(m_stx_abs, absolute, q+2, lab, 0);
                     GenNative(m_sta_abs, absolute, q, lab, 0);
                     end {if}
        	  else begin
                     GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, shift16);
                     GenNative(m_sta_long, longabsolute, q+2, lab, 0);
                     if opcode = pc_cpo then
                	GenImplied(m_tax);
                     GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, 0);
                     GenNative(m_sta_long, longabsolute, q, lab, 0);
                     end; {else}
        	  gLong.where := A_X;
        	  end {if}
               else begin
        	  GenImplied(m_txa);
        	  GenImplied(m_clc);
        	  GenNative(m_adc_imm, immediate, gLong.disp, gLong.lab, 0);
        	  if smallMemoryModel then
                     GenNative(m_sta_abs, absolute, q, lab, 0)
        	  else
                     GenNative(m_sta_long, longabsolute, q, lab, 0);
        	  GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, shift16);
        	  GenNative(m_adc_imm, immediate, 0, nil, 0);
        	  if smallMemoryModel then
                     GenNative(m_sta_abs, absolute, q+2, lab, 0)
        	  else
                     GenNative(m_sta_long, longabsolute, q+2, lab, 0);
        	  end; {else}

            constant: begin
               if gLong.lval = 0 then begin
        	  if smallMemoryModel then begin
                     GenNative(m_stz_abs, absolute, q+2, lab, 0);
                     GenNative(m_stz_abs, absolute, q, lab, 0);
                     end {if}
        	  else begin
                     GenNative(m_lda_imm, immediate, 0, nil, 0);
                     GenNative(m_sta_long, longabsolute, q+2, lab, 0);
                     GenNative(m_sta_long, longabsolute, q, lab, 0);
                     end; {else}
        	  end {if}
               else if not smallMemoryModel then begin
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).msw, nil, 0);
        	  GenNative(m_sta_long, longabsolute, q+2, lab, 0);
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0);
        	  GenNative(m_sta_long, longabsolute, q, lab, 0);
        	  end {else if}
               else begin
        	  if long(gLong.lval).msw = 0 then
                     GenNative(m_stz_abs, absolute, q+2, lab, 0)
        	  else begin
                     GenNative(m_ldx_imm, immediate, long(gLong.lval).msw, nil, 0);
                     GenNative(m_stx_abs, absolute, q+2, lab, 0);
                     end; {else}
        	  if long(gLong.lval).lsw = 0 then
                     GenNative(m_stz_abs, absolute, q, lab, 0)
        	  else begin
                     GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0);
                     GenNative(m_sta_abs, absolute, q, lab, 0);
                     end; {else}
        	  if (long(gLong.lval).lsw <> 0) and (long(gLong.lval).msw <> 0) then
                     gLong.where := A_X;
        	  end; {else}
               end; {case constant}

            otherwise:
               Error(cge1);
            end; {case}
         end; {else}
      end; {case CGLong, cgULong}

   cgQuad, cgUQuad: begin
      if opcode = pc_sro then begin
         gQuad.preference := globalLabel;
         gQuad.lab := lab;
         gQuad.disp := q;
         end {if}
      else {if opcode = pc_cpo then}
         gQuad.preference := onStack;
      GenTree(op^.left);
      if gQuad.where = onStack then begin
         if opcode = pc_sro then
            GenImplied(m_pla)
         else {if opcode = pc_cpo then}
            GenNative(m_lda_s, direct, 1, nil, 0);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, q, lab, 0)
         else
            GenNative(m_sta_long, longabsolute, q, lab, 0);
         if opcode = pc_sro then
            GenImplied(m_pla)
         else {if opcode = pc_cpo then}
            GenNative(m_lda_s, direct, 3, nil, 0);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, q+2, lab, 0)
         else
            GenNative(m_sta_long, longabsolute, q+2, lab, 0);
         if opcode = pc_sro then
            GenImplied(m_pla)
         else {if opcode = pc_cpo then}
            GenNative(m_lda_s, direct, 5, nil, 0);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, q+4, lab, 0)
         else
            GenNative(m_sta_long, longabsolute, q+4, lab, 0);
         if opcode = pc_sro then
            GenImplied(m_pla)
         else {if opcode = pc_cpo then}
            GenNative(m_lda_s, direct, 7, nil, 0);
         if smallMemoryModel then
            GenNative(m_sta_abs, absolute, q+6, lab, 0)
         else
            GenNative(m_sta_long, longabsolute, q+6, lab, 0);
         end; {if}
      end; {case cgQuad, cgUQuad}
   end; {case}
end; {GenSroCpo}
      

procedure GenStoCpi (op: icptr);

{ Generate code for a pc_sto or pc_cpi			}

var
   disp: integer;			{disp in stack frame}
   opcode: pcodes;			{temp storage for op code}
   optype: baseTypeEnum;		{operand type}
   short: boolean;			{use short registers?}
   simple: boolean;			{is the load a simple load?}
   lLong: longType;			{address record for left node}
   zero: boolean;			{is the operand a constant zero?}
   lab1: integer;			{label}


   procedure LoadLSW;

   { load the least significant word of a four byte value	}

   begin {LoadLSW}
   if lLong.where = onStack then
      if opcode = pc_sto then
         GenImplied(m_pla)
      else
         GenNative(m_lda_s, direct, 1, nil, 0)
   else {if lLong.where = constant then}
      GenNative(m_lda_imm, immediate, long(lLong.lval).lsw, nil, 0);
   end; {LoadLSW}


   procedure LoadMSW;

   { load the most significant word of a four byte value	}
   {								}
   { Note: LoadLSW MUST be called first!			}

   begin {LoadMSW}
   if lLong.where = onStack then
      if opcode = pc_sto then
         GenImplied(m_pla)
      else
         GenNative(m_lda_s, direct, 3, nil, 0)
   else {if lLong.where = constant then}
      GenNative(m_lda_imm, immediate, long(lLong.lval).msw, nil, 0);
   end; {LoadMSW}


   procedure LoadWord;

   { Get the operand for a cgByte, cgUByte, cgWord or cgUWord	}
   { into the accumulator					}

   begin {LoadWord}
   if simple then begin
      with op^.right^ do
         if opcode = pc_ldc then
            GenNative(m_lda_imm, immediate, q, nil, 0)
         else if opcode = pc_lod then
            GenNative(m_lda_dir, direct, LabelToDisp(r) + q, nil, 0)
         else {if opcode = pc_ldo then}
            if smallMemoryModel then
               GenNative(m_lda_abs, absolute, q, lab, 0)
            else
               GenNative(m_lda_long, longabsolute, q, lab, 0);
      if not short then
         if op^.right^.optype in [cgByte,cgUByte] then
            if op^.right^.opcode <> pc_ldc then begin
               GenNative(m_and_imm, immediate, $00FF, nil, 0);
               if optype = cgByte then begin
                  GenNative(m_bit_imm, immediate, $0080, nil, 0);
                  lab1 := GenLabel;
                  GenNative(m_beq, relative, lab1, nil, 0);
                  GenNative(m_ora_imm, immediate, $FF00, nil, 0);
                  GenLab(lab1);
                  end; {if}
               end; {if}
      end {if} 
   else begin
      GenImplied(m_pla);
      if short then
         GenNative(m_sep, immediate, 32, nil, 0);
      end {else}
   end; {LoadWord}


begin {GenStoCpi} 
opcode := op^.opcode;
optype := op^.optype;
case optype of

   cgReal,cgDouble,cgComp,cgExtended: begin
      if opcode = pc_sto then begin
         GenTree(op^.right);
         gLong.preference := onStack;
         GenTree(op^.left);
         if optype = cgReal then
            GenCall(9)
         else if optype = cgDouble then
            GenCall(10)
         else if optype = cgComp then
            GenCall(66)
         else {if optype = cgExtended then}
            GenCall(67);
         end {if}
      else {if opcode = pc_cpi then} begin
         if optype = cgExtended then begin         
            GenTree(op^.right);
            gLong.preference := onStack;
            GenTree(op^.left);
            GenCall(69);
            end {if}
         else begin
            gLong.preference := onStack;
            GenTree(op^.left);
            GenTree(op^.right);
            GenNative(m_lda_s, direct, 13, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_s, direct, 13, nil, 0);
            GenImplied(m_pha);
            if optype = cgReal then begin
               GenCall(9);
               GenCall(21);
               end {if}
            else if optype = cgDouble then begin
               GenCall(10);
               GenCall(22);
               end {else if}
            else {if optype = cgComp then} begin
               GenCall(66);
               GenCall(70);
               end; {else}
            end; {else}
         end; {else}
      end; {case cgReal,cgDouble,cgComp,cgExtended}

   cgQuad,cgUQuad: begin
      gQuad.preference := onStack;
      if opcode = pc_sto then
         if op^.left^.opcode = pc_lod then begin
            disp := LabelToDisp(op^.left^.r) + op^.left^.q;
            if disp <= 255 then begin
               gQuad.preference := inPointer;
               gQuad.disp := disp;
               end; {if}
            end; {if}
      GenTree(op^.right);
      if gQuad.where = onStack then begin
         gLong.preference := A_X;
         GenTree(op^.left);
         if gLong.where = onStack then begin
            GenImplied(m_pla);
            GenImplied(m_plx);
            end; {if}
         GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
         GenNative(m_stx_dir, direct, dworkLoc+2, nil, 0);
         if opcode = pc_sto then
            GenImplied(m_pla)
         else {if op^.opcode = pc_cpi then}
            GenNative(m_lda_s, direct, 1, nil, 0);
         GenNative(m_sta_indl, direct, dworkLoc, nil, 0);
         GenNative(m_ldy_imm, immediate, 2, nil, 0);
         if opcode = pc_sto then
            GenImplied(m_pla)
         else {if op^.opcode = pc_cpi then}
            GenNative(m_lda_s, direct, 3, nil, 0);
         GenNative(m_sta_indly, direct, dworkLoc, nil, 0);
         GenImplied(m_iny);
         GenImplied(m_iny);
         if opcode = pc_sto then
            GenImplied(m_pla)
         else {if op^.opcode = pc_cpi then}
            GenNative(m_lda_s, direct, 5, nil, 0);
         GenNative(m_sta_indly, direct, dworkLoc, nil, 0);
         GenImplied(m_iny);
         GenImplied(m_iny);
         if opcode = pc_sto then
            GenImplied(m_pla)
         else {if op^.opcode = pc_cpi then}
            GenNative(m_lda_s, direct, 7, nil, 0);
         GenNative(m_sta_indly, direct, dworkLoc, nil, 0);
         if op^.opcode = pc_cpi then
            gQuad.where := onStack;
         end; {if}
      end; {case cgQuad,cgUQuad}

   cgLong,cgULong: begin
      if opcode = pc_sto then
         gLong.preference := onStack+constant
      else
         gLong.preference := (onStack+constant) & gLong.preference;
      GenTree(op^.right);
      lLong := gLong;
      gLong.preference := localAddress+inPointer+globalLabel+A_X;
      GenTree(op^.left);
      if gLong.where = onStack then begin
         GenImplied(m_pla);
         GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
         GenImplied(m_pla);
         GenNative(m_sta_dir, direct, dworkLoc+2, nil, 0);
         LoadLSW;
         GenNative(m_sta_indl, direct, dworkLoc, nil, 0);
         GenNative(m_ldy_imm, immediate, 2, nil, 0);
         LoadMSW;
         GenNative(m_sta_indly, direct, dworkLoc, nil, 0);
         end {if}
      else if gLong.where = A_X then begin
         GenNative(m_sta_dir, direct, dworkLoc, nil, 0);
         GenNative(m_stx_dir, direct, dworkLoc+2, nil, 0);
         LoadLSW;
         GenNative(m_sta_indl, direct, dworkLoc, nil, 0);
         GenNative(m_ldy_imm, immediate, 2, nil, 0);
         LoadMSW;
         GenNative(m_sta_indly, direct, dworkLoc, nil, 0);
         end {if}
      else if gLong.where = localAddress then begin
         LoadLSW;
         if gLong.fixedDisp then
            if (gLong.disp & $FF00) = 0 then
               GenNative(m_sta_dir, direct, gLong.disp, nil, 0)
            else begin
               GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
               GenNative(m_sta_dirX, direct, 0, nil, 0);
               end {else}
         else begin
            if (gLong.disp >= 254) or (gLong.disp < 0) then begin
               GenImplied(m_tay);
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               GenImplied(m_tya);
               gLong.disp := 0;
               end; {if}
            GenNative(m_sta_dirX, direct, gLong.disp, nil, 0);
            end; {else}
         LoadMSW;
         if gLong.fixedDisp then
            if ((gLong.disp+2) & $FF00) = 0 then
               GenNative(m_sta_dir, direct, gLong.disp+2, nil, 0)
            else begin
               GenNative(m_ldx_imm, immediate, gLong.disp+2, nil, 0);
               GenNative(m_sta_dirX, direct, 0, nil, 0);
               end {else}
         else begin
            if (gLong.disp >= 254) or (gLong.disp < 0) then begin
               GenImplied(m_tay);
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
               GenImplied(m_tax);
               GenImplied(m_tya);
               gLong.disp := 0;
               end; {if}
            GenNative(m_sta_dirX, direct, gLong.disp+2, nil, 0);
            end; {else}
         end {else if}
      else if gLong.where = globalLabel then begin
         LoadLSW;
         if gLong.fixedDisp then
            if smallMemoryModel then
               GenNative(m_sta_abs, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_sta_long, longAbs, gLong.disp, gLong.lab, 0)
         else
            if smallMemoryModel then
               GenNative(m_sta_absX, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_sta_longX, longAbs, gLong.disp, gLong.lab, 0);
         LoadMSW;
         if gLong.fixedDisp then
            if smallMemoryModel then
               GenNative(m_sta_abs, absolute, gLong.disp+2, gLong.lab, 0)
            else
               GenNative(m_sta_long, longAbs, gLong.disp+2, gLong.lab, 0)
         else
            if smallMemoryModel then
               GenNative(m_sta_absX, absolute, gLong.disp+2, gLong.lab, 0)
            else
               GenNative(m_sta_longX, longAbs, gLong.disp+2, gLong.lab, 0);
         end {else if}
      else begin
         LoadLSW;
         if gLong.fixedDisp = true then begin
            GenNative(m_sta_indl, direct, gLong.disp, nil, 0);
            GenNative(m_ldy_imm, immediate, 2, nil, 0);
            end {if}
         else begin
            GenNative(m_sta_indlY, direct, gLong.disp, nil, 0);
            GenImplied(m_iny);
            GenImplied(m_iny);
            end; {else}
         LoadMSW;
         GenNative(m_sta_indly, direct, gLong.Disp, nil, 0);
         end; {else}
      gLong := lLong;
      end; {case cgLong,cgULong}

   cgByte,cgUByte,cgWord,cgUWord: begin
      short := optype in [cgByte,cgUByte];
      simple := false;
      zero := false;
      if op^.opcode = pc_sto then begin
	 if short then
            if op^.right^.opcode = pc_cnv then
               if (op^.right^.q >> 4) in [ord(cgWord),ord(cgUWord)] then
        	  op^.right := op^.right^.left;
	 with op^.right^ do begin
	    if opcode = pc_ldo then
               simple := true
	    else if opcode = pc_lod then
               simple := LabelToDisp(r) + q < 256
	    else if opcode = pc_ldc then begin
               simple := true;
               zero := q = 0;
               end; {else if}
            end; {with}
         end; {if}
      if not (zero or simple) then begin
         GenTree(op^.right);
         GenImplied(m_pha);
         end; {if}
      GetPointer(op^.left);
      if gLong.where = inPointer then begin
         if short and simple then
            GenNative(m_sep, immediate, 32, nil, 0);
         if zero then
            GenNative(m_lda_imm, immediate, 0, nil, 0)
         else
            LoadWord;
         if gLong.fixedDisp then
            GenNative(m_sta_indl, direct, gLong.disp, nil, 0)
         else
            GenNative(m_sta_indlY, direct, gLong.disp, nil, 0);
         end {if}
      else if gLong.where = localAddress then begin
         if gLong.fixedDisp then begin
            if short and simple then
               GenNative(m_sep, immediate, 32, nil, 0);
            if (gLong.disp & $FF00) = 0 then
               if zero then
                  GenNative(m_stz_dir, direct, gLong.disp, nil, 0)
               else begin
                  LoadWord;
                  GenNative(m_sta_dir, direct, gLong.disp, nil, 0);
                  end {else}
            else begin
               if zero then begin
        	  GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
                  GenNative(m_stz_dirX, direct, 0, nil, 0);
                  end {if}
               else begin
                  LoadWord;
        	  GenNative(m_ldx_imm, immediate, gLong.disp, nil, 0);
                  GenNative(m_sta_dirX, direct, 0, nil, 0);
                  end; {else}
               end {else}
            end {if}
         else begin
            if (gLong.disp & $FF00) <> 0 then begin
               GenImplied(m_txa);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, glong.disp, nil, 0);
               GenImplied(m_tax);
               gLong.disp := 0;
               end; {if}
            if short and simple then
               GenNative(m_sep, immediate, 32, nil, 0);
            if zero then
               GenNative(m_stz_dirX, direct, gLong.disp, nil, 0)
            else begin
               LoadWord;
               GenNative(m_sta_dirX, direct, gLong.disp, nil, 0);
               end; {else}
            end; {else}
         end {else if}
      else {if gLong.where = globalLabel then} begin
         if short and simple then
            GenNative(m_sep, immediate, 32, nil, 0);
         if zero then begin
            if not smallMemoryModel then
               GenNative(m_lda_imm, immediate, 0, nil, 0);
            end {if}
         else
            LoadWord;
         if gLong.fixedDisp then
            if smallMemoryModel then
               if zero then
                  GenNative(m_stz_abs, absolute, gLong.disp, gLong.lab, 0)
               else
                  GenNative(m_sta_abs, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_sta_long, longAbs, gLong.disp, gLong.lab, 0)
         else
            if smallMemoryModel then
               if zero then
                  GenNative(m_stz_absX, absolute, gLong.disp, gLong.lab, 0)
               else
                  GenNative(m_sta_absX, absolute, gLong.disp, gLong.lab, 0)
            else
               GenNative(m_sta_longX, longAbs, gLong.disp, gLong.lab, 0);
         end; {else}
      if short then begin
         GenNative(m_rep, immediate, 32, nil, 0);
         if opcode = pc_cpi then begin
            GenNative(m_and_imm, immediate, $00FF, nil, 0);
            if optype = cgByte then begin
               GenNative(m_bit_imm, immediate, $0080, nil, 0);
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               GenNative(m_ora_imm, immediate, $FF00, nil, 0);
               GenLab(lab1);
               end; {if}
            end; {if}
         end; {if}
      end; {case cgByte,cgUByte,cgWord,cgUWord}

   otherwise:
      Error(cge1);
   end; {case}
end; {GenStoCpi}
      

procedure GenStrCop (op: icptr);

{ Generate code for a pc_str or pc_cop				}

var
   disp: integer;			{store location}
   optype: baseTypeEnum;		{op^.optype}
   zero: boolean;			{is the operand a constant zero?}

begin {GenStrCop}    
disp := LabelToDisp(op^.r) + op^.q;	
optype := op^.optype;
case optype of
   cgByte, cgUByte, cgWord, cgUWord: begin
      zero := false;
      if op^.left^.opcode = pc_ldc then
         if op^.opcode = pc_str then
            if op^.left^.q = 0 then
               zero := true;
      if not zero then begin
	 if optype in [cgByte,cgUByte] then begin
            if op^.opcode = pc_str then
               if op^.left^.opcode = pc_cnv then
        	  if (op^.left^.q >> 4) in [ord(cgWord),ord(cgUWord)] then
        	     op^.left := op^.left^.left;
            if (op^.left^.opcode in [pc_ldc,pc_ldc,pc_lod])
               and (op^.opcode = pc_str) then begin
               GenNative(m_sep, immediate, 32, nil, 0);
	       GenTree(op^.left);
               end {if}
            else begin
	       GenTree(op^.left);
               GenNative(m_sep, immediate, 32, nil, 0);
               end; {else}
            end {if}
         else
            GenTree(op^.left);
         end {if}
      else
         if optype in [cgByte,cgUByte] then
            GenNative(m_sep, immediate, 32, nil, 0);
      if disp > 255 then begin
         GenNative(m_ldx_imm, immediate, disp, nil, 0);
         if zero then
            GenNative(m_stz_dirx, direct, 0, nil, 0)
         else
            GenNative(m_sta_dirx, direct, 0, nil, 0);
         end {if}
      else
         if zero then
            GenNative(m_stz_dir, direct, disp, nil, 0)
         else
            GenNative(m_sta_dir, direct, disp, nil, 0);
      if optype in [cgByte,cgUByte] then
         GenNative(m_rep, immediate, 32, nil, 0);
      end;

   cgReal, cgDouble, cgComp, cgExtended: begin
      GenTree(op^.left);
      GenNative(m_pea, immediate, 0, nil, 0);
      GenImplied(m_tdc);
      GenImplied(m_clc);
      GenNative(m_adc_imm, immediate, disp, nil, 0);
      GenImplied(m_pha);
      if op^.opcode = pc_str then begin
         if optype = cgReal then
            GenCall(9)
         else if optype = cgDouble then
            GenCall(10)
         else if optype = cgComp then
            GenCall(66)
         else {if optype = cgExtended then}
            GenCall(67);
         end {if}
      else begin
         if optype = cgReal then begin
            GenCall(9);
            GenNative(m_pea, immediate, 0, nil, 0);
            GenImplied(m_tdc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, disp, nil, 0);
            GenImplied(m_pha);
            GenCall(21);
            end {if}
         else if optype = cgDouble then begin
            GenCall(10);
            GenNative(m_pea, immediate, 0, nil, 0);
            GenImplied(m_tdc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, disp, nil, 0);
            GenImplied(m_pha);
            GenCall(22);
            end {else if}
         else if optype = cgComp then begin
            GenCall(66);
            GenNative(m_pea, immediate, 0, nil, 0);
            GenImplied(m_tdc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, disp, nil, 0);
            GenImplied(m_pha);
            GenCall(70);
            end {else if}
         else {if optype = cgExtended then}
            GenCall(69);
         end; {else}
      end;

   cgLong, cgULong: begin
      if (op^.opcode = pc_str) and (op^.left^.opcode in [pc_adl,pc_sbl]) then
         GenAdlSbl(op^.left, op)
      else if (op^.opcode = pc_str) and (op^.left^.opcode in [pc_inc,pc_dec]) then
         GenIncDec(op^.left, op)
      else begin
	 if op^.opcode = pc_str then
	    gLong.preference :=
               A_X+onStack+inPointer+localAddress+globalLabel+constant
	 else
	    gLong.preference := onStack;
	 GenTree(op^.left);
	 case gLong.where of

            A_X:
               if disp < 254 then begin
        	  GenNative(m_stx_dir, direct, disp+2, nil, 0);
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  end {else if}
               else begin
        	  GenImplied(m_txy);
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
        	  GenNative(m_sty_dirX, direct, 2, nil, 0);
        	  if op^.opcode = pc_cop then
                     GenImplied(m_tyx);
        	  end; {else}

            onStack:
               if disp < 254 then begin
        	  if op^.opcode = pc_str then
                     GenImplied(m_pla)
        	  else {if op^.opcode = pc_cop then}
                     GenNative(m_lda_s, direct, 1, nil, 0);
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  if op^.opcode = pc_str then
                     GenImplied(m_pla)
        	  else {if op^.opcode = pc_cop then}
                     GenNative(m_lda_s, direct, 3, nil, 0);
        	  GenNative(m_sta_dir, direct, disp+2, nil, 0);
        	  end {else if}
               else begin
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
        	  if op^.opcode = pc_str then
                     GenImplied(m_pla)
        	  else {if op^.opcode = pc_cop then}
                     GenNative(m_lda_s, direct, 1, nil, 0);
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
        	  if op^.opcode = pc_str then
                     GenImplied(m_pla)
        	  else {if op^.opcode = pc_cop then}
                     GenNative(m_lda_s, direct, 3, nil, 0);
        	  GenNative(m_sta_dirX, direct, 2, nil, 0);
        	  end; {else}

            inPointer: begin
               if (disp < 254) and (gLong.disp < 254) and gLong.fixedDisp
        	  and (disp >= 0) and (gLong.disp >= 0) then begin
        	  GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
        	  GenNative(m_ldx_dir, direct, gLong.disp+2, nil, 0);
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  GenNative(m_stx_dir, direct, disp+2, nil, 0);
        	  end {if}
               else if (disp < 254) and (gLong.disp < 254)
        	  and (disp >= 0) and (gLong.disp >= 0)
                  and (op^.opcode = pc_str) then begin
        	  GenImplied(m_tya);
        	  GenImplied(m_clc);
        	  GenNative(m_adc_dir, direct, gLong.disp, nil, 0);
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  GenNative(m_lda_dir, direct, gLong.disp+2, nil, 0);
        	  GenNative(m_adc_imm, immediate, 0, nil, 0);
        	  GenNative(m_sta_dir, direct, disp+2, nil, 0);
        	  end {else if}
               else begin
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
        	  if not gLong.fixedDisp then begin
                     GenImplied(m_tya);
                     GenImplied(m_clc);
                     GenNative(m_adc_dir, direct, gLong.disp, nil, 0);
                     end {if}
        	  else
                     GenNative(m_lda_dir, direct, gLong.disp, nil, 0);
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
        	  GenNative(m_lda_dir, direct, gLong.disp+2, nil, 0);
        	  if not gLong.fixedDisp then
                     GenNative(m_adc_imm, immediate, 0, nil, 0);
        	  GenNative(m_sta_dirX, direct, 2, nil, 0);
        	  end; {else}
               end;

            localAddress:
               if disp < 254 then begin
        	  GenNative(m_stz_dir, direct, disp+2, nil, 0);
        	  GenImplied(m_tdc);
        	  GenImplied(m_clc);
        	  GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
        	  if not gLong.fixedDisp then begin
                     GenImplied(m_phx);
                     GenNative(m_adc_s, direct, 1, nil, 0);
                     GenImplied(m_plx);
                     end; {if}
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  end {else if disp < 254}
               else begin
        	  if not gLong.fixedDisp then
                     GenImplied(m_phx);
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
        	  GenImplied(m_tdc);
        	  GenImplied(m_clc);
        	  GenNative(m_adc_imm, immediate, gLong.disp, nil, 0);
                  if not gLong.fixedDisp then
                     GenNative(m_adc_s, direct, 1, nil, 0);
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
        	  GenNative(m_stz_dirX, direct, 2, nil, 0);
                  if not gLong.fixedDisp then
                     GenImplied(m_plx);
        	  end; {else}

            globalLabel: begin
               if not gLong.fixedDisp then
                  GenImplied(m_txa);
               if disp > 253 then begin
                  if op^.opcode = pc_cop then
                     if not gLong.fixedDisp then
                        GenImplied(m_tay)
                     else
                        GenImplied(m_txy);
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
                  end; {if}
               if gLong.fixedDisp then
        	  GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, 0)
               else begin
        	  GenImplied(m_clc);
        	  GenNative(m_adc_imm, immediate, gLong.disp, gLong.lab, 0);
        	  end; {else}
               if disp < 254 then
        	  GenNative(m_sta_dir, direct, disp, nil, 0)
               else
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
               GenNative(m_lda_imm, immediate, gLong.disp, gLong.lab, shift16);
               if not gLong.fixedDisp then
        	  GenNative(m_adc_imm, immediate, 0, nil, 0);
               if disp < 254 then
        	  GenNative(m_sta_dir, direct, disp+2, nil, 0)
               else begin
        	  GenNative(m_sta_dirX, direct, 2, nil, 0);
                  if op^.opcode = pc_cop then
                     GenImplied(m_tyx);
                  end; {else}
               end;

            constant:
               if disp < 254 then begin
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0);
        	  GenNative(m_sta_dir, direct, disp, nil, 0);
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).msw, nil, 0);
        	  GenNative(m_sta_dir, direct, disp+2, nil, 0);
        	  end {else}
               else begin
        	  GenNative(m_ldx_imm, immediate, disp, nil, 0);
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).lsw, nil, 0);
        	  GenNative(m_sta_dirX, direct, 0, nil, 0);
        	  GenNative(m_lda_imm, immediate, long(gLong.lval).msw, nil, 0);
        	  GenNative(m_sta_dirX, direct, 2, nil, 0);
        	  end; {else}

            otherwise:
               Error(cge1);
            end; {case}
         end; {else}
      end;

   cgQuad, cgUQuad: begin
      if op^.opcode = pc_str then begin
         gQuad.preference := localAddress;
         gQuad.disp := disp;
         end {if}
      else {if op^.opcode = pc_cop then}
         gQuad.preference := onStack;
      GenTree(op^.left);
      if gQuad.where = onStack then begin
         if disp < 250 then begin
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 1, nil, 0);
            GenNative(m_sta_dir, direct, disp, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 3, nil, 0);
            GenNative(m_sta_dir, direct, disp+2, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 5, nil, 0);
            GenNative(m_sta_dir, direct, disp+4, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 7, nil, 0);
            GenNative(m_sta_dir, direct, disp+6, nil, 0);
            end {else if}
         else begin
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 1, nil, 0);
            GenNative(m_sta_dirX, direct, 0, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 3, nil, 0);
            GenNative(m_sta_dirX, direct, 2, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 5, nil, 0);
            GenNative(m_sta_dirX, direct, 4, nil, 0);
            if op^.opcode = pc_str then
               GenImplied(m_pla)
            else {if op^.opcode = pc_cop then}
               GenNative(m_lda_s, direct, 7, nil, 0);
            GenNative(m_sta_dirX, direct, 6, nil, 0);
            end; {else}
         end; {if}
      end;

   otherwise: Error(cge1);

   end; {case}
end; {GenStrCop}


procedure GenSxiZxi (op: icptr);

{ generate a pc_sxi or pc_zxi					}

var
   mask: integer;
   lab1: integer;                       {label number}

begin {GenSxiZxi}
GenTree(op^.left);
mask := (1 << op^.q) - 1;
GenNative(m_and_imm, immediate, mask, nil, 0);
if op^.opcode = pc_sxi then begin
   GenNative(m_bit_imm, immediate, 1 << (op^.q - 1), nil, 0);
   lab1 := GenLabel;
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, ~mask, nil, 0);
   GenLab(lab1);
   end; {if}
end; {GenSxiZxi}


procedure GenSxlZxl (op: icptr);

{ generate a pc_sxl or pc_zxl					}

var
   mask: integer;
   lab1: integer;                       {label number}

begin {GenSxlZxl}
if (gLong.preference & A_X) <> 0 then
   gLong.preference := A_X
else
   gLong.preference := onStack;
GenTree(op^.left);
if gLong.where = A_X then begin
   GenImplied(m_tay);
   GenImplied(m_txa);
   end {if}
else
   GenNative(m_lda_s, direct, 3, nil, 0);

mask := (1 << (op^.q - 16)) - 1;
GenNative(m_and_imm, immediate, mask, nil, 0);
if op^.opcode = pc_sxl then begin
   GenNative(m_bit_imm, immediate, 1 << (op^.q - 16 - 1), nil, 0);
   lab1 := GenLabel;
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_ora_imm, immediate, ~mask, nil, 0);
   GenLab(lab1);
   end; {if}

if gLong.where = A_X then begin
   GenImplied(m_tax);
   GenImplied(m_tya);
   end {if}
else
   GenNative(m_sta_s, direct, 3, nil, 0);
end; {GenSxlZxl}


procedure GenSxqZxq (op: icptr);

{ generate a pc_sxq or pc_zxq					}

var
   mask: integer;
   offset: integer;
   lab1: integer;                       {label number}

begin {GenSxqZxq}
gQuad.preference := onStack;
GenTree(op^.left);

if op^.q <= 48 then begin
   offset := 32;
   GenNative(m_lda_s, direct, 5, nil, 0);
   end {if}
else begin
   offset := 48;
   GenNative(m_lda_s, direct, 7, nil, 0);
   end; {else}

mask := (1 << (op^.q - offset)) - 1;
if mask <> $ffff then
   GenNative(m_and_imm, immediate, mask, nil, 0);
if op^.opcode = pc_sxq then begin
   if offset = 32 then
      GenNative(m_ldx_imm, immediate, 0, nil, 0);
   GenNative(m_bit_imm, immediate, 1 << (op^.q - offset - 1), nil, 0);
   lab1 := GenLabel;
   GenNative(m_beq, relative, lab1, nil, 0);
   if mask <> $ffff then
      GenNative(m_ora_imm, immediate, ~mask, nil, 0);
   if offset = 32 then
      GenImplied(m_dex);
   GenLab(lab1);
   end; {if}

if offset = 32 then begin
   GenNative(m_sta_s, direct, 5, nil, 0);
   if op^.opcode = pc_sxq then
      GenImplied(m_txa)
   else
      GenNative(m_lda_imm, immediate, 0, nil, 0);
   end; {if}
GenNative(m_sta_s, direct, 7, nil, 0);
end; {GenSxqZxq}


procedure GenUnaryLong (op: icptr);

{ generate a pc_bnl or pc_ngl					}

begin {GenUnaryLong}
gLong.preference := onStack;            {get the operand}
GenTree(op^.left);
case op^.opcode of			{do the operation}

   pc_bnl: begin
      GenNative(m_lda_s, direct, 1, nil, 0);
      GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
      GenNative(m_sta_s, direct, 1, nil, 0);
      GenNative(m_lda_s, direct, 3, nil, 0);
      GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
      GenNative(m_sta_s, direct, 3, nil, 0);
      end; {case pc_bnl}

   pc_ngl: begin
      GenImplied(m_sec);
      GenNative(m_lda_imm, immediate, 0, nil, 0);
      GenNative(m_sbc_s, direct, 1, nil, 0);
      GenNative(m_sta_s, direct, 1, nil, 0);
      GenNative(m_lda_imm, immediate, 0, nil, 0);
      GenNative(m_sbc_s, direct, 3, nil, 0);
      GenNative(m_sta_s, direct, 3, nil, 0);
      end; {case pc_ngl}
   end; {case}
gLong.where := onStack;                 {the result is on the stack}
end; {GenUnaryLong}


procedure GenUnaryQuad (op: icptr);

{ generate a pc_bnq or pc_ngq					}

begin {GenUnaryQuad}
case op^.opcode of			{do the operation}

   pc_bnq: begin
      if SimpleQuadLoad(op^.left) then begin
         OpOnWordOfQuad(m_lda_imm, op^.left, 6);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         StoreWordOfQuad(6);
         OpOnWordOfQuad(m_lda_imm, op^.left, 4);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         StoreWordOfQuad(4);
         OpOnWordOfQuad(m_lda_imm, op^.left, 2);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         StoreWordOfQuad(2);
         OpOnWordOfQuad(m_lda_imm, op^.left, 0);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         StoreWordOfQuad(0);
         gQuad.where := gQuad.preference;
         end {if}
      else begin
         gQuad.preference := onStack;
         GenTree(op^.left);
         GenNative(m_lda_s, direct, 1, nil, 0);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         GenNative(m_sta_s, direct, 1, nil, 0);
         GenNative(m_lda_s, direct, 3, nil, 0);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         GenNative(m_sta_s, direct, 3, nil, 0);
         GenNative(m_lda_s, direct, 5, nil, 0);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         GenNative(m_sta_s, direct, 5, nil, 0);
         GenNative(m_lda_s, direct, 7, nil, 0);
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         gQuad.where := onStack;
         end; {else}
      end; {case pc_bnq}

   pc_ngq: begin
      if SimpleQuadLoad(op^.left) then begin
         gQuad.where := gQuad.preference;
         if gQuad.preference = onStack then begin
            GenImplied(m_tsc);
            GenImplied(m_sec);
            GenNative(m_sbc_imm, immediate, 8, nil, 0);
            GenImplied(m_tcs);
            gQuad.preference := inStackLoc;
            gQuad.disp := 1;
            end; {if}
         GenImplied(m_sec);
         GenNative(m_lda_imm, immediate, 0, nil, 0);
         OpOnWordOfQuad(m_sbc_imm, op^.left, 0);
         StoreWordOfQuad(0);
         GenNative(m_lda_imm, immediate, 0, nil, 0);
         OpOnWordOfQuad(m_sbc_imm, op^.left, 2);
         StoreWordOfQuad(2);
         GenNative(m_lda_imm, immediate, 0, nil, 0);
         OpOnWordOfQuad(m_sbc_imm, op^.left, 4);
         StoreWordOfQuad(4);
         GenNative(m_lda_imm, immediate, 0, nil, 0);
         OpOnWordOfQuad(m_sbc_imm, op^.left, 6);
         StoreWordOfQuad(6);
         end {if}
      else begin
         gQuad.preference := onStack;
         GenTree(op^.left);
         GenImplied(m_sec);
         GenNative(m_ldy_imm, immediate, 0, nil, 0);
         GenImplied(m_tya);
         GenNative(m_sbc_s, direct, 1, nil, 0);
         GenNative(m_sta_s, direct, 1, nil, 0);
         GenImplied(m_tya);
         GenNative(m_sbc_s, direct, 3, nil, 0);
         GenNative(m_sta_s, direct, 3, nil, 0);
         GenImplied(m_tya);
         GenNative(m_sbc_s, direct, 5, nil, 0);
         GenNative(m_sta_s, direct, 5, nil, 0);
         GenImplied(m_tya);
         GenNative(m_sbc_s, direct, 7, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         gQuad.where := onStack;
         end; {else}
      end; {case pc_ngq}
   end; {case}
end; {GenUnaryQuad}


{$segment 'gen2'}

procedure GenDebugSourceFile (debugFile: gsosOutStringPtr);

{ generate debug code indicating the specified source file name }

var
   i: integer;                          {loop/index variable}
   len: integer;                        {length of the file name}

begin {GenDebugSourceFile}
GenNative(m_cop, immediate, 6, nil, 0);
GenNative(d_add, genaddress, stringSize, nil, stringReference);
GenNative(d_add, genaddress, stringSize, nil, stringReference+shift16);
len := debugFile^.theString.size;
if len > 255 then
   len := 255;
if maxString-stringSize >= len+1 then begin
   stringSpace^[stringSize+1] := chr(len);
   for i := 1 to len do
      stringSpace^[i+stringSize+1] :=
         debugFile^.theString.theString[i];
   stringSize := stringSize + len + 1;
   end {if}
else
   Error(cge3);
end; {GenDebugSourceFile}


procedure GenTree {op: icptr};

{ generate code for op and its children				}
{								}
{ parameters:							}
{    op - opcode for which to generate code			}


   procedure GenAdi (op: icptr);

   { generate a pc_adi						}

   var
      nd: icptr;

   begin {GenAdi}
   if not Complex(op^.left) then
      if Complex(op^.right) then begin
	 nd := op^.left;
	 op^.left := op^.right;
	 op^.right := nd;
	 end; {if}
   GenTree(op^.left);
   if Complex(op^.right) then begin
      GenImplied(m_pha);
      GenTree(op^.right);
      GenImplied(m_clc);
      GenNative(m_adc_s, direct, 1, nil, 0);
      GenImplied(m_plx);
      end {if}
   else begin
      GenImplied(m_clc);
      OperA(m_adc_imm, op^.right);
      end; {else}
   end; {GenAdi}


   procedure GenBinLong (op: icptr);

   { generate one of: pc_blr, pc_blx, pc_bal, pc_dvl, pc_mdl,	}
   {    pc_mpl, pc_sll, pc_slr, pc_udl, pc_ulm, pc_uml, pc_vsr	}

   var
      nd: icptr;			{for swapping left/right children}
      lab1,lab2: integer;		{label numbers}


      procedure GenOp (ops, opi: integer);

      { generate a binary operation				}
      {								}
      { parameters:						}
      {    ops - stack version of operation			}
      {    opi - immediate version of operation			}

      begin {GenOp}
      if gLong.where = A_X then
         GenImplied(m_phx)
      else
         GenImplied(m_pla);
      if gLong.where = constant then begin
	 GenNative(opi, immediate, long(gLong.lval).lsw, nil, 0);
	 GenImplied(m_pha);
	 GenNative(m_lda_s, direct, 3, nil, 0);
	 GenNative(opi, immediate, long(gLong.lval).msw, nil, 0);
	 GenNative(m_sta_s, direct, 3, nil, 0);
	 end {if}
      else begin
	 GenNative(ops, direct, 3, nil, 0);
	 GenNative(m_sta_s, direct, 3, nil, 0);
	 GenImplied(m_pla);
	 GenNative(ops, direct, 3, nil, 0);
	 GenNative(m_sta_s, direct, 3, nil, 0);
	 end; {else}
      end; {GenOp}


   begin {GenBinLong}
   if (op^.left^.opcode = pc_ldc) and
      (op^.opcode in [pc_blr,pc_blx,pc_bal]) then begin
      nd := op^.left;
      op^.left := op^.right;
      op^.right := nd;
      end; {if}
   if op^.opcode = pc_mdl then
      GenImplied(m_phd);		{reserve stack space}
   gLong.preference := onStack;
   GenTree(op^.left);
   if op^.opcode in [pc_blr,pc_blx,pc_bal] then begin
      gLong.preference := constant;
      GenTree(op^.right);
      end {if}
   else if op^.opcode in [pc_uml,pc_udl,pc_ulm] then begin
      gLong.preference := A_X;
      GenTree(op^.right);
      if gLong.where = onStack then begin
         GenImplied(m_pla);
         GenImplied(m_plx);
         end; {if}
      end {else if}
   else begin
      gLong.preference := onStack;
      GenTree(op^.right);
      end; {else}
   case op^.opcode of

      pc_blr: GenOp(m_ora_s, m_ora_imm);

      pc_blx: GenOp(m_eor_s, m_eor_imm);

      pc_bal: GenOp(m_and_s, m_and_imm);

      pc_dvl: GenCall(43);

      pc_mdl: begin
              lab1 := GenLabel;
              lab2 := GenLabel;
              				{stash high word of dividend (for sign)}
              GenNative(m_lda_s, direct, 7, nil, 0);
              GenNative(m_sta_s, direct, 9, nil, 0);
              GenCall(78);		{call ~DIV4}
              GenImplied(m_ply);	{ignore quotient}
              GenImplied(m_ply);
              GenImplied(m_pla);	{get remainder (always positive or 0)}
              GenImplied(m_plx);
              GenImplied(m_ply);	{if dividend was negative...}
              GenNative(m_bpl, relative, lab1, nil, 0);
              GenImplied(m_clc);	{  negate remainder}
              GenNative(m_eor_imm, immediate, -1, nil, 0);
              GenNative(m_adc_imm, immediate, 1, nil, 0);
              GenImplied(m_tay);
              GenImplied(m_txa);
              GenNative(m_eor_imm, immediate, -1, nil, 0);
              GenNative(m_adc_imm, immediate, 0, nil, 0);
              GenImplied(m_pha);
              GenImplied(m_phy);
              GenNative(m_bra, relative, lab2, nil, 0);
              GenLab(lab1);
              GenImplied(m_phx);
              GenImplied(m_pha);
              GenLab(lab2);
              end;

      pc_mpl: GenCall(42);

      pc_sll: GenCall(45);

      pc_slr: GenCall(47);

      pc_udl: GenCall(49);

      pc_ulm: GenCall(50);

      pc_uml: GenCall(48);

      pc_vsr: GenCall(46);

      otherwise: Error(cge1);
      end; {case}
   gLong.where := onStack;
   end; {GenBinLong}


   procedure GenBinQuad (op: icptr);

   { generate one of: pc_bqr, pc_bqx, pc_baq, pc_mpq, pc_umq,   }
   {    pc_dvq, pc_udq, pc_mdq, pc_uqm                          }

      procedure GenBitwiseOp;

      { generate a 64-bit binary bitwise operation              }
      {                                                         }
      { parameters:                                             }
      {    ops - stack version of operation                     }

      var
         mop: integer;                  {machine opcode}

      begin {GenBitwiseOp}
      if SimpleQuadLoad(op^.left) and SimpleQuadLoad(op^.right) then begin
         case op^.opcode of
            pc_bqr: mop := m_ora_imm;
            pc_bqx: mop := m_eor_imm;
            pc_baq: mop := m_and_imm;
            end; {case}
         OpOnWordOfQuad(m_lda_imm, op^.left, 6);
         OpOnWordOfQuad(mop, op^.right, 6);
         StoreWordOfQuad(6);
         OpOnWordOfQuad(m_lda_imm, op^.left, 4);
         OpOnWordOfQuad(mop, op^.right, 4);
         StoreWordOfQuad(4);
         OpOnWordOfQuad(m_lda_imm, op^.left, 2);
         OpOnWordOfQuad(mop, op^.right, 2);
         StoreWordOfQuad(2);
         OpOnWordOfQuad(m_lda_imm, op^.left, 0);
         OpOnWordOfQuad(mop, op^.right, 0);
         StoreWordOfQuad(0);
         gQuad.where := gQuad.preference;
         end {if}
      else begin
         case op^.opcode of
            pc_bqr: mop := m_ora_s;
            pc_bqx: mop := m_eor_s;
            pc_baq: mop := m_and_s;
            end; {case}
         gQuad.preference := onStack;
         GenTree(op^.left);
         gQuad.preference := onStack;
         GenTree(op^.right);
         GenImplied(m_pla);
         GenNative(mop, direct, 7, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         GenImplied(m_pla);
         GenNative(mop, direct, 7, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         GenImplied(m_pla);
         GenNative(mop, direct, 7, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         GenImplied(m_pla);
         GenNative(mop, direct, 7, nil, 0);
         GenNative(m_sta_s, direct, 7, nil, 0);
         gQuad.where := onStack;
         end; {else}
      end; {GenBitwiseOp}

   begin {GenBinQuad}
   if op^.opcode in [pc_bqr,pc_bqx,pc_baq] then
      GenBitwiseOp
   else begin
      gQuad.preference := onStack;
      GenTree(op^.left);
      gQuad.preference := onStack;
      GenTree(op^.right);
      case op^.opcode of
         pc_mpq: GenCall(79);
      
         pc_umq: GenCall(80);
      
         pc_dvq: begin
                 GenCall(81);           {do division}
                 GenImplied(m_pla);     {get quotient, discarding remainder}
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 end;
      
         pc_udq: begin
                 GenCall(82);           {do division}
                 GenImplied(m_pla);     {get quotient, discarding remainder}
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 GenImplied(m_pla);
                 GenNative(m_sta_s, direct, 7, nil, 0);
                 end;

         pc_mdq: begin
                 GenCall(81);           {do division}          
                 GenImplied(m_tsc);     {discard quotient, leaving remainder}
                 GenImplied(m_clc);
                 GenNative(m_adc_imm, immediate, 8, nil, 0);
                 GenImplied(m_tcs);
                 end;

         pc_uqm: begin
                 GenCall(82);           {do division}          
                 GenImplied(m_tsc);     {discard quotient, leaving remainder}
                 GenImplied(m_clc);
                 GenNative(m_adc_imm, immediate, 8, nil, 0);
                 GenImplied(m_tcs);
                 end;

         pc_slq: GenCall(85);
      
         pc_sqr: GenCall(86);
      
         pc_wsr: GenCall(87);

         otherwise: Error(cge1);
         end; {case}
      gQuad.where := onStack;
      end; {else}
   end; {GenBinQuad}


   procedure GenBno (op: icptr);

   { Generate code for a pc_bno					}

   var
      lLong: longType;			{requested address type}
      lQuad: quadType;

   begin {GenBno}
   lLong := gLong;
   lQuad := gQuad;
   GenTree(op^.left);
   gLong := lLong;
   gQuad := lQuad;
   GenTree(op^.right);
   end; {GenBno}


   procedure GenBntNgiNot (op: icptr);

   { Generate code for a pc_bnt, pc_ngi or pc_not		}

   var
      lab1: integer;
      operandIsBoolean: boolean;

   begin {GenBntNgiNot}
   if op^.opcode = pc_not then
      operandIsBoolean := op^.left^.opcode in 
         [pc_and,pc_ior,pc_lnd,pc_lor,pc_not,pc_neq,pc_equ,pc_geq,pc_leq,
          pc_les,pc_grt];
   GenTree(op^.left);
   case op^.opcode of
      pc_bnt:
	 GenNative(m_eor_imm, immediate, -1, nil, 0);

      pc_ngi: begin
	 GenNative(m_eor_imm, immediate, -1, nil, 0);
	 GenImplied(m_ina);
	 end; {case pc_ngi}

      pc_not:
         if not operandIsBoolean then begin
            lab1 := GenLabel;
            GenImpliedForFlags(m_tax);
            GenNative(m_beq, relative, lab1, nil, 0);
            GenNative(m_lda_imm, immediate, $ffff, nil, 0);
            GenLab(lab1);
            GenImplied(m_ina);
            end {if}
         else
            GenNative(m_eor_imm, immediate, 1, nil, 0);
      end; {case}
   end; {GenBntNgiNot}


   procedure GenCui (op: icptr);

   { Generate code for a pc_cui					}

   var
      lab1: integer;			{return point}
      lLong: longType;			{used to reserve gLong}
      lQuad: quadType;			{saved copy of gQuad}
      lArgsSize: integer;		{saved copy of argsSize}
      extraStackSize: integer;		{size of extra stuff pushed on stack}

   begin {GenCui}
   lArgsSize := argsSize;
   argsSize := 0;
   extraStackSize := 0;
   
   {For functions returning cg(U)Quad, make space for result}
   if op^.optype in [cgQuad,cgUQuad] then
      if gQuad.preference <> localAddress then begin
         GenImplied(m_tsc);
         GenImplied(m_sec);
         GenNative(m_sbc_imm, immediate, 8, nil, 0);
         GenImplied(m_tcs);
         end; {if}

   {save the stack register}
   if ((saveStack or checkStack) and (op^.q >= 0)) or (op^.q > 0) then begin
      if stackSaveDepth <> 0 then begin
         GenNative(m_pei_dir, direct, stackLoc, nil, 0);
         extraStackSize := 2;
         end; {if}
      GenImplied(m_tsx);
      GenNative(m_stx_dir, direct, stackLoc, nil, 0);
      stackSaveDepth := stackSaveDepth + 1;
      end; {if}

   {generate parameters}
   {place the operands on the stack}
   lQuad := gQuad;
   lLong := gLong;
   GenTree(op^.left);

   {get the address to call}
   gLong.preference := A_X;
   GenTree(op^.right);

   {create a return label}
   lab1 := GenLabel;

   {place the call/return addrs on stack}
   if gLong.where = A_X then begin
      GenImplied(m_tay);
      GenImplied(m_txa);
      end {if}
   else {if gLong.where = onStack then} begin
      GenImplied(m_ply);
      GenImplied(m_pla);
      end; {else}
   GenNative(m_and_imm, immediate, $00ff, nil, 0);
   GenNative(m_ora_imm, genAddress, lab1, nil, subtract1+shiftLeft8);
   GenNative(m_pea, genAddress, lab1, nil, subtract1+shift8);
   GenImplied(m_pha);
   GenImplied(m_dey);
   GenImplied(m_phy);

   {For functions returning cg(U)Quad, x = address to store result in}
   if op^.optype in [cgQuad,cgUQuad] then 
      if lQuad.preference = localAddress then begin
         GenImplied(m_tdc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, lQuad.disp, nil, 0);
         GenImplied(m_tax);
         end {if}
      else begin
         GenImplied(m_tsc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, argsSize+extraStackSize+6+1, nil, 0);
         GenImplied(m_tax);
         end; {else}

   {indirect call}
   GenImplied(m_rtl);
   GenLab(lab1);

   if checkStack and (op^.q >= 0) then begin
      {check the stack for errors}
      stackSaveDepth := stackSaveDepth - 1;
      GenNative(m_ldy_dir, direct, stackLoc, nil, 0);
      GenCall(76);
      if stackSaveDepth <> 0 then begin
         GenImplied(m_ply);
         GenNative(m_sty_dir, direct, stackLoc, nil, 0);
         end; {if}
      end {if}
   else if (saveStack and (op^.q >= 0)) or (op^.q > 0) then begin
      stackSaveDepth := stackSaveDepth - 1;
      if not (op^.optype in [cgVoid,cgByte,cgUByte,cgWord,cgUWord,cgQuad,cgUQuad])
         then
         GenImplied(m_txy);
      GenNative(m_ldx_dir, direct, stackLoc, nil, 0);
      GenImplied(m_txs);
      if not (op^.optype in [cgVoid,cgByte,cgUByte,cgWord,cgUWord,cgQuad,cgUQuad])
         then
         GenImplied(m_tyx);
      if stackSaveDepth <> 0 then begin
         GenImplied(m_ply);
         GenNative(m_sty_dir, direct, stackLoc, nil, 0);
         end; {if}
      end; {else}

   {save the returned value}
   gLong := lLong;
   gQuad := lQuad;
   gLong.where := A_X;
   if gQuad.preference = localAddress then
      gQuad.where := localAddress
   else
      gQuad.where := onStack;
   SaveRetValue(op^.optype);
   argsSize := lArgsSize;
   end; {GenCui}


   procedure GenCup (op: icptr);

   { Generate code for a pc_cup					}

   var
      lLong: longType;                  {used to reserve gLong}
      lQuad: quadType;                  {saved copy of gQuad}
      lArgsSize: integer;               {saved copy of argsSize}
      extraStackSize: integer;          {size of extra stuff pushed on stack}

   begin {GenCup}
   lArgsSize := argsSize;
   argsSize := 0;
   extraStackSize := 0;
   
   {For functions returning cg(U)Quad, make space for result}
   if op^.optype in [cgQuad,cgUQuad] then
      if gQuad.preference <> localAddress then begin
         GenImplied(m_tsc);
         GenImplied(m_sec);
         GenNative(m_sbc_imm, immediate, 8, nil, 0);
         GenImplied(m_tcs);
         end; {if}

   {save the stack register}
   if ((saveStack or checkStack) and (op^.q >= 0)) or (op^.q > 0) then begin
      if stackSaveDepth <> 0 then begin
         GenNative(m_pei_dir, direct, stackLoc, nil, 0);
         extraStackSize := 2;
         end; {if}
      GenImplied(m_tsx);
      GenNative(m_stx_dir, direct, stackLoc, nil, 0);
      stackSaveDepth := stackSaveDepth + 1;
      end; {if}

   {generate parameters}
   lQuad := gQuad;
   lLong := gLong;
   GenTree(op^.left);
   gLong := lLong;
   gQuad := lQuad;

   {For functions returning cg(U)Quad, x = address to store result in}
   if op^.optype in [cgQuad,cgUQuad] then
      if gQuad.preference = localAddress then begin
         GenImplied(m_tdc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, gQuad.disp, nil, 0);
         GenImplied(m_tax);
         end {if}
      else if argsSize + extraStackSize in [0,1,2] then begin
         GenImplied(m_tsx);
         GenImplied(m_inx);
         if argsSize + extraStackSize in [1,2] then begin
            GenImplied(m_inx);
            if argsSize + extraStackSize = 2 then
               GenImplied(m_inx);
            end; {if}
         end {if}
      else begin
         GenImplied(m_tsc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, argsSize+extraStackSize+1, nil, 0);
         GenImplied(m_tax);
         end; {else}

   {generate the jsl}
   GenNative(m_jsl, longAbs, 0, op^.lab, 0);

   {check the stack for errors}
   if checkStack and (op^.q >= 0) then begin
      stackSaveDepth := stackSaveDepth - 1;
      GenNative(m_ldy_dir, direct, stackLoc, nil, 0);
      GenCall(76);
      if stackSaveDepth <> 0 then begin
         GenImplied(m_ply);
         GenNative(m_sty_dir, direct, stackLoc, nil, 0);
         end; {if}
      end {if}
   else if (saveStack and (op^.q >= 0)) or (op^.q > 0) then begin
      stackSaveDepth := stackSaveDepth - 1;
      if not (op^.optype in [cgVoid,cgByte,cgUByte,cgWord,cgUWord,cgQuad,cgUQuad])
         then
         GenImplied(m_txy);
      GenNative(m_ldx_dir, direct, stackLoc, nil, 0);
      GenImplied(m_txs);
      if not (op^.optype in [cgVoid,cgByte,cgUByte,cgWord,cgUWord,cgQuad,cgUQuad])
         then
         GenImplied(m_tyx);
      if stackSaveDepth <> 0 then begin
         GenImplied(m_ply);
         GenNative(m_sty_dir, direct, stackLoc, nil, 0);
         end; {if}
      end; {else}

   {save the returned value}
   gLong.where := A_X;
   if gQuad.preference = localAddress then
      gQuad.where := localAddress
   else
      gQuad.where := onStack;
   SaveRetValue(op^.optype);
   argsSize := lArgsSize;
   end; {GenCup}


   procedure GenDviMod (op: icptr);
   
   { Generate code for a pc_dvi, pc_mod, pc_udi or pc_uim	}

   var
      opcode: pcodes;			{temp storage}
      lab1,lab2,lab3: integer;		{label numbers}
      val: integer;
      power: integer;

   begin {GenDviMod}
   opcode := op^.opcode;
   if (op^.right^.opcode = pc_ldc) and not rangeCheck then begin
      val := op^.right^.q;
      if opcode = pc_udi then begin
         case val of
            1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384: begin
               GenTree(op^.left);
               if val >= 256 then begin
                  GenNative(m_and_imm, immediate, $FF00, nil, 0);
                  GenImplied(m_xba);
                  val := val >> 8;
                  end; {if}
               while not odd(val) do begin
                  GenImplied(m_lsr_a);
                  val := val >> 1;
                  end; {while}
               opcode := pc_nop;
               end;

            otherwise:
               if (val >= 1000) or (val < 0) then begin {1000..65535}
                  GenTree(op^.left);
                  lab1 := GenLabel;
                  GenNative(m_ldy_imm, immediate, -1, nil, 0);
                  GenImplied(m_sec);
                  GenLab(lab1);
                  GenImplied(m_iny);
                  GenNative(m_sbc_imm, immediate, val, nil, 0);
                  GenNative(m_bcs, relative, lab1, nil, 0);
                  GenImplied(m_tya);
                  opcode := pc_nop;
                  end; {if}
            end; {case}
         end {if}
      else if opcode = pc_uim then begin
         case val of
            1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384: begin
               GenTree(op^.left);
               GenNative(m_and_imm, immediate, val-1, nil, 0);
               opcode := pc_nop;
               end;

            otherwise:
               if (val >= 750) or (val < 0) then begin  {750..65535}
                  GenTree(op^.left);
                  lab1 := GenLabel;
                  GenImplied(m_sec);
                  GenLab(lab1);
                  GenNative(m_sbc_imm, immediate, val, nil, 0);
                  GenNative(m_bcs, relative, lab1, nil, 0);
                  GenNative(m_adc_imm, immediate, val, nil, 0);
                  opcode := pc_nop;
                  end; {if}
            end; {case}
         end {else if}
      else if opcode = pc_dvi then begin
         case val of
            -1: begin
               GenTree(op^.left);
               GenNative(m_eor_imm, immediate, -1, nil, 0);
               GenImplied(m_ina);
               opcode := pc_nop;
               end;

            1: begin
               GenTree(op^.left);
               opcode := pc_nop;
               end;

            2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384: begin
               GenTree(op^.left);
               power := 0;
               while not odd(val) do begin
                  power := power + 1;
                  val := val >> 1;
                  end; {while}
               if power <> 1 then begin
                  GenNative(m_ldy_imm, immediate, power, nil, 0);
                  lab1 := GenLabel;
                  GenLab(lab1);
                  end; {if}
               lab2 := GenLabel;
               lab3 := GenLabel;
               GenImpliedForFlags(m_tax);
               GenImplied(m_clc);
               GenNative(m_bpl, relative, lab2, nil, 0);
               GenImplied(m_ina);
               GenNative(m_beq, relative, lab3, nil, 0);
               GenImplied(m_sec);
               GenLab(lab2);
               GenImplied(m_ror_a);
               if power <> 1 then begin
                  GenImplied(m_dey);
                  GenNative(m_bne, relative, lab1, nil, 0);
                  end; {if}
               GenLab(lab3);
               opcode := pc_nop;
               end;

            otherwise: ;
            end; {case}
         end {else if}
      else {if opcode = pc_mod then} begin
         case val of
            -1,1: begin
               GenTree(op^.left);
               GenNative(m_lda_imm, immediate, 0, nil, 0);
               opcode := pc_nop;
               end;

            2: begin
               GenTree(op^.left);
               lab1 := GenLabel;
               lab2 := GenLabel;
               GenImplied(m_asl_a);
               GenNative(m_and_imm, immediate, 2, nil, 0);
               GenNative(m_beq, relative, lab2, nil, 0);
               GenNative(m_bcc, relative, lab1, nil, 0);
               GenImplied(m_dea);
               GenImplied(m_dea);
               GenLab(lab1);
               GenImplied(m_dea);
               GenLab(lab2);
               opcode := pc_nop;
               end;

            otherwise: ;
            end; {case}
         end; {else}
      end; {if}
   if opcode = pc_nop then
      {nothing to do - optimized above}
   else if Complex(op^.right) then begin
      GenTree(op^.right);
      if Complex(op^.left) then begin
	 GenImplied(m_pha);
	 GenTree(op^.left);
	 GenImplied(m_plx);
	 end {if}
      else begin
	 GenImplied(m_tax);
	 GenTree(op^.left);
	 end; {else}
      end {else if}
   else begin
      GenTree(op^.left);
      LoadX(op^.right);
      end; {else}
   if opcode = pc_mod then begin
      lab1 := GenLabel;
      GenImplied(m_pha);		{stash away dividend (for sign)}
      GenCall(26);			{call ~DIV2}
      GenImplied(m_txa);		{get remainder (always positive or 0)}
      GenImplied(m_ply);		{if dividend was negative...}
      GenNative(m_bpl, relative, lab1, nil, 0);
      GenNative(m_eor_imm, immediate, -1, nil, 0);  {...negate remainder}
      GenImplied(m_ina);
      GenLab(lab1);
      end {if}
   else if opcode = pc_dvi then
      GenCall(26)
   else if opcode in [pc_udi,pc_uim] then begin
      GenCall(40);
      if opcode = pc_uim then
	 GenImplied(m_txa);
      end; {else}
   if rangeCheck then
      GenCall(25);
   end; {GenDviMod}


   procedure GenEnt(op: icptr);

   { Generate code for a pc_ent					}
   
   var
      i: integer;
      len: integer;

   begin {GenEnt}
   
   if debugStrFlag then begin		{gsbug/niftylist debug string}
      len := length(op^.lab^);
      CnOut(m_brl);
      CnOut2(len + 3);
      CnOut2($7771);
      CnOut(len);
      for i := 1 to len do
         CnOut(ord(op^.lab^[i]));
   end;
   
   if rangeCheck then begin		{if range checking is on, check for a stack overflow}
      GenNative(m_pea, immediate, localSize - returnSize - 1, nil, 0);
      GenCall(1);
      end; {if}

   if localSize = 0 then begin		{create the stack frame}
      if parameterSize <> 0 then begin
	 GenImplied(m_tsc);
	 GenImplied(m_phd);
	 GenImplied(m_tcd);
         end; {if}
      end {if}          
   else if localSize = 2 then begin
      GenImplied(m_pha);
      GenImplied(m_tsc);
      GenImplied(m_phd);
      GenImplied(m_tcd);
      end {else if}
   else begin
      GenImplied(m_tsc);
      GenImplied(m_sec);
      GenNative(m_sbc_imm, immediate, localSize, nil, 0);
      GenImplied(m_tcs);
      GenImplied(m_phd);
      GenImplied(m_tcd);
      end; {if}

   if isQuadFunction then begin		{save return location for cg(U)Quad}
      GenNative(m_stx_dir, direct, funloc, nil, 0);
      GenNative(m_stz_dir, direct, funloc+2, nil, 0);
      end; {if}

   if dataBank then begin		{preserve and set data bank}
      GenImplied(m_phb);
      GenImplied(m_phb);
      GenImplied(m_pla);
      GenNative(m_sta_dir, direct, bankLoc, nil, 0);
      GenNative(m_pea, immediate, 0, @'~GLOBALS', shift8);
      GenImplied(m_plb);
      GenImplied(m_plb);
      end; {if}

   {no pc_nam (yet)}
   namePushed := false;
   end; {GenEnt}


   procedure GenFix (op: icptr);

   { Generate code for a pc_fix					}

   begin {GenFix}
   GenNative(m_pea, immediate, localLabel[op^.q], nil, 0);
   if op^.optype = cgReal then
      GenCall(95)
   else if op^.optype = cgDouble then
      GenCall(96)
   else if op^.optype = cgComp then
      GenCall(97);
   end; {GenFix}


   procedure GenFjpTjp (op: icptr);

   { Generate code for a pc_fjp or pc_tjp			}

   var
      lab1: integer;			{branch point}
      opcode: pcodes;			{op^.left^.opcode}

   begin {GenFjpTjp}
   if op^.left^.opcode in [pc_equ,pc_geq,pc_grt,pc_les,pc_leq,pc_neq] then
      if op^.left^.opcode in [pc_equ,pc_neq] then
         GenEquNeq(op^.left, op^.opcode, op^.q)
      else
         GenCmp(op^.left, op^.opcode, op^.q)
   else begin
      lab1 := GenLabel;
      GenTree(op^.left);
      opcode := op^.left^.opcode;
      if NeedsCondition(opcode) then
         GenImpliedForFlags(m_tax)
      else if opcode = pc_ind then
         if op^.left^.optype in [cgByte,cgUByte] then
            GenImpliedForFlags(m_tax);
      if op^.opcode = pc_fjp then
         GenNative(m_bne, relative, lab1, nil, 0)
      else {if op^.opcode = pc_tjp then}
         GenNative(m_beq, relative, lab1, nil, 0);
      GenNative(m_brl, longrelative, op^.q, nil, 0);
      GenLab(lab1);
      end; {else}
   end; {GenFjpTjp}


   procedure GenLaoLad (op: icptr);

   { Generate code for a pc_lao, pc_lad				}

   var
      q: integer;			{displacement}

   begin {GenLaoLad}
   if op^.opcode = pc_lad then
      q := 0
   else
      q := op^.q;
   if (globalLabel & gLong.preference) <> 0 then begin
      gLong.fixedDisp := true;
      gLong.where := globalLabel;
      gLong.disp := q;
      gLong.lab := op^.lab;
      end {if}
   else if (A_X & gLong.preference) <> 0 then begin
      gLong.where := A_X;
      GenNative(m_ldx_imm, immediate, q, op^.lab, shift16);
      GenNative(m_lda_imm, immediate, q, op^.lab, 0);
      end {else if}
   else begin
      gLong.where := onStack;
      GenNative(m_pea, immediate, q, op^.lab, shift16);
      GenNative(m_pea, immediate, q, op^.lab, 0);
      end; {else}
   end; {GenLaoLad}


   procedure GenLbfLbu (op: icptr);

   { Generate code for a pc_lbf or pc_lbu			}

   var
      lLong: longType;			{requested address type}

   begin {GenLbfLbu}
   lLong := gLong;
   gLong.preference := onStack;
   GenTree(op^.left);
   GenNative(m_pea, immediate, op^.r, nil, 0);
   GenNative(m_pea, immediate, op^.q, nil, 0);
   if op^.opcode = pc_lbf then
      GenCall(73)
   else
      GenCall(72);
   if op^.optype in [cgLong,cgULong] then begin
      if (A_X & lLong.preference) <> 0 then
         gLong.where := A_X
      else begin
         gLong.where := onStack;
         GenImplied(m_phx);
         GenImplied(m_pha);
         end; {else}
      end; {if}
   end; {GenLbfLbu}


   procedure GenLca (op: icptr);

   { Generate code for a pc_lca					}

   var
      i: integer;			{loop/index variable}

   begin {GenLca}
   gLong.where := onStack;
   GenNative(m_pea, immediate, stringSize, nil, stringReference+shift16);
   GenNative(m_pea, immediate, stringSize, nil, stringReference);
   if maxString-stringSize >= op^.q then begin
      for i := 1 to op^.q do
         stringSpace^[i+stringSize] := op^.str^.str[i];
      stringSize := stringSize+op^.q;
      end
   else
      Error(cge3);
   op^.optype := cgULong;
   end; {GenLca}


   procedure GenLda (op: icptr);

   { Generate code for a pc_lda					}

   begin {GenLda}
   if (localAddress & gLong.preference) <> 0 then begin
      gLong.fixedDisp := true;
      gLong.where := localAddress;
      gLong.disp := LabelToDisp(op^.r) + op^.q;
      end {if}
   else if (A_X & gLong.preference) <> 0 then begin
      gLong.where := A_X;
      GenImplied(m_tdc);
      GenImplied(m_clc);
      GenNative(m_adc_imm, immediate, LabelToDisp(op^.r) + op^.q, nil, 0);
      GenNative(m_ldx_imm, immediate, 0, nil, 0);
      end {else if}
   else begin
      gLong.where := onStack;
      GenNative(m_pea, immediate, 0, nil, 0);
      GenImplied(m_tdc);
      GenImplied(m_clc);
      GenNative(m_adc_imm, immediate, LabelToDisp(op^.r) + op^.q, nil, 0);
      GenImplied(m_pha);
      end; {else}
   end; {GenLda}


   procedure GenLdc (op: icptr);

   { Generate code for a pc_ldc					}

   type
      kind = (vreal, vlonglong, vwords); {kinds of equivalenced data}
      switchRec = packed record
	 case kind of
	    vreal: (theReal: extended);
	    vlonglong: (theLonglong: longlong);
	    vwords: (words: packed array[1..5] of integer);
	 end;

   var
      switch: switchRec;                {used for type conversion}


      procedure PushWords (switch: switchRec; count: integer);
   
      { Generate code to push words from the switch record      }
      {                                                         }
      { parameters                                              }
      {     switch - the switch record                          }
      {     count - number of words to push                     }
   
      var
         val: integer;                     {word value to push}

      begin {PushWords}
      repeat
         val := switch.words[count];
         if (count >= 3)
            and (switch.words[count-1] = val)
            and (switch.words[count-2] = val)
            then begin
            GenNative(m_lda_imm, immediate, val, nil, 0);
            repeat
               GenImplied(m_pha);
               count := count - 1;
            until (count = 0) or (switch.words[count] <> val);
            end {if}
         else begin
            GenNative(m_pea, immediate, val, nil, 0);
            count := count - 1;
            end; {else}
      until count = 0;
      end; {PushWords}


   begin {GenLdc}
   case op^.optype of
      cgByte: begin
         if op^.q > 127 then
            op^.q := op^.q | $FF00;
         GenNative(m_lda_imm, immediate, op^.q, nil, 0);
         end;

      cgUByte, cgWord, cgUWord:
         GenNative(m_lda_imm, immediate, op^.q, nil, 0);

      cgReal, cgDouble, cgComp, cgExtended: begin
         switch.theReal := op^.rval;
         PushWords(switch, 5);
         end;

      cgLong, cgULong:
         if (constant & gLong.preference) <> 0 then begin
            gLong.where := constant;
            gLong.lval := op^.lval;
            end
         else if (A_X & gLong.preference) <> 0 then begin
            gLong.where := A_X;
            GenNative(m_lda_imm, immediate, long(op^.lval).lsw, nil, 0);
            GenNative(m_ldx_imm, immediate, long(op^.lval).msw, nil, 0);
            end
         else begin
            gLong.where := onStack;
            GenNative(m_pea, immediate, long(op^.lval).msw, nil, 0);
            GenNative(m_pea, immediate, long(op^.lval).lsw, nil, 0);
            end;

      cgQuad,cgUQuad: begin
         if gQuad.preference = onStack then begin
            switch.theLonglong := op^.qval;
            PushWords(switch, 4);
            end {if}
         else begin
            GenNative(m_lda_imm, immediate, long(op^.qval.hi).msw, nil, 0);
            StoreWordOfQuad(6);
            GenNative(m_lda_imm, immediate, long(op^.qval.hi).lsw, nil, 0);
            StoreWordOfQuad(4);
            GenNative(m_lda_imm, immediate, long(op^.qval.lo).msw, nil, 0);
            StoreWordOfQuad(2);
            GenNative(m_lda_imm, immediate, long(op^.qval.lo).lsw, nil, 0);
            StoreWordOfQuad(0);
            end; {else}
         gQuad.where := gQuad.preference;
         end;

      otherwise:
         Error(cge1);
      end; {case}
   end; {GenLdc}


   procedure GenLdo (op: icptr);

   { Generate code for a pc_ldo					}

   var
      lab1: integer;			{branch point}

   begin {GenLdo}
   case op^.optype of
      cgWord, cgUWord:
         if smallMemoryModel then
            GenNative(m_lda_abs, absolute, op^.q, op^.lab, 0)
         else
            GenNative(m_lda_long, longAbs, op^.q, op^.lab, 0);

      cgByte, cgUByte: begin
         if smallMemoryModel then
            GenNative(m_lda_abs, absolute, op^.q, op^.lab, 0)
         else
            GenNative(m_lda_long, longAbs, op^.q, op^.lab, 0);
         GenNative(m_and_imm, immediate, 255, nil, 0);
         if op^.optype = cgByte then begin
            GenNative(m_bit_imm, immediate, $0080, nil, 0);
            lab1 := GenLabel;
            GenNative(m_beq, relative, lab1, nil, 0);
            GenNative(m_ora_imm, immediate, $FF00, nil, 0);
            GenLab(lab1);
            GenNative(m_cmp_imm, immediate, $0000, nil, 0);
            end; {if}
         end;

      cgReal, cgDouble, cgComp, cgExtended: begin
         GenNative(m_pea, immediate, op^.q, op^.lab, shift16);
         GenNative(m_pea, immediate, op^.q, op^.lab, 0);
         if op^.optype = cgReal then
            GenCall(21)
         else if op^.optype = cgDouble then
            GenCall(22)
         else if op^.optype = cgComp then
            GenCall(70)
         else {if op^.optype = cgExtended then}
            GenCall(71);
         end;

      cgLong, cgULong: begin
         if (A_X & gLong.preference) <> 0 then
            gLong.where := A_X
         else
            gLong.where := onStack;
         if smallMemoryModel then begin
            GenNative(m_ldx_abs, absolute, op^.q+2, op^.lab, 0);
            GenNative(m_lda_abs, absolute, op^.q, op^.lab, 0);
            if gLong.where = onStack then begin
               GenImplied(m_phx);
               GenImplied(m_pha);
               end; {if}
            end {if}
         else begin
            GenNative(m_lda_long, longabsolute, op^.q+2, op^.lab, 0);
            if gLong.where = onStack then
               GenImplied(m_pha)
            else
               GenImplied(m_tax);
            GenNative(m_lda_long, longabsolute, op^.q, op^.lab, 0);
            if gLong.where = onStack then
               GenImplied(m_pha);
            end; {else}
         end; {case cgLong,cgULong}

      cgQuad, cgUQuad: begin
         if smallMemoryModel then begin
            GenNative(m_lda_abs, absolute, op^.q+6, op^.lab, 0);
            StoreWordOfQuad(6);
            GenNative(m_lda_abs, absolute, op^.q+4, op^.lab, 0);
            StoreWordOfQuad(4);
            GenNative(m_lda_abs, absolute, op^.q+2, op^.lab, 0);
            StoreWordOfQuad(2);
            GenNative(m_lda_abs, absolute, op^.q, op^.lab, 0);
            StoreWordOfQuad(0);
            end {if}
         else begin
            GenNative(m_lda_long, longabsolute, op^.q+6, op^.lab, 0);
            StoreWordOfQuad(6);
            GenNative(m_lda_long, longabsolute, op^.q+4, op^.lab, 0);
            StoreWordOfQuad(4);
            GenNative(m_lda_long, longabsolute, op^.q+2, op^.lab, 0);
            StoreWordOfQuad(2);
            GenNative(m_lda_long, longabsolute, op^.q, op^.lab, 0);
            StoreWordOfQuad(0);
            end; {else}
         gQuad.where := gQuad.preference;
         end; {case cgQuad,cgUQuad}

      otherwise:
         Error(cge1);
      end; {case}
   end; {GenLdo}


   procedure GenLnm (op: icptr);

   { Generate code for a pc_lnm					}

   begin {GenLnm}
   if op^.left <> nil then
      GenTree(op^.left);
   if traceBack then begin
      GenNative(m_pea, immediate, op^.r, nil, 0);
      GenCall(6);
      end; {if}
   if debugFlag then begin
      if op^.lab <> nil then
         GenDebugSourceFile(op^.lab);
      GenNative(m_cop, immediate, op^.q, nil, 0);
      GenNative(d_wrd, special, op^.r, nil, 0);
      end; {if}
   end; {GenLnm}


   procedure GenLod (op: icptr);

   { Generate code for a pc_lod					}

   var
      disp: integer;			{load location}
      lab1: integer;			{branch point}
      optype: baseTypeEnum;		{op^.optype}
   
   begin {GenLod}
   disp := LabelToDisp(op^.r) + op^.q;	
   optype := op^.optype;
   case optype of
      cgReal, cgDouble, cgComp, cgExtended: begin
         GenNative(m_pea, immediate, 0, nil, 0);
         GenImplied(m_tdc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, disp, nil, 0);
         GenImplied(m_pha);
         if optype = cgReal then
            GenCall(21)
         else if optype = cgDouble then
            GenCall(22)
         else if optype = cgComp then
            GenCall(70)
         else {if optype = cgExtended then}
            GenCall(71);
         end;

      cgQuad, cgUQuad: begin
         if disp >= 250 then begin
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            GenNative(m_lda_dirx, direct, 6, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirx, direct, 4, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirx, direct, 2, nil, 0);
            GenImplied(m_pha);
            GenNative(m_lda_dirx, direct, 0, nil, 0);
            GenImplied(m_pha);
            gQuad.where := onStack;
            end {if}
         else begin
            if gQuad.preference = onStack then begin
               GenNative(m_pei_dir, direct, disp+6, nil, 0);
               GenNative(m_pei_dir, direct, disp+4, nil, 0);
               GenNative(m_pei_dir, direct, disp+2, nil, 0);
               GenNative(m_pei_dir, direct, disp, nil, 0);
               end {if}
            else begin
               GenNative(m_lda_dir, direct, disp+6, nil, 0);
               StoreWordOfQuad(6);
               GenNative(m_lda_dir, direct, disp+4, nil, 0);
               StoreWordOfQuad(4);
               GenNative(m_lda_dir, direct, disp+2, nil, 0);
               StoreWordOfQuad(2);
               GenNative(m_lda_dir, direct, disp, nil, 0);
               StoreWordOfQuad(0);
               end; {else}
            gQuad.where := gQuad.preference;
            end; {else}
         end;

      cgLong, cgULong: begin
         if ((inPointer & gLong.preference) <> 0) and (disp < 254) then
            begin
            gLong.where := inPointer;
            gLong.fixedDisp := true;
            gLong.disp := disp;
            end {if}
         else if ((A_X & gLong.preference) <> 0) and (disp < 254) then begin
            gLong.where := A_X;
            GenNative(m_ldx_dir, direct, disp+2, nil, 0);
            GenNative(m_lda_dir, direct, disp, nil, 0);
            end {else if}
         else begin
            gLong.where := onStack;
            if disp >= 254 then begin
               GenNative(m_ldx_imm, immediate, disp, nil, 0);
               GenNative(m_lda_dirx, direct, 2, nil, 0);
               GenImplied(m_pha);
               GenNative(m_lda_dirx, direct, 0, nil, 0);
               GenImplied(m_pha);
               end {if}
            else begin
               GenNative(m_pei_dir, direct, disp+2, nil, 0);
               GenNative(m_pei_dir, direct, disp, nil, 0);
               end; {else}
            end; {else}
         end;

      cgByte, cgUByte, cgWord, cgUWord: begin
         if disp >= 256 then begin
            GenNative(m_ldx_imm, immediate, disp, nil, 0);
            GenNative(m_lda_dirx, direct, 0, nil, 0);
            end
         else
            GenNative(m_lda_dir, direct, disp, nil, 0);
         if optype in [cgByte,cgUByte] then begin
            GenNative(m_and_imm, immediate, $00FF, nil, 0);
            if optype = cgByte then begin
               GenNative(m_bit_imm, immediate, $0080, nil, 0);
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               GenNative(m_ora_imm, immediate, $FF00, nil, 0);
               GenLab(lab1);
               GenNative(m_cmp_imm, immediate, $0000, nil, 0);
               end; {if}
            end;
         end;

      otherwise:
         Error(cge1);

      end; {case}
   end; {GenLod}


   procedure GenLorLnd (op: icptr);

   { Generate code for a pc_lor or pc_lnd			}

   var
      lab1,lab2,lab3,lab4: integer;	{labels}

   begin {GenLorLnd}
   lab1 := GenLabel;
   lab3 := GenLabel;
   lab4 := GenLabel;

   gLong.preference := A_X;
   GenTree(op^.left);
   if glong.where = A_X then
      GenImpliedForFlags(m_tay)
   else begin
      GenImplied(m_plx);
      GenImplied(m_pla);
      end; {else}
   GenNative(m_bne, relative, lab1, nil, 0);
   GenImplied(m_txa);
   if op^.opcode = pc_lor then begin
      lab2 := GenLabel;
      GenNative(m_beq, relative, lab2, nil, 0);
      GenLabUsedOnce(lab1);
      GenNative(m_brl, longrelative, lab3, nil, 0);
      GenLab(lab2);
      end {if}
   else begin
      GenNative(m_bne, relative, lab1, nil, 0);
      GenNative(m_brl, longrelative, lab4, nil, 0);
      GenLab(lab1);
      end; {if}

   gLong.preference := A_X;
   GenTree(op^.right);
   if glong.where = A_X then
      GenImpliedForFlags(m_tay)
   else begin
      GenImplied(m_plx);
      GenImplied(m_pla);
      end; {else}
   GenNative(m_bne, relative, lab3, nil, 0);
   GenImplied(m_txa);
   GenNative(m_beq, relative, lab4, nil, 0);
   GenLab(lab3);
   GenNative(m_lda_imm, immediate, 1, nil, 0);
   GenLab(lab4);
   end; {GenLorLnd}


   procedure GenMov (op: icptr; duplicate: boolean);

   { Generate code for a pc_mov					}
   {								}
   { parameters:						}
   {    op - pc_mov instruction					}
   {    duplicate - should the dest address be left on the	}
   {       stack?						}

   var
      banks: integer;			{number of banks to move}


      procedure Load (opcode: integer; op: icptr);

      { generate a load immediate based on instruction type	}
      {								}
      { parameters:						}
      {    opcode - native code load operation			}
      {    op - node to load					}

      var
	 i: integer;

      begin {Load}
      if op^.opcode = pc_lao then
         GenNative(opcode, immediate, op^.q, op^.lab, 0)
      else if op^.opcode = pc_lca then begin
         GenNative(opcode, immediate, stringsize, nil, StringReference);
         if maxstring-stringsize >= op^.q then begin
            for i := 1 to op^.q do
               stringspace^[i+stringsize] := op^.str^.str[i];
            stringsize := stringsize + op^.q;
            end {if}
         else
            Error(cge3);
         end {else if}
      else {if op^.opcode = pc_lda then} begin
         GenImplied(m_tdc);
         GenImplied(m_clc);
         GenNative(m_adc_imm, immediate, LabelToDisp(op^.r) + op^.q, nil, 0);
         if opcode = m_ldy_imm then
            GenImplied(m_tay)
         else
            GenImplied(m_tax);
         end; {else}
      end; {Load}


   begin {GenMov}
   banks := op^.r;
   {determine if the destination address must be left on the stack}
   if (banks = 0)
      and (op^.q <> 0)
      and (not duplicate)
      and ((op^.left^.opcode in [pc_lca,pc_lda])
         or ((op^.left^.opcode = pc_lao) and smallMemoryModel))
      and ((op^.right^.opcode in [pc_lca,pc_lda])
         or ((op^.right^.opcode = pc_lao) and smallMemoryModel)) then begin

      {take advantage of any available short cuts}
      Load(m_ldy_imm, op^.left);
      Load(m_ldx_imm, op^.right);
      GenNative(m_lda_imm, immediate, op^.q-1, nil, 0);
      GenImplied(m_phb);
      GenImplied(m_mvn);
      with op^.left^ do
	 if opcode = pc_lao then
            GenNative(d_bmov, immediate, q, lab, shift16)
	 else if opcode = pc_lca then
            GenNative(d_bmov, immediate, 0, nil, stringReference+shift16)
         else {if opcode = pc_lda then}
            GenNative(d_bmov, immediate, 0, nil, 0);
      with op^.right^ do
	 if opcode = pc_lao then
            GenNative(d_bmov, immediate, q, lab, shift16)
	 else if opcode = pc_lca then
            GenNative(d_bmov, immediate, 0, nil, stringReference+shift16)
         else {if opcode = pc_lda then}
            GenNative(d_bmov, immediate, 0, nil, 0);
      GenImplied(m_plb);
      end {if}
   else begin

      {no short cuts are available - do it the hard way}
      gLong.preference := onStack;
      GenTree(op^.left);
      gLong.preference := onStack;
      GenTree(op^.right);
      if banks <> 0 then
	 GenNative(m_pea, immediate, banks, nil, 0);
      GenNative(m_pea, immediate, op^.q, nil, 0);
      if banks = 0 then begin
	 if duplicate then
            GenCall(55)
	 else
            GenCall(54);
	 end {if}
      else
	 if duplicate then
            GenCall(63)
	 else
            GenCall(62);
      end; {else}
   end; {GenMov}


   procedure GenMpi (op: icptr);

   { Generate code for a pc_mpi or pc_umi			}
   
   var
      nd: icptr;
      val: integer;

   begin {GenMpi}
   if ((op^.left^.opcode = pc_ldc) or (op^.right^.opcode = pc_ldc))
      and ((op^.opcode = pc_umi) or (not rangeCheck)) then begin
      if op^.left^.opcode = pc_ldc then begin
         val := op^.left^.q;
         nd := op^.right;
         end {if}
      else begin
         val := op^.right^.q;
         nd := op^.left;
         end; {else}
      if nd^.opcode = pc_ldc then
         GenNative(m_lda_imm, immediate, ord(ord4(val) * ord4(nd^.q)), nil, 0)
      else begin
         GenTree(nd);
         case val of
            0: GenNative(m_lda_imm, immediate, 0, nil, 0);

            1,2,4,8,16,32,64,128:
               while not odd(val) do begin  
                  GenImplied(m_asl_a);
                  val := val >> 1;
                  end; {while}

            256,512,1024,2048,4096,8192,16384: begin
               GenNative(m_and_imm, immediate, $00FF, nil, 0);
               GenImplied(m_xba);
               val := val >> 8;
               while not odd(val) do begin  
                  GenImplied(m_asl_a);
                  val := val >> 1;
                  end; {while}
               end;

            3,5,6,9,10,12,17,18,20,24,33,34,36,40,48,65,66,68,72,80,96: begin
               if odd(val) then         {prevent lda+pha -> pei optimization}
                  GenLab(GenLabel);
               while not odd(val) do begin  
                  GenImplied(m_asl_a);
                  val := val >> 1;
                  end; {while}
               GenImplied(m_pha);
               val := val - 1;
               while not odd(val) do begin  
                  GenImplied(m_asl_a);
                  val := val >> 1;
                  end; {while}
               GenImplied(m_clc);
               GenNative(m_adc_s, direct, 1, nil, 0);
               GenImplied(m_plx);
               end;

            -1,-2,-4,-8,-16,-32,-64,-128: begin
               GenNative(m_eor_imm, immediate, -1, nil, 0);
               GenImplied(m_ina);
               val := -val;
               while not odd(val) do begin  
                  GenImplied(m_asl_a);
                  val := val >> 1;
                  end; {while}
               end;

            -256: begin
               GenNative(m_eor_imm, immediate, -1, nil, 0);
               GenImplied(m_ina);
               GenNative(m_and_imm, immediate, $00FF, nil, 0);
               GenImplied(m_xba);
               end;

            otherwise: begin
               if val = $8000 then begin
                  GenImplied(m_lsr_a);
                  GenNative(m_lda_imm, immediate, 0, nil, 0);
                  GenImplied(m_ror_a);
                  end {if}
               else begin
                  GenNative(m_ldx_imm, immediate, val, nil, 0);
                  if op^.opcode = pc_mpi then
                     GenCall(28)
                  else {pc_umi}
                     GenCall(94);
                  end; {else}
               end;
            end; {case}
         end; {else}
      end {if}
   else begin
      if not Complex(op^.left) then
         if Complex(op^.right) then begin
            nd := op^.left;
            op^.left := op^.right;
            op^.right := nd;
            end; {if}
      GenTree(op^.left);
      if Complex(op^.right) then begin
         GenImplied(m_pha);
         GenTree(op^.right);
         GenImplied(m_plx);
         end {if}
      else
         LoadX(op^.right);
      if op^.opcode = pc_mpi then begin
         GenCall(28);      
         if rangeCheck then
            GenCall(25);
         end {if}
      else {pc_umi}
         GenCall(94);
      end; {else}
   end; {GenMpi}


   procedure GenNam (op: icptr);                    

   { Generate code for a pc_nam					}

   var
      i: integer;			{loop/index variable}

   begin {GenNam}
   {generate a call to install the name in the traceback facility}
   if traceBack then begin
      GenNative(m_pea, immediate, stringSize, nil, stringReference+shift16);
      GenNative(m_pea, immediate, stringSize, nil, stringReference);
      GenCall(5);
      namePushed := true;
      end; {if}

   {send the name to the profiler}
   if profileFlag then begin
      GenNative(m_cop, immediate, 3, nil, 0);
      GenNative(d_add, genaddress, stringSize, nil, stringReference);
      GenNative(d_add, genaddress, stringSize, nil, stringReference+shift16);
      end; {if}

   {place the name in the string buffer}
   if maxString-stringSize >= op^.q+1 then begin
      stringSpace^[stringSize+1] := chr(op^.q);
      for i := 1 to op^.q do
         stringSpace^[i+stringSize+1] := op^.str^.str[i];
      stringSize := stringSize + op^.q + 1;
      end {if}
   else
      Error(cge3);

   {send the file name to the debugger}
   if debugFlag then
      GenDebugSourceFile(@debugSourceFileGS);
   end; {GenNam}


   procedure GenNat (op: icptr);                    

   { Generate code for a pc_nat					}

   var
      flags: integer;			{work var for flags}
      mode: addressingmode;		{work var for addressing mode}
      pval: longint;			{temp pointer}
      val: longint;			{constant operand}
      opcode: integer;			{opcode}

   begin {GenNat}
   val := op^.opnd;
   flags := op^.q;
   pval := op^.llab;
   mode := addressingMode(op^.r);
   opcode := op^.s;
   if opcode < 256 then
      opcode := opcode | asmFlag;
   if op^.slab <> 0 then begin
      val := val+LabelToDisp(op^.slab);
      if mode = direct then
         if (val > 255) or (val < 0) then
            Error(cge4);
      end; {if}
   if mode in [relative,longrelative] then
      GenNative(opcode, mode, op^.llab, op^.lab, op^.q)
   else if (mode = longabsolute) and (op^.llab <> 0) then
      GenNative(opcode, mode, long(val).lsw, pointer(pval),
         flags | localLab)
   else if (mode = longabsolute) and (op^.llab = 0)
      and (op^.lab = nil) then
      GenNative(opcode, mode, 0, pointer(val), flags | constantOpnd)
   else begin
      if (mode = absolute) and (op^.llab = 0) then
         flags := flags | constantOpnd;
      if op^.llab <> 0 then
         GenNative(opcode, mode, long(val).lsw, pointer(pval),
            flags | localLab)
      else
         GenNative(opcode, mode, long(val).lsw, op^.lab, flags);
      end; {else}
   end; {GenNat}


   procedure GenNgr (op: icptr);

   { Generate code for a pc_ngr					}

   begin {GenNgr}
   GenTree(op^.left);
   GenNative(m_lda_s, direct, 9, nil, 0);
   GenNative(m_eor_imm, immediate, -32767-1, nil, 0);
   GenNative(m_sta_s, direct, 9, nil, 0);
   end; {GenNgr}


   procedure GenPop (op: icptr);                    

   { Generate code for a pc_pop					}

   var
      isIncLoad: boolean;		{is the operand one of the inc/dec & load commands?}

   begin {GenPop}
   glong.preference := A_X;		{generate the operand}
   gQuad.preference := nowhere;
   isIncLoad := op^.left^.opcode in
      [pc_lil,pc_lli,pc_ldl,pc_lld,pc_gil,pc_gli,pc_gdl,pc_gld,
       pc_iil,pc_ili,pc_idl,pc_ild];
   if isIncLoad then
      skipLoad := true;
   if op^.left^.opcode = pc_mov then
      GenMov(op^.left, false)
   else if op^.left^.opcode in [pc_cop,pc_cpo,pc_cpi,pc_cbf] then begin
      if op^.left^.opcode = pc_cop then
         op^.left^.opcode := pc_str
      else if op^.left^.opcode = pc_cpo then
         op^.left^.opcode := pc_sro
      else if op^.left^.opcode = pc_cpi then
         op^.left^.opcode := pc_sto
      else {if op^.left^.opcode = pc_cbf then}
         op^.left^.opcode := pc_sbf;
      GenTree(op^.left);
      end {else if}
   else begin
      GenTree(op^.left);
      if isIncLoad then
	 skipLoad := false;
      case op^.optype of		{do the pop}
	 otherwise: Error(cge1);

	 cgByte, cgUByte, cgWord, cgUWord, cgVoid: ;

	 cgLong, cgULong:
            if not isIncLoad then
               if gLong.where = onStack then begin
        	  GenImplied(m_pla);
        	  GenImplied(m_pla);
        	  end; {if}
               {else do nothing}

	 cgQuad, cgUQuad: begin
            if gQuad.where = onStack then begin
               GenImplied(m_tsc);
               GenImplied(m_clc);
               GenNative(m_adc_imm, immediate, 8, nil, 0);
               GenImplied(m_tcs);
               end; {if}
            end;
         
	 cgReal, cgDouble, cgComp, cgExtended: begin
            GenImplied(m_tsc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, 10, nil, 0);
            GenImplied(m_tcs);
            end;
	 end; {case}
      end; {else}
   end; {GenPop}


   procedure GenPsh (op: icptr);

   { Generate code for a pc_psh					}

   begin {GenPsh}
   gLong.preference := onStack;
   GenTree(op^.left);
   GenTree(op^.right);
   GenImplied(m_pha);
   GenCall(77);
   end; {GenPsh}


   procedure GenRbo (op: icptr);

   { Generate code for a pc_rbo					}

   begin {GenRbo}
   GenTree(op^.left);
   GenImplied(m_xba);
   end; {GenRbo}


   procedure GenRealBinOp (op: icptr);

   { Generate code for a pc_adr, pc_dvr, pc_mpr or pc_sbr	}

   var
      nd: icptr;			{temp pointer}
      snum: integer;			{library subroutine numbers}
      ss,sd,sc,se: integer;		{sane call numbers}

   begin {GenRealBinOp}
   case op^.opcode of
      pc_adr: begin
	 snum := 56;
	 ss := $0200;
	 sd := $0100;
	 sc := $0500;
	 se := $0000;
	 end;

      pc_dvr: begin
	 snum := 57;
	 ss := $0206;
	 sd := $0106;
	 sc := $0506;
	 se := $0006;
	 end;

      pc_mpr: begin
	 snum := 58;
	 ss := $0204;
	 sd := $0104;
	 sc := $0504;
	 se := $0004;
	 end;

      pc_sbr: begin
	 snum := 59;
	 ss := $0202;
	 sd := $0102;
	 sc := $0502;
	 se := $0002;
	 end;
      end; {case}

   if op^.opcode in [pc_mpr,pc_adr] then
      if op^.left^.opcode in [pc_lod,pc_ldo] then begin
         nd := op^.left;
         op^.left := op^.right;
         op^.right := nd;
         end; {if}
   GenTree(op^.left);
   if (op^.right^.opcode in [pc_lod,pc_ldo]) and (floatCard = 0) then
      with op^.right^ do begin
	 if opcode = pc_lod then begin
            GenNative(m_pea, immediate, 0, nil, 0);
            GenImplied(m_tdc);
            GenImplied(m_clc);
            GenNative(m_adc_imm, immediate, LabelToDisp(r) + q, nil, 0);
            GenImplied(m_pha);              
            end {if}
	 else begin
            GenNative(m_pea, immediate, q, lab, shift16);
            GenNative(m_pea, immediate, q, lab, 0);
            end; {else}
	 GenNative(m_pea, immediate, 0, nil, 0);
	 GenImplied(m_tsc);
	 GenImplied(m_clc);
	 GenNative(m_adc_imm, immediate, 7, nil, 0);
	 GenImplied(m_pha);
	 if optype = cgReal then
            sd := ss
	 else if optype = cgExtended then
            sd := se
	 else if optype = cgComp then
            sd := sc;
	 GenNative(m_pea, immediate, sd, nil, 0);
	 GenNative(m_ldx_imm, immediate, $090A, nil, 0);
	 GenNative(m_jsl, longAbs, 0, nil, toolCall);
	 end {with}
   else begin
      GenTree(op^.right);
      GenCall(snum);
      end; {else}
   end; {GenRealBinOp}


   procedure GenRetRev (op: icptr);

   { Generate code for a pc_ret	or pc_rev			}

   var
      size: integer;			{localSize + parameterSize}
      lab1: integer;			{label}
      valuePushed: boolean;             {return value pushed on stack?}
      evaluateAtEnd: boolean;           {evaluate return val right before rtl?}

   begin {GenRetRev}
   size := localSize + parameterSize;
   evaluateAtEnd := false;

   {calculate return value, if necessary}
   if op^.opcode = pc_rev then begin
      if op^.left^.opcode in [pc_ldc,pc_lca,pc_lao,pc_lad] then begin
         evaluateAtEnd := true;
         valuePushed := false;
         end {if}
      else begin
         valuePushed := namePushed or debugFlag or profileFlag
            or ((parameterSize <> 0) and (size > 253));
         if valuePushed then
            gLong.preference := onStack
         else
            gLong.preference := A_X;
         GenTree(op^.left);
         if op^.optype in [cgByte,cgUByte,cgWord,cgUWord] then begin
            if valuePushed then
               GenImplied(m_pha)
            else
               GenImplied(m_tay);
            end {if}
         else {if op^.optype in [cgLong,cgULong] then} begin
            valuePushed := gLong.where = onStack;
            if not valuePushed then
               GenImplied(m_tay);
            end; {else}
         end; {else}
      end;
   
   {pop the name record}
   if namePushed then
      GenCall(2);

   {generate an exit code for the debugger/profiler's benefit}
   if debugFlag or profileFlag then
      GenNative(m_cop, immediate, 4, nil, 0);

   {if anything needs to be removed from the stack, move the return address}
   if parameterSize <> 0 then begin
      if localSize > 253 then begin
         GenNative(m_ldx_imm, immediate, localSize+1, nil, 0);
         GenNative(m_lda_dirx, direct, 0, nil, 0);
         GenNative(m_ldy_dirx, direct, 1, nil, 0);
         GenNative(m_ldx_imm, immediate,
            localSize+parameterSize+1, nil, 0);
         GenNative(m_sta_dirx, direct, 0, nil, 0);
         GenNative(m_sty_dirx, direct, 1, nil, 0);
         end {if}
      else begin
         GenNative(m_lda_dir, direct, localSize+2, nil, 0);
         if localSize+parameterSize > 253 then begin
            GenNative(m_ldx_imm, immediate,
               localSize+parameterSize+1, nil, 0);
            GenNative(m_sta_dirx, direct, 1, nil, 0);
            GenNative(m_lda_dir, direct, localSize+1, nil, 0);
            GenNative(m_sta_dirx, direct, 0, nil, 0);
            end {if}
         else begin
            GenNative(m_sta_dir, direct,
               localSize+parameterSize+2, nil, 0);
            GenNative(m_lda_dir, direct, localSize+1, nil, 0);
            GenNative(m_sta_dir, direct,
               localSize+parameterSize+1, nil, 0);
            end; {else}
         end; {else}
      end; {if}
   
   if op^.opcode = pc_rev then begin
      if valuePushed then begin
         if size = 2 then
            GenImplied(m_pla)
         else
            GenImplied(m_ply);
         if op^.optype in [cgLong,cgULong] then
            GenImplied(m_plx);
         end {if}
      else if not evaluateAtEnd then
         if size = 2 then
            GenImplied(m_tya);
      end {if}
   else
      case op^.optype of                {load the value to return}

         cgVoid: ;

         cgByte,cgUByte: begin
            GenNative(m_lda_dir, direct, funLoc, nil, 0);
            GenNative(m_and_imm, immediate, $00FF, nil, 0);         
            if op^.optype = cgByte then begin
               GenNative(m_bit_imm, immediate, $0080, nil, 0);
               lab1 := GenLabel;
               GenNative(m_beq, relative, lab1, nil, 0);
               GenNative(m_ora_imm, immediate, $FF00, nil, 0);
               GenLab(lab1);
               end; {if}
            if size <> 2 then
               GenImplied(m_tay);
            end;

         cgWord,cgUWord:
            if size = 2 then
               GenNative(m_lda_dir, direct, funLoc, nil, 0)
            else
               GenNative(m_ldy_dir, direct, funLoc, nil, 0);

         cgReal:
            GenCall(3);

         cgDouble:
            GenCall(4);

         cgComp:
            GenCall(64);

         cgExtended:
            GenCall(65);

         cgLong,cgULong: begin
            GenNative(m_ldx_dir, direct, funLoc+2, nil, 0);
            GenNative(m_ldy_dir, direct, funLoc, nil, 0);
            end;

         cgQuad,cgUQuad: ;                 {return value was already written}

         otherwise:
            Error(cge1);
         end; {case}

   {restore data bank reg}
   if dataBank then begin
      GenNative(m_pei_dir, direct, bankLoc, nil, 0);
      GenImplied(m_plb);
      GenImplied(m_plb);
      end; {if}

   {get rid of the stack frame space}
   if size <> 0 then
      GenImplied(m_pld);
   if size = 2 then
      GenImplied(m_ply)
   else if size <> 0 then begin
      GenImplied(m_tsc);
      GenImplied(m_clc);
      GenNative(m_adc_imm, immediate, size, nil, 0);
      GenImplied(m_tcs);
      end; {if}

   {put return value in correct place}
   case op^.optype of
      cgByte,cgUByte,cgWord,cgUWord: begin
         if evaluateAtEnd then
            GenTree(op^.left)
         else if size <> 2 then
            GenImplied(m_tya);
         if toolParms then        {save value on stack for tools}
            GenNative(m_sta_s, direct, returnSize+1, nil, 0);
         end;

      cgLong,cgULong,cgReal,cgDouble,cgComp,cgExtended: begin
         if evaluateAtEnd then begin
            gLong.preference := A_X;
            GenTree(op^.left);
            if gLong.where = onStack then begin
               GenImplied(m_pla);
               GenImplied(m_plx);
               end; {if}
            end {if}
         else if size <> 2 then
            GenImplied(m_tya);
         if toolParms then begin  {save value on stack for tools}
            GenNative(m_sta_s, direct, returnSize+1, nil, 0);
            GenImplied(m_txa);
            GenNative(m_sta_s, direct, returnSize+3, nil, 0);
            end; {if}
         end;

      cgVoid,cgQuad,cgUQuad: ;

      otherwise:
         Error(cge1);
      end; {case}

   {return to the caller}
   GenImplied(m_rtl);
   end; {GenRetRev}


   procedure GenSbfCbf (op: icptr);

   { Generate code for a pc_sbf or pc_cbf			}

   begin {GenSbfCbf}
   gLong.preference := onStack;
   GenTree(op^.left);
   GenNative(m_pea, immediate, op^.r, nil, 0);
   GenNative(m_pea, immediate, op^.q, nil, 0);
   if op^.optype in [cgLong,cgULong] then begin
      gLong.preference := onStack;
      GenTree(op^.right);
      end {if}
   else begin
      GenNative(m_pea, immediate, 0, nil, 0);
      GenTree(op^.right);
      GenImplied(m_pha);
      end; {else}
   if op^.opcode = pc_sbf then
      GenCall(74)
   else begin
      GenCall(75);
      if not (op^.optype in [cgLong,cgULong]) then begin
         GenImplied(m_pla);
         GenImplied(m_plx);
         end; {if}
      end; {else}
   end; {GenSbfCbf}


   procedure GenSbi (op: icptr);

   { Generate code for a pc_sbi					}
   
   begin {GenSbi}
   if Complex(op^.right) then begin
      GenTree(op^.right);
      if Complex(op^.left) then begin
	 GenImplied(m_pha);
	 GenTree(op^.left);
	 GenImplied(m_sec);
	 GenNative(m_sbc_s, direct, 1, nil, 0);
	 GenImplied(m_plx);
         end {if}
      else begin
         GenNative(m_eor_imm, immediate, $FFFF, nil, 0);
	 GenImplied(m_sec);
         OperA(m_adc_imm, op^.left);
         end; {else}
      end {if}
   else begin
      GenTree(op^.left);
      GenImplied(m_sec);
      OperA(m_sbc_imm, op^.right);
      end; {else}
   end; {GenSbi}


   procedure GenStk (op: icptr);

   { Generate code for a pc_stk					}

   begin {GenStk}
   if op^.left^.opcode = pc_psh then begin
      if (op^.left^.right^.opcode = pc_ldc) and
         (op^.left^.right^.optype in [cgWord,cgUWord]) then
         argsSize := argsSize + op^.left^.right^.q
      else
         Error(cge1);
      end {if}
   else
      case op^.optype of
         cgByte,cgUByte,cgWord,cgUWord:
            argsSize := argsSize + cgWordSize;
         cgReal,cgDouble,cgComp,cgExtended:
            argsSize := argsSize + cgExtendedSize;
         cgLong,cgULong:
            argsSize := argsSize + cgLongSize;
         cgQuad,cgUQuad:
            argsSize := argsSize + cgQuadSize;
         otherwise: Error(cge1);
         end; {case}
   glong.preference := onStack;		{generate the operand}
   gQuad.preference := onStack;
   GenTree(op^.left);
   if op^.optype in			{do the stk}
      [cgByte, cgUByte, cgWord, cgUWord] then
      GenImplied(m_pha);
   end; {GenStk}
   

   procedure GenShlShrUsr (op: icptr);

   { Generate code for a pc_shl, pc_shr or pc_usr		}

   var
      i,op1,op2,op3,num: integer;	{temp variables}

   begin {GenShlShrUsr}
   {get the standard native operations}
   if op^.opcode = pc_shl then begin
      op1 := m_asl_a;
      op2 := m_lsr_a;
      op3 := m_ror_a;
      end {if}
   else begin
      op1 := m_lsr_a;
      op2 := m_asl_a;
      op3 := m_rol_a;
      end; {else}

   {take short cuts if they are legal}
   if (op^.right^.opcode = pc_ldc) and (op^.opcode <> pc_shr) then begin
      num := op^.right^.q;
      if (num > 16) or (num < -16) then
	 GenNative(m_lda_imm, immediate, 0, nil, 0)
      else if num > 0 then begin
         GenTree(op^.left);
         if num in [13..15] then begin
            for i := 1 to 17-num do
               GenImplied(op3);
            if op^.opcode = pc_shl then
               i := $ffff << num
            else
               i := $7fff >> (num-1);
            GenNative(m_and_imm, immediate, i, nil, 0);
            end {if}
         else begin
            if num >= 8 then begin
               GenImplied(m_xba);
               if op1 = m_lsr_a then
                  i := $00FF
               else
                  i := $FF00;
               GenNative(m_and_imm, immediate, i, nil, 0);
               num := num-8;
               end; {if}
            for i := 1 to num do
               GenImplied(op1);
            end; {else}
	 end {else if}
      else if num < 0 then begin
	 GenTree(op^.left);
         if num <= -8 then begin
            GenImplied(m_xba);
            if op2 = m_lsr_a then
               i := $00FF
            else
               i := $FF00;
            GenNative(m_and_imm, immediate, i, nil, 0);
            num := num+8;
            end; {if}
	 for i := 1 to -num do
            GenImplied(op2);
	 end {else if}
      else
	 GenTree(op^.left);
      end {if}
   else begin
      GenTree(op^.left);
      if Complex(op^.right) then begin
	 GenImplied(m_pha);
	 GenTree(op^.right);
	 GenImplied(m_tax);
	 GenImplied(m_pla);
	 end {if}
      else
	 LoadX(op^.right);
      if op^.opcode = pc_shl then
	 GenCall(23)
      else if op^.opcode = pc_shr then
	 GenCall(24)
      else {if op^.opcode = pc_usr then}
	 GenCall(41);
      end; {else}
   end; {GenShlShrUsr}
   

   procedure GenTl1 (op: icptr);

   { Generate code for a pc_tl1					}

   var
      lLong: longType;                     {used to reserve gLong}

   begin {GenTl1}
   if op^.r in [2,4] then begin
      GenImplied(m_pha);
      if op^.r = 4 then
         GenImplied(m_pha);
      end; {if}
   lLong := gLong;
   GenTree(op^.left);
   gLong := lLong;
   GenNative(m_ldx_imm, immediate, op^.q, nil, 0);
   GenNative(m_jsl, longAbs, 0, pointer(op^.lval), toolCall);
   if smallMemoryModel then
      GenNative(m_sta_abs, absolute, 0, @'~TOOLERROR', 0)
   else
      GenNative(m_sta_long, longAbs, 0, @'~TOOLERROR', 0);
   if op^.r in [2,4] then begin
      if op^.r = 2 then
         GenImplied(m_pla)
      else
         gLong.where := onStack;
      end; {if}
   end; {GenTl1}


   procedure GenTri (op: icptr);

   { Generate code for a pc_tri					}

   var
      lab1,lab2,lab3: integer;		{label for branches}

   begin {GenTri}
   lab1 := GenLabel;
   lab2 := GenLabel;
   lab3 := GenLabel;
   GenTree(op^.left);
   if NeedsCondition(op^.left^.opcode) then
      GenImpliedForFlags(m_tax);
   GenNative(m_beq, relative, lab1, nil, 0);
   GenNative(m_brl, longrelative, lab2, nil, 0);
   GenLab(lab1);
   gLong.preference := onStack;
   GenTree(op^.right^.right);
   GenNative(m_brl, longrelative, lab3, nil, 0);
   GenLab(lab2);
   gLong.preference := onStack;
   GenTree(op^.right^.left);
   GenLab(lab3);
   gLong.where := onStack;
   end; {GenTri}


   procedure GenXjp (op: icptr);

   { Generate code for a pc_xjp					}

   var
      lab1: integer;
      q: integer;

   begin {GenXjp}
   q := op^.q;
   GenTree(op^.left);
   GenNative(m_cmp_imm, immediate, q, nil, 0);
   lab1 := GenLabel;
   GenNative(m_bcc, relative, lab1, nil, 0);
   GenNative(m_lda_imm, immediate, q, nil, 0);
   GenLab(lab1);
   GenImplied(m_asl_a);
   GenImplied(m_tax);
   lab1 := GenLabel;
   GenNative(m_jmp_indX, absolute, lab1, nil, 0);
   GenLab(lab1);
   end; {GenXjp}


   procedure DirEnp;

   { Generate code for a dc_enp					}

   begin {DirEnp}
   GenImplied(d_end);
   EndSeg;
   InitLabels;
   end; {DirEnp}


   procedure DirStr (op: icptr);

   { Generate code for a dc_str					}

   begin {DirStr}
   skipLoad := false;
   InitNative;
   Header(op^.lab, op^.r, op^.q);
   end; {DirStr}


   procedure DirSym (op: icptr);

   { Generate code for a dc_sym					}

   begin {DirSym}
   if debugFlag then
      GenNative(d_sym, special, op^.q, pointer(op^.lab), 0);
   end; {DirSym}


begin {GenTree}
{write('GEN: '); WriteCode(op); {debug}
Spin;
case op^.opcode of
   dc_cns: GenNative(d_cns, gnrConstant, op^.q, pointer(op), 0);
   dc_dst: GenNative(d_lab, gnrSpace, op^.q, nil, 0);
   dc_enp: DirEnp;
   dc_lab: GenLab(op^.q);
   dc_loc,dc_prm: ;
   dc_glb: GenNative(d_lab, gnrLabel, op^.r, op^.lab, isPrivate*op^.q);
   dc_pin: GenNative(d_pin, special, 0, nil, 0);
   dc_str: DirStr(op);
   dc_sym: DirSym(op);
   pc_add: GenNative(d_add, genaddress, op^.q, nil, 0);
   pc_adi: GenAdi(op);
   pc_adl,pc_sbl: GenAdlSbl(op, nil);
   pc_adq,pc_sbq: GenAdqSbq(op);
   pc_adr,pc_dvr,pc_mpr,pc_sbr: GenRealBinOp(op);
   pc_and,pc_bnd,pc_bor,pc_bxr,pc_ior: GenLogic(op);
   pc_blr,pc_blx,pc_bal,pc_dvl,pc_mdl,pc_mpl,pc_sll,pc_slr,pc_udl,pc_ulm,
      pc_uml,pc_vsr: GenBinLong(op);
   pc_bqr,pc_bqx,pc_baq,pc_mpq,pc_umq,pc_dvq,pc_udq,pc_mdq,pc_uqm,pc_slq,
      pc_sqr,pc_wsr: GenBinQuad(op);
   pc_bnl,pc_ngl: GenUnaryLong(op);
   pc_bnq,pc_ngq: GenUnaryQuad(op);
   pc_bno: GenBno(op);
   pc_bnt,pc_ngi,pc_not: GenBntNgiNot(op);
   pc_ckp: GenCkp(op);
   pc_cnv: GenCnv(op);
   pc_cui: GenCui(op);
   pc_cup: GenCup(op);
   pc_dec,pc_inc: GenIncDec(op, nil);
   pc_dvi,pc_mod,pc_udi,pc_uim: GenDviMod(op);
   pc_ent: GenEnt(op);
   pc_equ,pc_neq: GenEquNeq(op, op^.opcode, 0);
   pc_fix: GenFix(op);
   pc_fjp,pc_tjp: GenFjpTjp(op);
   pc_geq,pc_grt,pc_leq,pc_les: GenCmp(op, op^.opcode, 0);
   pc_gil,pc_gli,pc_gdl,pc_gld: GenGilGliGdlGld(op);
   pc_iil,pc_ili,pc_idl,pc_ild: GenIilIliIdlIld(op);
   pc_ind: GenInd(op);
   pc_ixa: GenIxa(op);
   pc_lao,pc_lad: GenLaoLad(op);
   pc_lbf,pc_lbu: GenLbfLbu(op);
   pc_lca: GenLca(op);  
   pc_lda: GenLda(op);  
   pc_ldc: GenLdc(op);  
   pc_ldo: GenLdo(op);
   pc_lil,pc_lli,pc_ldl,pc_lld: GenLilLliLdlLld(op);
   pc_lnm: GenLnm(op);
   pc_lod: GenLod(op);  
   pc_lor,pc_lnd: GenLorLnd(op);
   pc_mov: GenMov(op, true);
   pc_mpi,pc_umi: GenMpi(op);
   pc_nam: GenNam(op);
   pc_nat: GenNat(op);
   pc_ngr: GenNgr(op);
   pc_nop: ;
   pc_pop: GenPop(op);                
   pc_psh: GenPsh(op);
   pc_rbo: GenRbo(op);
   pc_ret,pc_rev: GenRetRev(op);
   pc_sbf,pc_cbf: GenSbfCbf(op);
   pc_sbi: GenSbi(op);
   pc_shl,pc_shr,pc_usr: GenShlShrUsr(op);
   pc_stk: GenStk(op);
   pc_sro,pc_cpo: GenSroCpo(op);
   pc_sto,pc_cpi: GenStoCpi(op);
   pc_str,pc_cop: GenStrCop(op);
   pc_sxi,pc_zxi: GenSxiZxi(op);
   pc_sxl,pc_zxl: GenSxlZxl(op);
   pc_sxq,pc_zxq: GenSxqZxq(op);
   pc_tl1: GenTl1(op);
   pc_tri: GenTri(op);
   pc_ujp: GenNative(m_brl, longrelative, op^.q, nil, 0);
   pc_xjp: GenXjp(op);

   otherwise: Error(cge1);
   end; {case}
end; {GenTree}

{---------------------------------------------------------------}

procedure Gen {blk: blockPtr};

{ Generates native code for a list of blocks			}
{                                                               }
{ parameters:                                                   }
{    blk - first of the list of blocks				}

const
   locSize = 4;				{variables <= this size allocated first}

var
   bk: blockPtr;			{used to trace block lists}
   minSize: integer;			{location for the next local label}
   op: icptr;				{used to trace code lists}


   procedure DirLoc1 (op: icptr);

   { allocates stack frame locations for small dc_loc		}

   begin {DirLoc1}
   if op^.q <= locSize then begin
      if op^.r < maxLocalLabel then begin
	 localLabel[op^.r] := minSize;
         minSize := minSize + op^.q;
	 end {if}
      else
	 Error(cge2);
      end; {if}
   end; {DirLoc1}


   procedure DirLoc2 (op: icptr);

   { allocates stack frame locations for large dc_loc		}

   begin {DirLoc2}
   if op^.q > locSize then begin
      if op^.r < maxLocalLabel then begin
	 localLabel[op^.r] := minSize;
         minSize := minSize + op^.q;
	 end {if}
      else
	 Error(cge2);
      end; {if}
   end; {DirLoc2}


   procedure DirPrm (op: icptr);

   { allocates stack frame locations for parameters		}

   begin {DirPrm}
   if op^.s < maxLocalLabel then 
      localLabel[op^.s] := localSize + returnSize + 1 + op^.r
   else
      Error(cge2);
   end; {DirPrm}


   procedure Scan (op: icptr);

   { scans the code stream for instructions that effect the	}
   { size of the stack frame					}
   {								}
   { parameters:						}
   {    op - scan this opcode and its children			}

   var
      opcode: pcodes;			{op^.opcode}
      size: integer;			{function return value size}

   begin {Scan}
   if op^.left <> nil then
      Scan(op^.left);
   if op^.right <> nil then
      Scan(op^.right);
   opcode := op^.opcode;
   if opcode = dc_loc then
      localSize := localSize + op^.q
   else if opcode = dc_prm then
      parameterSize := parameterSize + op^.q
   else if opcode = pc_ret then begin
      case op^.optype of
         otherwise:			size := 0;
         cgByte,cgUByte,cgWord,cgUWord:	size := cgWordSize;
         cgReal:			size := cgRealSize;
         cgDouble:			size := cgDoubleSize;
         cgComp:			size := cgCompSize;
         cgExtended:			size := cgExtendedSize;
         cgLong,cgULong:		size := cgLongSize;
         cgQuad,cgUQuad:		begin
                        		size := cgLongSize; {pointer}
                        		isQuadFunction := true;
                        		end;
         end; {case}
      funLoc := 1;
      if dworkLoc <> 0 then
         dworkLoc := dworkLoc + size;
      minSize := minSize + size;
      localSize := localSize + size;
      end {else if}
   else if opcode in
      [pc_les,pc_leq,pc_grt,pc_geq,pc_sto,pc_cpi,pc_ind,
       pc_ili,pc_iil,pc_idl,pc_ild,pc_ixa]
      then begin
      if dworkLoc = 0 then begin
         dworkLoc := minSize;
         minSize := minSize + 4;
         localSize := localSize + 4;
         end; {if}
      end; {else if}
   end; {Scan}


begin {Gen}
bk := blk;				{determine the size of the stack frame}
localSize := 0;
parameterSize := 0;
funLoc := 0;
dworkLoc := 0;
minSize := 1;
stackSaveDepth := 0;
isQuadFunction := false;
while bk <> nil do begin 
   op := bk^.code;
   while op <> nil do begin
      Scan(op);
      op := op^.next;
      end; {while}
   bk := bk^.next;
   end; {while}
if saveStack or checkStack or (strictVararg and hasVarargsCall) then begin
   stackLoc := minSize;
   minSize := minSize + 2;
   localSize := localSize + 2;
   end; {if}
if dataBank then begin
   bankLoc := minSize;
   minSize := minSize + 2;
   localSize := localSize + 2;
   end; {if}                  
bk := blk;				{allocate locations for the values}
while bk <> nil do begin 
   op := bk^.code;
   while op <> nil do begin
      if op^.opcode = dc_loc then
         DirLoc1(op)
      else if op^.opcode = dc_prm then
         DirPrm(op);
      op := op^.next;
      end; {while}
   bk := bk^.next;
   end; {while}
bk := blk;
while bk <> nil do begin 
   op := bk^.code;
   while op <> nil do begin
      if op^.opcode = dc_loc then
         DirLoc2(op);
      op := op^.next;
      end; {while}
   bk := bk^.next;
   end; {while}
while blk <> nil do begin		{generate code for the block}
   op := blk^.code;
   while op <> nil do begin
      GenTree(op);
      op := op^.next;
      end; {while}
   blk := blk^.next;
   end; {while}
end; {Gen}


function LabelToDisp {lab: integer): integer};

{ convert a local label number to a stack frame displacement    }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }

begin {LabelToDisp}
if lab = 0 then
   LabelToDisp := funLoc
else
   LabelToDisp := localLabel[lab];
end; {LabelToDisp}

end.
