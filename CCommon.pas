{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  CCommon                                                      }
{                                                               }
{  Common declarations and global data for the compiler.        }
{                                                               }
{  Variables:                                                   }
{                                                               }
{  bofPtr - pointer to the start of sourceFile                  }
{  chPtr - pointer to the next character in the file            }
{  codegenStarted - have we started the code generator?         }
{  debugType - line number debug types                          }
{  doingFunction - true if processing a function                }
{  doingParameters - are we processing parm definitions?        }
{  doingPartial - are we doing a partial compile?               }
{  enterEditor - enter editor on terminal errors?               }
{  expandMacros - should macros be expanded?                    }
{  firstPtr - points to first char in current line              }
{  gotoList - list of goto labels                               }
{  includeFile - include file name (for return from includes)   }
{  infoString - language specific command line info             }
{  lastLine - last line number used by pc_nam                   }
{  liDCB - get/set LInfo DCB                                    }
{  lineNumber - source line number                              }
{  lint - lint flags                                            }
{  list - generate source listing?                              }
{  memoryCompile - memory based compile?                        }
{  nameFound - has a pc_nam been generated?                     }
{  numErrors - number of errors in the program                  }
{  objFile - object file name                                   }
{  oldincludeFile - previous includeFile value                  }
{  partialFile - partial compile list                           }
{  sourceFile - source file name                                }
{  terminalErrors - are all errors terminal?                    }
{  traceBack - generate traceback code?                         }
{  useGlobalPool - use global (or local) string pool?           }
{  wait - wait for keypress after errors?                       }
{                                                               }
{  doDispose - dispose of the expression tree as we go?         }
{  expressionValue - the expression evaluator returns the       }
{          value of constant expressions in this variable       }
{  expressionType - the type of the expression                  }
{  expressionTree - for non-constant initializers               }
{  isConstant - is the initializer expression conastant?        }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  CheckGotoList - Make sure all labels have been defined       }
{  ClearHourGlass - Erase the hourglass from the screen		}
{  CopyLongString - copy a long string                          }
{  CopyString - copy a string                                   }
{  DrawHourGlass - Draw the hourglass on the screen		}
{  ExitToEditor - do an error exit to the editor                }
{  GetLocalLabel - get the next local label number              }
{  Hash - find hash displacement                                }
{  InitCCommon - Initialize this module				}
{  ReadFile - read a file                                       }
{  Spin - Spin the spinner					}
{  StopSpin - Stop the spinner					}
{  SystemError - intercept run time compiler errors             }
{  TermError - flag a terminal error                            }
{  typeSpec - type of the last type specifier evaluated by      }
{       TypeSpecifier                                           }
{                                                               }
{---------------------------------------------------------------}

unit CCommon;

interface

const
                                        {hashsize appears in CCOMMON.ASM}
   hashSize      = 876;                 {# hash buckets - 1}
   hashSize2     = 1753;                {# hash buckets * 2 - 1}
   maxLine       = 255;                 {max length of a line}
   maxPath	 = 255;			{max length of a path name}
					{NOTE: maxPath is used in Scanner.asm}
   longstringlen = 4000;                {max length of a string constant}
 
   minChar      = 0;                    {min ordinal value of source character}
   maxChar      = 255;                  {max ordinal value of source character}

                                        {lint masks}
                                        {----------}
   lintUndefFn          = $0001;        {flag use of undefined functions}
   lintNoFnType         = $0002;        {flag functions with no type}
   lintNotPrototyped    = $0004;        {flag functions with no prototypes}
   lintPragmas          = $0008;        {flag unknown prototypes}

                                        {bit masks for GetLInfo flags}
                                        {----------------------------}
   flag_d       = $10000000;            {generate debug code?}
   flag_e       = $08000000;            {abort to editor on terminal error?}
   flag_i       = $00800000;            {ignore symbol files?}
   flag_l       = $00100000;            {list source lines?}
   flag_m       = $00080000;            {memory based compile?}
   flag_o       = $00020000;            {optimize?}
   flag_p       = $00010000;            {print progress info?}
   flag_r       = $00004000;            {rebuild symbol files?}
   flag_s       = $00002000;            {list symbol tables?}
   flag_t       = $00001000;            {treat all errors as terminal?}
   flag_w       = $00000200;            {wait when an error is found?}

   versionStr = '2.1.1 B3';		{compiler version}

type
                                        {Misc.}
                                        {-----}
   long = record lsw,msw: integer; end; {for extracting words from longints}
 
   cString = packed array [1..256] of char; {null terminated string}
   cStringPtr = ^cString;
   longString = record                  {long null terminated string}
      length: integer;
      str: packed array [1..longstringlen] of char;
      end;
   longStringPtr = ^longString;
   pString = packed array [0..maxLine] of char; {length string}
   stringPtr = ^pString;
   ptr        = ^byte;                  {general purpose pointer}
   handle     = ^ptr;                   {gereral purpose handle}
 
   gsosInString = record
       size: integer;
       theString: packed array [1..maxPath] of char;
       end;
   gsosInStringPtr = ^gsosInString;

   {GS/OS class 1 output string}
   gsosOutString = record
       maxSize: integer;
       theString: gsosInString;
       end;
   gsosOutStringPtr = ^gsosOutString;
   
   { The base types include two main categories.  The values starting    }
   { with cg are defined in the code generater, and may be passed to the }
   { code generator for resolution.  The cc types are used internally in }
   { the compiler.  Any values whose type is cc must be resulved to one  }
   { of the cg types before the code generator is called.                }
 
   baseTypeEnum = (cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,
                   cgReal,cgDouble,cgComp,cgExtended,cgString,
                   cgVoid,ccPointer);

                                        {tokens}
                                        {------}
                                        {Note: tokenEnum is duplicated in }
                                        { Table.asm                       }
   tokenEnum = (                        {enumeration of the tokens}
               ident,                   {identifiers}
                                        {constants}
               intconst,uintconst,longconst,ulongconst,doubleconst,
               stringconst,
                                        {reserved words}
               autosy,asmsy,breaksy,casesy,charsy,
               continuesy,constsy,compsy,defaultsy,dosy,
               doublesy,elsesy,enumsy,externsy,extendedsy,
               floatsy,forsy,gotosy,ifsy,intsy,
               inlinesy,longsy,pascalsy,registersy,returnsy,
               shortsy,sizeofsy,staticsy,structsy,switchsy,
               segmentsy,signedsy,typedefsy,unionsy,unsignedsy,
               voidsy,volatilesy,whilesy,
                                        {reserved symbols}
               excch,percentch,carotch,andch,asteriskch,
               minusch,plusch,eqch,tildech,barch,
               dotch,ltch,gtch,slashch,questionch,
               lparench,rparench,lbrackch,rbrackch,lbracech,
               rbracech,commach,semicolonch,colonch,poundch,
               minusgtop,plusplusop,minusminusop,ltltop,gtgtop,
               lteqop,gteqop,eqeqop,exceqop,andandop,
               barbarop,pluseqop,minuseqop,asteriskeqop,slasheqop,
               percenteqop,ltlteqop,gtgteqop,andeqop,caroteqop,
               bareqop,poundpoundop,
               eolsy,eofsy,             {control characters}
               typedef,                 {user types}
               uminus,uand,uasterisk,   {converted operations}
               parameteroper,castoper,opplusplus,opminusminus,
               macroParm);              {macro language}

                                        {Note: this enumeration also    }
                                        { appears in TABLE.ASM,         }
                                        { SCANNER.asm                   }
   charEnum =                           {character kinds}
      (illegal,ch_special,ch_dash,ch_plus,ch_lt,ch_gt,ch_eq,ch_exc,
       ch_and,ch_bar,ch_dot,ch_white,ch_eol,ch_eof,ch_char,ch_string,
       ch_asterisk,ch_slash,ch_percent,ch_carot,ch_pound,letter,digit);

   tokenSet = set of tokenEnum;
   tokenClass = (reservedWord,reservedSymbol,identifier,intConstant,longConstant,
                 doubleConstant,stringConstant,macroParameter);
   identPtr = ^identRecord;             {^ to a symbol table entry}
   tokenType = record                   {a token}
      kind: tokenEnum;                  {kind of token}
      numString: stringPtr;             {chars in number (macros only)}
      case class: tokenClass of         {token info}
         reservedWord  : ();
         reservedSymbol: ();
         identifier    : (name: stringPtr;
                          symbolPtr: identPtr);
         intConstant   : (ival: integer);
         longConstant  : (lval: longint);
         doubleConstant: (rval: double);
         stringConstant: (sval: longstringPtr;
                          ispstring: boolean);
         macroParameter: (pnum: integer);
     end;
 
                                        {expressions}
                                        {-----------}
  expressionKind = (                    {kinds of expressions}
     preprocessorExpression,            {used by preprocessor commands}
     arrayExpression,                   {array subscripts, case labels,
                                         bit-field lengths, enum values}
     initializerExpression,             {static variable initializers}
     autoInitializerExpression,         {auto variable initializers}
     normalExpression);                 {for run-time evaluation}
  typePtr = ^typeRecord;
  tokenPtr = ^tokenRecord;
  tokenRecord = record                  {for operation, operand stacks}
     next: tokenPtr;                    {next token on the stack}
     left,middle,right: tokenPtr;       {operand paths for operations}
     token: tokenType;                  {token at this node/leaf}
     case boolean of
        true : (id: identPtr;);         {^symbol table entry for this operand}
        false: (castType: typePtr;);    {cast type (for type casts only)}
     end;

                                        {goto label list}
                                        {---------------}
   gotoPtr = ^gotoRecord;
   gotoRecord = record
      {Note: if the size changes, see gotoSize}
      next: gotoPtr;
      name: stringPtr;
      lab: integer;
      defined: boolean;
      end;

                                        {symbol tables}
                                        {-------------}
                                        {classes of variables in the sym. tbl}
  spaceType = (tagSpace,variableSpace,allSpaces,fieldListSpace);

  parameterPtr = ^parameterRecord;      {prototype parameter list}
  parameterRecord = record
     next: parameterPtr;
     parameter: identPtr;
     parameterType: typePtr;
     end;

  typeKind = (scalarType,arrayType,pointerType,functionType,enumType,
              enumConst,structType,unionType,definedType);
  typeRecord = record                   {type}
     size: longint;                     {size of the type in bytes}
     isConstant: boolean;               {is the type a constant?}
     saveDisp: longint;			{disp in symbol file}
     case kind: typeKind of             {NOTE: aType,pType and fType must overlap}
        scalarType  : (baseType: baseTypeEnum;);
        arrayType   : (aType: typePtr;
                       elements: longint;
                      );
        pointerType : (pType: typePtr;);
        functionType: (fType: typePtr;          {return type}
                       varargs,                 {are there a variable # of args?}
                       prototyped: boolean;     {is it prototyped?}
                       overrideKR: boolean;     {K&R overrides to prototypes?}
                       parameterList: parameterPtr; {prototyped parameter list}
                       isPascal: boolean;       {pascal parameters?}
                       toolNum: integer;        {non-zero for tool functions}
                       dispatcher: longint;     {dispatch addr}
                      );
        enumConst   : (eval: integer;);
        enumType    : ();
        definedType : (dType: typePtr;);
        structType,
        unionType   : (fieldList: identPtr;	{field list}
		       sName: stringPtr;	{struct name; for forward refs}
                      );
     end;

   initializerPtr = ^initializerRecord; {initializers}
   initializerRecord = record
      next: initializerPtr;             {next record in the chain}
      count: integer;                   {# of duplicate records}
      bitdisp: integer;                 {disp in byte (field lists only)}
      bitsize: integer;                 {width in bits; 0 for byte sizes}
      isStruct: boolean;                {is this a struct initializer?}
      case isConstant: boolean of       {is this a constant initializer?}
         false: (iTree: tokenPtr);
         true : (
            case itype: baseTypeEnum of
               cgByte,
               cgUByte,
               cgWord,
               cgUWord,
               cgLong,
               cgULong   : (iVal: longint);
               cgString  : (sVal: longstringPtr);
               cgReal,
               cgDouble,
               cgComp,
               cgExtended: (rVal: double);
               cgVoid,
               ccPointer: (
                  pVal: longint;
                  pPlus: boolean;
                  case isName: boolean of
                     true : (pName: stringPtr);
                     false: (pStr : longstringPtr);
                  );
               );
     end;

  storageType = (stackFrame,parameter,external,global,none,private);
  stateKind = (declared,defined,initialized);
  identRecord = record                  {identifier}
     next: identPtr;                    {next symbol in this hash bucket}
     saved: boolean;			{has the symbol been saved (hashed) in the symbol file?}
     name: stringPtr;                   {symbol name}
     itype: typePtr;                    {symbol type}
     disp: longint;                     {disp past start of struct (field lists only)}
     bitDisp: integer;                  {disp in byte (field lists only)}
                                        {parameter number (K&R parms only)}
     bitsize: integer;                  {width in bits; 0 for byte sizes}
     state: stateKind;                  {state of the definition}
     iPtr: initializerPtr;              {pointer to the first initializer}
     isForwardDeclared: boolean;        {does this var use a forward declared type?}
     class: tokenEnum;                  {storage class}
     case storage: storageType of
        stackFrame: (lln: integer);     {local label #}
        parameter: (pln: integer;       {paramater label #}
                    pdisp: integer;     {disp of parameter}
                    pnext: identPtr);   {next parameter}
        external: ();
        global,private: ();
        none: ();
     end;

                                        {mini-assembler}
                                        {--------------}
                                        {opcodes}
   opcode = (o_adc,o_and,o_asl,o_bit,o_cmp,o_cop,o_cpx,o_cpy,o_dec,o_eor,
             o_inc,o_jml,o_jmp,o_jsl,o_jsr,o_lda,o_ldx,o_ldy,o_lsr,o_ora,
             o_pea,o_pei,o_rep,o_rol,o_ror,o_sbc,o_sep,o_sta,o_stx,o_sty,
             o_stz,o_trb,o_tsb,

             o_dcb,o_dcw,o_dcl,

             o_brk,

             o_mvn,o_mvp,

             o_bcc,o_bcs,o_beq,o_bmi,o_bne,o_bpl,o_bra,o_brl,o_per,o_bvc,
             o_bvs,

             o_clc,o_cld,o_cli,o_clv,o_dex,o_dey,o_inx,o_iny,o_nop,o_pha,
             o_phb,o_phd,o_phk,o_php,o_phx,o_phy,o_pla,o_plb,o_pld,o_plp,
             o_plx,o_ply,o_rti,o_rtl,o_rts,o_sec,o_sed,o_sei,o_stp,o_tax,
             o_tay,o_tcd,o_tcs,o_tdc,o_tsc,o_tsx,o_txa,o_txs,o_txy,o_tya,
             o_tyx,o_wai,o_xba,o_xce);

                                        {addressing modes}
   operands = (acc,imm,dp,dp_x,dp_y,op,op_x,op_y,i_dp_x,i_dp_y,dp_s,li_dp,la,
               i_dp,i_op,i_la,i_op_x,i_dp_s_y,li_dp_y,long_x);

                                        {work variables}
                                        {--------------}
   tempPtr = ^tempRecord;
   tempRecord = record
      last,next: tempPtr;               {doubly linked list}
      labelNum: integer;                {label number}
      size: integer;                    {size of the variable}
      end;

                                        {ORCA Shell and ProDOS}
                                        {---------------------}
   timeField = array[1..8] of byte;

   optionListRecord = record
      totalSize: integer;
      requiredSize: integer;
      fileSysID: integer;
      theData: packed array [1..100] of char;
      end;
   optionListPtr = ^optionListRecord;
                          
   fastFileDCBGS = record 
      pcount: integer;
      action: integer;
      index: integer;
      flags: integer;
      fileHandle: handle;
      pathName: gsosInStringPtr;
      access: integer;
      fileType: integer;
      auxType: longint;
      storageType: integer;
      createDate: timeField;
      modDate: timeField;
      option: optionListPtr;
      fileLength: longint;
      blocksUsed: longint;
      end;

   getLInfoDCBGS = record
      pcount: integer;
      sFile: gsosOutStringPtr;
      dFile: gsosOutStringPtr;
      namesList: gsosOutStringPtr;
      iString: gsosOutStringPtr;
      merr: byte;
      merrf: byte;
      lops: byte;
      kFlag: byte;
      mFlags: longint;
      pFlags: longint;
      org: longint;
      end;
   
   getPrefixOSDCB = record
      pcount: integer;
      prefixNum: integer;
      prefix: gsosOutStringPtr;
      end;
   
   versionDCBGS = record
      pcount: integer;
      version: packed array[1..4] of char;
      end;

{---------------------------------------------------------------}

var
                                        {misc}
                                        {----}
   bofPtr: ptr;                         {pointer to the start of sourceFile}
   chPtr: ptr;                          {pointer to the next character in the file}
                                        {debugType is also in SCANNER.ASM}
   debugType: (stop,break,autogo);      {line number debug types}
   doingParameters: boolean;            {are we processing parm definitions?}
   expandMacros: boolean;               {should macros be expanded?}
   ffDCBGS: fastFileDCBGS;		{fast file DCB}
   firstPtr: ptr;                       {points to first char in current line}
   gotoList: gotoPtr;                   {list of goto labels}
   includeFileGS: gsosOutString;	{include file name (for return from includes)}
   infoStringGS: gsosOutString;         {language specific command line info}
   intLabel: integer;                   {last used label number}
   languageNumber: integer;             {our language number}
   lastLine: 0..maxint;                 {last line number used by pc_nam}
   liDCBGS: getLInfoDCBGS;		{get/set LInfo DCB}
   lineNumber: 0..maxint;               {source line number}
   nameFound: boolean;                  {has a pc_nam been generated?}
   nextLocalLabel: integer;             {next available local data label number}
   numErrors: integer;                  {number of errors in the program}
   objFile: gsosOutString;              {object file name}
   oldincludeFileGS: gsosOutString;	{previous includeFile value}
   outFileGS: gsosOutString;		{keep file name}
   partialFileGS: gsosOutString;        {partial compile list}
   sourceFileGS: gsosOutString;		{debug source file name}
   tempList: tempPtr;                   {list of temp work variables}

                                        {expression results}
                                        {------------------}
   doDispose: boolean;                  {dispose of the expression tree as we go?}
   realExpressionValue: double;         {value of the last real constant expression}
   expressionValue: longint;            {value of the last constant expression}
   expressionType: typePtr;             {the type of the expression}
   initializerTree: tokenPtr;           {for non-constant initializers}
   isConstant: boolean;                 {is the initializer expression conastant?}

                                        {type specifier results}
                                        {----------------------}
   typeSpec: typePtr;                   {type specifier}

                                        {flags}
                                        {-----}
   codegenStarted: boolean;             {have we started the code generator?}
   doingFunction: boolean;              {are we processing a function?}
   doingPartial: boolean;               {are we doing a partial compile?}
   enterEditor: boolean;                {enter editor on terminal errors?}
   foundFunction: boolean;              {has a function been found?}
   lint: integer;                       {lint flags}
   list: boolean;                       {generate source listing?}
   ignoreSymbols: boolean;		{ignore .sym file?}
   memoryCompile: boolean;              {memory based compile?}
   printSymbols: boolean;               {+s flag set?}
   progress: boolean;                   {write progress info?}
   rebuildSymbols: boolean;		{rebuild .sym file?}
   switchLanguages: boolean;            {switch languages on exit?}
   terminalErrors: boolean;             {are all errors terminal?}
   traceBack: boolean;                  {generate traceback code?}
   unix_1: boolean;			{is int 32 bits? (or 16 bits)}
   useGlobalPool: boolean;              {use global (or local) string pool?}
   wait: boolean;                       {wait for keypress after errors?}

{---------------------------------------------------------------}

                                        {ORCA Shell and ProDOS}
                                        {---------------------}

procedure GetLInfoGS (var parms: getLInfoDCBGS); prodos ($0141);
 
procedure FastFileGS (var parms: fastFileDCBGS); prodos ($014E);
 
procedure SetLInfoGS (var parms: getLInfoDCBGS); prodos ($0142);
 
procedure GetPrefixGS (var parms: getPrefixOSDCB); prodos ($200A);
 
procedure VersionGS (var parms: versionDCBGS); prodos ($0147);

{---------------------------------------------------------------}

procedure CheckGotoList;

{ Make sure all labels have been defined                        }


procedure ClearHourGlass;

{ Erase the hourglass from the screen				}


procedure CopyLongString (toPtr, fromPtr: longStringptr);

{  copy a long string                                           }
{                                                               }
{  parameters:                                                  }
{       toPtr - location to copy to                             }
{       fromPtr - location to copy from                         }


procedure CopyString (toPtr, fromPtr: ptr); extern;

{  copy a string                                                }
{                                                               }
{  parameters:                                                  }
{       toPtr - location to copy to                             }
{       fromPtr - location to copy from                         }


procedure DrawHourGlass;

{ Draw the hourglass on the screen				}


procedure ExitToEditor (msg: stringPtr; disp: longint);

{  do an error exit to the editor                               }
{                                                               }
{  parameters:                                                  }
{       msg - pointer to the error message                      }
{       disp - displacement into the error file                 }
{                                                               }
{  variables:                                                   }
{       includeFile - source file name                          }


function GenLabel: integer;

{ generate the next local label, checking for too many          }

 
function GetLocalLabel: integer;

{ get the next local label number                               }


function Hash (sPtr: stringPtr): integer; extern;

{  find hash displacement                                       }
{                                                               }
{  Finds the displacement into an array of pointers using a     }
{  hash function.                                               }
{                                                               }
{  parameters:                                                  }
{       sPtr - points to string to find hash for                }


procedure InitCCommon;

{ Initialize this module					}


procedure ReadFile;

{  read a file                                                  }
{                                                               }
{  variables:                                                   }
{       bofPtr - pointer to the start of the file               }
{       ffDCB.file_length - length of the file                  }
{       includeFile - source file name                          }


procedure Spin;

{ Spin the spinner						}
{								}
{ Notes: Starts the spinner if it is not already in use		}


procedure StopSpin;

{ Stop the spinner						}
{								}
{ Notes: The call is safe, and ignored, if the spinner is	}


procedure SystemError (errNo: integer);

{ intercept run time compiler errors                            }


procedure TermError (errnum: integer);

{ flag a terminal error                                         }

{---------------------------------------------------------------}

implementation

const
                                        {Note: maxLabel is also defined in cgi.pas}
   maxLabel = 2400;			{max # compiler generated labels}

					{spinner}
                                        {-------}
   spinSpeed = 8;			{calls before one spinner move}

type
   consoleOutDCBGS = record
      pcount: integer;
      ch: char; 
      end;

var                                              
					{spinner}
                                        {-------}
   
   spinning: boolean;			{are we spinning now?}
   spinDisp: integer;			{disp to the spinner character}
   spinCount: integer;			{spin loop counter}

   spinner: array[0..3] of char;	{spinner characters}
   

procedure Error (err: integer); extern; {in scanner.pas}

{ flag an error                                                 }
{                                                               }
{ err - error number                                            }


{procedure Error2 (loc, err: integer); extern; {debug} {in scanner.pas}

{ flag an error                                                 }
{                                                               }
{ loc - error location                                          }
{ err - error number                                            }


procedure MMQuit; extern; {in mm.pas}

{ Dispose of memory allocated with private user IDs             }


procedure ConsoleOutGS (var parms: consoleOutDCBGS); prodos ($015A);

{---------------------------------------------------------------}

procedure CheckGotoList;

{ Make sure all labels have been defined                        }

var
   gt: gotoPtr;                         {work pointer}
   msg: stringPtr;                      {work string}

begin {CheckGotoList}
gt := gotoList;
while gt <> nil do begin
   if not gt^.defined then begin
      numErrors := numErrors+1;
      new(msg);
      msg^ := concat('Undefined label: ', gt^.name^);
      writeln(msg^);
      if terminalErrors then begin
         if enterEditor then
            ExitToEditor(msg, ord4(firstPtr)-ord4(bofPtr))
         else
            TermError(0);
         end; {if}
      dispose(msg);
      end; {if}
   gt := gt^.next;
   end; {while}
end; {CheckGotoList}


procedure ClearHourGlass;

{ Erase the hourglass from the screen				}

var
   coRec: consoleOutDCBGS;		{Console out record}

begin {ClearHourGlass}           
coRec.pcount := 1;
coRec.ch := ' ';	ConsoleOutGS(coRec);
coRec.ch := chr(8);	ConsoleOutGS(coRec);
end; {ClearHourGlass}


procedure CopyLongString {toPtr, fromPtr: longStringPtr};

{  copy a long string                                           }
{                                                               }
{  parameters:                                                  }
{       toPtr - location to copy to                             }
{       fromPtr - location to copy from                         }

var
   i: integer;                          {loop variable}

begin {CopyLongString}
toPtr^.length := fromPtr^.length;       {set the length}
for i := 1 to fromPtr^.length do
   toPtr^.str[i] := fromPtr^.str[i];
end; {CopyLongString}


procedure DrawHourGlass;

{ Draw the hourglass on the screen				}

var
   coRec: consoleOutDCBGS;		{Console out record}

begin {DrawHourGlass}           
coRec.pcount := 1;
coRec.ch := chr(27);	ConsoleOutGS(coRec);
coRec.ch := chr(15);	ConsoleOutGS(coRec);
coRec.ch := 'C';	ConsoleOutGS(coRec);
coRec.ch := chr(24);	ConsoleOutGS(coRec);
coRec.ch := chr(14);	ConsoleOutGS(coRec);
coRec.ch := chr(8);	ConsoleOutGS(coRec);
end; {DrawHourGlass}


procedure ExitToEditor {msg: stringPtr; disp: longint};

{  do an error exit to the editor                               }
{                                                               }
{  parameters:                                                  }
{       msg - pointer to the error message                      }
{       disp - displacement into the error file                 }
{                                                               }
{  variables:                                                   }
{       includeFile - source file name                          }

var
   msgGS: gsosInString;			{message}

begin {ExitToEditor}
msgGS.size := length(msg^);		{set up the error message}
msgGS.theString := msg^;
liDCBGS.org := disp;			{mark the error}
liDCBGS.namesList := @msgGS;
liDCBGS.lops := 0;			{prevent re-entry}
liDCBGS.merrf := 255;
with liDCBGS do begin
   sFile := pointer(ord4(sFile)+2);
   dFile := pointer(ord4(dFile)+2);
   iString := pointer(ord4(iString)+2);
   end; {with}
SetLInfoGS(liDCBGS);
StopSpin;				{stop the spinner}
MMQuit;                                 {dispose of the memory pools}
halt(-1);                               {return to the shell}
end; {ExitToEditor}


function GenLabel{: integer};

{ generate the next local label, checking for too many          }

begin {GenLabel}
if intLabel < maxLabel then
   intLabel := intLabel+1
else begin
   intLabel := 0;
   Error(58);
   end;
GenLabel := intLabel;
end; {GenLabel}

 
function GetLocalLabel{: integer};

{ get the next local label number                               }

begin {GetLocalLabel}
GetLocalLabel := nextLocalLabel;
nextLocalLabel := nextLocalLabel+1;
end; {GetLocalLabel}


procedure InitCCommon;

{ Initialize this module					}

begin {InitCCommon}
spinning := false;			{not spinning the spinner}
spinDisp := 0;				{start spinning with the first character}
spinner[0] := '|';			{set up the spinner characters}
spinner[1] := '/';
spinner[2] := '-';
spinner[3] := '\';
end; {InitCCommon}


procedure ReadFile;

{  read a file                                                  }
{                                                               }
{  variables:                                                   }
{       bofPtr - pointer to the start of the file               }
{       ffDCB.file_length - length of the file                  }
{       includeFile - source file name                          }

const
   SRC   = $B0;                         {source file type}

begin {ReadFile}
with ffDCBGS do begin			{read the source file}
   pCount := 14;
   action := 0;
   flags := $C000;
   pathName := @includeFileGS.theString;
   end; {with}
FastFileGS(ffDCBGS);
if ToolError <> 0 then begin
   sourceFileGS := includeFileGS;
   includeFileGS := oldincludeFileGS;
   TermError(1);
   end; {if}
if ffDCBGS.fileType <> SRC then begin
   includeFileGS := oldincludeFileGS;
   TermError(6);
   end; {if}
bofPtr := ffDCBGS.fileHandle^;		{set beginning of file pointer}
end; {ReadFile}


procedure Spin;

{ Spin the spinner						}
{								}
{ Notes: Starts the spinner if it is not already in use		}

var
   coRec: consoleOutDCBGS;		{Console out record}

begin {Spin}
if not spinning then begin
   spinning := true;
   spinCount := spinSpeed;
   end; {if}
spinCount := spinCount - 1;
if spinCount = 0 then begin
   spinCount := spinSpeed;
   spinDisp := spinDisp - 1;
   if spinDisp < 0 then
      spinDisp := 3;
   coRec.pcount := 1;
   coRec.ch := spinner[spinDisp];
   ConsoleOutGS(coRec);
   coRec.ch := chr(8);
   ConsoleOutGS(coRec);
   end; {if}
end; {Spin}


procedure StopSpin;

{ Stop the spinner						}
{								}
{ Notes: The call is safe, and ignored, if the spinner is	}
{	inactive.						}

var
   coRec: consoleOutDCBGS;		{Console out record}

begin {StopSpin}
if spinning then begin
   spinning := false;
   coRec.pcount := 1;
   coRec.ch := ' ';
   ConsoleOutGS(coRec);
   coRec.ch := chr(8);
   ConsoleOutGS(coRec);
   end; {if}
end; {StopSpin}


procedure SystemError {errNo: integer};

{ intercept run time compiler errors                            }

begin {SystemError}
if errNo = 5 then
   TermError(5)
else
   TermError(3);
end; {SystemError}


procedure TermError {errnum: integer};

{ flag a terminal error                                         }

var
   msg: pString;                        {terminal error message}

begin {TermError}
case errnum of                          {print the error}
   0 : ;
   1 : msg := concat('Error reading ', sourceFileGS.theString.theString);
   2 : msg := concat('Error purging ', sourceFileGS.theString.theString);
   3 : msg := 'terminal compiler error';
   4 : msg := 'user termination';
   5 : msg := 'out of memory';
   6 : msg := 'source files must have a file type of SRC';
   7 : msg := 'you cannot change languages with an include directive';
   8 : msg := 'you cannot change languages from an included file';
   9 : msg := concat('Error writing ', objFile.theString.theString);
   10: msg := 'ORCA/C requires version 2.0 or later of the shell';
   11: msg := 'The program is too large to compile to memory -- use Compile to Disk';
   otherwise: Error(57);
   end; {case}
with ffDCBGS do begin			{purge the source file}
   pCount := 5;
   action := 7;
   pathName := @includeFileGS.theString;
   end; {with}
FastFileGS(ffDCBGS);
writeln('Terminal error: ', msg);       {write the error to stdout}
if enterEditor then                     {error exit to editor}
   ExitToEditor(@msg, ord4(chPtr) - ord4(bofPtr))
else begin
   liDCBGS.lops := 0;			{prevent re-entry}
   liDCBGS.merrf := 127;
   with liDCBGS do begin
      sFile := pointer(ord4(sFile)+2);
      dFile := pointer(ord4(dFile)+2);
      namesList := pointer(ord4(namesList)+2);
      iString := pointer(ord4(iString)+2);
      end; {with}
   SetLInfoGS(liDCBGS);
   StopSpin;				{stop the spinner}
   MMQuit;                              {dispose of the memory pools}
   halt(-1);                            {return to the shell}
   end; {else}
end; {TermError}

end.

{$append 'ccommon.asm'}
