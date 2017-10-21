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

{$segment 'CodeGen'}

type
   labelptr = ^labelentry;              {pointer to a forward ref node}
   labelentry = record                  {forward ref node}
      addr: integer;
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
      Out2(-shift); Out2(-1);
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
   next,temp: labelptr;                 {work pointers}

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
         temp := next;
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
   rkind = (k1,k2,k3);                  {cnv record types}

var
   ch: char;                            {temp storage for string constants}
   cns: realRec;                        {for converting reals to bytes}
   cnv: record                          {for converting double, real to bytes}
      case rkind of
         k1: (rval: real;);
         k2: (dval: double;);
         k3: (ival1,ival2,ival3,ival4: integer;);
      end;
   count: integer;                      {number of constants to repeat}
   i,j,k: integer;                      {loop variables}
   lsegDisp: integer;                   {for backtracking while writting the   }
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
      LabelSearch(long(name).lsw, 1, ord(odd(flags div shift16))*16, operand)
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
         Out2(operand); Out2(0);
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
      LabelSearch(long(name).lsw, 2, ord(odd(flags div shift16))*16, operand)
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
               if odd(operand div 32) then longA := true;
               if odd(operand div 16) then longI := true;
               end {if}
            else if opcode = m_sep then begin
               if odd(operand div 32) then longA := false;
               if odd(operand div 16) then longI := false;
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
      isJSL := opcode = m_jsl;          {allow for dynamic segs}
      if name = nil then
         if odd(flags div toolcall) then begin
            CnOut2(0);
            CnOut(225);
            end {if}
         else
            LabelSearch(operand, 3, 0, 0)
      else
         if odd(flags div toolcall) then begin
            CnOut2(long(name).lsw);
            CnOut(long(name).msw);
            end {if}
         else
            RefName(name, operand, 3, 0);
      isJSL := false;
      end;

   longabsolute: begin
      if opcode <> d_add then begin
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
         if opcode = d_add then
            CnOut2(long(lval).msw)
         else
            CnOut(long(lval).msw);
         end {else if}
      else if name <> nil then
         RefName(name, operand, i, 0)
      else begin
         CnOut2(operand);
         CnOut(0);
         if opcode = d_add then
            CnOut(0);
         end; {else}
      end;

   absolute: begin
      if opcode <> d_add then
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
      if opcode <> d_add then
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
                                  cns.itsReal := icptr(name)^.rval;
                                  CnvSX(cns);
                                  for j := 1 to 10 do
                                     CnOut(cns.inSANE[j]);
                                  end;
            cgString            : begin
                                  sptr := icptr(name)^.str;
                                  for j := 1 to sptr^.length do
                                     CnOut(ord(sPtr^.str[j]));
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
                                     if maxString-stringSize >= j+1 then begin
                                        for k := 1 to j do
                                           stringSpace[k+stringSize] :=
                                              sptr^.str[k];
                                        stringSpace[stringSize+j+1] := chr(0);
                                        stringSize := stringSize+j+1;
                                        end {if}
                                     else
                                        Error(cge3);
                                     end; {else}
                                  end;
            otherwise           : Error(cge1);
            end; {case}
      end;

   genAddress: begin
      if opcode < 256 then
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
      else
         LabelSearch(operand, 0, 0, 0);
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
      CnOut(ord(stringspace[i]));
   Purge;
   end; {if}
Out(0);                                 {end the segment}
segDisp := 8;                           {update header}
Out2(long(pc).lsw);
Out2(long(pc).msw);
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

begin {GenNative}
{ writeln('GenNative: ',p_opcode:4, ', mode=', ord(p_mode):1,
   ' operand=', p_operand:1);      {debug}
if p_opcode <> d_end then
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
      lab: stringPtr;			{for holdling names var pointers}
      menuLen: integer;                 {length of the menu name string}


      procedure SetDataBank;

      { set up the data bank register                           }

      begin {SetDataBank}
      CnOut(m_pea);
      RefName(@'~GLOBALS', 0, 2, -8);
      CnOut(m_plb);
      CnOut(m_plb);
      end; {SetDataBank}


   begin {RootFile}
   {open the initial object module}
   fname2.theString.theString := concat(fname1.theString.theString, '.root');
   fname2.theString.size := length(fname2.theString.theString);
   OpenObj(fname2);

   {write the header}
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
      end

   {control panel device initialization}
   else if isCDev then begin
      CnOut(m_pea);
      CnOut2(1);
      CnOut(m_jsl);
      RefName(@'~DAID', 0, 3, 0);
      CnOut(m_phb);
      SetDataBank;
      CnOut(m_pla);
      CnOut(m_sta_s); CnOut(13);
      CnOut(m_pla);
      CnOut(m_sta_s); CnOut(13);
      CnOut(m_jsl);
      RefName(openName,0,3,0);
      CnOut(m_tay);
      CnOut(m_lda_s); CnOut(3);
      CnOut(m_pha);
      CnOut(m_lda_s); CnOut(3);
      CnOut(m_pha);
      CnOut(m_txa);
      CnOut(m_sta_s); CnOut(7);
      CnOut(m_tya);
      CnOut(m_sta_s); CnOut(5);
      CnOut(m_plb);
      CnOut(m_rtl);
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
      CnOut(m_jsl);
      if rtl then
         RefName(@'~_BWSTARTUP4', 0, 3, 0)
      else
         RefName(@'~_BWSTARTUP3', 0, 3, 0);

      {set the data bank register}
      SetDataBank;

      {write JSL to main entry point}
      CnOut(m_jsl);
      if rtl then
         RefName(@'~C_STARTUP2', 0, 3, 0)
      else
         RefName(@'~C_STARTUP', 0, 3, 0);
      CnOut(m_jsl);
      RefName(@'main', 0, 3, 0);
      CnOut(m_jsl);
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
      Header(@'~_STACK', $4012, 0);
      currentSegment := defaultSegment;
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
