{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Symbol Table                                                 }
{                                                               }
{  Handle the symbol table.                                     }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  CheckStaticFunctions - check for undefined functions         }
{  CompTypes - Determine if the two types are compatible        }
{  DoGlobals - declare the ~globals and ~arrays segments        }
{  FindSymbol - locate a symbol in the symbol table             }
{  GenParameters - Generate labels and space for the parameters }
{  GenSymbols - generate a symbol table for the debugger        }
{  InitSymbol - initialize the symbol table handler             }
{  NewSymbol - insert a new symbol in the symbol table          }
{  PopTable - Pop a symbol table (remove definitions local to a }
{       block)                                                  }
{  PushTable - Create a new symbol table, pushing the old one   }
{  ResolveForwardReference - resolve a forward reference        }
{                                                               }
{  External Variables:                                          }
{                                                               }
{  table - current symbol table                                 }
{                                                               }
{  charPtr - pointer to the base type for char                  }
{  sCharPtr - pointer to the base type for signed char          }
{  uCharPtr - pointer to the base type for unsigned char        }
{  shortPtr - pointer to the base type for short                }
{  uShortPtr - pointer to the base type for unsigned short      }
{  intPtr - pointer to the base type for int                    }
{  uIntPtr - pointer to the base type for unsigned int          }
{  int32Ptr - pointer to the base type for 32-bit int           }
{  uInt32Ptr - pointer to the base type for 32-bit unsigned int }
{  longPtr - pointer to the base type for long                  }
{  uLongPtr - pointer to the base type for unsigned long        }
{  longLongPtr - pointer to the base type for long long         }
{  uLongLongPtr - pointer to base type for unsigned long long   }
{  floatPtr - pointer to the base type for float                }
{  doublePtr - pointer to the base type for double              }
{  compPtr - pointer to the base type for comp                  }
{  extendedPtr - pointer to the base type for extended          }
{  boolPtr - pointer to the base type for _Bool                 }
{  voidPtr - pointer to the base type for void                  }
{  voidPtrPtr - typeless pointer, for some type casting         }
{  charPtrPtr - pointer to type record for char *               }
{  vaInfoPtr - pointer to type record for internal va info type }
{  stringTypePtr - pointer to the base type for string literals }
{  utf16StringTypePtr - pointer to the base type for UTF-16     }
{       string literals                                         }
{  utf32StringTypePtr - pointer to the base type for UTF-32     }
{       string literals                                         }
{  constCharPtr - pointer to the type const char                }
{  defaultStruct - default for structures with errors           }
{                                                               }
{---------------------------------------------------------------}

unit Symbol;

{$LibPrefix '0/obj/'}

interface

uses CCommon, CGI, MM, Scanner;

{$segment 'CC'}

{---------------------------------------------------------------}

type
   symbolTablePtr = ^symbolTable;
   symbolTable = record                 {a symbol table}
      {NOTE: the array of buckets must come first in the record!}
      buckets: array[0..hashSize2] of identPtr; {hash buckets}
      next: symbolTablePtr;             {next symbol table}
      staticNum: packed array[1..6] of char; {staticNum at start of table}
      end;

var
   table: symbolTablePtr;               {current symbol table}
   globalTable: symbolTablePtr;         {global symbol table}
   functionTable: symbolTablePtr;       {table for top level of current function}

                                        {output from GenParameters}
   lastParameterLLN: integer;           {label number of last parameter (0 if none)}
   lastParameterSize: integer;          {size of last parameter}

                                        {base types}
   charPtr,sCharPtr,uCharPtr,shortPtr,uShortPtr,intPtr,uIntPtr,int32Ptr,
      uInt32Ptr,longPtr,uLongPtr,longLongPtr,uLongLongPtr,boolPtr,
      floatPtr,doublePtr,compPtr,extendedPtr,stringTypePtr,utf16StringTypePtr,
      utf32StringTypePtr,voidPtr,voidPtrPtr,charPtrPtr,vaInfoPtr,constCharPtr,
      defaultStruct: typePtr;

{---------------------------------------------------------------}

procedure CheckStaticFunctions;

{ check for undefined functions                                 }


procedure CheckUnused (tPtr: symbolTablePtr);

{ check for unused variables in symbol table                    }


function CompTypes (t1, t2: typePtr): boolean;

{ Determine if the two types are compatible                     }


function StrictCompTypes (t1, t2: typePtr): boolean;

{ Determine if the two types are compatible, strictly following }
{ C standard rules.                                             }


procedure DoGlobals;

{ declare the ~globals and ~arrays segments                     }


function FindSymbol (var tk: tokenType; class: spaceType; oneLevel: boolean;
                     staticAllowed: boolean): identPtr;

{ locate a symbol in the symbol table                           }
{                                                               }
{ parameters:                                                   }
{       tk - token record for the identifier to find            }
{       class - the kind of variable space to search            }
{       oneLevel - search one level only? (used to check for    }
{               duplicate symbols)                              }
{       staticAllowed - can we check for static variables?      }
{                                                               }
{ returns:                                                      }
{       A pointer to the symbol table entry is returned.  If    }
{       there is no entry, nil is returned.                     }


procedure GenParameters (pp: parameterPtr);

{ Generate labels and space for the parameters                  }
{								}
{ parameters:							}
{    pp - pointer to first parameter				}
{                                                               }
{ variables:                                                    }
{     lastParameterLLN - label number of last parameter         }
{     lastParameterSize - size of last parameter                }
          

procedure GenSymbols (sym: symbolTablePtr; doGlobals: boolean);

{ generate a symbol table for the debugger                      }
{                                                               }
{ parameters:                                                   }
{       sym - symbol table to generate                          }
{       doGlobals - include global symbols in the table         }
{                                                               }
{ outputs:                                                      }
{       symLength - length of debug symbol table                }


procedure InitSymbol;

{ Initialize the symbol table module                            }


function IsVoid (tp: typePtr): boolean;

{ Check to see if a type is void                                }
{                                                               }
{ Parameters:                                                   }
{    tp - type to check                                         }
{                                                               }
{ Returns: True if the type is void, else false                 }


function LabelToDisp (lab: integer): integer; extern;

{ convert a local label number to a stack frame displacement    }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }


function MakePascalType (origType: typePtr): typePtr;

{ make a version of a type with the pascal qualifier applied    }
{                                                               }
{ parameters:                                                   }
{       origType - the original type                            }
{                                                               }
{ returns: pointer to the pascal-qualified type                 }


function MakePointerTo (pType: typePtr): typePtr;

{ make a pointer type                                           }
{                                                               }
{ parameters:                                                   }
{       pType - the type pointed to                             }
{                                                               }
{ returns: the pointer type                                     }


function MakeCompositeType (t1, t2: typePtr): typePtr;

{ Make the composite type of two compatible types.              }
{ See C17 section 6.2.7.                                        }
{                                                               }
{ parameters:                                                   }
{       t1,t2 - the input types (must be compatible)            }
{                                                               }
{ returns: pointer to the composite type                        }


function MakeQualifiedType (origType: typePtr; qualifiers: typeQualifierSet):
   typePtr;

{ make a qualified version of a type                            }
{                                                               }
{ parameters:                                                   }
{       origType - the original type                            }
{       qualifiers - the type qualifier(s) to add               }
{                                                               }
{ returns: pointer to the qualified type                        }


function Unqualify (tp: typePtr): typePtr;

{ returns the unqualified version of a type                     }
{                                                               }
{ parameters:                                                   }
{       tp - the original type                                  }
{                                                               }
{ returns: pointer to the unqualified type                      }


function NewSymbol (name: stringPtr; itype: typePtr; class: tokenEnum;
                   space: spaceType; state: stateKind; isInline: boolean):
                   identPtr;

{ insert a new symbol in the symbol table                       }
{                                                               }
{ parameters:                                                   }
{       name - pointer to the symbol name                       }
{       itype - pointer to the symbol type                      }
{       class - storage class                                   }
{       space - the kind of variable space to put the           }
{               identifier in                                   }
{       state - variable declaration state                      }
{                                                               }
{ returns: pointer to the inserted symbol                       }


procedure PopTable;

{ Pop a symbol table (remove definitions local to a block)      }


{procedure PrintOneSymbol (ip: identPtr); {debug}

{ Print a symbol						}
{								}
{ Parameters:							}
{    ip - identifier to print					}


{procedure PrintTable (sym: symbolTablePtr);  {debug}

{ print a symbol table                                          }
{                                                               }
{ parameters:                                                   }
{       sym - symbol table to print                             }


procedure PushTable;

{ Create a new symbol table, pushing the old one                }


procedure ResolveForwardReference (iPtr: identPtr);

{ resolve a forward reference                                   }
{                                                               }
{ parameters:                                                   }
{       iPtr - ptr to the forward declared identifier           }


function StringType(prefix: charStrPrefixEnum): typePtr;

{ returns the type of a string literal with specified prefix    }
{                                                               }
{ parameters:                                                   }
{       prefix - the prefix                                     }

{---------------------------------------------------------------}

implementation

type
                                        {From CGC.pas}
   realrec = record                     {used to convert from real to in-SANE}
      itsReal: extended;
      inSANE: packed array[1..10] of byte;
      inCOMP: packed array[1..8] of byte;
      end;

var
   staticNum: packed array[1..6] of char; {static variable number}

{- Imported from expression.pas --------------------------------}

procedure GenerateCode (tree: tokenPtr); extern;

{ generate code from a fully formed expression tree             }
{                                                               }
{ parameters:                                                   }
{     tree - top of the expression tree to generate code from   }
{                                                               }
{ variables:                                                    }
{     expressionType - result type of the expression            }


function UsualUnaryConversions: baseTypeEnum; extern;

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


{- Imported from CGC.pas ---------------------------------------}

procedure CnvSC (rec: realrec); extern;

{ convert a real number to SANE comp format                     }
{                                                               }
{ parameters:                                                   }
{       rec - record containing the value to convert; also      }
{               has space for the result                        }

{---------------------------------------------------------------}

procedure CnOut (i: integer); extern;

{ write a byte to the constant buffer                           }
{                                                               }
{ parameters:                                                   }
{       i - byte to write                                       }


procedure CnOut2 (i: integer); extern;

{ write a word to the constant buffer                           }
{                                                               }
{ parameters:                                                   }
{       i - word to write                                       }


procedure Out (b: integer); extern;

{ write a byte to the output file                               }
{                                                               }
{ parameters:                                                   }
{       b - byte to write                                       }


procedure Out2 (w: integer); extern;

{ write a word to the output file                               }
{                                                               }
{ parameters:                                                   }
{       w - word to write                                       }


procedure RefName (lab: stringPtr; disp, len, shift: integer); extern;

{ handle a reference to a named label                           }
{                                                               }
{ parameters:                                                   }
{       lab - label name                                        }
{       disp - displacement past the label                      }
{       len - number of bytes in the reference                  }
{       shift - shift factor                                    }


procedure LabelSearch (lab: integer; len, shift, disp: integer); extern;

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


procedure Purge; extern;

{ write any constant bytes to the output buffer                 }

{---------------------------------------------------------------}

procedure ClearTable (table: symbolTable); extern;

{ clear the symbol table to all zeros                           }

procedure SaveBF (addr: ptr; bitdisp, bitsize: integer; val: longint); extern;

{ save a value to a bit-field                                   }
{                                                               }
{ parameters:                                                   }
{       addr - address to copy to                               }
{       bitdisp - displacement past the address                 }
{       bitsize - number of bits                                }
{       val - value to copy                                     }

{---------------------------------------------------------------}


procedure CheckStaticFunctions;

{ check for undefined functions                                 }

var
   i: 0..hashSize;                      {loop variable}
   sp: identPtr;                        {pointer to a symbol table entry}

   msg: stringPtr;                      {error message ptr}

begin {CheckStaticFunctions}
for i := 0 to hashSize do begin
   sp := globalTable^.buckets[i];
   while sp <> nil do begin
      if sp^.storage = private then
         if sp^.itype^.kind = functionType then
            if sp^.state <> defined then begin
               numErrors := numErrors+1;
               new(msg);
               msg^ := concat('The static function ', sp^.name^,
                  ' was not defined.');
               writeln('*** ', msg^);
               if terminalErrors then begin
                  if enterEditor then
                     ExitToEditor(msg, ord4(firstPtr)-ord4(bofPtr))
                  else
                     TermError(0);
                  end; {if}
               liDCBGS.merrf := 16;
               end; {if}
      sp := sp^.next;
      end; {while}
   end; {for}
end; {CheckStaticFunctions}


function CompTypes {t1, t2: typePtr): boolean};

{ Determine if the two types are compatible                     }

label 1;

var
   el1,el2: longint;                    {array sizes}
   kind1,kind2: typeKind;               {temp variables (for speed)}
   p1, p2: parameterPtr;                {for tracing parameter lists}
   pt1,pt2: typePtr;                    {pointer types}

begin {CompTypes}
CompTypes := false;                     {assume the types are not compatible}
kind1 := t1^.kind;                      {get these for efficiency}
kind2 := t2^.kind;
if kind2 = definedType then             {scan past type definitions}
   CompTypes := CompTypes(t1, t2^.dType)
else if kind1 = definedType then
   CompTypes := CompTypes(t1^.dType, t2)

else
   case kind1 of

      scalarType:
         if kind2 = scalarType then begin
            CompTypes := t1^.baseType = t2^.baseType;
            if t1^.cType <> t2^.cType then
               if (not looseTypeChecks) 
                  or (t1^.cType = ctBool) or (t2^.cType = ctBool) then
                  CompTypes := false;
            end {if}
         else if kind2 = enumType then
            CompTypes := (t1^.baseType = cgWord) and (t1^.cType = ctInt);

      arrayType:
         if kind2 = arrayType then begin
            el1 := t1^.elements;
            el2 := t2^.elements;
            if el1 = 0 then
               el1 := el2
            else if el2 = 0 then
               el2 := el1;
            if el1 = el2 then
               CompTypes := CompTypes(t1^.atype, t2^.atype);
            end; {if}

      functionType:
         if kind2 = functionType then begin
            if looseTypeChecks or (t1^.prototyped <> t2^.prototyped) then
               CompTypes := CompTypes(t1^.ftype,t2^.ftype)
            else
               CompTypes := StrictCompTypes(t1, t2);
            end {if}
         else if kind2 = pointerType then
            if t2^.ptype^.kind = functionType then
               CompTypes := CompTypes(t1, t2^.ptype);

      pointerType: begin
         if IsVoid(t1^.ptype) or IsVoid(t2^.ptype) then begin
            CompTypes := true;
            goto 1;
            end; {if}
         if kind2 = pointertype then
            CompTypes := CompTypes(t1^.ptype, t2^.ptype)
         else if kind2 = functionType then
            CompTypes := CompTypes(t1^.ptype, t2);
         end;

      enumType:
         if kind2 = scalarType then
            CompTypes := (t2^.baseType = cgWord) and (t2^.cType = ctInt)
         else if kind2 = enumType then
            CompTypes := true;

      structType,unionType:
         CompTypes := t1 = t2;

      otherwise: ;

      end; {case t1^.kind}
1:
end; {CompTypes}


function StrictCompTypes {t1, t2: typePtr): boolean};

{ Determine if the two types are compatible, strictly following }
{ C standard rules.                                             }

label 1;

var
   el1,el2: longint;                    {array sizes}
   kind1,kind2: typeKind;               {temp variables (for speed)}
   p1, p2: parameterPtr;                {for tracing parameter lists}
   tp1,tp2: typeRecord;                 {temporary types used in comparison}


begin {StrictCompTypes}
if t1 = t2 then begin                   {shortcut}
   StrictCompTypes := true;
   goto 1;
   end; {if}
StrictCompTypes := false;               {assume the types are not compatible}
if t1^.qualifiers <> t2^.qualifiers then {qualifiers must be the same}
   goto 1;
while t1^.kind = definedType do         {scan past type definitions}
   t1 := t1^.dType;
while t2^.kind = definedType do
   t2 := t2^.dType;
kind1 := t1^.kind;                      {get these for efficiency}
kind2 := t2^.kind;

case kind1 of

   scalarType:
      if kind2 = scalarType then begin
         StrictCompTypes :=
            (t1^.baseType = t2^.baseType) and (t1^.cType = t2^.cType);
         end {if}
      else if kind2 = enumType then
         StrictCompTypes := (t1^.baseType = cgWord) and (t1^.cType = ctInt);

   arrayType:
      if kind2 = arrayType then begin
         el1 := t1^.elements;
         el2 := t2^.elements;
         if el1 = 0 then
            el1 := el2
         else if el2 = 0 then
            el2 := el1;
         if el1 = el2 then
            StrictCompTypes := StrictCompTypes(t1^.atype, t2^.atype);
         end; {if}

   functionType:
      if kind2 = functionType then begin
         if not StrictCompTypes(t1^.ftype, t2^.ftype) then
            goto 1;
         if t1^.varargs <> t2^.varargs then
            goto 1;
         if t1^.prototyped and t2^.prototyped then begin
            p1 := t1^.parameterList;
            p2 := t2^.parameterList;
            while (p1 <> nil) and (p2 <> nil) do begin
               tp1 := p1^.parameterType^;
               tp2 := p2^.parameterType^;
               if p1^.parameterType = p2^.parameterType then
                  {these parameters are compatible}
               else begin
                  tp1.qualifiers := [];
                  tp2.qualifiers := [];
                  if tp1.kind = arrayType then
                     tp1.kind := pointerType
                  else if tp1.kind = functionType then begin
                     tp1.size := cgPointerSize;
                     tp1.qualifiers := [];
                     tp1.saveDisp := 0;
                     tp1.kind := pointerType;
                     tp1.pType := p1^.parameterType;
                     end; {else if}
                  if tp2.kind = arrayType then
                     tp2.kind := pointerType
                  else if tp2.kind = functionType then begin
                     tp2.size := cgPointerSize;
                     tp2.qualifiers := [];
                     tp2.saveDisp := 0;
                     tp2.kind := pointerType;
                     tp2.pType := p2^.parameterType;
                     end; {else if}
                  if not StrictCompTypes(@tp1, @tp2) then
                     goto 1;
                  end; {else}
                  p1 := p1^.next;
                  p2 := p2^.next;
               end; {while}
            if p1 <> p2 then
               goto 1;
            end {if}
         else if t1^.prototyped then begin
            p1 := t1^.parameterList;
            while p1 <> nil do begin
               if p1^.parameterType^.kind = scalarType then
                  if p1^.parameterType^.cType in [ctChar,ctSChar,ctUChar,
                     ctShort,ctUShort,ctFloat,ctBool] then
                     goto 1;
               p1 := p1^.next;
               end; {while}
            end {else if}
         else if t2^.prototyped then begin
            p2 := t2^.parameterList;
            while p2 <> nil do begin
               if p2^.parameterType^.kind = scalarType then
                  if p2^.parameterType^.cType in [ctChar,ctSChar,ctUChar,
                     ctShort,ctUShort,ctFloat,ctBool] then
                     goto 1;
               p2 := p2^.next;
               end; {while}
            end; {else if}
         StrictCompTypes := true;
         end; {if}

   pointerType:
      if kind2 = pointertype then
         StrictCompTypes := StrictCompTypes(t1^.ptype, t2^.ptype);

   enumType:
      if kind2 = scalarType then
         StrictCompTypes := (t2^.baseType = cgWord) and (t2^.cType = ctInt)
      else if kind2 = enumType then
         StrictCompTypes := true;

   structType,unionType:
      StrictCompTypes := t1 = t2;

   otherwise: ;

   end; {case}
1:
end; {StrictCompTypes}


procedure DoGlobals;

{ declare the ~globals and ~arrays segments                     }


   procedure StaticInit (variable: identPtr);

   { statically initialize a variable                           }

   type
                                        {record of pointer initializers}
      relocPtr = ^relocationRecord;
      relocationRecord = record
         next: relocPtr;                {next record}
         initializer: initializerPtr;   {the initializer}
         disp: longint;                 {disp in overall data structure}
         end;

                                        {pointers to each type}
      bytePtr = ^byte;
      wordPtr = ^integer;
      longPtr = ^longint;
      quadPtr = ^longlong;
      realPtr = ^real;
      doublePtr = ^double;
      extendedPtr = ^extended;

   var
      buffPtr: ptr;                     {pointer to data buffer}
      count: integer;                   {# of duplicate records}
      disp: longint;                    {disp into buffer (for output)}
      endDisp: longint;                 {ending disp for current chunk}
      i: integer;                       {loop counter}
      ip: initializerPtr;               {used to trace initializer lists}
      lastReloc, nextReloc: relocPtr;   {for reversing relocs list}
      realVal: realRec;                 {used for extended-to-comp conversion}
      relocs: relocPtr;                 {list of records needing relocation}
      
                                        {pointers used to write data}
      bp: bytePtr;
      wp: wordPtr;
      lp: longPtr;
      qp: quadPtr;
      rp: realPtr;
      dp: doublePtr;
      ep: extendedPtr;


      procedure UpdateRelocs;

      { update relocation records to account for an initializer }

      var
         disp: longint;                 {disp of current initializer}
         done: boolean;                 {done with loop?}
         endDisp: longint;              {disp at end of current initializer}
         last: ^relocPtr;               {the pointer referring to rp}
         rp: relocPtr;                  {reloc record being processed}

      begin {UpdateRelocs}
      disp := ip^.disp;
      if ip^.bitsize <> 0 then begin
         endDisp := disp + (ip^.bitdisp + ip^.bitsize + 7) div 8;
         disp := disp + ip^.bitdisp div 8;
         end {if}
      else if ip^.basetype = cgString then
         endDisp := disp + ip^.sVal^.length
      else
         endDisp := disp + TypeSize(ip^.baseType);
      last := @relocs;
      rp := relocs;
      done := false;
      while (rp <> nil) and not done do begin
         if rp^.disp + cgPointerSize <= disp then begin
            {initializer is entirely after this reloc: no conflicts}
            done := true;
            end {if}
         else if endDisp <= rp^.disp then begin
            {initializer is entirely before this reloc}
            last := @rp^.next;
            rp := rp^.next;
            end {else if}
         else begin
            {conflict: remove the conflicting reloc record}
            last^ := rp^.next;
            lp := pointer(ord4(buffPtr) + rp^.disp);
            lp^ := 0;
            dispose(rp);
            rp := last^;
            end; {else}
         end; {while}
      if ip^.basetype = ccPointer then begin
         new(rp);
         rp^.next := last^;
         last^ := rp;
         rp^.disp := ip^.disp;
         rp^.initializer := ip;
         end; {if}
      end; {UpdateRelocs}
   
   begin {StaticInit}
                                        {allocate buffer}
                                        {(+3 for possible bitfield overhang)}
   buffPtr := GLongMalloc(variable^.itype^.size+3);
   
   relocs := nil;                       {evaluate initializers}
   ip := variable^.iPtr;
   while ip <> nil do begin
      count := 0;
      while count < ip^.count do begin
         UpdateRelocs;
         if ip^.bitsize <> 0 then begin
            bp := pointer(ord4(buffPtr) + ip^.disp + count);
            SaveBF(bp, ip^.bitdisp, ip^.bitsize, ip^.iVal);
            end {if}
         else
            case ip^.basetype of
               cgByte,cgUByte: begin
                  bp := pointer(ord4(buffPtr) + ip^.disp + count);
                  bp^ := ord(ip^.iVal) & $ff;
                  end;

               cgWord,cgUWord: begin
                  wp := pointer(ord4(buffPtr) + ip^.disp + count);
                  wp^ := ord(ip^.iVal);
                  end;

               cgLong,cgULong: begin
                  lp := pointer(ord4(buffPtr) + ip^.disp + count);
                  lp^ := ip^.iVal;
                  end;
            
               cgQuad,cgUQuad: begin
                  qp := pointer(ord4(buffPtr) + ip^.disp + count);
                  qp^ := ip^.qVal;
                  end;

               cgReal: begin
                  rp := pointer(ord4(buffPtr) + ip^.disp + count);
                  rp^ := ip^.rVal;
                  end;

               cgDouble: begin
                  dp := pointer(ord4(buffPtr) + ip^.disp + count);
                  dp^ := ip^.rVal;
                  end;

               cgExtended: begin
                  ep := pointer(ord4(buffPtr) + ip^.disp + count);
                  ep^ := ip^.rVal;
                  end;

               cgComp: begin
                  realVal.itsReal := ip^.rVal;
                  CnvSC(realVal);
                  for i := 1 to 8 do begin
                     bp := pointer(ord4(buffPtr) + ip^.disp + count + i-1);
                     bp^ := realVal.inCOMP[i];
                     end; {for}
                  end;
     
               cgString: begin
                  for i := 1 to ip^.sVal^.length do begin
                     bp := pointer(ord4(buffPtr) + ip^.disp + count + i-1);
                     bp^ := ord(ip^.sVal^.str[i]);
                     end; {for}
                  end;
     
               ccPointer: ;             {handled by UpdateRelocs}
         
               cgVoid: Error(57);
               end; {case}
         count := count + 1;            {assumes count > 1 only for bytes}
         end; {while}
      ip := ip^.next;
      end; {while}
                        
   lastReloc := nil;                    {reverse the relocs list}
   while relocs <> nil do begin
      nextReloc := relocs^.next;
      relocs^.next := lastReloc;
      lastReloc := relocs;
      relocs := nextReloc;
      end; {while}
   relocs := lastReloc;

   disp := 0;                           {generate the initialization data}
   while disp < variable^.itype^.size do begin
      if relocs = nil then
         endDisp := variable^.itype^.size
      else
         endDisp := relocs^.disp;
      if disp <> endDisp then begin
         GenBS(dc_cns, pointer(ord4(buffPtr) + disp), endDisp - disp);
         disp := endDisp;
         end; {if}
      if relocs <> nil then begin
         code^.optype := ccPointer;
         code^.r := ord(relocs^.initializer^.pPlus);
         code^.q := 1;
         code^.pVal := relocs^.initializer^.pVal;
         if relocs^.initializer^.isName then begin
            code^.lab := relocs^.initializer^.pName;
            code^.pstr := nil;
            end {if}
         else
            code^.pstr := relocs^.initializer^.pstr;
         Gen0(dc_cns);
         lastReloc := relocs;
         relocs := relocs^.next;
         dispose(lastReloc);
         disp := disp + cgPointerSize;
         end; {if}
      end; {while}
   end; {StaticInit}


   procedure GenArrays;

   { define global arrays                                       }

   var
      didOne: boolean;                  {have we found an array yet?}
      i: 0..hashSize;                   {loop variable}
      ip: initializerPtr;               {used to trace initializer lists}
      lval: longint;                    {for converting types}
      size: longint;                    {size of the array}
      sp: identPtr;                     {pointer to a symbol table entry}
      tPtr: typePtr;                    {type of global array/struct/union}
      msg: stringPtr;                   {error message ptr}

   begin {GenArrays}
   didOne := false;
   for i := 0 to hashSize do begin
      sp := table^.buckets[i];
      while sp <> nil do begin
         if sp^.storage in [global,private] then begin
            tPtr := sp^.itype;
            while tPtr^.kind = definedType do
               tPtr := tPtr^.dType;
            if tPtr^.kind in [arrayType,structType,unionType] then begin
               if not didOne then begin
                  if smallMemoryModel then
                     currentSegment := '          '
                  else
                     currentSegment := '~ARRAYS   ';
                  segmentKind := 0;     {this segment is not dynamic!}
                  Gen2Name(dc_str, $4000, 1, @'~ARRAYS');
                  didOne := true;
                  end; {if}
               if sp^.state = initialized then begin
                  Gen2Name(dc_glb, 0, ord(sp^.storage = private), sp^.name);
                  StaticInit(sp);
                  end {if}
               else begin
                  size := sp^.itype^.size;
                  if size = 0 then begin
                     if sp^.itype^.kind = arrayType then begin
                                        {implicitly initialize with one element}
                        size := sp^.itype^.aType^.size;
                        end {if}
                     else begin
                        numErrors := numErrors+1;
                        new(msg);
                        msg^ := concat('The struct or union ''', sp^.name^,
                           ''' has incomplete type that was never completed.');
                        writeln('*** ', msg^);
                        if terminalErrors then begin
                           if enterEditor then
                              ExitToEditor(msg, ord4(firstPtr)-ord4(bofPtr))
                           else
                              TermError(0);
                           end; {if}
                        liDCBGS.merrf := 16;
                        end; {else}
                     end; {if}
                  Gen2Name(dc_glb, long(size).lsw & $7FFF,
                     ord(sp^.storage = private), sp^.name);
        	  size := size & $FFFF8000;
        	  while size <> 0 do begin
                     Gen1(dc_dst, 16384);
                     size := size-16384;
                     end; {while}
                  end; {else}
               end; {if}
            end; {if}
         sp := sp^.next;
         end; {while}
      end; {for}
   if didOne then
      Gen0(dc_enp);
   end; {GenArrays}


   procedure GenGlobals;

   { define non-array global variables                          }

   var
      i: 0..hashSize;                   {loop variable}
      ip: initializerPtr;               {used to trace initializer lists}
      lval: longint;                    {for extracting lsw}
      sp: identPtr;                     {pointer to a symbol table entry}

   begin {GenGlobals}
   Gen2t(dc_cns, 0, 1, cgByte);
   for i := 0 to hashSize do begin
      sp := table^.buckets[i];
      while sp <> nil do begin
         if sp^.storage in [global,private] then
            if sp^.itype^.kind in [scalarType,pointerType] then begin
               if sp^.state = initialized then begin
                  Gen2Name(dc_glb, 0, ord(sp^.storage = private), sp^.name);
                  ip := sp^.iPtr;
                  case ip^.basetype of
                     cgByte,cgUByte,cgWord,cgUWord: begin
                        lval := ip^.ival;
                        Gen2t(dc_cns, long(lval).lsw, 1, ip^.basetype);
                        end;
                     cgLong,cgULong:
                        GenL1(dc_cns, ip^.ival, 1);
                     cgQuad,cgUQuad:
                        GenQ1(dc_cns, ip^.qval, 1);
                     cgReal,cgDouble,cgComp,cgExtended:
                        GenR1t(dc_cns, ip^.rval, 1, ip^.basetype);
                     cgString:
                        GenS(dc_cns, ip^.sval);
                     ccPointer: begin
                        code^.optype := ccPointer;
                        code^.q := 1;
                        code^.r := ord(ip^.pPlus);
                        code^.pVal := ip^.pVal;
                        if ip^.isName then begin
                           code^.lab := ip^.pName;
                           code^.pstr := nil;
                           end {if}
                        else
                           code^.pstr := ip^.pstr;
                        Gen0(dc_cns);
                        end;
                     otherwise: Error(57);
                     end; {case}
                  end {if}
               {else if sp^.itype^.size = 0 then begin
                  Error(57);
                  end {else if}
               else
                  Gen2Name(dc_glb, ord(sp^.itype^.size),
                     ord(sp^.storage = private), sp^.name);
               end;
         sp := sp^.next;
         end; {while}
      end; {for}
   end; {GenGlobals}

begin {DoGlobals}
{print the global symbol table}
{if printSymbols then                 {debug}
{   PrintTable(globalTable);          {debug}

{declare the ~globals segment, which holds non-array data types}
if smallMemoryModel then
   currentSegment := '          '
else
   currentSegment := '~GLOBALS  ';
segmentKind := 0;                       {this segment is not dynamic!}
Gen2Name(dc_str, $4000, 0, @'~GLOBALS');
GenGlobals;
Gen0(dc_enp);

{declare the ~arrays segment, which holds global arrays}
GenArrays;
end; {DoGlobals}


function FindSymbol {var tk: tokenType; class: spaceType; oneLevel: boolean;
                     staticAllowed: boolean): identPtr};

{ locate a symbol in the symbol table                           }
{                                                               }
{ parameters:                                                   }
{       tk - token record for the identifier to find            }
{       class - the kind of variable space to search            }
{       oneLevel - search one level only? (used to check for    }
{               duplicate symbols)                              }
{       staticAllowed - can we check for static variables?      }
{                                                               }
{ returns:                                                      }
{       A pointer to the symbol table entry is returned.  If    }
{       there is no entry, nil is returned.                     }

label 1;

var
   doTagSpace: boolean;                 {do we still need to do the tags?}
   hashDisp: longint;                   {disp into the hash table}
   i: integer;                          {loop variable}
   iHandle: ^identPtr;                  {pointer to start of hash bucket}
   iPtr: identPtr;                      {pointer to the current symbol}
   match: boolean;                      {for comparing substrings}
   name: stringPtr;                     {name to search for}
   np: stringPtr;                       {for searching for static variables}
   sPtr: symbolTablePtr;                {^ to current symbol table}

begin {FindSymbol}
{get ready to search}
staticAllowed := staticAllowed and (staticNum <> '~0000');
name := tk.name;                        {use a local variable}
hashDisp := Hash(name);                 {get the disp into the symbol table}
sPtr := table;                          {initialize the address of the sym. tbl}
FindSymbol := nil;                      {assume we won't find it}
np := nil;                              {no string buffer, yet}

{check for the variable}
while sPtr <> nil do begin
   iHandle := pointer(hashDisp+ord4(sPtr));
   if class = tagSpace then
      iHandle := pointer(ord4(iHandle) + (hashSize+1)*4);
   doTagSpace := class = allSpaces;
   iPtr := iHandle^;
   if iPtr = nil then
      if doTagSpace then begin
         iHandle := pointer(ord4(iHandle) + (hashSize+1)*4);
         iPtr := iHandle^;
         doTagSpace := false;
         end; {if}

   {scan the hash bucket for a global or auto variable}
   while iPtr <> nil do begin
      if iPtr^.name^ = name^ then begin
         FindSymbol := iPtr;
         if iPtr^.isForwardDeclared then
            ResolveForwardReference(iPtr);
         tk.symbolPtr := iPtr;
         goto 1;
         end; {if}
      iPtr := iPtr^.next;
      if iPtr = nil then
         if doTagSpace then begin
            iHandle := pointer(ord4(iHandle) + (hashSize+1)*4);
            iPtr := iHandle^;
            doTagSpace := false;
            end; {if}
      end; {while}

   {rescan for a static variable}
   if staticAllowed then begin
      if np = nil then begin            {form the static name}
         if length(name^) < 251 then begin
            new(np);
            np^[0] := chr(5+length(name^));
            for i := 1 to 5 do
               np^[i] := sPtr^.staticNum[i];
            for i := 1 to length(name^) do
               np^[i+5] := name^[i];
            end; {if}
         end {if}
      else
         for i := 2 to 5 do
            np^[i] := sPtr^.StaticNum[i];

      {scan the hash bucket for the identifier}
      iHandle := pointer(hashDisp+ord4(globalTable));
      if class = tagSpace then
         iHandle := pointer(ord4(iHandle) + (hashSize+1)*4);
      iPtr := iHandle^;

      while iPtr <> nil do begin
         if iPtr^.name^ = np^ then begin
            FindSymbol := iPtr;
            if iPtr^.isForwardDeclared then
               ResolveForwardReference(iPtr);
            tk.symbolPtr := iPtr;
            goto 1;
            end; {if}
         iPtr := iPtr^.next;
         end; {while}
      end; {if staticAllowed}

   if oneLevel then
      sPtr := nil
   else
      sPtr := sPtr^.next;
   end; {while}

1:
if np <> nil then
   dispose(np);
end; {FindSymbol}


procedure GenParameters {pp: parameterPtr};

{ Generate labels and space for the parameters                  }
{								}
{ parameters:							}
{    pp - pointer to first parameter				}
{                                                               }
{ variables:                                                    }
{     lastParameterLLN - label number of last parameter         }
{     lastParameterSize - size of last parameter                }

var
   i: 0..hashSize;                      {loop variable}
   pln: integer;			{label number}
   size: integer;                       {size of the parameter}
   sp: identPtr;			{symbol pointer}
   tk: tokenType;			{symbol name token}
   first: boolean;                      {first iteration of loop over params?}

begin {GenParameters}
first := true;
if pp <> nil then begin			{prototyped parameters}
   tk.kind := ident;
   tk.numString := nil;
   tk.class := identifier;
   while pp <> nil do begin
      pln := GetLocalLabel;
      tk.name := pp^.parameter^.name;
      tk.symbolPtr := nil;
      sp := FindSymbol(tk, variableSpace, true, false);
      if sp = nil then
         sp := pp^.parameter;
      if sp^.itype^.kind = arrayType then begin
         size := cgPointerSize;
         Gen3(dc_prm, pln, cgPointerSize, sp^.pdisp);
         end {if}
      else begin
	 size := long(sp^.itype^.size).lsw;
	 if (size = 1) and (sp^.itype^.kind = scalarType) then
            size := 2;
	 if sp^.itype^.kind = scalarType then
            if sp^.itype^.baseType in [cgReal,cgDouble,cgComp] then begin
               {convert floating-point parameters to declared type}
               Gen1t(pc_fix, pln, sp^.itype^.baseType);
               size := cgExtendedSize;
               end; {if}
	 Gen3(dc_prm, pln, size, sp^.pdisp);
	 end; {else}
      sp^.pln := pln;
      if first then begin
         first := false;
         lastParameterLLN := pln;
         lastParameterSize := size;
         end; {if}
      pp := pp^.next;
      end; {while}
   end {if}
else begin				{K&R parameters}
   for i := 0 to hashSize do begin              
      sp := table^.buckets[i];
      while sp <> nil do begin
	 if sp^.storage = parameter then begin
            pln := GetLocalLabel;
            sp^.pln := pln;
            if sp^.itype^.kind = arrayType then begin
               size := cgPointerSize;
               Gen3(dc_prm, sp^.lln, cgPointerSize, sp^.pdisp);
               end {if}
            else begin
               size := long(sp^.itype^.size).lsw;
               if (size = 1) and (sp^.itype^.kind = scalarType) then
        	  size := 2;
               if sp^.itype^.kind = scalarType then
                  if sp^.itype^.baseType in [cgReal,cgDouble,cgComp] then begin
                     {convert floating-point parameters to declared type}
                     Gen1t(pc_fix, pln, sp^.itype^.baseType);
                     size := cgExtendedSize;
                     end; {if}
               Gen3(dc_prm, sp^.lln, size, sp^.pdisp);
               end; {else}
            if first then begin
               first := false;
               lastParameterLLN := pln;
               lastParameterSize := size;
               end; {if}
            end; {if}
	 sp := sp^.next;
	 end; {while}
      end; {for}
   if first then begin
      lastParameterLLN := 0;
      lastParameterSize := 0;
      end; {if}
   end; {else}
end; {GenParameters}


procedure GenSymbols {sym: symbolTablePtr; doGlobals: boolean};

{ generate a symbol table for the debugger                      }
{                                                               }
{ parameters:                                                   }
{       sym - symbol table to generate                          }
{       doGlobals - include global symbols in the table         }
{                                                               }
{ outputs:                                                      }
{       symLength - length of debug symbol table                }

const
   noDisp = -1;				{disp returned by GetTypeDisp if the type was not found}

type
   tpPtr = ^tpRecord;			{type list displacements}
   tpRecord = record
      next: tpPtr;
      tp: typePtr;
      disp: integer;
      end;

var
   i: 0..hashSize;			{loop/index variable}
   ip: identPtr;			{used to trace identifier lists}
   tpList,tp2: tpPtr;			{type displacement list}


   function GetTypeDisp (tp: typePtr): integer;

   { Look for an existing entry for this type			}
   {								}
   { Parameters:						}
   {    tp - type to look for					}
   {								}
   { Returns: Disp to a variable of the same type, or noDisp if	}
   {    there is no such entry.					}
   {								}
   { Notes: If the type is not in the type list, it is entered	}
   {   in the list by this call.				}

   var
      tp1, tp2: tpPtr;			{used to manipulate type list}

   begin {GetTypeDisp}
   tp1 := tpList;			{look for the type}
   tp2 := nil;
   while tp1 <> nil do 
      if tp1^.tp = tp then begin
         tp2 := tp1;
         tp1 := nil;
         end {if}
      else
         tp1 := tp1^.next;
   if tp2 <> nil then            
      GetTypeDisp := tp2^.disp		{return disp to entry}
   else begin
      GetTypeDisp := noDisp;		{no entry}
      new(tp1);				{create a new entry}
      tp1^.next := tpList;
      tpList := tp1;
      tp1^.tp := tp;
      tp1^.disp := symLength-12;
      end; {else}
   end; {GetTypeDisp}


   procedure GenSymbol (ip: identPtr; storage: storageType);

   { Generate a single symbol or struct field			}
   {								}
   { parameters:						}
   {    ip - identifier to generate				}
   {    storage - storage type; none for struct/union fields	}

   var
      disp: integer;			{disp to symbol of same type}
      tPtr: typePtr;


      procedure WriteAddress (ip: identPtr);

      { Write the address and DP flag				}
      {								}
      { parameters:						}
      {    ip - identifier					}

      var
         size: longint;			{used to break apart longints}

      begin {WriteAddress}
      if storage in [external,global,private] then begin
         RefName(ip^.name, 0, 4, 0);
         CnOut(1);
         end {if}
      else if storage = none then begin
         size := ip^.disp;
         CnOut2(long(size).lsw);
         CnOut2(long(size).msw);
         CnOut(ord(ip^.next <> nil));
         end {else if}
      else begin
         CnOut2(LabelToDisp(ip^.lln));
         CnOut2(0);
         CnOut(0);
         end; {else}
      end; {WriteAddress}


      procedure WriteName (ip: identPtr);

      { Write the name field for an identifier			}
      {								}
      { parameters:						}
      {    ip - identifier					}

      var
         len: 0..maxint;		{string length}
         j: 0..maxint;			{loop/index variable}

      begin {WriteName}
      Purge;				{generate the address of the variable  }
      Out(235); Out(4);			{ name                                 }
      LabelSearch(maxLabel, 4, 0, 0);
      if stringsize <> 0 then begin
         Out(129);
         Out2(stringsize); Out2(0);
         Out(1);
         end; {if}
      Out(0);
      len := length(ip^.name^);		{place the name in the string buffer}
      if maxstring-stringsize >= len+1 then begin
         stringspace^[stringsize+1] := chr(len);
         for j := 1 to len do
            stringspace^[j+stringsize+1] := ip^.name^[j];
         stringsize := stringsize+len+1;
         end {if}
      else
         Error(60);
      end; {WriteName}


      procedure WriteScalarType (tp: typePtr; modifiers, subscripts: integer);

      { Write a scalar type and subscript field			}
      {								}
      { parameters:						}
      {    tp - type pointer					}
      {    modifiers - value to or with the type code		}
      {    subscripts - number of subscripts			}

      var
         val: integer;			{type value}

      begin {WriteScalarType}
      case tp^.baseType of
	 cgByte:	val := $40;
         cgUByte:	val := $00;
         cgWord:	if tp^.cType = ctBool then
                	   val := $09
                	else
                	   val := $01;
         cgUWord:	val := $41;
         cgLong:	val := $02;
         cgULong:	val := $42;
         cgReal:	val := $03;
         cgDouble:	val := $04;
         cgComp:	val := $0A;
         cgExtended:	val := $05;
         cgQuad:	val := $0A; {same as comp}
         cgUQuad:	val := $4A;
         otherwise:	val := $01;
         end; {case}
      CnOut(val | modifiers);		{write the format byte}
      CnOut2(subscripts);		{write the # of subscripts}
      end; {WriteScalarType}


      procedure WritePointerType (tp: typePtr; subscripts: integer);

      { write a pointer type field				}
      {								}
      { parameters:						}
      {    tp - pointer type					}
      {    subscripts - number of subscript fields		}

      begin {WritePointerType}
      tp := tp^.ptype;
      while tp^.kind = definedType do
         tp := tp^.dType;
      case tp^.kind of
         scalarType:	WriteScalarType(tp, $80, subscripts);
         enumType,
         functionType:  WriteScalarType(intPtr, $80, subscripts);
         otherwise:	begin
        		CnOut(11);
        		CnOut2(subscripts);
                        end;
         end; {case}
      end; {WritePointerType}


      procedure ExpandPointerType (tp: typePtr); forward;
      

      procedure ExpandStructType (tp: typePtr);

      { write the type entries for a struct or union		}
      {								}
      { parameters:						}
      {    tp - struct/union type				}

      var
         ip: identPtr;			{used to trace the field list}

      begin {ExpandStructType}
      ip := tp^.fieldList;
      { fieldList is nil if this is a forward declared struct. }
      if ip = nil then ip := defaultStruct^.fieldList;

      while ip <> nil do begin
         if ip^.name^[1] <> '~' then
            GenSymbol(ip, none);
         ip := ip^.next;
         end; {while}
      end; {ExpandStructType}


      procedure WriteArrays (tp: typePtr);

      { handle an array type					}
      {								}
      { parameters:						}
      {    tp - array type					}

      var
         count: 0..maxint;		{# of subscripts}
         size: longint;			{for converting long numbers}
         tp2: typePtr;			{used to trace array type list}

      begin {WriteArrays}
      count := 0;			{count the subscripts}
      tp2 := tp;
      while tp2^.kind = arrayType do begin
         count := count+1;
         tp2 := tp2^.aType;
         end; {while}
      while tp2^.kind = definedType do
         tp2 := tp2^.dType;         
      if tp2^.kind = scalarType then	{write the type code}
         if tp2^.baseType in [cgByte,cgUByte] then begin
            count := count-1;
            CnOut(6);
            CnOut2(count);
            end {if}
         else
            WriteScalarType(tp2, 0, count)
      else if tp2^.kind = enumType then
         WriteScalarType(intPtr, 0, count)
      else if tp2^.kind = pointerType then
         WritePointerType(tp2, count)
      else begin
         CnOut(12);
         CnOut2(count);
         end; {else if}
      while count <> 0 do begin		{write the subscript entries}
         CnOut2(0); CnOut2(0);
         if tp^.elements = 0 then
            size := $00FFFFFF
         else
            size := tp^.elements-1;
         CnOut2(long(size).lsw); CnOut2(long(size).msw);
         size := tp^.aType^.size;
         CnOut2(long(size).lsw); CnOut2(long(size).msw);
         symLength := symLength+12;
         tp := tp^.aType;
         count := count-1;
         end; {while}
      if tp2^.kind = pointerType then	{expand complex types}
         ExpandPointerType(tp2)
      else if tp2^.kind in [structtype,uniontype] then
         ExpandStructType(tp2);
      end; {WriteArrays}


      procedure ExpandPointerType {tp: typePtr};

      { write the type entries for complex pointer types	}
      {								}
      { parameters:						}
      {    tp - pointer type					}

      var
	 disp: integer;			{disp to symbol of same type}

      begin {ExpandPointerType}
      tp := tp^.ptype;
      while tp^.kind = definedType do
         tp := tp^.dType;
      if tp^.kind in [pointerType,arrayType,structType,unionType] then
         begin
         symLength := symLength+12;
         CnOut2(0); CnOut2(0);
         CnOut2(0); CnOut2(0);
         CnOut(0);
	 case tp^.kind of
            pointerType:	begin
         		   	WritePointerType(tp, 0);
                           	ExpandPointerType(tp);
                           	end;
            arrayType:		WriteArrays(tp);
            structType,
            unionType:		begin
				disp := GetTypeDisp(tp);
                                if disp = noDisp then begin
        		   	   CnOut(12);
        		   	   CnOut2(0);
                           	   ExpandStructType(tp);
                                   end {if}
                                else begin
        		   	   CnOut(13);
        		   	   CnOut2(disp);
                                   end; {else}
                           	end;
            end; {case}
         end; {if}
      end; {ExpandPointerType}


   begin {GenSymbol}
   tPtr := ip^.itype;
   while tPtr^.kind = definedType do
      tPtr := tPtr^.dType;
   if tPtr^.kind in
      [scalarType,arrayType,pointerType,enumType,structType,unionType]
      then begin
      symLength := symLength+12;        {update length of symbol table}
      WriteName(ip);			{write the name field}
      WriteAddress(ip);			{write the address field}
      case tPtr^.kind of
         scalarType:	WriteScalarType(tPtr, 0, 0);
         enumType:	WriteScalarType(intPtr, 0, 0);
         pointerType:	begin
         		WritePointerType(tPtr, 0);
                        ExpandPointerType(tPtr);
                        end;
         arrayType:	WriteArrays(tPtr);
         structType,
         unionType:	begin
			disp := GetTypeDisp(tPtr);
                        if disp = noDisp then begin
        		   CnOut(12);
        		   CnOut2(0);
                           ExpandStructType(tPtr);
                           end {if}
                        else begin
        		   CnOut(13);
        		   CnOut2(disp);
                           end; {else}
                        end;
         end; {case}
      end; {if}
   end; {GenSymbol}


begin {GenSymbols}
tpList := nil;				{no types so far}
if sym <> nil then
   for i := 0 to hashSize do begin      {loop over all hash buckets}
      ip := sym^.buckets[i];            {trace through all symbols in this bucket}
      while ip <> nil do begin
         if ip^.storage <> none then
            GenSymbol(ip, ip^.storage);
         ip := ip^.next;                {next symbol}
         end; {while}
      end; {for}
while tpList <> nil do begin		{dispose of type list}
   tp2 := tpList;
   tpList := tp2^.next;
   dispose(tp2);
   end; {while}
if doGlobals then			{do globals}
   GenSymbols(globalTable, false);
end; {GenSymbols}


procedure InitSymbol;

{ Initialize the symbol table module                            }

var
   i: 0..hashSize;                      {loop variable}

begin {InitSymbol}
staticNum := '~0000';                   {no functions processed}
table := nil;                           {initialize the global symbol table}
PushTable;
globalTable := table;
functionTable := nil;
                                        {declare base types}
new(sCharPtr);                          {signed char}
with sCharPtr^ do begin
   size := cgByteSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgByte;
   cType := ctSChar;
   end; {with}
new(charPtr);                           {char}
with charPtr^ do begin
   size := cgByteSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgUByte;
   cType := ctChar;
   end; {with}
new(uCharPtr);                          {unsigned char}
with uCharPtr^ do begin
   size := cgByteSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgUByte;
   cType := ctUChar;
   end; {with}
new(shortPtr);                          {short}
with shortPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgWord;
   cType := ctShort;
   end; {with}
new(uShortPtr);                         {unsigned short}
with uShortPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgUWord;
   cType := ctUShort;
   end; {with}
new(intPtr);                            {int}
with intPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgWord;
   cType := ctInt;
   end; {with}
new(uIntPtr);                           {unsigned int}
with uIntPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgUWord;
   cType := ctUInt;
   end; {with}
new(int32Ptr);                          {int (32-bit)}
with int32Ptr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgLong;
   cType := ctInt32;
   end; {with}
new(uInt32Ptr);                         {unsigned int (32-bit)}
with uInt32Ptr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgULong;
   cType := ctUInt32;
   end; {with}
new(longPtr);                           {long}
with longPtr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgLong;
   cType := ctLong;
   end; {with}
new(uLongPtr);                          {unsigned long}
with uLongPtr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgULong;
   cType := ctULong;
   end; {with}
new(longLongPtr);                       {long long}
with longLongPtr^ do begin
   size := cgQuadSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgQuad;
   cType := ctLongLong;
   end; {with}
new(uLongLongPtr);                      {unsigned long long}
with uLongLongPtr^ do begin
   size := cgQuadSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgUQuad;
   cType := ctULongLong;
   end; {with}
new(floatPtr);                          {real}
with floatPtr^ do begin
   size := cgRealSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgReal;
   cType := ctFloat;
   end; {with}
new(doublePtr);                         {double}
with doublePtr^ do begin
   size := cgDoubleSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgDouble;
   cType := ctDouble;
   end; {with}
new(compPtr);                           {comp}
with compPtr^ do begin
   size := cgCompSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgComp;
   cType := ctComp;
   end; {with}
new(extendedPtr);                       {extended, aka long double}
with extendedPtr^ do begin
   size := cgExtendedSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgExtended;
   cType := ctLongDouble;
   end; {with}
new(boolPtr);                           {_Bool}
with boolPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgWord;
   cType := ctBool;
   end; {with}
new(stringTypePtr);                     {string constant type}
with stringTypePtr^ do begin
   size := 0;
   saveDisp := 0;
   qualifiers := [];
   kind := arrayType;
   aType := charPtr;
   elements := 0;
   end; {with}
new(utf16StringTypePtr);                {UTF-16 string constant type}
with utf16StringTypePtr^ do begin
   size := 0;
   saveDisp := 0;
   qualifiers := [];
   kind := arrayType;
   aType := uShortPtr;
   elements := 0;
   end; {with}
new(utf32StringTypePtr);                {UTF-32 string constant type}
with utf32StringTypePtr^ do begin
   size := 0;
   saveDisp := 0;
   qualifiers := [];
   kind := arrayType;
   aType := uLongPtr;
   elements := 0;
   end; {with}
new(voidPtr);                           {void}
with voidPtr^ do begin
   size := 0;
   saveDisp := 0;
   qualifiers := [];
   kind := scalarType;
   baseType := cgVoid;
   cType := ctVoid;
   end; {with}
new(voidPtrPtr);                        {typeless pointer}
with voidPtrPtr^ do begin
   size := cgPointerSize;
   saveDisp := 0;
   qualifiers := [];
   kind := pointerType;
   pType := voidPtr;
   end; {with}
new(charPtrPtr);                        {char *}
with charPtrPtr^ do begin
   size := cgPointerSize;
   saveDisp := 0;
   qualifiers := [];
   kind := pointerType;
   pType := charPtr;
   end; {with}
new(vaInfoPtr);                         {internal varargs info type (char*[2])}
with vaInfoPtr^ do begin
   size := cgPointerSize*2;
   saveDisp := 0;
   qualifiers := [];
   kind := arrayType;
   aType := charPtrPtr;
   elements := 2;
   end; {with}
new(defaultStruct);                     {default structure}
with defaultStruct^ do begin            {(for structures with errors)}
   size := cgWordSize;
   saveDisp := 0;
   qualifiers := [];
   kind := structType;
   sName := nil;
   constMember := false;
   flexibleArrayMember := false;
   new(fieldList);
   with fieldlist^ do begin
      next := nil;
      name := @'field';
      itype := intPtr;
      class := ident;
      state := declared;
      disp := 0;
      bitdisp := 0;
      end; {with}
   end; {with}
new(constCharPtr);                      {const char}
constCharPtr^ := charPtr^;
constCharPtr^.qualifiers := [tqConst];
end; {InitSymbol}


function IsVoid {tp: typePtr): boolean};

{ Check to see if a type is void                                }
{                                                               }
{ Parameters:                                                   }
{    tp - type to check                                         }
{                                                               }
{ Returns: True if the type is void, else false                 }

begin {IsVoid}
IsVoid := false;
if tp = voidPtr then
   IsVoid := true
else if tp^.kind = scalarType then
   if tp^.baseType = cgVoid then
      IsVoid := true;
end; {IsVoid}


function CopyType (tp: typePtr): typePtr;

{ Make a new copy of a type, so it can be modified.             }
{                                                               }
{ Parameters:                                                   }
{    tp - type to copy                                          }
{                                                               }
{ Returns: The new copy of the type                             }

var
   tType: typePtr;                      {the new copy of the type}
   p1,p2: parameterPtr;                 {parameter ptrs for copying prototypes}
   pPtr: ^parameterPtr;                 {temp for copying prototypes}

begin {CopyType}
if tp^.kind in [structType,unionType] then
   Error(57);
tType := pointer(Malloc(sizeof(typeRecord)));
tType^ := tp^;                          {copy type record}
tType^.saveDisp := 0;
if tp^.kind = functionType then         {copy prototype parameter list}
   if tp^.prototyped then begin
      p1 := tp^.parameterList;
      pPtr := @tType^.parameterList;
      while p1 <> nil do begin
         p2 := pointer(Malloc(sizeof(parameterRecord)));
         p2^ := p1^;
         pPtr^ := p2;
         pPtr := @p2^.next;
         p1 := p1^.next;
         end; {while}
      end; {if}
CopyType := tType;
end; {CopyType}


function MakeCompositeType {t1, t2: typePtr): typePtr};

{ Make the composite type of two compatible types.              }
{ See C17 section 6.2.7.                                        }
{                                                               }
{ parameters:                                                   }
{       t1,t2 - the input types (should be compatible)          }
{                                                               }
{ returns: pointer to the composite type                        }

var
   compType: typePtr;                   {the composite type}
   tType: typePtr;                      {temp type}
   p1,p2: parameterPtr;                 {parameter ptrs for handling prototypes}

begin {MakeCompositeType}
compType := t2;                         {default to t2}
if t1 <> t2 then
   if t1^.kind = t2^.kind then begin
      if t2^.kind = functionType then   {switch fn types if only t1 is prototyped}
         if not t2^.prototyped then
            if t1^.prototyped then begin
               compType := t1;
               t1 := t2;
               t2 := compType;
               end; {if}
                                        {apply recursively for derived types}
      if t2^.kind in [arrayType,pointerType,functionType] then begin
            tType := MakeCompositeType(t1^.aType,t2^.aType);
            if tType <> t2^.aType then begin
               compType := CopyType(compType);
               compType^.aType := tType;
               end; {if}
         end; {if}
      if t2^.kind = arrayType then      {get array size from t1 if needed}
         if t2^.size = 0 then
            if t1^.size <> 0 then
               if t1^.aType^.size = t2^.aType^.size then begin
                  if compType = t2 then
                     compType := CopyType(t2);
                  CompType^.size := t1^.size;
                  CompType^.elements := t1^.elements;
                  end; {if}
      if t2^.kind = functionType then   {compose function parameter types}
         if t1^.prototyped and t2^.prototyped then begin
            if compType = t2 then
               compType := CopyType(t2);
            p1 := t1^.parameterList;
            p2 := compType^.parameterList;
            while (p1 <> nil) and (p2 <> nil) do begin
               p2^.parameterType :=
                  MakeCompositeType(p1^.parameterType,p2^.parameterType);
               p1 := p1^.next;
               p2 := p2^.next;
               end; {while}
            end;
      end; {if}
MakeCompositeType := compType;
end; {MakeCompositeType}


function MakePascalType {origType: typePtr): typePtr};

{ make a version of a type with the pascal qualifier applied    }
{                                                               }
{ parameters:                                                   }
{       origType - the original type                            }
{                                                               }
{ returns: pointer to the pascal-qualified type                 }

var
   pascalType: typePtr;                 {the modified type}
   tp,tp2: typePtr;                     {work pointers}
   p1,p2,p3: parameterPtr;              {for reversing prototyped parameters}

begin {MakePascalType}
pascalType := pointer(Malloc(sizeof(typeRecord)));
pascalType^ := origType^;
MakePascalType := pascalType;
tp := pascalType;
while tp <> nil do
   case tp^.kind of
      arrayType,
      pointerType:  begin
                    tp2 := pointer(Malloc(sizeof(typeRecord)));
                    tp2^ := tp^.pType^;
                    tp^.pType := tp2;
                    tp := tp2;
                    end;
      functionType: begin
                    if not tp^.isPascal then begin
                       {reverse the parameter list}
                       p1 := tp^.parameterList;
                       if p1 <> nil then begin
                          p2 := nil;
                          while p1 <> nil do begin
                             p3 := pointer(Malloc(sizeof(parameterRecord)));
                             p3^ := p1^;
                             p1 := p1^.next;
                             p3^.next := p2;
                             p2 := p3;
                             end; {while}
                          tp^.parameterList := p2;
                          end; {if}
                       tp^.isPascal := true;
                       end; {if}
                    tp := nil;
                    end;
      otherwise:    begin
                    Error(94);
                    MakePascalType := origType;
                    tp := nil;
                    end;
      end; {case}
end; {MakePascalType}


function MakePointerTo {pType: typePtr): typePtr};

{ make a pointer type                                           }
{                                                               }
{ parameters:                                                   }
{       pType - the type pointed to                             }
{                                                               }
{ returns: the pointer type                                     }

var
   tp: typePtr;                         {the pointer type}


begin {MakePointerTo}
tp := pointer(Malloc(sizeof(typeRecord)));
tp^.size := cgPointerSize;
tp^.saveDisp := 0;
tp^.qualifiers := [];
tp^.kind := pointerType;
tp^.pType := pType;
MakePointerTo := tp;
end; {MakePointerTo}


function MakeQualifiedType {origType: typePtr; qualifiers: typeQualifierSet):
   typePtr};

{ make a qualified version of a type                            }
{                                                               }
{ parameters:                                                   }
{       origType - the original type                            }
{       qualifiers - the type qualifier(s) to add               }
{                                                               }
{ returns: pointer to the qualified type                        }

var
   tp: typePtr;                         {the qualified type}
   elemType: typePtr;                   {array element type}

begin {MakeQualifiedType}
if qualifiers <> [] then begin          {make qualified version of type}
   tp := pointer(Malloc(sizeof(typeRecord)));
   if origType^.kind in [structType,unionType] then begin
      tp^.size := origType^.size;
      tp^.kind := definedType;
      tp^.dType := origType;
      tp^.saveDisp := 0;
      tp^.qualifiers := qualifiers;
      end {if}
   else begin
      tp^ := origType^;
      tp^.qualifiers := tp^.qualifiers + qualifiers;
      end; {else}
   MakeQualifiedType := tp;
                                        {move array type quals to element type}
   while tp^.kind = arrayType do begin
      elemType := pointer(Malloc(sizeof(typeRecord)));
      if tp^.aType^.kind in [structType,unionType] then begin
         elemType^.size := tp^.aType^.size;
         elemType^.kind := definedType;
         elemType^.dType := tp^.aType;
         elemType^.saveDisp := 0;
         elemType^.qualifiers := qualifiers;
         end {if}
      else begin
         elemType^ := tp^.aType^;
         elemType^.qualifiers := elemType^.qualifiers + qualifiers;
         end; {else}
      tp^.aType := elemType;
      tp^.qualifiers := [];             {remove for C23}
      tp := elemType;
      end; {if}
   end {if}
else
   MakeQualifiedType := origType;
end; {MakeQualifiedType}


function Unqualify {tp: typePtr): typePtr};

{ returns the unqualified version of a type                     }
{                                                               }
{ parameters:                                                   }
{       tp - the original type                                  }
{                                                               }
{ returns: pointer to the unqualified type                      }

var
   tp2: typePtr;                        {unqualified type}

begin {Unqualify}
while tp^.kind = definedType do
   tp := tp^.dType;
Unqualify := tp;
if tp^.qualifiers <> [] then
   if not (tp^.kind in [structType,unionType]) then begin
      tp2 := pointer(Malloc(sizeof(typeRecord)));
      tp2^ := tp^;
      tp2^.qualifiers := [];
      Unqualify := tp2;
      end;
end; {Unqualify}


function NewSymbol {name: stringPtr; itype: typePtr; class: tokenEnum;
                   space: spaceType; state: stateKind; isInline: boolean):
                   identPtr};

{ insert a new symbol in the symbol table                       }
{                                                               }
{ parameters:                                                   }
{       name - pointer to the symbol name                       }
{       itype - pointer to the symbol type                      }
{       class - storage class                                   }
{       space - the kind of variable space to put the           }
{               identifier in                                   }
{       state - variable declaration state                      }
{                                                               }
{ returns: pointer to the inserted symbol                       }

var
   cs: identPtr;                        {current symbol}
   hashPtr: ^identPtr;                  {pointer to hash bucket in symbol table}
   i: integer;                          {loop variable}
   isFunction: boolean;                 {is this the symbol for a function?}
   isGlobal: boolean;                   {are we using the global table?}
   lUseGlobalPool: boolean;             {use the global symbol pool?}
   needSymbol: boolean;                 {do we need to declare it?}
   np: stringPtr;                       {for forming static name}
   p: identPtr;                         {work pointer}
   tk: tokenType;                       {fake token; for FindSymbol}
   
   procedure UnInline;

   { Generate a non-inline definition for a function previously }
   { defined with an (apparent) inline definition.              }
   
   var
      fName: stringPtr;                 {name of function}
      i: integer;                       {loop variable}
   
   begin {UnInline}
   if cs^.iType^.isPascal then begin
      fName := pointer(Malloc(length(name^)+1));
      CopyString(pointer(fName), pointer(name));
      for i := 1 to length(fName^) do
         if fName^[i] in ['a'..'z'] then
            fName^[i] := chr(ord(fName^[i]) & $5F);
      end {if}
   else
      fName := name;
   Gen2Name(dc_str, 0, 0, fName);
   code^.s := m_jml;
   code^.q := 0;
   code^.r := ord(longabsolute);
   new(code^.lab);
   code^.lab^ := concat('~inline~',name^);
   Gen0(pc_nat);
   Gen0(dc_enp);
   end; {UnInline}

begin {NewSymbol}
needSymbol := true;                     {assume we need a symbol}
isGlobal := false;                      {set up defaults}
isFunction := false;
lUseGlobalPool := useGlobalPool;
tk.name := name;
tk.symbolPtr := nil;
if space <> fieldListSpace then begin   {are we defining a function?}
   if (itype <> nil) and (itype^.kind = functionType) then begin
      isFunction := true;
      if class in [autosy, ident] then
         class := externsy
      else                              {If explicit storage class is given,}
         isInline := false;             {this is not an inline definition.  }
      end {if}
   else if (itype <> nil) and (itype^.kind in [structType,unionType])
      and (itype^.fieldList = nil) and doingParameters then begin
      useGlobalPool := true;
      end; {else if}
   cs := FindSymbol(tk, space, true, true); {check for duplicates}
   if cs <> nil then begin
      if ((itype = nil)
         or (cs^.itype = nil)
         or (not CompTypes(cs^.itype, itype))
         or ((cs^.state = initialized) and (state = initialized))
         or ((class = typedefsy) <> (cs^.class = typedefsy))
         or ((globalTable <> table) 
            and (not (class in [externsy,typedefsy])
               or not (cs^.class in [externsy,typedefsy]))))
         and ((not doingParameters) or (cs^.state <> declared))
         then
         Error(42)
      else begin
         itype := MakeCompositeType(cs^.itype, itype);
         if class = externsy then
            if cs^.class = staticsy then
               class := staticsy;
         if cs^.storage = external then
            if isInline then
               isInline := cs^.inlineDefinition
            else if cs^.inlineDefinition then
               if iType^.kind = functionType then
                  if cs^.state = defined then
                     if table = globalTable then
                        UnInline;
         p := cs;
         needSymbol := false;
         end; {else}
      end {if}
   else if class = externsy then        {check for outer decl of same object/fn}
      if table <> globalTable then begin
         cs := FindSymbol(tk, space, false, true);
         if cs <> nil then
            if cs^.name^[1] <> '~' then {exclude block-scope statics}
               if cs^.storage in [global,external,private] then begin
                  if not CompTypes(cs^.itype, itype) then
                     Error(47);
                  itype := MakeCompositeType(cs^.itype, itype);
                  end; {if}
         end; {if}
   end; {if}
if class = staticsy then                {statics go in the global symbol table}
   if not isFunction then
      if globalTable <> table then begin
         isGlobal := true;              {note that we will use the global table}
         useGlobalPool := true;
         np := pointer(GMalloc(length(name^)+6)); {form static name}
         np^[0] := chr(5+length(name^));
         for i := 1 to 5 do
            np^[i] := table^.staticNum[i];
         for i := 1 to length(name^) do
            np^[i+5] := name^[i];
         name := np;
         end; {if}
if needSymbol then begin
   p := pointer(Calloc(sizeof(identRecord))); {get space for the record}
   {p^.iPtr := nil;}                    {no initializers, yet}
   {p^.saved := 0;}			{not saved}
   p^.state := state;                   {set the state}
   {p^.isForwardDeclared := false;}     {assume no forward declarations are used}
   p^.name := name;                     {record the name}
   {p^.next := nil;}
   {p^.used := false;}                  {unused for now}
   if space <> fieldListSpace then      {insert the symbol in the hash bucket}
      begin
      if itype = nil then
         hashPtr := pointer(ord4(table)+Hash(name))
      else if isGlobal then
         hashPtr := pointer(ord4(globalTable)+Hash(name))
      else
         hashPtr := pointer(ord4(table)+Hash(name));
      if space = tagSpace then
         hashPtr := pointer(ord4(hashPtr) + 4*(hashSize+1));
      p^.next := hashPtr^;
      hashPtr^ := p;
      end; {if}
   end; {if}
if space = fieldListSpace then          {check and set the storage class}
   p^.storage := none
else if class in [autosy,registersy] then
   begin
   if doingFunction or doingParameters then begin
      p^.storage := stackFrame;
      class := ident;
      end {if}
   else begin
      p^.storage := global;
      Error(62);
      end; {else}
   end {if}
else if class = ident then begin
   if doingFunction then begin
      p^.storage := stackFrame;
      class := autosy;
      end {if}
   else
      p^.storage := global;
   end {else if}
else if class = externsy then begin
   p^.storage := external;
   p^.inlineDefinition := isInline;
   end {else if}
else if class = staticsy then
   p^.storage := private
else
   p^.storage := none;
p^.class := class;
p^.itype := itype;                      {set the symbol field values}
NewSymbol := p;                         {return a pointer to the new entry}
useGlobalPool := lUseGlobalPool;        {restore the useGlobalPool variable}
end; {NewSymbol}


procedure CheckUnused {tPtr: symbolTablePtr};

{ check for unused variables in symbol table                    }

var
   i: integer;                          {loop variable}
   ip: identPtr;                        {current symbol}
   nameStr: stringPtr;

begin {CheckUnused}
for i := 0 to hashSize do begin         {loop over all hash buckets}
   ip := tPtr^.buckets[i];              {trace through non-static symbols}
   while ip <> nil do begin
      if not ip^.used then
         if ip^.itype <> nil then
            if not (ip^.itype^.kind in [functionType,enumConst]) then
               if ip^.storage in [stackFrame,private] then
                  if not (ip^.name^[1] in ['~','@']) then begin
                     new(nameStr);
                     nameStr^ := ip^.name^;
                     ErrorWithExtraString(185, nameStr);
                     end; {if}
      ip := ip^.next;
      end; {while}
   ip := globalTable^.buckets[i];       {trace through static symbols}
   while ip <> nil do begin
      if not ip^.used then
         if ip^.itype <> nil then
            if not (ip^.itype^.kind in [functionType,enumConst]) then
               if ip^.storage = private then
                  if copy(ip^.name^,1,5) = tPtr^.staticNum then begin
                     new(nameStr);
                     nameStr^ := copy(ip^.name^, 6, maxint);
                     ErrorWithExtraString(185, nameStr);
                     end; {if}
      ip := ip^.next;
      end; {while}
   end; {for}
end; {CheckUnused}


procedure PopTable;

{ Pop a symbol table (remove definitions local to a block)      }

var
   tPtr: symbolTablePtr;                {work pointer}

begin {PopTable}
tPtr := table;
{if printSymbols then                 {debug}
{   PrintTable(tPtr);                 {debug}
if (lint & lintUnused) <> 0 then
   CheckUnused(tPtr);
if tPtr^.next <> nil then begin
   table := table^.next;
   dispose(tPtr);
   end; {if}
end; {PopTable}


{ copy 'symbol.print'} {debug}


procedure PushTable;

{ Create a new symbol table, pushing the old one                }

var
   done: boolean;                       {loop termination}
   i: integer;                          {loop index}
   tPtr: symbolTablePtr;                {work pointer}

begin {PushTable}
i := 5;                                 {increment the static var number}
repeat
   staticNum[i] := succ(staticNum[i]);
   done := staticNum[i] <> succ('9');
   if not done then begin
      staticNum[i] := '0';
      i := i-1;
      done := i = 1;
      end; {if}
until done;
new(tPtr);                              {create a new symbol table}
ClearTable(tPtr^);
tPtr^.next := table;
table := tPtr;
tPtr^.staticNum := staticNum;           {record the static symbol table number}
end; {PushTable}


procedure ResolveForwardReference {iPtr: identPtr};

{ resolve a forward reference                                   }
{                                                               }
{ parameters:                                                   }
{       iPtr - ptr to the forward declared identifier           }

var
   fl: identPtr;			{for tracing field lists}
   ltk: tokenType;                      {for searching for forward refs}
   sym: identPtr;                       {for finding forward refs}
   lPtr,tPtr: typePtr;                  {for tracing forward declared types}

begin {ResolveForwardReference}
iPtr^.isForwardDeclared := false;	{we will succeed or flag an error...}
tPtr := iPtr^.itype;			{skip to the struct/union type}
lPtr := nil;
while tPtr^.kind in [pointerType,arrayType,functionType,definedType] do begin
   lPtr := tPtr;
   tPtr := tPtr^.pType;
   end;
if tPtr^.sName <> nil then begin	{resolve the forward reference}
   ltk.name := tPtr^.sName;
   ltk.symbolPtr := nil;
   sym := FindSymbol(ltk,tagSpace,false,true);
   if sym <> nil then begin
      if sym^.itype^.kind <> tPtr^.kind then
	 Error(107)
      else begin
         if sym^.itype = tPtr then
            tPtr^.sName := nil
         else begin
            tPtr := sym^.itype;
            if lPtr <> nil then
               lPtr^.ptype := tPtr;
            end; {else}
         end; {else}
      end; {if}
   end; {if}
if lPtr <> nil then
   tPtr := lPtr^.pType;			{check the field list for other fwd refs}
while tPtr^.kind in [pointerType,arrayType,functionType,definedType] do
   tPtr := tPtr^.pType;
if tPtr^.kind in [structType,unionType] then begin
   fl := tPtr^.fieldList;
   while fl <> nil do begin
      if fl^.isForwardDeclared then
         ResolveForwardReference(fl);
      fl := fl^.next;
      end; {while}
   end; {if}
end; {ResolveForwardReference}


function StringType{prefix: charStrPrefixEnum): typePtr};

{ returns the type of a string literal with specified prefix    }
{                                                               }
{ parameters:                                                   }
{       prefix - the prefix                                     }

begin {StringType}
if prefix in [prefix_none,prefix_u8] then
   StringType := stringTypePtr
else if prefix in [prefix_u16,prefix_L] then
   StringType := utf16StringTypePtr
else
   StringType := utf32StringTypePtr;
end; {StringType}

end.

{$append 'symbol.asm'}
