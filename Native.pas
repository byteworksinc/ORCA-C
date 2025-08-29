{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  ORCA Native Code Generation                                  }
{                                                               }
{  This module of the code generator is called to generate      }
{  native code instructions.  The native code is optimized      }
{  and written to the object segment.                           }
{                                                               }
{  Externally available procedures:                             }
{                                                               }
{  EndSeg - close out the current segment                       }
{  GenNative - write a native code instruction to the output    }
{       file                                                    }
{  GenImplied - short form of GenNative - reduces code size     }
{  GenCall - short form of jsl to library subroutine - reduces  }
{       code size                                               }
{  GenLab - generate a label                                    }
{  InitFile - Set up the object file				}
{  InitNative - set up for a new segment			}
{  RefName - handle a reference to a named label                }
{                                                               }
{---------------------------------------------------------------}

unit Native;

interface

{$LibPrefix '0/obj/'}

uses CCommon, CGI, CGC, ObjOut;

{$segment 'CODEGEN'}

type
   labelptr = ^labelentry;              {pointer to a forward ref node}
   labelentry = record                  {forward ref node}
      addr: longint;
      next: labelptr;
      end;

   labelrec = record                    {label record}
      defined: boolean;                 {Note: form used in objout.asm}
      chain: labelptr;
      case boolean of
         true : (val: longint);
         false: (ival,hval: integer);
      end;

var
                                        {current instruction info}
                                        {------------------------}
   pc: longint;                         {program counter}

                                        {65816 native code generation}
                                        {----------------------------}
   didOne: boolean;                     {has an optimization been done?}
   labeltab: array[0..maxlabel] of labelrec; {label table}
   localLabel: array[0..maxLocalLabel] of integer; {local variable label table}

{---------------------------------------------------------------}
   
procedure EndSeg;

{ close out the current segment                                 }


procedure GenNative (p_opcode: integer; p_mode: addressingMode;
                     p_operand: integer; p_name: stringPtr; p_flags: integer);

{ write a native code instruction to the output file            }
{                                                               }
{ parameters:                                                   }
{       p_opcode - native op code                               }
{       p_mode - addressing mode                                }
{       p_operand - integer operand                             }
{       p_name - named operand                                  }
{       p_flags - operand modifier flags                        }


procedure GenImplied (p_opcode: integer);

{ short form of GenNative - reduces code size                   }
{                                                               }
{ parameters:                                                   }
{       p_code - operation code                                 }


procedure GenImpliedForFlags (p_opcode: integer);

{ Generate implied addressing instruction used for flags only.  }
{                                                               }
{ parameters:                                                   }
{       p_code - operation code (m_tax or m_tay)                }


procedure GenCall (callNum: integer);

{ short form of jsl to library subroutine - reduces code size   }
{                                                               }
{ parameters:                                                   }
{       callNum - subroutine # to generate a call for           }


procedure GenLab (lnum: integer);

{ generate a label                                              }
{                                                               }
{ parameters:                                                   }
{       lnum - label number                                     }


procedure GenLabUsedOnce (lnum: integer);

{ generate a label that is only targeted by one branch          }
{                                                               }
{ parameters:                                                   }
{       lnum - label number                                     }


procedure InitFile (keepName: gsosOutStringPtr; keepFlag: integer; partial: boolean);

{ Set up the object file					}
{                                                               }
{ parameters:							}
{    keepName - name of the output file				}
{    keepFlag - keep status:					}
{       0 - don't keep the output				}
{       1 - create a new object module				}
{       2 - a .root already exists				}
{       3 - at least on .letter file exists			}
{    partial - is this a partial compile?			}
{								}
{ Note: Declared as extern in CGI.pas				}


procedure InitNative;

{ set up for a new segment					}


procedure LabelSearch (lab: integer; len, shift, disp: integer);

{ resolve a label reference                                     }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }
{       len - # bytes for the generated code                    }
{       shift - shift factor                                    }
{       disp - disp past the label                              }
{                                                               }
{ Note 1: maxlabel is reserved for use as the start of the      }
{       string space                                            }
{ Note 2: negative length indicates relative branch             }
{ Note 3: zero length indicates 2 byte addr -1                  }


procedure RefName (lab: stringPtr; disp, len, shift: integer);

{ handle a reference to a named label                           }
{                                                               }
{ parameters:                                                   }
{       lab - label name                                        }
{       disp - displacement past the label                      }
{       len - number of bytes in the reference                  }
{       shift - shift factor                                    }


{--------------------------------------------------------------------------}

implementation

const
   npeepSize = 128;			{native peephole optimizer window size}
   nMaxPeep = 4;			{max # instructions needed to opt.}
   
type                       
                                        {65816 native code generation}
                                        {----------------------------}
   npeepRange = 1..npeepsize;           {subrange for native code peephole opt.}

   nativeType = record                  {native code instruction}
      opcode: integer;                  {op code}
      mode: addressingMode;             {addressing mode}
      operand: integer;                 {operand value}
      name: stringPtr;                  {operand label}
      flags: integer;                   {modifier flags}
      end;

   registerConditions = (regUnknown,regImmediate,regAbsolute,regLocal);
   registerType = record                {used to track register contents}
      condition: registerConditions;
      value: integer;
      lab: stringPtr;
      flags: integer;
      end;

var
                                        {register optimization}
                                        {---------------------}
   aRegister,                           {current register contents}
      xRegister,
      yRegister: registerType;
   lastRegOpcode: integer;              {opcode of last reg/flag-setting instr.}
   
                                        {native peephole optimization}
                                        {----------------------------}
   nleadOpcodes: set of 0..max_opcode;  {instructions that can start an opt.}
   nstopOpcodes: set of 0..max_opcode;  {instructions not involved in opt.}
   nnextspot: npeepRange;               {next empty spot in npeep}
   npeep: array[npeepRange] of nativeType; {native peephole array}

                                        {I/O files}
                                        {---------}
   fname1, fname2: gsosOutString;	{file names}
   nextSuffix: char;                    {next suffix character to use}


procedure GenSymbols (sym: ptr; doGlobals: integer); extern;

{ generate the symbol table                                     }

{--------------------------------------------------------------------------}

procedure LabelSearch {lab: integer; len, shift, disp: integer};

{ resolve a label reference                                     }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }
{       len - # bytes for the generated code                    }
{       shift - shift factor                                    }
{       disp - disp past the label                              }
{                                                               }
{ Note 1: maxlabel is reserved for use as the start of the      }
{       string space                                            }
{ Note 2: negative length indicates relative branch             }
{ Note 3: zero length indicates 2 byte addr -1                  }

var
   next: labelptr;                      {work pointer}

begin {LabelSearch}
if labeltab[lab].defined and (len < 0) and (shift = 0) and (disp = 0) then begin

   {handle a relative branch to a known disp}
   if len = -1 then
      CnOut(labeltab[lab].ival - long(pc).lsw - cbufflen + len)
   else
      CnOut2(labeltab[lab].ival - long(pc).lsw - cbufflen + len);
   end {if}
else begin
   if lab <> maxlabel then begin

      {handle a normal label reference}
      Purge;                            {empty the constant buffer}
      if len < 0 then begin
         len := -len;                   {generate a RELEXPR}
         Out(238);
         Out(len);
         Out2(len); Out2(0);
         end {if}
      else begin
         if isJSL then                  {generate a standard EXPR}
            Out(243)
         else
            Out(235);
         if len = 0 then
            Out(2)
         else
            Out(len);
         end; {else}
      end; {if}
   Out(135);                            {generate a relative offset from the seg. start}
   if not labeltab[lab].defined then begin
      next := pointer(Malloc(sizeof(labelEntry))); {value unknown: create a reference}
      next^.next := labeltab[lab].chain;
      labeltab[lab].chain := next;
      next^.addr := blkcnt;
      Out2(0);
      Out2(0);
      end {if}
   else {labeltab[lab].defined} begin
      Out2(labeltab[lab].ival);         {value known: write it}
      Out2(labeltab[lab].hval);
      end; {else}
   if len = 0 then begin
      Out(129);                         {subtract 1 from addr}
      Out2(1); Out2(0);
      Out(2);
      len := 2;
      end; {if}
   if disp <> 0 then begin
      Out(129);                         {add in the displacement}
      Out2(disp);
      if disp < 0 then
         Out2(-1)
      else
         Out2(0);
      Out(1);
      end; {if}
   if shift <> 0 then begin
      Out(129);                         {shift the address}
      Out2(-shift); if (shift > 0) then Out2(-1) else Out2(0);
      Out(7);
      end; {if}
   if lab <> maxlabel then              {if not a string, end the expression}
      Out(0);
   pc := pc+len;                        {update the pc}
   end; {else}
end; {LabelSearch}


procedure UpDate (lab: integer; labelValue: longint);

{ define a label                                                }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }
{       labelValue - displacement in seg where label is located }

var
   next: labelptr;                      {work pointer}

begin {UpDate}
if labeltab[lab].defined then
   Error(cge1)
else begin

   {define the label for future references}
   with labeltab[lab] do begin
      defined := true;
      val := labelValue;
      next := chain;
      end; {with}

   {resolve any forward references}
   if next <> nil then begin
      Purge;
      while next <> nil do begin
         segdisp := next^.addr;
         Out2(long(labelvalue).lsw);
         Out2(long(labelvalue).msw);
         blkcnt := blkcnt-4;
         next := next^.next;
         end; {while}
      segdisp := blkcnt;
      end; {if}
   end; {else}
end; {UpDate}


procedure WriteNative (opcode: integer; mode: addressingMode; operand: integer;
                      name: stringPtr; flags: integer);

{ write a native code instruction to the output file            }
{                                                               }
{ parameters:                                                   }
{       opcode - native op code                                 }
{       mode - addressing mode                                  }
{       operand - integer operand                               }
{       name - named operand                                    }
{       flags - operand modifier flags                          }

label 1;

type
   rkind = (k1,k2,k3,k4,k5);            {cnv record types}

var
   bp: ^byte;                           {byte pointer}
   ch: char;                            {temp storage for string constants}
   cns: realRec;                        {for converting reals to bytes}
   cnv: record                          {for converting double, real to bytes}
      case rkind of
         k1: (rval: real;);
         k2: (dval: double;);
         k3: (qval: longlong);
         k4: (eval: extended);
         k5: (ival1,ival2,ival3,ival4,ival5: integer;);
      end;
   count: integer;                      {number of constants to repeat}
   i,j,k: integer;                      {loop variables}
   lsegDisp: longint;                   {for backtracking while writing the    }
                                        { debugger's symbol table              }
   lval: longint;                       {temp storage for long constant}
   nptr: stringPtr;                     {pointer to a name}
   sptr: longstringPtr;                 {pointer to a string constant}


   procedure GenImmediate1;

   { generate a one byte immediate operand                      }

   begin {GenImmediate1}
   if (flags & stringReference) <> 0 then begin
      Purge;
      Out(235); Out(1);                 {one byte expression}
      Out(128);                         {current location ctr}
      Out(129); Out2(-16); Out2(-1);    {-16}
      Out(7);                           {bit shift}
      Out(0);                           {end of expr}
      pc := pc+1;
      end {if}
   else if (flags & localLab) <> 0 then
      LabelSearch(long(name).lsw, 1, ord((flags & shift16) <> 0)*16, operand)
   else if (flags & shift16) <> 0 then
      RefName(name, operand, 1, -16)
   else
      CnOut(operand);
   end; {GenImmediate1}


   procedure GenImmediate2;

   { generate a two byte immediate operand                      }

   begin {GenImmediate2}
   if (flags & stringReference) <> 0 then begin
      Purge;
      Out(235); Out(2);
      LabelSearch(maxLabel, 2, 0, 0);
      if operand <> 0 then begin
         Out(129);
         Out2(operand); if (operand < 0) then Out2(-1) else Out2(0);
         Out(1);
         end; {if}
      if (flags & shift16) <> 0 then begin
         Out(129);
         Out2(-16); Out2(-1);
         Out(7);
         end; {if}
      Out(0);
      end {if}
   else if (flags & shift8) <> 0 then
      RefName(name, operand, 2, -8)
   else if (flags & localLab) <> 0 then
      LabelSearch(long(name).lsw, 2, ord((flags & shift16) <> 0)*16, operand)
   else if (flags & shift16) <> 0 then
      RefName(name, operand, 2, -16)
   else if name = nil then
      CnOut2(operand)
   else
      RefName(name, operand, 2, 0);
   end; {GenImmediate2}


   procedure DefGlobal (private: integer);

   { define a global label                                      }
   {                                                            }
   { parameters:                                                }
   {    private - private flag                                  }

   var
      i: integer;                       {loop variable}

   begin {DefGlobal}
   Purge;
   Out(230);                            {global label definition}
   Out(ord(name^[0]));                  {write label name}
   for i := 1 to ord(name^[0]) do
      Out(ord(name^[i]));
   Out2(0);				{length attribute}
   Out(ord('N'));                       {type attribute: other directive}
   Out(private);                        {private or global?}
   end; {DefGlobal}


   function ShiftSize (flags: integer): integer;

   { Determine the shift size specified by flags.               }
   { (Positive means right shift, negative means left shift.)   }
   {                                                            }
   { parameters:                                                }
   {    flags - the flags                                       }

   begin {ShiftSize}
   if (flags & shift8) <> 0 then
      ShiftSize := 8
   else if (flags & shift16) <> 0 then
      ShiftSize := 16
   else if (flags & shiftLeft8) <> 0 then
      ShiftSize := -8
   else
      ShiftSize := 0;
   end; {ShiftSize}


begin {WriteNative}
{ writeln('WriteNative: ',opcode:4, ', mode=', ord(mode):1,
   ' operand=', operand:1);      {debug}
case mode of

   implied:
      CnOut(opcode);

   immediate: begin
      if opcode = d_bmov then
         GenImmediate1
      else begin
         if opcode = m_and_imm then
            if not longA then
               if operand = 255 then
                  goto 1;
         opcode := opcode & ~asmFlag;
         CnOut(opcode);
         if opcode = m_pea then
            GenImmediate2
         else if opcode in
            [m_adc_imm,m_and_imm,m_cmp_imm,m_eor_imm,m_lda_imm,m_ora_imm,
             m_sbc_imm,m_bit_imm] then
               if longA then
                 GenImmediate2
              else
                 GenImmediate1
         else if opcode in [m_rep,m_sep,m_cop] then begin
            GenImmediate1;
            if opcode = m_rep then begin
               if (operand & 32) <> 0 then longA := true;
               if (operand & 16) <> 0 then longI := true;
               end {if}
            else if opcode = m_sep then begin
               if (operand & 32) <> 0 then longA := false;
               if (operand & 16) <> 0 then longI := false;
               end; {else}
            end {else}
         else
            if longI then
               GenImmediate2
            else
               GenImmediate1;
         end; {else}
      end;

   longabs: begin
      CnOut(opcode);
      isJSL := (opcode & ~asmFlag) = m_jsl;     {allow for dynamic segs}
      if name = nil then
         if (flags & toolcall) <> 0 then begin
            CnOut2(0);
            CnOut(225);
            end {if}
         else
            LabelSearch(operand, 3, 0, 0)
      else
         if (flags & toolcall) <> 0 then begin
            CnOut2(long(name).lsw);
            CnOut(long(name).msw);
            end {if}
         else
            RefName(name, operand, 3, 0);
      isJSL := false;
      end;

   longabsolute: begin
      if opcode <> d_dcl then begin
         CnOut(opcode);
         i := 3;
         end {if}
      else
         i := 4;
      if (flags & localLab) <> 0 then
         LabelSearch(long(name).lsw, i, 0, operand)
      else if (flags & constantOpnd) <> 0 then begin
         lval := ord4(name);
         CnOut2(long(lval).lsw);
         if opcode = d_dcl then
            CnOut2(long(lval).msw)
         else
            CnOut(long(lval).msw);
         end {else if}
      else if name <> nil then
         RefName(name, operand, i, 0)
      else begin
         CnOut2(operand);
         CnOut(0);
         if opcode = d_dcl then
            CnOut(0);
         end; {else}
      end;

   absolute: begin
      if opcode <> d_dcw then
         CnOut(opcode);
      if (flags & localLab) <> 0 then
         LabelSearch(long(name).lsw, 2, 0, operand)
      else if name <> nil then
         RefName(name, operand, 2, 0)
      else if (flags & constantOpnd) <> 0 then
         CnOut2(operand)
      else
         LabelSearch(operand, 2, 0, 0);
      end;

   direct: begin
      if opcode <> d_dcb then
         CnOut(opcode);
      if (flags & localLab) <> 0 then
         LabelSearch(long(name).lsw, 1, 0, operand)
      else if name <> nil then
         RefName(name, operand, 1, 0)
      else
         CnOut(operand);
      end;

   longrelative: begin
      CnOut(opcode);
      LabelSearch(operand, -2, 0, 0);
      end;

   relative: begin
      CnOut(opcode);
      LabelSearch(operand, -1, 0, 0);
      end;

   gnrLabel:
      if name = nil then
         UpDate(operand, pc+cbufflen)
      else begin
         DefGlobal((flags >> 5) & 1);
         if operand <> 0 then begin
            Out(241);
            Out2(operand);
            Out2(0);
            pc := pc+operand;
            end; {if}
        end; {else}

   gnrSpace:
      if operand <> 0 then begin
         Out(241);
         Out2(operand);
         Out2(0);
         pc := pc+operand;
         end; {if}

   gnrConstant: begin
      if icptr(name)^.optype = cgString then
         count := 1
      else
         count := icptr(name)^.q;
      for i := 1 to count do
         case icptr(name)^.optype of
            cgByte,cgUByte      : CnOut(icptr(name)^.r);
            cgWord,cgUWord      : CnOut2(icptr(name)^.r);
            cgLong,cgULong      : begin
                                  lval := icptr(name)^.lval;
                                  CnOut2(long(lval).lsw);
                                  CnOut2(long(lval).msw);
                                  end;
            cgQuad,cgUQuad      : begin
                                  cnv.qval := icptr(name)^.qval;
                                  CnOut2(cnv.ival1);
                                  CnOut2(cnv.ival2);
                                  CnOut2(cnv.ival3);
                                  CnOut2(cnv.ival4);
                                  end;
            cgReal              : begin
                                  cnv.rval := icptr(name)^.rval;
                                  CnOut2(cnv.ival1);
                                  CnOut2(cnv.ival2);
                                  end;
            cgDouble            : begin
                                  cnv.dval := icptr(name)^.rval;
                                  CnOut2(cnv.ival1);
                                  CnOut2(cnv.ival2);
                                  CnOut2(cnv.ival3);
                                  CnOut2(cnv.ival4);
                                  end;
            cgComp              : begin
                                  cns.itsReal := icptr(name)^.rval;
                                  CnvSC(cns);
                                  for j := 1 to 8 do
                                     CnOut(cns.inCOMP[j]);
                                  end;
            cgExtended          : begin
                                  cnv.eval := icptr(name)^.rval;
                                  CnOut2(cnv.ival1);
                                  CnOut2(cnv.ival2);
                                  CnOut2(cnv.ival3);
                                  CnOut2(cnv.ival4);
                                  CnOut2(cnv.ival5);
                                  end;
            cgString            : begin
                                  if not icptr(name)^.isByteSeq then begin
                                     sptr := icptr(name)^.str;
                                     for j := 1 to sptr^.length do
                                        CnOut(ord(sPtr^.str[j]));
                                     end {if}
                                  else begin
                                     lval := 0;
                                     while lval < icptr(name)^.len do begin
                                        bp := pointer(
                                           ord4(icptr(name)^.data) + lval);
                                        CnOut(bp^);
                                        lval := lval + 1;
                                        end;
                                     end; {else}
                                  end;
            ccPointer           : begin
                                  if icptr(name)^.lab <> nil then begin
                                     Purge;
                                     Out(235);
                                     Out(4);
                                     Out(131);
                                     pc := pc+4;
                                     nptr := icptr(name)^.lab;
                                     for j := 0 to ord(nptr^[0]) do
                                        Out(ord(nptr^[j]));
                                     lval := icptr(name)^.pVal;
                                     if lval <> 0 then begin
                                        Out(129);
                                        Out2(long(lval).lsw);
                                        Out2(long(lval).msw);
                                        Out(2-icptr(name)^.r);
                                        end; {if}
                                     Out(0);
                                     end {if}
                                  else begin
                                     lval := icptr(name)^.pVal;
                                     if icptr(name)^.r = 1 then
                                        operand := stringSize+long(lval).lsw
                                     else
                                        operand := stringSize-long(lval).lsw;
                                     flags := stringReference;
                                     GenImmediate2;
                                     flags := stringReference+shift16;
                                     GenImmediate2;
                                     sptr := icptr(name)^.pStr;
                                     j := sptr^.length;
                                     if maxString-stringSize >= j then begin
                                        for k := 1 to j do
                                           stringSpace^[k+stringSize] :=
                                              sptr^.str[k];
                                        stringSize := stringSize+j;
                                        end {if}
                                     else
                                        Error(cge3);
                                     end; {else}
                                  end;
            otherwise           : Error(cge1);
            end; {case}
      end;

   genAddress: begin
      if opcode < 256 then              {includes opcodes with asmFlag}
         CnOut(opcode);
      if (flags & stringReference) <> 0 then begin
         Purge;
         Out(235);
         Out(2);
         LabelSearch(maxLabel,2,0,0);
         if operand <> 0 then begin
            Out(129);
            Out2(operand);
            Out2(0);
            Out(1);
            end; {if}
         if (flags & shift16) <> 0 then begin
            Out(129);
            Out2(-16);
            Out2(-1);
            Out(7);
            end; {if}
         Out(0);
         end {if}
      else if operand = 0 then begin
         CnOut(0);
         CnOut(0);
         end {else if}
      else if (flags & shift16) <> 0 then
         if longA then
            LabelSearch(operand, 2, 16, 0)
         else
            LabelSearch(operand, 1, 16, 0)
      else if (flags & subtract1) <> 0 then
         LabelSearch(operand, 0, ShiftSize(flags), 0)
      else
         LabelSearch(operand, 2, 0, 0);
      end;

   special:
      if opcode = d_pin then begin
         segDisp := 36;
         out2(long(pc).lsw+cBuffLen);
         blkCnt := blkCnt-2;
         segDisp := blkCnt;
         end {if}
      else if opcode = d_sym then begin
         CnOut(m_cop);
         CnOut(5);
         Purge;
         lsegDisp := segDisp+1;
         CnOut2(0);
         symLength := 0;
         GenSymbols(pointer(name), operand);
         segDisp := lSegDisp;
         out2(symLength);
         blkCnt := blkCnt-2;
         segDisp := blkCnt;
         end {else if}
      else {d_wrd}
         CnOut2(operand);

   otherwise: Error(cge1);

   end; {case}
1:
end; {WriteNative}


procedure CheckRegisters(p_opcode: integer; p_mode: addressingMode;
                    p_operand: integer; p_name: stringPtr; p_flags: integer);

{ write a native code instruction to the output file            }
{                                                               }
{ parameters:                                                   }
{       p_opcode - native op code                               }
{       p_mode - addressing mode                                }
{       p_operand - integer operand                             }
{       p_name - named operand                                  }
{       p_flags - operand modifier flags                        }

label 1,2,3;

   function NZMatchA: boolean;
   
   { Are the N and Z flags known to match the value in A?       }
   {                                                            }
   { Note: Assumes long registers                               }
   
   begin {NZMatchA}
   NZMatchA := lastRegOpcode in
      [m_adc_abs,m_adc_dir,m_adc_imm,m_adc_s,m_adc_indl,m_adc_indly,
      m_and_abs,m_and_dir,m_and_imm,m_and_s,m_and_indl,m_and_indly,m_asl_a,
      m_dea,m_eor_abs,m_eor_dir,m_eor_imm,m_eor_s,m_eor_indl,m_eor_indly,
      m_ina,m_lda_abs,m_lda_absx,m_lda_dir,m_lda_dirx,m_lda_imm,m_lda_indl,
      m_lda_indly,m_lda_long,m_lda_longx,m_lda_s,m_lsr_a,m_ora_abs,m_ora_dir,
      m_ora_dirX,m_ora_imm,m_ora_long,m_ora_longX,m_ora_s,m_ora_indl,
      m_ora_indly,m_pla,m_rol_a,m_ror_a,m_sbc_abs,m_sbc_dir,m_sbc_imm,m_sbc_s,
      m_sbc_indl,m_sbc_indly,m_tax,m_tay,m_tcd,m_tdc,m_txa,m_tya];
   end; {NZMatchA}

begin {CheckRegisters}
case p_opcode of
   m_adc_abs,m_adc_dir,m_adc_imm,m_adc_s,m_and_abs,m_and_dir,m_and_imm,
   m_and_s,m_asl_a,m_dea,m_eor_abs,m_eor_dir,m_eor_imm,m_eor_s,m_lda_absx,
   m_lda_dirx,m_lda_indl,m_lda_indly,m_lda_longx,m_lda_s,m_lsr_a,m_ora_abs,
   m_ora_dir,m_ora_dirX,m_ora_imm,m_ora_long,m_ora_longX,m_ora_s,m_pla,
   m_sbc_abs,m_sbc_dir,m_sbc_imm,m_sbc_s,m_tdc,m_tsc,m_adc_indl,m_adc_indly,
   m_and_indl,m_and_indly,m_ora_indl,m_ora_indly,m_sbc_indl,m_sbc_indly,
   m_eor_indl,m_eor_indly,m_rol_a,m_ror_a:
      aRegister.condition := regUnknown;

   m_ldy_absX,m_ldy_dirX,m_ply:
      yRegister.condition := regUnknown;

   m_plx:
      xRegister.condition := regUnknown;

   m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_bvc,m_bvs,
   m_pha,m_phb,m_phd,m_php,m_phx,m_phy,m_pei_dir,m_tcs:
      goto 3;
   
   m_bra,m_brl,m_clc,m_cmp_abs,m_cmp_dir,m_cmp_imm,m_cmp_s,m_cmp_indl,
   m_cmp_indly,m_cpx_imm,m_jml,m_jmp_indX,m_plb,m_rtl,m_rts,m_sec,d_add,d_pin,
   m_cpx_abs,m_cpx_dir,m_cpy_imm,m_cmp_dirx,m_plp,m_cop,d_wrd:    ;

   m_pea: begin
      if aRegister.condition = regImmediate then
         if aRegister.value = p_operand then
            if aRegister.lab = p_name then
               if aRegister.flags = p_flags then
        	  if longA then begin
        	     p_opcode := m_pha;
        	     p_mode := implied;
        	     goto 2;
        	     end; {if}
      if longI then begin
	 if xRegister.condition = regImmediate then
            if xRegister.value = p_operand then
               if xRegister.lab = p_name then
        	  if xRegister.flags = p_flags then begin
        	     p_opcode := m_phx;
        	     p_mode := implied;
        	     goto 2;
        	     end; {if}
	 if yRegister.condition = regImmediate then
            if yRegister.value = p_operand then
               if yRegister.lab = p_name then
        	  if yRegister.flags = p_flags then begin
        	     p_opcode := m_phy;
        	     p_mode := implied;
        	     goto 2;
        	     end; {if}
         end; {if}
      goto 3;
      end;

   m_sta_s: begin
      if aRegister.condition = regLocal then
         aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         yRegister.condition := regUnknown;
      goto 3;
      end;
   
   m_pld,m_tcd: begin
      if aRegister.condition = regLocal then
         aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         yRegister.condition := regUnknown;
      end;

   m_sta_indl,m_sta_indlY: begin
      if aRegister.condition <> regImmediate then
         aRegister.condition := regUnknown;
      if xRegister.condition <> regImmediate then
         xRegister.condition := regUnknown;
      if yRegister.condition <> regImmediate then
         yRegister.condition := regUnknown;
      goto 3;
      end;

   m_sta_absX,m_stz_absX,m_sta_longX: begin
      if aRegister.condition = regAbsolute then
         if aRegister.lab = p_name then
            aRegister.condition := regUnknown;
      if xRegister.condition = regAbsolute then
         if xRegister.lab = p_name then
            xRegister.condition := regUnknown;
      if yRegister.condition = regAbsolute then
         if yRegister.lab = p_name then
            yRegister.condition := regUnknown;
      goto 3;
      end;

   m_dec_abs,m_inc_abs,m_tsb_abs: begin
      if aRegister.condition = regAbsolute then
         if aRegister.lab = p_name then
            if aRegister.value = p_operand then
               aRegister.condition := regUnknown;
      if xRegister.condition = regAbsolute then
         if xRegister.lab = p_name then
            if xRegister.value = p_operand then
               xRegister.condition := regUnknown;
      if yRegister.condition = regAbsolute then
         if yRegister.lab = p_name then
            if yRegister.value = p_operand then
               yRegister.condition := regUnknown;
      end;
   
   m_sta_abs,m_stx_abs,m_sty_abs,m_sta_long,m_stz_abs: begin
      if aRegister.condition = regAbsolute then
         if aRegister.lab = p_name then
            if aRegister.value = p_operand then
               if not (p_opcode in [m_sta_abs,m_sta_long]) then
                  aRegister.condition := regUnknown;
      if xRegister.condition = regAbsolute then
         if xRegister.lab = p_name then
            if xRegister.value = p_operand then
               if p_opcode <> m_stx_abs then
                  xRegister.condition := regUnknown;
      if yRegister.condition = regAbsolute then
         if yRegister.lab = p_name then
            if yRegister.value = p_operand then
               if p_opcode <> m_sty_abs then
                  yRegister.condition := regUnknown;
      goto 3;
      end;

   m_dec_dir,m_inc_dir,m_tsb_dir: begin
      if aRegister.condition = regLocal then
         if aRegister.value = p_operand then
            aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         if xRegister.value = p_operand then
            xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         if yRegister.value = p_operand then
            yRegister.condition := regUnknown;
      end;
   
   m_sta_dir,m_stx_dir,m_sty_dir,m_stz_dir: begin
      if aRegister.condition = regLocal then
         if aRegister.value = p_operand then
            if p_opcode <> m_sta_dir then
               aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         if xRegister.value = p_operand then
            if p_opcode <> m_stx_dir then
               xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         if yRegister.value = p_operand then
            if p_opcode <> m_sty_dir then
               yRegister.condition := regUnknown;
      goto 3;
      end;

   m_dec_dirX,m_inc_dirX: begin
      if aRegister.condition = regLocal then
         if aRegister.value >= p_operand-1 then
            aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         if xRegister.value >= p_operand-1 then
            xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         if yRegister.value >= p_operand-1 then
            yRegister.condition := regUnknown;
      end;
   
   m_sta_dirX,m_sty_dirX,m_stz_dirX: begin
      if aRegister.condition = regLocal then
         if aRegister.value >= p_operand-1 then
            aRegister.condition := regUnknown;
      if xRegister.condition = regLocal then
         if xRegister.value >= p_operand-1 then
            xRegister.condition := regUnknown;
      if yRegister.condition = regLocal then
         if yRegister.value >= p_operand-1 then
            yRegister.condition := regUnknown;
      goto 3;
      end;

   m_dex:
      if xRegister.condition = regImmediate then
         xRegister.value := xRegister.value-1
      else
         xRegister.condition := regUnknown;

   m_dey:
      if yRegister.condition = regImmediate then
         yRegister.value := yRegister.value-1
      else
         yRegister.condition := regUnknown;

   m_ina:
      if aRegister.condition = regImmediate then
         aRegister.value := aRegister.value+1
      else
         aRegister.condition := regUnknown;

   m_inx:
      if xRegister.condition = regImmediate then
         xRegister.value := xRegister.value+1
      else
         xRegister.condition := regUnknown;

   m_iny:
      if yRegister.condition = regImmediate then
         yRegister.value := yRegister.value+1
      else
         yRegister.condition := regUnknown;

   otherwise,
   m_jsl,m_mvn,m_rep,m_sep,d_lab,d_end,d_bmov,d_cns: begin
      aRegister.condition := regUnknown;
      xRegister.condition := regUnknown;
      yRegister.condition := regUnknown;
      end;

   m_lda_abs,m_lda_long: begin
      if (aRegister.condition = regAbsolute) and
         (aRegister.value = p_operand) and
         (aRegister.lab = p_name) then
         goto 1
      else if longA = longI then begin
         if (xRegister.condition = regAbsolute) and
            (xRegister.value = p_operand) and
            (xRegister.lab = p_name) then begin
            p_opcode := m_txa;
            p_mode := implied;
            aRegister := xRegister;
            goto 2;
            end {if}
         else if (yRegister.condition = regAbsolute) and
            (yRegister.value = p_operand) and
            (yRegister.lab = p_name) then begin
            p_opcode := m_tya;
            p_mode := implied;
            aRegister := yRegister;
            goto 2;
            end; {else if}
         end;
      aRegister.condition := regAbsolute;
      aRegister.value := p_operand;
      aRegister.lab := p_name;
      aRegister.flags := p_flags;
      end;

   m_lda_dir: begin
      if (aRegister.condition = regLocal) and
         (aRegister.value = p_operand) then
         goto 1
      else if longA = longI then begin
         if (xRegister.condition = regLocal) and
            (xRegister.value = p_operand) then begin
            p_opcode := m_txa;
            p_mode := implied;
            aRegister := xRegister;
            goto 2;
            end {if}
         else if (yRegister.condition = regLocal) and
            (yRegister.value = p_operand) then begin
            p_opcode := m_tya;
            p_mode := implied;
            aRegister := yRegister;
            goto 2;
            end; {else if}
         end; {else if}
      aRegister.condition := regLocal;
      aRegister.value := p_operand;
      aRegister.flags := p_flags;
      end;

   m_lda_imm: begin
      if (aRegister.condition = regImmediate) and
         (aRegister.value = p_operand) and
         (aRegister.lab = p_name) and
         (aRegister.flags = p_flags) then
         goto 1
      else if longA = longI then begin
         if (xRegister.condition = regImmediate) and
            (xRegister.value = p_operand) and
            (xRegister.lab = p_name) and
            (xRegister.flags = p_flags) then begin
            p_opcode := m_txa;
            p_mode := implied;
            aRegister := xRegister;
            goto 2;
            end {if}
         else if (yRegister.condition = regImmediate) and
            (yRegister.value = p_operand) and
            (yRegister.lab = p_name) and
            (yRegister.flags = p_flags) then begin
            p_opcode := m_tya;
            p_mode := implied;
            aRegister := yRegister;
            goto 2;
            end; {else if}
         end; {else if}
      if (aRegister.condition = regImmediate) and
         (aRegister.lab = p_name) and
         (aRegister.flags = p_flags) then
         if aRegister.value = (p_operand + 1) then begin
            p_opcode := m_dea;
            p_mode := implied;
            aRegister.value := p_operand;
            goto 2;
            end {if}   
         else if aRegister.value = (p_operand - 1) then begin
            p_opcode := m_ina;
            p_mode := implied;
            aRegister.value := p_operand;
            goto 2;
            end; {else if}
      aRegister.condition := regImmediate;
      aRegister.value := p_operand;
      aRegister.flags := p_flags;
      aRegister.lab := p_name;
      end;

   m_ldx_abs: begin
      if (xRegister.condition = regAbsolute) and
         (xRegister.value = p_operand) and
         (xRegister.lab = p_name) then
         goto 1
      else if (aRegister.condition = regAbsolute) and
         (aRegister.value = p_operand) and
         (aRegister.lab = p_name) and
         (longA = longI) then begin
         p_opcode := m_tax;
         p_mode := implied;
         xRegister := aRegister;
         end {else if}
      else if (yRegister.condition = regAbsolute) and
         (yRegister.value = p_operand) and
         (yRegister.lab = p_name) then begin
         p_opcode := m_tyx;
         p_mode := implied;
         xRegister := yRegister;
         end {else if}
      else begin
         xRegister.condition := regAbsolute;
         xRegister.value := p_operand;
         xRegister.lab := p_name;
         xRegister.flags := p_flags;
         end; {else}
      end;

   m_ldx_dir: begin
      if (xRegister.condition = regLocal) and
         (xRegister.value = p_operand) then
         goto 1
      else if (aRegister.condition = regLocal) and
         (aRegister.value = p_operand) and
         (longA = longI) then begin
         p_opcode := m_tax;
         p_mode := implied;
         xRegister := aRegister;
         end {else if}
      else if (yRegister.condition = regLocal) and
         (yRegister.value = p_operand) then begin
         p_opcode := m_tyx;
         p_mode := implied;
         xRegister := yRegister;
         end {else if}
      else begin
         xRegister.condition := regLocal;
         xRegister.value := p_operand;
         xRegister.flags := p_flags;
         end; {else}
      end;

   m_ldx_imm: begin
      if (xRegister.condition = regImmediate) and
         (xRegister.value = p_operand) and
         (xRegister.lab = p_name) and
         (xRegister.flags = p_flags) then
         goto 1
      else if (aRegister.condition = regImmediate) and
         (aRegister.value = p_operand) and
         (longA = longI) and
         (aRegister.lab = p_name) and
         (aRegister.flags = p_flags) then begin
         p_opcode := m_tax;
         p_mode := implied;
         xRegister := aRegister;
         end {else}
      else if (yRegister.condition = regImmediate) and
         (yRegister.value = p_operand) and
         (yRegister.lab = p_name) and
         (yRegister.flags = p_flags) then begin
         p_opcode := m_tyx;
         p_mode := implied;
         xRegister := yRegister;
         end {else if}
      else begin
	 if (xRegister.condition = regImmediate) and
            (xRegister.lab = p_name) and
            (xRegister.flags = p_flags) then
            if xRegister.value = (p_operand + 1) then begin
               p_opcode := m_dex;
               p_mode := implied;
               xRegister.value := p_operand;
               goto 2;
               end {if}   
            else if xRegister.value = (p_operand - 1) then begin
               p_opcode := m_inx;
               p_mode := implied;
               xRegister.value := p_operand;
               goto 2;
               end; {else if}
         xRegister.condition := regImmediate;
         xRegister.value := p_operand;
         xRegister.flags := p_flags;
         xRegister.lab := p_name;
         end; {else}
      end;

   m_ldy_abs: begin
      if (yRegister.condition = regAbsolute) and
         (yRegister.value = p_operand) and
         (yRegister.lab = p_name) then
         goto 1
      else if (aRegister.condition = regAbsolute) and
         (aRegister.value = p_operand) and
         (aRegister.lab = p_name) and
         (longA = longI) then begin
         p_opcode := m_tay;
         p_mode := implied;
         yRegister := aRegister;
         end {else if}
      else if (xRegister.condition = regAbsolute) and
         (xRegister.value = p_operand) and
         (xRegister.lab = p_name) then begin
         p_opcode := m_txy;
         p_mode := implied;
         yRegister := xRegister;
         end {else if}
      else begin
         yRegister.condition := regAbsolute;
         yRegister.value := p_operand;
         yRegister.lab := p_name;
         yRegister.flags := p_flags;
         end; {else}
      end;

   m_ldy_dir: begin
      if (yRegister.condition = regLocal) and
         (yRegister.value = p_operand) then
         goto 1
      else if (aRegister.condition = regLocal) and
         (aRegister.value = p_operand) and
         (longA = longI) then begin
         p_opcode := m_tay;
         p_mode := implied;
         yRegister := aRegister;
         end {else if}
      else if (xRegister.condition = regLocal) and
         (xRegister.value = p_operand) then begin
         p_opcode := m_txy;
         p_mode := implied;
         yRegister := xRegister;
         end {else if}
      else begin
         yRegister.condition := regLocal;
         yRegister.value := p_operand;
         yRegister.flags := p_flags;
         end; {else}
      end;

   m_ldy_imm: begin
      if (yRegister.condition = regImmediate) and
         (yRegister.value = p_operand) and
         (yRegister.lab = p_name) and
         (yRegister.flags = p_flags) then
         goto 1
      else if (aRegister.condition = regImmediate) and
         (aRegister.value = p_operand) and
         (aRegister.flags = p_flags) and
         (aRegister.lab = p_name) and
         (longA = longI) then begin
         p_opcode := m_tay;
         p_mode := implied;
         yRegister := aRegister;
         end {else if}
      else if (xRegister.condition = regImmediate) and
         (xRegister.value = p_operand) and
         (xRegister.lab = p_name) and
         (xRegister.flags = p_flags) then begin
         p_opcode := m_txy;
         p_mode := implied;
         yRegister := xRegister;
         end {else if}
      else begin
	 if (yRegister.condition = regImmediate) and
            (yRegister.lab = p_name) and
            (yRegister.flags = p_flags) then
            if yRegister.value = (p_operand + 1) then begin
               p_opcode := m_dey;
               p_mode := implied;
               yRegister.value := p_operand;
               goto 2;
               end {if}   
            else if yRegister.value = (p_operand - 1) then begin
               p_opcode := m_iny;
               p_mode := implied;
               yRegister.value := p_operand;
               goto 2;
               end; {else if}
         yRegister.condition := regImmediate;                   
         yRegister.value := p_operand;
         yRegister.flags := p_flags;
         yRegister.lab := p_name;
         end; {else}
      end;

   m_tax: begin
      if (p_flags & forFlags) <> 0 then begin
         if longA then
            if longI then
               if NZMatchA then
                  goto 1;
         end {if}
      else if aRegister.condition <> regUnknown then
         if aRegister.condition = xRegister.condition then
            if aRegister.value = xRegister.value then
               if aRegister.flags = xRegister.flags then
                  if aRegister.condition <> regAbsolute then
                     goto 1
                  else if aRegister.lab = xRegister.lab then
                     goto 1;
      xRegister := aRegister;
      end;

   m_tay: begin
      if (p_flags & forFlags) <> 0 then begin
         if longA then
            if longI then
               if NZMatchA then
                  goto 1;
         end {if}
      else if aRegister.condition <> regUnknown then
         if aRegister.condition = yRegister.condition then
            if aRegister.value = yRegister.value then
               if aRegister.flags = yRegister.flags then
                  if aRegister.condition <> regAbsolute then
                     goto 1
                  else if aRegister.lab = yRegister.lab then
                     goto 1;
      yRegister := aRegister;
      end;

   m_txa: begin
      if xRegister.condition <> regUnknown then
         if xRegister.condition = aRegister.condition then
            if xRegister.value = aRegister.value then
               if xRegister.flags = aRegister.flags then
                  if xRegister.condition <> regAbsolute then
                     goto 1
                  else if xRegister.lab = aRegister.lab then
                     goto 1;
      aRegister := xRegister;
      end;

   m_txy: begin
      if xRegister.condition <> regUnknown then
         if xRegister.condition = yRegister.condition then
            if xRegister.value = yRegister.value then
               if xRegister.flags = yRegister.flags then
                  if xRegister.condition <> regAbsolute then
                     goto 1
                  else if xRegister.lab = yRegister.lab then
                     goto 1;
      yRegister := xRegister;
      end;

   m_tya: begin
      if yRegister.condition <> regUnknown then
         if yRegister.condition = aRegister.condition then
            if yRegister.value = aRegister.value then
               if yRegister.flags = aRegister.flags then
                  if yRegister.condition <> regAbsolute then
                     goto 1
                  else if yRegister.lab = aRegister.lab then
                     goto 1;
      aRegister := yRegister;
      end;

   m_tyx: begin
      if yRegister.condition <> regUnknown then
         if yRegister.condition = xRegister.condition then
            if yRegister.value = xRegister.value then
               if yRegister.flags = xRegister.flags then
                  if yRegister.condition <> regAbsolute then
                     goto 1
                  else if yRegister.lab = xRegister.lab then
                     goto 1;
      xRegister := yRegister;
      end;
   end; {case}
2:                                      {emit the instruction normally}
lastRegOpcode := p_opcode;
3:                                      {branch here for instructions that}
                                        {do not modify A/X/Y or flags     }
WriteNative(p_opcode, p_mode, p_operand, p_name, p_flags);
1:                                      {branch here to skip the instruction}
end; {CheckRegisters}


procedure Remove (ns: integer); extern;

{ Remove the instruction ns from the peephole array             }
{                                                               }
{ parameters:                                                   }
{       ns - index of the instruction to remove                 }


function Short (n, lab: integer): boolean; extern;

{ see if a label is within range of a one-byte relative branch  }
{                                                               }
{ parameters:                                                   }
{       n - index to branch instruction                         }
{       lab - label number                                      }

{--------------------------------------------------------------------------}

procedure EndSeg;

{ close out the current segment                                 }

var
   i: integer;

begin {EndSeg}
Purge;                                  {dump constant buffer}
if stringsize <> 0 then begin           {define string space}
   UpDate(maxLabel, pc);                {define the local label for the string space}
   for i := 1 to stringsize do
      CnOut(ord(stringspace^[i]));
   Purge;
   end; {if}
Out(0);                                 {end the segment}
segDisp := 8;                           {update header}
Out2(long(pc).lsw);
Out2(long(pc).msw);
if pc > $00010000 then
   if currentSegment <> '~ARRAYS   ' then
      Error(184);
blkcnt := blkcnt-4;                     {purge the segment to disk}
segDisp := blkcnt;
CloseSeg;
end; {EndSeg}


procedure GenNative {p_opcode: integer; p_mode: addressingMode;
                     p_operand: integer; p_name: stringPtr; p_flags: integer};

{ write a native code instruction to the output file            }
{                                                               }
{ parameters:                                                   }
{       p_opcode - native op code                               }
{       p_mode - addressing mode                                }
{       p_operand - integer operand                             }
{       p_name - named operand                                  }
{       p_flags - operand modifier flags                        }

var
   done: boolean;                       {loop termination}
   llongA: boolean;                     {for tracking A size during opt.}
   i: integer;                          {index}
   op: integer;                         {temp storage for opcode}


   procedure Purge;

   { Empty the peephole array                                   }

   begin {Purge}
   while nnextSpot > 1 do begin
      if registers then
         CheckRegisters(npeep[1].opcode, npeep[1].mode, npeep[1].operand,
            npeep[1].name, npeep[1].flags)
      else
         WriteNative(npeep[1].opcode, npeep[1].mode, npeep[1].operand,
            npeep[1].name, npeep[1].flags);
      Remove(1);
      end; {while}
   end; {Purge}


   procedure Optimize(ns: integer; longA: boolean);

   { Optimize the instruction starting at ns                    }
   {                                                            }
   { parameters:                                                }
   {    ns - index of instruction  to check for optimization    }
   {    longA - is the accumulator long?                        }

   label 1;

   var
      tn: nativeType;			{temp operation}


      function ASafe (ns: integer): boolean;

      { See if it is safe to skip loading the A register        }
      {                                                         }
      { parameters:                                             }
      {    ns - starting index                                  }

      label 1;

      var
         i: integer;                    {loop variable}
         opcode: integer;               {copy of current op code}

      begin {ASafe}
      ASafe := false;
      for i := ns to nnextSpot-1 do begin
         opcode := npeep[i].opcode;
         if opcode in
            [m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_bra,m_brl,m_bvc,m_bvs,m_jml,
             m_jmp_indX,m_jsl,m_lda_abs,m_lda_absx,m_lda_dir,m_lda_dirx,
             m_lda_imm,m_lda_indl,m_lda_indly,m_lda_long,m_lda_longx,m_lda_s,
             m_pla,m_rtl,m_rts,m_tdc,m_txa,m_tya,m_tsc,d_end,d_bmov,
             d_add,d_pin,d_wrd,d_sym,d_cns] then begin
            ASafe := true;
            goto 1;
            end {if}
         else if not (opcode in
            [m_clc,m_cop,m_cpx_abs,m_cpx_dir,m_cpx_imm,m_dec_abs,m_dec_absX,
             m_dec_dir,m_dec_dirX,m_dex,m_dey,m_inc_abs,m_inc_absX,m_inc_dir,
             m_inc_dirX,m_inx,m_iny,m_ldx_abs,m_ldx_dir,m_ldx_imm,m_ldy_abs,
             m_ldy_absX,m_ldy_dir,m_ldy_dirX,m_ldy_imm,m_pea,m_pei_dir,m_phb,
             m_phd,m_phx,m_phy,m_php,m_plb,m_pld,m_plx,m_ply,m_plp,m_rep,
             m_sec,m_sep,m_stx_dir,m_stx_abs,m_sty_abs,m_sty_dir,m_sty_dirX,
             m_stz_abs,m_stz_absX,m_stz_dir,m_stz_dirX,m_tsx,m_txs,m_txy,
             m_tyx,d_lab]) then
            goto 1;
         end; {for}
1:
      end; {ASafe}


      function SignExtension (ns: integer): boolean;

      { See if the pattern is a sign extension			}
      {								}
      { Parameters:						}
      {    ns - start of suspected pattern			}
      {								}
      { Returns: true for a sign extension, else false		}

      begin {SignExtension}
      SignExtension := false;
      if npeep[ns].opcode = m_ldx_imm then
         if npeep[ns].operand = 0 then
            if npeep[ns+1].opcode = m_tay then
               if npeep[ns+2].opcode = m_bpl then
                  if npeep[ns+3].opcode = m_dex then
                     SignExtension := true;
      end; {SignExtension}


   begin {Optimize}
   with npeep[ns] do
      case opcode of

         m_and_imm:
            if npeep[ns+1].opcode = m_and_imm then begin
               operand := operand & npeep[ns+1].operand;
               Remove(ns+1);
               end; {if}

         m_eor_imm:
            if npeep[ns+1].opcode = m_eor_imm then begin
               operand := operand ! npeep[ns+1].operand;
               Remove(ns+1);
               end; {if}

         m_ora_imm:
            if npeep[ns+1].opcode = m_ora_imm then begin
               operand := operand | npeep[ns+1].operand;
               Remove(ns+1);
               end; {if}


         m_asl_a:
            if npeep[ns+1].opcode = m_tay then
               if npeep[ns+2].opcode = m_iny then
                  if npeep[ns+3].opcode = m_iny then begin
                     opcode := m_ina;
                     npeep[ns+1].opcode := m_asl_a;
                     npeep[ns+2].opcode := m_tay;
                     Remove(ns+3);
                     end; {if}

         m_bcs,m_beq,m_bne,m_bmi,m_bpl,m_bcc:
            if npeep[ns+2].opcode = d_lab then begin
               if npeep[ns+2].operand = operand then
                  if npeep[ns+1].opcode = m_brl then begin
                     if Short(ns,npeep[ns+1].operand) then begin
                        operand := npeep[ns+1].operand;
                        Remove(ns+1);
                        if opcode = m_bcs then
                           opcode := m_bcc
                        else if opcode = m_beq then
                           opcode := m_bne
                        else if opcode = m_bne then
                           opcode := m_beq
                        else if opcode = m_bmi then
                           opcode := m_bpl
                        else if opcode = m_bcc then
                           opcode := m_bcs
                        else
                           opcode := m_bmi;
                        end; {if}
                     end {if m_brl}
                  else if npeep[ns+1].opcode = m_bra then begin
                     operand := npeep[ns+1].operand;
                     Remove(ns+1); Remove(ns+1);
                     if opcode = m_bcs then
                        opcode := m_bcc
                     else if opcode = m_beq then
                        opcode := m_bne
                     else if opcode = m_bne then
                        opcode := m_beq
                     else if opcode = m_bmi then
                        opcode := m_bpl
                     else if opcode = m_bcc then
                        opcode := m_bcs
                     else
                        opcode := m_bmi;
                     end {else if m_bra}
                  else if npeep[ns+3].opcode in [m_bra,m_brl] then
                     if Short(ns,npeep[ns+3].operand) then begin
                        operand := npeep[ns+3].operand;
                        if (npeep[ns+2].flags & labelUsedOnce) <> 0 then
                           Remove(ns+2);
                        end; {if}
               end {if}
            else if npeep[ns+3].opcode = d_lab then
               if npeep[ns+3].operand = operand then
                  if npeep[ns+4].opcode in [m_bra,m_brl] then
                     if Short(ns,npeep[ns+4].operand) then begin
                        operand := npeep[ns+4].operand;
                        if (npeep[ns+3].flags & labelUsedOnce) <> 0 then
                           Remove(ns+3);
                        end; {if}

         m_brl:
            if Short(ns,operand) then begin
               opcode := m_bra;
               mode := relative;
               didOne := true;
               end; {if}

         {disabled because current codegen does not produce this sequence}
         {m_bvs:
            if npeep[ns+2].opcode = d_lab then
               if npeep[ns+2].operand = operand then
                  if npeep[ns+1].opcode = m_bmi then
                     if npeep[ns+4].opcode = d_lab then
                        if npeep[ns+1].operand = npeep[ns+4].operand then
                           if npeep[ns+3].opcode = m_brl then
                              if Short(ns,npeep[ns+3].operand) then
                                 if Short(ns+1,npeep[ns+3].operand) then begin
                                    operand := npeep[ns+3].operand;
                                    npeep[ns+1].operand := npeep[ns+3].operand;
                                    npeep[ns+1].opcode := m_bpl;
                                    Remove(ns+3);
                                    end; {if}

         {disabled - can generate bad code}
         {m_dec_abs:
            if npeep[ns+1].opcode = m_lda_abs then
               if name^ = npeep[ns+1].name^ then
                  if npeep[ns+2].opcode = m_beq then
                     Remove(ns+1);}

         m_lda_abs:
            if npeep[ns+1].opcode = m_clc then begin
               if npeep[ns+2].opcode = m_adc_abs then
                  if operand = npeep[ns+2].operand then
                     if name = npeep[ns+2].name then
                        if not rangeCheck then begin
                           npeep[ns+1].opcode := m_asl_a;
                           Remove(ns+2);
                           end; {if}
               end {if}
            else if npeep[ns+1].opcode = m_dea then begin
               if npeep[ns+2].opcode = m_tax then begin
                  opcode := m_ldx_abs;
                  npeep[ns+1].opcode := m_dex;
                  Remove(ns+2);
                  end; {if}
               end {else if}
            else if npeep[ns+2].opcode = m_sta_abs then begin
               if npeep[ns+1].opcode in [m_ora_dir,m_ora_abs,m_ora_dirX,
                  m_ora_imm,m_ora_longX,m_ora_s] then
                  if operand = npeep[ns+2].operand then
                     if name = npeep[ns+2].name then begin
                        npeep[ns+1].opcode := npeep[ns+1].opcode + $00A0;
                        npeep[ns+2].opcode := m_tsb_abs;
                        Remove(ns);
                        end; {if}
               end {else if}
            else if SignExtension(ns+1) then begin
               if registers then begin
                  {Leave pattern as ldx / lda / tay-for-flags / bpl ...}
                  {Either lda or tay will be removed by CheckRegisters.}
                  tn := npeep[ns];
                  npeep[ns] := npeep[ns+1];
                  npeep[ns+1] := tn;
                  end {if}
               else begin
                  npeep[ns+2] := npeep[ns];
                  Remove(ns);
                  end; {else}
               end {else if}
            else if npeep[ns+1].opcode = m_xba then
               if npeep[ns+2].opcode = m_and_imm then
                  if npeep[ns+2].operand = $00FF then begin
                     operand := operand+1;
                     Remove(ns+1);
                     end; {if}
                
         m_lda_dir:
            if npeep[ns+1].opcode = m_clc then begin
               if npeep[ns+2].opcode = m_adc_dir then
                  if operand = npeep[ns+2].operand then
                     if not rangeCheck then begin
                        npeep[ns+1].opcode := m_asl_a;
                        Remove(ns+2);
                        end; {if}
               end
            else if npeep[ns+1].opcode = m_dea then begin
               if npeep[ns+2].opcode = m_tax then begin
                  opcode := m_ldx_dir;
                  npeep[ns+1].opcode := m_dex;
                  Remove(ns+2);
                  end; {if}
               end {else if}
            else if npeep[ns+1].opcode = m_pha then begin
               if longA then begin
                  opcode := m_pei_dir;
                  Remove(ns+1);
                  end {if}
               end {else if}
            else if npeep[ns+2].opcode = m_sta_dir then begin
               if npeep[ns+1].opcode in [m_ora_dir,m_ora_abs,m_ora_dirX,
                  m_ora_imm,m_ora_longX,m_ora_s] then
                  if operand = npeep[ns+2].operand then begin
                     npeep[ns+1].opcode := npeep[ns+1].opcode + $00A0;
                     npeep[ns+2].opcode := m_tsb_dir;
                     Remove(ns);
                     end {if}
               end {else if}
            else if SignExtension(ns+1) then begin
               if registers then begin
                  {Leave pattern as ldx / lda / tay-for-flags / bpl ...}
                  {Either lda or tay will be removed by CheckRegisters.}
                  tn := npeep[ns];
                  npeep[ns] := npeep[ns+1];
                  npeep[ns+1] := tn;
                  end {if}
               else begin
                  npeep[ns+2] := npeep[ns];
                  Remove(ns);
                  end; {else}
               end {else if}
            else if npeep[ns+1].opcode = m_xba then begin
               if npeep[ns+2].opcode = m_and_imm then
                  if npeep[ns+2].operand = $00FF then begin
                     operand := operand+1;
                     Remove(ns+1);
                     end {if}
               end {else if}
            else if npeep[ns+1].opcode = m_tay then
               if npeep[ns+2].opcode in [m_lda_dir,m_lda_indly,m_pla] then begin
                  opcode := m_ldy_dir;
                  Remove(ns+1);
                  end {if}
               else if npeep[ns+2].opcode = m_pld then
                  if npeep[ns+3].opcode = m_tsc then begin
                     opcode := m_ldy_dir;
                     Remove(ns+1);
                     end; {if}

         m_ldx_dir:
            if npeep[ns+1].opcode = m_txs then  {optimize stack repair code}
               if npeep[ns+2].opcode = m_tsx then begin
                  if npeep[ns+3].opcode = m_stx_dir then
                     if npeep[ns+3].operand = npeep[ns].operand then begin
                        Remove(ns+2);
                        Remove(ns+2);
                        end; {if}
                  end {if}
               else if npeep[ns+2].opcode in
                  [m_sta_dir,m_sta_abs,m_sta_long,m_sta_indl,m_tyx] then begin
                  if (npeep[ns+2].opcode <> m_sta_dir)
                     or (npeep[ns+2].operand <> npeep[ns].operand) then
                     if npeep[ns+3].opcode = m_tsx then
                        if npeep[ns+4].opcode = m_stx_dir then
                           if npeep[ns+4].operand = npeep[ns].operand then begin
                              Remove(ns+3);
                              Remove(ns+3);
                              if npeep[ns+2].opcode = m_tyx then
                                 Remove(ns+2);
                              end; {if}
                  end {else if}
               else if npeep[ns+2].opcode = m_tsc then begin
                  npeep[ns].opcode := m_lda_dir;
                  npeep[ns+1].opcode := m_tcs;
                  Remove(ns+2);
                  end; {else if}

         m_pei_dir:
            if npeep[ns+1].opcode = m_pla then begin
               opcode := m_lda_dir;
               Remove(ns+1);
               end; {if}

         m_lda_imm:
            if npeep[ns+1].opcode = m_pha then
               if ASafe(ns+2) then
                  if longA then begin
                     opcode := m_pea;
                     Remove(ns+1);
                     end; {if}

         m_ldx_imm:
            if npeep[ns+1].opcode = m_lda_imm then
               if npeep[ns+2].opcode = m_phx then
                  if npeep[ns+3].opcode = m_pha then begin
                     opcode := m_pea;
                     npeep[ns+1].opcode := m_pea;
                     Remove(ns+2);
                     Remove(ns+2);
                     end; {if}

         m_ldy_imm:
            if npeep[ns+1].opcode = m_sep then
               if npeep[ns+1].operand = 32 then begin
                  didOne := true;
                  tn := npeep[ns];
                  npeep[ns] := npeep[ns+1];
                  npeep[ns+1] := tn;
                  end; {if}

         m_ora_abs:     
            if npeep[ns+1].opcode = m_sta_abs then
               if operand = npeep[ns+1].operand then
                  if name = npeep[ns+1].name then begin
                     opcode := m_tsb_abs;
                     Remove(ns+1);
                     end; {if}

         m_ora_dir:     
            if npeep[ns+1].opcode = m_sta_dir then
               if operand = npeep[ns+1].operand then begin
                  opcode := m_tsb_dir;
                  Remove(ns+1);
                  end; {if}

         m_pea:     
            if npeep[ns+1].opcode = m_pla then begin
               opcode := m_lda_imm;
               Remove(ns+1);
               end; {if}

         m_sta_abs:     
            if npeep[ns+1].opcode = m_lda_abs then
               if operand = npeep[ns+1].operand then
                  if name = npeep[ns+1].name then
                     if not (npeep[ns+2].opcode in
                        [m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_bvc,m_bvs]) then
                        Remove(ns+1);

         m_sta_dir:
            if npeep[ns+1].opcode = m_lda_dir then
               if operand = npeep[ns+1].operand then
                  if not (npeep[ns+2].opcode in
                     [m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_bvc,m_bvs]) then
                     Remove(ns+1);

         m_plb:
            if npeep[ns+1].opcode = m_phb then begin
               Remove(ns);
               Remove(ns);
               end; {if}

         {disabled - can generate bad code if the x value is used}
         {m_plx:
            if npeep[ns+1].opcode = m_pha then begin
               opcode := m_sta_s;
               mode := direct;
               operand := 1;
               Remove(ns+1);
               end; {if}

         m_tax:
            if npeep[ns+1].opcode = m_phx then begin
               Remove(ns+1);
               opcode := m_pha;
               end {if}
            else if npeep[ns+1].opcode = m_txa then begin
               if not (npeep[ns+2].opcode in
                  [m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_bvc,m_bvs]) then begin
                  Remove(ns);
                  Remove(ns);
                  end; {if}
               end {else if}
            else if npeep[ns+1].opcode = m_dey then
               if npeep[ns+2].opcode = m_dey then
                  if npeep[ns+3].opcode = m_lda_indly then
                     if npeep[ns+4].opcode = m_stx_dir then
                        if (npeep[ns+4].operand - npeep[ns+3].operand < -1)
                           or (npeep[ns+4].operand - npeep[ns+3].operand > 2)
                           then begin
                           npeep[ns] := npeep[ns+4];
                           opcode := m_sta_dir;
                           Remove(ns+4);
                           end; {if}

         m_tya:
            if npeep[ns+1].opcode = m_sta_dir then begin
               if ASafe(ns+2) then begin
                  npeep[ns+1].opcode := m_sty_dir;
                  Remove(ns);
                  end; {if}
               end {if}
            else if npeep[ns+1].opcode = m_sta_abs then begin
               if ASafe(ns+2) then begin
                  npeep[ns+1].opcode := m_sty_abs;
                  Remove(ns);
                  end; {if}
               end; {else if}

         m_tyx:
            if npeep[ns+1].opcode = m_phx then begin
               Remove(ns+1);
               opcode := m_phy;
               end; {if}

         m_pha:
            if npeep[ns+1].opcode = m_pla then begin
               Remove(ns);
               Remove(ns);
               end {if}
            else if npeep[ns+1].opcode in
               [m_ldx_abs,m_ldx_dir,m_ldy_imm,m_ldy_dir] then
               if npeep[ns+2].opcode = m_pla then begin
                  Remove(ns+2);
                  Remove(ns);
                  end; {if}

         m_phy:
            if npeep[ns+1].opcode = m_ply then begin
               Remove(ns);
               Remove(ns);
               end; {if}

         m_rep:
            if npeep[ns+1].opcode = m_sep then
               if npeep[ns].operand = npeep[ns+1].operand then begin
        	  Remove(ns);
        	  Remove(ns);
        	  end; {if}

         { kws }
         { stz $xx, stz $xx }
         m_stz_abs, m_stz_absX:
            if npeep[ns].opcode = npeep[ns+1].opcode then
               if npeep[ns].operand = npeep[ns+1].operand then
                  if npeep[ns].name = npeep[ns+1].name then
                     if not volatile then
                        Remove(ns+1);
         
         m_stz_dir, m_stz_dirX:
            if npeep[ns].opcode = npeep[ns+1].opcode then
               if npeep[ns].operand = npeep[ns+1].operand then
                  if not volatile then
                     Remove(ns+1);

         m_tcd:
            if npeep[ns+1].opcode = m_tdc then
               Remove(ns+1)
            else if npeep[ns+1].opcode in [m_pea,m_stz_dir,m_stz_abs] then
               if npeep[ns+2].opcode = m_tdc then
                  Remove(ns+2);

         m_tcs:
            if npeep[ns+1].opcode = m_tsx then
               if npeep[ns+2].opcode = m_stx_dir then begin
                  npeep[ns+2].opcode := m_sta_dir;
                  Remove(ns+1);
                  end; {if}

         m_tsx:
            if npeep[ns+1].opcode = m_stx_dir then
               if npeep[ns+2].opcode = m_pei_dir then
                  if npeep[ns+3].opcode = m_tsx then
                     if npeep[ns+4].opcode = m_stx_dir then
                        if npeep[ns+1].operand = npeep[ns+2].operand then
                           if npeep[ns+1].operand = npeep[ns+4].operand then
                              begin
                              npeep[ns+1].opcode := m_phx;
                              npeep[ns+1].mode := implied;
                              Remove(ns+2);
                              end; {if}

         {extra explicit cases to ensure this case statement uses a jump table}
         m_rtl,m_rts,m_jml,m_jsl,m_mvn,m_plp,m_pld,m_txs,
         otherwise: ;

         end; {case}
1:
  end; {Optimize}

begin {GenNative}
{ writeln('GenNative: ',p_opcode:4, ', mode=', ord(p_mode):1,
   ' operand=', p_operand:1);      {debug}
if npeephole then begin
   if (nnextspot = 1) and not (p_opcode in nleadOpcodes) then begin
      if p_opcode <> d_end then
         if registers then
            CheckRegisters(p_opcode, p_mode, p_operand, p_name, p_flags)
         else
            WriteNative(p_opcode, p_mode, p_operand, p_name, p_flags);
      end {if}
   else if p_opcode in nstopOpcodes then begin
      repeat
         didOne := false;
         i := 1;
         llongA := longA;
         while i < nnextSpot-nMaxPeep do begin
            op := npeep[i].opcode;
            if op = m_sep then begin
               if npeep[i].operand & $20 <> 0 then
                  llongA := false;
               end {if}
            else if op = m_rep then begin
               if npeep[i].operand & $20 <> 0 then
                  llongA := true;
               end; {else}
            Optimize(i,llongA);
            i := i+1;
            end; {while}
      until not didone;
      Purge;
      if p_opcode <> d_end then
         if registers then
            CheckRegisters(p_opcode, p_mode, p_operand, p_name, p_flags)
         else
            WriteNative(p_opcode, p_mode, p_operand, p_name, p_flags);
      end {else if}
   else if nnextSpot = npeepSize then begin
      repeat
         didOne := false;
         i := 1;
         llongA := longA;
         while i < nnextSpot-nMaxPeep do begin
            op := npeep[i].opcode;
            if op = m_sep then begin
               if npeep[i].operand & $20 <> 0 then
               llongA := false;
               end {if}
            else if op = m_rep then begin
               if npeep[i].operand & $20 <> 0 then
               llongA := true;
               end; {else}
            Optimize(i,llongA);
            i := i+1;
            end; {while}
      until not didone;
      done := false;
      repeat
         if nnextSpot = 1 then
            done := true
         else begin
            if npeep[1].opcode in nleadOpcodes then
               done := true
            else begin
               if registers then
                  CheckRegisters(nPeep[1].opcode, nPeep[1].mode,
                     nPeep[1].operand, nPeep[1].name, nPeep[1].flags)
               else
                  WriteNative(nPeep[1].opcode, nPeep[1].mode, nPeep[1].operand,
                     nPeep[1].name,nPeep[1].flags);
               Remove(1);
               end; {else}
            end; {else}
      until done;
      if nnextSpot = nPeepSize then begin
         if registers then
            CheckRegisters(nPeep[1].opcode, nPeep[1].mode, nPeep[1].operand,
               nPeep[1].name, nPeep[1].flags)
         else
            WriteNative(nPeep[1].opcode, nPeep[1].mode, nPeep[1].operand,
               nPeep[1].name, nPeep[1].flags);
         Remove(1);
         end; {if}
      with npeep[nnextSpot] do begin
         opcode := p_opcode;
         mode := p_mode;
         operand := p_operand;
         name := p_name;
         flags := p_flags;
         end; {with}
      nnextSpot := nnextSpot+1;
      if not (npeep[1].opcode in nleadOpcodes) then begin
         if registers then
            CheckRegisters(nPeep[1].opcode, nPeep[1].mode, nPeep[1].operand,
               nPeep[1].name, nPeep[1].flags)
         else
            WriteNative(nPeep[1].opcode, nPeep[1].mode, nPeep[1].operand,
               nPeep[1].name, nPeep[1].flags);
         Remove(1);
         end; {if}
      end {else if}
   else begin
      with npeep[nnextSpot] do begin
         opcode := p_opcode;
         mode := p_mode;
         operand := p_operand;
         name := p_name;
         flags := p_flags;
         end; {with}
      nnextSpot := nnextSpot+1;
      end; {else}
   end {if}
else if p_opcode <> d_end then
   if registers then
      CheckRegisters(p_opcode, p_mode, p_operand, p_name, p_flags)
   else
      WriteNative(p_opcode, p_mode, p_operand, p_name, p_flags);
end; {GenNative}


procedure GenImplied {p_opcode: integer};

{ short form of GenNative - reduces code size                   }
{                                                               }
{ parameters:                                                   }
{       p_code - operation code                                 }

begin {GenImplied}
GenNative(p_opcode, implied, 0, nil, 0);
end; {GenImplied}


procedure GenImpliedForFlags {p_opcode: integer};

{ Generate implied addressing instruction used for flags only.  }
{                                                               }
{ parameters:                                                   }
{       p_code - operation code (m_tax or m_tay)                }

begin {GenImpliedForFlags}
GenNative(p_opcode, implied, 0, nil, forFlags);
end; {GenImpliedForFlags}


procedure GenCall {callNum: integer};

{ short form of jsl to library subroutine - reduces code size   }
{                                                               }
{ parameters:                                                   }
{       callNum - subroutine # to generate a call for           }

var
   sp: stringPtr;                       {work string}

begin {GenCall}
case callNum of
    1: sp := @'~CHECKSTACK';
    2: sp := @'~RESETNAME';
    3: sp := @'~CREALRET';
    4: sp := @'~CDOUBLERET';
    5: sp := @'~SETNAME';
    6: sp := @'~SETLINENUMBER';
    7: sp := @'~REALFN';
    8: sp := @'~DOUBLEFN';
    9: sp := @'~SAVEREAL';
   10: sp := @'~SAVEDOUBLE';
   11: sp := @'~CNVINTREAL';
   12: sp := @'~CNVLONGREAL';
   13: sp := @'~CNVULONGREAL';
   14: sp := @'~CNVREALINT';
   15: sp := @'~CNVREALUINT';
   16: sp := @'~CNVREALLONG';
   17: sp := @'~CNVREALULONG';
   18: sp := @'~CNVL2';                 {PASCAL}
   19: sp := @'~SAVESET';
   20: sp := @'~LOADSET';               {PASCAL}
   21: sp := @'~LOADREAL';
   22: sp := @'~LOADDOUBLE';
   23: sp := @'~SHIFTLEFT';
   24: sp := @'~SSHIFTRIGHT';
   25: sp := @'~INTCHKC';
   26: sp := @'~DIV2';
   27: sp := @'~MOD2';
   28: sp := @'~MUL2';
   29: sp := @'~GRTL';
   30: sp := @'~GEQL';
   31: sp := @'~GRTE';
   32: sp := @'~GEQE';
   33: sp := @'~SETINCLUSION';
   34: sp := @'~GRTSTRING';
   35: sp := @'~GEQSTRING';
   36: sp := @'~EQUE';
   37: sp := @'~SETEQU';
   38: sp := @'~EQUSTRING';
   39: sp := @'~UMUL2';
   40: sp := @'~UDIV2';
   41: sp := @'~USHIFTRIGHT';
   42: sp := @'~MUL4';
   43: sp := @'~PDIV4';
   44: sp := @'~MOD4';
   45: sp := @'~SHL4';
   46: sp := @'~LSHR4';
   47: sp := @'~ASHR4';                 {CC}
   48: sp := @'~UMUL4';                 {CC}
   49: sp := @'~UDIV4';                 {CC}
   50: sp := @'~UMOD4';                 {CC}
   51: sp := @'~COPYREAL';
   52: sp := @'~COPYDOUBLE';
   53: sp := @'~XJPERROR';
   54: sp := @'~MOVE';
   55: sp := @'~MOVE2';
   56: sp := @'~ADDE';
   57: sp := @'~DIVE';
   58: sp := @'~MULE';
   59: sp := @'~SUBE';
   60: sp := @'~POWER';
   61: sp := @'~ARCTAN2E';
   62: sp := @'~LONGMOVE';
   63: sp := @'~LONGMOVE2';
   64: sp := @'~CCOMPRET';
   65: sp := @'~CEXTENDEDRET';
   66: sp := @'~SAVECOMP';
   67: sp := @'~SAVEEXTENDED';
   68: sp := @'~COPYCOMP';
   69: sp := @'~COPYEXTENDED';
   70: sp := @'~LOADCOMP';
   71: sp := @'~LOADEXTENDED';
   72: sp := @'~LOADUBF';
   73: sp := @'~LOADBF';
   74: sp := @'~SAVEBF';
   75: sp := @'~COPYBF';
   76: sp := @'~STACKERR';              {CC}
   77: sp := @'~LOADSTRUCT';            {CC}
   78: sp := @'~DIV4';                  {CC}
   79: sp := @'~MUL8';
   80: sp := @'~UMUL8';
   81: sp := @'~CDIV8';
   82: sp := @'~UDIV8';
   83: sp := @'~CNVLONGLONGREAL';
   84: sp := @'~CNVULONGLONGREAL';
   85: sp := @'~SHL8';
   86: sp := @'~ASHR8';
   87: sp := @'~LSHR8';
   88: sp := @'~SCMP8';
   89: sp := @'~CNVREALLONGLONG';
   90: sp := @'~CNVREALULONGLONG';
   91: sp := @'~SINGLEPRECISION';
   92: sp := @'~DOUBLEPRECISION';
   93: sp := @'~COMPPRECISION';
   94: sp := @'~CUMUL2';
   95: sp := @'~REALFIX';
   96: sp := @'~DOUBLEFIX';
   97: sp := @'~COMPFIX';
   98: sp := @'~CHECKPTRC';
   otherwise:
      Error(cge1);
   end; {case}
GenNative(m_jsl, longabs, 0, sp, 0);
end; {GenCall}


procedure GenLab {lnum: integer};

{ generate a label                                              }
{                                                               }
{ parameters:                                                   }
{       lnum - label number                                     }

begin {GenLab}
GenNative(d_lab, gnrlabel, lnum, nil, 0);
end; {GenLab}


procedure GenLabUsedOnce {lnum: integer};

{ generate a label that is only targeted by one branch          }
{                                                               }
{ parameters:                                                   }
{       lnum - label number                                     }

begin {GenLabUsedOnce}
GenNative(d_lab, gnrlabel, lnum, nil, labelUsedOnce);
end; {GenLabUsedOnce}


procedure InitFile {keepName: gsosOutStringPtr; keepFlag: integer; partial: boolean};

{ Set up the object file					}
{                                                               }
{ parameters:							}
{    keepName - name of the output file				}
{    keepFlag - keep status:					}
{       0 - don't keep the output				}
{       1 - create a new object module				}
{       2 - a .root already exists				}
{       3 - at least on .letter file exists			}
{    partial - is this a partial compile?			}
{								}
{ Note: Declared as extern in CGI.pas				}
          

   procedure RootFile;

   { Create and write the initial entry segment                 }

   const
      dispToOpen     =     21;          {disps to glue routines for NDAs}
      dispToClose    =     38;
      dispToAction   =     50;
      dispToInit     =     65;
      dispToCDAOpen  =     9;           {disps to glue routines for CDAs}
      dispToCDAClose =     36;

   var
      i: integer;                       {loop index}
      lab: stringPtr;			{for holding names var pointers}
      menuLen: integer;                 {length of the menu name string}


      procedure SetDataBank;

      { set up the data bank register                           }

      var
         lisJSL: boolean;               {saved copy of isJSL}

      begin {SetDataBank}
      lisJSL := isJSL;
      isJSL := false;
      CnOut(m_pea);
      RefName(@'~GLOBALS', 0, 2, -8);
      CnOut(m_plb);
      CnOut(m_plb);
      isJSL := lisJSL;
      end; {SetDataBank}


   begin {RootFile}
   {open the initial object module}
   fname2.theString.theString := concat(fname1.theString.theString, '.root');
   fname2.theString.size := length(fname2.theString.theString);
   OpenObj(fname2);

   {force this to be a static segment}
   if (segmentKind & $8000) <> 0 then begin
      currentSegment := '          ';
      segmentKind := 0;
      end; {if}

   {write the header}
   InitNative;
   Header(@'~_ROOT', $4000, 0);

   {new desk accessory initialization}
   if isNewDeskAcc then begin

      {set up the initial jump table}
      lab := @'~_ROOT';
      menuLen := length(menuLine);
      RefName(lab, menuLen + dispToOpen, 4, 0);
      RefName(lab, menuLen + dispToClose, 4, 0);
      RefName(lab, menuLen + dispToAction, 4, 0);
      RefName(lab, menuLen + dispToInit, 4, 0);
      CnOut2(refreshPeriod);
      CnOut2(eventMask);
      for i := 1 to menuLen do
         CnOut(ord(menuLine[i]));
      CnOut(0);

      {glue code for calling open routine}
      isJSL := true;
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_jsl);
      RefName(openName, 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_sta_s); CnOut(4);
      CnOut(m_txa);
      CnOut(m_sta_s); CnOut(6);
      CnOut(m_rtl);

      {glue code for calling close routine}
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_jsl);
      RefName(closeName, 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_rtl);

      {glue code for calling action routine}
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_pha);
      CnOut(m_phy);
      CnOut(m_phx);
      CnOut(m_jsl);
      RefName(actionName, 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_rtl);

      {glue code for calling init routine}
      CnOut(m_pha);
      CnOut(m_jsl);
      RefName(@'~DAID', 0, 3, 0);
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_pha);
      CnOut(m_jsl);
      RefName(initName, 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_rtl);
      isJSL := false;
      end

   {classic desk accessory initialization}
   else if isClassicDeskAcc then begin

      {write the name}
      menuLen := length(menuLine);
      CnOut(menuLen);
      for i := 1 to menuLen do
         CnOut(ord(menuLine[i]));

      {set up the initial jump table}
      lab := @'~_ROOT';
      RefName(lab, menuLen + dispToCDAOpen, 4, 0);
      RefName(lab, menuLen + dispToCDAClose, 4, 0);

      {glue code for calling open routine}
      isJSL := true;
      CnOut(m_pea);
      CnOut2(1);
      CnOut(m_jsl);
      RefName(@'~DAID', 0, 3, 0);
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_jsl);
      RefName(@'~CDASTART', 0, 3, 0);
      CnOut(m_jsl);
      RefName(openName,0,3,0);
      CnOut(m_jsl);
      RefName(@'~CDASHUTDOWN', 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_rtl);

      {glue code for calling close routine}
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_jsl);
      RefName(closeName, 0, 3, 0);
      CnOut(m_pea);
      CnOut2(0);
      CnOut(m_jsl);
      RefName(@'~DAID', 0, 3, 0);
      CnOut(m_plb);
      CnOut(m_rtl);
      isJSL := false;
      end

   {control panel device initialization}
   else if isCDev then begin
      CnOut(m_phb);                     {save data bank}
      SetDataBank;                      {set data bank}
      CnOut(m_plx);                     {get RTL address & original data bank}
      CnOut(m_ply);
      CnOut(m_lda_s); CnOut(3);         {move CDev parameters}
      CnOut(m_pha);
      CnOut(m_lda_s); CnOut(3);
      CnOut(m_pha);
      CnOut(m_lda_s); CnOut(9);
      CnOut(m_sta_s); CnOut(5);
      CnOut(m_lda_s); CnOut(11);
      CnOut(m_sta_s); CnOut(7);
      CnOut(m_lda_s); CnOut(13);
      CnOut(m_sta_s); CnOut(9);
      CnOut(m_sta_s); CnOut(15);        {store message in result space}
      CnOut(m_lda_long);                {store original user ID in result space}
      RefName(@'~USER_ID',0,3,0);
      CnOut(m_sta_s); CnOut(17);
      CnOut(m_txa);                     {save RTL address & original data bank}
      CnOut(m_sta_s); CnOut(11);
      CnOut(m_tya);
      CnOut(m_sta_s); CnOut(13);
      CnOut(m_pea); CnOut2(1);          {get user ID}
      CnOut(m_jsl);
      RefName(@'~DAID', 0, 3, 0);
      CnOut(m_jsl);                     {call CDev main routine}
      RefName(openName,0,3,0);
      CnOut(m_jml);                     {clean up and return to caller}
      RefName(@'~CDEVCLEANUP', 0, 3, 0);
      end

   {NBA initialization}
   else if isNBA then begin
      CnOut(m_jsl);
      RefName(@'~NBASTARTUP', 0, 3, 0);
      CnOut(m_phx);
      CnOut(m_phy);
      CnOut(m_jsl);
      RefName(openName,0,3,0);
      CnOut(m_jsl);
      RefName(@'~NBASHUTDOWN', 0, 3, 0);
      CnOut(m_rtl);
      end

   {XCMD initialization}
   else if isXCMD then begin
      CnOut(m_jsl);
      RefName(@'~XCMDSTARTUP', 0, 3, 0);
      CnOut(m_jsl);
      RefName(openName,0,3,0);
      CnOut(m_jsl);
      RefName(@'~XCMDSHUTDOWN', 0, 3, 0);
      CnOut(m_rtl);
      end

   {normal program initialization}
   else begin

      {write the initial JSL}
      isJSL := true;
      CnOut(m_jsl);
      if rtl then
         RefName(@'~_BWSTARTUP4', 0, 3, 0)
      else
         RefName(@'~_BWSTARTUP3', 0, 3, 0);

      {set the data bank register}
      SetDataBank;

      {set FPE slot, if using FPE}
      if floatCard = 1 then begin
         CnOut(m_lda_imm);
         if floatSlot in [1..7] then
            CnOut2(floatSlot)
         else
            CnOut2(0);
         CnOut(m_jsl);
         RefName(@'~INITFLOAT', 0, 3, 0);
         end; {if}

      {write JSL to main entry point}
      CnOut(m_jsl);
      if rtl then
         RefName(@'~C_STARTUP2', 0, 3, 0)
      else
         RefName(@'~C_STARTUP', 0, 3, 0);
      CnOut(m_jsl);
      RefName(@'main', 0, 3, 0);
      isJSL := false;
      CnOut(m_jml);
      if rtl then
         RefName(@'~C_SHUTDOWN2', 0, 3, 0)
      else
         RefName(@'~C_SHUTDOWN', 0, 3, 0);
      end;

   {finish the current segment}
   EndSeg;
   end; {RootFile}


   procedure SetStack;

   { Set up a stack frame					}

   begin {SetStack}
   if stackSize <> 0 then begin
      currentSegment := '~_STACK   ';	{write the header}
      segmentKind := 0;
      Header(@'~_STACK', $4012, 0);
      Out($F1);				{write the DS record to reserve space}
      Out2(stackSize);
      Out2(0);
      EndSeg;				{finish the current segment}
      end; {if}
   end; {SetStack}


begin {InitFile}
fname1 := keepname^;
if partial or (keepFlag = 3) then
   FindSuffix(fname1, nextSuffix)
else begin
   if (keepFlag = 1) and (not noroot) then begin
       RootFile;
       SetStack;
       CloseObj;
       end; {if}
   DestroySuffixes(fname1);
   nextSuffix := 'a';
   end; {else}
fname2.theString.theString := concat(fname1.theString.theString, '.', nextSuffix);
fname2.theString.size := length(fname2.theString.theString);
OpenObj(fname2);
end; {InitFile}


procedure InitNative; 

{ set up for a new segment					}

begin {InitNative}
aRegister.condition := regUnknown;	{set up the peephole optimizer}
xRegister.condition := regUnknown;
yRegister.condition := regUnknown;
lastRegOpcode := 0; {BRK}
nnextspot := 1;
nleadOpcodes := [m_asl_a,m_bcc,m_bcs,m_beq,m_bmi,m_bne,m_bpl,m_brl,{m_bvs,}
   {m_dec_abs,}m_lda_abs,m_lda_dir,m_lda_imm,m_ldx_imm,m_sta_abs,m_sta_dir,
   m_pha,m_plb,{m_plx,}m_tax,m_tya,m_tyx,m_phy,m_pei_dir,m_ldy_imm,m_rep,
   m_ora_dir,m_ora_abs,m_and_imm,m_pea,m_tcd];
nstopOpcodes := [d_end,d_pin];

stringSize := 0;			{initialize scalars for a new segment}
pc := 0;
cbufflen := 0;
longA := true;
longI := true;
end; {InitNative}


procedure RefName {lab: stringPtr; disp, len, shift: integer};

{ handle a reference to a named label                           }
{                                                               }
{ parameters:                                                   }
{       lab - label name                                        }
{       disp - displacement past the label                      }
{       len - number of bytes in the reference                  }
{       shift - shift factor                                    }

var
   i: integer;                          {loop var}
   slen: integer;                       {length of string}

begin {RefName}
Purge;                                  {clear any constant bytes}
if isJSL then                           {expression header}
   Out(243)
else
   Out(235);
Out(len);
Out(131);
pc := pc+len;
slen := length(lab^);
Out(slen);
for i := 1 to slen do
   Out(ord(lab^[i]));
if disp <> 0 then begin                 {if there is a disp, add it in}
   Out(129);
   Out2(disp);
   Out2(0);
   Out(1);
   end; {end}
if shift <> 0 then begin                {if there is a shift, add it in}
   Out(129);
   Out2(shift);
   if shift < 0 then
      Out2(-1)
   else
      Out2(0);
   Out(7);
   end; {if}
Out(0);                                 {end of expression}
end; {RefName}

end.

{$append 'native.asm'}
