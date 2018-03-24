{$optimize 1}
{---------------------------------------------------------------}
{                                                               }
{  Expression                                                   }
{                                                               }
{  Evaluate expressions                                         }
{                                                               }
{  Note:  The expression evaluator uses the scanner to fetch    }
{  tokens, but IT IS ALSO USED BY THE SCANNER to evaluate       }
{  expressions in preprocessor commands.  This circular         }
{  dependency is handle by defining all of the expression       }
{  evaluator's external types, constants, and variables in the  }
{  CCOMMON module.  The only procedure from this module used by }
{  the scanner is Expression, which is declared as an external  }
{  procedure in the scanner.                                    }
{                                                               }
{  External Variables:                                          }
{                                                               }
{  startExpression - tokens that may start an expression        }
{  bitDisp,bitSize - bit field disp, size                       }
{  unsigned - is the bit field unsigned?                        }
{  isBitField - is the field a bit field?                       }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  AssignmentConversion - do type checking and conversions for  }
{       assignment statements                                   }
{  CompareToZero - Compare the result on tos to zero.           }
{  DisposeTree - dispose of an expression tree                  }
{  DoSelection - Find the displacement & type for a             }
{       selection operation                                     }
{  Expression - handle an expression                            }
{  FreeTemp - place a temporary label in the available label    }
{       list                                                    }
{  GenerateCode - generate code from a fully formed expression  }
{       tree                                                    }
{  GetTemp - find a temporary work variable                     }
{  InitExpression - initlialize the expression handler          }
{  UsualBinaryConversions - performs the usual binary           }
{       conversions                                             }
{  UsualUnaryConversions - performs the usual unary conversions }
{                                                               }
{---------------------------------------------------------------}

unit Expression;

{$LibPrefix '0/obj/'}

interface

uses CCommon, Table, CGI, Scanner, Symbol, MM, Printf;

{$segment 'EXP'}

var
   startExpression: tokenSet;           {tokens that can start an expression}

                                        {set by DoSelection}
                                        {------------------}
   bitDisp,bitSize: integer;            {bit field disp, size}
   unsigned: boolean;                   {is the bit field unsigned?}
   isBitField: boolean;                 {is the field a bit field?}

                                        {misc}
                                        {----}
   lastwasconst: boolean;               {did the last GenerateCode result in an integer constant?}
   lastconst: longint;                  {last integer constant from GenerateCode}
{---------------------------------------------------------------}

procedure AssignmentConversion (t1, t2: typePtr; isConstant: boolean;
   value: longint; genCode, checkConst: boolean);

{ TOS is of type t2, and is about to be stored to a variable of }
{ type t1 by an assignment or a return statement.  Make sure    }
{ this is legal, and do any necessary type conversions on t2,   }
{ which is on the top of the evaluation stack.  Flag an error   }
{ if the conversion is illegal.                                 }
{                                                               }
{ parameters:                                                   }
{       t1 - type of the variable                               }
{       t2 - type of the expression                             }
{       isConstant - is the rhs a constant?                     }
{       value - if isConstant = true, then this is the value    }
{       genCode - should conversion code be generated?          }
{       checkConst - check for assignments to constants?        }


procedure CompareToZero(op: pcodes);

{ Compare the result on tos to zero.                            }
{                                                               }
{ This procedure is used by the logical statements to compare   }
{ _any_ scalar result to zero, giving a boolean result.         }
{                                                               }
{ parameters:                                                   }
{    op - operation to use on the compare                       }


procedure DisposeTree (tree: tokenPtr);
 
{ dispose of an expression tree                                  }
{                                                                }
{ parameters:                                                    }
{     tree - head of the expression tree to dispose of           }
 

procedure DoSelection (lType: typePtr; tree: tokenPtr; var size: longint);

{ Find the displacement & type for a selection operation        }
{                                                               }
{ parameters:                                                   }
{         lType - structure/union type                          }
{         id - tag field name                                   }
{         size - disp into the structure/union                  }
{                                                               }
{ returned in non-local variables:                              }
{         bitDisp - displacement to bit field                   }
{         bitSize - size of bit field                           }
{         unsigned - is the bit field unsigned?                 }
{         isBitField - is the field a bit field?                }
{                                                               }
{ varaibles:                                                    }
{         expressionType - set to the type of the field         }


procedure Expression (kind: expressionKind; stopSym: tokenSet);

{ handle an expression                                          }
{                                                               }
{ parameters:                                                   }
{       kind - Kind of expression; determines what operations   }
{               and what kind of operands are allowed.          }
{       stopSym - Set of symbols that can mark the end of an    }
{               expression; used to skip tokens after syntax    }
{               errors and to block certain operations.  For    }
{               example, the comma operator is not allowed in   }
{               an expression when evaluating a function        }
{               parameter list.                                 }
{                                                               }
{ variables:                                                    }
{       realExpressionValue - value of a real constant          }
{               expression                                      }
{       expressionValue - value of a constant expression        }
{       expressionType - type of the constant expression        }


procedure FreeTemp(labelNum, size: integer);

{ place a temporary label in the available label list           }
{                                                               }
{ parameters:                                                   }
{         labelNum - number of the label to free                }
{         size - size of the variable                           }
{                                                               }
{ variables:                                                    }
{         tempList - list of free labels                        }


procedure GenerateCode (tree: tokenPtr);

{ generate code from a fully formed expression tree              }
{                                                                }
{ parameters:                                                    }
{     tree - top of the expression tree to generate code from    }
{                                                                }
{ variables:                                                     }
{     expressionType - result type of the expression             }


function GetTemp(size: integer): integer;

{ find a temporary work variable                                }
{                                                               }
{ parameters:                                                   }
{         size - size of the variable                           }
{                                                               }
{ variables:                                                    }
{         tempList - list of free labels                        }
{                                                               }
{ Returns the label number.                                     }


procedure InitExpression;

{ initialize the expression handler                             }


function UsualBinaryConversions (lType: typePtr): baseTypeEnum;

{ performs the usual binary conversions                         }
{                                                               }
{ inputs:                                                       }
{         lType - type of the left operand                      }
{         expressionType - type of the right operand            }
{                                                               }
{ result:                                                       }
{         The base type of the operation to perform is          }
{         returned.  Any conversion code necessary has been     }
{         generated.                                            }
{                                                               }
{ outputs:                                                      }
{         expressionType - set to result type                   }


function UsualUnaryConversions: baseTypeEnum;

{ performs the usual unary conversions                          }
{                                                               }
{ inputs:                                                       }
{       expressionType - type of the operand                    }
{                                                               }
{ result:                                                       }
{       The base type of the operation to perform is returned.  }
{       Any conversion code necessary has been generated.       }
{                                                               }
{ outputs:                                                      }
{       expressionType - set to result type                     }

{---------------------------------------------------------------}

implementation

const
                                        {notAnOperation is also used in TABLE.ASM}
   notAnOperation = 200;                {used as the icp for non-operation tokens}

var
                                        {structured constants}
                                        {--------------------}
   startTerm: tokenSet;                 {tokens that can start a term}

                                        {misc}
                                        {----}
   errorFound: boolean;                 {was there are error during generation?}

{-- Procedures imported from the parser ------------------------}

procedure Match (kind: tokenEnum; err: integer); extern;

{ insure that the next token is of the specified type           }
{                                                               }
{  parameters:                                                  }
{       kind - expected token kind                              }
{       err - error number if the expected token is not found   }


procedure TypeSpecifier (doingFieldList,isConstant: boolean); extern;

{ handle a type specifier                                       }
{                                                               }
{ parameters:                                                   }
{       doingFieldList - are we processing a field list?        }
{       isConstant - did we already find a constsy?             }

{-- External unsigned math routines ----------------------------}

function lshr (x,y: longint): longint; extern;

function udiv (x,y: longint): longint; extern;

function uge (x,y: longint): longint; extern;

function ugt (x,y: longint): longint; extern;

function ule (x,y: longint): longint; extern;

function ult (x,y: longint): longint; extern;

function umod (x,y: longint): longint; extern;

function umul (x,y: longint): longint; extern;

{---------------------------------------------------------------}

function Unary(tp: baseTypeEnum): baseTypeEnum;

{ usual unary conversions                                       }
{                                                               }
{ This function returns the base type actually loaded on the    }
{ stack for a particular data type.  This corresponds to C's    }
{ usual unary conversions.                                      }
{                                                               }
{ parameter:                                                    }
{      tp - data type                                           }
{                                                               }
{ result:                                                       }
{      Stack type.                                              }

begin {Unary}
if tp in [cgByte,cgUByte,cgReal,cgDouble,cgComp] then
   if tp in [cgByte,cgUByte] then
      tp := cgWord
   else {if tp in [cgReal,cgDouble,cgComp] then}
      tp := cgExtended;
Unary := tp;
end; {Unary}


function UsualBinaryConversions {lType: typePtr): baseTypeEnum};

{ performs the usual binary conversions                         }
{                                                               }
{ inputs:                                                       }
{         lType - type of the left operand                      }
{         expressionType - type of the right operand            }
{                                                               }
{ result:                                                       }
{         The base type of the operation to perform is          }
{         returned.  Any conversion code necessary has been     }
{         generated.                                            }
{                                                               }
{ outputs:                                                      }
{         expressionType - set to result type                   }

var
   rType: typePtr;                      {right type}
   lt,rt: baseTypeEnum;                 {work variables}

begin {UsualBinaryConversions}
UsualBinaryConversions := cgULong;
if lType^.kind = pointerType then
   lType := uLongPtr
else if lType^.kind = scalarType then
   if lType^.baseType = cgVoid then begin
      lType := uLongPtr;
      Error(66);
      end; {if}
rType := expressionType;
if rType^.kind = pointerType then
   rType := uLongPtr
else if rType^.kind = scalarType then
   if rType^.baseType = cgVoid then begin
      rType := uLongPtr;
      Error(66);
      end; {if}
if (lType^.kind = scalarType) and (rType^.kind = scalarType) then begin
   lt := Unary(lType^.baseType);
   rt := Unary(rType^.baseType);
   if lt <> rt then begin
      if lt = cgExtended then begin
         if rt in [cgWord,cgUWord,cgLong,cgULong] then
            Gen2(pc_cnv, ord(rt), ord(cgExtended));
         UsualBinaryConversions := cgExtended;
         expressionType := extendedPtr;
         end {if}
      else if rt = cgExtended then begin
         if lt in [cgWord,cgUWord,cgLong,cgULong] then
            Gen2(pc_cnn, ord(lt), ord(cgExtended));
         UsualBinaryConversions := cgExtended;
         expressionType := extendedPtr;
         end {else if}
      else if lt = cgULong then begin
         if rt in [cgWord,cgUWord] then
            Gen2(pc_cnv, ord(rt), ord(cgULong));
         UsualBinaryConversions := cgULong;
         expressionType := uLongPtr;
         end {else if}
      else if rt = cgULong then begin
         if lt in [cgWord,cgUWord] then
            Gen2(pc_cnn, ord(lt), ord(cgULong));
         UsualBinaryConversions := cgULong;
         expressionType := uLongPtr;
         end {else if}
      else if lt = cgLong then begin
         if rt in [cgWord,cgUWord] then
            Gen2(pc_cnv, ord(rt), ord(cgLong));
         UsualBinaryConversions := cgLong;
         expressionType := longPtr;
         end {else if}
      else if rt = cgLong then begin
         if lt in [cgWord,cgUWord] then
            Gen2(pc_cnn, ord(lt), ord(cgLong));
         UsualBinaryConversions := cgLong;
         expressionType := longPtr;
         end {else if}
      else {one operand is unsigned in and the other is int} begin
         UsualBinaryConversions := cgUWord;
         expressionType := uWordPtr;
         end; {else}
      end {if}
   else begin {types are the same}
      UsualBinaryConversions := lt;
      if lt = cgWord then               {update types that may have changed}
         expressionType := wordPtr
      else if lt = cgExtended then
         expressionType := extendedPtr;
      end; {else}
   end {if}
else
   Error(66);
end; {UsualBinaryConversions}


function UsualUnaryConversions{: baseTypeEnum};

{ performs the usual unary conversions                          }
{                                                               }
{ inputs:                                                       }
{       expressionType - type of the operand                    }
{                                                               }
{ result:                                                       }
{       The base type of the operation to perform is returned.  }
{       Any conversion code necessary has been generated.       }
{                                                               }
{ outputs:                                                      }
{       expressionType - set to result type                     }

var
   et: baseTypeEnum;                    {work variables}

begin {UsualUnaryConversions}
UsualUnaryConversions := cgULong;
if expressionType^.kind = scalarType then begin
   et := Unary(expressionType^.baseType);
   UsualUnaryConversions := et;
   if et = cgWord then                  {update types that may have changed}
      expressionType := wordPtr
   else if et = cgExtended then
      expressionType := extendedPtr;
   end {if}
{else if expressionType^.kind in [arrayType,pointerType] then
   UsualUnaryConversions := cgULong};
end; {UsualUnaryConversions}


procedure DisposeTree {tree: tokenPtr};
 
{ dispose of an expression tree                                  }
{                                                                }
{ parameters:                                                    }
{     tree - head of the expression tree to dispose of           }
 
begin {DisposeTree}
if tree <> nil then begin
   DisposeTree(tree^.left);
   DisposeTree(tree^.middle);
   DisposeTree(tree^.right);
   dispose(tree);
   end; {if}
end; {DisposeTree}


procedure AssignmentConversion {t1, t2: typePtr; isConstant: boolean;
   value: longint; genCode, checkConst: boolean};

{ TOS is of type t2, and is about to be stored to a variable of }
{ type t1 by an assignment or a return statement.  Make sure    }
{ this is legal, and do any necessary type conversions on t2,   }
{ which is on the top of the evaluation stack.  Flag an error   }
{ if the conversion is illegal.                                 }
{                                                               }
{ parameters:                                                   }
{       t1 - type of the variable                               }
{       t2 - type of the expression                             }
{       isConstant - is the rhs a constant?                     }
{       value - if isConstant = true, then this is the value    }
{       genCode - should conversion code be generated?          }
{       checkConst - check for assignments to constants?        }

var
   baseType1,baseType2: baseTypeEnum;   {temp variables (for speed)}
   kind1,kind2: typeKind;               {temp variables (for speed)}

begin {AssignmentConversion}
kind1 := t1^.kind;
kind2 := t2^.kind;
if t1^.isConstant then
   if genCode then
      if checkConst then
         Error(93);
if kind2 = definedType then
   AssignmentConversion(t1, t2^.dType, false, 0, genCode, checkConst)
else if kind1 = definedType then
   AssignmentConversion(t1^.dType, t2, false, 0, genCode, checkConst)
else if kind2 in
   [scalarType,pointerType,enumType,structType,unionType,arrayType,functionType] then
   case kind1 of

      scalarType: begin
         baseType1 := t1^.baseType;
         if baseType1 = cgString then
            Error(64)
         else if baseType1 = cgVoid then
            Error(65)
         else if kind2 = enumType then begin
            if genCode then
               Gen2(pc_cnv, ord(cgWord), ord(baseType1));
            end {else if}
         else if kind2 = scalarType then begin
            baseType2 := t2^.baseType;
            if baseType2 in [cgString,cgVoid] then
               Error(47)
            else if genCode then
               Gen2(pc_cnv, ord(baseType2), ord(baseType1));
            end {else if}
         else
            Error(47);
         end;

      arrayType: ;
         {any errors are handled elsewhere}

      functionType,enumConst:
         Error(47);

      pointerType: begin
         if kind2 = pointerType then begin
            if not CompTypes(t1, t2) then
               Error(47);
            end {if}
         else if kind2 = arrayType then begin
            if not CompTypes(t1^.ptype, t2^.atype) then
               if t1^.ptype^.baseType <> cgVoid then
                  Error(47);
            end {if}
         else if kind2 = scalarType then begin
            if isConstant and (value = 0) then begin
               if genCode then
                  Gen2(pc_cnv, ord(t2^.baseType), ord(cgULong));
               end {if}
            else
               Error(47);
            end {else if}
         else
            Error(47);
         end;

      enumType: begin
         if kind2 = scalarType then begin
            baseType2 := t2^.baseType;
            if baseType2 in [cgString,cgVoid] then
               Error(47)
            else if genCode then
               Gen2(pc_cnv, ord(baseType2), ord(cgWord));
            end {if}
         else if kind2 <> enumType then
            Error(47);
         end;

      definedType:
         AssignmentConversion(t1^.dType, t2, isConstant, value, genCode,
            checkConst);

      structType,unionType:
         if not CompTypes(t1, t2) then
            Error(47);

      otherwise: Error(57);

      end; {case T1^.kind}

expressionType := t1;                   {set the type of the expression}
end; {AssignmentConversion}


function ExpressionTree (kind: expressionKind; stopSym: tokenSet): tokenPtr;

{ generate an expression tree                                    }
{                                                                }
{ Returns a pointer to the generated tree.  The pointer is       }
{ nil, and the variable errorFound is set to true, if an         }
{ error is found.                                                }
{                                                                }
{ parameters:                                                    }
{       kind - Kind of expression; determines what operations    }
{               and what kind of operands are allowed.           }
{       stopSym - Set of symbols that can mark the end of an     }
{               expression; used to skip tokens after syntax     }
{               errors and to block certain operations.  For     }
{               example, the comma operator is not allowed in    }
{               an expression when evaluating a function         }
{               parameter list.                                  }

label 1,2,3;

var
   done,done2: boolean;                 {for loop termination}
   doingSizeof: boolean;                {used to test for a sizeof operator}
   expectingTerm: boolean;              {should the next token be a term?}
   opStack: tokenPtr;                   {operation stack}
   parenCount: integer;                 {# of open parenthesis}
   stack: tokenPtr;                     {operand stack}

   op,sp: tokenPtr;                     {work pointers}


   procedure ComplexTerm;

   { handle complex terms                                       }

   var
      done: boolean;                    {for loop termination}
      namePtr: stringPtr;               {name of struct/union fields}
      sp,tp,tm: tokenPtr;               {work pointers}

   begin {ComplexTerm}
   while token.kind in
      [lbrackch,lparench,dotch,minusgtop,plusplusop,minusminusop] do begin
      case token.kind of

         lbrackch: begin                  {subscripting}
            NextToken;                    {skip the '['}
            new(sp);                      {evaluate the subscript}
            sp^.token.kind := plusch;
            sp^.token.class := reservedSymbol;
            sp^.left := stack;
            stack := stack^.next;
            sp^.middle := nil;
            sp^.right := ExpressionTree(normalExpression, [rbrackch]);
            sp^.next := stack;
            stack := sp;
            Match(rbrackch,24);           {skip the ']'}
            new(sp);                      {resolve the pointer}
            sp^.token.kind := uasterisk;
            sp^.token.class := reservedSymbol;
            sp^.left := stack;
            sp^.middle := nil;
            sp^.right := nil;
            sp^.next := stack^.next;
            stack := sp;
            end;

         lparench: begin                {function call}
            NextToken;
            new(sp);                    {create a parameter list terminator}
            sp^.token.kind := parameteroper;
            sp^.token.class := reservedSymbol;
            sp^.left := nil;
            sp^.middle := nil;
            sp^.right := nil;
            sp^.next := stack;
            stack := sp;
            if token.kind <> rparench   {evaluate the parameters}
               then begin
               done := false;
               repeat
                  if token.kind in [rparench,eofsy] then begin
                     done := true;
                     Error(35);
                     end {if}
                  else begin
                     new(sp);
                     sp^.token.kind := parameteroper;
                     sp^.token.class := reservedSymbol;
                     sp^.left := nil;
                     sp^.middle :=
                        ExpressionTree(normalExpression, [rparench,commach]);
                     sp^.right := stack;
                     sp^.next := stack^.next;
                     stack := sp;
                     if token.kind = commach then
                        NextToken
                     else
                        done := true;
                     end; {else}
               until done;
            end; {if}
            sp := stack;
            stack := sp^.next;
            sp^.left := stack;
            sp^.next := stack^.next;
            stack := sp;
            Match(rparench,12);
            end;

         dotch,minusgtop: begin         {direct and indirect selection}
            if token.kind = minusgtop then begin
               new(sp);                 {e->name == (*e).name}
               sp^.token.kind := uasterisk;
               sp^.token.class := reservedSymbol;
               sp^.left := stack;
               sp^.middle := nil;
               sp^.right := nil;
               sp^.next := stack^.next;
               stack := sp;
               token.kind := dotch;
               token.class := reservedSymbol;
               end; {if}
            new(sp);                    {create a record for the selection operator}
            sp^.token := token;
            sp^.left := stack;
            stack := stack^.next;
            sp^.middle := nil;
            sp^.right := nil;
            sp^.next := stack;
            stack := sp;
            NextToken;                  {skip the operator}
            if token.kind in [ident,typedef] then begin
               namePtr := token.name;   {record the name}
               new(sp);                 {record the selection field}
               sp^.token := token;
               sp^.left := nil;
               sp^.middle := nil;
               sp^.right := nil;
               stack^.right := sp;      {this becomes the right opnd}
               NextToken;               {skip the field name}
               end {if}
            else
               Error(9);
            end;

         plusplusop: begin              {postfix ++}
            NextToken;
            new(sp);
            sp^.token.kind := opplusplus;
            sp^.token.class := reservedSymbol;
            sp^.left := stack;
            stack := stack^.next;
            sp^.middle := nil;
            sp^.right := nil;
            sp^.next := stack;
            stack := sp;
            end;

         minusminusop: begin            {postfix --}
            NextToken;
            new(sp);
            sp^.token.kind := opminusminus;
            sp^.token.class := reservedSymbol;
            sp^.left := stack;
            stack := stack^.next;
            sp^.middle := nil;
            sp^.right := nil;
            sp^.next := stack;
            stack := sp;
            end;

         otherwise: Error(57);
         end; {case}
      end; {while}
   end; {ComplexTerm}


   procedure DoOperand;

   { process an operand                                         }

   label 1,2;

   var
      fnPtr: typePtr;                   {for defining functions on the fly}
      fToken: tokenType;                {used to save function name token}
      id: identPtr;                     {pointer to an id's symbol table entry}
      np: stringPtr;                    {for forming global names}
      sp: tokenPtr;                     {work pointer}

   begin {DoOperand}
   {create an operand on the stack}
   new(sp);
   sp^.token := token;
   sp^.next := stack;
   sp^.left := nil;
   sp^.middle := nil;
   sp^.right := nil;
   stack := sp;

   {handle the preprocessor 'defined' function}
   if kind = preprocessorExpression then
      if token.name^ = 'defined' then begin
         expandMacros := false;
         NextToken;
         sp^.token.kind := intconst;
         sp^.token.class := intConstant;
         if token.kind in [ident,typedef] then begin
            sp^.token.ival := ord(IsDefined(token.name));
            NextToken;
            end {if}
         else begin
            Match(lparench, 13);
            if token.kind in [ident,typedef] then begin
               sp^.token.ival := ord(IsDefined(token.name));
               NextToken;
               end {if}
            else begin
               Error(9);
               sp^.token.ival := 0;
               end; {else}
            Match(rparench, 12);
            end; {else}
         expandMacros := true;
         goto 1;
         end; {if}

   {check for illegal use}
   id := FindSymbol(token, variableSpace, false, true);
   if not (kind in
      [normalExpression,initializerExpression,autoInitializerExpression])
      then begin
      if id <> nil then
         if id^.itype^.kind = enumConst then
            goto 2;
      if kind <> preprocessorExpression then begin
         op := opStack;
         while op <> nil do begin
            if op^.token.kind = sizeofsy then
               goto 2;
            op := op^.next;
            end; {while}
         Error(41);
         errorFound := true;
         end; {if}
      end; {if}
   2:
   {skip the name}
   fToken := token;
   NextToken;

   {if the id is not declared, create a function returning integer}
   if id = nil then begin
      if token.kind = lparench then begin
         fnPtr := pointer(GCalloc(sizeof(typeRecord)));
         {fnPtr^.size := 0;}
         {fnPtr^.saveDisp := 0;}
         {fnPtr^.isConstant := false;}
         fnPtr^.kind := functionType;
         fnPtr^.fType := wordPtr;
         {fnPtr^.varargs := false;}
         {fnPtr^.prototyped := false;}
         {fnPtr^.overrideKR := false;}
         {fnPtr^.parameterList := nil;}
         {fnPtr^.isPascal := false;}
         {fnPtr^.toolNum := 0;}
         {fnPtr^.dispatcher := 0;}
         np := pointer(GMalloc(length(fToken.name^)+1));
         CopyString(pointer(np), pointer(fToken.name));
         id := NewSymbol(np, fnPtr, ident, variableSpace, declared);
         if (lint & lintUndefFn) <> 0 then
            Error(51);
         end {if}
      else if kind = preprocessorExpression then begin
         stack^.token.kind := intconst;
         stack^.token.ival := 0;
         end {else if}
      else begin
         Error(31);
         errorFound := true;
         end; {else}
      end {if id = nill}
   else if id^.itype^.kind = enumConst then begin
      stack^.token.kind := intconst;
      stack^.token.ival := id^.itype^.eval;
      end; {else if}
   stack^.id := id;                     {save the identifier}
   ComplexTerm;                         {handle subscripts, selection, etc.}
   1:
   end; {DoOperand}


   procedure Operation;

   { do an operation                                                }

   label 1;

   var
      baseType: baseTypeEnum;           {base type of value to cast}
      class: tokenClass;                {class of cast token}
      ekind: tokenEnum;                 {kind of constant expression}
      kindLeft, kindRight: tokenEnum;	{kinds of operands}
      lCodeGeneration: boolean;         {local copy of codeGeneration}
      op: tokenPtr;                     {work pointer}
      op1,op2: longint;                 {for evaluating constant expressions}
      rop1,rop2: double;                {for evaluating double expressions}
      tp: typePtr;                      {cast type}
      unsigned: boolean;                {is the term unsigned?}


      function Pop: tokenPtr;

      { pop an operand, returning its pointer                        }

      begin {Pop}
      if stack = nil then begin
         Error(36);
         errorFound := true;
         Pop := nil;
         end {if}
      else begin
         Pop := stack;
         stack := stack^.next;
         end; {else}
      end; {Pop}


      function RealVal (token: tokenType): double;

      { convert an operand to a real value                      }

      begin {RealVal}
      if token.kind = intconst then
         RealVal := token.ival
      else if token.kind = uintconst then begin
         if token.ival < 0 then
            RealVal := (token.ival & $7FFF) + 32768.0
         else
            RealVal := token.ival;
         end {else if}
      else if token.kind = longconst then
         RealVal := token.lval
      else if token.kind = ulongconst then begin
         if token.lval < 0 then
            RealVal := (token.lval & $7FFFFFFF) + 2147483648.0
         else
            RealVal := token.lval;
         end {else if}
      else
         RealVal := token.rval;
      end; {RealVal}


      function IntVal (token: tokenType): longint;

      { convert an operand to a longint value                   }

      begin {IntVal}
      if token.kind = intconst then
         IntVal := token.ival
      else if token.kind = uintconst then begin
         IntVal := token.ival & $0000FFFF;
         end {else if}
      else {if token.kind in [longconst,ulongconst] then} begin
         IntVal := token.lval;
         end; {else}
      end; {IntVal}


      function PPKind (token: tokenType): tokenEnum;

      { adjust kind of token for use in preprocessor expression }

      begin {PPKind}
      if token.kind = intconst then
         PPKind := longconst
      else if token.kind = uintconst then
         PPKind := ulongconst
      else
         PPKind := token.kind;
      end; {PPKind}


   begin {Operation}
   op := opStack;                       {pop the operation}
   opStack := op^.next;
   case op^.token.kind of

      commach: begin                    {,}
         op^.right := Pop;
         op^.left := Pop;
         end;

      eqch,                             {=}
      pluseqop,                         {+=}
      minuseqop,                        {-=}
      asteriskeqop,                     {*=}
      slasheqop,                        {/=}
      percenteqop,                      {%=}
      ltlteqop,                         {<<=}
      gtgteqop,                         {>>=}
      andeqop,                          {&=}
      caroteqop,                        {^=}
      bareqop: begin                    {|=}
         op^.right := Pop;
         op^.left := Pop;
         end;

      colonch: begin                    {? :}
         op^.right := Pop;
         op^.middle := Pop;
         op^.left := Pop;
         if op^.right^.token.kind in
            [intconst,uintconst,longconst,ulongconst] then
            if op^.left^.token.kind in
               [intconst,uintconst,longconst,ulongconst] then
               if op^.middle^.token.kind in
                  [intconst,uintconst,longconst,ulongconst] then begin
                  if IntVal(op^.left^.token) <> 0 then
                     op^.token := op^.middle^.token
                  else
                     op^.token := op^.right^.token;
                  dispose(op^.left);
                  dispose(op^.right);
                  dispose(op^.middle);
                  op^.left := nil;
                  op^.right := nil;
                  op^.middle := nil;
                  end; {if}
         end;

      questionch: begin              {error -> ? should not be unmatched}
         Error(29);
         errorFound := true;
         end;

      barbarop,                         {||}
      andandop,                         {&&}
      carotch,                          {^}
      barch,                            {|}
      andch,                            {&}
      eqeqop,                           {==}
      exceqop,                          {!=}
      ltch,                             {<}
      gtch,                             {>}
      lteqop,                           {<=}
      gteqop,                           {>=}
      ltltop,                           {<<}
      gtgtop,                           {>>}
      plusch,                           {+}
      minusch,                          {-}
      asteriskch,                       {*}
      slashch,                          {/}
      percentch: begin                  {%}
         op^.right := Pop;
         op^.left := Pop;
         kindRight := op^.right^.token.kind;
         kindLeft := op^.left^.token.kind;
         if kindRight in [intconst,uintconst,longconst,ulongconst] then begin
            if kindLeft in [intconst,uintconst,longconst,ulongconst] then begin
               if kind = preprocessorExpression then begin
                  kindLeft := PPKind(op^.left^.token);
                  kindRight := PPKind(op^.right^.token);
                  end; {if}

               {do the usual binary conversions}
               if (kindRight = ulongconst) or (kindLeft = ulongconst) then
                  ekind := ulongconst
               else if (kindRight = longconst) or (kindLeft = longconst) then
                  ekind := longconst
               else if (kindRight = uintconst) or (kindLeft = uintconst) then
                  ekind := uintconst
               else
                  ekind := intconst;

               {evaluate a constant operation}
               unsigned := ekind in [uintconst,ulongconst];
               op1 := IntVal(op^.left^.token);
               op2 := IntVal(op^.right^.token);
               dispose(op^.right);
               op^.right := nil;
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  barbarop    : begin                                   {||}
                                op1 := ord((op1 <> 0) or (op2 <> 0));
                                ekind := intconst;
                                end;
                  andandop    : begin                                   {&&}
                                op1 := ord((op1 <> 0) and (op2 <> 0));
                                ekind := intconst;
                                end;
                  carotch     : op1 := op1 ! op2;                       {^}
                  barch       : op1 := op1 | op2;                       {|}
                  andch       : op1 := op1 & op2;                       {&}
                  eqeqop      : begin                                   {==}
                                op1 := ord(op1 = op2);
                                ekind := intconst;
                                end;
                  exceqop     : begin                                   {!=}
                                op1 := ord(op1 <> op2);
                                ekind := intconst;
                                end;
                  ltch        : begin                                   {<}
                                if unsigned then
                                   op1 := ult(op1,op2)
                                else
                                   op1 := ord(op1 < op2);
                                ekind := intconst;
                                end;
                  gtch        : begin                                   {>}
                                if unsigned then
                                   op1 := ugt(op1,op2)
                                else
                                   op1 := ord(op1 > op2);
                                ekind := intconst;
                                end;
                  lteqop      : begin                                   {<=}
                                if unsigned then
                                   op1 := ule(op1,op2)
                                else
                                   op1 := ord(op1 <= op2);
                                ekind := intconst;
                                end;
                  gteqop      : begin                                   {>=}
                                if unsigned then
                                   op1 := uge(op1,op2)
                                else
                                   op1 := ord(op1 >= op2);
                                ekind := intconst;
                                end;
                  ltltop      : begin                                   {<<}
                                op1 := op1 << op2;
                                ekind := kindLeft;
                                end;
                  gtgtop      : begin                                   {>>}
                                if kindLeft in [uintconst,ulongconst] then
                                   op1 := lshr(op1,op2)
                                else
                                   op1 := op1 >> op2;
                                ekind := kindLeft;
                                end;
                  plusch      : op1 := op1 + op2;                       {+}
                  minusch     : op1 := op1 - op2;                       {-}
                  asteriskch  : if unsigned then          		{*}
                                   op1 := umul(op1,op2)
                                else
                                   op1 := op1 * op2;
                  slashch     : begin                                   {/}
                                if op2 = 0 then begin
                                   Error(109);
                                   op2 := 1;
                                   end; {if}
                                if unsigned then
                                   op1 := udiv(op1,op2)
                                else
                                   op1 := op1 div op2;
                                end;
                  percentch   : begin                                   {%}
                                if op2 <= 0 then {FIXME: support negative values}
                                   if (op2 = 0) or (not unsigned) then begin
                                      Error(109);
                                      op2 := 1;
                                      end; {if}
                                if unsigned then
                                   op1 := umod(op1,op2)
                                else
                                   op1 := op1 mod op2;
                                end;
                  otherwise: Error(57);
                  end; {case}
               op^.token.kind := ekind;
               if ekind in [longconst,ulongconst] then begin
                  op^.token.lval := op1;
                  op^.token.class := longConstant;
                  end {if}
               else begin
                  op^.token.ival := long(op1).lsw;
                  op^.token.class := intConstant;
                  end; {else}
               goto 1;
               end; {if}
            end; {if}
         if op^.right^.token.kind in
            [intconst,uintconst,longconst,ulongconst,doubleconst] then
            if op^.left^.token.kind in
               [intconst,uintconst,longconst,ulongconst,doubleconst] then
               begin
               ekind := doubleconst; {evaluate a constant operation}
               rop1 := RealVal(op^.left^.token);
               rop2 := RealVal(op^.right^.token);
               dispose(op^.right);
               op^.right := nil;
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  barbarop    : begin                                   {||}
                                op1 := ord((rop1 <> 0.0) or (rop2 <> 0.0));
                                ekind := intconst;
                                end;
                  andandop    : begin                                   {&&}
                                op1 := ord((rop1 <> 0.0) and (rop2 <> 0.0));
                                ekind := intconst;
                                end;
                  eqeqop      : begin                                   {==}
                                op1 := ord(rop1 = rop2);
                                ekind := intconst;
                                end;
                  exceqop     : begin                                   {!=}
                                op1 := ord(rop1 <> rop2);
                                ekind := intconst;
                                end;
                  ltch        : begin                                   {<}
                                op1 := ord(rop1 < rop2);
                                ekind := intconst;
                                end;
                  gtch        : begin                                   {>}
                                op1 := ord(rop1 > rop2);
                                ekind := intconst;
                                end;
                  lteqop      : begin                                   {<=}
                                op1 := ord(rop1 <= rop2);
                                ekind := intconst;
                                end;
                  gteqop      : begin                                   {>=}
                                op1 := ord(rop1 >= rop2);
                                ekind := intconst;
                                end;
                  plusch      : rop1 := rop1 + rop2;                    {+}
                  minusch     : rop1 := rop1 - rop2;                    {-}
                  asteriskch  : rop1 := rop1 * rop2;                    {*}
                  slashch     : begin                                   {/}
                                if rop2 = 0.0 then begin
                                   Error(109);
                                   rop2 := 1.0;
                                   end; {if}
                                rop1 := rop1 / rop2;
                                end;
                  otherwise   : Error(66);              {illegal operation}
                  end; {case}
               if ekind = intconst then begin
                  op^.token.ival := long(op1).lsw;
                  op^.token.class := intConstant;
                  op^.token.kind := intConst;
                  end {if}
               else begin
                  op^.token.rval := rop1;
                  op^.token.class := doubleConstant;
                  op^.token.kind := doubleConst;
                  end; {else}
               end; {if}
1:
         end;

      plusplusop,                       {prefix ++}
      minusminusop,                     {prefix --}
      opplusplus,                       {postfix ++}
      opminusminus,                     {postfix --}
      sizeofsy,                         {sizeof}
      castoper,                         {(type)}
      typedef,                          {(type-name)}
      tildech,                          {~}
      excch,                            {!}
      uminus,                           {unary -}
      uand,                             {unary &}
      uasterisk: begin                  {unary *}
         op^.left := Pop;

         if op^.token.kind = sizeofsy then begin
            op^.token.kind := ulongConst;
            op^.token.class := longConstant;
            if op^.left^.token.kind = stringConst then
               op^.token.lval := op^.left^.token.sval^.length+1
            else begin
               lCodeGeneration := codeGeneration;
               codeGeneration := false;
               GenerateCode(op^.left);
               codeGeneration := lCodeGeneration and (numErrors = 0);
               op^.token.lval := expressionType^.size;
               with expressionType^ do
                  if (size = 0) or ((kind = arrayType) and (elements = 0)) then
                     Error(49);
               end; {else}
            op^.left := nil;
            end {if sizeofsy}

         else if op^.token.kind = castoper then begin
            class := op^.left^.token.class;
            if class in [intConstant,longConstant,doubleConstant] then begin
               tp := op^.castType;
               while tp^.kind = definedType do
                  tp := tp^.dType;
               if tp^.kind = scalarType then begin
                  baseType := tp^.baseType;
                  if baseType < cgString then begin
                     if class = doubleConstant then begin
                        rop1 := RealVal(op^.left^.token);
                        op1 := trunc(rop1);
                        end {if}
                     else {if class in [intConstant,longConstant] then} begin
                        op1 := IntVal(op^.left^.token);
                        if op1 >= 0 then
                           rop1 := op1
                        else if op^.left^.token.kind = uintConst then
                           rop1 := (op1 & $7FFF) + 32768.0
                        else if op^.left^.token.kind = ulongConst then
                           rop1 := (op1 & $7FFFFFFF) + 2147483648.0
                        else
                           rop1 := op1;
                        end; {else if}
                     dispose(op^.left);
                     op^.left := nil;
                     if baseType in [cgByte,cgWord] then begin
                        op^.token.kind := intConst;
                        op^.token.class := intConstant;
                        op^.token.ival := long(op1).lsw;
                        if baseType = cgByte then
                           with op^.token do begin
                              ival := ival & $00FF;
                              if (ival & $0080) <> 0 then
                                 ival := ival | $FF00;
                              end; {with}
                        end {if}
                     else if baseType in [cgUByte,cgUWord] then begin
                        op^.token.kind := uintConst;         
                        op^.token.class := intConstant;
                        op^.token.ival := long(op1).lsw;
                        if baseType = cgUByte then
                           op^.token.ival := op^.token.ival & $00FF;
                        end {else if}
                     else if baseType = cgLong then begin
                        op^.token.kind := longConst;
                        op^.token.class := longConstant;
                        op^.token.lval := op1;
                        end {else if}
                     else if baseType = cgULong then begin
                        op^.token.kind := ulongConst;
                        op^.token.class := longConstant;
                        op^.token.lval := op1;
                        end {else if}
                     else begin
                        op^.token.kind := doubleConst;
                        op^.token.class := doubleConstant;
                        op^.token.rval := rop1;
                        end; {else if}
                     end; {if}
                  end; {if}
               end; {if}
            end {else if castoper}

         else if not (op^.token.kind in
            [typedef,plusplusop,minusminusop,opplusplus,opminusminus,uand]) then
            begin
            if (op^.left^.token.kind
               in [intconst,uintconst,longconst,ulongconst]) then begin

               {evaluate a constant operation}
               ekind := op^.left^.token.kind;
               if kind = preprocessorExpression then
                  ekind := PPKind(op^.left^.token);
               op1 := IntVal(op^.left^.token);
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  tildech     : op1 := ~op1;                    {~}
                  excch       : begin                           {!}
                     op1 := ord(op1 = 0);
                     ekind := intconst;
                     end;
                  uminus      : op1 := -op1;                    {unary -}
                  uasterisk   : Error(79);                      {unary *}
                  otherwise: Error(57);
                  end; {case}
               op^.token.kind := ekind;
               if ekind in [longconst,ulongconst] then begin
                  op^.token.class := longConstant;
                  op^.token.lval := op1;
                  end {if}
               else begin
                  op^.token.class := intConstant;
                  op^.token.ival := long(op1).lsw;
                  end; {else}
               end {if}
            else if op^.left^.token.kind = doubleconst then begin
               ekind := doubleconst; {evaluate a constant operation}
               rop1 := RealVal(op^.left^.token);
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  uminus      : begin                        {unary -}
                     op^.token.class := doubleConstant;
                     op^.token.kind := doubleConst;
                     op^.token.rval := -rop1;
                     end;
                  excch       : begin                        {!}
                     op^.token.class := intConstant;
                     op^.token.kind := intconst;
                     op^.token.ival := ord(rop1 = 0.0);
                     end;
                  otherwise   : begin                        {illegal operation}
                     Error(66);
                     op^.token.class := doubleConstant;
                     op^.token.kind := doubleConst;
                     op^.token.rval := rop1;
                     end;
                  end; {case}
               end; {if}
            end; {if}
         end;

      otherwise: Error(57);
      end; {case}
   op^.next := stack;                     {place the operation on the operand stack}
   stack := op;
   end; {Operation}


   procedure Skip;

   { skip all tokens in the reminader of the expression             }

   begin {Skip}
   while not (token.kind in stopSym+[eofsy]) do
      NextToken;
   errorFound := true;
   end; {Skip}


   procedure TypeName;

   { find the type (used for casts and sizeof)                  }
   {                                                            }
   { outputs:                                                   }
   {         typeSpec - pointer to the type                     }

   var
      tl,tp: typePtr;                   {for creating/reversing the type list}


      procedure AbstractDeclarator;

      { process an abstract declarator                          }
      {                                                         }
      { abstract-declarator:                                    }
      {    empty-abstract-declarator                            }
      {    nonempty-abstract-declarator                         }


         procedure NonEmptyAbstractDeclarator;

         { process a nonempty abstract declarator               }
         {                                                      }
         { nonempty-abstract-declarator:                        }
         {    ( nonempty-abstract-declarator )                  }
         {    abstract-declarator ( )                           }
         {    abstract-declaraotr [ expression OPT ]            }
         {    * abstract-declarator                             }

         var
            pcount: integer;            {paren counter}
            tp: typePtr;                {work pointer}

         begin {NonEmptyAbstractDeclarator}
         if token.kind = lparench then begin
            NextToken;
            if token.kind = rparench then begin

               {create a function type}
               tp := pointer(Calloc(sizeof(typeRecord)));
               {tp^.size := 0;}
               {tp^.saveDisp := 0;}
               {tp^.isConstant := false;}
               tp^.kind := functionType;
               {tp^.varargs := false;}
               {tp^.prototyped := false;}
               {tp^.overrideKR := false;}
               {tp^.parameterList := nil;}
               {tp^.isPascal := false;}
               {tp^.toolNum := 0;}
               {tp^.dispatcher := 0;}
               tp^.fType := tl;
               tl := tp;
               NextToken;
               end {if}
            else begin

               {handle a perenthesized type}
               if not (token.kind in [lparench,asteriskch,lbrackch]) then
                  begin
                  Error(82);
                  while not (token.kind in
                     [eofsy,lparench,asteriskch,lbrackch,rparench]) do
                     NextToken;
                  errorFound := true;
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
            tp^.size := cgLongSize;
            tp^.saveDisp := 0;
            tp^.isConstant := false;
            tp^.kind := pointerType;
            while token.kind in [constsy,volatilesy] do begin
               if token.kind = constsy then
                  tp^.isConstant := true
               else {if token.kind = volatilesy then}
                  if not doingSizeof then
                     volatile := true;
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
            {tp^.isConstant := false;}
            tp^.kind := functionType;
            {tp^.varargs := false;}
            {tp^.prototyped := false;}
            {tp^.overrideKR := false;}
            {tp^.parameterList := nil;}
            {tp^.isPascal := false;}
            {tp^.toolNum := 0;}
            {tp^.dispatcher := 0;}
            tp^.fType := tl;
            tl := tp;
            end; {if}
         end; {NonEmptyAbstractDeclarator}


      begin {AbstractDeclarator}
      while token.kind in [lparench,asteriskch,lbrackch] do
         NonEmptyAbstractDeclarator;
      end; {AbstractDeclarator}


   begin {TypeName}
   {read and process the type specifier}
   typeSpec := wordPtr;
   TypeSpecifier(false,false);

   {handle the abstract-declarator part}
   tl := nil;                           {no types so far}
   AbstractDeclarator;                  {create the type list}
   while tl <> nil do begin             {reverse the list & compute array sizes}
      tp := tl^.aType;                  {NOTE: assumes aType, pType and fType overlap in typeRecord}
      tl^.aType := typeSpec;
      if tl^.kind = arrayType then
         tl^.size := tl^.elements * typeSpec^.size;
      typeSpec := tl;
      tl := tp;
      end; {while}
   end; {TypeName}
    

begin {ExpressionTree}
opStack := nil;
stack := nil;
if token.kind = typedef then            {handle typedefs that are hidden}
   if FindSymbol(token,allSpaces,false,true) <> nil then
      if token.symbolPtr^.class <> typedefsy then
         token.kind := ident;
if token.kind in startExpression then begin
   expressionValue := 0;                {initialize the expression value}
   expectingTerm := true;               {the first item should be a term}
   done := false;                       {convert the expression to postfix form}
   parenCount := 0;
   repeat                               {scan the token list...}
      if token.kind in startTerm then begin

         {we must expect a term or unary operand}
         if not expectingTerm then begin
            Error(36);
            Skip;
            goto 1;
            end; {if}
         if token.kind = ident then

            {handle a complex operand}
            DoOperand
         else begin
            {handle a constant operand}
            new(sp);
            sp^.token := token;
            sp^.next := stack;
            sp^.left := nil;
            sp^.middle := nil;
            sp^.right := nil;
            stack := sp;
            if kind in [preprocessorExpression,arrayExpression] then
               if token.kind in [stringconst,doubleconst] then begin
                  if kind = arrayExpression then begin
                     op := opStack;
                     if token.kind = doubleconst then
                        if op <> nil then
                           if op^.token.kind = castoper then
                              if op^.casttype^.kind = scalarType then
                                 if op^.casttype^.baseType in [cgByte,cgUByte,
                                    cgWord,cgUWord,cgLong,cgULong] then
                                    goto 3;
                     while op <> nil do begin
                        if op^.token.kind = sizeofsy then
                           goto 3;
                        op := op^.next;
                        end; {while}
                     end; {if}
                  Error(41);
                  errorFound := true;
                  end; {if}
3:
            NextToken;
            ComplexTerm;
            end; {else}
         expectingTerm := false;        {the next thing should be an operation}
         end {else}
                                        {handle a closing parenthesis}
      else if (token.kind = rparench) and (parenCount > 0) then begin
         if expectingTerm then begin    {make sure it is in a legal spot}
            Error(37);
            Skip;
            goto 1;
            end; {if}
         while opStack^.token.kind <> lparench do
            Operation;                  {do pending operations}
         op := opStack;
         opStack := op^.next;
         dispose(op);
         parenCount := parenCount-1;
         NextToken;                     {skip the ')'}
         ComplexTerm;                   {handle subscripts, selection, etc.}
         end {else}
      else if token.kind = lparench then begin

         {handle open paren and type casts}
         if not expectingTerm then begin
            Error(38);
            Skip;
            goto 1;
            end; {if}
         NextToken;
         if token.kind in [unsignedsy,intsy,longsy,charsy,shortsy,floatsy,
            doublesy,compsy,extendedsy,voidsy,enumsy,structsy,unionsy,
            typedef,constsy,volatilesy,signedsy] then begin
            doingSizeof := false;
            if opStack <> nil then
               if opStack^.token.kind = sizeofsy then
                  doingSizeof := true;
            TypeName;
            if doingSizeof then begin

               {handle a sizeof operator}
               op := opStack;
               opStack := op^.next;
               dispose(op);
               new(sp);
               sp^.next := stack;
               sp^.left := nil;
               sp^.middle := nil;
               sp^.right := nil;
               sp^.token.kind := ulongconst;
               sp^.token.class := longConstant;
               sp^.token.lval := typeSpec^.size;
               with typeSpec^ do
                  if (size = 0) or ((kind = arrayType) and (elements = 0)) then
                     Error(49);
               sp^.next := stack;
               stack := sp;
               expectingTerm := false;
               end {if}
            else {doing a cast} begin

               {handle a type cast}
               new(op);                 {stack the cast operator}
               op^.left := nil;
               op^.middle := nil;
               op^.right := nil;
               op^.castType := typeSpec;
               op^.token.kind := castoper;
               op^.token.class := reservedWord;
               op^.next := opStack;
               opStack := op;
               end; {else}
            Match(rparench,12);
            end {if}
         else begin
            new(op);                    {record the '('}
            op^.next := opStack;
            op^.left := nil;
            op^.middle := nil;
            op^.right := nil;
            opStack := op;
            op^.token.kind := lparench;
            op^.token.class := reservedSymbol;
            parenCount := parenCount+1;
            end;
         end {else if}
      else begin                        {handle an operation...}
         if expectingTerm then          {convert unary operators to separate tokens}
            if token.kind in [asteriskch,minusch,plusch,andch] then
               case token.kind of
                  asteriskch: token.kind := uasterisk;
                  minusch   : token.kind := uminus;
                  andch     : token.kind := uand;
                  plusch    : begin
                              NextToken;
                              goto 2;
                              end;
                  otherwise : Error(57);
                  end; {case}
         if icp[token.kind] = notAnOperation then
            done := true                {end of expression found...}
         else if (token.kind in stopSym) and (parenCount = 0) then
            done := true
         else begin
            if not (kind in [normalExpression, autoInitializerExpression]) then
               if (token.kind in
                  [plusplusop,minusminusop,eqch,pluseqop,minuseqop,
                   opplusplus,opminusminus,
                   asteriskeqop,slasheqop,percenteqop,ltlteqop,
                   gtgteqop,caroteqop,bareqop,commach])
                  or ((kind = preprocessorExpression)
                      and (token.kind = sizeofsy))
                  or ((kind <> initializerExpression)
                      and (token.kind = uand)) then begin
                  Error(40);
                  errorFound := true;
                  end; {if}
            if token.kind in         {make sure we get what we want}
               [plusplusop,minusminusop,sizeofsy,tildech,excch,
                uasterisk,uminus,uand] then begin
               if not expectingTerm then begin
                  Error(38);
                  Skip;
                  goto 1;
                  end; {if}
               end {if}
            else begin
               if expectingTerm then begin
                  Error(37);
                  Skip;
                  goto 1;
                  end; {if}
               expectingTerm := true;
                                        {handle 2nd half of ternary operator}
               if token.kind = colonch then begin
                  done2 := false;       {do pending operations}
                  repeat
                     if opStack = nil then
                        done2 := true
                     else if opStack^.token.kind <> questionch then
                        Operation
                     else
                        done2 := true;
                  until done2;
                  if (opStack = nil) or
                     (opStack^.token.kind <> questionch) then begin
                     Error(39);
                     Skip;
                     goto 1;
                     end; {if}
                  op := opStack;
                  opStack := op^.next;
                  dispose(op);
                  end {if}
               else begin
        	  done2 := false;	{do operations with less precidence}
        	  repeat
                     if opStack = nil then
                	done2 := true
                     else if isp[opStack^.token.kind] >= icp[token.kind] then
                	Operation
                     else
                	done2 := true;
        	  until done2;
                  end; {else}
               end; {else}
            new(op);                    {record the operation}
            op^.next := opStack;
            op^.left := nil;
            op^.middle := nil;
            op^.right := nil;
            opStack := op;
            op^.token := token;
            NextToken;
            end; {else}
         end; {else}
2:
   until done;
   if parenCount > 0 then begin
      Error(12);
      errorFound := true;
      end {if}
   else begin
      while opStack <> nil do           {do pending operations}
         Operation;
                                        {there should be exactly one operand left}
      if (stack = nil) or (stack^.next <> nil) then begin
         Error(36);
         errorFound := true;
         end; {if}
      end; {else}
   end {if}
else begin                              {the start of an expression was not found}
   Error(35);
   if not (token.kind in stopSym) then
      NextToken;
   Skip;
   end; {else}
1:
if errorFound then begin
   while opStack <> nil do begin
      op := opStack;
      opStack := op^.next;
      dispose(op);
      end; {while}
   while stack <> nil do begin
      sp := stack;
      stack := sp^.next;
      DisposeTree(sp);
      end; {while}
   ExpressionTree := nil;
   end {if}
else
   ExpressionTree := stack;
end; {ExpressionTree}


procedure CompareToZero {op: pcodes};

{ Compare the result on tos to zero.                            }
{                                                               }
{ This procedure is used by the logical statements to compare   }
{ _any_ scalar result to zero, giving a boolean result.         }
{                                                               }
{ parameters:                                                   }
{    op - operation to use on the compare                       }

var
   bt: baseTypeEnum;                    {base type of loaded value}

begin {CompareToZero}
if expressionType^.kind in [pointerType,arrayType] then
   expressionType := uLongPtr;
if expressionType^.kind = scalarType then begin
   bt := UsualUnaryConversions;
   case bt of
      cgByte,cgUByte,cgWord,cgUWord:
         Gen1t(pc_ldc, 0, cgWord);
      cgLong,cgULong:
         GenLdcLong(0);
      cgReal,cgDouble,cgComp,cgExtended:
         GenLdcReal(0.0);
      otherwise:
         Error(47);
      end; {case}
   expressionType := wordPtr;
   Gen0t(op, bt);
   end {if}
else
   Error(47);
end; {CompareToZero}


procedure FreeTemp{labelNum, size: integer};

{ place a temporary label in the available label list           }
{                                                               }
{ parameters:                                                   }
{         labelNum - number of the label to free                }
{         size - size of the variable                           }
{                                                               }
{ variables:                                                    }
{         tempList - list of free labels                        }

var
   tl: tempPtr;                         {work pointer}

begin {FreeTemp}
new(tl);
tl^.next := tempList;
tl^.last := nil;
tl^.labelNum := labelNum;
tl^.size := size;
if tempList <> nil then
   tempList^.last := tl;
tempList := tl;
end; {FreeTemp}


function GetTemp{size: integer): integer};

{ find a temporary work variable                                }
{                                                               }
{ parameters:                                                   }
{         size - size of the variable                           }
{                                                               }
{ variables:                                                    }
{         tempList - list of free labels                        }
{                                                               }
{ Returns the label number.                                     }

label 1;

var
   lcodeGeneration: boolean;            {local copy of codeGeneration}
   ln: integer;                         {label number}
   tl: tempPtr;                         {work pointer}

begin {GetTemp}
{try to find a temp from the existing list}
tl := tempList;
while tl <> nil do begin
   if tl^.size = size then begin

      {found an old one - use it}
      if tl^.last = nil then
         tempList := tl^.next
      else
         tl^.last^.next := tl^.next;
      if tl^.next <> nil then
         tl^.next^.last := tl^.last;
      GetTemp := tl^.labelNum;
      goto 1;
      end; {if}
   tl := tl^.next;
   end; {while}

{none found - get a new one}
ln := GetLocalLabel;
GetTemp := ln;
lcodeGeneration := codeGeneration;
codeGeneration := true;
Gen2(dc_loc, ln, size);
codeGeneration := lCodeGeneration and (numErrors = 0);
1:
end; {GetTemp}


procedure LoadScalar (id: identPtr);

{ Load a scalar value.                                          }
{                                                               }
{ parameters:                                                   }
{         id - ident for value to load                          }

var
   tp: baseTypeEnum;                    {base type}

begin {LoadScalar}
if id^.itype^.kind = pointerType then
   tp := cgULong
else
   tp := id^.itype^.baseType;
case id^.storage of
   stackFrame, parameter:
      Gen2t(pc_lod, id^.lln, 0, tp);
   external, global, private:
      Gen1tName(pc_ldo, 0, tp, id^.name);
   otherwise: ;
   end; {case}
end; {LoadScalar}


procedure Cast(tp: typePtr);

{ Cast the current expression to the stated type                }
{                                                               }
{ parameters:                                                   }
{         tp - type to cast to                                  }
{                                                               }
{ inputs:                                                       }
{         expressionType - type of the expression to cast       }
{                                                               }
{ outputs:                                                      }
{         expressionType - set to result type                   }

var
   et,rt: baseTypeEnum;                 {work variables}

begin {Cast}
if (tp^.kind = scalarType) and (expressionType^.kind = scalarType) then begin
   rt := tp^.baseType;
   et := expressionType^.baseType;
   if rt <> et then
      if et <> cgVoid then
         Gen2(pc_cnv, ord(et), ord(rt))
      else
         Error(40);
   end {if}
else if (tp^.kind = enumType) and (expressionType^.kind = scalarType) then begin
   if expressionType^.baseType <> cgVoid then begin
      rt := cgWord;
      et := Unary(expressionType^.baseType);
      if rt <> et then
         Gen2(pc_cnv, ord(et), ord(rt));
      end {if}
   else
      Error(40);
   end {if}
else if (tp^.kind = scalarType) and (expressionType^.kind = enumType) then begin
   rt := Unary(tp^.baseType);
   et := cgWord;
   if rt <> et then
      Gen2(pc_cnv, ord(et), ord(rt));
   end {if}
else if tp^.kind = pointerType then begin
   case expressionType^.kind of

      scalarType:
         if expressionType^.baseType in
            [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong] then
            Gen2(pc_cnv, ord(Unary(expressionType^.baseType)),
               ord(cgULong))
         else if doDispose then
            Error(40);

      arrayType,pointerType: ;

      functionType,enumConst,enumType,definedType,structType,unionType:
         if doDispose then
            Error(40);

      otherwise: Error(57);

      end; {case}
   end {else if}
else if expressionType^.kind in [pointerType,arrayType] then begin
   case tp^.kind of  

      scalarType:
         if tp^.baseType in
            [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong] then
            Gen2(pc_cnv, ord(cgULong),
               ord(Unary(tp^.baseType)))
         else if tp^.baseType = cgVoid then
            Gen0t(pc_pop, UsualUnaryConversions)
         else
            Error(40);

      otherwise:
         Error(40);
      end; {case}
   end {else if}
else if expressionType^.kind in [structType,unionType] then begin
   if tp^.kind = scalarType then
      if tp^.baseType = cgVoid then
         Gen0t(pc_pop, UsualUnaryConversions)
      else Error(40)
   else Error(40);
   end {else if}
else
   Error(40);
expressionType := tp;
end; {Cast}


procedure DoSelection {lType: typePtr; tree: tokenPtr; var size: longint};

{ Find the displacement & type for a selection operation     }
{                                                            }
{ parameters:                                                }
{         lType - structure/union type                       }
{         tree - right-hand tree                             }
{         size - disp into the structure/union               }
{                                                            }
{ returned in non-local variables:                           }
{         bitDisp - displacement to bit field                }
{         bitSize - size of bit field                        }
{         unsigned - is the bit field unsigned?              }
{         isBitField - is the field a bit field?             }
{                                                            }
{ varaibles:                                                 }
{         expressionType - set to the type of the field      }

label 1;

var
   ip: identPtr;                        {for scanning for the field}

begin {DoSelection}
expressionType := wordPtr;              {set defaults in case there is an error}
size := 0;
if tree^.token.class = identifier then begin
   while lType^.kind = definedType do
      lType := lType^.dType;
   if lType^.kind in [structType,unionType] then begin
      ip := lType^.fieldList;           {find a matching field}
      while ip <> nil do begin
         if ip^.name^ = tree^.token.name^ then begin
            if ip^.isForwardDeclared then 
               ResolveForwardReference(ip);
            size := ip^.disp;           {match found - record parameters}
            expressionType := ip^.itype;
            bitDisp := ip^.bitDisp;
            bitSize := ip^.bitSize;
            isBitField := (bitSize+bitDisp) <> 0;
            unsigned := ip^.itype^.baseType in [cgUByte,cgUWord,cgULong];
            goto 1;
            end; {if}
         ip := ip^.next;
         end; {while}
      Error(81);
      end {if}
   else
      Error(80);
   end; {if}
1:
end; {DoSelection}


procedure L_Value(tree: tokenPtr);

{ Check for an l-value                                          }
{                                                               }
{ parameters:                                                   }
{         tree - expression tree to check                       }

var
   kind: tokenEnum;                     {for efficiency}

begin {L_Value}
kind := tree^.token.kind;

{A variable identifier is an l-value unless it is a function or }
{non-parameter array                                            }
if kind = ident then begin
   if tree^.id^.itype^.kind = arrayType then begin
      if tree^.id^.storage <> parameter then
         if doDispose then              {prevent spurious errors}
            Error(78);
      end {if}
   else if tree^.id^.itype^.kind in
      [functionType,enumConst,enumType] then
      if doDispose then                 {prevent spurious errors}
         Error(78);
   end {if}

{e.field is an l-value if and only if e is an l-value}
else if kind = dotch then
   L_Value(tree^.left)

{Bypass cast operators                                          }
{following test removed to flag bug for:			}
{ int *p; long l;						}
{ (long) p = l;							}
{else if kind = castoper then
   L_Value(tree^.left)}

{The result of an array subscript (a[i]), indirect selection,   }
{or the indirection operator all show up as the uasterisk       }
{operator at this point.  All are l-values, but nothing else    }
{not already allowed is an l-value.                             }
else if kind <> uasterisk then
   if doDispose then                    {prevent spurious errors}
      Error(78);
end; {L_Value}


procedure ChangePointer (op: pcodes; size: longint; tp: baseTypeEnum);

{ Add or subtract an integer to a pointer			}
{                                                               }
{ The stack has a pointer and an integer (integer on TOS).      }
{ The integer is removed, multiplied by size, and either        }
{ added to or subtracted from the pointer; the result           }
{ replaces the pointer on the stack                             }
{                                                               }
{ parameters:                                                   }
{    op - operation (pc_adl or pc_sbl)                          }
{    size - size of one pointer element                         }
{    tp - type of the integer operand                           }

begin {ChangePointer}
if size = 0 then
   Error(122);
case tp of
   cgByte,cgUByte,cgWord,cgUWord: begin
      if (size = long(size).lsw) and (op = pc_adl)
         and smallMemoryModel and (tp in [cgUByte,cgUWord]) then begin
         if size <> 1 then begin
            Gen1t(pc_ldc, long(size).lsw, cgWord);
            Gen0(pc_umi);
            end; {if}
         Gen0t(pc_ixa, cgUWord);
         end {if}
      else if smallMemoryModel and (size = long(size).lsw) then begin
         if size <> 1 then begin
            Gen1t(pc_ldc, long(size).lsw, cgWord);
            Gen0(pc_umi);
            end; {if}
         Gen2(pc_cnv, ord(tp), ord(cgLong));
         Gen0(op);
         end {else if}
      else begin
         Gen2(pc_cnv, ord(tp), ord(cgLong));
         if size <> 1 then begin
            GenLdcLong(size);
            Gen0(pc_mpl);
            end; {if}
         Gen0(op);
         end;
      end;
   cgLong,cgULong: begin
      if size <> 1 then begin
         GenLdcLong(size);
         if tp = cgLong then
            Gen0(pc_mpl)
         else
            Gen0(pc_uml);
         end; {if}
      Gen0(op);
      end;
   otherwise:
      Error(66);
   end; {case}
end; {ChangePointer}


procedure GenerateCode {tree: tokenPtr};

{ generate code from a fully formed expression tree              }
{                                                                }
{ parameters:                                                    }
{     tree - top of the expression tree to generate code from    }
{                                                                }
{ variables:                                                     }
{     expressionType - result type of the expression             }

var
   doingScalar: boolean;                {temp; for assignment operators}
   et: baseTypeEnum;                    {temp storage for a base type}
   i: integer;                          {loop variable}
   isString: boolean;                   {was the ? : a string?}
   lType: typePtr;                      {type of operands}
   kind: typeKind;                      {temp type kind}
   size: longint;                       {size of an array element}
   t1: integer;                         {temporary work space label number}
   tlastwasconst: boolean;              {temp lastwasconst}
   tlastconst: longint;                 {temp lastconst}
   tp: tokenPtr;                        {work pointer}
   tType: typePtr;                      {temp type of operand}

   lbitDisp,lbitSize: integer;          {for temp storage}
   lisBitField: boolean;


   function ExpressionKind (tree: tokenPtr): typeKind;

   { returns the type of an expression                           }
   {                                                             }
   { This subroutine is used to see if + and - operarions        }
   { should do pointer addition.                                 }
   {                                                             }
   { parameters:                                                 }
   {     tree - top of the expression tree to check              }

   var
      ldoDispose: boolean;              {local copy of doDispose}
      lcodeGeneration: boolean;         {local copy of codeGeneration}
      lexpressionType: typePtr;         {local copy of expressionType}

   begin {ExpressionKind}
   ldoDispose := doDispose;             {inhibit disposing of the tree}
   doDispose := false;
   lcodeGeneration := codeGeneration;   {inhibit code generation}
   codeGeneration := false;
   lexpressionType := expressionType;   {save the expression type}

   GenerateCode(tree);                  {get the type}
   ExpressionKind := expressionType^.kind;

   doDispose := ldoDispose;             {resore the volitile variables}
   codeGeneration := lCodeGeneration and (numErrors = 0);
   expressionType := lexpressionType;
   end; {ExpressionKind}


   procedure LoadAddress (tree: tokenPtr);

   { load the address of an l-value                              }
   {                                                             }
   { parameters:                                                 }
   {     tree - top of the expression tree to load the           }
   {         address of                                          }
   {                                                             }
   { variables:                                                  }
   {     expressionType - result type of the expression          }
   {     isBitField - this variable is set to false so that      }
   {         it can be used to see if DoSelection was called     }
   {         and located a bit field                             }

   label 1;

   var
      eType: typePtr;                   {work pointer}
      i: integer;                       {loop variable}
      size: longint;                    {disp in record}
      tname: stringPtr;                 {temp name pointer}

   begin {LoadAddress}
   isBitField := false;
   if tree^.token.kind = ident then begin

      {load the address of an identifier}
      with tree^.id^ do begin
         tname := name;
         if itype^.kind = functionType then begin
            if itype^.isPascal then begin
               tname := pointer(Malloc(length(name^)+1));
               CopyString(pointer(tname), pointer(name));
               for i := 1 to length(tname^) do
                  if tname^[i] in ['a'..'z'] then
                     tname^[i] := chr(ord(tname^[i]) & $5F);
               end; {if}
            end; {if}
         case storage of
            stackFrame:     Gen2(pc_lda, lln, 0);
            parameter:      if itype^.kind = arrayType then
                               Gen2t(pc_lod, pln, 0, cgULong)
                            else
                               Gen2(pc_lda, pln, 0);
            external,
            global,
            private:        Gen1Name(pc_lao, 0, tname);
            otherwise: ;
            end; {case}
         eType := pointer(Malloc(sizeof(typeRecord)));
         eType^.size := cgLongSize;
         eType^.saveDisp := 0;
         eType^.isConstant := false;
         eType^.kind := pointerType;
         eType^.pType := iType;
         expressionType := eType;
         end; {with}
      end {if}
   else if tree^.token.kind = uasterisk then begin

      {load the address of the item pointed to by the pointer}
      GenerateCode(tree^.left);
      isBitField := false;
      end {else if}
   else if tree^.token.kind = dotch then begin

      {load the address of a field of a record}
      LoadAddress(tree^.left);
      eType := expressionType;
      if eType^.kind in [arrayType,pointerType] then begin
         if eType^.kind = arrayType then
            eType := eType^.aType
         else if eType^.kind = pointerType then
            eType := eType^.pType;
         DoSelection(eType, tree^.right, size);
         if size <> 0 then
            if size & $00007FFF = size then
               Gen1t(pc_inc, long(size).lsw, cgULong)
            else begin
               GenLdcLong(size);
               Gen0(pc_adl);
               end; {else}
         eType := pointer(Malloc(sizeof(typeRecord)));
         eType^.size := cgLongSize;
         eType^.saveDisp := 0;
         eType^.isConstant := false;
         eType^.kind := pointerType;
         eType^.pType := expressionType;
         expressionType := eType;
         end {if}
      else
         Error(79);
      end {else if}
   else if tree^.token.kind = castoper then begin

      {load the address of a field of a record}
      LoadAddress(tree^.left);
      expressionType := tree^.castType;
      if expressionType^.kind <> arrayType then begin
         eType := pointer(Malloc(sizeof(typeRecord)));
         eType^.size := cgLongSize;
         eType^.saveDisp := 0;
         eType^.isConstant := false;
         eType^.kind := pointerType;
         eType^.pType := expressionType;
         expressionType := eType;
         end; {if}
      end {else if}

   else if ExpressionKind(tree) in [arrayType,pointerType] then
      GenerateCode(tree)
   else
      if doDispose then                 {prevent spurious errors}
         Error(78);
1:
   end; {LoadAddress}


   procedure DoIncDec (tree: tokenPtr; pc_l, pc_g, pc_i: pcodes);

   { do ++ and --                                               }
   {                                                            }
   { parameters:                                                }
   {     tree - tree to generate the instruction for            }
   {     pc_l - op code for a local ++ or --                    }
   {     pc_g - op code for a global ++ or --                   }
   {     pc_i - op code for an indirect ++ or --                }

   label 1;

   var
      baseType: baseTypeEnum;           {type of operation}
      lSize: longint;                   {number to inc or dec by}
      iSize: integer;                   {number to inc or dec by}
      tp: baseTypeEnum;                 {type of operand}


      procedure IncOrDec (inc: boolean);

      { Increment or decrement a number on TOS                  }
      {                                                         }
      { parameters:                                             }
      {      inc - increment the number?                        }

      begin {IncOrDec}
      case expressionType^.kind of

         scalarType:
            case tp of

               cgByte,cgUByte,cgWord,cgUWord: begin
                  Gen1t(pc_ldc, 1, cgWord);
                  if inc then
                     Gen0(pc_adi)
                  else
                     Gen0(pc_sbi);
                  end;

               cgLong,cgULong: begin
                  GenLdcLong(1);
                  if inc then
                     Gen0(pc_adl)
                  else
                     Gen0(pc_sbl);
                  end;

               cgReal,cgDouble,cgComp,cgExtended: begin
                  GenLdcReal(1.0);
                  if inc then
                     Gen0(pc_adr)
                  else
                     Gen0(pc_sbr);
                  end;

               otherwise: Error(57);

               end; {case}

         pointerType,arrayType: begin
            GenldcLong(expressionType^.pType^.size);
            if inc then
               Gen0(pc_adl)
            else
               Gen0(pc_sbl);
            end;

         otherwise: ;

         end; {case}
      end; {IncOrDec}


   begin {DoIncDec}
   L_Value(tree);
   with tree^.id^ do
      if (tree^.token.kind = ident)
         and ((iType^.kind in [scalarType,pointerType])
         or ((iType^.kind = arrayType) and (storage = parameter))) then begin

         {check for ++ or -- of a constant}
         if iType^.isConstant then
            Error(93);

         {do an efficient ++ or -- on a named location}
         if iType^.kind = scalarType then begin
            iSize := 1;
            baseType := iType^.baseType;
            if baseType in [cgReal,cgDouble,cgComp,cgExtended] then begin

               {do real inc or dec}
               LoadScalar(tree^.id);    {load the value}
               tp := baseType;
               expressionType := iType;
               IncOrDec(pc_l in [pc_lli,pc_lil]); {do the ++ or --}
               case storage of          {save the result}
                  stackFrame, parameter:
                     Gen2t(pc_cop, lln, 0, baseType);
                  external, global, private:
                     Gen1tName(pc_cpo, 0, baseType, name);
                  otherwise: ;
                  end; {case}
                                        {correct the value for postfix ops}
               if pc_l in [pc_lli,pc_lld] then
                  IncOrDec(pc_l = pc_lld);
               expressionType := doublePtr;
               goto 1;
               end; {if}
            end {if}
         else {if iType^.kind = pointerType then} begin
            lSize := iType^.pType^.size;
            if lSize = 0 then
               Error(122);
            if long(lSize).msw <> 0 then begin

               {handle inc/dec of >64K}
               LoadScalar(tree^.id);
               GenLdcLong(lSize);
               if pc_l in [pc_lli,pc_lil] then
                  Gen0(pc_adl)
               else
                  Gen0(pc_sbl);
               with tree^.left^.id^ do
                  case storage of
                     stackFrame, parameter:
                        Gen2t(pc_cop, lln, 0, cgULong);
                     external, global, private:
                        Gen1tName(pc_cpo, 0, cgULong, name);
                     otherwise: ;
                     end; {case}
               if pc_l in [pc_lli,pc_lld] then begin
                  GenLdcLong(lSize);
                  if pc_l = pc_lld then
                     Gen0(pc_adl)
                  else
                     Gen0(pc_sbl);
                  end; {if}
               goto 1;
               end; {if}
            baseType := cgULong;
            iSize := long(lSize).lsw;
            end; {else}
         case storage of
            stackFrame, parameter:
               Gen2t(pc_l, lln, iSize, baseType);
            external, global, private:
               Gen2tName(pc_g, iSize, 0, baseType, name);
            otherwise: ;
            end; {case}
         expressionType := itype;
         end {if}
      else begin

         {do an indirect ++ or --}
         LoadAddress(tree);             {get the address to save to}
         if expressionType^.kind = arrayType then
            expressionType := expressionType^.aType
         else if expressionType^.kind = pointerType then
            expressionType := expressionType^.pType;
         if expressionType^.kind = scalarType then
            if expressionType^.baseType in [cgByte,cgUByte,cgWord,cgUWord] then
               tp := expressionType^.baseType
            else
               tp := UsualUnaryConversions
         else
            tp := UsualUnaryConversions;
         if tp in [cgByte,cgUByte,cgWord,cgUword] then
            Gen0t(pc_i, tp)             {do indirect inc/dec}
         else begin
            t1 := GetTemp(cgLongSize);
            Gen2t(pc_str, t1, 0, cgULong);
            Gen2t(pc_lod, t1, 0, cgULong);
            Gen2t(pc_lod, t1, 0, cgULong);
            FreeTemp(t1, cgLongSize);
            Gen1t(pc_ind, 0, tp);       {load the value}
            IncOrDec(pc_l in [pc_lli,pc_lil]); {do the ++ or --}
            if isBitField then          {copy the value}
               if bitDisp+bitSize > 16 then begin
                  Gen2t(pc_cbf, bitDisp, bitSize, cgLong);
                  Gen0t(pc_bno, cgLong);
                  end {if}
               else begin
                  Gen2t(pc_cbf, bitDisp, bitSize, cgWord);
                  Gen0t(pc_bno, cgWord);
                  end {else}
            else begin
               Gen0t(pc_cpi, tp);
               Gen0t(pc_bno, tp);
               end; {else}
            if pc_l in [pc_lli,pc_lld] then {correct the value for postfix ops}
               IncOrDec(pc_l = pc_lld);
            end; {else}
         end; {else}
1:
   end; {DoIncDec}


   procedure FunctionCall (tree: tokenPtr);

   { generate the actual function call                          }

   var
      fName: stringPtr;                 {uppercase file name}
      fntype: typePtr;                  {temp function type}
      ftree: tokenPtr;                  {function address tree}
      ftype: typePtr;                   {function type}
      i: integer;                       {loop variable}
      indirect: boolean;                {is this an indirect call?}
      ldoDispose: boolean;              {local copy of doDispose}
      lcodeGeneration: boolean;         {local copy of codeGeneration}


      procedure FunctionParms (parms: tokenPtr; fType: typePtr);

      { Generate a function call.                               }
      {                                                         }
      { parameters:                                             }
      {    parms - parameter list                               }
      {    fType - function type                                }

      var
         kind: typeKind;                {for expression kinds}
         ldoDispose: boolean;           {local copy of doDispose}
         lnumErrors: integer;		{number of errors before type check}
         numParms: integer;             {# of parameters generated}
         parameters: parameterPtr;      {next prototyped parameter}
         pCount: integer;               {# of parameters prototyped}
         prototype: boolean;            {is the function prototyped?}
         tp: tokenPtr;                  {work pointers}
         fp, tfp: fmtArgPtr;
         fmt: fmt_type;


         procedure Reverse;

         { Reverse the parameter list                           }

         var
            p1,p2,p3: tokenPtr;         {work pointers}

         begin {Reverse}
         p3 := parms;                   {remove the last entry}
         p1 := parms;
         p2 := nil;
         while p3^.right <> nil do begin
            p2 := p3;
            p3 := p3^.right;
            end; {while}
         if p2 <> nil then
            p2^.right := nil
         else
            p1 := nil;
         while p1 <> nil do begin       {reverse the remaining parms}
            p2 := p1;
            p1 := p1^.right;
            p2^.right := p3;
            p3 := p2;
            end; {while}
         parms := p3;
         end; {Reverse}


      begin {FunctionParms}
      {check the validity of the parameter list}
      if ftype^.isPascal then           {reverse parms for pascal calls}
         Reverse;
      tp := parms;                      {set up to check types}
      prototype := ftype^.prototyped;
      parameters := ftype^.parameterList;
      pCount := 1;
      fmt := fmt_none;
      fp := nil;

      if ((lint & lintPrintf) <> 0) and fType^.varargs and not indirect then
        fmt := FormatClassify(ftree^.id^.name^);

      while parameters <> nil do begin  {count the prototypes}
         pCount := pCount+1;
         parameters := parameters^.next;
         end; {while}
      parameters := ftype^.parameterList;
      if prototype then begin           {check for wrong # of parms}
         while tp <> nil do begin       {count the parms}
            pCount := pCount-1;
            tp := tp^.right;
            end; {while}
         tp := parms;
         if (pCount > 0) or ((pCount <> 0) and not ftype^.varargs) then
            Error(85);
         end; {if}

        tp := parms;

      {generate the parameters}
      numParms := 0;
      lDoDispose := doDispose;
      doDispose := false;
      while tp <> nil do begin
         if tp^.middle <> nil then begin
            lnumErrors := numErrors;
            kind := ExpressionKind(tp^.middle);
            if numErrors = lnumErrors then
               if kind in [structType,unionType] then begin
        	  GenerateCode(tp^.middle);
        	  if expressionType^.size & $FFFF8000 <> 0 then
                     Error(61);
        	  Gen1t(pc_ldc, long(expressionType^.size).lsw, cgWord);
        	  Gen0(pc_psh);
        	  end {else if}
               else
        	  GenerateCode(tp^.middle);
            if fmt <> fmt_none then begin
                new(tfp);
                tfp^.next := fp;
                tfp^.tk := tp^.middle;
                tfp^.ty := expressionType;
                fp := tfp;
            end;
            if prototype then begin
               if pCount = 0 then begin
                  if parameters <> nil then begin
                     AssignmentConversion(parameters^.parameterType,
                        expressionType, lastWasConst, lastConst, true, false);
                     end; {if}
                  parameters := parameters^.next;
                  end {if}
               else
                  pCount := pCount+1;
               end; {if}
            Gen0t(pc_stk, UsualUnaryConversions);
            if numParms <> 0 then
               Gen0t(pc_bno, UsualUnaryConversions);
            numParms := numParms+1;
            end; {if}
         tp := tp^.right;
         end; {while}

      if fmt <> fmt_none then FormatCheck(fmt, fp);


      doDispose := lDoDispose;
      if numParms = 0 then
         Gen0(pc_nop);

      if ftype^.isPascal then		{restore parm order}
         Reverse;

      if doDispose then begin		{dispose of leaf nodes}
         DisposeTree(parms^.middle);
         DisposeTree(parms^.right);
         end; {if}
      end; {FunctionParms}


   begin {FunctionCall}
   {find the type of the function}
   indirect := true;                    {assume an indirect call}
   ftree := tree^.left;                 {get the function tree}
   if ftree^.token.kind = ident then    {check for direct calls}
      if ftree^.id^.itype^.kind = functionType then begin
         indirect := false;
         fType := ftree^.id^.itype;     {get the function type}
         end; {if}
   if indirect then begin               {get type for indirect call}
      ldoDispose := doDispose;
      doDispose := false;
      lcodeGeneration := codeGeneration;
      codeGeneration := false;
      GenerateCode(ftree);
      doDispose := ldoDispose;
      codeGeneration := lCodeGeneration and (numErrors = 0);
      ftype := expressionType;
      while ftype^.kind in [pointerType,arrayType] do
         ftype := ftype^.ptype;
      end; {if}

   {make sure the identifier is really a function}
   if ftype^.kind <> functionType then
         Error(114)
   else begin

      {generate function parameters}
      FunctionParms (tree, fType);                    

      {generate the function call}
      expressionType := ftype^.fType;
      if expressionType^.kind in [structType,unionType] then
	 expressionType := uLongPtr;
      if (ftype^.toolNum = 0) and (ftype^.dispatcher = 0) then begin
	 if indirect then begin
            fntype := expressionType;
            GenerateCode(ftree);
            expressionType := fntype;
            Gen1t(pc_cui, ord(fType^.varargs and strictVararg),
               UsualUnaryConversions);
            end {if}
	 else begin
            fname := ftree^.id^.name;
            if ftype^.isPascal then begin
               fname := pointer(Malloc(length(fname^)+1));
               CopyString(pointer(fname), pointer(ftree^.id^.name));
               for i := 1 to length(fname^) do
        	  if fName^[i] in ['a'..'z'] then
                     fName^[i] := chr(ord(fName^[i]) & $5F);
               end; {if}
            Gen1tName(pc_cup, ord(fType^.varargs and strictVararg),
               UsualUnaryConversions, fname);
            end; {else}
         if fType^.varargs then
            hasVarargsCall := true;
	 end {if}
      else
	 GenTool(pc_tl1, ftype^.toolNum, long(ftype^.ftype^.size).lsw,
            ftype^.dispatcher);
      expressionType := ftype^.fType;
      lastWasConst := false;
      end; {else}
   end; {FunctionCall}      


   procedure CompareCompatible (var t1,t2: typePtr);

   { Make sure that it is legal to compare t1 to t2             }

   begin {CompareCompatible}
   if (t1^.kind = functionType) or (t2^.kind = functionType) then begin
      if not CompTypes(t1, t2) then
         Error(47);
      end {if}
   else if t1^.kind in [pointerType,arrayType] then begin
      if t2^.kind in [pointerType,arrayType] then begin
         if (t1^.ptype = voidPtr) or (t2^.ptype = voidPtr) then
         else if t1^.kind = t2^.kind then begin
            if not CompTypes(t1, t2) then
               Error(47);
            end {if}
         else if not CompTypes(t1^.ptype, t2^.ptype) then
            Error(47);
         t2 := ulongPtr;
         end {if}
      else if (not lastwasconst) or (lastconst <> 0) then
         Error(47);
      t1 := ulongPtr;
      end {if}
   else if expressionType^.kind in [pointerType,arrayType] then begin
      if (not tlastwasconst) or (tlastconst <> 0) then
         Error(47);
      t2 := ulongPtr;
      end; {else if}
   end; {CompareCompatible}


begin {GenerateCode}
lastwasconst := false;
case tree^.token.kind of

   parameterOper:
      FunctionCall(tree);

   ident: begin
      case tree^.id^.itype^.kind of                                        

         scalarType: begin
            LoadScalar(tree^.id);
            expressionType := tree^.id^.itype;
            end;

         pointerType: begin
            LoadScalar(tree^.id);                          
            expressionType := tree^.id^.itype;
            end;


         arrayType: begin
            LoadAddress(tree);                             
            expressionType := expressionType^.ptype;
            end;

         functionType:
            LoadAddress(tree);                             

         structType, unionType: begin
            LoadAddress(tree);                             
            if expressionType^.kind = pointerType then
               expressionType := expressionType^.ptype;
            end;

         enumConst: begin
            Gen1t(pc_ldc, tree^.id^.itype^.eval, cgWord);  
            expressionType := wordPtr;
            end;

         otherwise: ;

         end; {case}
      end;

   intConst,uintConst: begin
      Gen1t(pc_ldc, tree^.token.ival, cgWord);
      lastwasconst := true;
      lastconst := tree^.token.ival;
      if tree^.token.kind = intConst then
         expressionType := wordPtr
      else
         expressionType := uwordPtr;
      end; {case intConst}

   longConst,ulongConst: begin
      GenLdcLong(tree^.token.lval);
      if tree^.token.kind = longConst then
         expressionType := longPtr
      else
         expressionType := ulongPtr;
      lastwasconst := true;
      lastconst := tree^.token.lval;
      end; {case longConst}

   doubleConst: begin
      GenLdcReal(tree^.token.rval);
      expressionType := doublePtr;
      end; {case doubleConst}

   stringConst: begin
      GenS(pc_lca, tree^.token.sval);
      expressionType := stringTypePtr;
      end; {case stringConst}

   eqch: begin                          {=}
      L_Value(tree^.left);
      with tree^.left^ do begin
         if token.kind = ident then
            kind := id^.itype^.kind
         else
            kind := definedType;
         if kind = arrayType then
            if id^.storage = parameter then
               kind := pointerType;
         if (token.kind = ident)
            and (kind in [scalarType,pointerType]) then begin
            GenerateCode(tree^.right);
            with tree^.left^.id^ do begin
               if itype^.kind in [pointerType,arrayType] then
                  lType := uLongPtr
               else
                  lType := itype;
               AssignmentConversion(itype, expressionType, lastWasConst,
                  lastConst, true, true);
               case storage of
                  stackFrame, parameter:
                     Gen2t(pc_cop, lln, 0, lType^.baseType);
                  external, global, private:
                     Gen1tName(pc_cpo, 0, lType^.baseType, name);
                  otherwise: ;
                  end; {case}
               end; {with}
            end {if}
         else begin
            LoadAddress(tree^.left);
            lType := expressionType;
            lisBitField := isBitField;
            lbitDisp := bitDisp;
            lbitSize := bitSize;
            if lType^.kind = arrayType then
               lType := lType^.aType
            else if lType^.kind = pointerType then
               lType := lType^.pType;
            GenerateCode(tree^.right);
            AssignmentConversion(lType, expressionType, lastWasConst,
               lastConst, true, true);
            case lType^.kind of
               scalarType:
                  if lisBitField then
                     Gen2t(pc_cbf, lbitDisp, lbitSize, lType^.baseType)
                  else
                     Gen0t(pc_cpi, lType^.baseType);

               pointerType:
                  Gen0t(pc_cpi, cgULong);

               structType,unionType:
                  Gen2(pc_mov, long(lType^.size).msw, long(lType^.size).lsw);

               otherwise:
                  Error(47);

               end; {case}
            end; {else}
         end; {with}
      end; {=}

   pluseqop,                            {+=}
   minuseqop,                           {-=}
   asteriskeqop,                        {*=}
   slasheqop,                           {/=}
   percenteqop,                         {%=}
   ltlteqop,                            {<<=}
   gtgteqop,                            {>>=}
   andeqop,                             {&=}
   caroteqop,                           {^=}
   bareqop: with tree^.left^ do         {|=}
      begin
      L_Value(tree^.left);
      if (token.kind = ident)
         and ((id^.itype^.kind in [scalarType,pointerType])
            or ((id^.itype^.kind = arrayType) and (id^.storage = parameter))) then begin
         doingScalar := true;
         LoadScalar(id);
         lType := id^.itype;
         t1 := 0;
         end {if}
      else begin
         doingScalar := false;
         LoadAddress(tree^.left);
         lisBitField := isBitField;
         lbitDisp := bitDisp;
         lbitSize := bitSize;
         t1 := GetTemp(cgLongSize);
         Gen2t(pc_str, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         lType := expressionType^.pType;
         if isBitField then begin
            if unsigned then
               Gen2t(pc_lbu, bitDisp, bitSize, lType^.baseType)
            else
               Gen2t(pc_lbf, bitDisp, bitSize, lType^.baseType);
            end {if}
         else if lType^.kind = pointerType then
            Gen1t(pc_ind, 0, cgULong)
         else
            Gen1t(pc_ind, 0, lType^.baseType);
         end; {else}
      if lType^.isConstant then
         Error(93);
      if doingScalar 
         and (ltype^.kind = arrayType) and (id^.storage = parameter) then
         kind := pointerType
      else
         kind := lType^.kind;
      GenerateCode(tree^.right);
      if tree^.token.kind in [gtgteqop,ltlteqop] then
         if kind = scalarType then
            if expressionType^.kind = scalarType then begin
               et := UsualUnaryConversions;
               if et <> Unary(ltype^.baseType) then begin
                  Gen2(pc_cnv, et, ord(Unary(ltype^.baseType)));
                  expressionType := lType;
                  end; {if}
               end; {if}
      if kind <> pointerType then
         et := UsualBinaryConversions(lType)
      else
         et := ccPointer;
      case tree^.token.kind of

         pluseqop:
            if kind = pointerType then begin
               ChangePointer(pc_adl, lType^.pType^.size, UsualUnaryConversions);
               expressionType := lType;
               end
            else if et in [cgWord,cgUWord] then
               Gen0(pc_adi)
            else if et in [cgLong,cgULong] then
               Gen0(pc_adl)
            else if et = cgExtended then
               Gen0(pc_adr)
            else
               Error(66);

         minuseqop:
            if kind = pointerType then begin
               ChangePointer(pc_sbl, lType^.pType^.size, UsualUnaryConversions);
               expressionType := lType;
               end
            else if et in [cgWord,cgUWord] then
               Gen0(pc_sbi)
            else if et in [cgLong,cgULong] then
               Gen0(pc_sbl)
            else if et = cgExtended then
               Gen0(pc_sbr)
            else
               Error(66);

         asteriskeqop:
            if et = cgWord then
               Gen0(pc_mpi)
            else if et = cgUWord then
               Gen0(pc_umi)
            else if et = cgLong then
               Gen0(pc_mpl)
            else if et = cgULong then
               Gen0(pc_uml)
            else if et = cgExtended then
               Gen0(pc_mpr)
            else
               Error(66);

         slasheqop:
            if et = cgWord then
               Gen0(pc_dvi)
            else if et = cgUWord then
               Gen0(pc_udi)
            else if et = cgLong then
               Gen0(pc_dvl)
            else if et = cgULong then
               Gen0(pc_udl)
            else if et = cgExtended then
               Gen0(pc_dvr)
            else
               Error(66);

         percenteqop:
            if et = cgWord then
               Gen0(pc_mod)
            else if et = cgUWord then
               Gen0(pc_uim)
            else if et = cgLong then
               Gen0(pc_mdl)
            else if et = cgULong then
               Gen0(pc_ulm)
            else
               Error(66);

         ltlteqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_shl)
            else if et in [cgLong,cgULong] then
               Gen0(pc_sll)
            else
               Error(66);

         gtgteqop:
            if et = cgWord then
               Gen0(pc_shr)
            else if et = cgUWord then
               Gen0(pc_usr)
            else if et = cgLong then
               Gen0(pc_slr)
            else if et = cgULong then
               Gen0(pc_vsr)
            else
               Error(66);

         andeqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bnd)
            else if et in [cgLong,cgULong] then
               Gen0(pc_bal)
            else
               Error(66);

         caroteqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bxr)
            else if et in [cgLong,cgULong] then
               Gen0(pc_blx)
            else
               Error(66);

         bareqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bor)
            else if et in [cgLong,cgULong] then
               Gen0(pc_blr)
            else
               Error(66);

         otherwise: Error(57);
         end; {case}
      AssignmentConversion(lType,expressionType,false,0,true,true);
      if doingScalar then begin
         if kind = pointerType then
            lType := uLongPtr;
         case id^.storage of
            stackFrame, parameter:
               Gen2t(pc_cop, id^.lln, 0, lType^.baseType);
            external, global, private:
               Gen1tName(pc_cpo, 0, lType^.baseType, id^.name);
            otherwise: ;
            end; {case}
         end {if}
      else begin
         if lisBitField then
            Gen2t(pc_cbf, lbitDisp, lbitSize, lType^.baseType)
         else begin
            if ltype^.kind in [pointerType,arrayType] then
               lType := uLongPtr;
            Gen0t(pc_cpi, lType^.baseType);
            end; {else}
         Gen0t(pc_bno, lType^.baseType);
         end; {else}
      if t1 <> 0 then
         FreeTemp(t1, cgLongSize);
      end; {with}

   commach: begin                       {,}
      GenerateCode(tree^.left);
      if expressionType^.baseType <> cgVoid then
         Gen0t(pc_pop, UsualUnaryConversions);
      GenerateCode(tree^.right);
      Gen0t(pc_bno, UsualUnaryConversions);
      {result type is already in expressionType}
      end; {case commach}

   barbarop: begin                      {||}
      GenerateCode(tree^.left);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else if UsualUnaryConversions = cgExtended then begin
         GenLdcReal(0.0);
         Gen0t(pc_neq, cgExtended);
         expressionType := wordPtr;
         end; {if}
      lType := expressionType;
      GenerateCode(tree^.right);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else if UsualUnaryConversions = cgExtended then begin
         GenLdcReal(0.0);
         Gen0t(pc_neq, cgExtended);
         expressionType := wordPtr;
         end; {if}
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_ior);
         cgLong,cgULong:
            Gen0(pc_lor);
         otherwise:
            error(66);
         end; {case}
      expressionType := wordPtr;
      end; {case barbarop}

   andandop: begin                      {&&}
      GenerateCode(tree^.left);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else if UsualUnaryConversions = cgExtended then begin
         GenLdcReal(0.0);
         Gen0t(pc_neq, cgExtended);
         expressionType := wordPtr;
         end; {if}
      lType := expressionType;
      GenerateCode(tree^.right);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else if UsualUnaryConversions = cgExtended then begin
         GenLdcReal(0.0);
         Gen0t(pc_neq, cgExtended);
         expressionType := wordPtr;
         end; {if}
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_and);
         cgLong,cgULong:
            Gen0(pc_lnd);
         otherwise:
            error(66);
         end; {case}
      expressionType := wordPtr;
      end; {case andandop}

   carotch: begin                       {^}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bxr);
         cgLong,cgULong:
            Gen0(pc_blx);
         otherwise:
            error(66);
         end; {case}
      end; {case carotch}

   barch: begin                         {|}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bor);
         cgLong,cgULong:
            Gen0(pc_blr);
         otherwise:
            error(66);
         end; {case}
      end; {case barch}

   andch: begin                         {&}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bnd);
         cgLong,cgULong:
            Gen0(pc_bal);
         otherwise:
            error(66);
         end; {case}
      end; {case andch}

   ltltop: begin                        {<<}
      GenerateCode(tree^.left);
      et := UsualUnaryConversions;
      lType := expressionType;
      GenerateCode(tree^.right);
      if (expressionType^.kind <> scalarType)
         or not (expressionType^.baseType in
         [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong]) then
         error(66);
      if expressionType^.baseType <> et then
         Gen2(pc_cnv, ord(expressionType^.baseType), ord(et));
      case et of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_shl);
         cgLong,cgULong:
            Gen0(pc_sll);
         otherwise:
            error(66);
         end; {case}
      expressionType := lType;
      end; {case ltltop}

   gtgtop: begin                        {>>}
      GenerateCode(tree^.left);
      et := UsualUnaryConversions;
      lType := expressionType;
      GenerateCode(tree^.right);
      if (expressionType^.kind <> scalarType)
         or not (expressionType^.baseType in
         [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong]) then
         error(66);
      if expressionType^.baseType <> et then
         Gen2(pc_cnv, ord(expressionType^.baseType), ord(et));
      case et of
         cgByte,cgWord:
            Gen0(pc_shr);
         cgUByte,cgUWord:
            Gen0(pc_usr);
         cgLong:
            Gen0(pc_slr);
         cgULong:
            Gen0(pc_vsr);
         otherwise:
            error(66);
         end; {case}
      expressionType := lType;
      end; {case gtgtop}

   plusch: begin                        {+}
      if ExpressionKind(tree^.right) in [arrayType,pointerType] then begin
         tree^.middle := tree^.right;
         tree^.right := tree^.left;
         tree^.left := tree^.middle;
         end; {if}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if lType^.kind in [arrayType,pointerType] then begin

         {pointer addition}
         et := UsualUnaryConversions;
         expressionType := lType;
         if lType^.kind = arrayType then
            lType := lType^.aType
         else
            lType := lType^.pType;
         ChangePointer(pc_adl, lType^.size, et);
         end {if}
      else begin

         {scalar addition}
         case UsualBinaryConversions(lType) of
            cgByte,cgUByte,cgWord,cgUWord:
               Gen0(pc_adi);
            cgLong,cgULong:
               Gen0(pc_adl);
            cgExtended:
               Gen0(pc_adr);
            otherwise:
               error(66);
            end; {case}
         end; {else}
      end; {case plusch}

   minusch: begin                       {-}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if lType^.kind in [pointerType,arrayType] then begin
         if lType^.kind = arrayType then
            size := lType^.aType^.size
         else
            size := lType^.pType^.size;
         if expressionType^.kind in [arrayType,pointerType] then begin

            {subtraction of two pointers}
            if size = 0 then
               Error(122)
                            {NOTE: assumes aType & pType overlap in typeRecord}
            else if not CompTypes(lType^.aType, expressionType^.aType) then
               Error(47);
            Gen0(pc_sbl);
            if size <> 1 then begin
               GenLdcLong(size);
               Gen0(pc_dvl);
               end; {if}
            lType := longPtr;
            end {if}
         else
            {subtract a scalar from a pointer}
            ChangePointer(pc_sbl, size, UsualUnaryConversions);
         expressionType := lType;
         end {if}
      else begin

         {scalar subtraction}
         case UsualBinaryConversions(lType) of
            cgByte,cgUByte,cgWord,cgUWord:
               Gen0(pc_sbi);
            cgLong,cgULong:
               Gen0(pc_sbl);
            cgExtended:
               Gen0(pc_sbr);
            otherwise:
               error(66);
            end; {case}
         end; {else}
      end; {case minusch}

   asteriskch: begin                    {*}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_mpi);
         cgUByte,cgUWord:
            Gen0(pc_umi);
         cgLong:
            Gen0(pc_mpl);
         cgULong:
            Gen0(pc_uml);
         cgExtended:
            Gen0(pc_mpr);
         otherwise:
            error(66);
         end; {case}
      end; {case asteriskch}

   slashch: begin                       {/}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_dvi);
         cgUByte,cgUWord:
            Gen0(pc_udi);
         cgLong:
            Gen0(pc_dvl);
         cgULong:
            Gen0(pc_udl);
         cgExtended:
            Gen0(pc_dvr);
         otherwise:
            error(66);
         end; {case}
      end; {case slashch}

   percentch: begin                     {%}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_mod);
         cgUByte,cgUWord:
            Gen0(pc_uim);
         cgLong:
            Gen0(pc_mdl);
         cgULong:
            Gen0(pc_ulm);
         otherwise:
            error(66);
         end; {case}
      end; {case percentch}

   eqeqop,                              {==}
   exceqop: begin                       {!=}
      GenerateCode(tree^.left);
      lType := expressionType;
      tlastwasconst := lastwasconst;
      tlastconst := lastconst;
      GenerateCode(tree^.right);
      CompareCompatible(ltype, expressionType);
      if tree^.token.kind = eqeqop then
         Gen0t(pc_equ, UsualBinaryConversions(lType))
      else
         Gen0t(pc_neq, UsualBinaryConversions(lType));
      expressionType := wordPtr;
      end; {case exceqop,eqeqop}

   lteqop,                              {<=}
   gteqop,                              {>=}
   ltch,                                {<}
   gtch: begin                          {>}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      CompareCompatible(ltype, expressionType);
      if tree^.token.kind = lteqop then
         Gen0t(pc_leq, UsualBinaryConversions(lType))
      else if tree^.token.kind = gteqop then
         Gen0t(pc_geq, UsualBinaryConversions(lType))
      else if tree^.token.kind = ltch then
         Gen0t(pc_les, UsualBinaryConversions(lType))
      else {if tree^.token.kind = gtch then}
         Gen0t(pc_grt, UsualBinaryConversions(lType));
      expressionType := wordPtr;
      end; {case lteqop,gteqop,ltch,gtch}

   uminus: begin                        {unary -}
      GenerateCode(tree^.left);
      case UsualUnaryConversions of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_ngi);
         cgLong,cgULong:
            Gen0(pc_ngl);
         cgExtended:
            Gen0(pc_ngr);
         otherwise:
            error(66);
         end; {case}
      end; {case uminus}

   tildech: begin                       {~}
      GenerateCode(tree^.left);
      case UsualUnaryConversions of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bnt);
         cgLong,cgULong:
            Gen0(pc_bnl);
         otherwise:
            error(66);
         end; {case}
      end; {case tildech}

   excch: begin                         {!}
      GenerateCode(tree^.left);
      if expressionType^.kind = pointerType then
         expressionType := uLongPtr;
      case UsualUnaryConversions of

         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_not);

         cgLong,cgULong: begin
            GenLdcLong(0);
            Gen0t(pc_equ, cgLong);
            end;

         cgExtended: begin
            GenLdcReal(0.0);
            Gen0t(pc_equ, cgExtended);
            end;

         otherwise:
            error(66);
         end; {case}
      expressionType := wordPtr;
      end; {case excch}

   plusplusop:                          {prefix ++}
      DoIncDec(tree^.left, pc_lil, pc_gil, pc_iil);

   opplusplus:                          {postfix ++}
      DoIncDec(tree^.left, pc_lli, pc_gli, pc_ili);

   minusminusop:                        {prefix --}
      DoIncDec(tree^.left, pc_ldl, pc_gdl, pc_idl);

   opminusminus:                        {postfix --}
      DoIncDec(tree^.left, pc_lld, pc_gld, pc_ild);

   uand:                                {unary & (address operator)}
      LoadAddress(tree^.left);

   uasterisk: begin                     {unary * (indirection)}
      GenerateCode(tree^.left);
      lType := expressionType;
      if lType^.kind in [functiontype,arrayType,pointerType] then begin
         if lType^.kind = arrayType then
            lType := lType^.aType
         else if lType^.kind = pointerType then
            lType := lType^.pType;
         expressionType := lType;
         if lType^.kind = scalarType then
            if lType^.baseType = cgVoid then
               Gen1t(pc_ind, 0, cgULong)
            else
               Gen1t(pc_ind, 0, lType^.baseType)
         else if lType^.kind = pointerType then
            Gen1t(pc_ind, 0, cgULong)
         else if not
            ((lType^.kind in [functionType,arrayType,structType,unionType])
            or ((lType^.kind = definedType) and  {handle const struct/union}
                (lType^.dType^.kind in [structType,unionType]))) then
            Error(79);
         end {if}
      else
         Error(79);
      end; {case uasterisk}

   dotch: begin                         {.}
      LoadAddress(tree^.left);
      lType := expressionType;
      if lType^.kind in [arrayType,pointerType] then begin
         if lType^.kind = arrayType then
            lType := lType^.aType
         else if lType^.kind = pointerType then
            lType := lType^.pType;
         DoSelection(lType, tree^.right, size);
         if (size & $00007FFF) <> size then begin
            GenLdcLong(size);
            Gen0(pc_adl);
            size := 0;
            end; {else}
         kind := expressionType^.kind;
         if kind = scalarType then begin
            et := expressionType^.baseType;
            if isBitField then begin
               GenLdcLong(size);
               Gen0(pc_adl);
               if unsigned then
                  Gen2t(pc_lbu, bitDisp, bitSize, et)
               else
                  Gen2t(pc_lbf, bitDisp, bitSize, et);
               end {if}
            else
               Gen1t(pc_ind, long(size).lsw, et);
            end {if}
         else if kind = pointerType then
            Gen1t(pc_ind, long(size).lsw, cgULong)
         else if kind = enumType then
            Gen1t(pc_ind, long(size).lsw, cgWord)
         else if size <> 0 then
            Gen1t(pc_inc, long(size).lsw, cgULong);
         end {if}
      else
         Error(79);
      end; {case dotch}

   colonch: begin                       {? :}
      GenerateCode(tree^.left);         {evaluate the condition}
      CompareToZero(pc_neq);
      GenerateCode(tree^.middle);       {evaluate true expression}
      lType := expressionType;
      tlastwasconst := lastwasconst;
      tlastconst := lastconst;
      GenerateCode(tree^.right);        {evaluate false expression}
      isString := false;                {handle string operands}
      if lType^.kind in [arrayType,pointerType] then
         if lType^.aType^.baseType = cgUByte then begin
            with expressionType^ do
               if kind in [arrayType,pointerType] then begin
                  if aType^.baseType = cgUByte then
                     isString := true
                  else if (kind = pointerType)
                     and (CompTypes(lType,expressionType)) then
                     {it's all OK}
                  else
                     Error(47)
                  end {if}
               else if (kind = scalarType)
                  and lastWasConst
                  and (lastConst = 0) then
                  et := UsualBinaryConversions(lType)
                  {it's all OK}
               else
                  Error(47);
            lType := voidPtrPtr;
            expressionType := voidPtrPtr;
            end; {if}
      with expressionType^ do
         if kind in [arrayType,pointerType] then
            if aType^.baseType in [cgByte,cgUByte] then begin
               if kind = pointerType then begin
                  if tlastwasconst and (tlastconst = 0) then
                     {it's all OK}
                  else if CompTypes(lType, expressionType) then
                     {it's all OK}
                  else
                     Error(47);
                  end {if}
               else
                  Error(47);
               et := UsualBinaryConversions(lType);
               lType := voidPtrPtr;
               expressionType := voidPtrPtr;
               end; {if}
                                        {generate the operation}
      if lType^.kind in [structType, unionType, arrayType] then begin
         if not CompTypes(lType, expressionType) then
            Error(47);
         Gen0(pc_bno);
         Gen0t(pc_tri, cgULong);
         end {if}
      else begin
         if expressionType^.kind = pointerType then
            tType := expressionType
         else
            tType := lType;
         if (expressionType^.kind = scalarType)
            and (expressionType^.baseType = cgVoid)
            and (lType^.kind = scalarType)
            and (lType^.baseType = cgVoid) then
            et := cgVoid
         else
            et := UsualBinaryConversions(lType);
         Gen0(pc_bno);
         Gen0t(pc_tri, et);
         end; {else}
      if isString then                  {set the type for strings}
         expressionType := stringTypePtr;
      end; {case colonch}

   castoper: begin                      {(cast)}
      GenerateCode(tree^.left);
      Cast(tree^.castType);
      end; {case castoper}

   otherwise:
      Error(57);

   end; {case}
if doDispose then
   dispose(tree);
end; {GenerateCode}


procedure Expression {kind: expressionKind; stopSym: tokenSet};

{ handle an expression                                          }
{                                                               }
{ parameters:                                                   }
{       kind - Kind of expression; determines what operations   }
{               and what kind of operands are allowed.          }
{       stopSym - Set of symbols that can mark the end of an    }
{               expression; used to skip tokens after syntax    }
{               errors and to block certain operations.  For    }
{               example, the comma operator is not allowed in   }
{               an expression when evaluating a function        }
{               parameter list.                                 }
{                                                               }
{ variables:                                                    }
{       realExpressionValue - value of a real constant          }
{               expression                                      }
{       expressionValue - value of a constant expression        }
{       expressionType - type of the constant expression        }

label 1;

var
   lcodeGeneration: boolean;            {local copy of codeGeneration}
   ldoDispose: boolean;                 {local copy of doDispose}
   tree: tokenPtr;                      {expression tree}
   castValue: tokenPtr;                 {element being type cast}

begin {Expression}
errorFound := false;                    {no error so far}
tree := ExpressionTree(kind, stopSym);  {create the expression tree}
if kind = normalExpression then begin   {generate code from the expression tree}
   if not errorFound then begin
      doDispose := true;
      GenerateCode(tree);
      end; {if}
   end {if}
else begin                              {record the expression for an initializer}
   initializerTree := tree;
   isConstant := false;
   if errorFound then begin
      DisposeTree(initializerTree);
      initializerTree := nil;
      end {if}
   else begin
      ldoDispose := doDispose;          {find the expression type}
      doDispose := false;
      lcodeGeneration := codeGeneration;
      codeGeneration := false;
      GenerateCode(tree);
      doDispose := ldoDispose;
      codeGeneration := lCodeGeneration and (numErrors = 0);
                                        {record the expression}
      if tree^.token.kind = castoper then begin
         castValue := tree^.left;
         while castValue^.token.kind = castoper do
            castValue := castValue^.left;
         if castValue^.token.kind in [intconst,uintconst] then begin
            expressionValue := castValue^.token.ival;
            isConstant := true;
            expressionType := tree^.castType;
            if (castValue^.token.kind = uintconst)
               or (expressionType^.kind = pointerType) then
               expressionValue := expressionValue & $0000FFFF;
            goto 1;
            end; {if}
         if castValue^.token.kind in [longconst,ulongconst] then begin
            expressionValue := castValue^.token.lval;
            isConstant := true;
            expressionType := tree^.castType;
            goto 1;
            end; {if}
         end; {if}
      if tree^.token.kind = intconst then begin
         expressionValue := tree^.token.ival;
         expressionType := wordPtr;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = uintconst then begin
         expressionValue := tree^.token.ival;
         expressionValue := expressionValue & $0000FFFF;
         expressionType := uwordPtr;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = longconst then begin
         expressionValue := tree^.token.lval;
         expressionType := longPtr;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = ulongconst then begin
         expressionValue := tree^.token.lval;
         expressionType := ulongPtr;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = doubleconst then begin
         realExpressionValue := tree^.token.rval;
         expressionType := extendedPtr;
         isConstant := true;
         if kind in [arrayExpression,preprocessorExpression] then begin
            expressionType := wordPtr;
            expressionValue := 1;
            Error(47);
            end; {if}
         end {else if}
      else if tree^.token.kind = stringconst then begin
         expressionValue := ord4(tree^.token.sval);
         expressionType := stringTypePtr;
         isConstant := true;
         if kind in [arrayExpression,preprocessorExpression] then begin
            expressionType := wordPtr;
            expressionValue := 1;
            Error(47);
            end; {if}
         end {else if}
      else if kind in [arrayExpression,preprocessorExpression] then begin
         DisposeTree(initializerTree);
         expressionValue := 1;
         end; {else if}
      end; {else}
   end; {else}
1:
end; {Expression}


procedure InitExpression;

{ initialize the expression handler                             }

begin {InitExpression}
startTerm := [ident,intconst,uintconst,longconst,ulongconst,doubleconst,
              stringconst];
startExpression:= startTerm +
             [lparench,asteriskch,andch,plusch,minusch,excch,tildech,sizeofsy,
              plusplusop,minusminusop,typedef];
end; {InitExpression}

end.

{$append 'expression.asm'}
