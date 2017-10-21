{$optimize 1}
{---------------------------------------------------------------}
{                                                               }
{  Parser                                                       }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  DoDeclaration - process a variable or function declaration   }
{  DoStatement - process a statement from a function            }
{  InitParser - initialize the parser                           }
{  Match - insure that the next token is of the specified type  }
{  TermParser - shut down the parser                            }
{  TypeSpecifier - handle a type specifier                      }
{                                                               }
{---------------------------------------------------------------}

unit Parser;

{$LibPrefix '0/obj/'}

interface

uses CCommon, Table, MM, CGI, Scanner, Header, Symbol, Expression, Asm;

{$segment 'parser'}

{---------------------------------------------------------------}

procedure DoDeclaration (doingPrototypes: boolean);

{ process a variable or function declaration                    }
{                                                               }
{ parameters:                                                   }
{       doingPrototypes - are we processing a parameter list?   }


procedure DoStatement;

{ process a statement from a function                           }


procedure InitParser;

{ Initialize the parser                                         }


procedure Match (kind: tokenEnum; err: integer);

{ insure that the next token is of the specified type           }
{                                                               }
{  parameters:                                                  }
{       kind - expected token kind                              }
{       err - error number if the expected token is not found   }


procedure TermParser;

{ shut down the parser                                          }


procedure TypeSpecifier (doingFieldList,isConstant: boolean);

{ handle a type specifier                                       }
{                                                               }
{ parameters:                                                   }
{       doingFieldList - are we processing a field list?        }
{       isConstant - did we already find a constsy?             }

{---------------------------------------------------------------}

implementation

const
   maxBitField = 32;                    {max # of bits in a bit field}
 
type

   identList = ^identNode;              {list of ids; used for initializers}
   identNode = record
      next: identList;
      id: identPtr;
      end;

   { The switch record is used to record the values for the     }
   { switch jump table.  The linked list of entries is in order }
   { of increasing switch value (val).                          }

   switchPtr = ^switchRecord;           {switch label table entry}
   switchRecord = record
      next,last: switchPtr;             {doubly linked list (for inserts)}
      lab: integer;                     {label to branch to}
      val: longint;                     {switch value}
      end;

                                        {token stack}
                                        {-----------}
   tokenStackPtr = ^tokenStackRecord;
   tokenStackRecord = record
      next: tokenStackPtr;
      token: tokenType;
      end;
                                        {statement stack}
                                        {---------------}
   statementPtr = ^statementRecord;
                                        {kinds of nestable statements}
   statementKind = (compoundSt,ifSt,elseSt,doSt,whileSt,forSt,switchSt);
   statementRecord = record             {element of the statement stack}
      next: statementPtr;               {next element on the stack}
      breakLab, continueLab: integer;   {branch points for break, continue}
      case kind: statementKind of
         compoundSt: (
            doingDeclaration: boolean;  {doing declarations? (or statements)}
            );
         ifSt: (
            ifLab: integer;             {branch point}
            );
         elseSt: (
            elseLab: integer;           {branch point}
            );
         doSt: (
            doLab: integer;             {branch point}
            );
         whileSt: (
            whileTop: integer;          {label at top of while loop}
            whileEnd: integer;          {label at bottom of while loop}
            );
         forSt: (
            forLoop: integer;           {branch here to loop}
            e3List: tokenStackPtr;      {tokens for last expression}
            );
         switchSt: (
            maxVal: longint;            {max switch value}
            isLong: boolean;            {do long switch?}
            ln: integer;                {temp var number}
            size: integer;              {temp var size}
            labelCount: integer;        {# of switch labels}
            switchExit: integer;        {branch point}
            switchLab: integer;         {branch point}
            switchList: switchPtr;      {list of labels and values}
            switchDefault: integer;     {default branch point}
            );
      end;

var
   doingMain: boolean;                  {are we processing the main function?}
   firstCompoundStatement: boolean;     {are we doing a function level compound statement?}
   fType: typePtr;                      {return type of the current function}
   initializerList: identList;          {list of initialized identifiers}
   isForwardDeclared: boolean;          {is the field list component           }
                                        { referenceing a forward struct/union? }
   isFunction: boolean;                 {is the declaration a function?}
   isPascal: boolean;                   {has the pascal modifier been used?}
                                        { (set by DoDeclaration)}
   returnLabel: integer;                {label for exit point}
   skipDeclarator: boolean;             {for enum,struct,union with no declarator}
   statementList: statementPtr;         {list of open statements}

                                        {parameter processing variables}
                                        {------------------------------}
   lastParameter: identPtr;             {next parameter to process}
   numberOfParameters: integer;         {number of indeclared parameters}
   pfunc: identPtr;                     {func. for which parms are being defined}
   protoType: typePtr;                  {type from a parameter list}
   protoVariable: identPtr;             {variable from a parameter list}

                                        {type info for the current declaration}
                                        {-------------------------------------}
   storageClass: tokenEnum;             {storage class of the declaration}
{  typeSpec: typePtr;    (in CCommon)   {type specifier}

{-- Parser Utility Procedures ----------------------------------}

procedure Match {kind: tokenEnum; err: integer};

{ insure that the next token is of the specified type           }
{                                                               }
{  parameters:                                                  }
{       kind - expected token kind                              }
{       err - error number if the expected token is not found   }

begin {Match}
if token.kind = kind then
   NextToken
else
   Error(err);
end; {Match}


procedure SkipStatement;

{ Skip the remainder of the current statement                   }

var
   bracketCount: integer;               {for error skip}

begin {SkipStatement}
bracketCount := 0;
while (token.kind <> eofsy) and
   ((token.kind <> semicolonch) or (bracketCount <> 0)) do begin
   if token.kind = lbrackch then
      bracketCount := bracketCount+1;
   if token.kind = rbrackch then
      if bracketCount <> 0 then
         bracketCount := bracketCount-1;
   NextToken;
   end; {while}
if token.kind = semicolonch then
   NextToken;
end; {SkipStatement}


procedure GotoLabel (op: pcodes);

{ Find a label in the goto label list, creating one if one      }
{ does not already exist.  Generate the label or a jump to it   }
{ based on op.                                                  }
{                                                               }
{ paremeters:                                                   }
{       op - operation code to create                           }

label 1;

var
   gt: gotoPtr;                         {work pointer}

begin {GotoLabel}
gt := gotoList;                         {try to find an existing label}
while gt <> nil do begin
   if gt^.name^ = token.name^ then
      goto 1;
   gt := gt^.next;
   end; {while}
gt := pointer(Malloc(sizeof(gotoRecord))); {no label record exists: create one}
gt^.next := gotoList;
gotoList := gt;
gt^.name := token.name;
gt^.lab := GenLabel;
gt^.defined := false;
1:
if op = dc_lab then begin
   if gt^.defined then
      Error(77)
   else begin
      gt^.defined := true;
      Gen1(dc_lab, gt^.lab);
      end; {else}
   end {if}
else
   Gen1(pc_ujp, gt^.lab);
end; {GotoLabel}


{-- Statements -------------------------------------------------}

procedure CompoundStatement (makeSymbols: boolean);

{ handle a compound statement                                   }
{								}
{ Parameters:							}
{    makeSymbols - create a symbol table? (False for a		}
{       function's outer wrapper, true for imbeded statements)	}

var
   stPtr: statementPtr;                 {for creating a compound statement record}

begin {CompoundStatement}
Match(lbracech,27);                     {make sure there is an opening '{'}
new(stPtr);                             {create a statement record}
stPtr^.next := statementList;
statementList := stPtr;
stPtr^.kind := compoundSt;
if makeSymbols then			{create a symbol table}
   PushTable;
stPtr^.doingDeclaration := true;        {allow declarations}
initializerList := nil;                 {no initializers, yet}
end; {CompoundStatement}


procedure EndCompoundStatement;

{ finish off a compound statement                               }

var
   dumpLocal: boolean;                  {dump the local memory pool?}
   tl: tempPtr;                         {work pointer}
   stPtr: statementPtr;                 {work pointer}

begin {EndCompoundStatement}
dumpLocal := false;
stPtr := statementList;                 {pop the statement record}
statementList := stPtr^.next;
doingFunction := statementList <> nil;  {see if we're done with the function}
if not doingFunction then begin         {if so, finish it off}
   Gen1(dc_lab, returnLabel);
   with fType^ do                       {generate the pc_ret instruction}
      case kind of
         scalarType  : Gen0t(pc_ret, baseType);
         arrayType   : ;
         structType  ,
         unionType   ,
         pointerType : Gen0t(pc_ret, cgULong);
         functionType: ;
         enumConst   : ;
         enumType    : Gen0t(pc_ret, cgWord);
         definedType : ;
         otherwise: Error(57);
         end; {case}
   Gen0 (dc_enp);                       {finish the segment}
   CheckGotoList;                       {make sure all labels are declared}
   while tempList <> nil do begin       {dump the local labels}
      tl := tempList;
      tempList := tl^.next;
      dispose(tl);
      end; {while}
   dumpLocal := true;                   {dump the local pool}
   nameFound := false;                  {no pc_nam for the next function (yet)}
   end; {if}
PopTable;				{remove this symbol table}
dispose(stPtr);                         {dump the record}
if dumpLocal then begin
   useGlobalPool := true;               {start using the global memory pool}
   LInit;                               {dispose of the local memory pool}
   end; {if}
NextToken;                              {remove the rbracech token}
end; {EndCompoundStatement}


procedure Statement;

{ handle a statement                                            }

label 1;

var
   lToken,tToken: tokenType;            {for look-ahead}
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}


   function GetSwitchRecord: statementPtr;

   { Find the enclosing switch statement                        }
   {                                                            }
   { Returns a pointer to the closest switch statement record,  }
   { or nil if there are none.                                  }

   label 1;

   var
      stPtr: statementPtr;              {work pointer}

   begin {GetSwitchRecord}
   stPtr := statementList;
   while stPtr <> nil do begin
      if stPtr^.kind = switchSt then
         goto 1;
      stPtr := stPtr^.next;
      end; {while}
1: GetSwitchRecord := stPtr;
   end; {GetSwitchRecord}


   procedure AssignmentStatement;
 
   { handle an asignment statement                               }
 
   begin {AssignmentStatement}
   if token.kind in startExpression then begin
      Expression(normalExpression, [semicolonch]);
      if expressionType^.baseType <> cgVoid then
         Gen0t(pc_pop, UsualUnaryConversions);
      if token.kind = semicolonch then
         NextToken
      else begin
         Error(22);
         SkipStatement;
         end; {else}
      end {if}
   else begin
      NextToken;
      Error(92);
      end; {else}
   end; {AssignmentStatement}


   procedure BreakStatement;
 
   { handle a break statement                                    }
 
   label 1,2;

   var
      stPtr: statementPtr;              {work pointer}

   begin {BreakStatement}
   stPtr := statementList;              {find the proper statement}
   while stPtr <> nil do begin
      if stPtr^.kind in [whileSt,doSt,forSt,switchSt] then
         goto 1;
      stPtr := stPtr^.next;
      end; {while}
   Error(76);
   goto 2;

1: if stPtr^.breakLab = 0 then          {if there is no break label, create one}
      stPtr^.breakLab := GenLabel;
   Gen1(pc_ujp, stPtr^.breakLab);       {branch to the break label}
2:
   NextToken;                           {skip the 'break' token}
   Match(semicolonch,22);               {insist on a closing ';'}
   end; {BreakStatement}


   procedure CaseStatement;
 
   { handle a case statement                                     }

   var
      stPtr: statementPtr;              {switch record for this case label}
      swPtr,swPtr2: switchPtr;          {work pointers for inserting new entry}
      val: integer;                     {case label value}

   begin {CaseStatement}
   while token.kind = casesy do begin
      NextToken;                        {skip the 'case' token}
      stPtr := GetSwitchRecord;         {get the proper switch record}
      Expression(arrayExpression, [colonch]); {evaluate the branch condition}
      val := long(expressionValue).lsw;
      if val <> expressionValue then
         if not stPtr^.isLong then
            Error(71);
      if stPtr = nil then
         Error(72)
      else begin
         new(swPtr2);                   {create the new label table entry}
         swPtr2^.lab := GenLabel;
         Gen1(dc_lab, swPtr2^.lab);
         swPtr2^.val := expressionValue;
         swPtr := stPtr^.switchList;
         if swPtr = nil then begin      {enter it in the table}
            swPtr2^.last := nil;
            swPtr2^.next := nil;
            stPtr^.switchList := swPtr2;
            stPtr^.maxVal := expressionValue;
            stPtr^.labelCount := 1;
            end {if}
         else begin
            while (swPtr^.next <> nil) and (swPtr^.val < expressionValue) do
               swPtr := swPtr^.next;
            if swPtr^.val = expressionValue then
               Error(73)
            else if swPtr^.val > expressionValue then begin
               swPtr2^.next := swPtr;
               if swPtr^.last = nil then
                  stPtr^.switchList := swPtr2
               else
                  swPtr^.last^.next := swPtr2;
               swPtr2^.last := swPtr^.last;
               swPtr^.last := swPtr2;
               end {else if}
            else begin {at end of list}
               swPtr2^.next := nil;
               swPtr2^.last := swPtr;
               swPtr^.next := swPtr2;
               stPtr^.maxVal := expressionValue;
               end; {else}
            stPtr^.labelCount := stPtr^.labelCount + 1;
            end; {else}
         end; {else}

      Match(colonch,29);                {get the colon}
      end; {while}
   Statement;                           {process the labeled statement}
   end; {CaseStatement}


   procedure ContinueStatement;
 
   { handle a continue statement                                 }
 
   label 1,2;

   var
      stPtr: statementPtr;              {work pointer}

   begin {ContinueStatement}
   stPtr := statementList;              {find the proper statement}
   while stPtr <> nil do begin
      if stPtr^.kind in [whileSt,doSt,forSt] then
         goto 1;
      stPtr := stPtr^.next;
      end; {while}
   Error(75);
   goto 2;

1: if stPtr^.continueLab = 0 then       {if there is no continue label, create one}
      stPtr^.continueLab := GenLabel;
   Gen1(pc_ujp, stPtr^.continueLab);    {branch to the continue label}
2:
   NextToken;                           {skip the 'continue' token}
   Match(semicolonch,22);               {insist on a closing ';'}
   end; {ContinueStatement}


   procedure DefaultStatement;
 
   { handle a default statement                                  }
 
   var
      stPtr: statementPtr;              {work pointer}

   begin {DefaultStatement}
   NextToken;                           {skip the 'default' token}
   Match(colonch,29);                   {get the colon}
   stPtr := GetSwitchRecord;            {record the presense of a default label}
   if stPtr = nil then
      Error(72)
   else if stPtr^.switchDefault <> 0 then
      Error(74)
   else begin
      stPtr^.switchDefault := GenLabel;
      Gen1(dc_lab, stPtr^.switchDefault);
      end; {else}
   Statement;                           {process the labeled statement}
   end; {DefaultStatement}


   procedure DoStatement;
 
   { handle a do statement                                       }
 
   var
      lab: integer;                     {branch label}
      stPtr: statementPtr;              {work pointer}
 
   begin {DoStatement}
   NextToken;                           {skip the 'do' token}
   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := doSt;
   lab := GenLabel;                     {create the branch label}
   Gen1(dc_lab, lab);
   stPtr^.doLab := lab;
   stPtr^.breakLab := 0;
   stPtr^.continueLab := 0;
   Statement;                           {process the first loop body statement}
   end; {DoStatement}


   procedure ForStatement;
 
   { handle a for statement                                      }
 
   var
      errorFound: boolean;              {did we find an error?}
      forLoop, continueLab, breakLab: integer; {branch points}
      lType: typePtr;                   {type of "left" expression}
      parencount: integer;              {number of unmatched '(' chars}
      stPtr: statementPtr;              {work pointer}
      tl,tk: tokenStackPtr;             {for forming expression list}

   begin {ForStatement}
   NextToken;                           {skip the 'for' token}
   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := forSt;
   forLoop := GenLabel;                 {create the branch labels}
   continueLab := GenLabel;
   breakLab := GenLabel;
   stPtr^.forLoop := forLoop;
   stPtr^.continueLab := continueLab;
   stPtr^.breakLab := breakLab;

   Match(lparench,13);                  {evaluate the start condition}
   if token.kind <> semicolonch then begin
      Expression(normalExpression, [semicolonch]);
      Gen0t(pc_pop, UsualUnaryConversions);
      end; {if}
   Match(semicolonch,22);

   Gen1(dc_lab, forLoop);               {this label points to the condition}
   if token.kind <> semicolonch then    {handle the loop test}
      begin                             {evaluate the expression}
      Expression(normalExpression, [semicolonch]);
      CompareToZero(pc_neq);            {Evaluate the condition}
      Gen1(pc_fjp, breakLab);
      end; {if}
   Match(semicolonch,22);

   tl := nil;                           {collect the tokens for the last expression}
   parencount := 0;
   errorFound := false;
   while (token.kind <> eofsy)
      and ((token.kind <> rparench) or (parencount <> 0))
      and (token.kind <> semicolonch) do begin
      new(tk);                          {place the token in the list}
      tk^.next := tl;
      tl := tk;
      tk^.token := token;
      if token.kind = lparench then     {allow parens in the expression}
         parencount := parencount+1
      else if token.kind = rparench then
         parencount := parencount-1;
      NextToken;                        {next token}
      end; {while}
   if errorFound then                   {if an error was found, dump the list}
      while tl <> nil do begin
         tk := tl;
         tl := tl^.next;
         dispose(tk);
         end; {while}
   stPtr^.e3List := tl;                 {save the list}
   Match(rparench,12);                  {get the closing for loop paren}

   Statement;                           {process the first loop body statement}
   end; {ForStatement}


   procedure IfStatement;
 
   { handle an if statement                                      }
 
   var
      lab: integer;                     {branch label}
      lType: typePtr;                   {type of "left" expression}
      stPtr: statementPtr;              {work pointer}
 
   begin {IfStatement}
   NextToken;                           {skip the 'if' token}
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression, [rparench]);
   Match(rparench, 12);

   lab := GenLabel;                     {create the branch label}
   CompareToZero(pc_neq);               {evaluate the condition}
   Gen1(pc_fjp, lab);

   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := ifSt;
   stPtr^.ifLab := lab;
   Statement;                           {process the 'true' statement}
   end; {IfStatement}


   procedure GotoStatement;
 
   { handle a goto statement                                     }
 
   begin {GotoStatement}
   NextToken;                           {skip the 'goto' token}
   if token.kind in [ident,typedef] then begin
      GotoLabel(pc_ujp);                {jump to the label}
      NextToken;                        {skip the token}
      end {if}
   else
      Error(9);                         {flag the error}
   Match(semicolonch, 22);              {insist on a closing ';'}
   end; {GotoStatement}


   procedure LabelStatement;
 
   { handle a labeled statement                                  }
 
   begin {LabelStatement}
   GotoLabel(dc_lab);                   {define the label}
   NextToken;                           {skip the label}
   if token.kind = colonch then         {if present, skip the colon}
      NextToken
   else begin                           {bad statement - flag error and skip it}
      Error(31);
      SkipStatement;
      end; {else}
   end; {LabelStatement}


   procedure ReturnStatement;
 
   { handle a return statement                                   }

   var
      id: identPtr;                     {structure id}
      size: longint;                    {size of the struct/union}
      tk: tokenType;                    {structure name token}

   begin {ReturnStatement}
   NextToken;                           {skip the 'return' token}
   if token.kind <> semicolonch then    {if present, evaluate the return value}
      begin
      if fType^.kind in [structType,unionType] then begin
         tk.kind := ident;
         tk.class := identifier;
         tk.name := @'@struct';
         tk.symbolPtr := nil;
         id := FindSymbol(tk, variableSpace, false, true);
         Gen1Name(pc_lao, 0, id^.name);
         size := fType^.size;
         end; {if}
      Expression(normalExpression, [semicolonch]);
      AssignmentConversion(fType, expressionType, lastWasConst, lastConst,
         true, true);
      case fType^.kind of
         scalarType:    Gen2t(pc_str, 0, 0, fType^.baseType);
         enumType:      Gen2t(pc_str, 0, 0, cgWord);
         pointerType:   Gen2t(pc_str, 0, 0, cgULong);
         structType,
         unionType:     begin
                        Gen2(pc_mov, long(size).msw, long(size).lsw);
                        Gen0t(pc_pop, cgULong);
                        end;
         otherwise:     ;
         end; {case}
      end; {if}
   Gen1(pc_ujp, returnLabel);           {branch to the exit point}
   Match(semicolonch, 22);              {insist on a closing ';'}
   end; {ReturnStatement}


   procedure SwitchStatement;
 
   { handle a switch statement                                   }
 
   var
      stPtr: statementPtr;              {work pointer}
      tp: typePtr;                      {for checking type}
 
   begin {SwitchStatement}
   NextToken;                           {skip the 'switch' token}
   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := switchSt;
   stPtr^.maxVal := -maxint4;
   stPtr^.isLong := false;
   stPtr^.labelCount := 0;
   stPtr^.switchLab := GenLabel;
   stPtr^.switchExit := GenLabel;
   stPtr^.breakLab := stPtr^.switchExit;
   stPtr^.switchList := nil;
   stPtr^.switchDefault := 0;
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression,[rparench]);
   Match(rparench, 12);
   tp := expressionType;                {make sure the expression is integral}
   while tp^.kind = definedType do
      tp := tp^.dType;
   case tp^.kind of

      scalarType:
         if tp^.baseType in [cgLong,cgULong] then begin
            stPtr^.isLong := true;
            stPtr^.size := cgLongSize;
            stPtr^.ln := GetTemp(cgLongSize);
            Gen2t(pc_str, stPtr^.ln, 0, cgLong);
            end {if}
         else if tp^.baseType in [cgByte,cgUByte,cgWord,cgUWord] then begin
            stPtr^.isLong := false;
            stPtr^.size := cgWordSize;
            stPtr^.ln := GetTemp(cgWordSize);
            Gen2t(pc_str, stPtr^.ln, 0, cgWord);
            end {else if}
         else
            Error(71);

      enumType: begin
         stPtr^.isLong := false;
         stPtr^.size := cgWordSize;
         stPtr^.ln := GetTemp(cgWordSize);
         Gen2t(pc_str, stPtr^.ln, 0, cgWord);
         end;

      otherwise:
         Error(71);
      end; {case}
   Gen1(pc_ujp, stPtr^.switchLab);      {branch to the xjp instruction}
   Statement;                           {process the loop body statement}
   end; {SwitchStatement}


   procedure WhileStatement;
 
   { handle a while statement                                    }

   var
      lType: typePtr;                   {type of "left" expression}
      stPtr: statementPtr;              {work pointer}
      top, endl: integer;               {branch points}

   begin {WhileStatement}
   NextToken;                           {skip the 'while' token}
   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := whileSt;
   top := GenLabel;                     {create the branch labels}
   endl := GenLabel;
   stPtr^.whileTop := top;
   stPtr^.whileEnd := endl;
   stPtr^.breakLab := endl;
   stPtr^.continueLab := top;
   Gen1(dc_lab, top);                   {define the top label}
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression, [rparench]);
   Match(rparench, 12);
   CompareToZero(pc_neq);               {evaluate the condition}
   Gen1(pc_fjp, endl);
   Statement;                           {process the first loop body statement}
   end; {WhileStatement}

begin {Statement}
1:
{if trace names are enabled and a line # is due, generate it}
if traceBack or debugFlag then
   if nameFound or debugFlag then
      if lastLine <> lineNumber then begin
         lastLine := lineNumber;
         Gen2(pc_lnm, lineNumber, ord(debugType));
         end; {if}

{handle the statement}
case token.kind of
   asmsy:               begin
                        NextToken;
                        AsmStatement;
                        end;
   breaksy:             BreakStatement;
   casesy:              CaseStatement;
   continuesy:          ContinueStatement;
   defaultsy:           DefaultStatement;
   dosy:                DoStatement;
   elsesy:              begin Error(25); SkipStatement; end;
   forsy:               ForStatement;
   gotosy:              GotoStatement;
   typedef,
   ident:               begin
                        lPrintMacroExpansions := printMacroExpansions;
                        printMacroExpansions := false;
                        lToken := token;
                        NextToken;
                        tToken := token;
                        PutBackToken(token, true);
                        token := lToken;
                        printMacroExpansions := lPrintMacroExpansions;
                        if tToken.kind = colonch then begin
                           LabelStatement;
                           goto 1;
                           end {if}
                        else
                           AssignmentStatement;
                        end;
   ifsy:                IfStatement;
   lbracech:            CompoundStatement(true);
   returnsy:            ReturnStatement;
   semicolonch:         NextToken;
   switchsy:            SwitchStatement;
   whilesy:             WhileStatement;
   otherwise:           AssignmentStatement;
   end; {case}
end; {Statement}


procedure EndDoStatement;

{ finish off a do statement                                     }

var
   lType: typePtr;                      {type of "left" expression}
   stPtr: statementPtr;                 {work pointer}

begin {EndDoStatement}
stPtr := statementList;                 {get the statement record}
if token.kind = whilesy then begin      {if a while clause exists, process it}
   NextToken;                           {skip the 'while' token}
   if stPtr^.continueLab <> 0 then      {create the continue label}
      Gen1(dc_lab, stPtr^.continueLab);
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression, [rparench]);
   Match(rparench, 12);
   CompareToZero(pc_equ);               {evaluate the condition}
   Gen1(pc_fjp, stPtr^.doLab);
   Match(semicolonch, 22);              {process the closing ';'}
   end {if}
else
   Error(30);                           {'while' expected}
if stPtr^.breakLab <> 0 then            {create the break label}
   Gen1(dc_lab, stPtr^.breakLab);
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
end; {EndDoStatement}


procedure EndIfStatement;

{ finish off an if statement                                    }

var
   lab1,lab2: integer;                  {branch labels}
   stPtr: statementPtr;                 {work pointer}

begin {EndIfStatement}
stPtr := statementList;                 {get the label to branch to}
lab1 := stPtr^.ifLab;
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);

if token.kind = elsesy then begin       {if an else clause exists, process it}
   NextToken;                           {skip 'else'}
   lab2 := GenLabel;                    {create the branch label}
   Gen1(pc_ujp, lab2);                  {branch past the else clause}
   Gen1(dc_lab, lab1);                  {create label for if to branch to}
   new(stPtr);                          {create a statement record}
   stPtr^.next := statementList;
   statementList := stPtr;
   stPtr^.kind := elseSt;
   stPtr^.elseLab := lab2;
   Statement;                           {evaluate the else clause}
   end {if}
else
   Gen1(dc_lab, lab1);                  {create label for if to branch to}
end; {EndIfStatement}


procedure EndElseStatement;

{ finish off an else clause                                     }

var
   stPtr: statementPtr;                 {work pointer}

begin {EndElseStatement}
stPtr := statementList;                 {create the label to branch to}
Gen1(dc_lab, stPtr^.elseLab);
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
end; {EndElseStatement}


procedure EndForStatement;

{ finish off a for statement                                    }

var
   ltoken: tokenType;                   {for putting ; on stack}
   stPtr: statementPtr;                 {work pointer}
   tl,tk: tokenStackPtr;                {for forming expression list}
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}

begin {EndForStatement}
stPtr := statementList;
Gen1(dc_lab, stPtr^.continueLab);       {define the continue label}

tl := stPtr^.e3List;                    {place the expression back in the list}
if tl <> nil then begin
   PutBackToken(token, false);
   ltoken.kind := semicolonch;
   ltoken.class := reservedSymbol;
   PutBackToken(ltoken, false);
   while tl <> nil do begin
      PutBackToken(tl^.token, false);
      tk := tl;
      tl := tl^.next;
      dispose(tk);
      end; {while}
   lPrintMacroExpansions := printMacroExpansions; {inhibit token echo}
   printMacroExpansions := false;
   NextToken;                           {evaluate the expression}
   Expression(normalExpression, [semicolonch]);
   Gen0t(pc_pop, UsualUnaryConversions);
   NextToken;                           {skip the seminolon}
   printMacroExpansions := lPrintMacroExpansions;
   end; {if}

Gen1(pc_ujp, stPtr^.forLoop);           {loop to the test}
Gen1(dc_lab, stPtr^.breakLab);          {create the exit label}
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
end; {EndForStatement}


procedure EndSwitchStatement;

{ finish off a switch statement                                 }

const
   sparse = 5;                          {label to tableSize ratio for sparse table}

var
   default: integer;                    {default label}
   ltp: baseTypeEnum;                   {base type}
   minVal: integer;                     {min switch value}
   stPtr: statementPtr;                 {work pointer}

                                        {copies of vars (for efficiency)}
                                        {-------------------------------}
   exitLab: integer;                    {label at the end of the jump table}
   isLong: boolean;                     {is the case expression long?}
   swPtr,swPtr2: switchPtr;             {switch label table list}

begin {EndSwitchStatement}
stPtr := statementList;                 {get the statement record}
exitLab := stPtr^.switchExit;           {get the exit label}
isLong := stPtr^.isLong;                {get the long flag}
swPtr := stPtr^.switchList;             {Skip further generation if there were}
if swPtr <> nil then begin              { no labels.                          }
   default := stPtr^.switchDefault;     {get a default label}
   if default = 0 then
      default := exitLab;
   Gen1(pc_ujp, exitLab);               {branch past the indexed jump}
   Gen1(dc_lab, stPtr^.switchLab);      {create the label for the xjp table}
   if isLong then                       {decide on a base type}
      ltp := cgLong
   else
      ltp := cgWord;
   if stPtr^.isLong
      or (((stPtr^.maxVal-swPtr^.val) div stPtr^.labelCount) > sparse) then
      begin

      {Long expressions and sparse switch statements are handled as a   }
      {series of if-goto tests.                                         }
      while swPtr <> nil do begin       {generate the compares}
         if isLong then
            GenLdcLong(swPtr^.val)
         else
            Gen1t(pc_ldc, long(swPtr^.val).lsw, cgWord);
         Gen2t(pc_lod, stPtr^.ln, 0, ltp);
         Gen0t(pc_equ, ltp);
         Gen1(pc_tjp, swPtr^.lab);
         swPtr2 := swPtr;
         swPtr := swPtr^.next;
         dispose(swPtr2);
         end; {while}
      Gen1(pc_ujp, default);            {anything else goes to default}
      end {if}
   else begin

      {compact word switch statements are handled with xjp}
      minVal := long(swPtr^.val).lsw;   {record the min label value}
      Gen2t(pc_lod, stPtr^.ln, 0, ltp); {get the value}
      Gen1t(pc_dec, minVal, cgWord);    {adjust the range}
      Gen1(pc_xjp, ord(stPtr^.maxVal-minVal+1)); {do the indexed jump}
      while swPtr <> nil do begin       {generate the jump table}
         while minVal < swPtr^.val do begin
            Gen1(pc_add, default);
            minVal := minVal+1;
            end; {while}
         minVal := minVal+1;
         Gen1(pc_add, swPtr^.lab);
         swPtr2 := swPtr;
         swPtr := swPtr^.next;
         dispose(swPtr2);
         end; {while}
      Gen1(pc_add, default);
      end; {if}
   Gen1(dc_lab, exitLab);               {generate the default label}
   end {if}
else begin
   Gen1(pc_ujp, exitLab);               {branch past the indexed jump}
   Gen1(dc_lab, stPtr^.switchLab);      {create the label for the xjp table}

   default := stPtr^.switchDefault;     {if there is one, jump to the default label}
   if default <> 0 then
      Gen1(pc_ujp, default);

   Gen1(dc_lab, exitLab);               {generate the default label}
   end; {else}
FreeTemp(stPtr^.ln, stPtr^.size);       {release temp variable}
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
end; {EndSwitchStatement}


procedure EndWhileStatement;

{ finish off a while statement                                  }

var
   stPtr: statementPtr;                 {work pointer}

begin {EndWhileStatement}
stPtr := statementList;                 {loop to the test}
Gen1(pc_ujp, stPtr^.whileTop);
Gen1(dc_lab, stPtr^.whileEnd);          {create the exit label}
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
end; {EndWhileStatement}

{-- Type declarations ------------------------------------------}

procedure Declarator(tPtr: typePtr; var variable: identPtr; space: spaceType;
   doingPrototypes: boolean);

{ handle a declarator                                           }
{                                                               }
{ parameters:                                                   }
{       tPtr - pointer to the type to use                       }
{       variable - pointer to variable being defined            }
{       space - variable space to use                           }
{       doingPrototypes - are we compiling prototype parameter  }
{               declarations?                                   }

label 1;

type
   typeDefPtr = ^typeDefRecord;         {for stacking type records}
   typeDefRecord = record
      next: typeDefPtr;
      typeDef: typePtr;
      end;
   pointerListPtr = ^pointerList;       {for stacking pointer types}
   pointerList = record
      next: pointerListPtr;
      isConstant: boolean;
      end;

var
   i: integer;                          {loop variable}
   lastWasIdentifier: boolean;          {for deciding if the declarator is a fuction}
   lastWasPointer: boolean;             {was the last type a pointer?}
   newName: stringPtr;                  {new symbol name}
   parameterStorage: boolean;           {is the new symbol in a parm list?}
   state: stateKind;                    {declaration state of the variable}
   tPtr2: typePtr;                      {work pointer}
   tsPtr: typeDefPtr;                   {work pointer}
   typeStack: typeDefPtr;               {stack of type definitions}
   varParmList: boolean;                {did we prototype a variable?}

                                        {for checking function compatibility}
                                        {-----------------------------------}
   checkParms: boolean;                 {do we need to do type checking on the parm?}
   compatible: boolean;			{are the parameters compatible?}
   ftoken: tokenType;                   {for checking extern functions}
   p1,p2,p3: parameterPtr;              {used to trace parameter lists}
   pt1,pt2: typePtr;			{parameter types}
   t1: typePtr;                         {function type}
   tk1,tk2: typeKind;			{parameter type kinds}
   unnamedParm: boolean;                {is this an unnamed prototype?}


   procedure StackDeclarations (var varParmList: boolean);
 
   { stack the declaration operators                            }
   {                                                            }
   { Parameters:                                                }
   {    varParmList - did we create one?                        }
 
   var
      cp,cpList: pointerListPtr;        {pointer list}
      done,done2: boolean;              {for loop termination}
      isPtr: boolean;                   {is the parenthesized expr a ptr?}
      wp: parameterPtr;                 {used to build prototype var list}
      pvar: identPtr;                   {work pointer}
      tPtr2: typePtr;                   {work pointer}
      ttPtr: typeDefPtr;                {work pointer}
      parencount: integer;              {for skipping in parm list}
      lvarParmList: boolean;            {did we prototype a variable?}
 
                                        {variables used to preserve states}
                                        { across recursive calls          }
                                        {---------------------------------}
      lisFunction: boolean;             {local copy of isFunction}
      lisPascal: boolean;               {local copy of isPascal}
      lLastParameter: identPtr;         {next parameter to process}
      lstorageClass: tokenEnum;         {storage class of the declaration}
      ltypeSpec: typePtr;               {type specifier}
      luseGlobalPool: boolean;          {local copy of useGlobalPool}
      lPrintMacroExpansions: boolean;   {local copy of printMacroExpansions}

   begin {StackDeclarations}
   varParmList := false;                {no var parm list, yet}
   lastWasIdentifier := false;          {used to see if the declaration is a fn}
   cpList := nil;
   if token.kind = typedef then
      token.kind := ident;
   case token.kind of

      ident: begin                      {handle 'ident'}
         if space = fieldListSpace then
            variable := nil
         else
            variable := FindSymbol(token, space, true, true);
         newName := token.name;
         if variable = nil then begin
            if storageClass = typedefsy then begin
               tPtr2 := pointer(Calloc(sizeof(typeRecord)));
               {tPtr2^.size := 0;}
               {tPtr2^.saveDisp := 0;}
               tPtr2^.kind := definedType;
               {tPtr^.isConstant := false;}
               tPtr2^.dType := tPtr;
               end {if}
            else
               tPtr2 := tPtr;
            if doingParameters then begin
               if not doingPrototypes then 
                  if not (tPtr2^.kind in
                     [enumConst,structType,unionType,definedType,pointerType])
                     then Error(50);
               parameterStorage := true;
               end; {if}
            end {if}
         else
            checkParms := true;
         NextToken;
         if token.kind = eqch then
            state := initialized;
         lastWasIdentifier := true;
         end;

      asteriskch: begin                 {handle '*' 'declarator'}
         while token.kind = asteriskch do begin
            NextToken;
            new(cp);
            cp^.next := cpList;
            cpList := cp;
            cp^.isConstant := false;
            while token.kind in
               [unsignedsy,signedsy,intsy,longsy,charsy,shortsy,floatsy,
                doublesy,compsy,extendedsy,voidsy,enumsy,structsy,unionsy,
                volatilesy,constsy] do begin
               if token.kind = constsy then
                  cpList^.isConstant := true
               else if token.kind = volatilesy then
                  volatile := true
               else
                  Error(9);
               NextToken;
               end; {while}
            end; {while}
         StackDeclarations(lvarParmList);
         end;

      lparench: begin                   {handle '(' 'declarator' ')'}
         NextToken;
         isPtr := token.kind = asteriskch;
         StackDeclarations(lvarParmList);
         Match(rparench,12);
         if isPtr then
            lastWasIdentifier := false;
         end;

      otherwise:
         if doingPrototypes then begin  {allow for unnamed parameters}
            pvar := pointer(Calloc(sizeof(identRecord)));
            {pvar^.next := nil;}
            {pvar^.saved := 0;}
            pvar^.name := @'?';
            pvar^.itype := tPtr;
            {pvar^.disp := 0;}
            {pvar^.bitDisp := 0;}
            {pvar^.bitsize := 0;}
            {pvar^.initialized := false;}
            {pvar^.iPtr := nil;}
            {pvar^.isForwardDeclared := false;}
            pvar^.class := autosy;
            pvar^.storage := parameter;
            variable := pvar;
            lastWasIdentifier := true;
            newName := nil;
            unnamedParm := true;
            end; {if}

      end; {case}

   while token.kind in [lparench,lbrackch] do begin

      {handle function declarations}
      if token.kind = lparench then begin
         lisPascal := isPascal;         {preserve this flag}
	 PushTable;			{create a symbol table}
                                        {determine if it's a function}
         isFunction := lastWasIdentifier or isFunction;
         varParmList := not isFunction;
         tPtr2 := pointer(GCalloc(sizeof(typeRecord))); {create the function type}
         {tPtr2^.size := 0;}
         {tPtr2^.saveDisp := 0;}
         tPtr2^.kind := functionType;
         {tPtr2^.isConstant := false;}
         {tPtr2^.varargs := false;}
         {tPtr2^.prototyped := false;}
         {tPtr2^.overrideKR := false;}
         {tPtr2^.parameterList := nil;}
         {tPtr2^.isPascal := false;}
         {tPtr2^.toolNum := 0;}
         {tPtr2^.dispatcher := 0;}
         new(ttPtr);
         ttPtr^.next := typeStack;
         typeStack := ttPtr;
         ttPtr^.typeDef := tPtr2;
         NextToken;                        {skip the '(' token}
         if token.kind = voidsy then begin {check for a void prototype}
            lPrintMacroExpansions := printMacroExpansions;
            printMacroExpansions := false;
            NextToken;
            printMacroExpansions := lPrintMacroExpansions;
            if token.kind = rparench then begin
               PutBackToken(token, false);
               NextToken;
               tPtr2^.prototyped := true;
               end
            else begin
               PutBackToken(token, false);
               token.kind := voidsy;
               token.class := reservedSymbol;
               end; {else}
            end; {if}
         if token.kind in               {see if we are doing a prototyped list}
            [autosy,externsy,registersy,staticsy,typedefsy,unsignedsy,intsy,
             longsy,charsy,shortsy,floatsy,doublesy,compsy,extendedsy,voidsy,
             enumsy,structsy,unionsy,typedef,signedsy,constsy] then begin

            {handle a prototype variable list}
            numberOfParameters := 0;    {don't allow K&R parm declarations}
            luseGlobalPool := useGlobalPool; {use global memory}
            useGlobalPool := true;
            done2 := false;
            lisFunction := isFunction;  {preserve global variables}
            ltypeSpec := typeSpec;
            lstorageClass := storageClass;
            with tPtr2^ do begin
               prototyped := true;      {it is prototyped}
               repeat                   {collect the declarations}
                  if (token.kind in [autosy,externsy,registersy,staticsy,
                                     typedefsy,unsignedsy,signedsy,intsy,longsy,
                                     charsy,shortsy,floatsy,doublesy,compsy,
                                     extendedsy,enumsy,structsy,unionsy,
                                     typedef,voidsy,volatilesy,constsy])
                                     then begin
                     lLastParameter := lastParameter;
                     DoDeclaration(true);
                     lastParameter := lLastParameter;
                     if protoType <> nil then begin
                        wp := pointer(Malloc(sizeof(parameterRecord)));
                        wp^.next := parameterList;
                        parameterList := wp;
                        wp^.parameter := protoVariable;
                        wp^.parameterType := protoType;
                        if protoVariable <> nil then begin
                           protoVariable^.pnext := lastParameter;
                           lastParameter := protoVariable;
                           end; {if}
                        end; {if}
                     if token.kind = commach then begin
                        NextToken;
                        if token.kind = dotch then begin
                           NextToken;
                           Match(dotch,89);
                           Match(dotch,89);
                           varargs := true;
                           done2 := true;
                           end; {if}
                        end {if}
                     else
                        done2 := true;
                     end {if}
                  else begin
                     Error(26);
                     parencount := 0;
                     while (token.kind <> eofsy)
                        and ((parencount > 0) or (token.kind <> rparench)) do
                        begin
                        if token.kind = rparench then
                           parencount := parencount-1
                        else if token.kind = lparench then
                           parencount := parencount+1;
                        NextToken;
                        end; {while}
                     done2 := true;
                     end; {else}
               until done2;
               end; {with}
            isFunction := lisFunction;  {restore global variables}
            storageClass := lstorageClass;
            typeSpec := ltypeSpec;
            useGlobalPool := luseGlobalPool;
            end {if prototype}
         else if token.kind = ident then begin

            {handle a K&R variable list}
            if (lint & lintNotPrototyped) <> 0 then
               Error(105);
            if doingFunction or doingPrototypes then
               Error(12)
            else begin
               numberOfParameters := 0; {no function parms yet}
               end; {else}
            repeat                      {make a list of parameters}
               if not doingFunction then begin
                  if token.kind <> ident then begin
                     Error(9);
                     while not (token.kind in [rparench,commach,ident]) do
                        NextToken;
                     end; {if}
                  if token.kind = ident then begin
                     pvar := NewSymbol(token.name, nil, ident, variableSpace,
                        declared);
                     pvar^.storage := parameter;
                     pvar^.pnext := lastParameter;
                     lastParameter := pvar;
                     numberOfParameters := numberOfParameters+1;
                     pvar^.bitdisp := numberOfParameters;
                     NextToken;
                     end; {if}
                  end; {if}
               if token.kind = commach then begin
                  NextToken;
                  done := false;
                  end {if}
               else
                  done := true;
            until done or (token.kind = eofsy);
            end {else if}
         else if (lint & lintNotPrototyped) <> 0 then
            if not tPtr2^.prototyped then
               Error(105);
         Match(rparench,12);            {insist on a closing ')' token}
         isPascal := lisPascal;         {restore this flag}
         end {if}

      {handle array declarations}
      else {if token.kind = lbrackch then} begin
         lastWasIdentifier := false;
         tPtr2 := pointer(Calloc(sizeof(typeRecord)));
         {tPtr2^.size := 0;}
         {tPtr2^.saveDisp := 0;}
         {tPtr2^.isConstant := false;}
         tPtr2^.kind := arrayType;
         {tPtr2^.elements := 0;}
         new(ttPtr);
         ttPtr^.next := typeStack;
         typeStack := ttPtr;
         ttPtr^.typeDef := tPtr2;
         NextToken;
         if token.kind <> rbrackch then begin
            Expression(arrayExpression, [rbrackch,semicolonch]);
            if expressionValue <= 0 then begin
               Error(45);
               expressionValue := 1;
               end; {if}
            tPtr2^.elements := expressionValue;
            end; {if}
         Match(rbrackch,24);
         end; {else if}
      end; {while}

   {stack pointer type records}
   while cpList <> nil do begin
      tPtr2 := pointer(Malloc(sizeof(typeRecord)));
      tPtr2^.size := cgPointerSize;
      tPtr2^.saveDisp := 0;
      tPtr2^.isConstant := cpList^.isConstant;
      tPtr2^.kind := pointerType;
      new(ttPtr);
      ttPtr^.next := typeStack;
      typeStack := ttPtr;
      ttPtr^.typeDef := tPtr2;
      cp := cpList;
      cpList := cp^.next;
      dispose(cp);
      end; {for}
   end; {StackDeclarations}

begin {Declarator}
newName := nil;                         {no identifier, yet}
unnamedParm := false;                   {not an unnamed parameter}
if storageClass = externsy then         {decide on a storage state}
   state := declared
else
   state := defined;
typeStack := nil;                       {no types so far}
parameterStorage := false;              {symbol is not in a parameter list}
checkParms := false;                    {assume we won't need to check for parameter type errors}
StackDeclarations(varParmList);         {stack the type records}
while typeStack <> nil do begin         {reverse the type stack}
   tsPtr := typeStack;
   typeStack := tsPtr^.next;
   if isFunction and (not useGlobalPool) then begin
      tPtr2 := pointer(GMalloc(sizeof(typeRecord)));
      tPtr2^ := tsPtr^.typeDef^;
      tPtr2^.saveDisp := 0;
      end {if}
   else
      tPtr2 := tsPtr^.typeDef;
   dispose(tsPtr);
   if tPtr^.kind = functionType then
      PopTable;
   case tPtr2^.kind of
      pointerType: begin
         tPtr2^.pType := tPtr;                     
         end;
      functionType: begin
         while tPtr^.kind = definedType do
            tPtr := tPtr^.dType;
         tPtr2^.fType := tPtr;
         if tPtr^.kind in [functionType,arrayType] then
            Error(103);
         end;
      arrayType: begin
         tPtr2^.size := tPtr^.size * tPtr2^.elements;
         tPtr2^.aType := tPtr;
         end;
      otherwise: ;
      end; {case}
   tPtr := tPtr2;
   end; {while}

if checkParms then begin                {check for parameter type conflicts}
   with variable^ do begin
      if doingParameters then begin
         if itype = nil then begin
            itype := tPtr;
            numberOfParameters := numberOfParameters-1;
            if pfunc^.itype^.prototyped then begin
               pfunc^.itype^.overrideKR := true;
               p1 := nil;
               for i := 1 to bitdisp do begin
                  p2 := pfunc^.itype^.parameterList;
                  while (p2^.next <> p1) and (p2 <> nil) do
                     p2 := p2^.next;
                  p1 := p2;
                  end; {for}
               compatible := false;
               if CompTypes(p1^.parameterType, tPtr) then
                  compatible := true
               else begin
                  tk1 := p1^.parameterType^.kind;
                  tk2 := tPtr^.kind;
                  if (tk1 = arrayType) and (tk2 = pointerType) then
                     compatible :=
                        CompTypes(p1^.parameterType^.aType, tPtr^.pType)
                  else if (tk1 = pointerType) and (tk2 = arrayType) then
                     compatible :=
                        CompTypes(p1^.parameterType^.pType, tPtr^.aType);
                  end; {else}
               if not compatible then
                  Error(47);
               end; {if}
            end {if}
         else
            Error(42);
         storage := parameter;
         parameterStorage := true;
         end; {if}
      end; {with}
   end {if}
else if doingParameters then
   if pfunc^.itype^.prototyped then
      if not doingPrototypes then
         if tPtr^.kind in
            [enumConst,structType,unionType,definedType,pointerType]
            then Error(50);

if tPtr^.kind = functionType then begin {declare the identifier}
   if variable <> nil then begin
      t1 := variable^.itype;
      if CompTypes(t1, tPtr) then begin
         if t1^.prototyped and tPtr^.prototyped then begin
            p2 := tptr^.parameterList;
            if isPascal then begin
               {reverse the parameter list}
               p1 := nil;
               while p2 <> nil do begin
                  p3 := p2;
                  p2 := p2^.next;
                  p3^.next := p1;
                  p1 := p3;
                  end; {while}
               tPtr^.parameterList := p1;
               end; {if}
            p2 := tPtr^.parameterList;
            p1 := t1^.parameterList;
            while (p1 <> nil) and (p2 <> nil) do begin
               if p1^.parameter = nil then
                  pt1 := p1^.parameterType
               else
                  pt1 := p1^.parameter^.itype;
               if p2^.parameter = nil then
                  pt2 := p2^.parameterType
               else
                  pt2 := p2^.parameter^.itype;
               if not CompTypes(pt1, pt2) then begin
                  Error(47);
                  goto 1;
                  end; {if}
               p1 := p1^.next;
               p2 := p2^.next;
               end; {while}
            if p1 <> p2 then
               Error(47);
            p2 := tptr^.parameterList;
            if isPascal then begin
               {reverse the parameter list}
               p1 := nil;
               while p2 <> nil do begin
                  p3 := p2;
                  p2 := p2^.next;
                  p3^.next := p1;
                  p1 := p3;
                  end; {while}
               tPtr^.parameterList := p1;
               end; {if}
            end; {if}
         end {if}
      else
         Error(42);
1:
      end; {if}
   end; {if}
if tPtr^.kind = functionType then
   state := declared;
if newName <> nil then                  {declare the variable}
   variable := NewSymbol(newName, tPtr, storageClass, space, state)
else if unnamedParm then
   variable^.itype := tPtr
else begin
   if token.kind <> semicolonch then
      Error(9);
   variable := nil;
   end; {else}
if variable <> nil then begin
   if parameterStorage then
      variable^.storage := parameter;
   if isForwardDeclared then begin      {handle forward declarations}
      tPtr := variable^.itype;
      lastWasPointer := false;
      while tPtr^.kind in
         [pointerType,arrayType,functionType,definedType] do begin
         if tPtr^.kind = pointerType then
            lastWasPointer := true
         else if tPtr^.kind <> definedType then
            lastWasPointer := false;
         tPtr := tPtr^.pType;
         end; {while}
      if ((tPtr <> typeSpec) and (not (tPtr^.kind in [structType,unionType])))
         then begin
         Error(107);
         SkipStatement;
         end; {if}
      variable^.isForwardDeclared := true;
      end; {if}
   end; {if}
end; {Declarator}


procedure Initializer (var variable: identPtr);

{ handle a variable initializer                                 }
{                                                               }
{ paramaters:                                                   }
{       variable - ptr to the identifier begin initialized      }

var
   bitcount: integer;                   {# if bits initialized}
   bitvalue: longint;                   {bit field initializer value}
   done: boolean;                       {for loop termination}
   errorFound: boolean;                 {used to remove bad initializations}
   iPtr,jPtr,kPtr: initializerPtr;      {for reversing the list}
   ip: identList;                       {used to place an id in the list}
   luseGlobalPool: boolean;             {local copy of useGlobalPool}


   procedure InitializeBitField;

   { If bit fields have been initialized, fill them in          }
   {                                                            }
   { Inputs:                                                    }
   {    bitcount - # of bits initialized                        }
   {    bitvalue - value of initializer                         }

   var
      iPtr: initializerPtr;             {for creating an initializer entry}

   begin {InitializeBitField}
   if bitcount <> 0 then begin          {skip if there has been no initializer}
{ writeln('InitializeBitField; bitcount = ', bitcount:1); {debug}
                                        {create the initializer entry}
      iPtr := pointer(Malloc(sizeof(initializerRecord)));
      iPtr^.next := variable^.iPtr;
      variable^.iPtr := iPtr;
      iPtr^.isConstant := isConstant;
      iPtr^.count := 1;
      iPtr^.bitdisp := 0;
      iPtr^.bitsize := 0;
      iPtr^.isStruct := false;
      iPtr^.iVal := bitvalue;
      if bitcount > 16 then
         iPtr^.itype := cgULong
      else if bitcount > 8 then
         iPtr^.itype := cgUWord
      else
         iPtr^.itype := cgUByte;
      bitcount := 0;                    {reset the bit field values}
      bitvalue := 0;
      end; {if}
   end; {InitializeBitField}


   procedure GetInitializerValue (tp: typePtr; bitsize,bitdisp: integer);
 
   { get the value of an initializer from a single expression    }
   {                                                             }
   { parameters:                                                 }
   {     tp - type of the variable being initialized             }
   {     bitsize - size of bit field (0 for non-bit fields)      }
   {     bitdisp - disp of bit field; unused if bitsize = 0      }
 
   label 1,2,3;

   var
      bitmask: longint;                 {used to add a value to a bit field}
      bKind: baseTypeEnum;              {type of constant}
      etype: typePtr;                   {expression type}
      i: integer;                       {loop variable}
      ip: identPtr;                     {ident in pointer constant}
      iPtr: initializerPtr;             {for creating an initializer entry}
      kind: tokenEnum;                  {kind of constant}
      offset, offset2: longint;		{integer offset from a pointer}
      operator: tokenEnum;              {operator for constant pointers}
      tKind: typeKind;                  {type of constant}
      tree: tokenPtr;                   {for evaluating pointer constants}


      function Subscript (tree: tokenPtr): typePtr;

      { handle subscripts in a pointer constant                 }
      {                                                         }
      { parameters:                                             }
      {    tree - subscript operators                           }
      {                                                         }
      { returns: type of the variable                           }
      {                                                         }
      { variables:                                              }
      {    iPtr - initializer location to store the array name  }
      {    offset - bytes past the start of the array           }

      var
         ip: identPtr;                  {ident pointer}
         rtree: tokenPtr;               {work pointer}
         tp: typePtr;                   {for tracking types}
         select: longint;               {selector size}
         size: longint;                 {subscript value}

      begin {Subscript}
      if tree^.token.kind = uasterisk then begin
         tree := tree^.left;
         if tree^.token.kind = plusch then begin
            rtree := tree^.right;
            if rtree^.token.kind in [intconst,uintconst] then
               size := rtree^.token.ival
            else if rtree^.token.kind in [longconst,ulongconst] then
               size := rtree^.token.lval
            else begin
               Error(18);
               errorFound := true;
               end; {else}
            tp := Subscript(tree^.left);
            if tp^.kind <> arrayType then
               Error(47)
            else begin
               tp := tp^.atype;
               offset := offset + size*tp^.size;
               Subscript := tp;
               end; {else}
            end {if}
         else begin
            Error(47);
            errorFound := true;
            Subscript := wordPtr;
            end; {else}
         end {if}
      else if tree^.token.kind = dotch then begin
         tp := Subscript(tree^.left);
         if tp^.kind in [structType,unionType] then begin
            DoSelection(tp, tree^.right, select);
            Subscript := expressionType;
            offset := offset+select;
            if isBitField then
               Error(106);
            end {if}
         else begin
            Error(47);
            errorFound := true;
            Subscript := wordPtr;
            end; {else}
         end {else if}
      else if tree^.token.kind = ident then begin
         ip := FindSymbol(tree^.token, allSpaces, false, true);
         if ip = nil then begin
            Error(31);
            errorFound := true;
            Subscript := wordPtr;
            iPtr^.pName := @'?';
            end {if}
         else begin
            Subscript := ip^.itype;
            iPtr^.pName := ip^.name;
            end; {else}
         end {else if}
      else begin
         Error(47);
         errorFound := true;
         Subscript := wordPtr;
         end; {else}
      end; {Subscript}


   begin {GetInitializerValue}
   if variable^.storage = stackFrame then
      Expression(autoInitializerExpression, [commach,rparench,rbracech])
   else
      Expression(initializerExpression, [commach,rparench,rbracech]);
   if bitsize = 0 then begin
      iPtr := pointer(Malloc(sizeof(initializerRecord)));
      iPtr^.next := variable^.iPtr;
      variable^.iPtr := iPtr;
      iPtr^.isConstant := isConstant;
      iPtr^.count := 1;
      iPtr^.bitdisp := 0;
      iPtr^.bitsize := 0;
      iPtr^.isStruct := false;
      end; {if}
   etype := expressionType;
   AssignmentConversion(tp, expressionType, isConstant, expressionValue,
      false, false);
   if variable^.storage = external then
      variable^.storage := global;
   if isConstant and (variable^.storage in [external,global,private]) then begin
      if bitsize = 0 then begin
         iPtr^.iVal := expressionValue;
         iPtr^.itype := tp^.baseType;
         InitializeBitField;
         end; {if}
      case tp^.kind of

         scalarType: begin
            bKind := tp^.baseType;
            if (bKind in [cgByte..cgULong])
               and (etype^.baseType in [cgByte..cgULong]) then begin
               if bKind in [cgLong,cgULong] then
                  if eType^.baseType = cgUByte then
                     iPtr^.iVal := iPtr^.iVal & $000000FF
                  else if eType^.baseType = cgUWord then
                     iPtr^.iVal := iPtr^.iVal & $0000FFFF;
               goto 3;
               end; {if}
            if bKind in [cgReal,cgDouble,cgComp,cgExtended] then begin
               if etype^.baseType in [cgByte..cgULong] then
                  iPtr^.rVal := expressionValue
               else if etype^.baseType in
                  [cgReal,cgDouble,cgComp,cgExtended] then
                  iPtr^.rval := realExpressionValue;
               goto 3;
               end; {if}
            Error(47);
            errorFound := true;
            goto 2;

3:          if bitsize <> 0 then begin

               {set up a bit field value}
               if bitdisp < bitcount then
                  InitializeBitField;
               bitmask := 0;
               for i := 1 to bitsize do
                  bitmask := (bitmask << 1) | 1;
               bitmask := bitmask & expressionValue;
               for i := 1 to bitdisp do
                  bitmask := bitmask << 1;
               bitvalue := bitvalue | bitmask;
               bitcount := bitcount + bitsize;
               end; {if}
            end;

         arrayType: begin
            if tp^.aType^.kind = scalarType then
               if tp^.aType^.baseType in [cgByte,cgUByte] then
                  if eType^.baseType = cgString then
                     goto 2;
            Error(46);
            errorFound := true;
            end;

         pointerType:
            if etype = stringTypePtr then begin
               iPtr^.isConstant := true;
               iPtr^.iType := ccPointer;
               iPtr^.pval := 0;
               iPtr^.pPlus := operator = plusch;
               iPtr^.isName := false;
               iPtr^.pStr := longstringPtr(expressionValue);
               end {if}
            else if etype^.kind = scalarType then
               if etype^.baseType in [cgByte..cgULong] then
                  if expressionValue = 0 then
                     iPtr^.iType := cgULong
                  else begin
                     Error(47);
                     errorFound := true;
                     end {else}
               else begin
                  Error(48);
                  errorFound := true;
                  end {else}
            else if etype^.kind = pointerType then begin
               iPtr^.iType := cgULong;
               iPtr^.pval := expressionValue;
               end {else if}
            else begin
               Error(48);
               errorFound := true;
               end; {else}

         structType,enumType: begin
            Error(46);
            errorFound := true;
            end;

         otherwise:
            Error(57);

         end; {case}
2:    DisposeTree(initializerTree);
      end {if}
   else begin
      if (tp^.kind = pointerType)
         or ((tp^.kind = scalarType) and (tp^.baseType in [cgLong,cgULong]))
         then begin
         iPtr^.iType := ccPointer;
         if variable^.storage in [external,global,private] then begin

            {do pointer constants with + or -}
            iPtr^.isConstant := true;
            tree := initializerTree;
            while tree^.token.kind = castoper do
               tree := tree^.left;
            offset := 0;
            operator := tree^.token.kind;
            while operator in [plusch,minusch] do begin
               with tree^.right^.token do
                  if kind in [intConst,longConst] then begin
                     if kind = intConst then
                        offSet2 := ival
                     else
                        offset2 := lval;
                     if operator = plusch then
                        offset := offset + offset2
                     else
                        offset := offset - offset2;
                     end {if}
                  else begin
                     Error(47);
                     errorFound := true;
                     end; {else}
               tree := tree^.left;
               operator := tree^.token.kind;
               end; {if}
            kind := tree^.token.kind;
            if kind = ident then begin

               {handle names of functions or static arrays}
               ip := FindSymbol(tree^.token, allSpaces, false, true);
               if ip = nil then begin
                  Error(31);
                  errorFound := true;
                  end {if}
               else begin
                  tKind := ip^.itype^.kind;
                  if tKind = functionType then begin
                     if operator in [plusch,minusch] then begin
                        Error(47);
                        errorFound := true;
                        end; {if}
                     end {if}
                  else if (tKind = arrayType)
                     and (ip^.storage in [external,global,private]) then begin
                     offset := offset*ip^.itype^.atype^.size;
                     end {else if}
                  else if tKind = pointerType then begin
                     Error(48);
                     errorFound := true;
                     end {else if}
                  else begin
                     Error(47);
                     errorFound := true;
                     end; {else}
                  iPtr^.pval := offset;
                  iPtr^.pPlus := true;
                  iPtr^.isName := true;
                  iPtr^.pName := ip^.name;
                  end; {if}
               end {if}
            else if kind = uand then begin
               tree := tree^.left;
               iPtr^.pPlus := operator = plusch;
               iPtr^.isName := true;
               if tree^.token.kind = ident then begin
                  ip := FindSymbol(tree^.token, allSpaces, false, true);
                  if ip = nil then begin
                     Error(31);
                     errorFound := true;
                     end {if}
                  else
                     if ip^.storage in [external,global,private] then begin
                        offset := offset*ip^.itype^.size;
                        iPtr^.pName := ip^.name;
                        end {if}
                     else begin
                        Error(47);
                        errorFound := true;
                        end; {else}
                  end {if}
               else begin
                  tp := Subscript(tree);
                  if offset > 0 then
                     iPtr^.pPlus := true
                  else begin
                     iPtr^.pPlus := false;
                     offset := -offset;
                     end; {else}
                  end; {else}
               iPtr^.pval := offset;
               end {else if}
            else if kind in [dotch,uasterisk] then begin
               iPtr^.isName := true;
               tp := Subscript(tree);
               if offset > 0 then
                  iPtr^.pPlus := true
               else begin
                  iPtr^.pPlus := false;
                  offset := -offset;
                  end; {else}
               iPtr^.pval := offset;
               end {else if}
            else if kind = stringConst then begin
               iPtr^.pval := offset;
               iPtr^.pPlus := operator = plusch;
               iPtr^.isName := false;
               iPtr^.pStr := tree^.token.sval;
               end {else if}
            else begin
               Error(47);
               errorFound := true;
               end; {else}
            DisposeTree(initializerTree);
            goto 1;
            end; {if}
         end {if}
      else if tp^.kind = structType then
         iPtr^.isStruct := true;

      {handle auto variables}
      if bitsize <> 0 then begin
         iPtr := pointer(Malloc(sizeof(initializerRecord)));
         iPtr^.next := variable^.iPtr;
         variable^.iPtr := iPtr;
         iPtr^.isConstant := isConstant;
         iPtr^.count := 1;
         iPtr^.bitdisp := bitdisp;
         iPtr^.bitsize := bitsize;
         iPtr^.isStruct := false;
         end; {if}
      if variable^.storage in [external,global,private] then begin
         Error(41);
         errorFound := true;
         end; {else}
      iPtr^.isConstant := false;
      iPtr^.iTree := initializerTree;
      iPtr^.bitdisp := bitdisp;
      iPtr^.bitsize := bitsize;
      end; {else}
1:
   end; {GetInitializerValue}


   procedure InitializeTerm (tp: typePtr; bitsize,bitdisp: integer;
      main: boolean);
 
   { initialize one level of the type                           }
   {                                                            }
   { parameters:                                                }
   {     tp - pointer to the type being initialized             }
   {     bitsize - size of bit field (0 for non-bit fields)     }
   {     bitdisp - disp of bit field; unused if bitsize = 0     }
   {     main - is this a call from the main level?             }
 
   var
      bitCount: integer;                {# of bits in a union}
      braces: boolean;                  {is the initializer inclosed in braces?}
      count,maxCount: longint;          {for tracking the size of an initializer}
      ep: tokenPtr;                     {for forming string expression}
      iPtr: initializerPtr;             {for creating an initializer entry}
      ip: identPtr;                     {for tracing field lists}
      kind: typeKind;                   {base type of an initializer}
      ktp: typePtr;			{array type with definedTypes removed}


      procedure Fill (count: longint; tp: typePtr);

      { fill in unspecified space in an initialized array with 0  }
      {                                                           }
      { parameters:                                               }
      {   count - ^ elements of this type to create               }
      {   tp - ptr to type of elements to create                  }

      var
         i: longint;                    {loop variable}
         iPtr: initializerPtr;          {for creating an initializer entry}
         tk: tokenPtr;                  {expression record}
         ip: identPtr;                  {pointer to next field in a structure}

      begin {Fill}
{     writeln('Fill tp^.kind = ', ord(tp^.kind):1, '; count = ', count:1); {debug}
      InitializeBitField;               {if needed, do the bit field}
      if tp^.kind = arrayType then

         {fill an array}
         Fill(count*tp^.elements ,tp^.aType)
      else if tp^.kind = structType then begin

         {fill a structure}
         i := count;
         while i <> 0 do begin
            ip := tp^.fieldList;
            while ip <> nil do begin
               Fill(1, ip^.iType);
               ip := ip^.next;
               end; {while}
            i := i-1;
            end; {while}
         end {else if}
      else if tp^.kind = unionType then

         {fill a union}
         Fill(count, tp^.fieldList^.iType)
      else

         {fill a single value}
         while count <> 0 do begin
            iPtr := pointer(Calloc(sizeof(initializerRecord)));
            iPtr^.next := variable^.iPtr;
            variable^.iPtr := iPtr;
            iPtr^.isConstant := variable^.storage in [external,global,private];
           {iPtr^.bitdisp := 0;}
           {iPtr^.bitsize := 0;}
           {iPtr^.isStruct := false;}
            if iPtr^.isConstant then begin
               if tp^.kind = scalarType then
                  iPtr^.itype := tp^.baseType
               else if tp^.kind = pointertype then begin
                  iPtr^.itype := cgULong;
                 {iPtr^.iVal := 0;}
                  end {else if}
               else begin
                  iPtr^.itype := cgWord;
                  Error(47);
                  errorFound := true;
                  end; {else}
               end {if}
            else begin
               new(tk);
               tk^.next := nil;
               tk^.left := nil;
               tk^.middle := nil;
               tk^.right := nil;
               tk^.token.kind := intconst;
               tk^.token.class := intConstant;
               tk^.token.ival := 0;
               iPtr^.iTree := tk;
               end; {else}
            if count < 16384 then begin
               iPtr^.count := long(count).lsw;
               count := 0;
               end {if}
            else begin
               iPtr^.count := 16384;
               count := count-16384;
               end; {else}
            end; {while}
      end; {Fill}
 
 
      procedure RecomputeSizes (tp: typePtr);
  
      { a size has been infered from an initializer - set the     }
      { appropriate type size values                              }
      {                                                           }
      { parameters:                                               }
      {   tp - type to check                                      }
  
      begin {RecomputeSizes}
      if tp^.aType^.kind = arrayType then
         RecomputeSizes(tp^.aType);
      with tp^ do
         size := aType^.size*elements;
      end; {RecomputeSizes}
 
   begin {InitializeTerm}
   braces := false;                     {allow for an opening brace}
   if token.kind = lbracech then begin
      NextToken;
      braces := true;
      end; {if}

   {handle arrays}
   while tp^.kind = definedType do
      tp := tp^.dType;
   kind := tp^.kind;
   if kind = arrayType then begin
      ktp := tp^.atype;
      while ktp^.kind = definedType do
	 ktp := ktp^.dType;
      kind := ktp^.kind;

      {handle string constants}
      if (token.kind = stringConst) and (kind = scalarType)
         and (ktp^.baseType in [cgByte,cgUByte]) then begin
         if tp^.elements = 0 then begin
            tp^.elements := token.sval^.length + 1;
            RecomputeSizes(variable^.itype);
            end {if}
         else if tp^.elements < token.sval^.length then begin
            Error(44);
            errorFound := true;
            end; {else if}
         with ktp^ do begin
            iPtr := pointer(Malloc(sizeof(initializerRecord)));
            iPtr^.next := variable^.iPtr;
            variable^.iPtr := iPtr;
            iPtr^.count := 1;
            iPtr^.bitdisp := 0;
            iPtr^.bitsize := 0;
            iPtr^.isStruct := false;
            if (variable^.storage in [external,global,private]) then begin
               iPtr^.isConstant := true;
               iPtr^.itype := cgString;
               iPtr^.sval := token.sval;
               count := tp^.elements - token.sval^.length;
               if count <> 0 then
                  Fill(count, bytePtr);
               end {if}
            else begin
               iPtr^.isConstant := false;
               new(ep);
               iPtr^.iTree := ep;
               ep^.next := nil;
               ep^.left := nil;
               ep^.middle := nil;
               ep^.right := nil;
               ep^.token := token;
               end; {else}
            end; {with}
         NextToken;
         end {if}

      {handle arrays of non-strings}
      else if kind in
         [scalarType,pointerType,enumType,arrayType,structType,unionType] then
         begin
         count := 0;                    {get the expressions|initializers}
         maxCount := tp^.elements;
         if token.kind <> rbracech then
            repeat
               InitializeTerm(ktp, 0, 0, false);
               count := count+1;
               if count <> maxCount then begin
                  if token.kind = commach then begin
                     NextToken;
                     done := token.kind = rbracech;
                     end {if}
                  else
                     done := true;
                  end {if}
               else
                  done := true;
            until done or (token.kind = eofsy) or (count = maxCount);
         if maxCount <> 0 then begin
            count := maxCount-count;
            if count <> 0 then          {if there weren't enough initializers...}
               Fill(count,ktp);         { fill in the blank spots}
            end {if}
         else begin
            tp^.elements := count;      {set the array size}
            RecomputeSizes(variable^.itype);
            end; {else}
         end {else if}

      else begin
         Error(47);
         errorFound := true;
         end; {else}
      end {if}

   {handle structures}
   else if kind = structType then begin
      if braces or (not main) then begin
         count := tp^.size;
         ip := tp^.fieldList;
         bitCount := 0;
         while (ip <> nil) and (token.kind <> rbracech) do begin
            if ip^.isForwardDeclared then
               ResolveForwardReference(ip);
            InitializeTerm(ip^.itype, ip^.bitsize, ip^.bitdisp, false);
            if ip^.bitSize <> 0 then begin
               bitCount := bitCount + ip^.bitSize;
               if bitCount > maxBitField then begin
                  count := count - (maxBitField div 8);
                  bitCount := ip^.bitSize;
                  end; {if}
               end {if}
            else begin
               if bitCount > 0 then begin
                  bitCount := (bitCount+7) div 8;
                  count := count-bitCount;
                  bitCount := 0;
                  end; {if}
               count := count-ip^.itype^.size;
               end; {else}
{           writeln('Initializer: ', ip^.bitsize:10, ip^.bitdisp:10, bitCount:10); {debug}
            ip := ip^.next;
            if token.kind = commach then begin
               if ip <> nil then
                  NextToken;
               end {if}
            else
               ip := nil;
            end; {while}
         if bitCount > 0 then begin
            InitializeBitField;
            bitCount := (bitCount+7) div 8;
            count := count-bitCount;
            bitCount := 0;
            end; {if}
         if count > 0 then
            Fill(count, bytePtr);
         end {if}
      else                              {struct assignment initializer}
         GetInitializerValue(tp, bitsize, bitdisp);
      end {else if}

   {handle unions}
   else if kind = unionType then begin
      ip := tp^.fieldList;
      if ip^.isForwardDeclared then
         ResolveForwardReference(ip);
      InitializeTerm(ip^.itype, 0, 0, false);
      count := tp^.size - ip^.itype^.size;
      if count > 0 then
         Fill(count, bytePtr);
      end {else if}

   {handle single-valued types}
   else if kind in [scalarType,pointerType,enumType] then
      GetInitializerValue(tp, bitsize, bitdisp)

   else begin
      Error(47);
      errorFound := true;
      end; {else}

   if braces then begin                 {if there was an opening brace then }
      if token.kind = commach then      { insist on a closing brace         }
         NextToken;
      if token.kind = rbracech then
         NextToken
      else begin
         Error(23);
         while not (token.kind in [rbracech,eofsy]) do
            NextToken;
         NextToken;
         errorFound := true;
         end; {else}
      end; {if}
   end; {InitializeTerm}

begin {Initializer}
bitcount := 0;                          {set up for bit fields}
bitvalue := 0;
errorFound := false;                    {no errors found so far}
luseGlobalPool := useGlobalPool;        {use global memory for global vars}
useGlobalPool := (variable^.storage in [external,global,private])
   or useGlobalPool;
                                        {make sure a required '{' is there}
if not (token.kind in [lbracech,stringConst]) then
   if variable^.itype^.kind = arrayType then begin
      Error(27);
      errorFound := true;
      end; {if}
InitializeTerm(variable^.itype, 0, 0, true); {do the initialization}
variable^.state := initialized;         {mark the variable as initialized}
iPtr := variable^.iPtr;                 {reverse the initializer list}
jPtr := nil;
while iPtr <> nil do begin
   kPtr := iPtr;
   iPtr := iPtr^.next;
   kPtr^.next := jPtr;
   jPtr := kPtr;
   end; {while}
variable^.iPtr := jPtr;
if errorFound then                      {eliminate bad initializers}
   variable^.state := defined;
new(ip);                                {place the initializer in the list}
ip^.next := initializerList;
ip^.id := variable;
initializerList := ip;
useGlobalPool := luseGlobalPool;        {restore useGlobalPool}
end; {Initializer}


procedure TypeSpecifier {doingFieldList,isConstant: boolean};

{ handle a type specifier                                       }
{                                                               }
{ parameters:                                                   }
{       doingFieldList - are we processing a field list?        }
{       isConstant - did we already find a constsy?             }
{                                                               }
{ outputs:                                                      }
{       isForwardDeclared - is the field list component         }
{               referenceing a forward struct/union?            }
{       skipDeclarator - for enum,struct,union with no          }
{               declarator                                      }
{       typespec - type specifier                               }

label 1,2;

var
   done: boolean;                       {for loop termination}
   enumVal: integer;                    {default value for the next enum constant}
   tPtr: typePtr;                       {for building types}
   variable: identPtr;                  {enumeration variable}
 
   structPtr: identPtr;                 {structure identifier}
   structTypePtr: typePtr;              {structure type}
   tKind: typeKind;                     {defining structure or union?}
 
   ttoken: tokenType;                   {temp variable for struct name}
   lUseGlobalPool: boolean;             {local copy of useGlobalPool}
   globalStruct: boolean;               {did we force global pool use?}

 
   procedure FieldList (tp: typePtr; kind: typeKind);
 
   { handle a field list                                         }
   {                                                             }
   { parameters                                                  }
   {     tp - place to store the type pointer                    }
 
   var
      bitDisp: integer;                 {current bit disp}
      disp: longint;                    {current byte disp}
      done: boolean;                    {for loop termination}
      fl,tfl,ufl: identPtr;             {field list}
      ldoingParameters: boolean;        {local copy of doingParameters}
      lisForwardDeclared: boolean;      {local copy of isForwardDeclared}
      lstorageClass: tokenEnum;         {storage class of the declaration}
      maxDisp: longint;                 {for determining union sizes}
      variable: identPtr;               {variable being defined}
 
   begin {FieldList}
   ldoingParameters := doingParameters; {allow fields in K&R dec. area}
   doingParameters := false;
   lisForwardDeclared := isForwardDeclared; {stack this value}
   lStorageClass := storageClass;       {don't allow auto in a struct}
   storageClass := ident;
   bitDisp := 0;                        {start allocation from byte 0}
   disp := 0;
   maxDisp := 0;
   fl := nil;                           {nothing in the field list, yet}
                                        {check for no declarations}
   if not (token.kind in [unsignedsy,signedsy,intsy,longsy,charsy,shortsy,
      floatsy,doublesy,compsy,extendedsy,enumsy,structsy,unionsy,typedefsy,
      typedef,voidsy,constsy,volatilesy]) then
      Error(26);
                                        {while there are entries in the field list...}
   while token.kind in [unsignedsy,signedsy,intsy,longsy,charsy,shortsy,floatsy,
      doublesy,compsy,extendedsy,enumsy,structsy,unionsy,typedefsy,typedef,
      voidsy,constsy,volatilesy] do begin
      typeSpec := wordPtr;              {default type specifier is an integer}
      TypeSpecifier(true,false);        {get the type specifier}
      if not skipDeclarator then
         repeat                         {declare the variables...}
            variable := nil;
            if token.kind <> colonch then begin
               Declarator(typeSpec, variable, fieldListSpace, false);
               if variable <> nil then  {enter the var in the field list}
                  begin
                  tfl := fl;            {(check for dups)}
                  while tfl <> nil do begin
                     if tfl^.name^ = variable^.name^ then
                        Error(42);
                     tfl := tfl^.next;
                     end; {while}
                  variable^.next := fl;
                  fl := variable;
                  end; {if}
               end; {if}
            if token.kind = colonch then {handle a bit field}
               begin
               if kind = unionType then
                  Error(56);
               NextToken;
               Expression(arrayExpression,[commach,semicolonch]);
               if (expressionValue >= maxBitField) or (expressionValue < 0) then
                  begin
                  Error(54);
                  expressionValue := maxBitField-1;
                  end; {if}
               if (bitdisp+long(expressionValue).lsw > maxBitField)
                  or (long(expressionValue).lsw = 0) then begin
                  disp := disp+((bitDisp+7) div 8);
                  bitdisp := 0;
                  if long(expressionValue).lsw = 0 then
                     if variable <> nil then
                        Error(55);
                  end; {if}
               if variable <> nil then begin
                  variable^.disp := disp;
                  variable^.bitdisp := bitdisp;
                  variable^.bitsize := long(expressionValue).lsw;
                  bitdisp := bitdisp+long(expressionValue).lsw;
                  end; {if}
               end {if}
            else if variable <> nil then begin
               if bitdisp <> 0 then begin
                  disp := disp+((bitDisp+7) div 8);
                  bitdisp := 0;
                  end {if}
               else if kind = unionType then
                  disp := 0;
               variable^.disp := disp;
               variable^.bitdisp := bitdisp;
               variable^.bitsize := 0;
               disp := disp + variable^.itype^.size;
               if disp > maxDisp then
                  maxDisp := disp;
               end; {if}
            if token.kind = commach then {allow repeated declarations}
               begin
               NextToken;
               done := false;
               end {if}
            else
               done := true;
         until done or (token.kind = eofsy);
      Match(semicolonch,22);            {insist on a closing ';'}
      end; {while}
   if fl <> nil then begin
      ufl := nil;                       {reverse the field list}
      while fl <> nil do begin
         tfl := fl;
         fl := fl^.next;
         tfl^.next := ufl;
         ufl := tfl;
         end; {while}
      if kind = structType then begin   {return the field list}
         if bitdisp <> 0 then
            disp := disp+((bitDisp+7) div 8);
         tp^.size := disp;
         end {if}
      else
         tp^.size := maxDisp;
      tp^.fieldList := ufl;
      end; {if}
   storageClass := lStorageClass;       {restore default storage class}
   isForwardDeclared := lisForwardDeclared; {restore the forward flag}
   doingParameters := ldoingParameters; {restore the parameters flag}
   end; {FieldList}


   procedure CheckConst;

   { Check the token to see if it is a const or volatile        }

   begin {CheckConst}
   while token.kind in [constsy,volatilesy] do begin
      if token.kind = constsy then
         isConstant := true
      else
         volatile := true;
      NextToken;
      end; {while}
   end; {CheckConst}


begin {TypeSpecifier}
isForwardDeclared := false;             {not doing a forward reference (yet)}
skipDeclarator := false;                {declarations are required (so far)}
CheckConst;
case token.kind of
   unsignedsy: begin                    {unsigned}
      NextToken;
      CheckConst;
      if token.kind = shortsy then begin
         NextToken;
         CheckConst;
         if token.kind = intsy then begin
            NextToken;
            CheckConst;
            end; {if}
         typeSpec := uWordPtr;
         end {if}
      else if token.kind = longsy then begin
         NextToken;
         CheckConst;
         if token.kind = intsy then begin
            NextToken;
            CheckConst;
            end; {if}
         typeSpec := uLongPtr;
         end {else if}
      else if token.kind = charsy then begin
         NextToken;
         CheckConst;
         typeSpec := uBytePtr;
         end {else if}
      else if token.kind = intsy then begin
         NextToken;
         CheckConst;
	 if unix_1 then
            typeSpec := uLongPtr
	 else
            typeSpec := uWordPtr;
         end {else if}
      else begin
         CheckConst;
	 if unix_1 then
            typeSpec := uLongPtr
	 else
            typeSpec := uWordPtr;
         end; {else if}
      end;

   signedsy: begin                      {signed}
      NextToken;
      CheckConst;
      if token.kind = shortsy then begin
         NextToken;
         CheckConst;
         if token.kind = intsy then begin
            NextToken;
            CheckConst;
            end; {if}
         typeSpec := wordPtr;
         end {if}
      else if token.kind = longsy then begin
         NextToken;
         CheckConst;
         if token.kind = intsy then begin
            NextToken;
            CheckConst;
            end; {if}
         typeSpec := longPtr;
         end {else if}
      else if token.kind = intsy then begin
         NextToken;
         CheckConst;
	 if unix_1 then
            typeSpec := longPtr
	 else
            typeSpec := wordPtr;
         end {else if}
      else if token.kind = charsy then begin
         NextToken;
         CheckConst;
         typeSpec := bytePtr;
         end; {else if}
      end;

   intsy: begin                         {int}
      NextToken;
      CheckConst;
      if unix_1 then
         typeSpec := longPtr
      else
         typeSpec := wordPtr;
      end;

   longsy: begin                        {long}
      NextToken;
      CheckConst;
      typeSpec := longPtr;
      if token.kind in [intsy,floatsy] then begin
         if token.kind = floatsy then
            typeSpec := doublePtr;
         NextToken;
         CheckConst;
         end {if}
      else if token.kind = doublesy then begin
         typeSpec := extendedPtr;
         NextToken;
         CheckConst;
         end; {else if}
      end;

   charsy: begin                        {char}
      NextToken;
      CheckConst;
      typeSpec := uBytePtr;
      end;

   shortsy: begin                       {short}
      NextToken;
      CheckConst;
      if token.kind = intsy then begin
         NextToken;
         CheckConst;
         end; {if}
      typeSpec := wordPtr;
      end;

   floatsy: begin                       {float}
      NextToken;
      CheckConst;
      typeSpec := realPtr;
      end;

   doublesy: begin                      {double}
      NextToken;
      CheckConst;
      typeSpec := doublePtr;
      end;

   compsy: begin                        {comp}
      NextToken;
      CheckConst;
      typeSpec := compPtr;
      end;

   extendedsy: begin                    {extended}
      NextToken;
      CheckConst;
      typeSpec := extendedPtr;
      end;

   voidsy: begin                        {void}
      NextToken;
      CheckConst;
      typeSpec := voidPtr;
      end;

   enumsy: begin                        {enum}
      NextToken;                        {skip the 'enum' token}
      if token.kind = ident then begin  {handle a type definition}
         variable := FindSymbol(token, tagSpace, true, true);
         ttoken := token;
         NextToken;
         if variable <> nil then
            if variable^.itype^.kind = enumType then
               if token.kind <> lbracech then
                  goto 1;
         tPtr := pointer(Malloc(sizeof(typeRecord)));
         tPtr^.size := cgWordSize;
         tPtr^.saveDisp := 0;
         tPtr^.isConstant := false;
         tPtr^.kind := enumType;
         variable :=
            NewSymbol(ttoken.name, tPtr, storageClass, tagSpace, defined);
         CheckConst;
         end {if}
      else if token.kind <> lbracech then
         Error(9);
      enumVal := 0;                     {set the default value}
      if token.kind = lbracech then begin
         NextToken;                     {skip the '{'}
         repeat                         {declare the enum constants}
            tPtr := pointer(Malloc(sizeof(typeRecord)));
            tPtr^.size := cgWordSize;
            tPtr^.saveDisp := 0;
            tPtr^.isConstant := false;
            tPtr^.kind := enumConst;
            if token.kind = ident then begin
               variable :=
                  NewSymbol(token.name, tPtr, ident, variableSpace, defined);
               NextToken;
               end {if}
            else
               Error(9);
            if token.kind = eqch then begin {handle explicit enumeration values}
               NextToken;
               Expression(arrayExpression,[commach,rbracech]);
               enumVal := long(expressionValue).lsw;
               if enumVal <> expressionValue then
                  Error(6);
               end; {if}
            tPtr^.eval := enumVal;      {set the enumeration constant value}
            enumVal := enumVal+1;       {inc the default enumeration value}
            if token.kind = commach then {next enumeration...}
               begin
               done := false;
               NextToken;
               end {if}
            else
               done := true;
         until done or (token.kind = eofsy);
         if token.kind = rbracech then
            NextToken
         else begin
            Error(23);
            SkipStatement;
            end; {else}
         end; {if}
1:    skipDeclarator := token.kind = semicolonch;
      end;
  
   structsy,                            {struct}
   unionsy: begin                       {union}
      globalStruct := false;            {we didn't make it global}
      if token.kind = structsy then     {set the type kind to use}
         tKind := structType
      else
         tKind := unionType;
      structPtr := nil;                 {no record, yet}
      structTypePtr := defaultStruct;   {use int as a default type}
      NextToken;                        {skip 'struct' or 'union'}
      if token.kind in [ident,typedef]  {if there is a struct name then...}
         then begin
					{look up the name}
         structPtr := FindSymbol(token, tagSpace, true, true);
         ttoken := token;               {record the structure name}
         NextToken;                     {skip the structure name}
         if structPtr = nil then begin  {if the name hasn't been defined then...}
            if token.kind <> lbracech then
               structPtr := FindSymbol(ttoken, tagSpace, false, true);
            if structPtr <> nil then
               structTypePtr := structPtr^.itype
            else begin
               isForwardDeclared := true;
               globalStruct := doingParameters and (token.kind <> lbracech);
               if globalStruct then begin
                  lUseGlobalPool := useGlobalPool;
                  useGlobalPool := true;
                  end; {if}
               structTypePtr := pointer(Calloc(sizeof(typeRecord)));
              {structTypePtr^.size := 0;}
              {structTypePtr^.saveDisp := 0;}
              {structTypePtr^.isConstant := false;}
               structTypePtr^.kind := tkind;
              {structTypePtr^.fieldList := nil;}
              {structTypePtr^.sName := nil;}
               structPtr := NewSymbol(ttoken.name, structTypePtr, ident,
                  tagSpace, defined);
               structTypePtr^.sName := structPtr^.name;
               end;
            end {if}
                                        {the name has been defined, so...}
         else if structPtr^.itype^.kind <> tKind then begin
            Error(42);			{it's an error if it's not a struct}
            structPtr := nil;
            end {else}
         else begin                     {record the existing structure type}
            structTypePtr := structPtr^.itype;
            CheckConst;
            end; {else}
         end {if}
      else if token.kind <> lbracech then
         Error(9);                      {its an error if there's no name or struct}
2:    if token.kind = lbracech then     {handle a structure definition...}
         begin                          {error if we already have one!}
         if (structTypePtr <> defaultStruct)
            and (structTypePtr^.fieldList <> nil) then begin
            Error(53);
            structPtr := nil;
            end; {if}
         NextToken;                     {skip the '{'}
         if structTypePtr = defaultStruct then begin
            structTypePtr := pointer(Calloc(sizeof(typeRecord)));
           {structTypePtr^.size := 0;}
           {structTypePtr^.saveDisp := 0;}
           {structTypePtr^.isConstant := false;}
            structTypePtr^.kind := tkind;
           {structTypePtr^.fieldList := nil;}
           {structTypePtr^.sName := nil;}
            end; {if}
         if structPtr <> nil then
            structPtr^.itype := structTypePtr;
         FieldList(structTypePtr,tKind); {define the fields}
         if token.kind = rbracech then  {insist on a closing rbrace}
            NextToken
         else begin
            Error(23);
            SkipStatement;
            end; {else}
         end; {if}
      if globalStruct then
         useGlobalPool := lUseGlobalPool;
      typeSpec := structTypePtr;
      skipDeclarator := token.kind = semicolonch;
      end;
 
   typedef: begin                       {named type definition}
      typeSpec := token.symbolPtr^.itype;
      NextToken;
      end;

   otherwise: ;
   end; {case}

if isconstant then begin                {handle a constant type}
   new(tPtr);
   if typeSpec^.kind in [structType,unionType] then begin
      with tPtr^ do begin
         size := typeSpec^.size;
         kind := definedType;
         dType := typeSpec;
         end; {with}
      end {if}
   else
      tPtr^ := typeSpec^;
   tPtr^.isConstant := true;
   typeSpec := tPtr;
   end; {if}
end; {TypeSpecifier}


{-- Externally available subroutines ---------------------------}

procedure DoDeclaration {doingPrototypes: boolean};

{ process a variable or function declaration                    }
{                                                               }
{ parameters:                                                   }
{       doingPrototypes - are we processing a parameter list?   }

label 1,2,3;

var
   done: boolean;                       {for loop termination}
   foundConstsy: boolean;               {did we find a constsy?}
   fName: stringPtr;                    {for forming uppercase names}
   i: integer;                          {loop variable}
   isAsm: boolean;                      {has the asm modifier been used?}
   lDoingParameters: boolean;           {local copy of doingParameters}
   lisPascal: boolean;                  {local copy of isPascal}
   lp,tlp,tlp2: identPtr;               {for tracing parameter list}
   ltypeSpec: typePtr;                  {copy of type specifier}
   lUseGlobalPool: boolean;             {local copy of useGlobalPool}
   nextPdisp: integer;                  {for calculating parameter disps}
   noFDefinitions: boolean;             {are function definitions inhibited?}
   p1,p2,p3: parameterPtr;              {for reversing prototyped parameters}
   variable: identPtr;                  {pointer to the variable being declared}
   fnType: typePtr;                     {function type}
   segType: integer;                    {segment type}
   tp: typePtr;                         {for tracing type lists}
   tk: tokenType;                       {work token}
   typeFound: boolean;                  {has some type specifier been found?}


   procedure CheckArray (v: identPtr; firstVariable: boolean);
 
   { make sure all required array sizes are specified            }
   {                                                             }
   { parameters:                                                 }
   {     v - pointer to the identifier to check                  }
   {     firstVariable - can the first array subscript be of a   }
   {             non-fixed size?                                 }
 
   label 1;
 
   var
      tp: typePtr;                      {work pointer}
 
   begin {CheckArray}
   if v <> nil then begin               {skip check if there's no variable}
      tp := v^.itype;                   {initialize the type pointer}
      while tp <> nil do begin          {check all types}
         if tp^.kind = arrayType then   {if it's an array with an unspecified  }
            if tp^.elements = 0 then    { size and an unspecified size is not  }
               if not firstVariable then { allowed here, flag an error.         }
                  begin
                  Error(49);
                  goto 1;
                  end; {if}
         firstVariable := false;        {unspecified sizes are only allowed in }
                                        { the first subscript                  }
         case tp^.kind of               {next type...}
            arrayType:
               tp := tp^.aType;
            pointerType: begin
               tp := tp^.pType;
               firstVariable := true;   {(also allowed for pointers to arrays)}
               end;
            functionType:
               tp := tp^.fType;
            otherwise:
               tp := nil;
            end; {case}
         end; {while}
      end; {if}
1:
   end; {CheckArray}


   procedure SegmentStatement;

   { compile a segment statement                                }
   {                                                            }
   { statement syntax:                                          }
   {                                                            }
   {    'segment' string-constant [',' 'dynamic']               }

   var
      i: integer;                       {loop variable}
      len: integer;                     {segment name length}

   begin {SegmentStatement}
   NextToken;
   if token.kind = stringConst then begin
      for i := 1 to 10 do begin
         defaultSegment[i] := chr(0);
         currentSegment[i] := chr(0);
         end; {for}
      len := token.sval^.length;
      if len > 10 then
         len := 10;
      for i := 1 to len do
         defaultSegment[i] := token.sval^.str[i];
      for i := 1 to len do
         currentSegment[i] := token.sval^.str[i];
      FlagPragmas(p_segment);
      NextToken;
      if token.kind = commach then begin
         NextToken;
         if token.kind = ident then begin
            if token.name^ = 'dynamic' then
               segmentKind := $8000
            else Error(84);
            NextToken;
            end {if}
         else Error(84);
         end {if}
      else
         segmentKind := 0;
      Match(semicolonch,22);
      end {if}
   else begin
      Error(83);
      SkipStatement;
      end; {else}
   end; {SegmentStatement}


   function InPartialList (fName: stringPtr): boolean;

   { See if the function is in the partial compile list.        }
   {                                                            }
   { If the function is in the list, the function name is       }
   { removed from the list, and true is returned.  If not,      }
   { false is returned.                                         }
   {                                                            }
   { parameters:                                                }
   {    fName - name of the function to check for               }

   label 1,2;

   var
      ch: char;                         {work character}
      i,j: integer;                     {loop variable}
      len: integer;                     {length of fName}

   begin {InPartialList}
   i := partialFileGS.theString.size;   {strip trailing blanks}
   while (i > 0) and (partialFileGS.theString.theString[i] = ' ') do begin
      partialFileGS.theString.theString[i] := chr(0);
      i := i-1;
      end; {while}
   while partialFileGS.theString.theString[1] = ' ' do               {skip leading blanks}
      for i := 1 to partialFileGS.theString.size do
         partialFileGS.theString.theString[i] :=
            partialFileGS.theString.theString[i+1];
   InPartialList := true;               {assume success}
   i := 1;                              {scan the name list}
   len := length(fName^);
   while partialFileGS.theString.theString[i] <> chr(0) do begin
      for j := 1 to len do begin
         if partialFileGS.theString.theString[i+j-1] <> fName^[j] then
            goto 1;
         end; {for}
      if partialFileGS.theString.theString[i+len] in [' ', chr(0)] then begin

         {found a match - remove from list & return}
         j := i+len;
         while partialFileGS.theString.theString[j] = ' ' do
            j := j+1;
         repeat
            ch := partialFileGS.theString.theString[j];
            partialFileGS.theString.theString[i] := ch;
            i := i+1;
            j := j+1;
         until ch = chr(0);
         goto 2;
         end; {if}
1:    {no match - skip to next name}
      while not (partialFileGS.theString.theString[i] in [chr(0), ' ']) do
         i := i+1;
      while partialFileGS.theString.theString[i] = ' ' do
         i := i+1;
      end; {while}
   InPartialList := false;              {no match found}
2:
   end; {InPartialList}


   procedure SkipFunction (isAsm: boolean);

   { Skip a function body for a partial compile                 }
   {                                                            }
   { Parameters:                                                }
   {    isAsm - are we compiling an asm function?               }

   var
      braceCount: integer;              {# of unmatched { chars}
      doingAsm: boolean;                {compiling an asm statement?}

   begin {SkipFunction}
   Match(lbracech,27);                  {skip to the closing rbrackch}
   braceCount := 1;
   doingAsm := false;
   if isAsm then
      charKinds[ord('#')] := ch_pound;
   while (not (token.kind = eofsy)) and (braceCount <> 0) do begin
      if token.kind = asmsy then begin
         doingAsm := true;
         charKinds[ord('#')] := ch_pound;
         end {if}
      else if token.kind = lbracech then
         braceCount := braceCount+1
      else if token.kind = rbracech then begin
         braceCount := braceCount-1;
         if doingAsm then begin
            doingAsm := false;
            charKinds[ord('#')] := illegal;
            end; {if}
         end; {else if}
      NextToken;
      end; {while}
   nameFound := false;                  {no pc_nam for the next function (yet)}
   doingFunction := false;              {no longer doing a function}
   charKinds[ord('#')] := illegal;      {# is a preprocessor command}
   end; {SkipFunction}


begin {DoDeclaration}
lDoingParameters := doingParameters;    {record the status}
noFDefinitions := false;                {are function definitions inhibited?}
typeFound := false;                     {no explicit type found, yet}
foundConstsy := false;                  {did not find a constsy}
if doingPrototypes then                 {prototypes implies a parm list}
   doingParameters := true
else
   lastParameter := nil;                {init parm list if we're not doing prototypes}
isFunction := false;                    {assume it's not a function}
if not doingFunction then               {handle any segment statements}
   while token.kind = segmentsy do
      SegmentStatement;
inhibitHeader := true;			{block imbedded includes in headers}
if token.kind in [constsy,volatilesy]   {handle leading constsy, volatile}
   then begin
   while token.kind in [constsy,volatilesy] do begin
      if token.kind = constsy then
         foundConstsy := true
      else
         volatile := true;
      NextToken;
      end; {while}
   end; {if}
storageClass := ident;                  {handle a StorageClassSpecifier}
lUseGlobalPool := useGlobalPool;
if token.kind in [autosy,externsy,registersy,staticsy,typedefsy] then begin
   typeFound := true;
   storageClass := token.kind;
   if not doingFunction then
      if token.kind = autosy then
         Error(62);
   if doingParameters then begin
      if token.kind <> registersy then
         Error(87);
      end {if}
   else if storageClass in [staticsy,typedefsy] then
      useGlobalPool := true;
   NextToken;
   end; {if}
isAsm := false;
isPascal := false;
while token.kind in [pascalsy,asmsy] do begin
   if token.kind = pascalsy then
      isPascal := true
   else
      isAsm := true;
   NextToken;
   end; {while}
lisPascal := isPascal;
typeSpec := wordPtr;                    {default type specifier is an integer}
if token.kind in                        {handle a TypeSpecifier/declarator}
   [unsignedsy,signedsy,intsy,longsy,charsy,shortsy,floatsy,doublesy,compsy,
   extendedsy,voidsy,enumsy,structsy,unionsy,typedef,volatilesy,constsy] then
   begin
   typeFound := true;
   TypeSpecifier(false,foundConstsy);
   if not skipDeclarator then begin
      variable := nil;
      Declarator(typeSpec, variable, variableSpace, doingPrototypes);
      if variable = nil then begin
         inhibitHeader := false;
         if token.kind = semicolonch then
            NextToken
         else begin
            Error(22);
            SkipStatement;
            end; {else}
         goto 1;
         end; {if}
      end; {if}
   end {if}
else begin
   variable := nil;
   Declarator (typeSpec, variable, variableSpace, doingPrototypes);
   if variable = nil then begin
      inhibitHeader := false;
      if token.kind = semicolonch then
         NextToken
      else begin
         Error(22);
         SkipStatement;
         end; {else}
      goto 1;
      end; {if}
   end;
isPascal := lisPascal;

{make sure variables have some type info}
if isFunction then begin
   if not typeFound then
      if (lint & lintNoFnType) <> 0 then
         Error(104);
   end {if}
else
   if not typeFound then
      Error(26);

3:
{handle a function declaration}
if isFunction then begin

   if doingParameters then              {a function cannot be a parameter}
      Error(28);
   fnType := variable^.itype;           {get the type of the function}
   while (fnType <> nil) and (fnType^.kind <> functionType) do
      case fnType^.kind of
         arrayType  : fnType := fnType^.aType;
         pointerType: fnType := fnType^.pType;
         definedType: fnType := fnType^.dType;
         otherwise  : fnType := nil;
         end; {case}
   if fnType = nil then begin
      SkipStatement;
      goto 1;
      end; {if}
   if isPascal then begin		{reverse prototyped parameters}
      p1 := fnType^.parameterList;
      if p1 <> nil then begin
         p2 := nil;
         while p1 <> nil do begin
            p3 := p1;
            p1 := p1^.next;
            p3^.next := p2;
            p2 := p3;
            end; {while}
         fnType^.parameterList := p2;
         end; {if}
      end; {if}

   {handle functions in the parameter list}
   if doingPrototypes then
      PopTable

   {external or forward declaration}
   else if (storageClass = externsy)
      or (token.kind in [commach,semicolonch,inlinesy]) then begin
      fnType^.isPascal := isPascal;     {note if we have pascal parms}
      if token.kind = inlinesy then     {handle tool declarations}
         with fnType^ do begin
            NextToken;
            Match(lparench,13);
            if token.kind in [intconst,uintconst] then begin
               toolNum := token.ival;
               NextToken;
               end {if}
            else
               Error(18);
            Match(commach,86);
            if token.kind in [longconst,ulongconst] then begin
               dispatcher := token.lval;
               NextToken;
               end {if}
            else if token.kind in [intconst,uintconst] then begin
               dispatcher := token.ival;
               NextToken;
               end {if}
            else
               Error(18);
            Match(rparench,12);
            end; {with}
      doingParameters := doingPrototypes; {not doing parms any more}
      if token.kind = semicolonch then begin
         inhibitHeader := false;
         NextToken;                     {skip the trailing semicolon}
         end {if}
      else if (token.kind = commach) and (not doingPrototypes) then begin
         PopTable;			{pop the symbol table}
         NextToken;                     {allow further declarations}
         variable := nil;
         isFunction := false;
         Declarator (typeSpec, variable, variableSpace, doingPrototypes);
         if variable = nil then begin
            inhibitHeader := false;
            if token.kind = semicolonch then
               NextToken
            else begin
               Error(22);
               SkipStatement;
               end; {else}
            goto 1;
            end; {if}
         goto 3;
         end {else if}
      else begin
         Error(22);
         SkipStatement;
         end; {else}
      PopTable;				{pop the symbol table}
      end {if}

   {cannot imbed functions...}
   else if doingFunction then begin
      isPascal := false;
      Error(28);
      while token.kind <> eofsy do
         NextToken;
      end {if}

   {local declaration}
   else begin
      if noFDefinitions then
         Error(22);
      ftype := fnType^.ftype;           {record the type of the function}
      while fType^.kind = definedType do
         fType := fType^.dType;
      variable^.state := defined;       {note that the function is defined}
      pfunc := variable;                {set the identifier for parm checks}
      fnType^.isPascal := isPascal;     {note if we have pascal parms}
      doingFunction := true;            {read the parameter list}
      doingParameters := true;
                                        {declare the parameters}
      lp := lastParameter;              {(save now; it's volatile)}
      while not (token.kind in [lbracech,eofsy]) do
         if (token.kind in [autosy,externsy,registersy,staticsy,typedefsy,
                            unsignedsy,signedsy,intsy,longsy,charsy,shortsy,
                            floatsy,doublesy,compsy,extendedsy,enumsy,
                            structsy,unionsy,typedef,voidsy,volatilesy,
                            constsy,ident]) then
            DoDeclaration(false)
         else begin
            Error(27);
            NextToken;
            end; {else}
      if numberOfParameters <> 0 then   {default K&R parm type is int}
         begin
         tlp := lp;
         while tlp <> nil do begin
            if tlp^.itype = nil then
               tlp^.itype := wordPtr;
            tlp := tlp^.pnext;
            end; {while}
         end; {if}
      tlp := lp;			{make sure all parameters have an}
      while tlp <> nil do		{ identifier			 }
         if tlp^.name^ = '?' then begin
            Error(113);
            tlp := nil;
            end {if}
         else
            tlp := tlp^.pnext;
      doingParameters := false;
      fName := variable^.name;          {skip if this is not needed for a      }
      if doingPartial then              { partial compile                      }
         if not InPartialList(fName) then begin
            SkipFunction(isAsm);
            goto 2;
            end; {if}
      TermHeader;			{make sure the header file is closed}
      if progress then                  {write progress information}
         writeln('Compiling ', fName^);
      useGlobalPool := false;           {start a local label pool}
      if not codegenStarted and (liDCBGS.kFlag <> 0) then begin {init the code generator (if it needs it)}
         CodeGenInit (outFileGS, liDCBGS.kFlag, doingPartial);
         liDCBGS.kFlag := 3;
         codegenStarted := true;
         end; {if}
      foundFunction := true;            {got one...}
      segType := ord(variable^.class = staticsy) * $4000;
      if fnType^.isPascal then begin
         fName := pointer(Malloc(length(variable^.name^)+1));
         CopyString(pointer(fName), pointer(variable^.name));
         for i := 1 to length(fName^) do
            if fName^[i] in ['a'..'z'] then
               fName^[i] := chr(ord(fName^[i]) & $5F);
         Gen2Name (dc_str, segType, 0, fName);
         end {if}
      else
         Gen2Name (dc_str, segType, 0, variable^.name);
      doingMain := variable^.name^ = 'main';
      firstCompoundStatement := true;
      Gen0 (dc_pin);
      if not isAsm then
         Gen0(pc_ent);
      nextLocalLabel := 1;              {initialize GetLocalLabel}
      returnLabel := GenLabel;          {set up an exit point}
      tempList := nil;                  {initialize the work label list}
      if not isAsm then                 {generate traceback, profile code}
         if traceBack or profileFlag then begin
            if traceBack then
               nameFound := true;
            GenPS(pc_nam, variable^.name);
            end; {if}
      nextPdisp := 0;                   {assign displacements to the parameters}
      if not fnType^.isPascal then begin
         tlp := lp;
         lp := nil;
         while tlp <> nil do begin
            tlp2 := tlp;
            tlp := tlp^.pnext;
            tlp2^.pnext := lp;
            lp := tlp2;
            end; {while}
         end; {if}
      while lp <> nil do begin
         lp^.pdisp := nextPdisp;
         if lp^.itype^.kind = arrayType then
            nextPdisp := nextPdisp + cgPointerSize
         else begin
            if lp^.itype^.kind = scalarType then
               if lp^.itype^.baseType in [cgReal,cgDouble,cgComp] then
                  {all floating-points are passed as extended}
                  lp^.itype := extendedPtr;
            nextPdisp := nextPdisp + long(lp^.itype^.size).lsw;
            if (long(lp^.itype^.size).lsw = 1)
               and (lp^.itype^.kind = scalarType) then
               nextPdisp := nextPdisp+1;
            end; {else}
         lp := lp^.pnext;
         end; {while}
      gotoList := nil;                  {initialize the label list}
                                        {set up struct/union area}
      if variable^.itype^.ftype^.kind in [structType,unionType] then begin
         lp := NewSymbol(@'@struct', variable^.itype^.ftype, staticsy,
            variablespace, declared);
         tk.kind := ident;
         tk.class := identifier;
         tk.name := @'@struct';
         tk.symbolPtr := nil;
         lp := FindSymbol(tk, variableSpace, false, true);
         Gen1Name(pc_lao, 0, lp^.name);
         Gen2t(pc_str, 0, 0, cgULong);
         end; {if}
      if isAsm then begin
         AsmFunction(variable);         {handle assembly language functions}
         PopTable;
         end {if}
      else begin
					{generate parameter labels}
         if fnType^.overrideKR then
            GenParameters(nil)
         else
            GenParameters(fnType^.parameterList); 
         CompoundStatement(false);      {process the statements}
         end; {else}
      end; {else}
2: ;
   end {if}

{handle a variable declaration}
else {if not isFunction then} begin
   noFDefinitions := true;
   if not SkipDeclarator then
      repeat
         if isPascal then begin
            tp := variable^.itype;
            while tp <> nil do
               case tp^.kind of
                  scalarType,
                  enumType,
                  enumConst,
                  definedType,
                  structType,
                  unionType:    begin tp := nil; Error(94); end;
                  arrayType:    tp := tp^.atype;
                  pointerType:  tp := tp^.pType;
                  functionType: begin tp^.isPascal := true; tp := nil; end;
                  end; {case}
            end; {if}
         if token.kind = eqch then begin
            if storageClass = typedefsy then
               Error(52);
            if doingPrototypes then
               Error(88);
            NextToken;                  {handle an initializer}
            ltypeSpec := typeSpec;
            Initializer(variable);
            typeSpec := ltypeSpec;
            end; {if}
                                        {check to insure array sizes are specified}
         if storageClass <> typedefsy then
            CheckArray(variable, (storageClass = externsy) or doingParameters);
                                        {allocate space}
         if variable^.storage = stackFrame then begin
            variable^.lln := GetLocalLabel;
            Gen2(dc_loc, variable^.lln, long(variable^.itype^.size).lsw);
            end; {if}
         if (token.kind = commach) and (not doingPrototypes) then begin
            done := false;              {allow multiple variables on one line}
            NextToken;
            variable := nil;
            Declarator(typeSpec, variable, variableSpace, doingPrototypes);
            if variable = nil then begin
               if token.kind = semicolonch then
                  NextToken
               else begin
                  Error(22);
                  SkipStatement;
                  end; {else}
               goto 1;
               end; {if}
            goto 3;
            end {if}
         else
            done := true;
      until done or (token.kind = eofsy);
   if doingPrototypes then begin
      protoVariable := variable;        {make the var available to Declarator}
      if protoVariable = nil then
         protoType := typeSpec
      else
         protoType := protoVariable^.iType;
      end {if}
   else begin
      inhibitHeader := false;
      if token.kind = semicolonch then  {must end with a semicolon}
         NextToken
      else begin
         Error(22);
         SkipStatement;
         end; {else}
      end; {else}
   end; {else}
1:
doingParameters := lDoingParameters;    {restore the status}
useGlobalPool := lUseGlobalPool;
inhibitHeader := false;
end; {DoDeclaration}


procedure DoStatement;

{ process a statement from a function                           }


   procedure AutoInit;
   
   { initialize auto variables                                  }
   
   var
      count: integer;                   {initializer counter}
      ip: identPtr;                     {pointer to a symbol table entry}
      lp1,lp2: identList;               {used to reverse, track the list}
      iPtr: initializerPtr;             {pointer to the next initializer}


      procedure Initialize (id: identPtr; disp: longint; itype: typePtr);

      { initialize a variable                                   }
      {                                                         }
      { parameters:                                             }
      {    id - pointer to the identifier                       }
      {    disp - disp past the identifier to initialize        }
      {    itype - type of the variable to initialize           }
      {                                                         }
      { variables:                                              }
      {    count - number of times to re-use the initializer    }
      {    ip - pointer to the initializer record to use        }

      label 1;

      var
         elements: longint;             {# array elements}
         fp: identPtr;                  {for tracing field lists}
         size: integer;			{fill size}
         union: boolean;                {are we doing a union?}

                                        {bit field manipulation}
                                        {----------------------}
         bitcount: integer;             {# if bits so far}
         bitsize,bitdisp: integer;      {defines size, location of a bit field}

                                        {assignment conversion}
                                        {---------------------}
         tree: tokenPtr;                {expression tree}
         val: longint;                  {constant expression value}
         isConstant: boolean;           {is the expression a constant?}


         procedure LoadAddress;

         { Load the address of the operand                      }

         begin {LoadAddress}
         with id^ do                    {load the base address}
            case storage of
               stackFrame:     Gen2(pc_lda, lln, 0);
               parameter:      if itype^.kind = arrayType then
                                  Gen2t(pc_lod, pln, 0, cgULong)
                               else
                                  Gen2(pc_lda, pln, 0);
               external,
               global,
               private:        Gen1Name(pc_lao, 0, name);
               otherwise: ;
               end; {case}
         if disp <> 0 then
            Gen1t(pc_inc, long(disp).lsw, cgULong)
         end; {LoadAddress}


         function ZeroFill (elements: longint; itype: typePtr;
                            count: integer; iPtr: initializerPtr): boolean;

         { See if an array can be zero filled				}
         {								}
         { parameters:							}
         {    elements - elements in the array				}
         {    itype - type of each array element			}
         {    count - remaining initializer repititions			}
         {    iPtr - initializer record					}

         begin {ZeroFill}
         ZeroFill := false;
         if not iPtr^.isConstant then
            if itype^.kind in [scalarType,enumType] then
               if count >= elements then
                  with iPtr^.itree^ do
        	     if token.kind = intconst then
                        if token.ival = 0 then
                           ZeroFill := true;
         end; {ZeroFill}


      begin {Initialize}
      case itype^.kind of

         scalarType,pointerType,enumType,functionType: begin
            LoadAddress;                {load the destination address}
            doDispose := count = 1;     {generate the expression value}
            tree := iptr^.itree;        {see if this is a constant}
                                        {do assignment conversions}
            while tree^.token.kind = castoper do
               tree := tree^.left;
            isConstant := tree^.token.class in [intConstant,longConstant];
            if isConstant then
               if tree^.token.class = intConstant then
                  val := tree^.token.ival
               else
                  val := tree^.token.lval;

{        if isConstant then
            if tree^.token.class = intConstant then
               Writeln('loc 2: bitsize = ', iPtr^.bitsize:1, '; ival = ', tree^.token.ival:1) {debug}
{           else
               Writeln('loc 2: bitsize = ', iPtr^.bitsize:1, '; lval = ', tree^.token.lval:1) {debug}
{        else
            Writeln('loc 2: bitsize = ', iPtr^.bitsize:1); {debug}

            GenerateCode(iptr^.iTree);
            AssignmentConversion(itype, expressionType, isConstant, val, true,
               false);
            case itype^.kind of         {save the value}
               scalarType:
                  if iptr^.bitsize <> 0 then
                     Gen2t(pc_sbf, iptr^.bitdisp, iptr^.bitsize, itype^.basetype)
                  else
                     Gen0t(pc_sto, itype^.baseType);
               enumType:
                  Gen0t(pc_sto, cgWord);
               pointerType,functionType:
                  Gen0t(pc_sto, cgULong);
               end; {case}
            end;

         arrayType: begin
            if itype^.aType^.kind = scalarType then
               if itype^.aType^.baseType in [cgByte,cgUByte] then
                  if iPtr^.iTree^.token.kind = stringConst then begin
                     GenLdcLong(itype^.elements);
                     Gen0t(pc_stk, cgULong);
                     GenS(pc_lca, iPtr^.iTree^.token.sval);
                     Gen0t(pc_stk, cgULong);
                     Gen0t(pc_bno, cgULong);
                     LoadAddress;
                     Gen0t(pc_stk, cgULong);
                     Gen0t(pc_bno, cgULong);
                     Gen1tName(pc_cup, 0, cgVoid, @'strncpy');
                     iPtr := iPtr^.next;
                     goto 1;
                     end; {if}
            elements := itype^.elements;
            itype := itype^.atype;
            if ZeroFill(elements, itype, count, iPtr) then begin
               if itype^.kind = enumType then
                  size := cgWordSize
               else
                  size := TypeSize(itype^.baseType);
               size := size * long(elements).lsw;
               LoadAddress;
               Gen0t(pc_stk, cgULong);
               Gen1t(pc_ldc, size, cgWord);
               Gen0t(pc_stk, cgWord);
               Gen0t(pc_bno, cgULong);
               Gen1tName(pc_cup, 0, cgVoid, @'~ZERO');
               disp := disp + size;
               count := count - long(elements).lsw;
               if count = 0 then begin
                  iPtr := iPtr^.next;
                  count := iPtr^.count;
                  end; {if}
               end {if}
            else begin
               while elements <> 0 do begin
        	  Initialize(id, disp, itype);
        	  if itype^.kind in [scalarType,pointerType,enumType] then begin
                     count := count-1;
                     if count = 0 then begin
                	iPtr := iPtr^.next;
                	count := iPtr^.count;
                	end; {if}
                     end; {if}
        	  disp := disp+itype^.size;
        	  elements := elements-1;
        	  end; {while}
               end; {else}
1:          end;

         structType,unionType: begin
            if iPtr^.isStruct then begin
               LoadAddress;             {load the destination address}
               GenerateCode(iptr^.iTree); {load the stuct address}
                                        {do the assignment}
               AssignmentConversion(itype, expressionType, isConstant, val,
                  true, false);
               with expressionType^ do
                  Gen2(pc_mov, long(size).msw, long(size).lsw);
               Gen0t(pc_pop, UsualUnaryConversions);
               end {if}
            else begin
               union := itype^.kind = unionType;
               fp := itype^.fieldList;
               bitsize := iPtr^.bitsize;
               bitdisp := iPtr^.bitdisp;
               bitcount := 0;
               while fp <> nil do begin
                  itype := fp^.itype;
{                 writeln('Initialize:    disp = ',    disp:3, '; fp^.   Disp = ', fp^.disp:3, 'itype^.size = ', itype^.size:1); {debug}
{                 writeln('            bitDisp = ', bitDisp:3, '; fp^.bitDisp = ', fp^.bitDisp:3); {debug}
{                 writeln('            bitSize = ', bitSize:3, '; fp^.bitSize = ', fp^.bitSize:3); {debug}
                  Initialize(id, disp, itype);
                  if bitsize = 0 then begin
                     if bitcount <> 0 then begin
                        disp := disp + (bitcount+7) div 8;
                        bitcount := 0;
                        end {if}
                     else if fp^.bitSize <> 0 then begin
                        bitcount := 8;
                        while (fp <> nil) and (bitcount > 0) do begin
                           bitcount := bitcount - fp^.bitSize;
                           if bitcount > 0 then
                              if fp^.next <> nil then
                                 if fp^.next^.bitSize <> 0 then
                                    fp := fp^.next
                        	 else
                        	    bitcount := 0;
                           end; {while}
                        bitcount := 0;
                        disp := disp + 1;
                        end {else if}
                     else
                        disp := disp + itype^.size;
                     end {if}
                  else if fp^.bitSize = 0 then begin
                     bitsize := 0;
                     disp := disp + itype^.size;
                     end {else if}
                  else begin
                     if bitsize + bitdisp < bitcount then
                        disp := disp + (bitcount + 7) div 8;
                     bitcount := bitsize + bitdisp;
                     end; {else}
                  if itype^.kind in [scalarType,pointerType,enumType] then begin
                     count := count-1;
                     if count = 0 then begin
                        iPtr := iPtr^.next;
                        count := iPtr^.count;
                        bitsize := iPtr^.bitsize;
                        bitdisp := iPtr^.bitdisp;
                        end; {if}
                     end; {if}
                  if union then
                     fp := nil
                  else
                     fp := fp^.next;
                  end; {while}
               end; {else}
            end;

         otherwise: Error(57);
         end; {case}
      end; {Initialize}


   begin {AutoInit}
   lp1 := nil;                          {reverse the list}
   while initializerList <> nil do begin
      lp2 := initializerList;
      initializerList := lp2^.next;
      lp2^.next := lp1;
      lp1 := lp2;
      end; {while}
  while lp1 <> nil do begin             {initialize the variables}
     ip := lp1^.id;
     iPtr := ip^.iPtr;
     count := iPtr^.count;
     if ip^.class <> staticsy then
        Initialize(ip, 0, ip^.itype);
     lp2 := lp1;
     lp1 := lp1^.next;
     dispose(lp2);
     end; {while}
   end; {AutoInit}


begin {DoStatement}
case statementList^.kind of

   compoundSt: begin
      if token.kind = rbracech then begin
         if statementList^.doingDeclaration then
            if initializerList <> nil then
               AutoInit;
         EndCompoundStatement;
         end {if}
      else if (statementList^.doingDeclaration = true)
         and (token.kind in [autosy,externsy,registersy,staticsy,typedefsy,
                             unsignedsy,signedsy,intsy,longsy,charsy,shortsy,
                             floatsy,doublesy,compsy,extendedsy,enumsy,
                             structsy,unionsy,typedef,voidsy,volatilesy,
                             constsy])
         then
         DoDeclaration(false)
      else begin
         if statementList^.doingDeclaration then begin
            statementList^.doingDeclaration := false;
            if firstCompoundStatement then begin
               Gen1Name(dc_sym, ord(doingMain), pointer(table));
               firstCompoundStatement := false;
               end; {if}
            if initializerList <> nil then
               AutoInit;
            end; {if}
         Statement;
         end; {else}
      end;
 
   ifSt:
      EndIfStatement;
 
   elseSt:
      EndElseStatement;
 
   doSt:
      EndDoStatement;
 
   whileSt:
      EndWhileStatement;
 
   forSt:
      EndForStatement;

   switchSt:
      EndSwitchStatement;

   otherwise: Error(57);
   end; {case}
end; {DoStatement}


procedure InitParser;

{ Initialize the parser                                         }

begin {InitParser}
doingFunction := false;                 {not doing a function (yet)}
doingParameters := false;               {not processing parameters}
lastLine := 0;                          {no pc_lnm generated yet}
nameFound := false;                     {no pc_nam generated yet}
statementList := nil;                   {no open statements}
codegenStarted := false;                {code generator is not started}
end; {InitParser}


procedure TermParser;

{ shut down the parser                                          }

begin {TermParser}
if statementList <> nil then
   case statementList^.kind of
      compoundSt  : Error(34);
      doSt        : Error(33);
      elseSt      : Error(67);
      forSt       : Error(69);
      ifSt        : Error(32);
      switchSt    : Error(70);
      whileSt     : Error(68);
      otherwise: Error(57);
      end; {case}
end; {TermParser}

end.
