{$optimize 1}
{---------------------------------------------------------------}
{                                                               }
{  Parser                                                       }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  DoDeclaration - process a variable or function declaration   }
{  DoStatement - process a statement from a function            }
{  AutoInit - generate code to initialize an auto variable      }
{  InitParser - initialize the parser                           }
{  Match - insure that the next token is of the specified type  }
{  TermParser - shut down the parser                            }
{  DeclarationSpecifiers - handle a type specifier              }
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


function TypeName: typePtr;

{ process a type name (used for casts and sizeof/_Alignof)      }
{                                                               }
{ returns: a pointer to the type                                }


procedure AutoInit (variable: identPtr; line: longint;
   isCompoundLiteral: boolean);

{ generate code to initialize an auto variable                  }
{                                                               }
{ parameters:                                                   }
{       variable - the variable to initialize                   }
{       line - line number (used for debugging)                 }
{       isCompoundLiteral - initializing a compound literal?    }


function MakeFuncIdentifier: identPtr;

{ Make the predefined identifier __func__.                      }
{                                                               }
{ It is inserted in the symbol table as if the following        }
{ declaration appeared at the beginning of the function body:   }
{                                                               }
{     static const char __func__[] = "function-name";           }
{                                                               }
{ This must only be called within a function body.              }


function MakeCompoundLiteral(tp: typePtr): identPtr;

{ Make the identifier for a compound literal.                   }
{                                                               }
{ parameters:                                                   }
{       tp - the type of the compound literal                   }


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
      val: longlong;                    {switch value}
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
            lFenvAccess: boolean;       {previous value of fenvAccess just}
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
            ln: integer;                {temp var number}
            size: integer;              {temp var size}
            labelCount: integer;        {# of switch labels}
            switchExit: integer;        {branch point}
            switchLab: integer;         {branch point}
            switchList: switchPtr;      {list of labels and values}
            switchDefault: integer;     {default branch point}
            );
      end;

                                        {type info for a declaration}
                                        {---------------------------}
   declSpecifiersRecord = record
      storageClass: tokenEnum;          {storage class of the declaration}
      typeSpec: typePtr;                {type specifier}
      declarationModifiers: tokenSet;   {all storage class specifiers, type }
                                        {qualifiers, function specifiers, & }
                                        {alignment specifiers in declaration}
      end;

var
   firstCompoundStatement: boolean;     {are we doing a function level compound statement?}
   fType: typePtr;                      {return type of the current function}
   functionName: stringPtr;             {name of the current function}
   isForwardDeclared: boolean;          {is the field list component           }
                                        { referencing a forward struct/union?  }
   isFunction: boolean;                 {is the declaration a function?}
   returnLabel: integer;                {label for exit point}
   statementList: statementPtr;         {list of open statements}
   savedVolatile: boolean;              {saved copy of volatile}
   doingForLoopClause1: boolean;        {doing the first clause of a for loop?}
   compoundLiteralNumber: integer;      {number of compound literal}
   compoundLiteralToAllocate: identPtr; {compound literal that needs space allocated}
   vaInfoLLN: integer;                  {label number of internal va info (0 for none)}
   declaredTagOrEnumConst: boolean;     {was a tag or enum const declared?}

                                        {parameter processing variables}
                                        {------------------------------}
   lastParameter: identPtr;             {next parameter to process}
   numberOfParameters: integer;         {number of indeclared parameters}
   pfunc: identPtr;                     {func. for which parms are being defined}
   protoType: typePtr;                  {type from a parameter list}
   protoVariable: identPtr;             {variable from a parameter list}

                                        {syntactic classes of tokens}
                                        {---------------------------}
{  specifierQualifierListElement: tokenSet; (in CCommon)}
{  topLevelDeclarationStart: tokenSet; (in CCommon)}
   localDeclarationStart: tokenSet;
   declarationSpecifiersElement: tokenSet;
   structDeclarationStart: tokenSet;

{-- External procedures ----------------------------------------}

function slt64(a,b: longlong): boolean; extern;

function sgt64(a,b: longlong): boolean; extern;

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
{ parameters:                                                   }
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
{       function's outer wrapper, true for imbedded statements)	}

var
   stPtr: statementPtr;                 {for creating a compound statement record}

begin {CompoundStatement}
new(stPtr);                             {create a statement record}
stPtr^.lFenvAccess := fenvAccess;       {save existing value of fenvAccess}
Match(lbracech,27);                     {make sure there is an opening '{'}
stPtr^.next := statementList;
statementList := stPtr;
stPtr^.kind := compoundSt;
if makeSymbols then			{create a symbol table}
   PushTable;
stPtr^.doingDeclaration := true;        {allow declarations}
end; {CompoundStatement}


procedure EndCompoundStatement;

{ finish off a compound statement                               }

var
   dumpLocal: boolean;                  {dump the local memory pool?}
   tl: tempPtr;                         {work pointer}
   stPtr: statementPtr;                 {work pointer}

begin {EndCompoundStatement}
while compoundLiteralToAllocate <> nil do begin  {allocate compound literals}
   Gen2(dc_loc, compoundLiteralToAllocate^.lln,
      long(compoundLiteralToAllocate^.itype^.size).lsw);
   compoundLiteralToAllocate := compoundLiteralToAllocate^.clnext;
   end {while};
dumpLocal := false;
stPtr := statementList;                 {pop the statement record}
statementList := stPtr^.next;
doingFunction := statementList <> nil;  {see if we're done with the function}
if not doingFunction then begin         {if so, finish it off}
   if doingMain then begin              {executing to the end of main returns 0}
      if fType^.kind = scalarType then begin
         if fType^.baseType in [cgByte,cgUByte,cgWord,cgUWord] then begin
            Gen1t(pc_ldc, 0, fType^.baseType);
            Gen2t(pc_str, 0, 0, fType^.baseType);
            end {if}
         else if fType^.baseType in [cgLong,cgULong] then begin
            GenLdcLong(0);
            Gen2t(pc_str, 0, 0, fType^.baseType);
            end; {else if}
         end {if}
      else if fType^.kind = enumType then begin
         Gen1t(pc_ldc, 0, cgWord);
         Gen2t(pc_str, 0, 0, cgWord);
         end; {else if}
      end; {if}
   Gen1(dc_lab, returnLabel);
   if vaInfoLLN <> 0 then begin         {clean up variable args, if any}
      Gen2(pc_lda, vaInfoLLN, 0);
      Gen0t(pc_stk, cgULong);
      Gen1tName(pc_cup, -1, cgVoid, @'__va_end');
      end; {if}
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
   volatile := savedVolatile;           {local volatile vars are out of scope}
   fIsNoreturn := false;                {not doing a noreturn function}
   functionTable := nil;
   functionName := nil;
   end; {if}
PopTable;				{remove this symbol table}
fenvAccess := stPtr^.lFenvAccess;       {restore old value of fenvAccess}
dispose(stPtr);                         {dump the record}
if dumpLocal then begin
   useGlobalPool := true;               {start using the global memory pool}
   LInit;                               {dispose of the local memory pool}
   end; {if}
NextToken;                              {remove the rbracech token}
end; {EndCompoundStatement}


procedure RecordLineNumber (lineNumber: longint);

{ generate debug code to record the line number as specified    }

var
   newSourceFileGS: gsosOutStringPtr;

begin {RecordLineNumber}
if (lastLine <> lineNumber) or changedSourceFile then begin
   lastLine := lineNumber;
   if changedSourceFile then begin
      newSourceFileGS := pointer(Malloc(sizeof(gsosOutString)));
      newSourceFileGS^ := sourceFileGS;
      Gen2Name(pc_lnm, ord(lineNumber), ord(debugType), pointer(newSourceFileGS));
      changedSourceFile := false;
      end {if}
   else
      Gen2Name(pc_lnm, ord(lineNumber), ord(debugType), nil);
   end; {if}
end; {RecordLineNumber}


procedure Statement;

{ handle a statement                                            }

label 1;

var
   lToken,tToken: tokenType;            {for look-ahead}
   lSuppressMacroExpansions: boolean;   {local copy of suppressMacroExpansions}


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
 
   { handle an assignment statement                              }
 
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
      val: longlong;                    {case label value}

   begin {CaseStatement}
   while token.kind = casesy do begin
      NextToken;                        {skip the 'case' token}
      stPtr := GetSwitchRecord;         {get the proper switch record}
      Expression(arrayExpression, [colonch]); {evaluate the branch condition}
      GetLLExpressionValue(val);
      if stPtr^.size = cgLongSize then begin {convert out-of-range values}
         if val.lo < 0 then
            val.hi := -1
         else
            val.hi := 0;
         end {if}
      else if stPtr^.size = cgWordSize then begin
         if long(val.lo).lsw < 0 then begin
            val.hi := -1;
            val.lo := val.lo | $FFFF0000;
            end {if}
         else begin
            val.hi := 0;
            val.lo := val.lo & $0000FFFF;
            end; {else}
         end; {else if}
      if stPtr = nil then
         Error(72)
      else begin
         new(swPtr2);                   {create the new label table entry}
         swPtr2^.lab := GenLabel;
         Gen1(dc_lab, swPtr2^.lab);
         swPtr2^.val := val;
         swPtr := stPtr^.switchList;
         if val.lo > stPtr^.maxVal then
            stPtr^.maxVal := val.lo;
         if swPtr = nil then begin      {enter it in the table}
            swPtr2^.last := nil;
            swPtr2^.next := nil;
            stPtr^.switchList := swPtr2;
            stPtr^.labelCount := 1;
            end {if}
         else begin
            while (swPtr^.next <> nil) and slt64(swPtr^.val, val) do
               swPtr := swPtr^.next;
            if (swPtr^.val.lo = val.lo) and (swPtr^.val.hi = val.hi) then
               Error(73)
            else if sgt64(swPtr^.val, val) then begin
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
   if c99Scope then PushTable;
   if c99Scope then PushTable;
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

   if c99Scope then PushTable;
   Match(lparench,13);                  {evaluate the start condition}
   if allowMixedDeclarations and (token.kind in localDeclarationStart) then begin
      doingForLoopClause1 := true;
      DoDeclaration(false);
      doingForLoopClause1 := false;
      end {if}
   else if token.kind <> semicolonch then begin
      Expression(normalExpression, [semicolonch]);
      Gen0t(pc_pop, UsualUnaryConversions);
      Match(semicolonch,22);
      end {else if}
   else
      NextToken;

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

   if c99Scope then PushTable;
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
   if c99Scope then PushTable;
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
   if c99Scope then PushTable;
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
   if fIsNoreturn then
      if (lint & lintReturn) <> 0 then
         Error(153);
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
         end {if}
      else if fType^.kind = scalarType then
         if fType^.baseType in [cgQuad,cgUQuad] then
            Gen2t(pc_lod, 0, 0, cgULong);
      Expression(normalExpression, [semicolonch]);
      AssignmentConversion(fType, expressionType, lastWasConst, lastConst,
         true, false);
      case fType^.kind of
         scalarType:    if fType^.baseType in [cgQuad,cgUQuad] then
                           Gen0t(pc_sto, fType^.baseType)
                        else
                           Gen2t(pc_str, 0, 0, fType^.baseType);
         enumType:      Gen2t(pc_str, 0, 0, cgWord);
         pointerType:   Gen2t(pc_str, 0, 0, cgULong);
         structType,
         unionType:     begin
                        Gen2(pc_mov, long(size).msw, long(size).lsw);
                        Gen0t(pc_pop, cgULong);
                        end;
         otherwise:     ;
         end; {case}
      end {if}
   else begin
      if (fType^.kind <> scalarType) or (fType^.baseType <> cgVoid) then
         if ((lint & lintC99Syntax) <> 0) or ((lint & lintReturn) <> 0) then
            Error(152);
      end; {else}
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
   stPtr^.labelCount := 0;
   stPtr^.switchLab := GenLabel;
   stPtr^.switchExit := GenLabel;
   stPtr^.breakLab := stPtr^.switchExit;
   stPtr^.switchList := nil;
   stPtr^.switchDefault := 0;
   if c99Scope then PushTable;
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression,[rparench]);
   Match(rparench, 12);
   tp := expressionType;                {make sure the expression is integral}
   while tp^.kind = definedType do
      tp := tp^.dType;
   case tp^.kind of

      scalarType:
         if tp^.baseType in [cgQuad,cgUQuad] then begin
            stPtr^.size := cgQuadSize;
            stPtr^.ln := GetTemp(cgQuadSize);
            Gen2t(pc_str, stPtr^.ln, 0, cgQuad);
            end {if}
         else if tp^.baseType in [cgLong,cgULong] then begin
            stPtr^.size := cgLongSize;
            stPtr^.ln := GetTemp(cgLongSize);
            Gen2t(pc_str, stPtr^.ln, 0, cgLong);
            end {if}
         else if tp^.baseType in [cgByte,cgUByte,cgWord,cgUWord] then begin
            stPtr^.size := cgWordSize;
            stPtr^.ln := GetTemp(cgWordSize);
            Gen2t(pc_str, stPtr^.ln, 0, cgWord);
            end {else if}
         else
            Error(71);

      enumType: begin
         stPtr^.size := cgWordSize;
         stPtr^.ln := GetTemp(cgWordSize);
         Gen2t(pc_str, stPtr^.ln, 0, cgWord);
         end;

      otherwise:
         Error(71);
      end; {case}
   Gen1(pc_ujp, stPtr^.switchLab);      {branch to the xjp instruction}
   if c99Scope then PushTable;
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
   if c99Scope then PushTable;
   Match(lparench, 13);                 {evaluate the condition}
   Expression(normalExpression, [rparench]);
   Match(rparench, 12);
   CompareToZero(pc_neq);               {evaluate the condition}
   Gen1(pc_fjp, endl);
   if c99Scope then PushTable;
   Statement;                           {process the first loop body statement}
   end; {WhileStatement}

begin {Statement}
1:
{if trace names are enabled and a line # is due, generate it}
if traceBack or debugFlag then
   if nameFound or debugFlag then
      RecordLineNumber(lineNumber);

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
                        lSuppressMacroExpansions := suppressMacroExpansions;
                        suppressMacroExpansions := true;
                        lToken := token;
                        NextToken;
                        tToken := token;
                        PutBackToken(token, true);
                        token := lToken;
                        suppressMacroExpansions := lSuppressMacroExpansions;
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
if c99Scope then PopTable;
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
if c99Scope then PopTable;
end; {EndDoStatement}


procedure EndIfStatement;

{ finish off an if statement                                    }

var
   lab1,lab2: integer;                  {branch labels}
   stPtr: statementPtr;                 {work pointer}

begin {EndIfStatement}
if c99Scope then PopTable;
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
   if c99Scope then PushTable;
   Statement;                           {evaluate the else clause}
   end {if}
else begin
   Gen1(dc_lab, lab1);                  {create label for if to branch to}
   if c99Scope then PopTable;
   end; {else}
end; {EndIfStatement}


procedure EndElseStatement;

{ finish off an else clause                                     }

var
   stPtr: statementPtr;                 {work pointer}

begin {EndElseStatement}
if c99Scope then PopTable;
stPtr := statementList;                 {create the label to branch to}
Gen1(dc_lab, stPtr^.elseLab);
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
if c99Scope then PopTable;
end; {EndElseStatement}


procedure EndForStatement;

{ finish off a for statement                                    }

var
   ltoken: tokenType;                   {for putting ; on stack}
   stPtr: statementPtr;                 {work pointer}
   tl,tk: tokenStackPtr;                {for forming expression list}
   lSuppressMacroExpansions: boolean;   {local copy of suppressMacroExpansions}

begin {EndForStatement}
if c99Scope then PopTable;
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
   lSuppressMacroExpansions := suppressMacroExpansions; {inhibit token echo}
   suppressMacroExpansions := true;
   NextToken;                           {evaluate the expression}
   Expression(normalExpression, [semicolonch]);
   Gen0t(pc_pop, UsualUnaryConversions);
   NextToken;                           {skip the semicolon}
   suppressMacroExpansions := lSuppressMacroExpansions;
   end; {if}

Gen1(pc_ujp, stPtr^.forLoop);           {loop to the test}
Gen1(dc_lab, stPtr^.breakLab);          {create the exit label}
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
if c99Scope then PopTable;
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
   isLongLong: boolean;                 {is the case expression long long?}
   swPtr,swPtr2: switchPtr;             {switch label table list}

begin {EndSwitchStatement}
if c99Scope then PopTable;
stPtr := statementList;                 {get the statement record}
exitLab := stPtr^.switchExit;           {get the exit label}
isLong := stPtr^.size = cgLongSize;     {get the long flag}
isLongLong := stPtr^.size = cgQuadSize; {get the long long flag}
swPtr := stPtr^.switchList;             {Skip further generation if there were}
if swPtr <> nil then begin              { no labels.                          }
   default := stPtr^.switchDefault;     {get a default label}
   if default = 0 then
      default := exitLab;
   Gen1(pc_ujp, exitLab);               {branch past the indexed jump}
   Gen1(dc_lab, stPtr^.switchLab);      {create the label for the xjp table}
   if isLongLong then                   {decide on a base type}
      ltp := cgQuad
   else if isLong then
      ltp := cgLong
   else
      ltp := cgWord;
   if isLong or isLongLong
      or (((stPtr^.maxVal-swPtr^.val.lo) div stPtr^.labelCount) > sparse) then
      begin

      {Long expressions and sparse switch statements are handled as a   }
      {series of if-goto tests.                                         }
      while swPtr <> nil do begin       {generate the compares}
         if isLongLong then
            GenLdcQuad(swPtr^.val)
         else if isLong then
            GenLdcLong(swPtr^.val.lo)
         else
            Gen1t(pc_ldc, long(swPtr^.val.lo).lsw, cgWord);
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
      minVal := long(swPtr^.val.lo).lsw; {record the min label value}
      Gen2t(pc_lod, stPtr^.ln, 0, ltp); {get the value}
      Gen1t(pc_dec, minVal, cgWord);    {adjust the range}
      Gen1(pc_xjp, ord(stPtr^.maxVal-minVal+1)); {do the indexed jump}
      while swPtr <> nil do begin       {generate the jump table}
         while minVal < swPtr^.val.lo do begin
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
if c99Scope then PopTable;
end; {EndSwitchStatement}


procedure EndWhileStatement;

{ finish off a while statement                                  }

var
   stPtr: statementPtr;                 {work pointer}

begin {EndWhileStatement}
if c99Scope then PopTable;
stPtr := statementList;                 {loop to the test}
Gen1(pc_ujp, stPtr^.whileTop);
Gen1(dc_lab, stPtr^.whileEnd);          {create the exit label}
statementList := stPtr^.next;           {pop the statement record}
dispose(stPtr);
if c99Scope then PopTable;
end; {EndWhileStatement}

{-- Type declarations ------------------------------------------}

procedure Declarator(declSpecifiers: declSpecifiersRecord;
   var variable: identPtr; space: spaceType; doingPrototypes: boolean);

{ handle a declarator                                           }
{                                                               }
{ parameters:                                                   }
{       declSpecifiers - type/specifiers to use                 }
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
      qualifiers: typeQualifierSet;
      end;

var
   i: integer;                          {loop variable}
   lastWasIdentifier: boolean;          {for deciding if the declarator is a function}
   lastWasPointer: boolean;             {was the last type a pointer?}
   madeFunctionTable: boolean;          {made symbol table for function type?}
   newName: stringPtr;                  {new symbol name}
   parameterStorage: boolean;           {is the new symbol in a parm list?}
   state: stateKind;                    {declaration state of the variable}
   tPtr: typePtr;                       {type of declaration}
   tPtr2: typePtr;                      {work pointer}
   tsPtr: typeDefPtr;                   {work pointer}
   typeStack: typeDefPtr;               {stack of type definitions}
   lTable: symbolTablePtr;              {saved copy of table}

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


   procedure StackDeclarations;
 
   { stack the declaration operators                            }
 
   var
      cp,cpList: pointerListPtr;        {pointer list}
      done,done2: boolean;              {for loop termination}
      isPtr: boolean;                   {is the parenthesized expr a ptr?}
      isVoid: boolean;                  {is the type specifier void?}
      wp: parameterPtr;                 {used to build prototype var list}
      pvar: identPtr;                   {work pointer}
      tPtr2: typePtr;                   {work pointer}
      ttPtr: typeDefPtr;                {work pointer}
      parencount: integer;              {for skipping in parm list}
      gotStatic: boolean;               {got 'static' in array declarator?}
 
                                        {variables used to preserve states}
                                        { across recursive calls          }
                                        {---------------------------------}
      lisFunction: boolean;             {local copy of isFunction}
      lLastParameter: identPtr;         {next parameter to process}
      lSuppressMacroExpansions: boolean;{local copy of suppressMacroExpansions}
      ldeclaredTagOrEnumConst: boolean; {local copy of declaredTagOrEnumConst}

   begin {StackDeclarations}
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
            if declSpecifiers.storageClass = typedefsy then begin
               tPtr2 := pointer(Calloc(sizeof(typeRecord)));
               {tPtr2^.size := 0;}
               {tPtr2^.saveDisp := 0;}
               tPtr2^.kind := definedType;
               {tPtr2^.qualifiers := [];}
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
            cp^.qualifiers := [];
            while token.kind in [_Alignassy..whilesy] do begin
               if token.kind = constsy then
                  cpList^.qualifiers := cpList^.qualifiers + [tqConst]
               else if token.kind = volatilesy then begin
                  cpList^.qualifiers := cpList^.qualifiers + [tqVolatile];
                  volatile := true
                  end {else if}
               else if token.kind = restrictsy then  {always allowed for now}
                  cpList^.qualifiers := cpList^.qualifiers + [tqRestrict]
               else
                  Error(9);
               NextToken;
               end; {while}
            end; {while}
         StackDeclarations;
         end;

      lparench: begin                   {handle '(' 'declarator' ')'}
         NextToken;
         isPtr := token.kind = asteriskch;
         StackDeclarations;
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
	 PushTable;			{create a symbol table}
                                        {determine if it's a function}
         isFunction := lastWasIdentifier or isFunction;
         tPtr2 := pointer(GCalloc(sizeof(typeRecord))); {create the function type}
         {tPtr2^.size := 0;}
         {tPtr2^.saveDisp := 0;}
         tPtr2^.kind := functionType;
         {tPtr2^.qualifiers := [];}
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
         isVoid := token.kind = voidsy;
         if token.kind = typedef then
            if token.symbolPtr^.itype^.kind = scalarType then
               if token.symbolPtr^.itype^.baseType = cgVoid then
                  isVoid := true;
         if isVoid then begin              {check for a void prototype}
            lSuppressMacroExpansions := suppressMacroExpansions;
            suppressMacroExpansions := true;
            NextToken;
            suppressMacroExpansions := lSuppressMacroExpansions;
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
                                        {see if we are doing a prototyped list}
         if token.kind in declarationSpecifiersElement then begin
            {handle a prototype variable list}
            numberOfParameters := 0;    {don't allow K&R parm declarations}
            done2 := false;
            lisFunction := isFunction;  {preserve global variables}
            with tPtr2^ do begin
               prototyped := true;      {it is prototyped}
               repeat                   {collect the declarations}
                  if token.kind in declarationSpecifiersElement then begin
                     ldeclaredTagOrEnumConst := declaredTagOrEnumConst;
                     lLastParameter := lastParameter;
                     DoDeclaration(true);
                     lastParameter := lLastParameter;
                     declaredTagOrEnumConst :=
                        ldeclaredTagOrEnumConst or declaredTagOrEnumConst;
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
                        if token.kind = dotdotdotsy then begin
                           NextToken;
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
                        declared, false);
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
         if madeFunctionTable or not lastWasIdentifier then
            PopTable
         else
            madeFunctionTable := true;
         end {if}

      {handle array declarations}
      else {if token.kind = lbrackch then} begin
         lastWasIdentifier := false;
         tPtr2 := pointer(Calloc(sizeof(typeRecord)));
         {tPtr2^.size := 0;}
         {tPtr2^.saveDisp := 0;}
         {tPtr2^.qualifiers := [];}
         tPtr2^.kind := arrayType;
         {tPtr2^.elements := 0;}
         NextToken;
         gotStatic := false;
         if doingParameters and (typeStack = nil) then begin
            tPtr2^.kind := pointerType; {adjust to pointer type}
            tPtr2^.size := cgPointerSize;
            if token.kind = staticsy then begin
               gotStatic := true;
               NextToken;
               end; {if}
            while token.kind in [constsy,volatilesy,restrictsy] do begin
               if token.kind = constsy then
                  tPtr2^.qualifiers := tPtr2^.qualifiers + [tqConst]
               else if token.kind = volatilesy then begin
                  tPtr2^.qualifiers := tPtr2^.qualifiers + [tqVolatile];
                  volatile := true;
                  end {else}
               else {if token.kind = restrictsy then}
                  tPtr2^.qualifiers := tPtr2^.qualifiers + [tqRestrict];
               NextToken;
               end; {while}
            if not gotStatic then
               if token.kind = staticsy then begin
                  gotStatic := true;
                  NextToken;
                  end; {if}
            end; {if}
         new(ttPtr);
         ttPtr^.next := typeStack;
         typeStack := ttPtr;
         ttPtr^.typeDef := tPtr2;
         if token.kind <> rbrackch then begin
            Expression(arrayExpression, [rbrackch,semicolonch]);
            if expressionValue <= 0 then begin
               Error(45);
               expressionValue := 1;
               end; {if}
            tPtr2^.elements := expressionValue;
            end {if}
         else if gotStatic then
            Error(35);
         Match(rbrackch,24);
         end; {else if}
      end; {while}

   {stack pointer type records}
   while cpList <> nil do begin
      tPtr2 := pointer(Malloc(sizeof(typeRecord)));
      tPtr2^.size := cgPointerSize;
      tPtr2^.saveDisp := 0;
      tPtr2^.qualifiers := cpList^.qualifiers;
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
tPtr := declSpecifiers.typeSpec;
newName := nil;                         {no identifier, yet}
unnamedParm := false;                   {not an unnamed parameter}
if declSpecifiers.storageClass = externsy then  {decide on a storage state}
   state := declared
else
   state := defined;
madeFunctionTable := false;             {no symbol table for function}
typeStack := nil;                       {no types so far}
parameterStorage := false;              {symbol is not in a parameter list}
checkParms := false;                    {assume we won't need to check for parameter type errors}
StackDeclarations;                      {stack the type records}
while typeStack <> nil do begin         {reverse the type stack}
   tsPtr := typeStack;
   typeStack := tsPtr^.next;
   tPtr2 := tsPtr^.typeDef;
   dispose(tsPtr);
   case tPtr2^.kind of
      pointerType: begin
         tPtr2^.pType := tPtr;                     
         end;
      functionType: begin
         while tPtr^.kind = definedType do
            tPtr := tPtr^.dType;
         tPtr2^.fType := Unqualify(tPtr);
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

if doingParameters then                 {adjust array parameters to pointers}
   if tPtr^.kind = arrayType then
      tPtr := MakePointerTo(tPtr^.aType);

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
   if not doingPrototypes then
      if pfunc^.itype^.prototyped then
         if tPtr^.kind in
            [enumConst,structType,unionType,definedType,pointerType]
            then Error(50);

if tPtr^.kind = functionType then begin {declare the identifier}
   if variable <> nil then begin
      if pascalsy in declSpecifiers.declarationModifiers then begin
         {reverse the parameter list}
         p2 := tptr^.parameterList;
         p1 := nil;
         while p2 <> nil do begin
            p3 := p2;
            p2 := p2^.next;
            p3^.next := p1;
            p1 := p3;
            end; {while}
         tPtr^.parameterList := p1;
         end; {if}
      t1 := variable^.itype;
      if (t1^.kind = functionType) and CompTypes(t1, tPtr) then begin
         if t1^.prototyped and tPtr^.prototyped then begin
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
               compatible := false;
               if CompTypes(pt1, pt2) then 
                  compatible := true
               else begin
                  tk1 := pt1^.kind;
                  tk2 := pt2^.kind;
                  if (tk1 = arrayType) and (tk2 = pointerType) then
                     compatible := CompTypes(pt1^.aType, pt2^.pType)
                  else if (tk1 = pointerType) and (tk2 = arrayType) then
                     compatible := CompTypes(pt1^.pType, pt2^.aType)
                  end; {else}
               if not compatible then begin
                  Error(47);
                  goto 1;
                  end; {if}
               p1 := p1^.next;
               p2 := p2^.next;
               end; {while}
            if p1 <> p2 then
               Error(47);
            end; {if}
         end {if}
      else
         if (t1^.kind = functionType) and CompTypes(t1^.fType,tPtr^.fType) then
            Error(47)
         else
            Error(42);
1:
      if pascalsy in declSpecifiers.declarationModifiers then begin
         {reverse the parameter list}
         p2 := tptr^.parameterList;
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
   end; {if}
if tPtr^.kind = functionType then
   state := declared;
if madeFunctionTable then begin
   lTable := table;
   table := table^.next;
   end; {if}
if newName <> nil then                  {declare the variable}
   variable := NewSymbol(newName, tPtr, declSpecifiers.storageClass,
      space, state, inlinesy in declSpecifiers.declarationModifiers)
else if unnamedParm then
   variable^.itype := tPtr
else begin
   if token.kind <> semicolonch then
      Error(9);
   variable := nil;
   end; {else}
if madeFunctionTable then
   table := lTable;
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
      if ((tPtr <> declSpecifiers.typeSpec)
         and (not (tPtr^.kind in [structType,unionType])))
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
   disp: longint;                       {disp within overall object being initialized}
   done: boolean;                       {for loop termination}
   errorFound: boolean;                 {used to remove bad initializations}
   iPtr,jPtr,kPtr: initializerPtr;      {for reversing the list}
   ip: identList;                       {used to place an id in the list}
   luseGlobalPool: boolean;             {local copy of useGlobalPool}
   skipComma: boolean;                  {skip an expected comma}


   procedure InsertInitializerRecord (iPtr: initializerPtr; size: longint);

   { Insert an initializer record in the initializer list       }
   {                                                            }
   { parameters:                                                }
   {    iPtr - the record to insert                             }
   {    size - number of bytes initialized by this record       }
   
   begin {InsertInitializerRecord}
   iPtr^.disp := disp;
   iPtr^.next := variable^.iPtr;
   variable^.iPtr := iPtr;
{  writeln('Inserted initializer record with size ', size:1, ' at disp ', disp:1); {debug}
   disp := disp + size;
   end; {InsertInitializerRecord}


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
      iPtr^.isConstant := isConstant;
      iPtr^.count := 1;
      iPtr^.bitdisp := 0;
      iPtr^.bitsize := 0;
      iPtr^.iVal := bitvalue;
      if bitcount <= 8 then
         iPtr^.basetype := cgUByte
      else if bitcount <= 24 then
         iPtr^.basetype := cgUWord
      else
         iPtr^.basetype := cgULong;
      InsertInitializerRecord(iPtr, TypeSize(iPtr^.basetype));
      if bitcount in [17..24] then begin {3-byte bitfield: split into two parts}
         iPtr^.iVal := bitvalue & $0000FFFF;
         bitcount := bitcount - 16;
         bitvalue := bitvalue >> 16;
         InitializeBitField;
         end;
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
            if rtree^.token.kind in
               [intconst,uintconst,ushortconst,charconst,scharconst,ucharconst] then
               size := rtree^.token.ival
            else if rtree^.token.kind in [longconst,ulongconst] then
               size := rtree^.token.lval
            else if rtree^.token.kind in [longlongconst,ulonglongconst] then begin
               size := rtree^.token.qval.lo;
               with rtree^.token.qval do
                  if not (((hi = 0) and (lo & $ff000000 = 0)) or
                     ((hi = -1) and (lo & $ff000000 = $ff000000))) then
                     Error(6);
               end {else if}
            else begin
               Error(18);
               errorFound := true;
               end; {else}
            tp := Subscript(tree^.left);
            end {if}
         else begin
            size := 0;
            tp := Subscript(tree);
            end; {else}
         if tp^.kind = arrayType then begin
            tp := tp^.atype;
            offset := offset + size*tp^.size;
            Subscript := tp;
            end {if}
         else if tp^.kind = functionType then begin
            Subscript := tp;
            end {else if}
         else begin
            Error(47);
            errorFound := true;
            Subscript := intPtr;
            end; {else}
         end {if}
      else if tree^.token.kind = dotch then begin
         tp := Subscript(tree^.left);
         while tp^.kind = definedType do
            tp := tp^.dType;
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
            Subscript := intPtr;
            end; {else}
         end {else if}
      else if tree^.token.kind = ident then begin
         ip := FindSymbol(tree^.token, allSpaces, false, true);
         if ip = nil then begin
            Error(31);
            errorFound := true;
            Subscript := intPtr;
            iPtr^.pName := @'?';
            end {if}
         else begin
            Subscript := ip^.itype;
            iPtr^.pName := ip^.name;
            end; {else}
         end {else if}
      else if tree^.token.kind = stringConst then begin
         Subscript := StringType(tree^.token.prefix);
         iPtr^.isName := false;
         iPtr^.pStr := tree^.token.sval;
         end {else if}
      else begin
         Error(47);
         errorFound := true;
         Subscript := intPtr;
         end; {else}
      end; {Subscript}


   begin {GetInitializerValue}
   if variable^.storage = stackFrame then
      Expression(autoInitializerExpression, [commach,rparench,rbracech])
   else
      Expression(initializerExpression, [commach,rparench,rbracech]);
   if bitsize = 0 then begin
      iPtr := pointer(Malloc(sizeof(initializerRecord)));
      InsertInitializerRecord(iPtr, tp^.size);
      iPtr^.isConstant := isConstant;
      iPtr^.count := 1;
      iPtr^.bitdisp := 0;
      iPtr^.bitsize := 0;
      end; {if}
   etype := expressionType;
   AssignmentConversion(tp, expressionType, isConstant, expressionValue,
      false, false);
   if variable^.storage = external then
      variable^.storage := global;
   if isConstant and (variable^.storage in [external,global,private]) then begin
      if bitsize = 0 then begin
         if etype^.baseType in [cgQuad,cgUQuad] then begin
            iPtr^.qVal := llExpressionValue;
            end {if}
         else begin
            iPtr^.qval.hi := 0;
            iPtr^.iVal := expressionValue;
            end; {else}
         iPtr^.basetype := tp^.baseType;
         InitializeBitField;
         end; {if}
      case tp^.kind of

         scalarType: begin
            bKind := tp^.baseType;
            if (etype^.baseType in [cgByte..cgULong,cgQuad,cgUQuad])
               and (bKind in [cgByte..cgULong,cgQuad,cgUQuad]) then begin
               if bKind in [cgLong,cgULong,cgQuad,cgUQuad] then
                  if eType^.baseType = cgUByte then
                     iPtr^.iVal := iPtr^.iVal & $000000FF
                  else if eType^.baseType = cgUWord then
                     iPtr^.iVal := iPtr^.iVal & $0000FFFF;
               if bKind in [cgQuad,cgUQuad] then
                  if etype^.baseType in [cgByte..cgULong] then
                     if (etype^.baseType in [cgByte,cgWord,cgLong])
                        and (iPtr^.iVal < 0) then
                        iPtr^.qVal.hi := -1
                     else
                        iPtr^.qVal.hi := 0;
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
            if (etype = stringTypePtr) or (etype = utf16StringTypePtr)
               or (etype = utf32StringTypePtr) then begin
               iPtr^.isConstant := true;
               iPtr^.basetype := ccPointer;
               iPtr^.pval := 0;
               iPtr^.pPlus := false;
               iPtr^.isName := false;
               iPtr^.pStr := longstringPtr(expressionValue);
               end {if}
            else if etype^.kind = scalarType then
               if etype^.baseType in [cgByte..cgULong] then
                  if expressionValue = 0 then
                     iPtr^.basetype := cgULong
                  else begin
                     Error(47);
                     errorFound := true;
                     end {else}
               else if etype^.baseType in [cgQuad,cgUQuad] then
                  if (llExpressionValue.hi = 0) and
                     (llExpressionValue.lo = 0) then
                     iPtr^.basetype := cgULong
                  else begin
                     Error(47);
                     errorFound := true;
                     end {else}
               else begin
                  Error(48);
                  errorFound := true;
                  end {else}
            else if etype^.kind = pointerType then begin
               iPtr^.basetype := cgULong;
               iPtr^.pval := expressionValue;
               end {else if}
            else begin
               Error(48);
               errorFound := true;
               end; {else}

         structType,unionType,enumType: begin
            Error(46);
            errorFound := true;
            end;

         otherwise:
            Error(57);

         end; {case}
2:    DisposeTree(initializerTree);
      end {if}
   else begin
      if ((tp^.kind = pointerType)
         or ((tp^.kind = scalarType) and (tp^.baseType in [cgLong,cgULong])))
         and (bitsize = 0)
         then begin
         iPtr^.basetype := ccPointer;
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
                  if kind in [intConst,uintconst,ushortconst,longConst,
                     ulongconst,longlongConst,ulonglongconst,charconst,
                     scharconst,ucharconst] then begin
                     if kind in [intConst,charconst,scharconst,ucharconst] then
                        offSet2 := ival
                     else if kind in [uintConst,ushortconst] then
                        offset2 := ival & $0000ffff
                     else if kind in [longConst,ulongconst] then begin
                        offset2 := lval;
                        if (lval & $ff000000 <> 0)
                           and (lval & $ff000000 <> $ff000000) then
                           Error(6);
                        end {else if}
                     else {if kind = longlongConst then} begin
                        offset2 := qval.lo;
                        with qval do
                           if not (((hi = 0) and (lo & $ff000000 = 0)) or
                              ((hi = -1) and (lo & $ff000000 = $ff000000))) then
                              Error(6);
                        end; {else}
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
               iPtr^.pPlus := true;
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
               iPtr^.pPlus := true;
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
         end; {if}

      {handle auto variables}
      if bitsize <> 0 then begin
         iPtr := pointer(Malloc(sizeof(initializerRecord)));
         InsertInitializerRecord(iPtr, 0); {TODO should size be 0?}
         iPtr^.isConstant := isConstant;
         iPtr^.count := 1;
         iPtr^.bitdisp := bitdisp;
         iPtr^.bitsize := bitsize;
         end; {if}
      if variable^.storage in [external,global,private] then begin
         Error(41);
         errorFound := true;
         end; {else}
      iPtr^.isConstant := false;
      iPtr^.iTree := initializerTree;
      iPtr^.iType := tp;
      iPtr^.bitdisp := bitdisp;
      iPtr^.bitsize := bitsize;
      end; {else}
1:
   end; {GetInitializerValue}


   procedure InitializeTerm (tp: typePtr; bitsize,bitdisp: integer;
      main, nestedDesignator, noFill: boolean);
 
   { initialize one level of the type                           }
   {                                                            }
   { parameters:                                                }
   {     tp - pointer to the type being initialized             }
   {     bitsize - size of bit field (0 for non-bit fields)     }
   {     bitdisp - disp of bit field; unused if bitsize = 0     }
   {     main - is this a call from the main level?             }
   {     nestedDesignator - handling second or later level of   }
   {         designator in a designator list?                   }
   {     noFill - if set, do not fill empty space with zeros    }

   label 1,2;
 
   var
      bitCount: integer;                {# of bits in a union}
      braces: boolean;                  {is the initializer inclosed in braces?}
      count,maxCount: longint;          {for tracking the size of an initializer}
      ep: tokenPtr;                     {for forming string expression}
      fillSize: longint;                {size to fill with zeros}
      hasNestedDesignator: boolean;     {nested designator in current designation?}
      iPtr: initializerPtr;             {for creating an initializer entry}
      ip: identPtr;                     {for tracing field lists}
      kind: typeKind;                   {base type of an initializer}
      ktp: typePtr;			{array type with definedTypes removed}
      lSuppressMacroExpansions: boolean;{local copy of suppressMacroExpansions}
      maxDisp: longint;                 {maximum disp value so far}
      newDisp: longint;                 {new disp set by a designator}
      setNoFill: boolean;               {set noFill on recursive calls?}
      startingDisp: longint;            {disp at start of this term}
      stringElementType: typePtr;       {element type of string literal}
      stringLength: integer;            {elements in a string literal}


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
         if variable^.storage in [external,global,private] then
            Fill(count * tp^.size, sCharPtr)
         else begin
            i := count;
            while i <> 0 do begin
               ip := tp^.fieldList;
               while ip <> nil do begin
                  if not ip^.anonMemberField then
                     Fill(1, ip^.iType);
                  ip := ip^.next;
                  end; {while}
               i := i-1;
               end; {while}
            end; {else}
         end {else if}
      else if tp^.kind = unionType then begin

         {fill a union}
         if variable^.storage in [external,global,private] then
            Fill(count * tp^.size, sCharPtr)
         else
            Fill(count, tp^.fieldList^.iType);
         end {else if}
      else

         {fill a single value}
         while count <> 0 do begin
            iPtr := pointer(Calloc(sizeof(initializerRecord)));
            iPtr^.isConstant := variable^.storage in [external,global,private];
           {iPtr^.bitdisp := 0;}
           {iPtr^.bitsize := 0;}
            if iPtr^.isConstant then begin
               if tp^.kind = scalarType then
                  iPtr^.basetype := tp^.baseType
               else if tp^.kind = pointertype then begin
                  iPtr^.basetype := cgULong;
                 {iPtr^.iVal := 0;}
                  end {else if}
               else begin
                  iPtr^.basetype := cgWord;
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
               iPtr^.iType := tp;
               end; {else}
            if count < 16384 then begin
               iPtr^.count := long(count).lsw;
               count := 0;
               end {if}
            else begin
               iPtr^.count := 16384;
               count := count-16384;
               end; {else}
            InsertInitializerRecord(iPtr, tp^.size * iPtr^.count);
            end; {while}
      end; {Fill}
 
 
      procedure RecomputeSizes (tp: typePtr);
  
      { a size has been inferred from an initializer - set the    }
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
      noFill := false;
      end; {if}

   {handle arrays}
   while tp^.kind = definedType do
      tp := tp^.dType;
   kind := tp^.kind;
                                        {check for designators that need to}
                                        {be handled at an outer level      }
   if token.kind in [dotch,lbrackch] then
      if not (braces or nestedDesignator) then begin
         {TODO fill?}
         skipComma := true;
         goto 1;
         end; {if}
   startingDisp := disp;
   setNoFill := noFill;
   if kind = arrayType then begin
      ktp := tp^.atype;
      while ktp^.kind = definedType do
	 ktp := ktp^.dType;
      kind := ktp^.kind;

      {handle string constants}
      if token.kind = stringConst then
         stringElementType := StringType(token.prefix)^.aType;
      if (token.kind = stringConst) and (kind = scalarType) and 
         (((ktp^.baseType in [cgByte,cgUByte])
            and (stringElementType = charPtr))
         or CompTypes(ktp,stringElementType)) then begin
         stringLength := token.sval^.length div ord(stringElementType^.size);
         if tp^.elements = 0 then begin
            tp^.elements := stringLength;
            RecomputeSizes(variable^.itype);
            end {if}
         else if tp^.elements < stringLength-1 then begin
            Error(44);
            errorFound := true;
            end; {else if}
         with ktp^ do begin
            iPtr := pointer(Malloc(sizeof(initializerRecord)));
            iPtr^.count := 1;
            iPtr^.bitdisp := 0;
            iPtr^.bitsize := 0;
            if (variable^.storage in [external,global,private]) then begin
               InsertInitializerRecord(iPtr, token.sval^.length);
               iPtr^.isConstant := true;
               iPtr^.basetype := cgString;
               iPtr^.sval := token.sval;
               count := tp^.elements - stringLength;
               if count > 0 then
                  Fill(count, stringElementType)
               else if count = -1 then begin
                  iPtr^.sval := pointer(GMalloc(token.sval^.length+2));
                  CopyLongString(iPtr^.sval, token.sval);
                  iPtr^.sval^.length :=
                     iPtr^.sval^.length - ord(stringElementType^.size);
                  end; {else if}
               end {if}
            else begin
               InsertInitializerRecord(iPtr,
                  tp^.elements * stringElementType^.size);
               iPtr^.isConstant := false;
               new(ep);
               iPtr^.iTree := ep;
               iPtr^.iType := tp;
               ep^.next := nil;
               ep^.left := nil;
               ep^.middle := nil;
               ep^.right := nil;
               ep^.token := token;
               end; {else}
            end; {with}
         NextToken;
         end {if}

      {handle arrays not initialized with a string constant}
      else if kind in
         [scalarType,pointerType,enumType,arrayType,structType,unionType] then
         begin
         count := 0;                    {get the expressions|initializers}
         maxCount := tp^.elements;
         maxDisp := disp;
         if token.kind <> rbracech then
            repeat
               hasNestedDesignator := false;
               if token.kind = lbrackch then begin
                  if not (braces or (nestedDesignator and (disp=startingDisp)))
                     then begin
                     skipComma := true;
                     goto 1;
                     end; {if}
                  NextToken;
                  Expression(arrayExpression, [rbrackch]);
                  if (expressionValue < 0)
                     or ((maxCount <> 0) and (expressionValue >= maxCount)) then
                     begin
                     Error(183);
                     count := 0;
                     end {if}
                  else begin
                     count := expressionValue;
                     end; {else}
                  Match(rbrackch, 24);
                  newDisp := startingDisp + count * ktp^.size;
                  if not noFill then begin
                     fillSize := newDisp - maxDisp;
                     if token.kind in [lbrackch,dotch] then
                        fillSize := fillSize + ktp^.size;
                     if fillSize > 0 then begin
                        disp := maxDisp;
                        Fill(fillSize, charPtr);
                        maxDisp := disp;
                        end; {if}
                     end; {if}
                  setNoFill := true;
                  disp := newDisp;
                  if token.kind in [dotch,lbrackch] then
                     hasNestedDesignator := true
                  else
                     Match(eqch, 182);
                  end; {if}
               InitializeTerm(ktp, 0, 0, false, hasNestedDesignator, 
                  setNoFill or hasNestedDesignator);
               if disp > maxDisp then
                  maxDisp := disp;
               count := count+1;
               if (count = maxCount) and not braces then
                  done := true
               else if (token.kind = commach) or skipComma then begin
                  if skipComma then
                     skipComma := false
                  else
                     NextToken;
                  done := token.kind = rbracech;
                  if not done then
                     if count = maxCount then
                        if not (token.kind = lbrackch) then begin
                           Error(183);
                           count := 0;
                           end; {if}
                  end {else if}
               else
                  done := true;
            until done or (token.kind = eofsy);
         if maxCount = 0 then begin     {set the array size}
            maxCount := (maxDisp - startingDisp + ktp^.size - 1) div ktp^.size;
            tp^.elements := maxCount;   
            RecomputeSizes(variable^.itype);
            end; {if}
         if not noFill then begin
            disp := startingDisp + maxCount * ktp^.size;
            if disp > maxDisp then begin {if there weren't enough initializers...}
               fillSize := disp - maxDisp;
               disp := maxDisp;
               Fill(fillSize, charPtr); { fill in the blank spots}
               end; {if}
            end; {if}
         end {else if}

      else begin
         Error(47);
         errorFound := true;
         end; {else}
      end {if}

   {handle structures and unions}
   else if kind in [structType, unionType] then begin
      if braces or (not main) then begin
         count := tp^.size;
         ip := tp^.fieldList;
         bitCount := 0;
         maxDisp := disp;
         lSuppressMacroExpansions := suppressMacroExpansions;
         while true do begin
            if (ip <> nil) and ip^.isForwardDeclared then
               ResolveForwardReference(ip);
            if token.kind = rbracech then       {fill remainder with zeros}
               goto 2;
            hasNestedDesignator := false;
            if token.kind  = dotch then begin
               if not (braces or (nestedDesignator and (disp=startingDisp)))
                  then begin
                  skipComma := true;
                  goto 1;
                  end; {if}
               NextToken;
               if token.kind = ident then begin
                  ip := tp^.fieldList;
                  done := false;
                  while (ip <> nil) and not done do
                     if ip^.name^ = token.name^ then
                        done := true
                     else
                        ip := ip^.next;
                  if ip = nil then
                     Error(81);
                  NextToken;
                  {TODO if ip is an anonymous member field ...}
                  {TODO fill}
                  if token.kind in [dotch,lbrackch] then begin
                     hasNestedDesignator := true;
                     end {if}
                  else
                     Match(eqch, 182);
                  end {if}
               else begin
                  Error(9);
                  ip := nil;
                  end; {else}
               end; {if}
            if (ip = nil) or (ip^.itype^.size = 0) then
               goto 2;
            if ip^.bitSize = 0 then
               if bitCount > 0 then begin
                  InitializeBitField;
                  bitCount := (bitCount+7) div 8;
                  count := count-bitCount;
                  bitCount := 0;
                  disp := startingDisp + tp^.size - count;
                  end; {if}
            disp := startingDisp + ip^.disp;
            InitializeTerm(ip^.itype, ip^.bitsize, ip^.bitdisp, false,
               hasNestedDesignator, setNoFill or hasNestedDesignator);
            if ip^.bitSize <> 0 then begin
               bitCount := bitCount + ip^.bitSize;
               if bitCount > maxBitField then begin
                  count := count - (maxBitField div 8);
                  bitCount := ip^.bitSize;
                  end; {if}
               end {if}
            else begin
               count := count-ip^.itype^.size;
               end; {else}
            if disp > maxDisp then
               maxDisp := disp;
{           writeln('Initializer: ', ip^.bitsize:10, ip^.bitdisp:10, bitCount:10); {debug}
            if kind = unionType then
               ip := nil
            else begin
               ip := ip^.next;
               while (ip <> nil) and ip^.anonMemberField do
                  ip := ip^.next;
               end; {else}
            if ((ip = nil) or (ip^.itype^.size = 0)) and not braces then
               goto 2;
            {TODO need other code to disallow dual commas before right brace?}
            if token.kind = commach then
               NextToken
            else if token.kind <> rbracech then
               ip := nil;
            end; {while}
2:       if bitCount > 0 then begin
            InitializeBitField;
            bitCount := (bitCount+7) div 8;
            count := count-bitCount;
            bitCount := 0;
            disp := startingDisp + tp^.size - count;
            end; {if}
         {TODO fill as appropriate in auto case too}
         if count > 0 then
            if variable^.storage in [external,global,private] then
               Fill(count, sCharPtr);
         suppressMacroExpansions := lSuppressMacroExpansions;
         end {if}
      else                              {struct/union assignment initializer}
         GetInitializerValue(tp, bitsize, bitdisp);
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
1:
   end; {InitializeTerm}

begin {Initializer}
bitcount := 0;                          {set up for bit fields}
bitvalue := 0;
disp := 0;                              {start at beginning of the object}
errorFound := false;                    {no errors found so far}
skipComma := false;
luseGlobalPool := useGlobalPool;        {use global memory for global vars}
useGlobalPool := (variable^.storage in [external,global,private])
   or useGlobalPool;
                                        {make sure a required '{' is there}
if not (token.kind in [lbracech,stringConst]) then
   if variable^.itype^.kind = arrayType then begin
      Error(27);
      errorFound := true;
      end; {if}
InitializeTerm(variable^.itype, 0, 0, true, false, false); {do the initialization}
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
useGlobalPool := luseGlobalPool;        {restore useGlobalPool}
end; {Initializer}


procedure DoStaticAssert;

{ process a static assertion                                    }

begin {DoStaticAssert}
NextToken;
Match(lparench, 13);
Expression(arrayExpression, [commach]);
if (expressionType = nil) or (expressionType^.kind <> scalarType) then
   Error(18)
else if expressionValue = 0 then
   Error(132);
Match(commach, 86);
Match(stringconst, 83);
Match(rparench, 12);
Match(semicolonch, 22);
end; {DoStaticAssert}


procedure DeclarationSpecifiers (var declSpecifiers: declSpecifiersRecord;
   allowedTokens: tokenSet; badNextTokenError: integer);

{ handle declaration specifiers or a specifier-qualifier list   }
{                                                               }
{ parameters:                                                   }
{       declSpecifiers - record to hold result type & specifiers}
{       allowedTokens - specifiers/qualifiers that can be used  }
{       badNextTokenError - error code for an unexpected token  }
{               following the declaration specifiers            }
{                                                               }
{ outputs:                                                      }
{       isForwardDeclared - is the field list component         }
{               referencing a forward struct/union?             }
{       declaredTagOrEnumConst - set if a tag or an enum const  }
{               is declared (otherwise unchanged)               }

label 1,2,3;

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
   
   typeSpecifiers: tokenSet;            {set of tokens specifying the type}
   typeDone: boolean;                   {no more type specifiers can be accepted}
   
   typeQualifiers: typeQualifierSet;    {set of type qualifiers found}

   myIsForwardDeclared: boolean;        {value of isForwardDeclared to generate}
   myTypeSpec: typePtr;                 {value of typeSpec to generate}
   myDeclarationModifiers: tokenSet;    {all modifiers in this declaration}
   myStorageClass: tokenEnum;           {storage class}
   
   isLongLong: boolean;                 {is this a "long long" type?}
 
   procedure FieldList (tp: typePtr; kind: typeKind);
 
   { handle a field list                                         }
   {                                                             }
   { parameters                                                  }
   {     tp - place to store the type pointer                    }

   label 1;

   var
      bitDisp: integer;                 {current bit disp}
      disp: longint;                    {current byte disp}
      done: boolean;                    {for loop termination}
      fl,tfl,ufl: identPtr;             {field list}
      ldoingParameters: boolean;        {local copy of doingParameters}
      lisForwardDeclared: boolean;      {local copy of isForwardDeclared}
      maxDisp: longint;                 {for determining union sizes}
      variable: identPtr;               {variable being defined}
      didFlexibleArray: boolean;        {have we seen a flexible array member?}
      fieldDeclSpecifiers: declSpecifiersRecord; {decl specifiers for field}
      tPtr: typePtr;                    {for building types}
      anonMember: boolean;              {processing an anonymous struct/union?}
      
      procedure AddField(variable: identPtr; anonMember: identPtr);
 
      { add a field to the field list                            }
      {                                                          }
      { parameters                                               }
      {     variable - field to add                              }
      {     anonMember - anonymous struct/union that this field  }
      {         came from, if any (nil if not an anonymous       }
      {         member field)                                    }

      label 1;
      
      var
         tfl: identPtr;                 {for traversing field list}
      
      begin {AddField}
      if variable^.name^ <> '~anonymous' then begin
         tfl := fl;                     {(check for dups)}
         while tfl <> nil do begin
            if tfl^.name^ = variable^.name^ then begin
               Error(42);
               goto 1;
               end; {if}
            tfl := tfl^.next;
            end; {while}
         end; {if}
1:    variable^.next := fl;
      if anonMember <> nil then begin
         variable^.anonMemberField := true;
         variable^.anonMember := anonMember;
         end {if}
      else
         variable^.anonMemberField := false;
      fl := variable;
      end; {AddField}
 
   begin {FieldList}
   ldoingParameters := doingParameters; {allow fields in K&R dec. area}
   doingParameters := false;
   lisForwardDeclared := isForwardDeclared; {stack this value}
   bitDisp := 0;                        {start allocation from byte 0}
   disp := 0;
   maxDisp := 0;
   didFlexibleArray := false;
   fl := nil;                           {nothing in the field list, yet}
                                        {while there are entries in the field list...}
1: while token.kind in structDeclarationStart do begin
      if token.kind = _Static_assertsy then begin
         DoStaticAssert;
         goto 1;
         end; {if}
      DeclarationSpecifiers(fieldDeclSpecifiers, specifierQualifierListElement, 176);
      repeat                            {declare the variables...}
         if didFlexibleArray then
            Error(118);
         variable := nil;
         anonMember := false;
         if token.kind <> colonch then begin
            if (token.kind = semicolonch) then begin
               tPtr := fieldDeclSpecifiers.typeSpec;
               while tPtr^.kind = definedType do
                  tPtr := tPtr^.dType;
               if (tPtr^.kind in [structType,unionType])
                  and (tPtr^.sName = nil)
                  and ((structsy in fieldDeclSpecifiers.declarationModifiers)
                     or (unionsy in fieldDeclSpecifiers.declarationModifiers))
                  then begin
                  variable := NewSymbol(@'~anonymous', tPtr, ident,
                     fieldListSpace, defined, false);
                  anonMember := true;
                  TermHeader;           {cannot record anon member in .sym file}
                  end; {if}
               end {if}
            else
               Declarator(fieldDeclSpecifiers, variable, fieldListSpace, false);
            if variable <> nil then     {enter the var in the field list}
               AddField(variable, nil);
            end; {if}
         if kind = unionType then begin
            disp := 0;
            bitdisp := 0;
            end; {if}
         if token.kind = colonch then   {handle a bit field}
            begin
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
               tPtr := variable^.itype;
               end {if}
            else
               tPtr := fieldDeclSpecifiers.typeSpec;
            bitdisp := bitdisp+long(expressionValue).lsw;
            if kind = unionType then
               if ((bitDisp+7) div 8) > maxDisp then
                  maxDisp := ((bitDisp+7) div 8);
            if (tPtr^.kind <> scalarType)
               or not (tPtr^.baseType in
                  [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong])
               or (expressionValue > tPtr^.size*8)
               or ((expressionValue > 1) and (tPtr^.cType = ctBool)) then
               Error(115);
            if _Alignassy in fieldDeclSpecifiers.declarationModifiers then
               Error(142);
            end {if}
         else if variable <> nil then begin
            if bitdisp <> 0 then begin
               disp := disp+((bitDisp+7) div 8);
               bitdisp := 0;
               end; {if}
            variable^.disp := disp;
            variable^.bitdisp := bitdisp;
            variable^.bitsize := 0;
            if anonMember then begin    
               tfl := variable^.itype^.fieldList;
               while tfl <> nil do begin
                  ufl := pointer(Malloc(sizeof(identRecord)));
                  ufl^ := tfl^;
                  AddField(ufl, variable);
                  ufl^.disp := ufl^.disp + disp;
                  tfl := tfl^.next;
                  end; {while}
               end; {if}
            disp := disp + variable^.itype^.size;
            if disp > maxDisp then
               maxDisp := disp;
            if variable^.itype^.size = 0 then
               if (variable^.itype^.kind = arrayType) 
                  and (disp > 0) then begin {handle flexible array member}
                  didFlexibleArray := true;
                  tp^.flexibleArrayMember := true;
                  end {if}
               else
                  Error(117);
            end {if}
         else
            Error(116);

         if variable <> nil then        {check for a const member}
            tPtr := variable^.itype
         else
            tPtr := fieldDeclSpecifiers.typeSpec;
         while tPtr^.kind in [definedType,arrayType] do begin
            if tqConst in tPtr^.qualifiers then
               tp^.constMember := true;
            if tPtr^.kind = definedType then
               tPtr := tPtr^.dType
            else {if tPtr^.kind = arrayType then}
               tPtr := tPtr^.aType;
            end; {while}
         if tqConst in tPtr^.qualifiers then
            tp^.constMember := true;
         if tPtr^.kind in [structType,unionType] then begin
            if tPtr^.constMember then
               tp^.constMember := true;
            if tPtr^.flexibleArrayMember then
               if kind = structType then
                  Error(169)
               else {if kind = unionType then}
                  tp^.flexibleArrayMember := true;
            end; {if}

         if token.kind = commach then   {allow repeated declarations}
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
      end {if}
   else
      Error(26);                        {error if no named declarations}
   isForwardDeclared := lisForwardDeclared; {restore the forward flag}
   doingParameters := ldoingParameters; {restore the parameters flag}
   end; {FieldList}


   procedure ResolveType;

   { Resolve a set of type specifier keywords to a type         }

   begin {ResolveType}
   {See C17 6.7.2}
   if typeSpecifiers = [voidsy] then
      myTypeSpec := voidPtr
   else if typeSpecifiers = [charsy] then
      myTypeSpec := charPtr
   else if typeSpecifiers = [signedsy,charsy] then
      myTypeSpec := sCharPtr
   else if typeSpecifiers = [unsignedsy,charsy] then
      myTypeSpec := uCharPtr
   else if (typeSpecifiers = [shortsy])
      or (typeSpecifiers = [signedsy,shortsy])
      or (typeSpecifiers = [shortsy,intsy])
      or (typeSpecifiers = [signedsy,shortsy,intsy]) then
      myTypeSpec := shortPtr
   else if (typeSpecifiers = [unsignedsy,shortsy])
      or (typeSpecifiers = [unsignedsy,shortsy,intsy]) then
      myTypeSpec := uShortPtr
   else if (typeSpecifiers = [intsy])
      or (typeSpecifiers = [signedsy])
      or (typeSpecifiers = [signedsy,intsy]) then begin
      if unix_1 then
         myTypeSpec := int32Ptr
      else
         myTypeSpec := intPtr;
      end {else if}
   else if (typeSpecifiers = [unsignedsy])
      or (typeSpecifiers = [unsignedsy,intsy]) then begin
      if unix_1 then
         myTypeSpec := uInt32Ptr
      else
         myTypeSpec := uIntPtr;
      end {else if}
   else if (typeSpecifiers = [longsy])
      or (typeSpecifiers = [signedsy,longsy])
      or (typeSpecifiers = [longsy,intsy])
      or (typeSpecifiers = [signedsy,longsy,intsy]) then begin
      if isLongLong then
         myTypeSpec := longLongPtr
      else
         myTypeSpec := longPtr;
      end {else if}
   else if (typeSpecifiers = [unsignedsy,longsy])
      or (typeSpecifiers = [unsignedsy,longsy,intsy]) then begin
      if isLongLong then
         myTypeSpec := uLongLongPtr
      else
         myTypeSpec := uLongPtr;
      end {else if}
   else if typeSpecifiers = [floatsy] then
      myTypeSpec := floatPtr
   else if typeSpecifiers = [doublesy] then
      myTypeSpec := doublePtr
   else if (typeSpecifiers = [longsy,doublesy])
      or (typeSpecifiers = [extendedsy]) then
      myTypeSpec := extendedPtr
   else if typeSpecifiers = [compsy] then
      myTypeSpec := compPtr
   else if typeSpecifiers = [_Boolsy] then begin
      myTypeSpec := boolPtr;
      end {else if}
   else
      Error(badNextTokenError);
   end; {ResolveType}


begin {DeclarationSpecifiers}
myTypeSpec := nil;
myIsForwardDeclared := false;           {not doing a forward reference (yet)}
myDeclarationModifiers := [];
myStorageClass := ident;
typeQualifiers := [];
typeSpecifiers := [];
typeDone := false;
isLongLong := false;
while token.kind in allowedTokens do begin
   case token.kind of
      {storage class specifiers}
      autosy,externsy,registersy,staticsy,typedefsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         if myStorageClass <> ident then begin
            if typeDone or (typeSpecifiers <> []) then
               Error(badNextTokenError)
            else
               Error(26);
            end; {if}
         myStorageClass := token.kind;
         if not doingFunction then
            if token.kind = autosy then
               Error(62);
         if doingParameters then begin
            if token.kind <> registersy then
               Error(87);
            end {if}
         else if myStorageClass in [staticsy,typedefsy] then begin
            {Error if we may have allocated type info in local pool.}
            {This should not come up with current use of MM pools.  }
            if not useGlobalPool then
               if typeDone then
                  Error(57);
            useGlobalPool := true;
            end; {else if}
         if doingForLoopClause1 then
            if not (myStorageClass in [autosy,registersy]) then
               Error(127);
         if _Thread_localsy in myDeclarationModifiers then
            if not (myStorageClass in [staticsy,externsy]) then
               Error(177);
         NextToken;
         end;

      _Thread_localsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         if doingParameters then
            Error(87);
         if not (myStorageClass in [ident,staticsy,externsy]) then
            Error(177);
         NextToken;
         end;

      {function specifiers}
      inlinesy,_Noreturnsy,asmsy,pascalsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         NextToken;
         end;

      {type qualifiers}
      constsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         typeQualifiers := typeQualifiers + [tqConst];
         NextToken;
         end;

      volatilesy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         typeQualifiers := typeQualifiers + [tqVolatile];
         volatile := true;
         NextToken;
         end;

      restrictsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         typeQualifiers := typeQualifiers + [tqRestrict];
         if typeDone or (typeSpecifiers <> []) then
            if (myTypeSpec^.kind <> pointerType)
               or (myTypeSpec^.pType^.kind = functionType) then
               Error(143);
         NextToken;
         end;

      _Atomicsy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         Error(137);
         NextToken;
         if token.kind = lparench then begin
            {_Atomic(typename) as type specifier}
            if typeDone or (typeSpecifiers <> []) then
               Error(badNextTokenError);
            NextToken;
            myTypeSpec := TypeName;
            Match(rparench, 12);
            end; {if}
            typeDone := true;
         end;

      {type specifiers}
      unsignedsy,signedsy,intsy,longsy,charsy,shortsy,floatsy,doublesy,voidsy,
      compsy,extendedsy,_Boolsy: begin
         if typeDone then
            Error(badNextTokenError)
         else if token.kind in typeSpecifiers then begin
            if (token.kind = longsy) and 
               ((myTypeSpec = longPtr) or (myTypeSpec = uLongPtr)) then begin
               isLongLong := true;
               ResolveType;
               end
            else
               Error(badNextTokenError);
            end {if}
         else begin
            if restrictsy in myDeclarationModifiers then begin
               myDeclarationModifiers := myDeclarationModifiers - [restrictsy];
               Error(143);
               end; {if}
            typeSpecifiers := typeSpecifiers + [token.kind];
            ResolveType;
            end; {else}
         NextToken;
         end;

      _Complexsy,_Imaginarysy: begin
         Error(136);
         NextToken;
         end;

      enumsy: begin                     {enum}
         if typeDone or (typeSpecifiers <> []) then
            Error(badNextTokenError)
         else if restrictsy in myDeclarationModifiers then
            Error(143);
         NextToken;                     {skip the 'enum' token}
         if token.kind in [ident,typedef] then begin {handle a type definition}
            ttoken := token;
            NextToken;
            variable :=
               FindSymbol(ttoken, tagSpace, token.kind = lbracech, true);
            if token.kind = lbracech then begin
               if (variable <> nil) and (variable^.itype^.kind = enumType) then
                  if not looseTypeChecks then
                     Error(53);
               end {if}
            else
               if (variable <> nil) and (variable^.itype^.kind = enumType) then
                  begin
                  if looseTypeChecks then
                     declaredTagOrEnumConst := true;
                  goto 1;
                  end {if}
               else begin
                  declaredTagOrEnumConst := true;
                  if not looseTypeChecks then
                     Error(171);
                  end; {else}
            tPtr := pointer(Malloc(sizeof(typeRecord)));
            tPtr^.size := cgWordSize;
            tPtr^.saveDisp := 0;
            tPtr^.qualifiers := [];
            tPtr^.kind := enumType;
            variable :=
               NewSymbol(ttoken.name, tPtr, ident, tagSpace, defined, false);
            end {if}
         else if token.kind <> lbracech then
            Error(9);
         enumVal := 0;                  {set the default value}
         if token.kind = lbracech then begin
            declaredTagOrEnumConst := true;
            NextToken;                  {skip the '{'}
            repeat                      {declare the enum constants}
               tPtr := pointer(Malloc(sizeof(typeRecord)));
               tPtr^.size := cgWordSize;
               tPtr^.saveDisp := 0;
               tPtr^.qualifiers := [];
               tPtr^.kind := enumConst;
               if token.kind = ident then begin
                  variable := NewSymbol(token.name, tPtr, ident, variableSpace,
                     defined, false);
                  NextToken;
                  end {if}
               else
                  Error(9);
               if token.kind = eqch then begin {handle explicit enumeration values}
                  NextToken;
                  Expression(arrayExpression,[commach,rbracech]);
                  enumVal := long(expressionValue).lsw;
                  if enumVal <> expressionValue then
                     Error(6)
                  else if enumVal < 0 then
                     if expressionType^.kind = scalarType then
                        if expressionType^.baseType in [cgULong,cgUQuad] then
                           Error(6);
                  end; {if}
               tPtr^.eval := enumVal;   {set the enumeration constant value}
               enumVal := enumVal+1;    {inc the default enumeration value}
               if token.kind = commach then {next enumeration...}
                  begin
                  done := false;
                  NextToken;
                  {kws -- allow trailing , in enum }
                  { C99 6.7.2.2 Enumeration specifiers }
                  if token.kind = rbracech then done := true;
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
1:       myTypeSpec := intPtr;
         typeDone := true;
         end;
  
      structsy,                         {struct}
      unionsy: begin                    {union}
         if typeDone or (typeSpecifiers <> []) then
            Error(badNextTokenError)
         else if restrictsy in myDeclarationModifiers then
            Error(143);
         globalStruct := false;         {we didn't make it global}
         if token.kind = structsy then  {set the type kind to use}
            tKind := structType
         else
            tKind := unionType;
         structPtr := nil;              {no record, yet}
         structTypePtr := defaultStruct; {use int as a default type}
         NextToken;                     {skip 'struct' or 'union'}
         if token.kind in [ident,typedef] {if there is a struct name then...}
            then begin
                                        {look up the name}
            structPtr := FindSymbol(token, tagSpace, true, true);
            ttoken := token;            {record the structure name}
            NextToken;                  {skip the structure name}
            if (token.kind = lbracech) or
               ((token.kind = semicolonch) and (myDeclarationModifiers = []))
               then
               declaredTagOrEnumConst := true;
            if structPtr = nil then begin {if the name hasn't been defined then...}
               if token.kind <> lbracech then
                  if (token.kind <> semicolonch) or 
                     (myDeclarationModifiers <> []) then
                     structPtr := FindSymbol(ttoken, tagSpace, false, true);
               if structPtr <> nil then
                  structTypePtr := structPtr^.itype
               else begin
                  myIsForwardDeclared := true;
                  globalStruct := doingParameters and (token.kind <> lbracech);
                  if globalStruct then begin
                     lUseGlobalPool := useGlobalPool;
                     useGlobalPool := true;
                     end; {if}
                  structTypePtr := pointer(Calloc(sizeof(typeRecord)));
                 {structTypePtr^.size := 0;}
                 {structTypePtr^.saveDisp := 0;}
                 {structTypePtr^.qualifiers := [];}
                  structTypePtr^.kind := tkind;
                 {structTypePtr^.fieldList := nil;}
                 {structTypePtr^.sName := nil;}
                 {structTypePtr^.constMember := false;}
                 {structTypePtr^.flexibleArrayMember := false;}
                  structPtr := NewSymbol(ttoken.name, structTypePtr, ident,
                     tagSpace, defined, false);
                  structTypePtr^.sName := structPtr^.name;
                  declaredTagOrEnumConst := true;
                  end;
               end {if}
                                        {the name has been defined, so...}
            else if structPtr^.itype^.kind <> tKind then begin
               Error(42);               {it's an error if it's not a struct}
               declaredTagOrEnumConst := true; {avoid extra errors}
               structPtr := nil;
               end {else}
            else begin                  {record the existing structure type}
               structTypePtr := structPtr^.itype;
               end; {else}
            end {if}
         else if token.kind <> lbracech then begin
            Error(9);                   {its an error if there's no name or struct}
            declaredTagOrEnumConst := true; {avoid extra errors}
            end; {else if}
2:       if token.kind = lbracech then  {handle a structure definition...}
            begin                       {error if we already have one!}
            if (structTypePtr <> defaultStruct)
               and (structTypePtr^.fieldList <> nil) then begin
               Error(53);
               structPtr := nil;
               end; {if}
            NextToken;                  {skip the '{'}
            if structTypePtr = defaultStruct then begin
               structTypePtr := pointer(Calloc(sizeof(typeRecord)));
              {structTypePtr^.size := 0;}
              {structTypePtr^.saveDisp := 0;}
              {structTypePtr^.qualifiers := [];}
               structTypePtr^.kind := tkind;
              {structTypePtr^.fieldList := nil;}
              {structTypePtr^.sName := nil;}
              {structTypePtr^.constMember := false;}
              {structTypePtr^.flexibleArrayMember := false;}
               end; {if}
            if structPtr <> nil then
               structPtr^.itype := structTypePtr;
            FieldList(structTypePtr,tKind); {define the fields}
            if token.kind = rbracech then {insist on a closing rbrace}
               NextToken
            else begin
               Error(23);
               SkipStatement;
               end; {else}
            end; {if}
         if globalStruct then
            useGlobalPool := lUseGlobalPool;
         myTypeSpec := structTypePtr;
         if tKind = structType then
            myDeclarationModifiers := myDeclarationModifiers + [structsy]
         else
            myDeclarationModifiers := myDeclarationModifiers + [unionsy];
         typeDone := true;
         end;
 
      typedef: begin                    {named type definition}
         if (typeSpecifiers = []) and not typeDone then begin
            myTypeSpec := token.symbolPtr^.itype;
            if restrictsy in myDeclarationModifiers then
               if (myTypeSpec^.kind <> pointerType)
                  or (myTypeSpec^.pType^.kind = functionType) then
                  Error(143);
            NextToken;
            typeDone := true;
            end {if}
         else                           {interpret as declarator, not type specifier}
            goto 3;
         end;

      {alignment specifier}
      _Alignassy: begin
         myDeclarationModifiers := myDeclarationModifiers + [token.kind];
         NextToken;
         Match(lparench, 13);
         if token.kind in specifierQualifierListElement then begin
            tPtr := TypeName;
            with tPtr^ do
               if (size = 0) or ((kind = arrayType) and (elements = 0)) then
                  Error(133);
            end {if}
         else begin
            Expression(arrayExpression, [rparench]);
            if (expressionValue <> 0) and (expressionValue <> 1) then
               Error(138);
            end;
         Match(rparench, 12);
         end;

      otherwise: begin
         Error(57);
         NextToken;
         end;
      end; {case}
   end; {while}
3:
isForwardDeclared := myIsForwardDeclared;
declSpecifiers.declarationModifiers := myDeclarationModifiers;
if _Thread_localsy in myDeclarationModifiers then
   if myStorageClass = ident then
      if doingFunction then
         Error(177);
if myTypeSpec = nil then begin
   myTypeSpec := intPtr;                {under C89, default type is int}
   if (lint & lintC99Syntax) <> 0 then
      Error(151);
   end; {if}
declSpecifiers.typeSpec :=              {apply type qualifiers}
   MakeQualifiedType(myTypeSpec, typeQualifiers);
declSpecifiers.storageClass := myStorageClass;
end; {DeclarationSpecifiers}


{-- Externally available subroutines ---------------------------}

procedure DoDeclaration {doingPrototypes: boolean};

{ process a variable or function declaration                    }
{                                                               }
{ parameters:                                                   }
{       doingPrototypes - is this a prototype parameter decl?   }

label 1,2,3,4;

var
   declarationSpecifierFound: boolean;  {has some decl specifier been found?}
   first: boolean;                      {handling first declarator in decl?}
   fName: stringPtr;                    {for forming uppercase names}
   i: integer;                          {loop variable}
   isAsm: boolean;                      {has the asm modifier been used?}
   isInline: boolean;                   {has the inline specifier been used?}
   isNoreturn: boolean;                 {has the _Noreturn specifier been used?}
   isPascal: boolean;                   {has the pascal modifier been used?}
   alignmentSpecified: boolean;         {was an alignment explicitly specified?}
   lDoingParameters: boolean;           {local copy of doingParameters}
   lInhibitHeader: boolean;             {local copy of inhibitHeader}
   lp,tlp,tlp2: identPtr;               {for tracing parameter list}
   lUseGlobalPool: boolean;             {local copy of useGlobalPool}
   nextPdisp: integer;                  {for calculating parameter disps}
   p1,p2,p3: parameterPtr;              {for reversing prototyped parameters}
   variable: identPtr;                  {pointer to the variable being declared}
   fnType: typePtr;                     {function type}
   segType: integer;                    {segment type}
   tp: typePtr;                         {for tracing type lists}
   tk: tokenType;                       {work token}
   startLine: longint;                  {line where this declaration starts}
   declSpecifiers: declSpecifiersRecord; {type & specifiers for the declaration}


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
            begin
            if tp^.elements = 0 then    { size and an unspecified size is not  }
               if not firstVariable then { allowed here, flag an error.         }
                  begin
                  Error(49);
                  goto 1;
                  end; {if}
            if tp^.aType^.size = 0 then begin
               Error(123);
               goto 1;
               end; {if}
            if tp^.aType^.kind in [structType,unionType] then
               if tp^.aType^.flexibleArrayMember then
                  Error(169);
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

   begin {SkipFunction}
   Match(lbracech,27);                  {skip to the closing rbrackch}
   braceCount := 1;
   while (not (token.kind = eofsy)) and (braceCount <> 0) do begin
      if token.kind = lbracech then
         braceCount := braceCount+1
      else if token.kind = rbracech then
         braceCount := braceCount-1;
      NextToken;
      end; {while}
   nameFound := false;                  {no pc_nam for the next function (yet)}
   doingFunction := false;              {no longer doing a function}
   end; {SkipFunction}


begin {DoDeclaration}
lInhibitHeader:= inhibitHeader;
inhibitHeader := true;			{block imbedded includes in headers}
if token.kind = _Static_assertsy then begin
   DoStaticAssert;
   goto 4;
   end; {if}
lDoingParameters := doingParameters;    {record the status}
first := true;                          {preparing to handle first declarator}
if doingPrototypes then                 {prototypes implies a parm list}
   doingParameters := true
else
   lastParameter := nil;                {init parm list if we're not doing prototypes}
startLine := lineNumber;
if not doingFunction then               {handle any segment statements}
   while token.kind = segmentsy do
      SegmentStatement;
lUseGlobalPool := useGlobalPool;
                                        {handle a TypeSpecifier/declarator}
declarationSpecifierFound := token.kind in declarationSpecifiersElement;
declaredTagOrEnumConst := false;
DeclarationSpecifiers(declSpecifiers, declarationSpecifiersElement, 176);
isPascal := pascalsy in declSpecifiers.declarationModifiers;
isAsm := asmsy in declSpecifiers.declarationModifiers;
isInline := inlinesy in declSpecifiers.declarationModifiers;
isNoreturn := _Noreturnsy in declSpecifiers.declarationModifiers;
alignmentSpecified := _Alignassy in declSpecifiers.declarationModifiers;
if token.kind = semicolonch then
   if not doingPrototypes then
      if not declaredTagOrEnumConst then
         Error(176);

3:
isFunction := false;                    {assume it's not a function}
variable := nil;
Declarator(declSpecifiers, variable, variableSpace, doingPrototypes);
if variable = nil then begin
   inhibitHeader := lInhibitHeader;
   if token.kind = semicolonch then begin
      if not first then
         Error(176);
      NextToken;
      end {if}
   else begin
      Error(22);
      SkipStatement;
      end; {else}
   goto 1;
   end; {if}

{handle a function declaration}
if isFunction then begin

   if not declarationSpecifierFound then
      if first then
         if doingPrototypes or (token.kind in [commach,semicolonch]) then
            Error(26)
         else
            if (lint & lintNoFnType) <> 0 then
               if (lint & lintC99Syntax) = 0 then
                  Error(104);
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
   if isInline or isNoreturn then
      if not (isNewDeskAcc or isClassicDeskAcc or isCDev or isNBA or isXCMD) then
         if variable^.name^ = 'main' then
            Error(181);
   if alignmentSpecified then
      Error(142);
   if _Thread_localsy in declSpecifiers.declarationModifiers then
      Error(178);
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
   else if token.kind in [commach,semicolonch,inlinesy] then begin
      fnType^.isPascal := isPascal;     {note if we have pascal parms}
      if token.kind = inlinesy then     {handle tool declarations}
         with fnType^ do begin
            NextToken;
            Match(lparench,13);
            if token.kind in
               [intconst,uintconst,ushortconst,charconst,scharconst,ucharconst]
               then begin
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
            else if token.kind in
               [intconst,uintconst,ushortconst,charconst,scharconst,ucharconst]
               then begin
               dispatcher := token.ival;
               NextToken;
               end {if}
            else
               Error(18);
            Match(rparench,12);
            end; {with}
      doingParameters := doingPrototypes; {not doing parms any more}
      if token.kind = semicolonch then begin
         inhibitHeader := lInhibitHeader;
         NextToken;                     {skip the trailing semicolon}
         end {if}
      else if (token.kind = commach) and (not doingPrototypes) then begin
         PopTable;			{pop the symbol table}
         NextToken;                     {allow further declarations}
         first := false;
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
      if not first then
         Error(22);
      if variable^.state = defined then
         Error(42);
      ftype := fnType^.ftype;           {record the type of the function}
      while fType^.kind = definedType do
         fType := fType^.dType;
      fIsNoreturn := isNoreturn;        {record if function is _Noreturn}
      variable^.state := defined;       {note that the function is defined}
      pfunc := variable;                {set the identifier for parm checks}
      fnType^.isPascal := isPascal;     {note if we have pascal parms}
      doingFunction := true;            {read the parameter list}
      doingParameters := true;
                                        {declare the parameters}
      lp := lastParameter;              {(save now; it's volatile)}
      while not (token.kind in [lbracech,eofsy]) do
         if token.kind in declarationSpecifiersElement then
            DoDeclaration(false)
         else begin
            Error(27);
            NextToken;
            end; {else}
      if numberOfParameters <> 0 then   {default K&R parm type is int}
         begin
         tlp := lp;
         while tlp <> nil do begin
            if tlp^.itype = nil then begin
               tlp^.itype := intPtr;
               if (lint & lintC99Syntax) <> 0 then
                  if (lint & lintNotPrototyped) = 0 then
                     Error(147);        {C99+ require K&R params to be declared}
               end; {if}
            tlp := tlp^.pnext;
            end; {while}
         end; {if}
      tlp := lp;			{make sure all parameters have an}
      while tlp <> nil do begin		{ identifier and a complete type }
         if tlp^.name^ = '?' then begin
            Error(113);
            tlp := nil;
            end {if}
         else begin
            if tlp^.itype^.size = 0 then
               if not (tlp^.itype^.kind in [arrayType,functionType]) then
                  Error(148);
            tlp := tlp^.pnext;
            end; {else}
         end; {while}
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
      if (variable^.storage = external) and variable^.inlineDefinition then begin
         new(fname);
         fname^ := concat('~inline~', variable^.name^);
         segType := $4000;
         end {if}
      else if fnType^.isPascal then begin
         fName := pointer(Malloc(length(variable^.name^)+1));
         CopyString(pointer(fName), pointer(variable^.name));
         for i := 1 to length(fName^) do
            if fName^[i] in ['a'..'z'] then
               fName^[i] := chr(ord(fName^[i]) & $5F);
         end; {if}
      Gen2Name(dc_str, segType, 0, fName);
      doingMain := variable^.name^ = 'main';
      hasVarargsCall := false;
      firstCompoundStatement := true;
      Gen0 (dc_pin);
      if not isAsm then
         Gen1Name(pc_ent, 0, variable^.name);
      functionName := variable^.name;
      nextLocalLabel := 1;              {initialize GetLocalLabel}
      returnLabel := GenLabel;          {set up an exit point}
      tempList := nil;                  {initialize the work label list}
      if not isAsm then                 {generate traceback, profile code}
         if traceBack or profileFlag then begin
            if traceBack then
               nameFound := true;
            debugSourceFileGS := sourceFileGS;
            GenPS(pc_nam, variable^.name);
            end; {if}
      changedSourceFile := false;
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
            if (lp^.itype^.kind = scalarType) and
               (lp^.itype^.baseType in [cgReal,cgDouble,cgComp]) then begin
               if extendedParameters then
                  {all floating-point params are treated as extended}
                  lp^.itype :=
                     MakeQualifiedType(extendedPtr, lp^.itype^.qualifiers);
               nextPdisp := nextPdisp + cgExtendedSize;
               end {if}
            else begin
               nextPdisp := nextPdisp + long(lp^.itype^.size).lsw;
               if (long(lp^.itype^.size).lsw = 1)
                  and (lp^.itype^.kind = scalarType) then
                  nextPdisp := nextPdisp+1;
               end; {else}
            end; {else}
         lp := lp^.pnext;
         end; {while}
      gotoList := nil;                  {initialize the label list}
      fenvAccessInFunction := fenvAccess;
      if isAsm then begin
         AsmFunction(variable);         {handle assembly language functions}
         PopTable;
         end {if}
      else begin
                                        {set up struct/union area}
         if variable^.itype^.ftype^.kind in [structType,unionType] then begin
            lp := NewSymbol(@'@struct', variable^.itype^.ftype, staticsy,
               variablespace, declared, false);
            tk.kind := ident;
            tk.class := identifier;
            tk.name := @'@struct';
            tk.symbolPtr := nil;
            lp := FindSymbol(tk, variableSpace, false, true);
            Gen1Name(pc_lao, 0, lp^.name);
            Gen2t(pc_str, 0, 0, cgULong);
            end; {if}
					{generate parameter labels}
         if fnType^.overrideKR then
            GenParameters(nil)
         else
            GenParameters(fnType^.parameterList); 
         savedVolatile := volatile;
         functionTable := table;
         if fnType^.varargs then begin  {make internal va info for varargs funcs}
            lp := NewSymbol(@'__orcac_va_info', vaInfoPtr, autosy,
               variableSpace, declared, false);
            lp^.lln := GetLocalLabel;
            Gen2(dc_loc, lp^.lln, ord(vaInfoPtr^.size));
            Gen2(pc_lda, lastParameterLLN, lastParameterSize);
            Gen2t(pc_cop, lp^.lln, 0, cgULong);
            Gen2t(pc_str, lp^.lln, cgPointerSize, cgULong);
            vaInfoLLN := lp^.lln;
            end {if}
         else
            vaInfoLLN := 0;
         CompoundStatement(false);      {process the statements}
         end; {else}
      end; {else}
2: ;
   end {if}

{handle a variable declaration}
else {if not isFunction then} begin
   if not declarationSpecifierFound then
      if first then
         Error(26);
   if alignmentSpecified then
      if declSpecifiers.storageClass in [typedefsy,registersy] then
         Error(142);
   if isPascal then
      variable^.itype := MakePascalType(variable^.itype);
   if isInline then
      Error(119);
   if isNoreturn then
      Error(141);
   if token.kind = eqch then begin
      if declSpecifiers.storageClass = typedefsy then
         Error(52);
      if doingPrototypes then
         Error(88);
                                        {allocate copy of incomplete array type,}
      tp := variable^.itype;            {so it can be completed by Initializer}
      if (tp^.kind = arrayType) and (tp^.elements = 0) then begin
         variable^.itype := pointer(Malloc(sizeof(typeRecord)));
         variable^.itype^ := tp^;
         variable^.itype^.saveDisp := 0;
         end;
      TermHeader;                       {make sure the header file is closed}
      NextToken;                        {handle an initializer}
      Initializer(variable);
      end; {if}
                                        {check to insure array sizes are specified}
   if declSpecifiers.storageClass <> typedefsy then
      CheckArray(variable,
         (declSpecifiers.storageClass = externsy) 
         or doingParameters or not doingFunction);
                                        {allocate space}
   if variable^.storage = stackFrame then begin
      variable^.lln := GetLocalLabel;
      Gen2(dc_loc, variable^.lln, long(variable^.itype^.size).lsw);
      if variable^.state = initialized then
         AutoInit(variable, startLine, false); {initialize auto variable}
      end; {if}
   if (token.kind = commach) and (not doingPrototypes) then begin
      NextToken;                        {allow multiple variables on one line}
      first := false;
      goto 3;
      end; {if}
   if doingPrototypes then begin
      protoVariable := variable;        {make the var available to Declarator}
      if protoVariable = nil then
         protoType := declSpecifiers.typeSpec
      else
         protoType := protoVariable^.iType;
      end {if}
   else begin
      inhibitHeader := lInhibitHeader;
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
4:
inhibitHeader := lInhibitHeader;
end; {DoDeclaration}


function TypeName{: typePtr};

{ process a type name (used for casts and sizeof/_Alignof)      }
{                                                               }
{ returns: a pointer to the type                                }

var
   tl,tp: typePtr;                      {for creating/reversing the type list}
   declSpecifiers: declSpecifiersRecord; {type & specifiers for the type name}


   procedure AbstractDeclarator;

   { process an abstract declarator                             }
   {                                                            }
   { abstract-declarator:                                       }
   {    empty-abstract-declarator                               }
   {    nonempty-abstract-declarator                            }


      procedure NonEmptyAbstractDeclarator;

      { process a nonempty abstract declarator                  }
      {                                                         }
      { nonempty-abstract-declarator:                           }
      {    ( nonempty-abstract-declarator )                     }
      {    abstract-declarator ( )                              }
      {    abstract-declarator [ expression OPT ]               }
      {    * abstract-declarator                                }

      var
         pcount: integer;               {paren counter}
         tp: typePtr;                   {work pointer}

      begin {NonEmptyAbstractDeclarator}
      if token.kind = lparench then begin
         NextToken;
         if token.kind = rparench then begin

            {create a function type}
            tp := pointer(Calloc(sizeof(typeRecord)));
            {tp^.size := 0;}
            {tp^.saveDisp := 0;}
            {tp^.qualifiers := [];}
            tp^.kind := functionType;
            {tp^.varargs := false;}
            {tp^.prototyped := false;}
            {tp^.overrideKR := false;}
            {tp^.parameterList := nil;}
            {tp^.isPascal := false;}
            {tp^.toolNum := 0;}
            {tp^.dispatcher := 0;}
            tp^.fType := Unqualify(tl);
            tl := tp;
            NextToken;
            end {if}
         else begin

            {handle a parenthesized type}
            if not (token.kind in [lparench,asteriskch,lbrackch]) then
               begin
               Error(82);
               while not (token.kind in
                  [eofsy,lparench,asteriskch,lbrackch,rparench]) do
                  NextToken;
               end; {if}
            if token.kind in [lparench,asteriskch,lbrackch] then
               NonEmptyAbstractDeclarator;
            Match(rparench,12);
            end; {else}
         end {if token.kind = lparench}
      else if token.kind = asteriskch then begin

         {create a pointer type}
         NextToken;
         tp := pointer(Malloc(sizeof(typeRecord)));
         tp^.size := cgPointerSize;
         tp^.saveDisp := 0;
         tp^.qualifiers := [];
         tp^.kind := pointerType;
         while token.kind in [constsy,volatilesy,restrictsy] do begin
            if token.kind = constsy then
               tp^.qualifiers := tp^.qualifiers + [tqConst]
            else if token.kind = volatilesy then begin
               tp^.qualifiers := tp^.qualifiers + [tqVolatile];
               volatile := true;
               end {else}
            else {if token.kind = restrictsy then}
               tp^.qualifiers := tp^.qualifiers + [tqRestrict];
            NextToken;
            end; {while}
         AbstractDeclarator;
         tp^.fType := tl;
         tl := tp;
         end {else if token.kind = asteriskch}
      else {if token.kind = lbrackch then} begin

         {create an array type}
         NextToken;
         if token.kind = rbrackch then
            expressionValue := 0
         else begin
            Expression(arrayExpression, [rbrackch]);
            if expressionValue <= 0 then begin
               Error(45);
               expressionValue := 1;
               end; {if}
            end; {else}
         tp := pointer(Malloc(sizeof(typeRecord)));
         tp^.saveDisp := 0;
         tp^.kind := arrayType;
         tp^.elements := expressionValue;
         tp^.fType := tl;
         tl := tp;
         Match(rbrackch,24);
         end; {else}

      if token.kind = lparench then begin
         {create a function type}
         NextToken;
         pcount := 1;
         while (token.kind <> eofsy) and (pcount <> 0) do begin
            if token.kind = rparench then
               pcount := pcount-1
            else if token.kind = lparench then
               pcount := pcount+1;
            NextToken;
            end; {while}
         tp := pointer(Calloc(sizeof(typeRecord)));
         {tp^.size := 0;}
         {tp.saveDisp := 0;}
         {tp^.qualifiers := [];}
         tp^.kind := functionType;
         {tp^.varargs := false;}
         {tp^.prototyped := false;}
         {tp^.overrideKR := false;}
         {tp^.parameterList := nil;}
         {tp^.isPascal := false;}
         {tp^.toolNum := 0;}
         {tp^.dispatcher := 0;}
         tp^.fType := Unqualify(tl);
         tl := tp;
         end; {if}
      end; {NonEmptyAbstractDeclarator}


   begin {AbstractDeclarator}
   while token.kind in [lparench,asteriskch,lbrackch] do
      NonEmptyAbstractDeclarator;
   end; {AbstractDeclarator}


begin {TypeName}
{read and process the type specifier}
DeclarationSpecifiers(declSpecifiers, specifierQualifierListElement, 12);

{_Alignas is not allowed in most uses of type names.            }
{TODO: _Alignas should be allowed in compound literals.         }
if _Alignassy in declSpecifiers.declarationModifiers then
   Error(142);

{handle the abstract-declarator part}
tl := nil;                              {no types so far}
AbstractDeclarator;                     {create the type list}
while tl <> nil do begin                {reverse the list & compute array sizes}
   tp := tl^.aType;                     {NOTE: assumes aType, pType and fType overlap in typeRecord}
   tl^.aType := declSpecifiers.typeSpec;
   if tl^.kind = arrayType then
      tl^.size := tl^.elements * declSpecifiers.typeSpec^.size;
   declSpecifiers.typeSpec := tl;
   tl := tp;
   end; {while}
if pascalsy in declSpecifiers.declarationModifiers then
   declSpecifiers.typeSpec := MakePascalType(declSpecifiers.typeSpec);
TypeName := declSpecifiers.typeSpec;
end; {TypeName}


procedure DoStatement;

{ process a statement from a function                           }

var
   lToken: tokenType;                   {temporary copy of old token}
   nToken: tokenType;                   {new token}
   hasStatementNext: boolean;           {is a stmt next within a compound stmt?}
   lSuppressMacroExpansions: boolean;   {local copy of suppressMacroExpansions}

begin {DoStatement}
case statementList^.kind of

   compoundSt: begin
      hasStatementNext := true;
      if token.kind = rbracech then begin
         hasStatementNext := false;
         EndCompoundStatement;
         end {if}
      else if (statementList^.doingDeclaration or allowMixedDeclarations)
         and (token.kind in localDeclarationStart)
         then begin
         hasStatementNext := false;
         if token.kind <> typedef then
            DoDeclaration(false)
         else begin
            lToken := token;
            lSuppressMacroExpansions := suppressMacroExpansions;
            suppressMacroExpansions := true; {inhibit token echo}
            NextToken;
            suppressMacroExpansions := lSuppressMacroExpansions;
            nToken := token;
            PutBackToken(nToken, false);
            token := lToken;
            if nToken.kind <> colonch then
               DoDeclaration(false)
            else
               hasStatementNext := true;
            end {else}
         end; {else if}
         
      if hasStatementNext then begin
         if statementList^.doingDeclaration then begin
            statementList^.doingDeclaration := false;
            if firstCompoundStatement then begin
               Gen1Name(dc_sym, ord(doingMain), pointer(table));
               firstCompoundStatement := false;
               end; {if}
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


procedure AutoInit {variable: identPtr; line: longint;
   isCompoundLiteral: boolean};

{ generate code to initialize an auto variable                  }
{                                                               }
{ parameters:                                                   }
{       variable - the variable to initialize                   }
{       line - line number (used for debugging)                 }
{       isCompoundLiteral - initializing a compound literal?    }

var
   iPtr: initializerPtr;                {pointer to the next initializer}
   codeCount: longint;                  {number of initializer expressions}
   treeCount: integer;                  {current number of distinct trees}
   ldoDispose: boolean;                 {local copy of doDispose}


   procedure InitializeOneElement;

   { initialize (part of) a variable using the initializer iPtr }
   {                                                            }
   { variables:                                                 }
   {    variable - the variable to initialize                   }
   {    count - number of times to re-use the initializer       }
   {    iPtr - pointer to the initializer record to use         }

   label 1,2,3;

   var
      count: integer;                   {initializer counter}
      disp: longint;                    {displacement to initialize at}
      elements: longint;                {# array elements}
      itype: typePtr;                   {the type being initialized}
      size: integer;                    {fill size}

                                        {assignment conversion}
                                        {---------------------}
      tree: tokenPtr;                   {expression tree}
      val: longint;                     {constant expression value}
      isConstant: boolean;              {is the expression a constant?}


      procedure LoadAddress;

      { Load the address of the operand                         }

      begin {LoadAddress}
      if variable^.storage = stackFrame then
         Gen2(pc_lda, variable^.lln, ord(disp))
      else
         Error(57);
      end; {LoadAddress}


      function ZeroFill (elements: longint; itype: typePtr;
                         count: integer; iPtr: initializerPtr): boolean;

      { See if an array can be zero filled			}
      {								}
      { parameters:						}
      {    elements - elements in the array			}
      {    itype - type of each array element			}
      {    count - remaining initializer repetitions		}
      {    iPtr - initializer record				}

      begin {ZeroFill}
      ZeroFill := false;
      if not iPtr^.isConstant then
         if itype^.kind in [scalarType,enumType] then
            if count >= elements then
               with iPtr^.itree^ do
                  if token.kind = intconst then
                     if token.ival = 0 then
                                        {don't call ~ZERO for very small arrays}
                        if elements * itype^.size > 10 then
                           ZeroFill := true;
      end; {ZeroFill}


      procedure AddOperation;

      { Deal with a new initializer expression in a compound    }
      { literal, adding expression tree nodes as appropriate.   }
      { This aims to produce a balanced binary tree.            }
      
      var
         val: longint;
      
      begin {AddOperation}
      treeCount := treeCount + 1;
      codeCount := codeCount + 1;
      val := codeCount;
      while (val & 1) = 0 do begin
         Gen0t(pc_bno, cgVoid);
         treeCount := treeCount - 1;
         val := val >> 1;
         end; {end}
      end; {AddOperation}
      

   begin {InitializeOneElement}
   disp := iPtr^.disp;
   count := iPtr^.count;
3: itype := iPtr^.iType;
   while itype^.kind = definedType do
      itype := itype^.dType;
   case itype^.kind of

      scalarType,pointerType,enumType,functionType: begin
         tree := iptr^.itree;           
         if tree = nil then goto 2;     {don't generate code in error case}
         LoadAddress;                   {load the destination address}
                                        {generate the expression value}
         doDispose := ldoDispose and (count = 1);
                                        {see if this is a constant}
                                        {do assignment conversions}
         while tree^.token.kind = castoper do
            tree := tree^.left;
         isConstant :=
            tree^.token.class in [intConstant,longConstant,longlongConstant];
         if isConstant then
            if tree^.token.class = intConstant then
               val := tree^.token.ival
            else if tree^.token.class = longConstant then
               val := tree^.token.lval
            else {if tree^.token.class = longlongConstant then} begin
               if (tree^.token.qval.hi = 0) and (tree^.token.qval.lo >= 0) then
                  val := tree^.token.qval.lo
               else
                  isConstant := false;
               end; {else}
        
         if isConstant then             {zero-initialize two bytes at a time}
            if val = 0 then
               if count > 1 then
                  if itype^.size = 1 then begin
                     itype := shortPtr;
                     count := count - 1;
                     end; {if}

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
         case itype^.kind of            {save the value}
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
         if isCompoundLiteral then
            AddOperation;
2:       end;

      arrayType: begin
         elements := itype^.elements;
         if elements = 0 then goto 1;   {don't init flexible array member}
         if itype^.aType^.kind = scalarType then
            if iPtr^.iTree^.token.kind = stringConst then begin
               elements := elements * itype^.aType^.size;
               size := iPtr^.iTree^.token.sval^.length;
               if size >= elements then
                  size := ord(elements)
               else
                  size := size-1;
               if size <> 0 then begin
                  GenLdcLong(size);
                  Gen0t(pc_stk, cgULong);
                  GenS(pc_lca, iPtr^.iTree^.token.sval);
                  Gen0t(pc_stk, cgULong);
                  Gen0t(pc_bno, cgULong);
                  LoadAddress;
                  Gen0t(pc_stk, cgULong);
                  Gen0t(pc_bno, cgULong);
                  Gen1tName(pc_cup, 0, cgVoid, @'memcpy');
                  if isCompoundLiteral then
                     AddOperation;
                  end; {if}
               if size < elements then begin
                  elements := elements - size;     
                  disp := disp + size;                
                  LoadAddress;
                  Gen0t(pc_stk, cgULong);
                  Gen1t(pc_ldc, ord(elements), cgWord);
                  Gen0t(pc_stk, cgWord);
                  Gen0t(pc_bno, cgULong);
                  Gen1tName(pc_cup, -1, cgVoid, @'~ZERO');
                  if isCompoundLiteral then
                     AddOperation;
                  end; {if}
               end; {if}
1:          end;

      structType,unionType: begin
         LoadAddress;                   {load the destination address}
         GenerateCode(iptr^.iTree);     {load the struct address}
                                        {do the assignment}
         AssignmentConversion(itype, expressionType, isConstant, val,
            true, false);
         with expressionType^ do
            Gen2(pc_mov, long(size).msw, long(size).lsw);
         Gen0t(pc_pop, UsualUnaryConversions);
         if isCompoundLiteral then
            AddOperation;
         end; {if}

      otherwise: Error(57);
      end; {case}
   if count <> 1 then begin
      count := count - 1;
      disp := disp + itype^.size;
      goto 3;
      end; {if}
   end; {InitializeOneElement}


begin {AutoInit}
iPtr := variable^.iPtr;
if isCompoundLiteral then begin
   treeCount := 0;
   codeCount := 0;
   ldoDispose := doDispose;
   end {if}
else
   ldoDispose := true;
if variable^.class <> staticsy then begin
   if traceBack or debugFlag then
      if nameFound or debugFlag then
         if (statementList <> nil) and not statementList^.doingDeclaration then
            if lineNumber <> 0 then
               RecordLineNumber(line);
   while iPtr <> nil do begin
      InitializeOneElement;
      iPtr := iPtr^.next;
      end; {while}
   end; {if}
if isCompoundLiteral then begin
   while treeCount > 1 do begin
      Gen0t(pc_bno, cgVoid);
      treeCount := treeCount - 1;
      end; {while}
   doDispose := lDoDispose;
   end; {if}
end; {AutoInit}


function MakeFuncIdentifier{: identPtr};

{ Make the predefined identifier __func__.                      }
{                                                               }
{ It is inserted in the symbol table as if the following        }
{ declaration appeared at the beginning of the function body:   }
{                                                               }
{     static const char __func__[] = "function-name";           }
{                                                               }
{ This must only be called within a function body.              }

var
   lTable: symbolTablePtr;              {saved copy of current symbol table}
   tp: typePtr;                         {the type of __func__}
   id: identPtr;                        {the identifier for __func__}
   sval: longstringPtr;                 {the initializer string}
   iPtr: initializerPtr;                {the initializer}
   i: integer;                          {loop variable}
   len: integer;                        {string length}

begin {MakeFuncIdentifier}
lTable := table;
table := functionTable;

len := ord(functionName^[0]) + 1;
tp := pointer(GCalloc(sizeof(typeRecord)));
tp^.size := len;
{tp^.saveDisp := 0;}
{tp^.qualifiers := [];}
tp^.kind := arrayType;
tp^.aType := constCharPtr;
tp^.elements := len;
id := NewSymbol(@'__func__', tp, staticsy, variableSpace, initialized, false);

sval := pointer(GCalloc(len + sizeof(integer)));
sval^.length := len;
for i := 1 to len-1 do
   sval^.str[i] := functionName^[i];
{sval^.str[len] := chr(0);}
iPtr := pointer(GCalloc(sizeof(initializerRecord)));
{iPtr^.next := nil;}
iPtr^.count := 1;
{iPtr^.bitdisp := 0;}
{iPtr^.bitsize := 0;}
iPtr^.isConstant := true;
iPtr^.basetype := cgString;
iPtr^.sval := sval;
id^.iPtr := iPtr;

table := lTable;
MakeFuncIdentifier := id;
end; {MakeFuncIdentifier}


function MakeCompoundLiteral{tp: typePtr): identPtr};

{ Make the identifier for a compound literal.                   }
{                                                               }
{ parameters:                                                   }
{       tp - the type of the compound literal                   }

type
   nameString = packed array [0..24] of char;

var
   id: identPtr;                        {the identifier for the literal}
   name: ^nameString;                   {the name for the identifier}
   class: tokenEnum;                    {storage class}

begin {MakeCompoundLiteral}
if functionTable <> nil then
   class := autosy
else
   class := staticsy;
name := pointer(Malloc(25));
name^ := concat('~CompoundLiteral', cnvis(compoundLiteralNumber));
id := NewSymbol(name, tp, class, variableSpace, defined, false);
compoundLiteralNumber := compoundLiteralNumber + 1;
if compoundLiteralNumber = 0 then
   Error(57);
Initializer(id);
MakeCompoundLiteral := id;
if class = autosy then begin
   id^.lln := GetLocalLabel;
   id^.clnext := compoundLiteralToAllocate;
   compoundLiteralToAllocate := id;
   end;
end; {MakeCompoundLiteral}


procedure InitParser;

{ Initialize the parser                                         }

var
   typeSpecifierStart: tokenSet;
   storageClassSpecifiers: tokenSet;
   typeQualifiers: tokenSet;
   functionSpecifiers: tokenSet;
   alignmentSpecifiers: tokenSet;

begin {InitParser}
doingFunction := false;                 {not doing a function (yet)}
doingParameters := false;               {not processing parameters}
lastLine := 0;                          {no pc_lnm generated yet}
nameFound := false;                     {no pc_nam generated yet}
statementList := nil;                   {no open statements}
codegenStarted := false;                {code generator is not started}
doingForLoopClause1 := false;           {not doing a for loop}
fIsNoreturn := false;                   {not doing a noreturn function}
compoundLiteralNumber := 1;             {no compound literals yet}
compoundLiteralToAllocate := nil;       {no compound literals needing space yet}

                                        {init syntactic classes of tokens}
                                        {See C17 section 6.7 ff.}
typeSpecifierStart := 
   [voidsy,charsy,shortsy,intsy,longsy,floatsy,doublesy,signedsy,unsignedsy,
    extendedsy,compsy,_Boolsy,_Complexsy,_Imaginarysy,_Atomicsy,
    structsy,unionsy,enumsy,typedef];

storageClassSpecifiers :=
   [typedefsy,externsy,staticsy,_Thread_localsy,autosy,registersy];

typeQualifiers :=
   [constsy,volatilesy,restrictsy,_Atomicsy];

functionSpecifiers := [inlinesy,_Noreturnsy,pascalsy,asmsy];

alignmentSpecifiers := [_Alignassy];

declarationSpecifiersElement := typeSpecifierStart + storageClassSpecifiers
   + typeQualifiers + functionSpecifiers + alignmentSpecifiers;

specifierQualifierListElement := 
   typeSpecifierStart + typeQualifiers + alignmentSpecifiers + [pascalsy];

structDeclarationStart := specifierQualifierListElement + [_Static_assertsy];

topLevelDeclarationStart :=
   declarationSpecifiersElement + [ident,segmentsy,_Static_assertsy];

localDeclarationStart :=
   declarationSpecifiersElement + [_Static_assertsy] - [asmsy];
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
