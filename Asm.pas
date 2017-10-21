{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Asm                                                          }
{                                                               }
{  This unit implements the built-in assembler and              }
{  disassembler.                                                }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  AsmFunction - assemble an assembly language function         }
{  AsmStatement - assemble some in-line code                    }
{  InitAsm - initialize the assembler                           }
{                                                               }
{---------------------------------------------------------------}

unit Asm;

interface

{$LibPrefix '0/obj/'}

uses CCommon, Table, CGI, Scanner, Symbol, MM, Expression;

{$segment 'cc'}

procedure AsmFunction (variable: identPtr);

{ Assemble an assembly language function                        }
{                                                               }
{ parameters:                                                   }
{    variable - pointer to the function variable                }


procedure AsmStatement;

{ Assemble some in-line code                                    }


procedure InitAsm;

{ Initialize the assembler                                      }


{---------------------------------------------------------------}

implementation

{---------------------------------------------------------------}

var
   doingAsmFunction: boolean;           {was AsmStatement called from AsmFunction?}

{- Imported from the parser: -----------------------------------}

procedure Match (kind: tokenEnum; err: integer); extern;

{ insure that the next token is of the specified type           }
{                                                               }
{  parameters:                                                  }
{       kind - expected token kind                              }
{       err - error number if the expected token is not found   }

{- Private routines --------------------------------------------}

function FindLabel (name: stringPtr; definition: boolean): integer;

{ Find a label in the label list.  If none exists, create one.  }
{                                                               }
{ parameters:                                                   }
{    name - name of the label                                   }
{    definition - is this the defining point?                   }

label 1;

var
   lb: gotoPtr;                         {work pointer}
   lnum: integer;                       {label number}

begin {FindLabel}
lb := gotoList;                         {try to find an existing label}
while lb <> nil do begin
   if lb^.name^ = name^ then begin
      lnum := lb^.lab;
      goto 1;
      end;
   lb := lb^.next;
   end; {while}
lb := pointer(Malloc(sizeof(gotoRecord))); {no label record exists: create one}
lb^.next := gotoList;
gotoList := lb;
lb^.name := name;
lnum := GenLabel;
lb^.lab := lnum;
lb^.defined := false;
1:
if definition then begin
   if lb^.defined then
      Error(77)
   else begin
      lb^.defined := true;
      Gen1(dc_lab, lb^.lab);
      end; {else}
   end; {if}
FindLabel := lnum;
end; {FindLabel}

{- Global routines ---------------------------------------------}

procedure AsmFunction {variable: identPtr};

{ Assemble an assembly language function                        }
{                                                               }
{ parameters:                                                   }
{    variable - pointer to the function variable                }

var
   tl: tempPtr;                         {work pointer}

begin {AsmFunction}

{process the statements}
doingAsmFunction := true;
AsmStatement;
doingAsmFunction := false;

{finish the subroutine}
Gen0 (dc_enp);                          {finish the segment}
CheckGotoList;                          {make sure all labels are declared}
while tempList <> nil do begin          {dump the local labels}
   tl := tempList;
   tempList := tl^.next;
   dispose(tl);
   end; {while}
LInit;                                  {dispose of the local memory pool}
nameFound := false;                     {no pc_nam for the next function (yet)}
doingFunction := false;                 {no longer doing a function}
end; {AsmFunction}


procedure AsmStatement;

{ Assemble some in-line code                                    }

label 1,2,3,99;

var
   i: integer;                          {loop variable}
   lnum: integer;                       {label number}
   name: packed array[0..3] of char;    {op code name}
   opc: opcode;                         {operation code enumeration}
   opname: tokenType;                   {operation code token}
   optype: operands;                    {operand type}

                                        {set by Exp}
                                        {----------}
   isConstant: boolean;                 {constant? (or identifier expression}
   operand: tokenType;                  {operand (if not isConstant)}
   operation: (plus,minus,none);        {kind of operation}
   size: (directPage,absoluteaddress,longAddress); {size of the operand}
   value: longint;                      {expression value}


   procedure Skip;

   { An error was found: skip to the end & quit                 }

   begin {Skip}
   charKinds[ord('#')] := ch_pound;
   while not (token.kind in [rbracech,eofsy]) do
      NextToken;
   charKinds[ord('#')] := illegal;
   goto 99;
   end; {Skip}


   procedure Exp (stop: tokenSet; EOLallowed: boolean);

   { Parse an expression in an operand                          }
   {                                                            }
   { Parameters:                                                }
   {    stop - stop symbols                                     }
   {    EOLallowed - can the expression end with EOL?           }
   {                                                            }
   { Outputs:                                                   }
   {    isConstant - constant? (or identifier expression)       }
   {    operand - operand (if not isConstant)                   }
   {    operation - kind of operation                           }
   {    size - size of the operand                              }
   {    value - expression value                                }

   var
      forced: boolean;                  {is the expression type forced?}
      i: 0..maxint;			{loop/index variable}
      id: identPtr;                     {identifier}
      tcode: intermediate_code;         {temp storage for code}

   begin {Exp}
   if token.kind in [ltch,barch,gtch]   {allow for operand size forcing}
      then begin
      forced := true;
      if token.kind = ltch then
         size := directPage
      else if token.kind = barch then
         size := absoluteaddress
      else {if token.kind = gtch then}
         size := longAddress;
      NextToken;
      end {if}
   else
      forced := false;

   if EOLallowed then begin             {handle expressions that can end at eol}
      reportEOL := true;
      stop := stop+[eolsy];
      end; {if}
   if token.kind = ident then begin     {handle expressions with an identifier}
      if not forced then
         size := absoluteaddress;
      isConstant := false;
      operand := token;
      id := FindSymbol(token, variableSpace, false, true);
      if id = nil then begin
         code^.llab := FindLabel(token.name, false);
         if (not forced) and (not smallMemoryModel) then
            size := longAddress;
         end {if}
      else begin
         operand.symbolPtr := id;
         if id^.storage in [stackFrame,parameter] then begin
            code^.slab := id^.lln;
            if not forced then
               size := directPage;
            end {if}
         else begin
            code^.lab := id^.name;
            if id^.itype^.kind = functionType then begin
               if id^.itype^.isPascal then begin
        	  code^.lab := pointer(Malloc(length(id^.name^)+1));
        	  CopyString(pointer(code^.lab), pointer(id^.name));
        	  for i := 1 to length(code^.lab^) do
                     if code^.lab^[i] in ['a'..'z'] then
                	code^.lab^[i] := chr(ord(code^.lab^[i]) & $5F);
        	  end; {if}
               end; {if}
            if (not forced) and (not smallMemoryModel) then
               size := longAddress;
            end; {else}
         end; {else}
      NextToken;
      if token.kind in [plusch,minusch] then begin
         if token.kind = plusch then
            operation := plus
         else
            operation := minus;
         NextToken;
         tcode := code^;
         Expression(arrayExpression, stop);
         code^ := tcode;
         value := expressionValue;
         if expressionType^.kind = scalarType then
            if expressionType^.baseType <= cgUWord then
               value := value & $0000FFFF;
         end {if}
      else begin
         operation := none;
         value := 0;
         end; {else}
      end {if token = ident}
   else begin                           {constant expression}
      operation := none;
      isConstant := true;
      tcode := code^;
      Expression(arrayExpression, stop);
      code^ := tcode;
      value := expressionValue;
      if expressionType^.kind = scalarType then
         if expressionType^.baseType <= cgUWord then
            value := value & $0000FFFF;
      if not forced then
         if long(value).msw = 0 then begin
            if long(value).lsw & $FF00 = 0 then
               size := directPage
            else
               size := absoluteaddress;
            end {if}
         else
            size := longAddress;
      end; {else}

   reportEOL := false;
   if token.kind = eolsy then
      NextToken;
   end; {Exp}


   function RegCompare (str: stringPtr; reg: char): boolean;

   { Compare a string to a register constant                    }
   {                                                            }
   { parameters:                                                }
   {    str - string pointer                                    }
   {    reg - register character                                }

   begin {RegCompare}
   RegCompare := false;
   if length(str^) = 1 then
      RegCompare := chr(ord(str^[1]) | $20) = reg;
   end; {RegCompare}


   procedure CheckForComment;

   { Handle an assembly language comment (ignore chars from ; to EOL) }

   begin {CheckForComment}
   while token.kind = semicolonch do begin
      while not (charKinds[ord(ch)] in [ch_eol,ch_eof]) do
         NextCh;
      NextCh;
      NextToken;
      end; {if}
   end; {CheckForComment}


begin {AsmStatement}
Match(lbracech,27);
while not (token.kind in [rbracech,eofsy]) do begin

   {find the label and op-code}
   CheckForComment;
   charKinds[ord('#')] := ch_pound;     {allow # as a token}
   if token.kind <> ident then begin    {error if not an identifier}
      Error(9);
      Skip;
      end; {if}
   opname := token;
   NextToken;
   while token.kind = colonch do begin  {define a label}
      lnum := FindLabel(opname.name, true);
      NextToken;
      CheckForComment;
      if token.kind <> ident then
         Skip;
      opname := token;
      NextToken;
      end; {while}
   charKinds[ord('#')] := illegal;      {don't allow # as a token}

   {identify the op-code}
   if length(opname.name^) = 3 then begin
      name := opname.name^;
      for i := 1 to 3 do
         if name[i] in ['A'..'Z'] then
            name[i] := chr(ord(name[i]) | $20);
      for opc := o_adc to o_xce do
         if names[opc] = name then
            goto 1;
      end; {if}
   Error(95);
   Skip;

1: code^.q := 0;                        {default to no flags}

   {handle general operand instructions}
   if opc <= o_tsb then begin
      optype := op;
      if token.kind = lparench then begin
         NextToken;
         Exp([commach,rparench], false);
         if token.kind = commach then begin
            NextToken;
            if token.kind = ident then begin
               if RegCompare(token.name, 'x') then begin
                  NextToken;
                  Match(rparench,12);
                  if size = directPage then
                     optype := i_dp_x
                  else if size = absoluteaddress then
                     optype := i_op_x
                  else
                     Error(96);
                  end {if}
               else if RegCompare(token.name, 's') then begin
                  NextToken;
                  Match(rparench,12);
                  Match(commach,86);
                  if token.kind = ident then begin
                     if RegCompare(token.name, 'y') then
                        NextToken
                     else
                        Error(97);
                     end {if}
                  else
                     Error(97);
                  if size = directPage then
                     optype := i_dp_s_y
                  else Error(96);
                  end {else if}
               else
                  Error(97);
               end {if token.kind = ident}
            else Error(97);
            end {if token.kind = commach}
         else if token.kind = rparench then begin
            NextToken;
            if token.kind = commach then begin
               NextToken;
               if token.kind = ident then begin
                  if RegCompare(token.name, 'y') then
                     NextToken
                  else
                     Error(97);
                  end {if}
               else Error(97);
               if size = directPage then
                  optype := i_dp_y
               else Error(96);
               end {if}
            else begin
               if size = directPage then
                  optype := i_dp
               else if size = absoluteaddress then
                  optype := i_op
               else
                  Error(96);
               end; {else}
            end {else if token.kind = rparench}
         else Error(12);
         end {if}

      else if token.kind = lbrackch then begin
         NextToken;
         Exp([commach,rbrackch], false);
         Match(rbrackch,24);
         if token.kind = commach then begin
            NextToken;
            if token.kind = ident then begin
               if RegCompare(token.name, 'y') then
                  NextToken
               else
                  Error(97);
               end {if}
            else Error(97);
            if size = directPage then
               optype := li_dp_y
            else Error(96);
            end {if}
         else begin
            if size = directPage then
               optype := li_dp
            else if size = absoluteaddress then
               optype := i_la
            else
               Error(96);
            end; {else}
         end {else if}

      else if token.kind = poundch then begin
         optype := imm;
         NextToken;
         if token.kind = ltch then begin
            NextToken;
            Exp([semicolonch], true);
            end {if}
         else if token.kind = gtch then begin
            NextToken;
            Exp([semicolonch], true);
            if isConstant then
               value := value >> 8
            else
               code^.q := shift8;
            end {else if}
         else if token.kind = carotch then begin
            NextToken;
            Exp([semicolonch], true);
            if isConstant then
               value := value >> 16
            else
               code^.q := shift16;
            end {else if}
         else
            Exp([semicolonch], true);
         end {else if}

      else begin
         if token.kind = ident then
            if RegCompare(token.name, 'a') then begin
               optype := acc;
               NextToken;
               goto 2;
               end; {if}
         Exp([commach,semicolonch], true);
         if token.kind = commach then begin
            NextToken;
            if token.kind = ident then begin
               if RegCompare(token.name, 'x') then begin
                  NextToken;
                  if size = directPage then
                     optype := dp_x
                  else if size = absoluteaddress then
                     optype := op_x
                  else
                     optype := long_x;
                  end {if}
               else if RegCompare(token.name, 'y') then begin
                  NextToken;
                  if size = directPage then
                     optype := dp_y
                  else if size = absoluteaddress then
                     optype := op_y
                  else
                     Error(96);
                  end {else if}
               else if RegCompare(token.name, 's') then begin
                  NextToken;
                  if size = directPage then
                     optype := dp_s
                  else Error(96);
                  end {else if}
               else Error(97);
               end {if token.kind = ident}
            else Error(97);
            end {if}
         else begin
            if size = directPage then
               optype := dp
            else if size = absoluteaddress then
               optype := op
            else
               optype := la;
            end; {else}
         end; {else}

2:    {make sure the operand is valid}
      if nopcodes[opc,optype] = 0 then begin
         if optype = i_dp_x then
            optype := i_op_x
         else if optype = i_dp then
            optype := i_op
         else if optype = dp then
            optype := op
         else if optype = dp_x then
            optype := op_x
         else if optype = dp_y then
            optype := op_y;
         if nopcodes[opc,optype] = 0 then
            if optype = op then
               optype := la;
         if nopcodes[opc,optype] = 0 then
            Error(98);
         end; {if}

      code^.s := nopcodes[opc,optype];

      if optype = acc then
         code^.r := ord(implied)
      else if optype = imm then
         code^.r := ord(imm)
      else if optype in [la,long_x] then
         code^.r := ord(longabsolute)
      else if optype in [op,op_x,op_y,i_op,i_op_x,i_la] then
         code^.r := ord(absolute)
      else
         code^.r := ord(direct);
      end {if opc <= o_tsb}

   {handle data declarations}
   else if opc <= o_dcl then begin
      Exp([semicolonch], true);
      code^.s := d_add;
      if opc = o_dcb then
         code^.r := ord(direct)
      else if opc = o_dcw then
         code^.r := ord(absolute)
      else
         code^.r := ord(longabsolute);
      end {if opc <= o_dcl}

   {handle the brk instruction}
   else if opc = o_brk then begin
      Exp([semicolonch], true);
      code^.r := ord(direct);
      code^.s := 0;
      end {if opc = o_brk}

   {handle moves}
   else if opc in [o_mvn,o_mvp] then begin
      if opc = o_mvn then
         code^.s := $54
      else
         code^.s := $44;
      Gen0(pc_nat);
      code^.s := d_bmov;
      code^.r := ord(immediate);
      Exp([commach,semicolonch], false);
      if isConstant then begin
         code^.opnd := long(value).msw;
         code^.q := 0;
         end {if}
      else begin
         code^.opnd := value;
         code^.q := shift16;
         end; {else}
      Gen0(pc_nat);
      Match(commach,86);
      code^.s := d_bmov;
      code^.r := ord(immediate);
      Exp([semicolonch], true);
      if isConstant then begin
         code^.opnd := long(value).msw;
         code^.q := 0;
         end {if}
      else begin
         code^.opnd := value;
         code^.q := shift16;
         end; {else}
      goto 3;
      end {if opc in [o_mvn,o_mvp]}

   {handle relative branches}
   else if opc <= o_bvs then begin
      code^.s := ropcodes[opc];
      if token.kind = ident then begin
         code^.llab := FindLabel(token.name, false);
         NextToken;
         code^.lab := nil;
         if opc in [o_brl,o_per] then
            code^.r := ord(longrelative)
         else
            code^.r := ord(relative);
         goto 3;
         end {if}
      else Error(97);
      end {else if opc <= o_bvs}

   {handle implied operand instructions}
   else begin
      code^.s := iopcodes[opc];
      code^.r := ord(implied);
      end;

   {generate the code}
   if operation = minus then
      code^.opnd := -value
   else
      code^.opnd := value;
3: Gen0(pc_nat);

   CheckForComment;
   end; {while}
99:
if doingAsmFunction then
   useGlobalPool := true;
Match(rbracech,23);
end; {AsmStatement}


procedure InitAsm;

{ Initialize the assembler                                      }

begin {AsmInit}
doingAsmFunction := false;
end; {AsmInit}

end.
