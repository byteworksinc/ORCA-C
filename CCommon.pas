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
{  isConstant - is the initializer expression constant?         }
{  typeSpec - type given by the last declaration specifiers,    }
{          specifier-qualifier list, or type name evaluated     }
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
{                                                               }
{---------------------------------------------------------------}

unit CCommon;

interface

{$segment 'CC'}

const
                                        {hashsize appears in CCOMMON.ASM}
   hashSize      = 876;                 {# hash buckets - 1}
                                        {NOTE: hashsize2 is used in Symbol.asm}
   hashSize2     = 1753;                {# hash buckets * 2 - 1}
   maxLine       = 255;                 {max length of a line}
   maxPath	 = 255;			{max length of a path name}
					{NOTE: maxPath is used in Scanner.asm}
   longstringlen = 32760;               {max length of a string constant}
 
   minChar      = 0;                    {min ordinal value of source character}
   maxChar      = 255;                  {max ordinal value of source character}

                                        {lint masks}
                                        {----------}
   lintUndefFn          = $0001;        {flag use of undefined functions}
   lintNoFnType         = $0002;        {flag functions with no type}
   lintNotPrototyped    = $0004;        {flag functions with no prototypes}
   lintPragmas          = $0008;        {flag unknown pragmas}
   lintPrintf           = $0010;        {check printf/scanf format flags}
   lintOverflow         = $0020;        {check for overflows}
   lintC99Syntax        = $0040;        {check for syntax that C99 disallows}
   lintReturn           = $0080;        {flag issues with how functions return}
   lintUnused           = $0100;        {check for unused variables}
   lintConstantRange    = $0200;        {check for out-of-range constants}

                                        {bit masks for GetLInfo flags}
                                        {----------------------------}
   flag_d       = $10000000;            {generate debug code?}
   flag_e       = $08000000;            {abort to editor on terminal error?}
   flag_f       = $04000000;            {print filenames in error messages?}
   flag_i       = $00800000;            {ignore symbol files?}
   flag_l       = $00100000;            {list source lines?}
   flag_m       = $00080000;            {memory based compile?}
   flag_o       = $00020000;            {optimize?}
   flag_p       = $00010000;            {print progress info?}
   flag_r       = $00004000;            {rebuild symbol files?}
   flag_s       = $00002000;            {list symbol tables?}
   flag_t       = $00001000;            {treat all errors as terminal?}
   flag_w       = $00000200;            {wait when an error is found?}

   versionStr = '2.3.0 dev';		{compiler version}

type
                                        {Misc.}
                                        {-----}
   long = record lsw,msw: integer; end; {for extracting words from longints}
   longlong = record lo,hi: longint; end; {64-bit integer representation}
 
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
   handle     = ^ptr;                   {general purpose handle}
 
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
   
   { C language standards }
   { Note: this enumeration also appears in Scanner.asm. }
   cStandardEnum = (c89,c95,c99,c11,c17,c23);
   
   { The base types include two main categories.  The values starting    }
   { with cg are defined in the code generator, and may be passed to the }
   { code generator for resolution.  The cc types are used internally in }
   { the compiler.  Any values whose type is cc must be resolved to one  }
   { of the cg types before the code generator is called.                }
 
   baseTypeEnum = (cgByte,cgUByte,cgWord,cgUWord,cgLong,cgULong,
                   cgReal,cgDouble,cgComp,cgExtended,cgString,
                   cgVoid,cgQuad,cgUQuad,ccPointer);

   { Basic types (plus the void type) as defined by the C language.      }
   { This differs from baseTypeEnum in that different types with the     }
   { same representation are distinguished from each other.              }
   { (ctInt32/ctUInt32 are 32-bit int types when using #pragma unix 1.)  }

   cTypeEnum = (ctChar, ctSChar, ctUChar, ctShort, ctUShort, ctInt, ctUInt,
                ctLong, ctULong, ctFloat, ctDouble, ctLongDouble, ctComp,
                ctVoid, ctInt32, ctUInt32, ctBool, ctLongLong, ctULongLong);

                                        {tokens}
                                        {------}
                                        {Note: tokenEnum is duplicated in }
                                        { Table.asm                       }
   tokenEnum = (                        {enumeration of the tokens}
               ident,                   {identifiers}
                                        {constants}
                                        {Note: compconst tokens are       }
                                        { not found in program code.      }
                                        { They are created only by casts. }
               intconst,uintconst,longconst,ulongconst,longlongconst,
               ulonglongconst,floatconst,doubleconst,extendedconst,compconst,
               stringconst,
                                        {reserved words}
               _Alignassy,_Alignofsy,_Atomicsy,_BitIntsy,_Boolsy,
               _Complexsy,_Decimal128sy,_Decimal32sy,_Decimal64sy,_Genericsy,
               _Imaginarysy,_Noreturnsy,_Static_assertsy,_Thread_localsy,alignassy,
               alignofsy,autosy,asmsy,boolsy,breaksy,
               casesy,charsy,continuesy,constsy,constexprsy,
               compsy,defaultsy,dosy,doublesy,elsesy,
               enumsy,externsy,extendedsy,falsesy,floatsy,
               forsy,gotosy,ifsy,intsy,inlinesy,
               longsy,nullptrsy,pascalsy,registersy,restrictsy,
               returnsy,shortsy,sizeofsy,staticsy,static_assertsy,
               structsy,switchsy,segmentsy,signedsy,thread_localsy,
               truesy,typedefsy,typeofsy,typeof_unqualsy,unionsy,
               unsignedsy,voidsy,volatilesy,whilesy,
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
               bareqop,poundpoundop,dotdotdotsy,coloncolonsy,
               ppnumber,                {preprocessing number (pp-token)}
               otherch,                 {other non-whitespace char (pp-token)}
               eolsy,eofsy,             {control characters}
               typedef,                 {user types}
                                        {converted operations}
               uminus,uplus,uand,uasterisk,
               parameteroper,castoper,opplusplus,opminusminus,compoundliteral,
               macroParm);              {macro language}

                                        {Note: this enumeration also    }
                                        { appears in TABLE.ASM,         }
                                        { SCANNER.asm                   }
   charEnum =                           {character kinds}
      (illegal,ch_special,ch_dash,ch_plus,ch_lt,ch_gt,ch_eq,ch_exc,
       ch_and,ch_bar,ch_dot,ch_white,ch_eol,ch_eof,ch_char,ch_string,
       ch_asterisk,ch_slash,ch_percent,ch_carot,ch_pound,ch_colon,
       ch_backslash,ch_other,letter,digit);

                                        {prefixes of a character/string literal}
   charStrPrefixEnum = (prefix_none,prefix_L,prefix_u16,prefix_U32,prefix_u8);

   tokenSet = set of tokenEnum;
   tokenClass = (reservedWord,reservedSymbol,identifier,intConstant,longConstant,
                 longlongConstant,realConstant,stringConstant,otherCharacter,
                 preprocessingNumber,macroParameter);
   identPtr = ^identRecord;             {^ to a symbol table entry}
   typePtr = ^typeRecord;
   tokenType = record                   {a token}
      kind: tokenEnum;                  {kind of token}
      numString: stringPtr;             {chars in number (macros only)}
      case class: tokenClass of         {token info}
         reservedWord  : ();
         reservedSymbol: (isDigraph: boolean);
         identifier    : (name: stringPtr;
                          symbolPtr: identPtr);
         intConstant   : (ival: integer;
                          itype: typePtr);
         longConstant  : (lval: longint);
         longlongConstant: (qval: longlong);
         realConstant  : (rval: extended);
         stringConstant: (sval: longstringPtr;
                          ispstring: boolean;
                          prefix: charStrPrefixEnum);
         otherCharacter: (ch: char);    {used for preprocessing tokens only}
         preprocessingNumber: (errCode: integer);  {used for pp tokens only}
         macroParameter: (pnum: integer);
     end;
 
                                        {expressions}
                                        {-----------}
  expressionKind = (                    {kinds of expressions}
     preprocessorExpression,            {used by preprocessor commands}
     integerConstantExpression,         {array subscripts, case labels,
                                         bit-field lengths, enum values}
     initializerExpression,             {static variable initializers}
     autoInitializerExpression,         {auto variable initializers}
     normalExpression);                 {for run-time evaluation}
  tokenPtr = ^tokenRecord;
  tokenRecord = record                  {for operation, operand stacks}
     next: tokenPtr;                    {next token on the stack}
     left,middle,right: tokenPtr;       {operand paths for operations}
     token: tokenType;                  {token at this node/leaf}
     case boolean of
        true : (id: identPtr;);         {^symbol table entry for this operand}
        false: (castType: typePtr;      {cast type (for casts or VLA sizeof)}
                vlaCode: ptr;);         {code for VLA type in cast/sizeof/etc.}
     end;

                                        {goto label list}
                                        {---------------}
   gotoPtr = ^gotoRecord;
   gotoRecord = record
      next: gotoPtr;
      name: stringPtr;
      lab: integer;
      defined: boolean;
      lastVMSym: identPtr;              {last variably modified sym before label}
                                        {(if defined) or first goto (if not)    }
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

  typeQualifierEnum = (tqConst, tqVolatile, tqRestrict);
  typeQualifierSet = set of typeQualifierEnum;

  typeKind = (scalarType,arrayType,pointerType,functionType,enumType,
              enumConst,structType,unionType,definedType);
  typeRecord = record                   {type}
     size: longint;                     {size of the type in bytes (1 for VLA)}
     qualifiers: typeQualifierSet;      {type qualifiers}
     saveDisp: longint;			{disp in symbol file}
     case kind: typeKind of             {NOTE: aType,pType and fType must overlap}
        scalarType  : (baseType: baseTypeEnum;  {our internal type representation}
                       cType: cTypeEnum);       {type in the C type system}
        arrayType   : (aType: typePtr;
                       elements: longint;       {number of elements; 0 if unknown}
                       isVariableLength: boolean;
                       sizeLLN: integer;        {LLN of VLA size var; 0 for [*]}
                       sizeTree: tokenPtr;      {used during VLA type construction}
                       aQualifiers: typeQualifierSet; {qualifiers within []}
                      );
        pointerType : (pType: typePtr;
                       wasStarVLA: boolean;);   {adjusted from VLA type with [*]?}
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
		       constMember: boolean;    {does it have a const member?}
		       flexibleArrayMember: boolean; {does it have a FAM?}
                      );
     end;

   initializerPtr = ^initializerRecord; {initializers}
   initializerRecord = record
      next: initializerPtr;             {next record in the chain}
      disp: longint;                    {disp within overall object being initialized}
      count: integer;                   {# of duplicate records (>1 for bytes only)}
      bitdisp: integer;                 {disp in byte (field lists only)}
      bitsize: integer;                 {width in bits; 0 for byte sizes}
      case isConstant: boolean of       {is this a constant initializer?}
         false: (
            iType: typePtr;             {type being initialized}
            iTree: tokenPtr;            {initializer expression}
            );
         true : (                       {Note: qVal.lo must overlap iVal}
            case basetype: baseTypeEnum of
               cgByte,
               cgUByte,
               cgWord,
               cgUWord,
               cgLong,
               cgULong   : (iVal: longint);
               cgQuad,
               cgUQuad   : (qVal: longlong);
               cgString  : (sVal: longstringPtr);
               cgReal,
               cgDouble,
               cgComp,
               cgExtended: (rVal: extended);
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
     used: boolean;                     {is this identifier used?}
     underspecified: boolean;           {not yet fully specified (need initializer)?}
     nextVMSym: identPtr;               {previous symbol of variably modified type}
     case storage: storageType of
        stackFrame: (lln: integer;      {local label #}
                     clnext: identPtr); {next compound literal}
        parameter:  (pln: integer;      {paramater label #}
                     pdisp: integer;    {disp of parameter}
                     pnext: identPtr);  {next parameter}
        external:   (inlineDefinition: boolean); {(potential) inline definition of function?}
        global,private: ();
        none: (
           case anonMemberField: boolean of {field from an anonymous struct/union member?}
              true : (anonMember: identPtr); {containing anonymous struct/union}
              false: ();
        );
     end;

                                        {mini-assembler}
                                        {--------------}
                                        {opcodes}
   opcode = (o_adc,o_and,o_asl,o_bit,o_cmp,o_cop,o_cpx,o_cpy,o_dec,o_eor,
             o_inc,o_jml,o_jmp,o_jsl,o_jsr,o_lda,o_ldx,o_ldy,o_lsr,o_ora,
             o_pea,o_pei,o_rep,o_rol,o_ror,o_sbc,o_sep,o_sta,o_stx,o_sty,
             o_stz,o_trb,o_tsb,

             o_dcb,o_dcw,o_dcl,

             o_brk,o_wdm,

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
   changedSourceFile: boolean;          {source file changed in function?}
   cStd: cStandardEnum;                 {selected C standard}
   debugSourceFileGS: gsosOutString;    {debug source file name}
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
   lastLine: 0..maxint4;                {last line number used by pc_nam}
   liDCBGS: getLInfoDCBGS;		{get/set LInfo DCB}
   lineNumber: 0..maxint4;              {source line number}
   nameFound: boolean;                  {has a pc_nam been generated?}
   nextLocalLabel: integer;             {next available local data label number}
   numErrors: integer;                  {number of errors in the program}
   objFile: gsosOutString;              {object file name}
   oldincludeFileGS: gsosOutString;	{previous includeFile value}
   outFileGS: gsosOutString;		{keep file name}
   partialFileGS: gsosOutString;        {partial compile list}
   pragmaKeepFile: gsosOutStringPtr;    {filename specified in #pragma keep}
   sourceFileGS: gsosOutString;         {presumed source file name}
   strictMode: boolean;                 {strictly follow standard, without extensions?}
   tempList: tempPtr;                   {list of temp work variables}
   vlaTrees: 0..maxint4;                {number of trees for computing VLA sizes}
   longlong0: longlong;                 {the value 0 as a longlong}
   longlong1: longlong;                 {the value 1 as a longlong}

                                        {expression results}
                                        {------------------}
   doDispose: boolean;                  {dispose of the expression tree as we go?}
   realExpressionValue: extended;       {value of the last real constant expression}
   llExpressionValue: longlong;         {value of the last long long constant expression}
   expressionValue: longint;            {value of the last constant expression}
   expressionType: typePtr;             {the type of the expression}
   initializerTree: tokenPtr;           {for non-constant initializers}
   isConstant: boolean;                 {is the initializer expression constant?}
   expressionIsLongLong: boolean;       {is the last constant expression long long?}

                                        {flags}
                                        {-----}
   codegenStarted: boolean;             {have we started the code generator?}
   doingFunction: boolean;              {are we processing a function?}
   doingPartial: boolean;               {are we doing a partial compile?}
   enterEditor: boolean;                {enter editor on terminal errors?}
   filenamesInErrors: boolean;          {print filenames in error messages?}
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
   lintIsError: boolean;                {treat lint messages as errors?}
   fIsNoreturn: boolean;                {is the current function _Noreturn?}
   doingMain: boolean;                  {are we processing the main function?}
   fenvAccess: boolean;                 {is the FENV_ACCESS pragma on?}
   fenvAccessInFunction: boolean;       {was FENV_ACCESS on anywhere in current function?}

                                        {syntactic classes of tokens}
                                        {---------------------------}
   specifierQualifierListElement: tokenSet;
   topLevelDeclarationStart: tokenSet;

                                        {base types}
                                        {----------}
   charPtr,sCharPtr,uCharPtr,shortPtr,uShortPtr,intPtr,uIntPtr,int32Ptr,
      uInt32Ptr,longPtr,uLongPtr,longLongPtr,uLongLongPtr,boolPtr,
      floatPtr,doublePtr,compPtr,extendedPtr,stringTypePtr,utf8StringTypePtr,
      utf16StringTypePtr,utf32StringTypePtr,voidPtr,voidPtrPtr,charPtrPtr,
      vaInfoPtr,constCharPtr,defaultStruct: typePtr;

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
                                        {Note: maxlabel is also defined in CGC.asm}
   maxLabel = 3275;			{max # compiler generated labels}

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
if disp < 0 then                        {sanity check disp}
   disp := 0;
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
longlong0.hi := 0;
longlong0.lo := 0;
longlong1.hi := 0;
longlong1.lo := 1;
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
   0 : msg := '' ;
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
  {11: msg := 'The program is too large to compile to memory -- use Compile to Disk';}
   12: msg := 'Invalid sym file detected. Re-run ORCA/C to proceed.';
   13: msg := 'file name or command-line parameter is too long';
   otherwise: begin
      msg := '';
      Error(57);
      end;
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
