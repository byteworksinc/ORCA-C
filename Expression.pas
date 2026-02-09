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
{  InitExpression - initialize the expression handler           }
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
   lastWasNullPtrConst: boolean;        {did last GenerateCode give a null ptr const?}
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
{ variables:                                                    }
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


procedure ExtendBitIntValue (var val: longlong; tp: typePtr);

{ If tp is a _BitInt type, truncate val to the width of that    }
{ type and then sign-extend or zero-extend it.                  }


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


procedure ValueExpressionConversions;

{ Perform type conversions applicable to an expression used     }
{ for its value.  These include lvalue conversion (removing     }
{ qualifiers), array-to-pointer conversion, and                 }
{ function-to-pointer conversion.  See C17 section 6.3.2.1.     }
{                                                               }
{ variables:                                                    }
{       expressionType - set to type after conversions          }


procedure GetLLExpressionValue (var val: longlong);

{ get the value of the last integer constant expression as a    }
{ long long (whether it had long long type or not).             }


function GetFullExpressionType: typePtr;

{ Get the full type of the last expression.                     }
{                                                               }
{ This differs from just reading expressionType in that the     }
{ types of string constants include their length.               }

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
   stringConstSize: integer;            {size of string constant}

{-- Procedures imported from the parser ------------------------}

procedure Match (kind: tokenEnum; err: integer); extern;

{ insure that the next token is of the specified type           }
{                                                               }
{  parameters:                                                  }
{       kind - expected token kind                              }
{       err - error number if the expected token is not found   }


function TypeName: typePtr; extern;

{ process a type name (used for casts and sizeof/_Alignof)      }
{                                                               }
{ returns: a pointer to the type                                }


function MakeFuncIdentifier: identPtr; extern;

{ Make the predefined identifier __func__.                      }
{                                                               }
{ It is inserted in the symbol table as if the following        }
{ declaration appeared at the beginning of the function body:   }
{                                                               }
{     static const char __func__[] = "function-name";           }
{                                                               }
{ This must only be called within a function body.              }


function MakeCompoundLiteral(tp: typePtr): identPtr; extern;

{ Make the identifier for a compound literal.                   }
{                                                               }
{ parameters:                                                   }
{       tp - the type of the compound literal                   }


procedure AutoInit (variable: identPtr; line: longint;
   isCompoundLiteral: boolean); extern;

{ generate code to initialize an auto variable                  }
{                                                               }
{ parameters:                                                   }
{       variable - the variable to initialize                   }
{       line - line number (used for debugging)                 }
{       isCompoundLiteral - initializing a compound literal?    }

{-- External unsigned math routines ----------------------------}

function lshr (x,y: longint): longint; extern;

function udiv (x,y: longint): longint; extern;

function uge (x,y: longint): integer; extern;

function ugt (x,y: longint): integer; extern;

function ule (x,y: longint): integer; extern;

function ult (x,y: longint): integer; extern;

function umod (x,y: longint): longint; extern;

function umul (x,y: longint): longint; extern;

{-- External 64-bit math routines ------------------------------}
{ Procedures for arithmetic and shifts compute "x := x OP y".   }

procedure umul64 (var x: longlong; y: longlong); extern;

procedure udiv64 (var x: longlong; y: longlong); extern;

procedure div64 (var x: longlong; y: longlong); extern;

procedure umod64 (var x: longlong; y: longlong); extern;

procedure rem64 (var x: longlong; y: longlong); extern;

procedure add64 (var x: longlong; y: longlong); extern;

procedure sub64 (var x: longlong; y: longlong); extern;

procedure shl64 (var x: longlong; y: integer); extern;

procedure ashr64 (var x: longlong; y: integer); extern;

procedure lshr64 (var x: longlong; y: integer); extern;

function ult64(a,b: longlong): integer; extern;

function uge64(a,b: longlong): integer; extern;

function ule64(a,b: longlong): integer; extern;

function ugt64(a,b: longlong): integer; extern;

function slt64(a,b: longlong): integer; extern;

function sge64(a,b: longlong): integer; extern;

function sle64(a,b: longlong): integer; extern;

function sgt64(a,b: longlong): integer; extern;

{-- External conversion functions; imported from CGC.pas -------}

procedure CnvXLL (var result: longlong; val: extended); extern;

procedure CnvXULL (var result: longlong; val: extended); extern;

function CnvLLX (val: longlong): extended; extern;

function CnvULLX (val: longlong): extended; extern;

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
if tp in [cgByte,cgUByte] then
   tp := cgWord;
Unary := tp;
end; {Unary}


function IntegerBinaryConversions(tp1, tp2: typePtr): typePtr;

{ perform the usual arithmetic conversions on two integer types }
{                                                               }
{ inputs:                                                       }
{       tp1, tp2 - integer types                                }
{                                                               }
{ result:                                                       }
{       The type resulting from the usual arithmetic            }
{       conversions on tp1 and tp2                              }

label 1;

var
   rank1, rank2: integer;               {integer conversion ranks of tp1,tp2}
   signed1, signed2: boolean;           {are tp1,tp2 signed integer types?}
   tType: typePtr;                      {temp type}


   function ConversionRank (tp: typePtr): integer;

   { Get the integer conversion rank of an integer type.        }
   { (This only applies to types after the integer promotions.) }

   begin {ConversionRank}
   case tp^.cType of
      ctInt,ctUInt:
         ConversionRank := 17;
      ctInt32,ctUInt32:
         ConversionRank := 34;
      ctLong,ctULong:
         ConversionRank := 35;
      ctLongLong,ctULongLong:
         ConversionRank := 68;
      ctBitInt,ctUBitInt:
         if tp^.bitIntWidth in [1..16] then
            ConversionRank := tp^.bitIntWidth
         else if tp^.bitIntWidth in [17..32] then
            ConversionRank := tp^.bitIntWidth + 1
         else
            ConversionRank := tp^.bitIntWidth + 3;
      otherwise: begin
         ConversionRank := 17;
         Error(57);
         end; {otherwise}
      end; {case}
   end; {ConversionRank}


   function CorrespondingUnsignedType (tp: typePtr): typePtr;

   { Get unsigned type corresponding to a signed integer type.  }

   begin {CorrespondingUnsignedType}
   case tp^.cType of
      ctInt:
         CorrespondingUnsignedType := uIntPtr;
      ctInt32:
         CorrespondingUnsignedType := uInt32Ptr;
      ctLong:
         CorrespondingUnsignedType := uLongPtr;
      ctLongLong:
         CorrespondingUnsignedType := uLongLongPtr;
      ctBitInt:
         CorrespondingUnsignedType := GetBitIntType(true, tp^.bitIntWidth);
      otherwise: begin
         CorrespondingUnsignedType := uIntPtr;
         Error(57);
         end; {otherwise}
      end; {case}
   end; {CorrespondingUnsignedType}


begin {IntegerBinaryConversions}
                                        {perform integer promotions}
if tp1^.cType in [ctBool,ctChar,ctUChar,ctSChar,ctShort] then
   tp1 := intPtr
else if tp1^.cType = ctUShort then
   tp1 := uIntPtr;
if tp2^.cType in [ctBool,ctChar,ctUChar,ctSChar,ctShort] then
   tp2 := intPtr
else if tp2^.cType = ctUShort then
   tp2 := uIntPtr;

if tp1 = tp2 then begin                 {shortcut}
   IntegerBinaryConversions := Unqualify(tp1);
   goto 1;
   end; {if}

rank1 := ConversionRank(tp1);           {order types so tp1 is top-ranked}
rank2 := ConversionRank(tp2);
if rank2 > rank1 then begin
   tType := tp1;
   tp1 := tp2;
   tp2 := tType;
   end; {if}

signed1 := IsSignedType(tp1);
signed2 := IsSignedType(tp2);

if signed1 = signed2 then               {apply conversion rules}
   IntegerBinaryConversions := Unqualify(tp1)
else if not signed1 then
   IntegerBinaryConversions := Unqualify(tp1)
else if (rank1 = rank2) and not signed2 then
   IntegerBinaryConversions := Unqualify(tp2)
else if Width(tp1) > Width(tp2) then
   IntegerBinaryConversions := Unqualify(tp1)
else
   IntegerBinaryConversions := CorrespondingUnsignedType(tp1);
1:
end; {IntegerBinaryConversions}


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
   lt,rt,et: baseTypeEnum;              {work variables}


   function CommonRealType (lt, rt: baseTypeEnum): baseTypeEnum;
   
   { Compute the common real type of two types, where at least  }
   { one of the types is a real type.                           }
   {                                                            }
   { inputs:                                                    }
   {         lt, rt - the two operand types                     }
   {                                                            }
   { outputs:                                                   }
   {         expressionType - set to result type                }
   
   begin {CommonRealType}
   if (lt = cgComp) and (rt = cgComp) then
      lt := cgComp
   else if (lt in [cgExtended,cgComp]) or (rt in [cgExtended,cgComp]) then
      lt := cgExtended
   else if (lt = cgDouble) or (rt = cgDouble) then
      lt := cgDouble
   else
      lt := cgReal;
   CommonRealType := lt;
   case lt of
      cgReal:     expressionType := floatPtr;
      cgDouble:   expressionType := doublePtr;
      cgExtended: expressionType := extendedPtr;
      cgComp:     expressionType := compPtr;
      end; {case}
   end; {CommonRealType}


   procedure ZeroExtend (width: integer; zxi,zxl,zxq: pcodes);

   { Zero-extend a value of specified width                     }

   begin {ZeroExtend}
   if width in [1..15] then
      Gen1(zxi, width)
   else if width in [17..31] then
      Gen1(zxl, width)
   else if width in [33..63] then
      Gen1(zxq, width);
   end; {ZeroExtend}


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
   if lt in [cgReal,cgDouble,cgExtended,cgComp] then begin
      if rt in [cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad] then
         Gen2(pc_cnv, ord(rt), ord(cgExtended));
      UsualBinaryConversions := CommonRealType(lt, rt);
      end {if}
   else if rt in [cgReal,cgDouble,cgExtended,cgComp] then begin
      if lt in [cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad] then
         Gen2(pc_cnn, ord(lt), ord(cgExtended));
      UsualBinaryConversions := CommonRealType(lt, rt);
      end {else if}
   else begin
      expressionType := IntegerBinaryConversions(ltype, rtype);
      et := expressionType^.baseType;
      if TypeSize(et) <> TypeSize(lt) then
         Gen2(pc_cnn, ord(lt), ord(et))
      else if TypeSize(et) <> TypeSize(rt) then
         Gen2(pc_cnv, ord(rt), ord(et));
      if expressionType^.cType = ctUBitInt then
         if IsSignedType(lType) then
            ZeroExtend(expressionType^.bitIntWidth, pc_zni, pc_znl, pc_znq)
         else if IsSignedType(rType) then
            ZeroExtend(expressionType^.bitIntWidth, pc_zxi, pc_zxl, pc_zxq);
      UsualBinaryConversions := et;
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
   if et = cgWord then begin            {update types that may have changed}
      if not (expressionType^.cType in [ctBitInt,ctUBitInt]) then
         expressionType := intPtr;
      end {if}
   else if et = cgUWord then begin
      if not (expressionType^.cType in [ctBitInt,ctUBitInt]) then
         expressionType := uIntPtr;
      end; {else if}
   end; {if}
expressionType := Unqualify(expressionType);
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


procedure ValueExpressionConversions;

{ Perform type conversions applicable to an expression used     }
{ for its value.  These include lvalue conversion (removing     }
{ qualifiers), array-to-pointer conversion, and                 }
{ function-to-pointer conversion.  See C17 section 6.3.2.1.     }
{                                                               }
{ variables:                                                    }
{       expressionType - set to type after conversions          }

begin {ValueExpressionConversions}
expressionType := Unqualify(expressionType);
if expressionType^.kind = arrayType then
   expressionType := MakePointerTo(expressionType^.aType)
else if expressionType^.kind = functionType then
   expressionType := MakePointerTo(expressionType);
end; {ValueExpressionConversions}


procedure ExtendBitIntValue {var val: longlong; tp: typePtr};

{ If tp is a _BitInt type, truncate val to the width of that    }
{ type and then sign-extend or zero-extend it.                  }

var
   mask: longlong;
   bitpos: longlong;

begin {ExtendBitIntValue}
if tp^.kind = scalarType then
   if tp^.cType in [ctBitInt,ctUBitInt] then begin
      bitpos := longlong1;
      shl64(bitpos, tp^.bitIntWidth - 1);
      mask := bitpos;
      shl64(mask, 1);
      sub64(mask, longlong1);
      val.hi := val.hi & mask.hi;
      val.lo := val.lo & mask.lo;
      if tp^.cType = ctBitInt then
         if ((val.hi & bitpos.hi) <> 0) or ((val.lo & bitpos.lo) <> 0) then
            begin
            val.hi := val.hi | ~mask.hi;
            val.lo := val.lo | ~mask.lo;
            end; {if}
      end; {if}
end; {ExtendBitIntValue}


procedure SignExtendBitInt (tp: typePtr);

{ Sign-extend a signed _BitInt.  This has no effect if tp is    }
{ not a signed _BitInt type.                                    }

begin {SignExtendBitInt}
if tp^.kind = scalarType then
   if tp^.cType = ctBitInt then
      if not (tp^.bitIntWidth in [16,32,64]) then
         case tp^.baseType of
            cgWord: Gen1(pc_sxi, tp^.bitIntWidth);
            cgLong: Gen1(pc_sxl, tp^.bitIntWidth);
            cgQuad: Gen1(pc_sxq, tp^.bitIntWidth);
            otherwise: Error(57);
            end; {case}
end; {SignExtendBitInt}


procedure TruncateUBitInt (tp: typePtr);

{ Truncate high-order bits beyond the width of an unsigned      }
{ _BitInt.  This has no effect if tp is not an unsigned _BitInt }
{ type.                                                         }

begin {TruncateUBitInt}
if tp^.kind = scalarType then
   if tp^.cType = ctUBitInt then
      if not (tp^.bitIntWidth in [16,32,64]) then
         case tp^.baseType of
            cgUWord: Gen1(pc_zxi, tp^.bitIntWidth);
            cgULong: Gen1(pc_zxl, tp^.bitIntWidth);
            cgUQuad: Gen1(pc_zxq, tp^.bitIntWidth);
            otherwise: Error(57);
            end; {case}
end; {TruncateUBitInt}


procedure BitIntConversion (t1, t2: typePtr);

{ Performs the _BitInt-related portion of a conversion from     }
{ t2 to t1.  This has no effect if t1 is not a _BitInt type.    }
{ If t1 is a _BitInt type, this will truncate the high-order    }
{ value bits beyond the width of the _BitInt type and then      }
{ sign-extend or zero-extend the value, if necessary.           }
{                                                               }
{ parameters:                                                   }
{       t1 - type being converted to                            }
{       t2 - type being converted from                          }

begin {BitIntConversion}
if t1^.kind = scalarType then
   if t1^.ctype = ctBitInt then begin
      if (Width(t2) > t1^.bitIntWidth) or
         ((Width(t2) = t1^.bitIntWidth) and not IsSignedType(t2)) then
         SignExtendBitInt(t1);
      end {if}
   else if t1^.ctype = ctUBitInt then
      if (Width(t2) > t1^.bitIntWidth) or IsSignedType(t2) then
         TruncateUBitInt(t1);
end; {BitIntConversion}


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


   procedure CheckConstantRange(t1: typePtr; value: longint);
   
   { Check for situations where an implicit conversion will     }
   { change the value of a constant.                            }
   {                                                            }
   { Note: This currently only addresses conversions to 8-bit   }
   {    or 16-bit integer types, and intentionally does not     }
   {    distinguish between signed and unsigned types.          }
   
   var
      min,max: longint;                 {min/max allowed values}
   
   begin {CheckConstantRange}
   if t1^.cType = ctBool then begin
      min := 0;
      max := 1;
      end {if}
   else if t1^.baseType in [cgByte,cgUByte] then begin
      min := -128;
      max := 255;
      end {else if}
   else if t1^.baseType in [cgWord,cgUWord] then begin
      min := -32768;
      max := 65536;
      end {else if}
   else begin
      min := -maxint4-1;
      max := maxint4;
      end; {else}
   if (value < min) or (value > max) then
      Error(186);
   end; {CheckConstantRange}


begin {AssignmentConversion}
kind1 := t1^.kind;
kind2 := t2^.kind;
if genCode then
   if checkConst then
      if kind2 <> definedType then
         if tqConst in t1^.qualifiers then
            Error(93)
         else if kind1 in [structType,unionType] then
            if t1^.constMember then
               Error(93);
if kind2 = definedType then
   AssignmentConversion(t1, t2^.dType, false, 0, genCode, checkConst)
else if kind1 = definedType then
   AssignmentConversion(t1^.dType, t2, false, 0, genCode, checkConst)
else if kind2 in
   [scalarType,pointerType,enumType,structType,unionType,arrayType,functionType] then
   case kind1 of

      scalarType: begin
         if ((lint & lintConstantRange) <> 0) then
            if isConstant then
               CheckConstantRange(t1, value);
         baseType1 := t1^.baseType;
         if baseType1 in [cgReal,cgDouble,cgComp] then
            baseType1 := cgExtended;
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
            else if genCode then begin
               if t1^.cType = ctBool then begin
                  expressionType := t2;
                  CompareToZero(pc_neq);
                  end {if}
               else
                  Gen2(pc_cnv, ord(baseType2), ord(baseType1));
               end {else if}
            end {else if}
         else if (t1^.cType = ctBool)
            and (kind2 in [pointerType,arrayType,functionType]) then begin
            if genCode then begin
               expressionType := t2;
               CompareToZero(pc_neq);
               end {if}
            end {else if}
         else
            Error(47);
         if genCode then
            BitIntConversion(t1, t2);
         end;

      arrayType: ;
         {any errors are handled elsewhere}

      functionType,enumConst:
         Error(47);

      pointerType: begin
         if kind2 = pointerType then begin
            if not CompTypes(t1, t2) then
               Error(47)
            else if not looseTypeChecks then
               if not (t1^.ptype^.qualifiers >= t2^.ptype^.qualifiers) then
                  Error(163);
            end {if}
         else if kind2 = arrayType then begin
            if not CompTypes(t1^.ptype, t2^.atype) and
               (t1^.ptype^.baseType <> cgVoid) then
               Error(47)
            else if not looseTypeChecks then
               if not (t1^.ptype^.qualifiers >= t2^.atype^.qualifiers) then
                  Error(163);
            end {if}
         else if kind2 = scalarType then begin
            if isConstant and (value = 0) then begin
               if genCode then
                  Gen2(pc_cnv, ord(t2^.baseType), ord(cgULong));
               end {if}
            else
               Error(47);
            end {else if}
         else if kind2 = functionType then
            AssignmentConversion(t1, MakePointerTo(t2), isConstant, value,
               genCode, checkConst)
         else
            Error(47);
         end;

      enumType: begin
         if kind2 = scalarType then begin
            if ((lint & lintConstantRange) <> 0) then
               if isConstant then
                  CheckConstantRange(intPtr, value);
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
   doingAlignof: boolean;               {used to test for an _Alignof operator}
   expectingTerm: boolean;              {should the next token be a term?}
   opStack: tokenPtr;                   {operation stack}
   parenCount: integer;                 {# of open parenthesis}
   stack: tokenPtr;                     {operand stack}
   codeLoc: codeRef;                    {code location for sizeof/etc.}
   tType: typePtr;                      {type for cast/sizeof/etc.}
   lVLATrees: 0..maxint4;               {local copy of vlaTrees}

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

   if kind = preprocessorExpression then
      if token.name^ = 'defined' then begin
         {handle the preprocessor 'defined' function}
         if prohibitDefined then
            Error(161);
         expandMacros := false;
         NextToken;
         sp^.token.kind := intconst;
         sp^.token.class := intConstant;
         sp^.token.itype := intPtr;
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
         end {if}
      else if (cStd >= c23) or not strictMode then begin
         if token.name^ = '__has_embed' then begin
            NextToken;
            if token.kind <> lparench then
               Error(13);
            sp^.token.class := longlongConstant;
            sp^.token.kind := longlongconst;
            sp^.token.qtype := longLongPtr;
            sp^.token.qval.lo := DoEmbed(false);
            sp^.token.qval.hi := 0;
            sp^.id := nil;
            Match(rparench, 12);
            goto 1;
            end {if}
         else if token.name^ = '__has_include' then begin
            NextToken;
            if token.kind <> lparench then
               Error(13);
            sp^.token.class := longlongConstant;
            sp^.token.kind := longlongconst;
            sp^.token.qtype := longLongPtr;
            sp^.token.qval.lo := ord(HasInclude);
            sp^.token.qval.hi := 0;
            sp^.id := nil;
            NextToken;
            Match(rparench, 12);
            goto 1;
            end {else if}
         else if token.name^ = '__has_c_attribute' then begin
            NextToken;
            Match(lparench, 13);
            if token.class in [identifier,reservedWord] then
               NextToken
            else
               Error(9);
            if token.kind = coloncolonsy then begin
               NextToken;
               if token.class in [identifier,reservedWord] then
                  NextToken
               else
                  Error(9);
               end; {if}
            sp^.token.class := longlongConstant;
            sp^.token.kind := longlongconst;
            sp^.token.qtype := longLongPtr;
            sp^.token.qval := longlong0; {no attributes are currently supported}
            sp^.id := nil;
            Match(rparench, 12);
            goto 1;
            end {else if}
         else if (cStd >= c23) and (token.name^ = 'true') then begin
            {handle 'true' in the preprocessor for C23}
            stack^.token.class := longlongConstant;
            stack^.token.kind := longlongconst;
            stack^.token.qtype := longLongPtr;
            stack^.token.qval := longlong1;
            stack^.id := nil;
            NextToken;
            goto 1;
            end; {else if}
         end; {else if}

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

   {in the preprocessor, all identifiers (post macro replacement) become 0}
   if kind = preprocessorExpression then begin
      stack^.token.class := longlongConstant;
      stack^.token.kind := longlongconst;
      stack^.token.qtype := longLongPtr;
      stack^.token.qval := longlong0;
      id := nil;
      end {if}

   {if the id is not declared, create a function returning integer}
   else if id = nil then begin
      if (fToken.name^ = '__func__') and (functionTable <> nil) then
         id := MakeFuncIdentifier
      else if token.kind = lparench then begin
         fnPtr := pointer(GCalloc(sizeof(typeRecord)));
         {fnPtr^.size := 0;}
         {fnPtr^.saveDisp := 0;}
         {fnPtr^.qualifiers := [];}
         fnPtr^.kind := functionType;
         fnPtr^.fType := intPtr;
         {fnPtr^.varargs := false;}
         {fnPtr^.prototyped := false;}
         {fnPtr^.overrideKR := false;}
         {fnPtr^.parameterList := nil;}
         {fnPtr^.isPascal := false;}
         {fnPtr^.toolNum := 0;}
         {fnPtr^.dispatcher := 0;}
         np := pointer(GMalloc(length(fToken.name^)+1));
         CopyString(pointer(np), pointer(fToken.name));
         id := NewSymbol(np, fnPtr, ident, variableSpace, declared, false);
         if ((lint & lintUndefFn) <> 0) or ((lint & lintC99Syntax) <> 0) then
            Error(51);
         end {if}
      else begin
         Error(31);
         errorFound := true;
         end; {else}
      end {if id = nil}
   else if id^.underspecified then begin
      id := nil;
      Error(198);
      errorFound := true;
      end {else if}
   else if id^.itype^.kind = enumConst then begin
      stack^.token.class := intConstant;
      stack^.token.kind := intconst;
      stack^.token.itype := intPtr;
      stack^.token.ival := id^.itype^.eval;
      end; {else if}

   if id <> nil then
      id^.used := true;
   stack^.id := id;                     {save the identifier}
   ComplexTerm;                         {handle subscripts, selection, etc.}
   1:
   end; {DoOperand}


   procedure Operation;

   { do an operation                                                }

   label 1,3,4;

   var
      baseType: baseTypeEnum;           {base type of value to cast}
      class: tokenClass;                {class of cast token}
      ekind: tokenEnum;                 {kind of constant expression}
      etype: typePtr;                   {type of constant expression}
      kindLeft, kindRight: tokenEnum;	{kinds of operands}
      lCodeGeneration: boolean;         {local copy of codeGeneration}
      ltype,rtype: typePtr;             {types of operands}
      op: tokenPtr;                     {work pointer}
      op1: longint;                     {for evaluating constant expressions}
      rop1,rop2: extended;              {for evaluating fp expressions}
      llop1, llop2: longlong;           {for evaluating long long expressions}
      tp: typePtr;                      {cast type}
      unsigned: boolean;                {is the term unsigned?}


      function Pop: tokenPtr;

      { pop an operand, returning its pointer                        }

      begin {Pop}
      if stack = nil then begin
         Error(36);
         errorFound := true;
         new(stack);                    {synthesize the missing token}
         stack^.token.class := intConstant;
         stack^.token.kind := intconst;
         stack^.token.itype := intPtr;
         stack^.token.ival := 0;
         stack^.next := nil;
         stack^.left := nil;
         stack^.middle := nil;
         stack^.right := nil;
         end; {if}
      Pop := stack;
      stack := stack^.next;
      end; {Pop}


      function RealVal (token: tokenType): extended;

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
      else if token.kind = longlongconst then
         RealVal := CnvLLX(token.qval)
      else if token.kind = ulonglongconst then
         RealVal := CnvULLX(token.qval)
      else
         RealVal := token.rval;
      end; {RealVal}


      procedure GetLongLongVal (var result: longlong; token: tokenType;
                                tp: typePtr);

      { get the value of token (converted to tp) as a long long }

      var
         mask: longlong;

      begin {GetLongLongVal}
      if token.kind = intconst then begin
         result.lo := token.ival;
         if result.lo < 0 then
            result.hi := -1
         else
            result.hi := 0;
         end {if}
      else if token.kind = uintconst then begin
         result.lo := token.ival & $0000FFFF;
         result.hi := 0;
         end {else if}
      else if token.kind = longconst then begin
         result.lo := token.lval;
         if result.lo < 0 then
            result.hi := -1
         else
            result.hi := 0;
         end {else if}
      else if token.kind = ulongconst then begin
         result.lo := token.lval;
         result.hi := 0;
         end {else if}
      else {if token.kind in [longlongconst,ulonglongconst] then} begin
         result := token.qval;
         end; {else}
      if tp^.kind = scalarType then
         if not IsSignedType(tp) then begin
            mask := longlong1;
            shl64(mask, Width(tp));
            sub64(mask, longlong1);
            result.hi := result.hi & mask.hi;
            result.lo := result.lo & mask.lo;
            end; {if}
      end; {GetLongLongVal}


      function PPType (tp: typePtr): typePtr;

      { adjust integer type for use in preprocessor expression  }

      begin {PPType}
      case tp^.cType of
         ctUChar,ctUShort,ctUInt,ctUInt32,ctULong,ctULongLong:
            PPType := uLongLongPtr;
         otherwise:
            PPType := longLongPtr;
         end; {case}
      end; {PPType}


      procedure SetIntToken(var tk: TokenType; val: longlong; tp: typePtr);

      { set tk to an integer constant token with the specified  }
      { and value (with val truncated to the width of tp).      }

      var
         mask: longlong;

      begin {SetIntToken}
      if tp^.baseType in [cgQuad,cgUQuad] then begin
         tk.class := longlongConstant;
         tk.qval := val;
         tk.qtype := tp;
         if tp^.baseType = cgUQuad then
            tk.kind := ulonglongconst
         else
            tk.kind := longlongconst;
         end {if}
      else if tp^.baseType in [cgLong,cgULong] then begin
         tk.class := longConstant;
         tk.lval := val.lo;
         tk.ltype := tp;
         if tp^.baseType = cgULong then
            tk.kind := ulongconst
         else
            tk.kind := longconst;
         end {if}
      else begin
         tk.class := intConstant;
         tk.ival := long(val.lo).lsw;
         tk.itype := tp;
         if tp^.baseType = cgUWord then
            tk.kind := uintconst
         else
            tk.kind := intconst;
         end; {else}
      if tp^.cType = ctUBitInt then begin
         mask := longlong1;
         shl64(mask, tp^.bitIntWidth);
         sub64(mask, longlong1);
         if tk.class = longlongConstant then
            tk.qval.hi := tk.qval.hi & mask.hi
         else if tk.class = longConstant then
            tk.lval := tk.lval & mask.lo
         else
            tk.ival := tk.ival & long(mask.lo).lsw;
         end; {if}
      end; {SetIntToken}


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
         if op^.right^.token.kind in [intconst,uintconst,
            longconst,ulongconst,longlongconst,ulonglongconst] then
            if op^.left^.token.kind in [intconst,uintconst,
               longconst,ulongconst,longlongconst,ulonglongconst]
               then
               if op^.middle^.token.kind in [intconst,uintconst,
                  longconst,ulongconst,longlongconst,ulonglongconst]
                  then begin
                  
                  ltype := op^.middle^.token.itype;
                  rtype := op^.right^.token.itype;

                  {do the usual binary conversions}
                  etype := IntegerBinaryConversions(ltype, rtype);
                  
                  GetLongLongVal(llop1, op^.left^.token, etype);
                  if (llop1.lo <> 0) or (llop1.hi <> 0) then
                     GetLongLongVal(llop2, op^.middle^.token, etype)
                  else
                     GetLongLongVal(llop2, op^.right^.token, etype);
                  SetIntToken(op^.token, llop2, etype);

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
         if kindRight in [intconst,uintconst,longconst,
            ulongconst,longlongconst,ulonglongconst] then begin
            if kindLeft in [intconst,uintconst,longconst,
               ulongconst,longlongconst,ulonglongconst] then begin

               ltype := op^.left^.token.itype;
               rtype := op^.right^.token.itype;

               if kind = preprocessorExpression then begin
                  ltype := PPType(ltype);
                  rtype := PPType(rtype);
                  end; {if}

               {do the usual binary conversions}
               etype := IntegerBinaryConversions(ltype, rtype);

               unsigned := etype^.baseType in [cgUWord,cgULong,cgUQuad];
               GetLongLongVal(llop1, op^.left^.token, etype);
               GetLongLongVal(llop2, op^.right^.token, etype);
               
               case op^.token.kind of
                  barbarop    : begin                                   {||}
                                llop1.lo :=
                                   ord((llop1.lo <> 0) or (llop1.hi <> 0) or
                                       (llop2.lo <> 0) or (llop2.hi <> 0));
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  andandop    : begin                                   {&&}
                                llop1.lo :=
                                   ord(((llop1.lo <> 0) or (llop1.hi <> 0)) and
                                       ((llop2.lo <> 0) or (llop2.hi <> 0)));
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  carotch     : begin                                   {^}
                                llop1.lo := llop1.lo ! llop2.lo;
                                llop1.hi := llop1.hi ! llop2.hi;
                                end;
                  barch       : begin                                   {|}
                                llop1.lo := llop1.lo | llop2.lo;
                                llop1.hi := llop1.hi | llop2.hi;
                                end;
                  andch       : begin                                   {&}
                                llop1.lo := llop1.lo & llop2.lo;
                                llop1.hi := llop1.hi & llop2.hi;
                                end;
                  eqeqop      : begin                                   {==}
                                llop1.lo := ord((llop1.lo = llop2.lo) and
                                                (llop1.hi = llop2.hi));
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  exceqop     : begin                                   {!=}
                                llop1.lo := ord((llop1.lo <> llop2.lo) or
                                                (llop1.hi <> llop2.hi));
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  ltch        : begin                                   {<}
                                if unsigned then
                                   llop1.lo := ult64(llop1, llop2)
                                else
                                   llop1.lo := slt64(llop1, llop2);
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  gtch        : begin                                   {>}
                                if unsigned then
                                   llop1.lo := ugt64(llop1, llop2)
                                else
                                   llop1.lo := sgt64(llop1, llop2);
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  lteqop      : begin                                   {<=}
                                if unsigned then
                                   llop1.lo := ule64(llop1, llop2)
                                else
                                   llop1.lo := sle64(llop1, llop2);
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  gteqop      : begin                                   {>=}
                                if unsigned then
                                   llop1.lo := uge64(llop1, llop2)
                                else
                                   llop1.lo := sge64(llop1, llop2);
                                llop1.hi := 0;
                                etype := intPtr;
                                end;
                  ltltop      : begin                                   {<<}
                                shl64(llop1, long(llop2.lo).lsw);
                                etype := op^.left^.token.itype;
                                ExtendBitIntValue(llop1, etype);
                                end;
                  gtgtop      : begin                                   {>>}
                                if kindleft in [uintconst,ulongconst,ulonglongconst] then
                                   lshr64(llop1, long(llop2.lo).lsw)
                                else
                                   ashr64(llop1, long(llop2.lo).lsw);
                                etype := op^.left^.token.itype;
                                end;
                  plusch      : add64(llop1, llop2);                    {+}
                  minusch     : sub64(llop1, llop2);                    {-}
                  asteriskch  : umul64(llop1, llop2);                   {*}
                  slashch     : begin                                   {/}
                                if (llop2.lo = 0) and (llop2.hi = 0) then begin
                                   if not (kind in [normalExpression,
                                      autoInitializerExpression]) then
                                      Error(109)
                                   else if ((lint & lintOverflow) <> 0) then
                                      Error(129);
                                   llop2 := longlong1;
                                   end; {if}
                                if unsigned then
                                   udiv64(llop1, llop2)
                                else
                                   div64(llop1, llop2);
                                end;
                  percentch   : begin                                   {%}
                                if (llop2.lo = 0) and (llop2.hi = 0) then begin
                                   if not (kind in [normalExpression,
                                      autoInitializerExpression]) then
                                      Error(109)
                                   else if ((lint & lintOverflow) <> 0) then
                                      Error(129);
                                   llop2 := longlong1;
                                   end; {if}
                                if unsigned then
                                   umod64(llop1, llop2)
                                else
                                   rem64(llop1, llop2);
                                end;
                  otherwise: Error(57);
                  end; {case}
                  
               dispose(op^.right);
               op^.right := nil;
               dispose(op^.left);
               op^.left := nil;
               if ((lint & lintOverflow) <> 0) then begin
                  if op^.token.kind in [plusch,minusch,asteriskch,slashch] then
                     if etype^.baseType = cgWord then
                        if llop1.lo <> long(llop1.lo).lsw then
                           Error(128);
                  if op^.token.kind in [ltltop,gtgtop] then begin
                     if etype^.baseType in [cgWord,cgUWord] then
                        if (llop2.lo < 0) or (llop2.lo > 15) or (llop2.hi <> 0) then
                           Error(130);
                     if etype^.baseType in [cgLong,cgULong] then
                        if (llop2.lo < 0) or (llop2.lo > 31) or (llop2.hi <> 0) then
                           Error(130);
                     if etype^.baseType in [cgQuad,cgUQuad] then
                        if (llop2.lo < 0) or (llop2.lo > 63) or (llop2.hi <> 0) then
                           Error(130);
                     end; {if}
                  end; {if}
               SetIntToken(op^.token, llop1, etype);
               goto 1;
               end; {if}
            end; {if}

         if op^.right^.token.kind in [intconst,uintconst,longconst,ulongconst,
            longlongconst,ulonglongconst,floatconst,doubleconst,extendedconst,
            compconst] then
            if op^.left^.token.kind in [intconst,uintconst,longconst,ulongconst,
               longlongconst,ulonglongconst,floatconst,doubleconst,extendedconst,
               compconst] then
               begin
               if fenvAccess then
                  if kind in [normalExpression, autoInitializerExpression] then
                     goto 1;
               if (op^.right^.token.kind = compConst)
                  and (op^.left^.token.kind = compConst) then
                  ekind := compconst
               else if (op^.right^.token.kind in [extendedConst,compConst])
                  or (op^.left^.token.kind in [extendedConst,compConst]) then
                  ekind := extendedconst
               else if (op^.right^.token.kind = doubleConst)
                  or (op^.left^.token.kind = doubleConst) then
                  ekind := doubleconst
               else
                  ekind := floatconst;
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
                  slashch     : rop1 := rop1 / rop2;                    {/}

                  otherwise   : Error(66);              {illegal operation}
                  end; {case}
               if ekind = intconst then begin
                  op^.token.ival := long(op1).lsw;
                  op^.token.class := intConstant;
                  op^.token.kind := intConst;
                  op^.token.itype := intPtr;
                  end {if}
               else begin
                  op^.token.rval := rop1;
                  op^.token.class := realConstant;
                  op^.token.kind := ekind;
                  end; {else}
               end; {if}
1:
         end;

      plusplusop,                       {prefix ++}
      minusminusop,                     {prefix --}
      opplusplus,                       {postfix ++}
      opminusminus,                     {postfix --}
      sizeofsy,                         {sizeof}
      _Alignofsy,                       {_Alignof (erroneous uses)}
      alignofsy,
      castoper,                         {(type)}
      typedef,                          {(type-name)}
      tildech,                          {~}
      excch,                            {!}
      uminus,                           {unary -}
      uplus,                            {unary +}
      uand,                             {unary &}
      uasterisk: begin                  {unary *}
         op^.left := Pop;

         if op^.token.kind = sizeofsy then begin
            kindLeft := op^.left^.token.kind;
            if kindLeft <> typeofsy then begin
               if kindLeft = stringConst then begin
                  op^.token.kind := ulongConst;
                  op^.token.class := longConstant;
                  op^.token.ltype := uLongPtr;
                  op^.token.lval := op^.left^.token.sval^.length;
                  end {if}
               else begin
                  codeLoc := GetCodeLocation;
                  GenerateCode(op^.left);
                  codeLoc := RemoveCode(codeLoc);
                  if kindLeft = dotch then
                     if isBitfield then
                        Error(49);
                  if (IsVLAType(expressionType)) then begin
                     op^.castType := expressionType;
                     op^.vlaCode := pointer(codeLoc);
                     goto 4;
                     end; {if}
                  op^.token.kind := ulongConst;
                  op^.token.class := longConstant;
                  op^.token.ltype := uLongPtr;
                  op^.token.lval := expressionType^.size;
                  with expressionType^ do
                     if (size = 0)
                        or ((kind = arrayType) and not isVariableLength and (elements = 0)) then
                        Error(49);
                  end; {else}
               op^.left := nil;
               end; {if}
            end {if sizeofsy}
        
         else if op^.token.kind in [_Alignofsy,alignofsy] then begin
            {error case: operand of _Alignof is not a parenthesized type-name}
            Error(36);
            op^.token.kind := ulongConst;
            op^.token.class := longConstant;
            op^.token.ltype := uLongPtr;
            op^.token.lval := 1;
            dispose(op^.left);
            end {else if _Alignofsy} 

         else if op^.token.kind = castoper then begin
            class := op^.left^.token.class;
            if class in [intConstant,longConstant,longlongconstant,
               realConstant] then begin
               tp := Unqualify(op^.castType);
               while tp^.kind = definedType do
                  tp := tp^.dType;
               if tp^.kind = scalarType then begin
                  baseType := tp^.baseType;
                  if fenvAccess then
                     if kind in [normalExpression, autoInitializerExpression] then
                        if (baseType in [cgReal,cgDouble,cgComp,cgExtended])
                           or (class = realConstant) then
                           goto 3;
                  if (baseType < cgString) or (baseType in [cgQuad,cgUQuad])
                     then begin
                     if class = realConstant then begin
                        rop1 := RealVal(op^.left^.token);
                        if baseType = cgUQuad then
                           CnvXULL(llop1, rop1)
                        else
                           CnvXLL(llop1, rop1);
                        end {if}
                     else begin                      {handle integer constants}
                        GetLongLongVal(llop1, op^.left^.token, tp);
                        if op^.left^.token.kind = ulonglongconst then
                           rop1 := CnvULLX(llop1)
                        else
                           rop1 := CnvLLX(llop1);
                        end; {else if}
                     dispose(op^.left);
                     op^.left := nil;
                     ExtendBitIntValue(llop1, tp);
                     if baseType in [cgByte,cgWord] then begin
                        op^.token.kind := intConst;
                        op^.token.class := intConstant;
                        op^.token.itype := tp;
                        if tp^.cType = ctBool then
                           op^.token.ival := ord(rop1 <> 0.0)
                        else
                           op^.token.ival := long(llop1.lo).lsw;
                        if baseType = cgByte then
                           with op^.token do begin
                              ival := ival & $00FF;
                              if (ival & $0080) <> 0 then
                                 ival := ival | $FF00;
                              end; {with}
                        end {if}
                     else if baseType = cgUWord then begin
                        op^.token.kind := uintConst;
                        op^.token.class := intConstant;
                        op^.token.itype := tp;
                        op^.token.ival := long(llop1.lo).lsw;
                        end {else if}
                     else if baseType = cgUByte then begin
                        op^.token.kind := intConst;
                        op^.token.class := intConstant;
                        op^.token.itype := tp;
                        op^.token.ival := long(llop1.lo).lsw;
                        op^.token.ival := op^.token.ival & $00FF;
                        end {else if}
                     else if baseType = cgLong then begin
                        op^.token.kind := longConst;
                        op^.token.class := longConstant;
                        op^.token.ltype := tp;
                        op^.token.lval := llop1.lo;
                        end {else if}
                     else if baseType = cgULong then begin
                        op^.token.kind := ulongConst;
                        op^.token.class := longConstant;
                        op^.token.ltype := tp;
                        op^.token.lval := llop1.lo;
                        end {else if}
                     else if baseType = cgQuad then begin
                        op^.token.kind := longlongConst;
                        op^.token.class := longlongConstant;
                        op^.token.qtype := tp;
                        op^.token.qval := llop1;
                        end {else if}
                     else if baseType = cgUQuad then begin
                        op^.token.kind := ulonglongConst;
                        op^.token.class := longlongConstant;
                        op^.token.qtype := tp;
                        op^.token.qval := llop1;
                        end {else if}
                     else begin
                        case baseType of
                           cgReal:      op^.token.kind := floatConst;
                           cgDouble:    op^.token.kind := doubleConst;
                           cgExtended:  op^.token.kind := extendedConst;
                           cgComp:      op^.token.kind := compConst;
                           end; {case}
                        op^.token.class := realConstant;
                        LimitPrecision(rop1, baseType);
                        op^.token.rval := rop1;
                        end; {else if}
                     end; {if}
3:                end; {if}
               end; {if}
            end {else if castoper}

         else if not (op^.token.kind in
            [typedef,plusplusop,minusminusop,opplusplus,opminusminus,uand]) then
            begin
            if op^.left^.token.kind in [longlongconst,ulonglongconst,
               intconst,uintconst,longconst,ulongconst] then begin
               
               {evaluate a constant operation with long long operand}
               etype := op^.left^.token.itype;
               if kind = preprocessorExpression then
                  etype := PPType(etype);
               etype := IntegerBinaryConversions(etype, etype);
               GetLongLongVal(llop1, op^.left^.token, etype);
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  tildech     : begin                           {~}
                     llop1.lo := ~llop1.lo;
                     llop1.hi := ~llop1.hi;
                     end;
                  excch       : begin                           {!}
                     llop1.lo := ord((llop1.hi = 0) and (llop1.lo = 0));
                     llop1.hi := 0;
                     etype := intPtr;
                     end;
                  uminus      : begin                           {unary -}
                     llop1.lo := ~llop1.lo;
                     llop1.hi := ~llop1.hi;
                     llop1.lo := llop1.lo + 1;
                     if llop1.lo = 0 then
                        llop1.hi := llop1.hi + 1;
                     end;
                  uplus       : ;                               {unary +}
                  uasterisk   : Error(79);                      {unary *}
                  otherwise: Error(57);
                  end; {case}
                  SetIntToken(op^.token, llop1, etype);
               end {if}

            else if op^.left^.token.kind in
               [floatconst,doubleconst,extendedconst,compconst] then begin
               if fenvAccess then
                  if kind in [normalExpression, autoInitializerExpression] then
                     goto 4;
               ekind := op^.left^.token.kind;
               rop1 := RealVal(op^.left^.token);
               dispose(op^.left);
               op^.left := nil;
               case op^.token.kind of
                  uminus      : begin                        {unary -}
                     op^.token.class := realConstant;
                     op^.token.kind := ekind;
                     op^.token.rval := -rop1;
                     end;
                  uplus       : begin                        {unary +}
                     op^.token.class := realConstant;
                     op^.token.kind := ekind;
                     op^.token.rval := rop1;
                     end;
                  excch       : begin                        {!}
                     op^.token.class := intConstant;
                     op^.token.kind := intconst;
                     op^.token.ival := ord(rop1 = 0.0);
                     op^.token.itype := intPtr;
                     end;
                  otherwise   : begin                        {illegal operation}
                     Error(66);
                     op^.token.class := realConstant;
                     op^.token.kind := ekind;
                     op^.token.rval := rop1;
                     end;
                  end; {case}
               end; {if}
            end; {if}
4:
         end;

      otherwise: Error(57);
      end; {case}
   op^.next := stack;                     {place the operation on the operand stack}
   stack := op;
   end; {Operation}


   procedure Skip;

   { skip all tokens in the remainder of the expression             }

   begin {Skip}
   while not (token.kind in stopSym+[eofsy]) do
      NextToken;
   errorFound := true;
   end; {Skip}


   procedure DoGeneric;

   { process a generic selection expression                     }

   label 10;

   type
      typeListPtr = ^typeList;
      typeList = record
         next: typeListPtr;
         theType: typePtr;
         end;

   var
      lCodeGeneration: boolean;         {local copy of codeGeneration}
      tempExpr: tokenPtr;               {temporary to hold expression trees}
      controllingType: typeRecord;      {type of controlling expression}
      typesSeen: typeListPtr;           {types that already have associations}
      tl: typeListPtr;                  {temporary type list pointer}
      resultExpr: tokenPtr;             {the result expression}
      defaultExpr: tokenPtr;            {the default expression}
      currentType: typePtr;             {the type for the current association}
      typesMatch: boolean;              {does the current type match}
      foundMatch: boolean;              {have we found a matching type?}
      foundDefault: boolean;            {have we found the default case?}

   begin {DoGeneric}
   if not expectingTerm then begin
      Error(36);
      Skip;
      goto 1;
      end; {if}
   NextToken;
   if token.kind <> lparench then begin
      Error(36);
      Skip;
      goto 1;
      end; {if}
   new(op);                             {record it like a parenthesized expr}
   op^.next := opStack;
   op^.left := nil;
   op^.middle := nil;
   op^.right := nil;
   opStack := op;
   op^.token.kind := lparench;
   op^.token.class := reservedSymbol;
   parenCount := parenCount+1;
   NextToken;                           {process the controlling expression}
   tempExpr := ExpressionTree(normalExpression, [commach]);
   lCodeGeneration := codeGeneration;
   codeGeneration := false;
   GenerateCode(tempExpr);
   codeGeneration := lCodeGeneration and (numErrors = 0);
                                        {get controlling type after conversions}
   if expressionType^.kind = functionType then begin
      controllingType.size := cgPointerSize;
      controllingType.kind := pointerType;
      controllingType.pType := expressionType;
      end {if}
   else if expressionType^.kind in [structType,unionType] then begin
      controllingType.size := expressionType^.size;
      controllingType.kind := definedType;
      controllingType.dType := expressionType;
      end {else if}
   else
      controllingType := expressionType^;
   if controllingType.kind = arrayType then begin
      controllingType.kind := pointerType;
      controllingType.size := cgPointerSize;
      end; {if}
   controllingType.qualifiers := [];
   controllingType.saveDisp := 0;

   typesSeen := nil;
   resultExpr := nil;
   defaultExpr := nil;
   foundMatch := false;
   foundDefault := false;
   while token.kind = commach do begin  {process the generic associations}
      NextToken;
      typesMatch := false;
      if token.kind <> defaultsy then begin   
         if not (token.kind in specifierQualifierListElement) then begin
            Error(26);
            while not (token.kind in [colonch,commach,rparench,eofsy]) do
               NextToken;
            end; {if}
         currentType := TypeName;       {get the type name}
         if (currentType^.size = 0) or (currentType^.kind = functionType) then
            Error(133);
         if IsVariablyModifiedType(currentType) then
            Error(201);
         treatNoParmsFnAsPrototyped := cStd >= c23;
         tl := typesSeen;               {check if it is a duplicate}
         while tl <> nil do begin
            if StrictCompTypes(currentType, tl^.theType) then begin
               Error(158);
               goto 10;
               end; {if}
            tl := tl^.next;
            end; {while}
         new(tl);                       {record it as seen}
         tl^.next := typesSeen;
         tl^.theType := currentType;
         typesSeen := tl;
                                        {see if the types match}
         typesMatch := StrictCompTypes(currentType, controllingType);
         if typesMatch then begin
            if foundMatch then begin    {sanity check - should never happen}
               typesMatch := false;
               Error(158);
               end; {if}
            foundMatch := true;
            end; {if}
         treatNoParmsFnAsPrototyped := false;
         end {if}
      else begin                        {handle default association}
         NextToken;
         currentType := nil;
         if foundDefault then
            Error(159);
         foundDefault := true;
         end; {else}
10:
      if token.kind = colonch then      {skip the colon}
         NextToken
      else
         Error(29);
                                        {get the expression in this association}
      if (currentType = nil) and (defaultExpr = nil) and not foundMatch then
         defaultExpr := ExpressionTree(kind, [commach,rparench])
      else if typesMatch then
         resultExpr := ExpressionTree(kind, [commach,rparench])
      else
         tempExpr := ExpressionTree(normalExpression, [commach,rparench]);
      end; {while}
   if token.kind <> rparench then
      Error(12);
   while typesSeen <> nil do begin      {dispose of the list of types seen}
      tl := typesSeen^.next;
      dispose(typesSeen);
      typesSeen := tl;
      end; {while}

   if not foundMatch then               {use default if no match found}
      if foundDefault then
         resultExpr := defaultExpr;
   if not (foundMatch or foundDefault) then begin
      Error(160);                       {report error & synthesize a token}
      resultExpr := pointer(Calloc(sizeof(tokenRecord)));
      resultExpr^.token.kind := intconst;
      resultExpr^.token.class := intConstant;
      resultExpr^.token.itype := intPtr;
      {resultExpr^.token.ival := 0;}
      end; {if}
   if resultExpr <> nil then begin
      resultExpr^.next := stack;        {stack the resulting expression}
      stack := resultExpr;
      end; {if}
   expectingTerm := false;
   end; {DoGeneric}


   procedure DoCompoundLiteral;

   { process a compound literal expression                      }
   
   label 1;
   
   var
      id: identPtr;
      sp: tokenPtr;
      vlaCode: ptr;
   
   begin {DoCompoundLiteral}
   if kind in [preprocessorExpression,integerConstantExpression] then begin
      op := opStack;
      while op <> nil do begin
         if op^.token.kind = sizeofsy then
            goto 1;
         op := op^.next;
         end; {while}
      Error(41);
      errorFound := true;
      end; {if}
1:
   vlaCode := opStack^.vlaCode;
   id := MakeCompoundLiteral(opStack^.castType);
   opStack := opStack^.next;
   
   {create an operand on the stack}
   new(sp);
   if id^.class = staticsy then
      sp^.token.kind := ident
   else
      sp^.token.kind := compoundliteral;
   sp^.token.class := identifier;
   sp^.token.symbolPtr := id;
   sp^.token.name := id^.name;
   sp^.id := id;
   sp^.next := stack;
   sp^.left := nil;
   sp^.middle := nil;
   sp^.right := nil;
   sp^.vlaCode := vlaCode;
   stack := sp;
   
   ComplexTerm;
   expectingTerm := false;
   end; {DoCompoundLiteral}


begin {ExpressionTree}
opStack := nil;
stack := nil;
if token.kind = typedef then            {handle typedefs that are hidden}
   if FindSymbol(token,variableSpace,false,true) <> nil then
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
            case token.kind of
               truesy: begin
                  token.kind := intconst;
                  token.class := intConstant;
                  token.itype := boolPtr;
                  token.ival := 1;
                  end; {case truesy}
               
               falsesy: begin
                  token.kind := intconst;
                  token.class := intConstant;
                  token.itype := boolPtr;
                  token.ival := 0;
                  end; {case falsesy}

               otherwise: ;
               end; {case}
            new(sp);
            sp^.token := token;
            sp^.next := stack;
            sp^.left := nil;
            sp^.middle := nil;
            sp^.right := nil;
            stack := sp;
            if kind in [preprocessorExpression,integerConstantExpression] then
               if token.kind in [stringconst,floatconst,doubleconst,
                  extendedconst,compconst] then begin
                  if kind = integerConstantExpression then begin
                     op := opStack;
                     if token.kind <> stringconst then
                        if op <> nil then
                           if op^.token.kind = castoper then
                              if op^.casttype^.kind = scalarType then
                                 if op^.casttype^.baseType in [cgByte,cgUByte,
                                    cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad]
                                    then goto 3;
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
         if token.kind in specifierQualifierListElement then begin
            doingSizeof := false;
            doingAlignof := false;
            if opStack <> nil then
               if opStack^.token.kind = sizeofsy then
                  doingSizeof := true
               else if opStack^.token.kind in [_Alignofsy,alignofsy] then
                  doingAlignof := true;
            codeLoc := GetCodeLocation;
            lVLATrees := vlaTrees;
            tType := TypeName;
            while vlaTrees > lVLATrees + 1 do begin
               Gen0t(pc_bno, cgULong);
               vlaTrees := vlaTrees - 1;
               end; {while}
            codeLoc := RemoveCode(codeLoc);
            vlaTrees := lVLATrees;
            Match(rparench,12);
            if (doingSizeof and (token.kind <> lbracech)) or doingAlignof then
               begin

               {handle a sizeof or alignof operator}
               if doingAlignof or not IsVLAType(tType) then begin
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
                  sp^.token.ltype := uLongPtr;
                  if doingSizeof then
                     sp^.token.lval := tType^.size
                  else {if doingAlignof then}
                     sp^.token.lval := 1;
                  with tType^ do
                     if (size = 0)
                        or ((kind = arrayType) and not isVariableLength and (elements = 0)) then
                        Error(133);
                  sp^.next := stack;
                  stack := sp;
                  end {if}
               else begin
                  {handle sizeof(VLA type)}
                  new(sp);
                  sp^.left := nil;
                  sp^.middle := nil;
                  sp^.right := nil;
                  sp^.castType := tType;
                  sp^.vlaCode := pointer(codeLoc);
                  sp^.token.kind := typeofsy;
                  sp^.token.class := reservedWord;
                  sp^.next := stack;
                  stack := sp;
                  end; {else} 
               expectingTerm := false;
               end {if}
            else {doing a cast} begin

               {handle a type cast}
               new(op);                 {stack the cast operator}
               op^.left := nil;
               op^.middle := nil;
               op^.right := nil;
               op^.castType := tType;
               op^.vlaCode := pointer(codeLoc);
               op^.token.kind := castoper;
               op^.token.class := reservedWord;
               op^.next := opStack;
               opStack := op;
               end; {else}
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
      else if (token.kind = lbracech)   {handle a compound literal}
         and (opstack <> nil) and (opStack^.token.kind = castoper) then begin
         DoCompoundLiteral
         end {else if}
      else if token.kind = _Genericsy then {handle _Generic}
         DoGeneric
      else begin                        {handle an operation...}
         if expectingTerm then          {convert unary operators to separate tokens}
            if token.kind in [asteriskch,minusch,plusch,andch] then
               case token.kind of
                  asteriskch: token.kind := uasterisk;
                  minusch   : token.kind := uminus;
                  andch     : token.kind := uand;
                  plusch    : token.kind := uplus;
                  otherwise : Error(57);
                  end; {case}
         if icp[token.kind] = notAnOperation then
            done := true                {end of expression found...}
         else if (token.kind in stopSym) and (parenCount = 0) 
            and ((opStack = nil) or (opStack^.token.kind <> questionch)) then
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
                  Error(161);
                  errorFound := true;
                  end; {if}
            if token.kind in         {make sure we get what we want}
               [plusplusop,minusminusop,sizeofsy,_Alignofsy,alignofsy,tildech,
                excch,uasterisk,uminus,uplus,uand] then begin
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
        	  done2 := false;	{do operations with less precedence}
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
if expressionType^.kind in [pointerType,arrayType,functionType] then
   expressionType := uLongPtr;
if expressionType^.kind = scalarType then begin
   bt := UsualUnaryConversions;
   case bt of
      cgByte,cgUByte,cgWord,cgUWord:
         Gen1t(pc_ldc, 0, cgWord);
      cgLong,cgULong:
         GenLdcLong(0);
      cgQuad,cgUQuad:
         GenLdcQuad(longlong0);
      cgReal,cgDouble,cgComp,cgExtended:
         GenLdcReal(0.0);
      otherwise:
         Error(47);
      end; {case}
   expressionType := intPtr;
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
if id^.itype^.kind = scalarType then
   tp := id^.itype^.baseType
else {if id^.itype^.kind in [pointerType,arrayType] then}
   tp := cgULong;
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
if (tp^.kind = scalarType) and (tp^.cType = ctBool) then begin
   CompareToZero(pc_neq);
   end {if}
else if (tp^.kind = scalarType) and (expressionType^.kind = scalarType) then begin
   rt := tp^.baseType;
   et := expressionType^.baseType;
   if (rt <> et) or (rt in [cgReal,cgDouble,cgComp]) then
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
            [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad] then
            Gen2(pc_cnv, ord(Unary(expressionType^.baseType)),
               ord(cgULong))
         else if doDispose then
            Error(40);

      arrayType,pointerType,functionType: ;

      enumConst,enumType,definedType,structType,unionType:
         if doDispose then
            Error(40);

      otherwise: Error(57);

      end; {case}
   end {else if}
else if expressionType^.kind in [pointerType,arrayType,functionType] then begin
   case tp^.kind of  

      scalarType:
         if tp^.baseType in
            [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad] then
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
BitIntConversion(tp, expressionType);
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
{ variables:                                                 }
{         expressionType - set to the type of the field      }

label 1;

var
   ip: identPtr;                        {for scanning for the field}
   qualifiers: typeQualifierSet;        {type qualifiers}

begin {DoSelection}
expressionType := intPtr;               {set defaults in case there is an error}
size := 0;
if tree^.token.class = identifier then begin
   qualifiers := lType^.qualifiers;
   while lType^.kind = definedType do begin
      lType := lType^.dType;
      qualifiers := qualifiers + lType^.qualifiers;
      end; {while}
   if lType^.kind in [structType,unionType] then begin
      ip := lType^.fieldList;           {find a matching field}
      while ip <> nil do begin
         if ip^.name^ = tree^.token.name^ then begin
            if ip^.isForwardDeclared then 
               ResolveForwardReference(ip);
            size := ip^.disp;           {match found - record parameters}
            expressionType := MakeQualifiedType(ip^.itype, qualifiers);
            bitDisp := ip^.bitDisp;
            bitSize := ip^.bitSize;
            isBitField := (bitSize+bitDisp) <> 0;
            unsigned := (ip^.itype^.baseType in [cgUByte,cgUWord,cgULong])
                        or (ip^.itype^.cType = ctBool);
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
if kind in [ident,compoundliteral] then begin
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


procedure ChangePointer (op: pcodes; elementType: typePtr; tp: baseTypeEnum);

{ Add or subtract an integer to a pointer			}
{                                                               }
{ The stack has a pointer and an integer (integer on TOS).      }
{ The integer is removed, multiplied by the element size, and   }
{ either added to or subtracted from the pointer; the result    }
{ replaces the pointer on the stack                             }
{                                                               }
{ parameters:                                                   }
{    op - operation (pc_adl or pc_sbl)                          }
{    elementType - type of one pointer element                  }
{    tp - type of the integer operand                           }

var
   size: longint;                       {size of one array element}

begin {ChangePointer}
if checkNullPointers then
   Gen0(pc_ckn);
if (elementType^.kind = arrayType) and elementType^.isVariableLength then begin
   Gen2(pc_cnv, ord(tp), ord(cgLong));
   Gen2t(pc_lod, elementType^.sizeLLN, 0, cgULong);
   Gen0(pc_mpl);
   Gen0(op);
   end {if}
else begin
   size := elementType^.size;
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
      cgLong,cgULong,cgQuad,cgUQuad: begin
         if tp in [cgQuad,cgUQuad] then 
            Gen2(pc_cnv, ord(tp), ord(cgLong));
         if size <> 1 then begin
            GenLdcLong(size);
            if tp in [cgLong,cgQuad] then
               Gen0(pc_mpl)
            else
               Gen0(pc_uml);
            end; {if}
         Gen0(op);
         end;
      otherwise:
         Error(66);
      end; {case}
   end; {else}
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
   isConst: boolean;                    {is this a constant?}
   isNullPtrConst: boolean;             {is this a null pointer constant?}
   isVolatile: boolean;                 {is this a volatile op?}
   lType: typePtr;                      {type of operands}
   kind: typeKind;                      {temp type kind}
   size: longint;                       {size of an array element}
   t1: integer;                         {temporary work space label number}
   tlastWasNullPtrConst: boolean;       {temp lastWasNullPtrConst}
   tp: tokenPtr;                        {work pointer}
   tType: typePtr;                      {temp type of operand}

   lbitDisp,lbitSize: integer;          {for temp storage}
   lisBitField: boolean;
   ldoDispose: boolean;                 {local copy of doDispose}


   procedure CheckForIncompleteStructType;
   
   { Check if expressionType is an incomplete struct/union type. }
   
   var
      tp: typePtr;                      {the type}
   
   begin
   tp := expressionType;
   while tp^.kind = definedType do
      tp := tp^.dType;
   if tp^.kind in [structType,unionType] then
      if tp^.size = 0 then
         Error(187);
   end;


   function ExpressionKind (tree: tokenPtr): typeKind;

   { returns the type of an expression                           }
   {                                                             }
   { This subroutine is used to see if + and - operations        }
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
   while expressionType^.kind = definedType do
      expressionType := expressionType^.dType;
   ExpressionKind := expressionType^.kind;

   doDispose := ldoDispose;             {restore the volatile variables}
   codeGeneration := lCodeGeneration and (numErrors = 0);
   expressionType := lexpressionType;
   end; {ExpressionKind}


   procedure LoadAddress (tree: tokenPtr; nullCheck: boolean);

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
         expressionType := MakePointerTo(iType);
         end; {with}
      end {if}
   else if tree^.token.kind = compoundliteral then begin

      {evaluate a compound literal and load its address}
      InsertCode(tree^.vlaCode);
      AutoInit(tree^.id, 0, true);
      tree^.token.kind := ident;
      LoadAddress(tree, false);
      tree^.token.kind := compoundliteral;
      Gen0t(pc_bno, cgULong);
      if tree^.vlaCode <> nil then
         Gen0t(pc_bno, cgULong);
      end {if}
   else if tree^.token.kind = uasterisk then begin

      {load the address of the item pointed to by the pointer}
      GenerateCode(tree^.left);
      if nullCheck then
         Gen0(pc_ckp);
      isBitField := false;
      if not (expressionType^.kind in [pointerType,arrayType,functionType]) then
         Error(79);
      end {else if}
   else if tree^.token.kind = dotch then begin

      {load the address of a field of a record}
      LoadAddress(tree^.left, nullCheck);
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
         expressionType := MakePointerTo(expressionType);
         end {if}
      else
         Error(79);
      end {else if}
   else if tree^.token.kind = castoper then begin

      {load the address of a field of a record}
      LoadAddress(tree^.left, nullCheck);
      expressionType := Unqualify(tree^.castType);
      if expressionType^.kind <> arrayType then
         expressionType := MakePointerTo(expressionType);
      end {else if}

   else if ExpressionKind(tree) in [arrayType,pointerType,structType,unionType]
      then begin
      GenerateCode(tree);
      if nullCheck then
         Gen0(pc_ckp);
      end {else if}
   else begin
      expressionType := intPtr;         {set default type in case of error}
      if doDispose then                 {prevent spurious errors}
         Error(78);
      end; {else}
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

         scalarType: begin
            case tp of

               cgByte,cgUByte,cgWord,cgUWord: begin
                  Gen1t(pc_ldc, 1, cgWord);
                  if inc then
                     Gen0(pc_adi)
                  else
                     Gen0(pc_sbi);
                  if expressionType^.cType = ctBool then begin
                     CompareToZero(pc_neq);
                     expressionType := boolPtr;
                     end {if}
                  end;

               cgLong,cgULong: begin
                  GenLdcLong(1);
                  if inc then
                     Gen0(pc_adl)
                  else
                     Gen0(pc_sbl);
                  end;

               cgQuad,cgUQuad: begin
                  GenLdcQuad(longlong1);
                  if inc then
                     Gen0(pc_adq)
                  else
                     Gen0(pc_sbq);
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
            TruncateUBitInt(expressionType);
            end;

         pointerType,arrayType: begin
            if checkNullPointers then
               Gen0(pc_ckp);
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
   if (tree^.token.kind = ident)
      and ((tree^.id^.iType^.kind in [scalarType,pointerType])
      or ((tree^.id^.iType^.kind = arrayType) and (tree^.id^.storage = parameter)))
      then
      with tree^.id^ do begin

         {check for ++ or -- of a constant}
         if tqConst in iType^.qualifiers then
            Error(93);

         {do an efficient ++ or -- on a named location}
         if iType^.kind = scalarType then begin
            iSize := 1;
            baseType := iType^.baseType;
            if (baseType in [cgReal,cgDouble,cgComp,cgExtended,cgQuad,cgUQuad])
               or (iType^.cType in [ctBool,ctUBitInt]) then begin

               {do real, bool, or unsigned _BitInt inc or dec}
               LoadScalar(tree^.id);    {load the value}
               if pc_l in [pc_lli,pc_lld] then
                  if iType^.cType in [ctBool,ctFloat,ctDouble,ctLongDouble,
                     ctComp] then begin
                     t1 := GetTemp(ord(iType^.size));
                     Gen2t(pc_cop, t1, 0, iType^.baseType);
                     end; {if}
               tp := baseType;
               expressionType := Unqualify(iType);
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
                  if iType^.cType in [ctBool,ctFloat,ctDouble,ctLongDouble,
                     ctComp] then begin
                     Gen0t(pc_pop, iType^.baseType);
                     Gen2t(pc_lod, t1, 0, iType^.baseType);
                     Gen0t(pc_bno, iType^.baseType);
                     FreeTemp(t1, ord(iType^.size));
                     end {if}
                  else
                     IncOrDec(pc_l = pc_lld);
               goto 1;
               end {if}
            else if baseType = cgVoid then
               Error(65);
            end {if}
         else {if iType^.kind in [pointerType,arrayType] then} begin
            lSize := iType^.pType^.size;
            if lSize = 0 then
               Error(122);
            if (long(lSize).msw <> 0) or checkNullPointers then begin

               {handle inc/dec of >64K or with null pointer check}
               LoadScalar(tree^.id);
               if checkNullPointers then
                  Gen0(pc_ckp);
               GenLdcLong(lSize);
               if pc_l in [pc_lli,pc_lil] then
                  Gen0(pc_adl)
               else
                  Gen0(pc_sbl);
               with tree^.id^ do
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
         expressionType := Unqualify(itype);
         end {with}
   else begin

      {do an indirect ++ or --}
      LoadAddress(tree, checkNullPointers);     {get the address to save to}
      if expressionType^.kind = arrayType then
         expressionType := expressionType^.aType
      else if expressionType^.kind = pointerType then
         expressionType := expressionType^.pType;
      if tqConst in expressionType^.qualifiers then
         Error(93);
      if expressionType^.kind = scalarType then
         if expressionType^.baseType in 
            [cgByte,cgUByte,cgWord,cgUWord,cgReal,cgDouble,cgComp,cgExtended] then
            tp := expressionType^.baseType
         else
            tp := UsualUnaryConversions
      else begin
         if expressionType^.kind in
            [structType,unionType,definedType,functionType] then
            Error(66);
         tp := UsualUnaryConversions;
         end; {else}
      if (tp in [cgByte,cgUByte,cgWord,cgUword])
         and not (expressionType^.cType in [ctBool,ctUBitInt])
         and not isBitField then
         Gen0t(pc_i, tp)                {do indirect inc/dec}
      else if tp = cgVoid then
         Error(65)
      else begin
         t1 := GetTemp(cgLongSize);
         Gen2t(pc_str, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         FreeTemp(t1, cgLongSize);
                                        {load the value}
         if isBitField then begin
            if unsigned then
               Gen2t(pc_lbu, bitDisp, bitSize, tp)
            else
               Gen2t(pc_lbf, bitDisp, bitSize, tp);
            end {if}
         else
            Gen2t(pc_ind, ord(tqVolatile in expressionType^.qualifiers), 0, tp);
         if pc_l in [pc_lli,pc_lld] then
            if (expressionType^.kind = scalarType) and
               (expressionType^.cType in
                  [ctBool,ctFloat,ctDouble,ctLongDouble,ctComp])
               then begin
               t1 := GetTemp(ord(expressionType^.size));
               Gen2t(pc_cop, t1, 0, expressionType^.baseType);
               end; {if}
         IncOrDec(pc_l in [pc_lli,pc_lil]); {do the ++ or --}
         if isBitField then             {copy the value}
            Gen2t(pc_cbf, bitDisp, bitSize, tp)
         else
            Gen0t(pc_cpi, tp);
         Gen0t(pc_bno, tp);
         if pc_l in [pc_lli,pc_lld] then {correct the value for postfix ops}
            if (expressionType^.kind = scalarType) and
               (expressionType^.cType in
                  [ctBool,ctFloat,ctDouble,ctLongDouble,ctComp])
               then begin
               Gen0t(pc_pop, expressionType^.baseType);
               Gen2t(pc_lod, t1, 0, expressionType^.baseType);
               Gen0t(pc_bno, expressionType^.baseType);
               FreeTemp(t1, ord(expressionType^.size));
               end {if}
            else
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
      hasVarargs: boolean;              {varargs call with 1+ varargs passed?}
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
         ldoDispose: boolean;           {local copy of doDispose}
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

      if (lint & lintPrintf) <> 0 then
         if fType^.varargs then
            if not indirect then
               if ftree^.id^.storage <> private then
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
         if pCount <> 0 then
            if ftype^.varargs and (pcount < 0) then
               hasVarargs := true
            else
               Error(85);
         end; {if}

        tp := parms;

      {generate the parameters}
      numParms := 0;
      lDoDispose := doDispose;
      doDispose := false;
      while tp <> nil do begin
         if tp^.middle <> nil then begin
            GenerateCode(tp^.middle);
            if expressionType^.kind in [structType,unionType,definedType]
               then begin
               tType := expressionType;
               while tType^.kind = definedType do
                  tType := tType^.dType;
               if tType^.kind in [structType,unionType] then begin
                  if tType^.size & $FFFF8000 <> 0 then
                     Error(61);
                  Gen1t(pc_ldc, long(tType^.size).lsw, cgWord);
                  Gen0(pc_psh);
                  end; {if}
               end; {if}
            if fmt <> fmt_none then begin
               new(tfp);
               tfp^.next := fp;
               tfp^.tk := tp^.middle;
               tfp^.ty := expressionType;
               fp := tfp;
               end; {if}
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
   hasVarargs := false;                 {assume no variable arguments}
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
      if ftype^.kind = pointerType then
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
            if checkNullPointers then
               Gen0(pc_ckp);
            expressionType := fntype;
            Gen1t(pc_cui, ord(hasVarargs and strictVararg),
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
            Gen1tName(pc_cup, ord(hasVarargs and strictVararg),
               UsualUnaryConversions, fname);
            end; {else}
         if hasVarargs then
            hasVarargsCall := true;
	 end {if}
      else
	 GenTool(pc_tl1, ftype^.toolNum, long(ftype^.ftype^.size).lsw,
            ftype^.dispatcher);
      expressionType := ftype^.fType;
      CheckForIncompleteStructType;
      end; {else}
   end; {FunctionCall}      


   procedure CompareCompatible (var t1,t2: typePtr; equality: boolean);

   { Make sure that it is legal to compare t1 to t2             }
   {                                                            }
   { parameters:                                                }
   {    t1,t2 - the types to compare                            }
   {    equality - is this for an (in)equality comparison?      }

   begin {CompareCompatible}
   if t1^.kind = functionType then
      t1 := MakePointerTo(t1);
   if t2^.kind = functionType then
      t2 := MakePointerTo(t2);
   if t1^.kind in [pointerType,arrayType] then begin
      if t2^.kind in [pointerType,arrayType] then begin
         if CompTypes(t1^.ptype, t2^.ptype) then begin
            if not looseTypeChecks and not equality then
               if t1^.ptype^.kind = functionType then
                  Error(47);
            end {if}
         else if (t1^.ptype^.kind=scalarType) and (t1^.ptype^.basetype=cgVoid)
         then begin
            if not looseTypeChecks then begin
               if not equality then
                  Error(47)
               else if not tlastWasNullPtrConst then
                  if t2^.ptype^.kind = functionType then
                     Error(47);
               end {if}
            end {else if}
         else if (t2^.ptype^.kind=scalarType) and (t2^.ptype^.basetype=cgVoid)
         then begin
            if not looseTypeChecks then begin
               if not equality then
                  Error(47)
               else if not lastWasNullPtrConst then
                  if t1^.ptype^.kind = functionType then
                     Error(47);
               end {if}
            end {else if}
         else
            Error(47);
         t2 := ulongPtr;
         end {if}
      else if not lastWasNullPtrConst
         or (not equality and not looseTypeChecks) then
         Error(47);
      t1 := ulongPtr;
      end {if}
   else if t2^.kind in [pointerType,arrayType] then begin
      if not equality or not tlastWasNullPtrConst then
         Error(47);
      t2 := ulongPtr;
      end; {else if}
   end; {CompareCompatible}


   procedure CheckDivByZero (var divisor: tokenType; opType: typePtr);

   { Check for division by (constant) zero.                     }
   {                                                            }
   { parameters:                                                }
   {    divisor - token for divisor                             }
   {    opType - type of the result of the operation            }

   begin {CheckDivByZero}
   if opType^.kind = scalarType then
      if opType^.baseType in 
         [cgByte,cgWord,cgUByte,cgUWord,cgLong,cgULong,cgQuad,cgUQuad] then
         if ((divisor.class = intConstant) and (divisor.ival = 0))
            or ((divisor.class = longConstant) and (divisor.lval = 0))
            or ((divisor.class = longlongConstant) 
               and (divisor.qval.lo = 0) and (divisor.qval.hi = 0))
            or ((divisor.class = realConstant) and (divisor.rval = 0.0)) then
            Error(129);
   end; {CheckDivByZero}


   procedure CheckShiftOverflow (var shiftCountTok: tokenType; opType: typePtr);

   { Check for invalid (too large or negative) shift count.     }
   {                                                            }
   { parameters:                                                }
   {    shiftCountTok - token for shift count                   }
   {    opType - type of the result of the operation            }

   var
      shiftCount: longint;

   begin {CheckShiftOverflow}
   if shiftCountTok.class = intConstant then
      shiftCount := shiftCountTok.ival
   else if shiftCountTok.class = longConstant then
      shiftCount := shiftCountTok.lval
   else if shiftCountTok.class = longlongConstant then begin
      if shiftCountTok.qval.hi = 0 then
         shiftCount := shiftCountTok.qval.lo
      else
         shiftCount := -1;
      end {else if}
   else
      shiftCount := 0;

   if (shiftCount <> 0) and (opType^.kind = scalarType) then begin
      if opType^.baseType in [cgByte,cgWord,cgUByte,cgUWord] then
         if (shiftCount < 0) or (shiftCount > 15) then
            Error(130);
      if opType^.baseType in [cgLong,cgULong] then
         if (shiftCount < 0) or (shiftCount > 31) then
            Error(130);
      if opType^.baseType in [cgQuad,cgUQuad] then
         if (shiftCount < 0) or (shiftCount > 63) then
            Error(130);
      end; {if}
   end; {CheckShiftOverflow}


begin {GenerateCode}
isConst := false;
isNullPtrConst := false;
case tree^.token.kind of

   parameterOper:
      FunctionCall(tree);

   ident: begin
      tType := tree^.id^.itype;
      while tType^.kind = definedType do
         tType := tType^.dType;
      case tType^.kind of                                        

         scalarType: begin
            LoadScalar(tree^.id);
            expressionType := tree^.id^.itype;
            end;

         pointerType: begin
            LoadScalar(tree^.id);                          
            expressionType := tree^.id^.itype;
            end;


         arrayType: begin
            LoadAddress(tree, false);                             
            expressionType := expressionType^.ptype;
            end;

         functionType:
            LoadAddress(tree, false);                             

         structType, unionType: begin
            LoadAddress(tree, false);                             
            if expressionType^.kind = pointerType then
               expressionType := expressionType^.ptype;
            CheckForIncompleteStructType;
            end;

         enumConst: begin
            Gen1t(pc_ldc, tree^.id^.itype^.eval, cgWord);  
            expressionType := intPtr;
            end;

         end; {case}
      end;

   compoundLiteral: begin
      InsertCode(tree^.vlaCode);
      AutoInit(tree^.id, 0, true);
      tree^.token.kind := ident;
      ldoDispose := doDispose;
      doDispose := false;
      GenerateCode(tree);
      doDispose := ldoDispose;
      tree^.token.kind := compoundliteral;
      if expressionType^.kind = scalarType then
         Gen0t(pc_bno, expressionType^.baseType)
      else
         Gen0t(pc_bno, cgULong);
      if tree^.vlaCode <> nil then
         if expressionType^.kind = scalarType then
            Gen0t(pc_bno, expressionType^.baseType)
         else
            Gen0t(pc_bno, cgULong);
      end;

   intConst,uintConst:
      begin
      Gen1t(pc_ldc, tree^.token.ival, cgWord);
      isConst := true;
      lastconst := tree^.token.ival;
      isNullPtrConst := tree^.token.ival = 0;
      expressionType := tree^.token.itype;
      end; {case intConst,uintConst}

   longConst,ulongConst: begin
      GenLdcLong(tree^.token.lval);
      isConst := true;
      lastconst := tree^.token.lval;
      isNullPtrConst := tree^.token.lval = 0;
      expressionType := tree^.token.ltype;
      end; {case longConst}

   longlongConst,ulonglongConst: begin
      GenLdcQuad(tree^.token.qval);
      if (tree^.token.qval.hi = 0) and (tree^.token.qval.lo >= 0) then begin
         isConst := true;
         lastconst := tree^.token.qval.lo;
         end; {if}
      isNullPtrConst := (tree^.token.qval.hi = 0) and (tree^.token.qval.lo = 0);
      expressionType := tree^.token.qtype;
      end; {case longlongConst}

   floatConst: begin
      GenLdcReal(tree^.token.rval);
      expressionType := floatPtr;
      end; {case floatConst}

   doubleConst: begin
      GenLdcReal(tree^.token.rval);
      expressionType := doublePtr;
      end; {case doubleConst}

   extendedConst: begin
      GenLdcReal(tree^.token.rval);
      expressionType := extendedPtr;
      end; {case extendedConst}

   compConst: begin
      GenLdcReal(tree^.token.rval);
      expressionType := compPtr;
      end; {case compConst}

   stringConst: begin
      GenS(pc_lca, tree^.token.sval);
      expressionType := StringType(tree^.token.prefix);
      stringConstSize := tree^.token.sval^.length;
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
            LoadAddress(tree^.left, checkNullPointers);
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
            while lType^.kind = definedType do
               lType := lType^.dType;
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
         LoadAddress(tree^.left, checkNullPointers);
         lisBitField := isBitField;
         lbitDisp := bitDisp;
         lbitSize := bitSize;
         t1 := GetTemp(cgLongSize);
         Gen2t(pc_str, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         Gen2t(pc_lod, t1, 0, cgULong);
         lType := expressionType^.pType;
         isVolatile := tqVolatile in lType^.qualifiers;
         if isBitField then begin
            if unsigned then
               Gen2t(pc_lbu, bitDisp, bitSize, lType^.baseType)
            else
               Gen2t(pc_lbf, bitDisp, bitSize, lType^.baseType);
            end {if}
         else if lType^.kind = pointerType then
            Gen2t(pc_ind, ord(isVolatile), 0, cgULong)
         else
            Gen2t(pc_ind, ord(isVolatile), 0, lType^.baseType);
         end; {else}
      if tqConst in lType^.qualifiers then
         Error(93);
      if doingScalar 
         and (ltype^.kind = arrayType) and (id^.storage = parameter) then
         kind := pointerType
      else
         kind := lType^.kind;
      GenerateCode(tree^.right);
      if expressionType^.kind <> scalarType then
         Error(66);
      if tree^.token.kind in [gtgteqop,ltlteqop] then
         if kind = scalarType then
            if expressionType^.kind = scalarType then begin
               if expressionType^.baseType in 
                  [cgReal,cgDouble,cgComp,cgExtended,cgVoid] then
                  Error(66);
               et := UsualUnaryConversions;
               if ltype^.baseType in [cgQuad,cgUQuad] then begin
                  if not (et in [cgWord,cgUWord]) then begin
                     Gen2(pc_cnv, et, ord(cgWord));
                     end; {if}
                  expressionType := lType;
                  end {if}
               else
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
               ChangePointer(pc_adl, lType^.pType, UsualUnaryConversions);
               expressionType := lType;
               end
            else if et in [cgWord,cgUWord] then
               Gen0(pc_adi)
            else if et in [cgLong,cgULong] then
               Gen0(pc_adl)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_adq)
            else if et in [cgReal,cgDouble,cgComp,cgExtended] then
               Gen0(pc_adr)
            else
               Error(66);

         minuseqop:
            if kind = pointerType then begin
               ChangePointer(pc_sbl, lType^.pType, UsualUnaryConversions);
               expressionType := lType;
               end
            else if et in [cgWord,cgUWord] then
               Gen0(pc_sbi)
            else if et in [cgLong,cgULong] then
               Gen0(pc_sbl)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_sbq)
            else if et in [cgReal,cgDouble,cgComp,cgExtended] then
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
            else if et = cgQuad then
               Gen0(pc_mpq)
            else if et = cgUQuad then
               Gen0(pc_umq)
            else if et in [cgReal,cgDouble,cgComp,cgExtended] then
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
            else if et = cgQuad then
               Gen0(pc_dvq)
            else if et = cgUQuad then
               Gen0(pc_udq)
            else if et in [cgReal,cgDouble,cgComp,cgExtended] then
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
            else if et = cgQuad then
               Gen0(pc_mdq)
            else if et = cgUQuad then
               Gen0(pc_uqm)
            else
               Error(66);

         ltlteqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_shl)
            else if et in [cgLong,cgULong] then
               Gen0(pc_sll)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_slq)
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
            else if et = cgQuad then
               Gen0(pc_sqr)
            else if et = cgUQuad then
               Gen0(pc_wsr)
            else
               Error(66);

         andeqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bnd)
            else if et in [cgLong,cgULong] then
               Gen0(pc_bal)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_baq)
            else
               Error(66);

         caroteqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bxr)
            else if et in [cgLong,cgULong] then
               Gen0(pc_blx)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_bqx)
            else
               Error(66);

         bareqop:
            if et in [cgWord,cgUWord] then
               Gen0(pc_bor)
            else if et in [cgLong,cgULong] then
               Gen0(pc_blr)
            else if et in [cgQuad,cgUQuad] then
               Gen0(pc_bqr)
            else
               Error(66);

         otherwise: Error(57);
         end; {case}
      if ((lint & lintOverflow) <> 0) then begin
         if tree^.token.kind in [slasheqop,percenteqop] then
            CheckDivByZero(tree^.right^.token, lType)
         else if tree^.token.kind in [ltlteqop,gtgteqop] then
            CheckShiftOverflow(tree^.right^.token, lType);
         end; {if}
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
      else begin
         et := UsualUnaryConversions;
         if et in [cgReal,cgDouble,cgComp,cgExtended] then begin
            GenLdcReal(0.0);
            Gen0t(pc_neq, cgExtended);
            expressionType := intPtr;
            end {if}
         else if et in [cgQuad,cgUQuad] then begin
            GenLdcQuad(longlong0);
            Gen0t(pc_neq, et);
            expressionType := intPtr;
            end; {else if}
         end; {else}
      lType := expressionType;
      GenerateCode(tree^.right);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else begin
         et := UsualUnaryConversions;
         if et in [cgReal,cgDouble,cgComp,cgExtended] then begin
            GenLdcReal(0.0);
            Gen0t(pc_neq, cgExtended);
            expressionType := intPtr;
            end {if}
         else if et in [cgQuad,cgUQuad] then begin
            GenLdcQuad(longlong0);
            Gen0t(pc_neq, et);
            expressionType := intPtr;
            end; {else if}
         end; {else}
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_ior);
         cgLong,cgULong:
            Gen0(pc_lor);
         otherwise:
            error(66);
         end; {case}
      expressionType := intPtr;
      end; {case barbarop}

   andandop: begin                      {&&}
      GenerateCode(tree^.left);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else begin
         et := UsualUnaryConversions;
         if et in [cgReal,cgDouble,cgComp,cgExtended] then begin
            GenLdcReal(0.0);
            Gen0t(pc_neq, cgExtended);
            expressionType := intPtr;
            end {if}
         else if et in [cgQuad,cgUQuad] then begin
            GenLdcQuad(longlong0);
            Gen0t(pc_neq, et);
            expressionType := intPtr;
            end; {else if}
         end; {else}
      lType := expressionType;
      GenerateCode(tree^.right);
      if expressionType^.kind in [pointerType,arrayType] then
         expressionType := uLongPtr
      else begin
         et := UsualUnaryConversions;
         if et in [cgReal,cgDouble,cgComp,cgExtended] then begin
            GenLdcReal(0.0);
            Gen0t(pc_neq, cgExtended);
            expressionType := intPtr;
            end {if}
         else if et in [cgQuad,cgUQuad] then begin
            GenLdcQuad(longlong0);
            Gen0t(pc_neq, et);
            expressionType := intPtr;
            end; {else if}
         end; {else}
      case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_and);
         cgLong,cgULong:
            Gen0(pc_lnd);
         otherwise:
            error(66);
         end; {case}
      expressionType := intPtr;
      end; {case andandop}

   carotch: begin                       {^}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bxr);
         cgLong,cgULong:
            Gen0(pc_blx);
         cgQuad,cgUQuad:
            Gen0(pc_bqx);
         otherwise:
            error(66);
         end; {case}
      end; {case carotch}

   barch: begin                         {|}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bor);
         cgLong,cgULong:
            Gen0(pc_blr);
         cgQuad,cgUQuad:
            Gen0(pc_bqr);
         otherwise:
            error(66);
         end; {case}
      end; {case barch}

   andch: begin                         {&}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bnd);
         cgLong,cgULong:
            Gen0(pc_bal);
         cgQuad,cgUQuad:
            Gen0(pc_baq);
         otherwise:
            error(66);
         end; {case}
      end; {case andch}

   ltltop: begin                        {<<}
      GenerateCode(tree^.left);
      if (expressionType^.kind <> scalarType) then
         error(66);
      et := UsualUnaryConversions;
      lType := expressionType;
      GenerateCode(tree^.right);
      if (expressionType^.kind <> scalarType)
         or not (expressionType^.baseType in
         [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad]) then
         error(66);
      if et in [cgQuad,cgUQuad] then begin
         if not (expressionType^.baseType in [cgWord,cgUWord]) then
            Gen2(pc_cnv, ord(expressionType^.baseType), ord(cgWord));
         end {if}
      else
         if expressionType^.baseType <> et then
            Gen2(pc_cnv, ord(expressionType^.baseType), ord(et));
      case et of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_shl);
         cgLong,cgULong:
            Gen0(pc_sll);
         cgQuad,cgUQuad:
            Gen0(pc_slq);
         otherwise:
            error(66);
         end; {case}
      expressionType := lType;
      TruncateUBitInt(expressionType);
      SignExtendBitInt(expressionType);
      if ((lint & lintOverflow) <> 0) then
         CheckShiftOverflow(tree^.right^.token, expressionType);
      end; {case ltltop}

   gtgtop: begin                        {>>}
      GenerateCode(tree^.left);
      if (expressionType^.kind <> scalarType) then
         error(66);
      et := UsualUnaryConversions;
      lType := expressionType;
      GenerateCode(tree^.right);
      if (expressionType^.kind <> scalarType)
         or not (expressionType^.baseType in
         [cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad]) then
         error(66);
      if et in [cgQuad,cgUQuad] then begin
         if not (expressionType^.baseType in [cgWord,cgUWord]) then
            Gen2(pc_cnv, ord(expressionType^.baseType), ord(cgWord));
         end {if}
      else
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
         cgQuad:
            Gen0(pc_sqr);
         cgUQuad:
            Gen0(pc_wsr);
         otherwise:
            error(66);
         end; {case}
      expressionType := lType;
      if ((lint & lintOverflow) <> 0) then
         CheckShiftOverflow(tree^.right^.token, expressionType);
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
         if expressionType^.kind <> scalarType then
            error(66);

         {pointer addition}
         et := UsualUnaryConversions;
         expressionType := lType;
         if lType^.kind = arrayType then
            lType := lType^.aType
         else
            lType := lType^.pType;
         ChangePointer(pc_adl, lType, et);
         if expressionType^.kind = arrayType then
            expressionType := MakePointerTo(expressionType^.aType);
         end {if}
      else begin

         {scalar addition}
         case UsualBinaryConversions(lType) of
            cgByte,cgUByte,cgWord,cgUWord:
               Gen0(pc_adi);
            cgLong,cgULong:
               Gen0(pc_adl);
            cgQuad,cgUQuad:
               Gen0(pc_adq);
            cgReal,cgDouble,cgComp,cgExtended:
               Gen0(pc_adr);
            otherwise:
               error(66);
            end; {case}
         TruncateUBitInt(expressionType);
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
               Error(47)
            else if not looseTypeChecks then
               if expressionType^.aType^.size = 0 then
                  Error(122);
            if checkNullPointers then begin
               Gen0(pc_ckn);
               Gen0(pc_ckp);
               end; {if}
            Gen0(pc_sbl);
            if (lType^.aType^.kind = arrayType)
               and lType^.aType^.isVariableLength then begin
               Gen2t(pc_lod, lType^.aType^.sizeLLN, 0, cgULong);
               Gen0(pc_dvl);
               end {if}
            else if size <> 1 then begin
               GenLdcLong(size);
               Gen0(pc_dvl);
               end; {if}
            lType := longPtr;
            end {if}
         else
            {subtract a scalar from a pointer}
            ChangePointer(pc_sbl, lType^.aType, UsualUnaryConversions);
         expressionType := lType;
         if expressionType^.kind = arrayType then
            expressionType := MakePointerTo(expressionType^.aType);
         end {if}
      else begin

         {scalar subtraction}
         if expressionType^.kind <> scalarType then
            error(66)
         else case UsualBinaryConversions(lType) of
            cgByte,cgUByte,cgWord,cgUWord:
               Gen0(pc_sbi);
            cgLong,cgULong:
               Gen0(pc_sbl);
            cgQuad,cgUQuad:
               Gen0(pc_sbq);
            cgReal,cgDouble,cgComp,cgExtended:
               Gen0(pc_sbr);
            otherwise:
               error(66);
            end; {case}
         TruncateUBitInt(expressionType);
         end; {else}
      end; {case minusch}

   asteriskch: begin                    {*}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_mpi);
         cgUByte,cgUWord:
            Gen0(pc_umi);
         cgLong:
            Gen0(pc_mpl);
         cgULong:
            Gen0(pc_uml);
         cgQuad:
            Gen0(pc_mpq);
         cgUQuad:
            Gen0(pc_umq);
         cgReal,cgDouble,cgComp,cgExtended:
            Gen0(pc_mpr);
         otherwise:
            error(66);
         end; {case}
      TruncateUBitInt(expressionType);
      end; {case asteriskch}

   slashch: begin                       {/}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_dvi);
         cgUByte,cgUWord:
            Gen0(pc_udi);
         cgLong:
            Gen0(pc_dvl);
         cgULong:
            Gen0(pc_udl);
         cgQuad:
            Gen0(pc_dvq);
         cgUQuad:
            Gen0(pc_udq);
         cgReal,cgDouble,cgComp,cgExtended:
            Gen0(pc_dvr);
         otherwise:
            error(66);
         end; {case}
      if ((lint & lintOverflow) <> 0) then
         CheckDivByZero(tree^.right^.token, expressionType);
      end; {case slashch}

   percentch: begin                     {%}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      if (lType^.kind <> scalarType) or (expressionType^.kind <> scalarType) then
         Error(66)
      else case UsualBinaryConversions(lType) of
         cgByte,cgWord:
            Gen0(pc_mod);
         cgUByte,cgUWord:
            Gen0(pc_uim);
         cgLong:
            Gen0(pc_mdl);
         cgULong:
            Gen0(pc_ulm);
         cgQuad:
            Gen0(pc_mdq);
         cgUQuad:
            Gen0(pc_uqm);
         otherwise:
            error(66);
         end; {case}
      if ((lint & lintOverflow) <> 0) then
         CheckDivByZero(tree^.right^.token, expressionType);
      end; {case percentch}

   eqeqop,                              {==}
   exceqop: begin                       {!=}
      GenerateCode(tree^.left);
      lType := expressionType;
      tLastWasNullPtrConst := lastWasNullPtrConst;
      GenerateCode(tree^.right);
      CompareCompatible(ltype, expressionType, true);
      if tree^.token.kind = eqeqop then
         Gen0t(pc_equ, UsualBinaryConversions(lType))
      else
         Gen0t(pc_neq, UsualBinaryConversions(lType));
      expressionType := intPtr;
      end; {case exceqop,eqeqop}

   lteqop,                              {<=}
   gteqop,                              {>=}
   ltch,                                {<}
   gtch: begin                          {>}
      GenerateCode(tree^.left);
      lType := expressionType;
      GenerateCode(tree^.right);
      CompareCompatible(ltype, expressionType, false);
      if tree^.token.kind = lteqop then
         Gen0t(pc_leq, UsualBinaryConversions(lType))
      else if tree^.token.kind = gteqop then
         Gen0t(pc_geq, UsualBinaryConversions(lType))
      else if tree^.token.kind = ltch then
         Gen0t(pc_les, UsualBinaryConversions(lType))
      else {if tree^.token.kind = gtch then}
         Gen0t(pc_grt, UsualBinaryConversions(lType));
      expressionType := intPtr;
      end; {case lteqop,gteqop,ltch,gtch}

   uminus: begin                        {unary -}
      GenerateCode(tree^.left);
      if expressionType^.kind <> scalarType then
         error(66)
      else case UsualUnaryConversions of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_ngi);
         cgLong,cgULong:
            Gen0(pc_ngl);
         cgQuad,cgUQuad:
            Gen0(pc_ngq);
         cgReal,cgDouble,cgComp,cgExtended:
            Gen0(pc_ngr);
         otherwise:
            error(66);
         end; {case}
      TruncateUBitInt(expressionType);
      end; {case uminus}

   uplus: begin                         {unary +}
      GenerateCode(tree^.left);
      if expressionType^.kind <> scalarType then
         error(66)
      else case UsualUnaryConversions of
         cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,cgQuad,cgUQuad,
         cgReal,cgDouble,cgComp,cgExtended:
            ;
         otherwise:
            error(66);
         end; {case}
      end; {case uplus}

   tildech: begin                       {~}
      GenerateCode(tree^.left);
      if expressionType^.kind <> scalarType then
         error(66)
      else case UsualUnaryConversions of
         cgByte,cgUByte,cgWord,cgUWord:
            Gen0(pc_bnt);
         cgLong,cgULong:
            Gen0(pc_bnl);
         cgQuad,cgUQuad:
            Gen0(pc_bnq);
         otherwise:
            error(66);
         end; {case}
      TruncateUBitInt(expressionType);
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

         cgQuad,cgUQuad: begin
            GenLdcQuad(longlong0);
            Gen0t(pc_equ, cgQuad);
            end;

         cgReal,cgDouble,cgComp,cgExtended: begin
            GenLdcReal(0.0);
            Gen0t(pc_equ, cgExtended);
            end;

         otherwise:
            error(66);
         end; {case}
      expressionType := intPtr;
      end; {case excch}

   plusplusop:                          {prefix ++}
      DoIncDec(tree^.left, pc_lil, pc_gil, pc_iil);

   opplusplus:                          {postfix ++}
      DoIncDec(tree^.left, pc_lli, pc_gli, pc_ili);

   minusminusop:                        {prefix --}
      DoIncDec(tree^.left, pc_ldl, pc_gdl, pc_idl);

   opminusminus:                        {postfix --}
      DoIncDec(tree^.left, pc_lld, pc_gld, pc_ild);

   uand: begin                          {unary & (address operator)}
      if not (tree^.left^.token.kind in 
         [ident,compoundliteral,stringconst,uasterisk]) then
         L_Value(tree^.left);
      LoadAddress(tree^.left, false);
      if tree^.left^.token.kind = stringconst then begin
         {build pointer-to-array type for address of string constant}
         tType := pointer(Malloc(sizeof(typeRecord)));
         tType^ := StringType(tree^.left^.token.prefix)^;
         tType^.size := tree^.left^.token.sval^.length;
         tType^.saveDisp := 0;
         tType^.isVariableLength := false;
         tType^.elements := tType^.size div tType^.aType^.size;
         expressionType := MakePointerTo(tType);
         end {if}
      else if expressionType^.kind = arrayType then
         expressionType := MakePointerTo(expressionType^.aType);
      end; {case uand}

   uasterisk: begin                     {unary * (indirection)}
      GenerateCode(tree^.left);
      lType := expressionType;
      if lType^.kind in [functiontype,arrayType,pointerType] then begin
         if lType^.kind = arrayType then
            lType := lType^.aType
         else if lType^.kind = pointerType then
            lType := lType^.pType;
         expressionType := lType;
         isVolatile := tqVolatile in lType^.qualifiers;
         if checkNullPointers then
            if lType^.kind <> functionType then
               Gen0(pc_ckp);
         if lType^.kind = scalarType then
            if lType^.baseType = cgVoid then
               Gen2(pc_cnv, cgULong, cgVoid)
            else
               Gen2t(pc_ind, ord(isVolatile), 0, lType^.baseType)
         else if lType^.kind = pointerType then
            Gen2t(pc_ind, ord(isVolatile), 0, cgULong)
         else if not
            ((lType^.kind in [functionType,arrayType,structType,unionType])
            or ((lType^.kind = definedType) and  {handle const struct/union}
                (lType^.dType^.kind in [structType,unionType]))) then
            Error(79)
         else
            CheckForIncompleteStructType;
         end {if}
      else
         Error(79);
      end; {case uasterisk}

   dotch: begin                         {.}
      LoadAddress(tree^.left, checkNullPointers);
      isBitfield := false;
      lType := expressionType;
      if lType^.kind in [arrayType,pointerType,structType,unionType] then begin
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
         isVolatile := tqVolatile in expressionType^.qualifiers;
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
               Gen2t(pc_ind, ord(isVolatile), long(size).lsw, et);
            end {if}
         else if kind = pointerType then
            Gen2t(pc_ind, ord(isVolatile), long(size).lsw, cgULong)
         else if kind = enumType then
            Gen2t(pc_ind, ord(isVolatile), long(size).lsw, cgWord)
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
      ValueExpressionConversions;
      lType := expressionType;
      tlastWasNullPtrConst := lastWasNullPtrConst;
      GenerateCode(tree^.right);        {evaluate false expression}
      ValueExpressionConversions;
                                        {check, compute, and convert types}
      if (lType^.kind = pointerType) or (expressionType^.kind = pointerType)
         then begin
         if tlastWasNullPtrConst then begin
            if lType^.kind = scalarType then
               Gen2(pc_cnn, ord(lType^.baseType), ord(cgULong));
            end {if}
         else if lastWasNullPtrConst then begin
            if expressionType^.kind = scalarType then
               Gen2(pc_cnv, ord(expressionType^.baseType), ord(cgULong));
            expressionType := lType;
            end {if}
         else if lType^.kind <> expressionType^.kind then {not both pointers}
            Error(47)
         else if IsVoid(lType^.pType) or IsVoid(expressionType^.pType) then begin
            if not looseTypeChecks then
               if (lType^.pType^.kind = functionType) or
                  (expressionType^.pType^.kind = functionType) then
                  Error(47);
            expressionType := MakePointerTo(MakeQualifiedType(voidPtr,
               lType^.pType^.qualifiers+expressionType^.pType^.qualifiers));
            end {else if}
         else if CompTypes(Unqualify(lType^.pType),
            Unqualify(expressionType^.pType)) then begin
            if not looseTypeChecks then
               if not StrictCompTypes(Unqualify(lType^.pType),
                  Unqualify(expressionType^.pType)) then
                  Error(47);
            expressionType := MakePointerTo(MakeQualifiedType(MakeCompositeType(
               Unqualify(lType^.pType),Unqualify(expressionType^.pType)),
               lType^.pType^.qualifiers+expressionType^.pType^.qualifiers));
            end {else if}
         else
            Error(47);
         et := cgULong;
         end {if}
      else if lType^.kind in [structType, unionType] then begin
         if not CompTypes(lType, expressionType) then
            Error(47);
         et := cgULong;
         end {if}
      else begin
         if IsVoid(lType) and IsVoid(expressionType) then
            et := cgVoid
         else
            et := UsualBinaryConversions(lType);
         end; {else}
                                        {generate the operation}
      Gen0(pc_bno);
      Gen0t(pc_tri, et);
      end; {case colonch}

   castoper: begin                      {(cast)}
      InsertCode(tree^.vlaCode);
      GenerateCode(tree^.left);
      if lastWasNullPtrConst then
         if expressionType^.kind = scalarType then
            if tree^.castType^.kind = pointerType then
               if IsVoid(tree^.castType^.pType) then
                  if tree^.castType^.pType^.qualifiers = [] then
                     isNullPtrConst := true;
      Cast(Unqualify(tree^.castType));
      if tree^.vlaCode <> nil then
         if tree^.castType^.kind = scalarType then
            Gen0t(pc_bno, tree^.castType^.baseType)
         else
            Gen0t(pc_bno, cgULong);
      end; {case castoper}

   sizeofsy: begin                      {sizeof(VLA type or expression)}
      if tree^.left^.token.kind = typeofsy then
         tp := tree^.left
      else
         tp := tree;
      InsertCode(tp^.vlaCode);
      if tp = tree then
         Gen0t(pc_pop, cgULong);
      Gen2t(pc_lod, tp^.castType^.sizeLLN, 0, cgULong);
      if tp^.vlaCode <> nil then
         Gen0t(pc_bno, cgULong);
      if doDispose then
         dispose(tree^.left);
      expressionType := uLongPtr;
      end; {case sizeofsy}

   otherwise:
      Error(57);

   end; {case}
if doDispose then
   dispose(tree);
lastWasNullPtrConst := isNullPtrConst;
lastWasConst := isConst;
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
{       expressionType - type of the expression                 }

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
      end {if}
   else
      expressionType := intPtr;         {set default type in case of error}
   end {if}
else begin                              {record the expression for an initializer}
   initializerTree := tree;
   isConstant := false;
   llExpressionValue.lo := 0;
   llExpressionValue.hi := 0;
   expressionIsLongLong := false;
   if errorFound then begin
      DisposeTree(initializerTree);
      initializerTree := nil;
      expressionType := intPtr;         {set default type in case of error}
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
         if castValue^.token.kind in [intconst,uintconst] then
            begin
            expressionValue := castValue^.token.ival;
            isConstant := true;
            expressionType := Unqualify(tree^.castType);
            if (castValue^.token.kind = uintconst)
               or (expressionType^.kind = pointerType) then
               expressionValue := expressionValue & $0000FFFF;
            goto 1;
            end; {if}
         if castValue^.token.kind in [longconst,ulongconst] then begin
            expressionValue := castValue^.token.lval;
            isConstant := true;
            expressionType := Unqualify(tree^.castType);
            goto 1;
            end; {if}
         end; {if}
      if tree^.token.kind = intconst then
         begin
         expressionValue := tree^.token.ival;
         expressionType := tree^.token.itype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = uintconst then begin
         expressionValue := tree^.token.ival;
         expressionValue := expressionValue & $0000FFFF;
         expressionType := tree^.token.itype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = longconst then begin
         expressionValue := tree^.token.lval;
         expressionType := tree^.token.ltype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = ulongconst then begin
         expressionValue := tree^.token.lval;
         expressionType := tree^.token.ltype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = longlongconst then begin
         llExpressionValue := tree^.token.qval;
         expressionIsLongLong := true;
         if ((llExpressionValue.hi = 0) and (llExpressionValue.lo >= 0))
            or ((llExpressionValue.hi = -1) and (llExpressionValue.lo < 0)) then
            expressionValue := llExpressionValue.lo
         else if llExpressionValue.hi < 0 then
            expressionValue := $80000000
         else
            expressionValue := $7fffffff;
         expressionType := tree^.token.qtype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind = ulonglongconst then begin
         llExpressionValue := tree^.token.qval;
         expressionIsLongLong := true;
         if llExpressionValue.hi = 0 then
            expressionValue := llExpressionValue.lo
         else
            expressionValue := $FFFFFFFF;
         expressionType := tree^.token.qtype;
         isConstant := true;
         end {else if}
      else if tree^.token.kind in 
         [floatconst,doubleconst,extendedconst,compconst] then begin
         realExpressionValue := tree^.token.rval;
         if tree^.token.kind = extendedconst then
            expressionType := extendedPtr
         else if tree^.token.kind = doubleconst then
            expressionType := doublePtr
         else if tree^.token.kind = floatconst then
            expressionType := floatPtr
         else {if tree^.token.kind = compconst then}
            expressionType := compPtr;
         isConstant := true;
         if kind in [integerConstantExpression,preprocessorExpression] then begin
            expressionType := intPtr;
            expressionValue := 1;
            Error(47);
            end; {if}
         end {else if}
      else if tree^.token.kind = stringconst then begin
         expressionValue := ord4(tree^.token.sval);
         expressionType := StringType(tree^.token.prefix);
         stringConstSize := tree^.token.sval^.length;
         isConstant := true;
         if kind in [integerConstantExpression,preprocessorExpression] then begin
            expressionType := intPtr;
            expressionValue := 1;
            Error(47);
            end; {if}
         end {else if}
      else if kind in [integerConstantExpression,preprocessorExpression] then begin
         DisposeTree(initializerTree);
         expressionValue := 1;
         end; {else if}
      end; {else}
   end; {else}
1:
end; {Expression}


procedure GetLLExpressionValue {var val: longlong};

{ get the value of the last integer constant expression as a    }
{ long long (whether it had long long type or not).             }

begin {GetLLExpressionValue}
   if expressionIsLongLong then
      val := llExpressionValue
   else begin
      val.lo := expressionValue;
      val.hi := 0;
      if expressionValue < 0 then
         if expressionType^.kind = scalarType then
            if expressionType^.baseType in [cgByte,cgWord,cgLong] then
               val.hi := -1;
      end;
end; {GetLLExpressionValue}


function GetFullExpressionType{: typePtr};

{ Get the full type of the last expression.                     }
{                                                               }
{ This differs from just reading expressionType in that the     }
{ types of string constants include their length.               }

var
   stringType: typePtr;                 {type of a string constant}

begin {GetFullExpressionType}
if (expressionType = stringTypePtr)
   or (expressionType = utf8StringTypePtr)
   or (expressionType = utf16StringTypePtr)
   or (expressionType = utf32StringTypePtr)
   then begin
   stringType := CopyType(expressionType);
   stringType^.size := stringConstSize;
   stringType^.elements := stringType^.size div stringType^.aType^.size;
   GetFullExpressionType := stringType;
   end {else}
else
   GetFullExpressionType := expressionType;
end; {GetFullExpressionType}


procedure InitExpression;

{ initialize the expression handler                             }

begin {InitExpression}
startTerm := [ident,intconst,uintconst,longconst,ulongconst,longlongconst,
              ulonglongconst,floatconst,doubleconst,extendedconst,compconst,
              stringconst,truesy,falsesy];
startExpression:= startTerm +
             [lparench,asteriskch,andch,plusch,minusch,excch,tildech,sizeofsy,
              plusplusop,minusminusop,typedef,_Alignofsy,alignofsy,_Genericsy];
end; {InitExpression}

end.

{$append 'expression.asm'}
