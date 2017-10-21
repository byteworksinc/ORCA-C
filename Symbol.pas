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
{  noDeclarations - have we declared anything at this level?    }
{  table - current symbol table                                 }
{                                                               }
{  bytePtr - pointer to the base type for bytes                 }
{  uBytePtr - pointer to the base type for unsigned bytes       }
{  wordPtr - pointer to the base type for words                 }
{  uWordPtr - pointer to the base type for unsigned words       }
{  longPtr - pointer to the base type for long words            }
{  uLongPtr - pointer to the base type for unsigned long words  }
{  realPtr - pointer to the base type for reals                 }
{  doublePtr - pointer to the base type for double precision    }
{       reals                                                   }
{  compPtr - pointer to the base type for comp reals            }
{  extendedPtr - pointer to the base type for extended reals    }
{  voidPtr - pointer to the base type for void                  }
{  voidPtrPtr - typeless pointer, for some type casting         }
{  stringTypePtr - pointer to the base type for string          }
{       constants                                               }
{  defaultStruc - default for structures with errors            }
{                                                               }
{---------------------------------------------------------------}

unit Symbol;

{$LibPrefix '0/obj/'}

interface

uses CCommon, CGI, MM, Scanner;

{$segment 'cc'}

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
   noDeclarations: boolean;             {have we declared anything at this level?}
   table: symbolTablePtr;               {current symbol table}
   globalTable: symbolTablePtr;         {global symbol table}
 
   bytePtr,uBytePtr,wordPtr,uWordPtr,   {base types}
      longPtr,uLongPtr,realPtr,doublePtr,compPtr,extendedPtr,
      stringTypePtr,voidPtr,voidPtrPtr,defaultStruct: typePtr;

{---------------------------------------------------------------}

procedure CheckStaticFunctions;

{ check for undefined functions                                 }


function CompTypes (t1, t2: typePtr): boolean;

{ Determine if the two types are compatible                     }


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


function LabelToDisp (lab: integer): integer; extern;

{ convert a local label number to a stack frame displacement    }
{                                                               }
{ parameters:                                                   }
{       lab - label number                                      }


function NewSymbol (name: stringPtr; itype: typePtr; class: tokenEnum;
                   space: spaceType; state: stateKind): identPtr;

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

{---------------------------------------------------------------}

implementation

var
   staticNum,                             {static variable number}
   firstStaticNum: packed array[1..6] of char; {staticNum at start of function}

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


   function IsVoid (tp: typePtr): boolean;

   { Check to see if a type is void				}
   {								}
   { Parameters:						}
   {    tp - type to check					}
   {								}
   { Returns: True if the type is void, else false		}

   begin {IsVoid}
   IsVoid := false;
   if tp = voidPtr then
      IsVoid := true
   else if tp^.kind = scalarType then
      if tp^.baseType = cgVoid then
         IsVoid := true;
   end; {IsVoid}


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
         if kind2 = scalarType then
            CompTypes := t1^.baseType = t2^.baseType
         else if kind2 = enumType then
            CompTypes := t1^.baseType = cgWord;

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
         if kind2 = functionType then
            CompTypes := CompTypes(t1^.ftype,t2^.ftype)
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
            CompTypes := t2^.baseType = cgWord
         else if kind2 = enumType then
            CompTypes := true;

      structType,unionType:
         CompTypes := t1 = t2;

      otherwise: ;

      end; {case t1^.kind}
1:
end; {CompTypes}


procedure DoGlobals;

{ declare the ~globals and ~arrays segments                     }


   procedure GenArrays;

   { define global arrays                                       }

   var
      didOne: boolean;                  {have we found an array yet?}
      i: 0..hashSize;                   {loop variable}
      ip: initializerPtr;               {used to trace initializer lists}
      lval: longint;                    {for converting types}
      size: longint;                    {size of the array}
      sp: identPtr;                     {pointer to a symbol table entry}

   begin {GenArrays}
   didOne := false;
   for i := 0 to hashSize do begin
      sp := table^.buckets[i];
      while sp <> nil do begin
         if sp^.storage in [global,private] then
            if sp^.itype^.kind in [arrayType,structType,unionType] then begin
               if not didOne then begin
                  if smallMemoryModel then
                     currentSegment := '          '
                  else
                     currentSegment := '~ARRAYS   ';
                  Gen2Name(dc_str, $4000, 1, @'~ARRAYS');
                  didOne := true;
                  end; {if}
               if sp^.state = initialized then begin
                  Gen2Name(dc_glb, 0, ord(sp^.storage = private), sp^.name);
                  ip := sp^.iPtr;
                  while ip <> nil do begin
                     case ip^.itype of
                        cgByte,cgUByte,cgWord,cgUWord: begin
                           lval := ip^.ival;
                           Gen2t(dc_cns, long(lval).lsw, ip^.count, ip^.itype);
                           end;
                        cgLong,cgULong:
                           GenL1(dc_cns, ip^.ival, ip^.count);
                        cgReal,cgDouble,cgComp,cgExtended:
                           GenR1t(dc_cns, ip^.rval, ip^.count, ip^.itype);
                        cgString:
                           GenS(dc_cns, ip^.sval);
                        ccPointer: begin
                           code^.optype := ccPointer;
                           code^.r := ord(ip^.pPlus);
                           code^.q := ip^.count;
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
                     ip := ip^.next;
                     end; {while}
                  end {if}
               else begin
                  size := sp^.itype^.size;
                  Gen2Name(dc_glb, long(size).lsw & $7FFF,
                     ord(sp^.storage = private), sp^.name);
        	  size := size & $FFFF8000;
        	  while size <> 0 do begin
                     Gen1(dc_dst, 16384);
                     size := size-16384;
                     end; {while}
                  end; {else}
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
                  case ip^.itype of
                     cgByte,cgUByte,cgWord,cgUWord: begin
                        lval := ip^.ival;
                        Gen2t(dc_cns, long(lval).lsw, 1, ip^.itype);
                        end;
                     cgLong,cgULong:
                        GenL1(dc_cns, ip^.ival, 1);
                     cgReal,cgDouble,cgComp,cgExtended:
                        GenR1t(dc_cns, ip^.rval, 1, ip^.itype);
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

{these segments are not dynamic!}
segmentKind := 0;

{declare the ~globals segment, which holds non-array data types}
if smallMemoryModel then
   currentSegment := '          '
else
   currentSegment := '~GLOBALS  ';
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

var
   i: 0..hashSize;                      {loop variable}
   pln: integer;			{label number}
   size: integer;                       {size of the parameter}
   sp: identPtr;			{symbol pointer}
   tk: tokenType;			{symbol name token}

begin {GenParameters}
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
      if sp^.itype^.kind = arrayType then
	 Gen3(dc_prm, pln, cgPointerSize, sp^.pdisp)
      else begin
	 size := long(sp^.itype^.size).lsw;
	 if (size = 1) and (sp^.itype^.kind = scalarType) then
            size := 2;
	 Gen3(dc_prm, pln, size, sp^.pdisp);
	 end; {else}
      sp^.pln := pln;
      pp := pp^.next;
      end; {while}
   end {if}
else begin				{K&R parameters}
   for i := 0 to hashSize do begin              
      sp := table^.buckets[i];
      while sp <> nil do begin
	 if sp^.storage = parameter then begin
            sp^.pln := GetLocalLabel;
            if sp^.itype^.kind = arrayType then
               Gen3(dc_prm, sp^.lln, cgPointerSize, sp^.pdisp)
            else begin
               size := long(sp^.itype^.size).lsw;
               if (size = 1) and (sp^.itype^.kind = scalarType) then
        	  size := 2;
               Gen3(dc_prm, sp^.lln, size, sp^.pdisp);
               end; {else}
            end; {if}
	 sp := sp^.next;
	 end; {while}
      end; {for}
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
      tp1^.disp := symLength;
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
         stringspace[stringsize+1] := chr(len);
         for j := 1 to len do
            stringspace[j+stringsize+1] := ip^.name^[j];
         stringsize := stringsize+len+1;
         end {if}
      else
         Error(60);
      end; {WriteName}


      procedure WriteScalarType (tp: typePtr; modifiers, subscripts: integer);

      { Write a scalar type and subscipt field			}
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
         cgWord:	val := $01;
         cgUWord:	val := $41;
         cgLong:	val := $02;
         cgULong:	val := $42;
         cgReal:	val := $03;
         cgDouble:	val := $04;
         cgComp:	val := $0A;
         cgExtended:	val := $05;
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
      case tp^.ptype^.kind of
         scalarType:	WriteScalarType(tp^.ptype, $80, subscripts);
         enumType,
         functionType:  WriteScalarType(wordPtr, $80, subscripts);
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
      while ip <> nil do begin
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
      if tp2^.kind = scalarType then	{write the type code}
         if tp2^.baseType in [cgByte,cgUByte] then begin
            count := count-1;
            CnOut(6);
            CnOut2(count);
            end {if}
         else
            WriteScalarType(tp2, 0, count)
      else if tp2^.kind = enumType then
         WriteScalarType(wordPtr, 0, count)
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
      if tp^.ptype^.kind in [pointerType,arrayType,structType,unionType] then
         begin
         symLength := symLength+12;
         CnOut2(0); CnOut2(0);
         CnOut2(0); CnOut2(0);
         CnOut(0);
	 case tp^.ptype^.kind of
            pointerType:	begin
         		   	WritePointerType(tp^.ptype, 0);
                           	ExpandPointerType(tp^.ptype);
                           	end;
            arrayType:		WriteArrays(tp^.ptype);
            structType,
            unionType:		begin
				disp := GetTypeDisp(tp^.ptype);
                                if disp = noDisp then begin
        		   	   CnOut(12);
        		   	   CnOut2(0);
                           	   ExpandStructType(tp^.ptype);
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
   if ip^.itype^.kind in
      [scalarType,arrayType,pointerType,enumType,structType,unionType]
      then begin
      WriteName(ip);			{write the name field}
      WriteAddress(ip);			{write the address field}
      case ip^.itype^.kind of
         scalarType:	WriteScalarType(ip^.itype, 0, 0);
         enumType:	WriteScalarType(wordPtr, 0, 0);
         pointerType:	begin
         		WritePointerType(ip^.itype, 0);
                        ExpandPointerType(ip^.itype);
                        end;
         arrayType:	WriteArrays(ip^.itype);
         structType,
         unionType:	begin
			disp := GetTypeDisp(ip^.itype);
                        if disp = noDisp then begin
        		   CnOut(12);
        		   CnOut2(0);
                           ExpandStructType(ip^.itype);
                           end {if}
                        else begin
        		   CnOut(13);
        		   CnOut2(disp);
                           end; {else}
                        end;
         end; {case}
      symLength := symLength+12;	{update length of symbol table}
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
noDeclarations := false;
                                        {declare base types}
new(bytePtr);                           {byte}
with bytePtr^ do begin
   size := cgByteSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgByte;
   end; {with}
new(uBytePtr);                          {unsigned byte}
with uBytePtr^ do begin
   size := cgByteSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgUByte;
   end; {with}
new(wordPtr);                           {word}
with wordPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgWord;
   end; {with}
new(uWordPtr);                          {unsigned word}
with uWordPtr^ do begin
   size := cgWordSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgUWord;
   end; {with}
new(longPtr);                           {long}
with longPtr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgLong;
   end; {with}
new(uLongPtr);                          {unsigned long}
with uLongPtr^ do begin
   size := cgLongSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgULong;
   end; {with}
new(realPtr);                           {real}
with realPtr^ do begin
   size := cgRealSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgReal;
   end; {with}
new(doublePtr);                         {double}
with doublePtr^ do begin
   size := cgDoubleSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgDouble;
   end; {with}
new(compPtr);                           {comp}
with compPtr^ do begin
   size := cgCompSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgComp;
   end; {with}
new(extendedPtr);                       {extended}
with extendedPtr^ do begin
   size := cgExtendedSize;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgExtended;
   end; {with}
new(stringTypePtr);                     {string constant type}
with stringTypePtr^ do begin
   size := 0;
   saveDisp := 0;
   isConstant := false;
   kind := arrayType;
   aType := uBytePtr;
   elements := 1;
   end; {with}
new(voidPtr);                           {void}
with voidPtr^ do begin
   size := 0;
   saveDisp := 0;
   isConstant := false;
   kind := scalarType;
   baseType := cgVoid;
   end; {with}
new(voidPtrPtr);                        {typeless pointer}
with voidPtrPtr^ do begin
   size := 4;
   saveDisp := 0;
   isConstant := false;
   kind := pointerType;
   pType := voidPtr;
   end; {with}
new(defaultStruct);                     {default structure}
with defaultStruct^ do begin            {(for structures with errors)}
   size := cgWordSize;
   saveDisp := 0;
   isConstant := false;
   kind := structType;
   sName := nil;
   new(fieldList);
   with fieldlist^ do begin
      next := nil;
      name := @'field';
      itype := wordPtr;
      class := ident;
      state := declared;
      disp := 0;
      bitdisp := 0;
      end; {with}
   end; {with}
end; {InitSymbol}


function NewSymbol {name: stringPtr; itype: typePtr; class: tokenEnum;
                   space: spaceType; state: stateKind): identPtr};

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
   isGlobal: boolean;                   {are we using the global table?}
   lUseGlobalPool: boolean;             {use the global symbol pool?}
   needSymbol: boolean;                 {do we need to declare it?}
   np: stringPtr;                       {for forming static name}
   p: identPtr;                         {work pointer}
   tk: tokenType;                       {fake token; for FindSymbol}

begin {NewSymbol}
needSymbol := true;                     {assume we need a symbol}
cs := nil;                              {no current symbol found}
isGlobal := false;                      {set up defaults}
lUseGlobalPool := useGlobalPool;
tk.name := name;
tk.symbolPtr := nil;
if space <> fieldListSpace then begin   {are we defining a function?}
   if itype^.kind = functionType then begin
      isGlobal := true;
      useGlobalPool := true;
      if class in [autosy, ident] then
         class := externsy;
      if not lUseGlobalPool then begin
         np := pointer(Malloc(length(name^)+1));
         CopyString(pointer(np), pointer(name));
         tk.name := np;
         name := np;
         end; {if}
      cs := FindSymbol(tk, space, false, true);
      if cs <> nil then begin
         if cs^.state = defined then
            if state = defined then
               Error(42);
         p := cs;
         needSymbol := false;
         if not itype^.prototyped then begin
            itype^.prototyped := cs^.itype^.prototyped;
            itype^.parameterList := cs^.itype^.parameterList;
            end; {if}
         end; {if}
      end {if}
   else if (itype^.kind in [structType,unionType]) and (itype^.fieldList = nil)
      and doingParameters then begin
      isGlobal := true;
      useGlobalPool := true;
      end; {else if}
   if noDeclarations then begin         {if we need a symbol table, create it}
      if not isGlobal then 
         noDeclarations := false;
      end {if}
   else begin                           {check for duplicates}
      cs := FindSymbol(tk, space, true, false);
      if cs <> nil then begin
         if (not CompTypes(cs^.itype, itype))
            or ((cs^.state = initialized) and (state = initialized))
            or (globalTable <> table) then
            if (not doingParameters) or (cs^.state <> declared) then
               Error(42);
         p := cs;
         needSymbol := false;
         end; {if}
      end; {else}
   end; {if}
if class = staticsy then                {statics go in the global symbol table}
   if not isGLobal then
      if globalTable <> table then begin
         cs := FindSymbol(tk, space, true, true);
         if cs <> nil then begin        {check for duplicates}
            if (not CompTypes(cs^.itype, itype))
               or ((cs^.state = defined) and (state <> initialized))
               or (cs^.state = initialized) then
               Error(42);
            p := cs;
            needSymbol := false;
            end; {if}
         isGlobal := true;              {note that we will use the global table}
         useGlobalPool := true;
         np := pointer(GMalloc(length(name^)+6));
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
      end {if}
   else
      p^.next := nil;
   end; {if}
if class in [autosy,registersy] then    {check and set the storage class}
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
else if class = externsy then
   p^.storage := external
else if class = staticsy then
   p^.storage := private
else
   p^.storage := none;
p^.class := class;
p^.itype := itype;                      {set the symbol field values}
NewSymbol := p;                         {return a pointer to the new entry}
useGlobalPool := lUseGlobalPool;        {restore the useGlobalPool variable}
end; {NewSymbol}


procedure PopTable;

{ Pop a symbol table (remove definitions local to a block)      }

var
   tPtr: symbolTablePtr;                {work pointer}

begin {PopTable}
tPtr := table;
{if printSymbols then                 {debug}
{   PrintTable(tPtr);                 {debug}
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
if table = globalTable then             {update fistStaticNum}
   firstStaticNum := staticNum;
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
iPtr^.isForwardDeclared := false;	{we will succeeed or flag an error...}
tPtr := iPtr^.itype;			{skip to the struct/union type}
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
         else
	    lPtr^.ptype := sym^.itype;
         end; {else}
      end; {if}
   end; {if}
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

end.

{$append 'symbol.asm'}
