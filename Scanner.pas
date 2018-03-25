{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Scanner                                                      }
{                                                               }
{  External Variables:                                          }
{                                                               }
{  ch - next character to process                               }
{  printMacroExpansions - print the token list?                 }
{  reportEOL - report eolsy as a token?                         }
{  token - next token to process                                }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  Error - flag an error                                        }
{  IsDefined - see if a macro name is in the macro table        }
{  InitScanner - initialize the scanner                         }
{  NextCh - Read the next character from the file, skipping     }
{       comments.                                               }
{  NextToken - read the next token from the file                }
{  PutBackToken - place a token into the token stream           }
{  TermScanner - Shut down the scanner.                         }
{                                                               }
{---------------------------------------------------------------}

unit Scanner;

interface

{$LibPrefix '0/obj/'}

uses CCommon, Table, CGI, MM;

{$segment 'SCANNER'}

type
   pragmas =				{kinds of pragmas}
      (p_startofenum,p_cda,p_cdev,p_float,p_keep,
       p_nda,p_debug,p_lint,p_memorymodel,p_expand,
       p_optimize,p_stacksize,p_toolparms,p_databank,p_rtl,
       p_noroot,p_path,p_ignore,p_segment,p_nba,
       p_xcmd,p_unix,p_line,p_endofenum);

                                        {preprocessor types}
                                        {------------------}
   tokenListRecordPtr = ^tokenListRecord;
   tokenListRecord = record             {element of a list of tokens}
      next: tokenListRecordPtr;         {next element in list}
      tokenString: longStringPtr;       {string making up the token}
      token: tokenType;                 {token}
      expandEnabled: boolean;           {can this token be macro expanded?}
      tokenStart,tokenEnd: ptr;         {token start/end markers}
      end;
   macroRecordPtr = ^macroRecord;
   macroRecord = record                 {preprocessor macro definition}
      next: macroRecordPtr;
      saved: boolean;
      name: stringPtr;
      parameters: integer;
      tokens: tokenListRecordPtr;
      readOnly: boolean;
      algorithm: integer;
      end;
   macroTable = array[0..hashSize] of macroRecordPtr; {preprocessor macro list}

					{path name lists}
                                        {---------------}
   pathRecordPtr = ^pathRecord;
   pathRecord = record
      next: pathRecordPtr;
      path: stringPtr;
      end;

var
   ch: char;                            {next character to process}
   macros: ^macroTable;                 {preprocessor macro list}
   pathList: pathRecordPtr;		{additional search paths}
   printMacroExpansions: boolean;       {print the token list?}
   reportEOL: boolean;                  {report eolsy as a token?}
   token: tokenType;                    {next token to process}

                                        {#pragma ignore flags}
                                        {--------------------}
   allowLongIntChar: boolean;           {allow long int char constants?}
   allowSlashSlashComments: boolean;    {allow // comments?}
   allowTokensAfterEndif: boolean;      {allow tokens after #endif?}
   skipIllegalTokens: boolean;          {skip flagging illegal tokens in skipped code?}

{---------------------------------------------------------------}

procedure DoDefaultsDotH;

{ Handle the defaults.h file					}


procedure Error (err: integer);

{ flag an error                                                 }
{                                                               }
{ err - error number                                            }


{procedure Error2 (loc, err: integer); {debug}

{ flag an error                                                 }
{                                                               }
{ loc - error location                                          }
{ err - error number                                            }


procedure InitScanner (start, endPtr: ptr);

{ initialize the scanner                                        }
{                                                               }
{ start - pointer to the first character in the file            }
{ endPtr - points one byte past the last character in the file  }


function IsDefined (name: stringPtr): boolean;

{ See if a macro name is in the macro table                     }
{                                                               }
{ The returned value is true if the macro exists, else false.   }
{                                                               }
{ parameters:                                                   }
{       name - name of the macro to search for                  }


procedure NextCh; extern;

{ Read the next character from the file, skipping comments.     }
{                                                               }
{ Globals:                                                      }
{       ch - character read                                     }


procedure NextToken;

{ Read the next token from the file.                            }


procedure PutBackToken (var token: tokenType; expandEnabled: boolean);

{ place a token into the token stream                           }
{                                                               }
{ parameters:                                                   }
{       token - token to put back into the token stream         }
{       expandEnabled - can macro expansion be performed?       }


procedure TermScanner;

{ Shut down the scanner.                                        }

{---------------------------------------------------------------}

implementation

const
                                        {special key values}
                                        {------------------}
   BS           = 8;                    {backspace}
   FF           = 12;                   {form feed}
   HT           = 9;                    {horizontal tab}
   NEWLINE      = 10;                   {newline}
   RETURN       = 13;                   {RETURN key code}
   VT           = 11;                   {vertical tab}

                                        {misc}
                                        {----}
   defaultName  = '13:ORCACDefs:Defaults.h'; {default include file name}
   maxErr       = 10;                   {max errors on one line}

type
   errorType = record                   {record of a single error}
      num: integer;                     {error number}
      line: integer;                    {line number}
      col: integer;                     {column number}
      end;

                                        {file inclusion}
                                        {--------------}
   filePtr = ^fileRecord;
   fileRecord = record			{NOTE: used in scanner.asm}
      next: filePtr;                    {next file in include stack}
      name: gsosOutString;		{name of the file}
      sname: gsosOutString;		{name of the file for __FILE__}
      lineNumber: integer;              {line number at the #include}
      disp: longint;                    {disp of next character to process}
      end;

   getFileInfoOSDCB = record
      pcount: integer;
      pathName: gsosInStringPtr;
      access: integer;
      fileType: integer;
      auxType: longint;
      storageType: integer;
      createDateTime: timeField;
      modDateTime: timeField;
      optionList: optionListPtr;
      dataEOF: longint;
      blocksUsed: longint;
      resourceEOF: longint;
      resourceBlocks: longint;
      end;

   expandDevicesDCBGS = record
      pcount: integer;
      inName: gsosInStringPtr;
      outName: gsosOutStringPtr;
      end;
   
                                        {conditional compilation parsing}
                                        {-------------------------------}
   ifPtr = ^ifRecord;
   ifRecord = record
      next: ifPtr;                      {next record in if stack}
      status:                           {what are we doing?}
         (processing,skippingToEndif,skippingToElse);
      elseFound: boolean;               {has an #else been found?}
      end;

var
   dateStr: longStringPtr;              {macro date string}
   doingPPExpression: boolean;          {are we processing a preprocessor expression?}
   doingstring: boolean;                {used to supress comments in strings}
   errors: array[1..maxErr] of errorType; {errors in this line}
   eofPtr: ptr;                         {points one byte past the last char in the file}
   fileList: filePtr;                   {include file list}
   flagOverflows: boolean;              {flag numeric overflows?}
   gettingFileName: boolean;            {are we in GetFileName?}
   lastWasReturn: boolean;              {was the last character an eol?}
   lineStr: string[5];			{string form of __LINE__}
   ifList: ifPtr;                       {points to the top prep. parse record}
   includeChPtr: ptr;			{chPtr at start of current token}
   includeCount: 0..maxint;		{nested include files (for EndInclude)}
   macroFound: macroRecordPtr;          {last macro found by IsDefined}
   needWriteLine: boolean;              {is there a line that needs to be written?}
   numErr: 0..maxErr;                   {number of errors in this line}
   oneStr: string[2];			{string form of __STDC__}
   ispstring: boolean;                  {is the current string a p-string?}
   saveNumber: boolean;                 {save the characters in a number?}
   skipping: boolean;                   {skipping tokens?}
   timeStr: longStringPtr;              {macro time string}
   tokenColumn: 0..maxint;              {column number at start of this token}
   tokenLine: 0..maxint;                {line number at start of this token}
   tokenList: tokenListRecordPtr;       {token putback buffer}
   tokenStart: ptr;                     {pointer to the first char in the token}
   tokenEnd: ptr;                       {pointer to the first char past the token}
   tokenExpandEnabled: boolean;         {can token be macro expanded? (only for ident)}
   versionStrL: longStringPtr;          {macro version string}
   workString: pstring;                 {for building strings and identifiers}

{-- External procedures; see expresssion evaluator for notes ---}

procedure EndInclude (chPtr: ptr); extern;

{ Saves symbols created by the include file			}
{								}
{ Parameters:							}
{    chPtr - chPtr when the file returned			}
{								}
{ Notes:							}
{    1. Call this subroutine right after processing an		}
{       include file.						}
{    2. Fron Header.pas						}


procedure ExpandDevicesGS (var parms: expandDevicesDCBGS); prodos ($0154);
           

procedure Expression (kind: expressionKind; stopSym: tokenSet); extern;

{ handle an expression                                          }


function FindSymbol (var tk: tokenType; class: spaceType; oneLevel: boolean;
                     staticAllowed: boolean): identPtr; extern;

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


procedure FlagPragmas (pragma: pragmas); extern;

{ record the effects of a pragma				}
{								}
{ parameters:							}
{    pragma - pragma to record					}
{								}
{ Notes:							}
{    1. From Header.pas						}


procedure GetFileInfoGS (var parms: getFileInfoOSDCB); prodos ($2006);


procedure StartInclude (name: gsosOutStringPtr); extern;

{ Marks the start of an include file				}
{								}
{ Notes:							}
{    1. Call this subroutine right after opening an include	}
{       file.							}
{    2. From Header.pas						}

{-- Scanner support --------------------------------------------}

procedure CheckDelimiters (var name: pString);

{ Check for delimiters, making sure they are ':'		}
{								}
{ parameters:							}
{    name - path name to check					}

label 1;

var
   dc: char;				{delimiter character}
   i: 0..255;				{loop/index variable}

begin {CheckDelimiters}
dc := ':';				{determine what the delimiter is}
for i := 1 to length(name) do
   if name[i] in [':','/'] then begin
      dc := name[i];
      goto 1;
      end; {if}
1:  ;
if dc = '/' then			{replace '/' delimiters with ':'}
   for i := 1 to length(name) do
      if name[i] = '/' then
         name[i] := ':';
end; {CheckDelimiters}


procedure AddPath (name: pString);

{ Add a path name to the path name table			}
{								}
{ parameters:							}
{    name - path name to add					}

var
   pp, ppe: pathRecordPtr;		{work pointers}

begin {AddPath}
if length(name) <> 0 then begin
   CheckDelimiters(name);		{make sure ':' is used}
   if name[length(name)] <> ':' then	{make sure there is a trailing delimiter}
      name := concat(name, ':');
					{create the new path record}
   pp := pathRecordPtr(GMalloc(sizeof(pathRecord)));
   pp^.next := nil;
   pp^.path := stringPtr(GMalloc(length(name)+1));
   pp^.path^ := name;
   if pathList = nil then		{add the path to the path list}
      pathList := pp
   else begin
      ppe := pathList;
      while ppe^.next <> nil do
         ppe := ppe^.next;
      ppe^.next := pp;
      end; {else}
   end; {if}
end; {AddPath}


function Convertsl(var str: pString): longint; extern;

{ Return the integer equivalent of the string.  Assumes a valid }
{ 4-byte integer string; supporst unsigned values.              }


procedure SetDateTime; extern;

{ set up the macro date/time strings                            }


function KeyPress: boolean; extern;
 
{ Has a key been presed?                                        }
{                                                               }
{ If a key has not been pressed, this function returns          }
{ false.  If a key has been pressed, it clears the key          }
{ strobe.  If the key was an open-apple ., a terminal exit      }
{ is performed; otherwise, the function returns true.           }
 

function IsDefined {name: stringPtr): boolean};

{ See if a macro name is in the macro table                     }
{                                                               }
{ The returned value is true if the macro exists, else false.   }
{                                                               }
{ parameters:                                                   }
{       name - name of the macro to search for                  }
{                                                               }
{ outputs:                                                      }
{       macroFound - pointer to the macro found                 }

label 1;

var
   bPtr: ^macroRecordPtr;               {pointer to hash bucket}
   mPtr: macroRecordPtr;                {for checking list of macros}

begin {IsDefined}
IsDefined := false;
bPtr := pointer(ord4(macros) + Hash(name));
mPtr := bPtr^;
while mPtr <> nil do begin
   if mPtr^.name^ = name^ then begin
      IsDefined := true;
      goto 1;
      end; {if}
   mPtr := mPtr^.next;
   end; {while}
1:
macroFound := mPtr;
end; {IsDefined}


procedure PutBackToken {var token: tokenType; expandEnabled: boolean};

{ place a token into the token stream                           }
{                                                               }
{ parameters:                                                   }
{       token - token to put back into the token stream         }
{       expandEnabled - can macro expansion be performed?       }

var
   tPtr: tokenListRecordPtr;            {work pointer}

begin {PutBackToken}
new(tPtr);
tPtr^.next := tokenList;
tokenList := tPtr;
tPtr^.token := token;
tPtr^.expandEnabled := expandEnabled;
tPtr^.tokenStart := tokenStart;
tPtr^.tokenEnd := tokenEnd;
end; {PutBackToken}


procedure WriteLine;

{ Write the current character to the screen.                    }
{                                                               }
{ Global Variables:                                             }
{   firstPtr - points to the first char in the line             }
{   chPtr - points to the end of line character                 }

var
   cl: 0..maxint;                       {column number loop index}
   cp: ptr;                             {work pointer}
   i: 1..maxErr;                        {error loop index}
   msg: stringPtr;                      {pointer to the error message}
 
begin {WriteLine}
if list or (numErr <> 0) then begin
   write(lineNumber:4, ' ');            {write the line #}
   cp := firstPtr;                      {write the characters in the line}
   while cp <> chPtr do begin
     if cp^ <> RETURN then
       write(chr(cp^));
     cp := pointer(ord4(cp) + 1);
     end; {while}
   writeln;                             {write the end of line character}
   for i := 1 to numErr do              {write any errors}
     with errors[i] do begin
       if line = lineNumber then begin
         for cl := 1 to col+4 do
           write(' ');
         write('^ ');
         end {if}
       else
         write('     Error in column ', col:1, ' of line ', line:1, ': ');
       case num of
         1 : msg := @'illegal character';
         2 : msg := @'invalid character constant';
         3 : msg := @'no end was found to the string';
         4 : msg := @'further errors suppressed';
         5 : msg := @'cannot redefine a macro';
         6 : msg := @'integer overflow';
         7 : msg := @'''8'' and ''9'' cannot be used in octal constants';
         8 : msg := @'unknown preprocessor command';
         9 : msg := @'identifier expected';
         10: msg := @'cannot undefine standard macros';
         11: msg := @'end of line expected';
         12: msg := @''')'' expected';
         13: msg := @'''('' expected';
         14: msg := @'incorrect number of macro parameters';
         15: msg := @'''>'' expected';
         16: msg := @'file name is too long';
         17: msg := @'keep must appear before any functions';
         18: msg := @'integer constant expected';
         19: msg := @'only one #else may be used per #if';
         20: msg := @'there is no #if for this directive';
         21: msg := @'an #if had no closing #endif';
         22: msg := @''';'' expected';
         23: msg := @'''}'' expected';
         24: msg := @''']'' expected';
         25: msg := @'the else has no matching if';
         26: msg := @'type expected';
         27: msg := @'''{'' expected';
         28: msg := @'a function cannot be defined here';
         29: msg := @''':'' expected';
         30: msg := @'''while'' expected';
         31: msg := @'undeclared identifier';
         32: msg := @'the last if statement was not finished';
         33: msg := @'the last do statement was not finished';
         34: msg := @'the last compound statement was not finished';
         35: msg := @'expression expected';
         36: msg := @'expression syntax error';
         37: msg := @'operand expected';
         38: msg := @'operation expected';
         39: msg := @'no matching ''?'' found for this '':'' operator';
         40: msg := @'illegal type cast';
         41: msg := @'illegal operand in a constant expression';
         42: msg := @'duplicate symbol';
         43: msg := @'the function''s type must match the previous declaration';
         44: msg := @'too many initializers';
         45: msg := @'the number of array elements must be greater than 0';
         46: msg := @'you must initialize the individual elements of a struct, union, or non-char array';
         47: msg := @'type conflict';
         48: msg := @'pointer initializers must resolve to an integer, address or string';
         49: msg := @'the size could not be determined';
         50: msg := @'only parameters or types may be declared here';
         51: msg := @'lint: undefined function';
         52: msg := @'you cannot initialize a type';
         53: msg := @'the structure or union has already been defined';
         54: msg := @'bit fields must be less than 32 bits wide';
         55: msg := @'a value cannot be zero bits wide';
         56: msg := @'bit fields in unions are not supported by ORCA/C';
         57: msg := @'compiler error';
         58: msg := @'implementation restriction: too many local labels';
         59: msg := @'file name expected';
         60: msg := @'implementation restriction: string space exhausted';
         61: msg := @'implementation restriction: run-time stack space exhausted';
         62: msg := @'auto or register can only be used in a function body';
         63: msg := @'token merging produced an illegal token';
         64: msg := @'assignment to an array is not allowed';
         65: msg := @'assignment to void is not allowed';
         66: msg := @'the operation cannot be performed on operands of the type given';
         67: msg := @'the last else clause was not finished';
         68: msg := @'the last while statement was not finished';
         69: msg := @'the last for statement was not finished';
         70: msg := @'the last switch statement was not finished';
         71: msg := @'switch expressions must evaluate to integers';
         72: msg := @'case and default labels must appear in a switch statement';
         73: msg := @'duplicate case label';
         74: msg := @'only one default label is allowed in a switch statement';
         75: msg := @'continue must appear in a while, do or for loop';
         76: msg := @'break must appear in a while, do, for or switch statement';
         77: msg := @'duplicate label';
         78: msg := @'l-value required';
         79: msg := @'illegal operand for the indirection operator';
         80: msg := @'the selection operator must be used on a structure or union';
         81: msg := @'the selected field does not exist in the structure or union';
         82: msg := @'''('', ''['' or ''*'' expected';
         83: msg := @'string constant expected';
         84: msg := @'''dynamic'' expected';
         85: msg := @'the number of parameters does not agree with the prototype';
         86: msg := @''','' expected';
         87: msg := @'invalid storage type for a parameter';
         88: msg := @'you cannot initialize a parameter';
         89: msg := @'''.'' expected';
         90: msg := @'string too long';
         91: msg := @'real constants cannot be unsigned';
         92: msg := @'statement expected';
         93: msg := @'assignment to const is not allowed';
         94: msg := @'pascal qualifier is only allowed on functions';
         95: msg := @'unidentified operation code';
         96: msg := @'incorrect operand size';
         97: msg := @'operand syntax error';
         98: msg := @'invalid operand';
         99: msg := @'comp data type is not supported by the 68881';
        100: msg := @'integer constants cannot use the f designator';
        101: msg := @'digits expected in the exponent';
       {102: msg := @'extern variables cannot be initialized';}
        103: msg := @'functions cannot return functions or arrays';
        104: msg := @'lint: missing function type';
        105: msg := @'lint: parameter list not prototyped';
        106: msg := @'cannot take the address of a bit field';
        107: msg := @'illegal use of forward declaration';
        108: msg := @'unknown cc= option on command line';
        109: msg := @'illegal math operation in a constant expression';
        110: msg := @'lint: unknown pragma';
        111: msg := @'the & operator cannot be applied to arrays';
        112: msg := @'segment buffer overflow';
        113: msg := @'all parameters must have a name';
        114: msg := @'a function call was made to a non-function';
        115: msg := @'illegal bit field declaration';
        116: msg := @'missing field name';
        117: msg := @'field cannot have incomplete type';
        118: msg := @'flexible array must be last member of structure';
        119: msg := @'inline specifier is only allowed on functions';
        120: msg := @'non-static inline functions are not supported';
        121: msg := @'invalid digit for binary constant';
        122: msg := @'arithmetic is not allowed on a pointer to an incomplete or function type';
        123: msg := @'array element type may not be an incomplete or function type';
        124: msg := @'invalid format string';
        125: msg := @'format string is not a string literal';
         otherwise: Error(57);
         end; {case}
       writeln(msg^);
       if terminalErrors then begin
          if enterEditor then
             ExitToEditor(msg, ord4(firstPtr)+col-ord4(bofPtr)-1)
          else
             TermError(0);
          end; {if}
       end; {with}
					{handle pauses}
   if ((numErr <> 0) and wait) or KeyPress then begin
      DrawHourglass;
      while not KeyPress do {nothing};               
      ClearHourglass;
      end; {if}
   numErr := 0;                         {no errors on next line...}
   end {if}
else
   if KeyPress then begin               {handle pauses}
      DrawHourglass;
      while not KeyPress do {nothing};
      ClearHourglass;
      end; {if}
Spin;					{twirl the spinner}
end; {WriteLine}


procedure PrintToken (token: tokenType);

{ Write a token to standard out                                 }
{								}
{ parameters:							}
{    token - token to print					}

label 1;

var
   ch: char;                            {work character}
   i: integer;                          {loop counter}


   procedure PrintHexDigit(i: integer);

   { Print a digit as a hex character                           }
   {                                                            }
   { Parameters:                                                }
   {    i: value to print in least significant 4 bits           }

   begin {PrintHexDigit}
   i := i & $000F;
   if i < 10 then
      write(chr(i | ord('0')))
   else
      write(chr(i + ord('A') - 10));
   end; {PrintHexDigit}


begin {PrintToken}
case token.kind of
   typedef,
   ident:            write(token.name^);

   intconst,
   uintconst:        write(token.ival:1);

   longConst,
   ulongConst:       write(token.lval:1);

   doubleConst:      write(token.rval:1);

   stringConst:      begin
                     write('"');
                     for i := 1 to token.sval^.length do begin
                        ch := token.sval^.str[i];
                        if ch in [' '..'~'] then
                           write(ch)
                        else begin
                           write('\x0');
                           PrintHexDigit(ord(ch)>>4);
                           PrintHexDigit(ord(ch));
                           end; {else}
                        end; {for}
                     write('"');
                     end;

   autosy,asmsy,breaksy,casesy,charsy,
   continuesy,constsy,compsy,defaultsy,dosy,
   doublesy,elsesy,enumsy,externsy,extendedsy,
   floatsy,forsy,gotosy,ifsy,intsy,
   inlinesy,longsy,pascalsy,registersy,returnsy,
   shortsy,sizeofsy,staticsy,structsy,switchsy,
   segmentsy,signedsy,typedefsy,unionsy,unsignedsy,
   voidsy,volatilesy,whilesy:
                     write(reservedWords[token.kind]);

   tildech,questionch,lparench,rparench,lbrackch,rbrackch,lbracech,
   rbracech,commach,semicolonch,colonch,poundch:
                     begin
                     for i := minChar to maxChar do
                        if charSym[i] = token.kind then begin
                           write(chr(i));
                           goto 1;
                           end; {if}
                     end;

   minusch:          write('-');

   plusch:           write('+');

   ltch:             write('<');

   gtch:             write('>');

   eqch:             write('=');

   excch:            write('!');

   andch:            write('&');

   barch:            write('|');

   percentch:        write('%');

   carotch:          write('^');

   asteriskch:       write('*');

   slashch:          write('/');

   dotch:            write('.');

   minusgtop:        write('->');

   opplusplus,
   plusplusop:       write('++');

   opminusminus,
   minusminusop:     write('--');

   ltltop:           write('<<');

   gtgtop:           write('>>');

   lteqop:           write('<=');

   gteqop:           write('>=');

   eqeqop:           write('==');

   exceqop:          write('!=');

   andandop:         write('&&');

   barbarop:         write('||');

   pluseqop:         write('+=');

   minuseqop:        write('-=');

   asteriskeqop:     write('*=');

   slasheqop:        write('/=');

   percenteqop:      write('%=');

   ltlteqop:         write('<<=');

   gtgteqop:         write('>>=');

   andeqop:          write('&=');

   caroteqop:        write('^=');

   bareqop:          write('!=');

   uminus:           write('-');

   uand:             write('+');

   uasterisk:        write('*');

   macroParm:        write('$', token.pnum:1);

   poundpoundop,
   parameteroper,
   castoper,
   eolsy,
   eofsy:	;
   end; {case}
1:
write(' ');
end; {PrintToken}

{ copy 'Scanner.debug'} {debug}

{-- The Preprocessor -------------------------------------------}

procedure CheckIdentifier; forward;

{ See if an identifier is a reserved word, macro or typedef     }


procedure DoNumber (scanWork: boolean); forward;

{  The current character starts a number - scan it            }
{                                                             }
{  Parameters:                                                }
{     scanWork - get characters from workString?              }
{                                                             }
{  Globals:                                                   }
{     ch - first character in sequence; set to first char     }
{             after sequence                                  }
{     workString - string to take numbers from                }


function GetFileType (var name: pString): integer; forward;

{ Checks to see if a file exists				}
{								}
{ parameters:							}
{    name - file name to check for				}
{								}
{ Returns: File type if the file exists, or -1 if the file does	}
{    not exist (or if GetFileInfo returns an error)		}


function OpenFile (doInclude, default: boolean): boolean; forward;

{ Open a new file and start scanning it				}
{								}
{ Parameters:							}
{    doInclude - are we doing a #include?			}
{    default - use the name <defaults.h>?			}
{								}
{ Returns: result from GetFileName				}


function FindMacro (name: stringPtr): macroRecordPtr;

{ If the current token is a macro, find the macro table entry   }
{                                                               }
{ Parameters:                                                   }
{       name - name of the suspected macro                      }
{                                                               }
{ Returns:                                                      }
{       Pointer to macro table entry; nil for none              }

label 1;

var
   bPtr: ^macroRecordPtr;               {pointer to hash bucket}
   mPtr: macroRecordPtr;                {pointer to macro entry}

begin {FindMacro}
FindMacro := nil;
bPtr := pointer(ord4(macros)+Hash(name));
mPtr := bPtr^;
while mPtr <> nil do begin
   if mPtr^.name^ = name^ then begin
      if mPtr^.parameters = -1 then
	 FindMacro := mPtr
      else if tokenList = nil then begin
	 while charKinds[ord(ch)] in [ch_white, ch_eol] do begin
	    if printMacroExpansions then
	       if charKinds[ord(ch)] = ch_eol then
        	  writeln
	       else
        	  write(ch);
	    NextCh;
	    end; {while}
         if ch = '(' then
            FindMacro := mPtr;
         end {else if}
      else if tokenList^.token.kind = lparench then
         FindMacro := mPtr;
      goto 1;
      end; {if}
   mPtr := mPtr^.next;
   end; {while}
1:
end; {FindMacro}


procedure LongToPString (pstr: stringPtr; lstr: longStringPtr);

{ Convert a long string into a p string                         }
{                                                               }
{ Parameters:                                                   }
{       pstr - pointer to the p-string                          }
{       lstr - pointer to the long string                       }

var
   i: integer;                          {loop variable}
   len: integer;                        {string length}

begin {LongToPString}
len := lstr^.length;
if len > 255 then
   len := 255;
pstr^[0] := chr(len);
for i := 1 to len do
   pstr^[i] := lstr^.str[i];
end; {LongToPString}


procedure Merge (var tk1: tokenType; tk2: tokenType);

{ Merge two tokens                                              }
{                                                               }
{ Parameters:                                                   }
{       tk1 - first token; result is stored here                }
{       tk2 - second token                                      }

label 1;

var
   class1,class2: tokenClass;           {token classes}
   cp: longstringPtr;                   {pointer to work string}
   i: integer;                          {loop variable}
   kind1,kind2: tokenEnum;              {token kinds}
   len,len1: integer;                   {length of strings}
   lt: tokenType;                       {local copy of token}
   str1,str2: stringPtr;                {identifier strings}

begin {Merge}
kind1 := tk1.kind;
class1 := tk1.class;
kind2 := tk2.kind;
class2 := tk2.class;
if class1 in [identifier,reservedWord] then begin
   if class1 = identifier then
      str1 := tk1.name
   else
      str1 := @reservedWords[kind1];
   if class2 = identifier then
      str2 := tk2.name
   else if class2 = reservedWord then
      str2 := @reservedWords[kind2]
   else if class2 in [intConstant,longConstant,doubleConstant] then
      str2 := tk2.numString                   
   else begin
      Error(63);
      goto 1;
      end; {else}
   workString := concat(str1^, str2^);
   for i := 1 to length(workString) do
      if not (charKinds[ord(workString[i])] in [letter,digit]) then begin
         Error(63);
         goto 1;
         end; {if}
   lt := token;
   token.kind := ident;
   token.class := identifier;
   token.numString := nil;
   token.name := @workString;
   token.symbolPtr := nil;
   CheckIdentifier;
   tk1 := token;
   token := lt;
   goto 1;
   end {class1 in [identifier,reservedWord]}

else if class1 in [intConstant,longConstant,doubleConstant] then begin
   if class2 in [intConstant,longConstant,doubleConstant] then
      str2 := tk2.numString
   else if class2 = identifier then
      str2 := tk2.name
   else if class2 = reservedWord then
      str2 := @reservedWords[kind2]
   else if kind2 = dotch then
      str2 := @'.'
   else begin
      Error(63);
      goto 1;
      end; {else}
   workString := concat(tk1.numString^, str2^);
   lt := token;
   DoNumber(true);
   tk1 := token;
   token := lt;
   goto 1;
   end {else if class1 in [intConstant,longConstant,doubleConstant]}

else if class1 = stringConstant then begin
   if class2 = stringConstant then begin
      len1 := tk1.sval^.length;
      len := len1+tk2.sval^.length;
      cp := pointer(Malloc(len+2));
      for i := 1 to len1 do
         cp^.str[i] := tk1.sval^.str[i];
      for i := 1 to len-len1 do
         cp^.str[i+len1] := tk2.sval^.str[i];
      cp^.length := len;
      if tk1.ispstring then
         cp^.str[1] := chr(len-1);
      tk1.sval := cp;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = dotch then begin
   if class2 in [intConstant,longConstant,doubleConstant] then begin
      workString := concat(tk1.numString^, tk2.numString^);
      lt := token;
      DoNumber(true);
      tk1 := token;
      token := lt;
      goto 1;
      end; {if}
   end {else if class1 in [intConstant,longConstant,doubleConstant]}

else if kind1 = poundch then begin
   if kind2 = poundch then begin
      tk1.kind := poundpoundop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = minusch then begin
   if kind2 = gtch then begin
      tk1.kind := minusgtop;
      goto 1;
      end {if}
   else if kind2 = minusch then begin
      tk1.kind := minusminusop;
      goto 1;
      end {else if}
   else if kind2 = eqch then begin
      tk1.kind := minuseqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = plusch then begin
   if kind2 = plusch then begin
      tk1.kind := plusplusop;
      goto 1;
      end {else if}
   else if kind2 = eqch then begin
      tk1.kind := pluseqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = ltch then begin
   if kind2 = ltch then begin
      tk1.kind := ltltop;
      goto 1;
      end {if}
   else if kind2 = lteqop then begin
      tk1.kind := ltlteqop;
      goto 1;
      end {else if}
   else if kind2 = eqch then begin
      tk1.kind := lteqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = ltltop then begin
   if kind2 = eqch then begin
      tk1.kind := ltlteqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = gtch then begin
   if kind2 = gtch then begin
      tk1.kind := gtgtop;
      goto 1;
      end {if}
   else if kind2 = gteqop then begin
      tk1.kind := gtgteqop;
      goto 1;
      end {else if}
   else if kind2 = eqch then begin
      tk1.kind := gteqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = gtgtop then begin
   if kind2 = eqch then begin
      tk1.kind := gtgteqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = eqch then begin
   if kind2 = eqch then begin
      tk1.kind := eqeqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = excch then begin
   if kind2 = eqch then begin
      tk1.kind := exceqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = andch then begin
   if kind2 = andch then begin
      tk1.kind := andandop;
      goto 1;
      end {if}
   else if kind2 = eqch then begin
      tk1.kind := andeqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = barch then begin
   if kind2 = barch then begin
      tk1.kind := barbarop;
      goto 1;
      end {if}
   else if kind2 = eqch then begin
      tk1.kind := bareqop;
      goto 1;
      end; {else if}
   end {else if}

else if kind1 = percentch then begin
   if kind2 = eqch then begin
      tk1.kind := percenteqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = carotch then begin
   if kind2 = eqch then begin
      tk1.kind := caroteqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = asteriskch then begin
   if kind2 = eqch then begin
      tk1.kind := asteriskeqop;
      goto 1;
      end; {if}
   end {else if}

else if kind1 = slashch then begin
   if kind2 = eqch then begin
      tk1.kind := slasheqop;
      goto 1;
      end; {if}
   end; {else if}

Error(63);
1:
end; {Merge}


procedure BuildStringToken (cp: ptr; len: integer);

{ Create a string token from a string                           }
{                                                               }
{ Used to stringize macros.                                     }
{                                                               }
{ Parameters:                                                   }
{       cp - pointer to the first character                     }
{       len - number of characters in the string                }

var
   i: integer;                          {loop variable}

begin {BuildStringToken}
token.kind := stringconst;
token.class := stringConstant;
token.ispstring := false;
token.sval := pointer(GMalloc(len+2));
for i := 1 to len do begin
   token.sval^.str[i] := chr(cp^);
   cp := pointer(ord4(cp)+1);
   end; {for}
token.sval^.length := len;
PutBackToken(token, true);
end; {BuildStringToken}


procedure DoInclude (default: boolean);

{ #include							}
{								}
{ Parameters:							}
{    default - open <defaults.h>?				}

var
   fp: filePtr;				{pointer to an include file}

begin {DoInclude}
new(fp);				{get a file record for the current file}
fp^.next := fileList;
fileList := fp;
fp^.name := includeFileGS;
fp^.sname := sourceFileGS;
if default then
   fp^.lineNumber := lineNumber
else
   fp^.lineNumber := lineNumber+1;
if OpenFile(true, default) then begin	{open a new file and proceed from there}
   lineNumber := 1;
   StartInclude(@includeFileGS);
   end {if}
else begin				{handle a file name error}
   fileList := fp^.next;
   dispose(fp);
   end; {else}
end; {DoInclude}


procedure Expand (macro: macroRecordPtr);

{ Expand a preprocessor macro                                   }
{                                                               }
{ Expands a preprocessor macro by putting tokens from the macro }
{ definition into the scanner's putback buffer.                 }
{                                                               }
{ Parameters:                                                   }
{       macro - pointer to the macro to expand                  }
{                                                               }
{ Globals:                                                      }
{       macroList - scanner putback buffer                      }

type
   parameterPtr = ^parameterRecord;
   parameterRecord = record             {parameter list element}
      next: parameterPtr;               {next parameter}
      tokens: tokenListRecordPtr;       {token list}
      tokenStart,tokenEnd: ptr;         {source pointers (for stringization)}
      end;

var
   bPtr: ^macroRecordPtr;               {pointer to hash bucket}
   done: boolean;                       {used to check for loop termination}
   expandEnabled: boolean;              {can the token be expanded?}
   i: integer;                          {loop counter}
   inhibit: boolean;                    {inhibit parameter expansion?}
   lexpandMacros: boolean;              {local copy of expandMacros}
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}
   mPtr: macroRecordPtr;                {for checking list of macros}
   newParm: parameterPtr;               {for building a new parameter entry}
   tlPtr, tPtr, tcPtr, lastPtr: tokenListRecordPtr; {work pointers}
   paramCount: integer;                 {# of parameters found in the invocation}
   parenCount: integer;                 {paren count; for balancing parenthesis}
   parmEnd: parameterPtr;               {for building a parameter list}
   parms: parameterPtr;                 {points to the list of parameters}
   pptr: parameterPtr;                  {work pointer for tracing parms list}
   sp: longStringPtr;                   {work pointer}
   stringization: boolean;              {are we stringizing a parameter?}

begin {Expand}
lPrintMacroExpansions := printMacroExpansions; {inhibit token printing}
printMacroExpansions := false;
lexpandMacros := expandMacros;          {prevent expansion of parameters}
expandMacros := false;
saveNumber := true;                     {save numeric strings}
parms := nil;                           {no parms so far}
if macro^.parameters >= 0 then begin    {find the values of the parameters}
   NextToken;                           {get the '(' (we hope...)}
   if token.kind = lparench then begin
      NextToken;                        {skip the '('}
      paramCount := 0;                  {process the parameters}
      parmEnd := nil;
      repeat
         done := true;
         if token.kind <> rparench then begin
            parenCount := 0;
            paramCount := paramCount+1;
            new(newParm);
            newParm^.next := nil;
            if parmEnd = nil then
               parms := newParm
            else
               parmEnd^.next := newParm;
            parmEnd := newParm;
            newParm^.tokens := nil;
            while (token.kind <> eofsy)
               and ((parenCount <> 0)
               or (not (token.kind in [rparench,commach]))) do begin
               new(tPtr);
               tPtr^.next := newParm^.tokens;
               newParm^.tokens := tPtr;
               tPtr^.token := token;
               tPtr^.tokenStart := tokenStart;
               tPtr^.tokenEnd := tokenEnd;
               tPtr^.expandEnabled := tokenExpandEnabled;
               if token.kind = lparench then
                  parenCount := parenCount+1
               else if token.kind = rparench then
                  parenCount := parenCount-1;
               NextToken;
               end; {while}
            if token.kind = commach then begin
               NextToken;
               done := false;
               end; {if}
            end; {if}
      until done;
      if paramCount <> macro^.parameters then
         Error(14);
      if token.kind <> rparench then begin  {insist on a closing ')'}
         if not gettingFileName then        {put back the source stream token}
            PutBackToken(token, true);
         Error(12);
         end; {if}
      end {if}
   else begin
      Error(13);
      if not gettingFileName then       {put back the source stream token}
         PutBackToken(token, true);
      end; {else}
   end; {if}
if macro^.readOnly then begin           {handle special macros}
   case macro^.algorithm of

      1: begin                          {__LINE__}
         token.kind := intconst;
         token.numString := @lineStr;
         token.class := intconstant;
         token.ival := lineNumber;
         lineStr := cnvis(token.ival);
         tokenStart := @lineStr[1];
         tokenEnd := pointer(ord4(tokenStart)+length(lineStr));
         end;

      2: begin                          {__FILE__}
         token.kind := stringConst;
         token.class := stringConstant;
         token.ispstring := false;
         sp := pointer(Malloc(5+sourceFileGS.theString.size));
         sp^.length := sourceFileGS.theString.size;
         for i := 1 to sourceFileGS.theString.size do
            sp^.str[i] := sourceFileGS.theString.theString[i];
         token.sval := sp;
         tokenStart := @sp^.str;
         tokenEnd := pointer(ord4(tokenStart)+sp^.length);
         end;

      3: begin                          {__DATE__}
         token.kind := stringConst;
         token.class := stringConstant;
         token.ispstring := false;
         token.sval := dateStr;
         tokenStart := @dateStr^.str;
         tokenEnd := pointer(ord4(tokenStart)+dateStr^.length);
         end;                                   

      4: begin                          {__TIME__}
         token.kind := stringConst;
         token.class := stringConstant;
         token.ispstring := false;
         token.sval := timeStr;
         tokenStart := @timeStr^.str;
         tokenEnd := pointer(ord4(tokenStart)+timeStr^.length);
         end;

      5: begin                          {__STDC__}
         token.kind := intConst;        {__ORCAC__}
         token.numString := @oneStr;
         token.class := intConstant;
         token.ival := 1;
         oneStr := '1';
         tokenStart := @oneStr[1];
         tokenEnd := pointer(ord4(tokenStart)+1);
         end;

      6: begin                          {__VERSION__}
         token.kind := stringConst;
         token.class := stringConstant;
         token.ispstring := false;
         token.sval := versionStrL;
         tokenStart := @versionStrL^.str;
         tokenEnd := pointer(ord4(tokenStart)+versionStrL^.length);
         end;                     

      otherwise: Error(57);

      end; {case}
   PutBackToken(token, true);
   end {if}
else begin

   {expand the macro}
   tlPtr := macro^.tokens;              {place the tokens in the buffer...}
   lastPtr := nil;
   while tlPtr <> nil do begin
      if tlPtr^.token.kind = macroParm then begin
         pptr := parms;                 {find the correct parameter}
         for i := 1 to tlPtr^.token.pnum do
            if pptr <> nil then
               pptr := pptr^.next;
         if pptr <> nil then begin

            {see if the macro is stringized}
            stringization := false;
            if tlPtr^.next <> nil then
               stringization := tlPtr^.next^.token.kind = poundch;

            {handle macro stringization}
            if stringization then begin
               tcPtr := pptr^.tokens;
               while tcPtr <> nil do begin
                  if tcPtr^.token.kind = stringconst then
                     BuildStringToken(@tcPtr^.token.sval^.str,
                        tcPtr^.token.sval^.length)
                  else
                     BuildStringToken(tcPtr^.tokenStart,
                        ord(ord4(tcPtr^.tokenEnd)-ord4(tcPtr^.tokenStart)));
                  tcPtr := tcPtr^.next;
                  end; {while}
               tlPtr := tlPtr^.next;
               end {if}

            {expand a macro parameter}
            else begin
               tcPtr := pptr^.tokens;
               while tcPtr <> nil do begin
                  tokenStart := tcPtr^.tokenStart;
                  tokenEnd := tcPtr^.tokenEnd;
                  if tcPtr^.token.kind = ident then begin
                     mPtr := FindMacro(tcPtr^.token.name);
                     inhibit := false;
                     if tlPtr^.next <> nil then
                        if tlPtr^.next^.token.kind = poundpoundop then
                           inhibit := true;
                     if lastPtr <> nil then
                        if lastPtr^.token.kind = poundpoundop then
                           inhibit := true;
                     if not tcPtr^.expandEnabled then
                        inhibit := true;
                     if tcPtr = pptr^.tokens then
                        if (mPtr <> nil) and (mPtr^.parameters > 0) then
                           inhibit := true;
                     if (mPtr <> nil) and (not inhibit) then
                        Expand(mPtr)
                     else begin
                        expandEnabled := tcPtr^.expandEnabled;
                        if expandEnabled then
                           if tcPtr^.token.name^ = macro^.name^ then
                              expandEnabled := false;
                        PutBackToken(tcPtr^.token, expandEnabled);
                        end; {else}
                     end {if}
                  else
                     PutBackToken(tcPtr^.token, true);
                  tcPtr := tcPtr^.next;
                  end; {while}
               end; {else}
            end; {if pptr <> nil}
         end {if tlPtr^.token.kind = macroParm}
      else begin

         {place an explicit parm in the token list}
         expandEnabled := true;
         if tlPtr^.token.kind = ident then
            if tlPtr^.token.name^ = macro^.name^ then
               expandEnabled := false;
         tokenStart := tlPtr^.tokenStart;
         tokenEnd := tlPtr^.tokenEnd;
         PutBackToken(tlPtr^.token, expandEnabled);
         end; {else}
      lastPtr := tlPtr;
      tlPtr := tlPtr^.next;
      end; {while}
   end; {else}
while parms <> nil do begin             {dispose of the parameter list}
   tPtr := parms^.tokens;
   while tPtr <> nil do begin
      tlPtr := tPtr^.next;
      dispose(tPtr);
      tPtr := tlPtr;
      end; {while}
   parmEnd := parms^.next;
   dispose(parms);
   parms := parmEnd;
   end; {while}
expandMacros := lexpandMacros;          {restore the flags}
printMacroExpansions := lPrintMacroExpansions;
saveNumber := false;                    {stop saving numeric strings}
end; {Expand}


function GetFileName (mustExist: boolean): boolean;

{ Read a file name from a directive line			}
{								}
{ parameters:							}
{    mustExist - should we look for an existing file?		}
{								}
{ Returns true if successful, false if not.			}
{								}
{ Note: The file name is placed in workString.			}

const
   SRC = $B0;				{source file type}

var
   i,j: integer;			{string index & loop vars}


   procedure Expand (var name: pString);

   { Expands a name to a full pathname				}
   {								}
   { parameters:						}
   {    name - file name to expand				}

   var
      exRec: expandDevicesDCBGS;	{expand devices}

   begin {Expand}
   exRec.pcount := 2;
   new(exRec.inName);
   exRec.inName^.theString := name;
   exRec.inName^.size := length(name);
   new(exRec.outName);
   exRec.outName^.maxSize := maxPath+4;
   ExpandDevicesGS(exRec);
   if toolerror = 0 then
      with exRec.outName^.theString do begin
         if size < maxPath then
            theString[size+1] := chr(0);
         name := theString;
         end; {with}
   dispose(exRec.inName);
   dispose(exRec.outName);
   end; {Expand}


   function GetLibraryName (var name: pstring): boolean;

   { See if a library pathname is available			}
   {								}
   { Parameters:						}
   {    name - file name; set to pathname if result is true	}
   {								}
   { Returns: True if a name is available, else false		}

   var
      lname: pString;			{local copy of name}

   begin {GetLibraryName}
   lname := concat('13:ORCACDefs:', name);
   Expand(lname);
   if GetFileType(lname) = SRC then begin
      name := lname;
      GetLibraryName := true;
      end {if}
   else
      GetLibraryName := false;
   end; {GetLibraryName}


   function GetLocalName (var name: pstring): boolean;

   { See if a local pathname is available			}
   {								}
   { Parameters:						}
   {    name - file name; set to pathname if result is true	}
   {								}
   { Returns: True if a name is available, else false		}

   var
      lname: pstring;			{work string}
      pp: pathRecordPtr;		{used to trace the path list}

   begin {GetLocalName}
   lname := name;
   Expand(lname);
   if GetFileType(lname) = SRC then begin
      GetLocalName := true;
      name := lname;
      end {if}
   else begin
      GetLocalName := false;
      pp := pathList;
      while pp <> nil do begin
         lname := concat(pp^.path^, name);
         if GetFileType(lname) = SRC then begin
            GetLocalName := true;
            name := lname;
            Expand(name);
            pp := nil;
            end {if}
         else
            pp := pp^.next;
         end; {while}
      end; {else}
   end; {GetLocalName}


   procedure MakeLibraryName (var name: pstring);

   { Create the library path name for an error message		}
   {								}
   { Parameters:						}
   {    name - file name; set to pathname			}

   begin {MakeLibraryName}
   name := concat('13:ORCACDefs:', name);
   Expand(name);
   end; {MakeLibraryName}


   procedure MakeLocalName (var name: pstring);

   { Create the local path name for an error message		}
   {								}
   { Parameters:						}
   {    name - file name; set to pathname			}

   begin {MakeLocalName}
   Expand(name);
   end; {MakeLocalName}


begin {GetFileName}
GetFileName := true;
gettingFileName := true;		{in GetFileName}
while charKinds[ord(ch)] = ch_white do	{finish processing the current line}
   NextCh;
if ch = '<' then begin			{process a library file...}
   NextToken;				{skip the '<'}
   token.kind := stringconst;		{convert a <> style name to a string}
   token.class := stringConstant;
   token.ispstring := false;
   i := 0;
   while not (charKinds[ord(ch)] in [ch_eol,ch_gt]) do begin
      i := i+1;
      if (i = maxLine) then begin
         Error(16);
         GetFileName := false;
         i := 0;
         end;
      workString[i] := ch;
      NextCh;
      end; {while}
   workString[0] := chr(i);
   CheckDelimiters(workString);
   if mustExist then begin
      if not GetLibraryName(workString) then
         if not GetLocalName(workString) then
            MakeLibraryName(workString);
      end {if}
   else
      MakeLibraryName(workString);
   if ch = '>' then
      NextCh
   else begin
      Error(15);
      GetFileName := false;
      end; {else}
   end {if}
else begin

   {handle file names that are strings or macro expansions}
   expandMacros := true;		{allow macros to be used in the name}
   NextToken;				{skip the command name}
   if token.kind = stringConst then begin
      LongToPString(@workString, token.sval);
      CheckDelimiters(workString);
      if mustExist then begin
         if not GetLocalName(workString) then
	    if not GetLibraryName(workString) then
               MakeLocalName(workString);
         end {if}
      else
         MakeLocalName(workString);
      end {if}    
   else if token.kind = ltch then begin

      {expand a macro to create a <filename> form name}
      NextToken;
      workString[0] := chr(0);
      while
         (token.class in [reservedWord,intconstant,longconstant,doubleconstant])
         or (token.kind in [dotch,ident]) do begin
         if token.kind = ident then
            workstring := concat(workstring, token.name^)
         else if token.kind = dotch then
            workstring := concat(workstring, '.')
         else if token.class = reservedWord then
            workstring := concat(workstring, reservedWords[token.kind])
         else {if token.class in [intconst,longconst,doubleconst] then}
            workstring := concat(workstring, token.numstring^);
         NextToken;
         end; {while}
      CheckDelimiters(workString);
      if mustExist then begin
	 if not GetLibraryName(workString) then
            if not GetLocalName(workString) then
               MakeLibraryName(workString);
         end {if}
      else
         MakeLibraryName(workString);
      if token.kind <> gtch then begin
         Error(15);
         GetFileName := false;
         end; {if}
      end {else if}
   else begin
      Error(59);
      GetFileName := false;
      end; {else}
   end; {else}
while charKinds[ord(ch)] = ch_white	{finish processing the current line}
   do NextCh;
if charKinds[ord(ch)] <> ch_eol then	{check for extra stuff on the line}
   begin
   Error(11);
   GetFileName := false;
   end; {if}
gettingFileName := false;		{not in GetFileName}
end; {GetFileName}


function GetFileType {var name: pString): integer};

{ Checks to see if a file exists				}
{								}
{ parameters:							}
{    name - file name to check for				}
{								}
{ Returns: File type if the file exists, or -1 if the file does	}
{    not exist (or if GetFileInfo returns an error)		}

var
   pathname: gsosInString;		{GS/OS style name}
   giRec: getFileInfoOSDCB;		{GetFileInfo record}

begin {GetFileType}
giRec.pcount := 3;
giRec.pathName := @pathname;
pathname.theString := name;
pathname.size := length(name);
GetFileInfoGS(giRec);
if ToolError = 0 then
   GetFileType := giRec.fileType
else
   GetFileType := -1;
end; {GetFileType}


function OpenFile {doInclude, default: boolean): boolean};

{ Open a new file and start scanning it				}
{								}
{ Parameters:							}
{    doInclude - are we doing a #include?			}
{    default - use the name <defaults.h>?			}
{								}
{ Returns: result from GetFileName				}

var
   gotName: boolean;			{did we get a file name?}

begin {OpenFile}
if default then begin			{get the file name}
   workString := defaultName;
   gotName := true;
   end {if}
else
   gotName := GetFileName(true);

if gotName then begin			{read the file name from the line}
   OpenFile := true;			{we opened it}
   if doInclude and progress then	{note our progress}
      writeln('Including ', workString);
   WriteLine;				{write the source line}
   lineNumber := lineNumber+1;
   firstPtr := pointer(ord4(chPtr)+2);
   needWriteLine := false;
   if doInclude then			{set the disp in the file}
      fileList^.disp := ord4(chPtr)-ord4(bofPtr);
   with ffDCBGS do begin		{purge the source file}
      pCount := 5;
      action := 7;
      pathName := @includeFileGS.theString;
      end; {with}
   FastFileGS(ffDCBGS);
   oldincludeFileGS := includeFileGS;	{set the file name}
   includeFileGS.theString.theString := workString;
   includeFileGS.theString.size := length(workString);
   ReadFile;				{read the file}
   chPtr := bofPtr;			{set the start, end pointers}
   eofPtr := pointer(ord4(bofPtr)+ffDCBGS.fileLength);
   firstPtr := chPtr;			{first char in line}
   ch := chr(RETURN);			{set the initial character}
   if languageNumber <> long(ffDCBGS.auxType).lsw then begin
      switchLanguages := true;		{switch languages}
      chPtr := eofPtr;
      if doInclude then
         TermError(7);
      if fileList <> nil then
         TermError(8);
      end; {if}
   end {if}
else
   OpenFile := false;			{we failed to opened it}
end; {OpenFile}


procedure PreProcess;

{ Handle preprocessor commands                                  }

label 2;

var
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}
   lReportEOL: boolean;                 {local copy of reportEOL}
   tSkipping: boolean;                  {temp copy of the skipping variable}
   val: integer;                        {expression value}


   function Defined: boolean;
 
   { See if a macro is defined                                   }
 
   begin {Defined}
   expandMacros := false;               {block expansions}
   NextToken;                           {skip the command name}
   if token.class in [reservedWord,identifier] then begin
      Defined := IsDefined(token.name); {see if the macro is defined}
      expandMacros := true;             {enable expansions}
      NextToken;                        {skip the macro name}
      if token.kind <> eolsy then       {check for extra stuff on the line}
         Error(11);
      end {if}
   else
      Error(9);
   end; {Defined}


   procedure NumericDirective;
 
   { Process a constant expression for a directive that has a    }
   { single number as the operand.                               }
   {                                                             }
   { Notes:  The expression evaluator returns the value in the   }
   { global variable expressionValue.                            }
 
   begin {NumericDirective}
   doingPPExpression := true;
   NextToken;                            {skip the directive name}
   Expression(preprocessorExpression, []); {evaluate the expression}
   doingPPExpression := false;
   end; {NumericDirective}


   procedure ProcessIf (skip: boolean);
 
   { handle the processing for #if, #ifdef and #ifndef           }
   {                                                             }
   { parameter:                                                  }
   {     skip - should we skip to the #else                      }
 
   var
      ip: ifPtr;                        {used to create a new if record}
 
   begin {ProcessIf}
   if token.kind <> eolsy then          {check for extra stuff on the line}
      if not tSkipping then
         Error(11);
   new(ip);                             {create a new if record}
   ip^.next := ifList;
   ifList := ip;
   if tSkipping then                    {set the status of the record}
      ip^.status := skippingToEndif
   else if skip then
      ip^.status := skippingToElse
   else
      ip^.status := processing;
   ip^.elseFound := false;              {no else has been found...}
   tSkipping := ip^.status <> processing; {decide if we should be skipping}
   end; {ProcessIf}


   procedure DoAppend;
 
   { #append                                                     }

   var
      tbool: boolean;                   {temp boolean}

   begin {DoAppend}
   tbool := OpenFile(false, false);	{open a new file and proceed from there}
   lineNumber := 1;
   end; {DoAppend}


   procedure DoCDA;

   { #pragma cda NAME START SHUTDOWN                            }

   begin {DoCDA}
   FlagPragmas(p_cda);
   isClassicDeskAcc := true;
   NextToken;                           {skip the command name}
   if token.kind = stringconst then     {get the name}
      begin
      LongToPString(@menuLine, token.sval);
      NextToken;
      end {if}
   else begin
      isClassicDeskAcc := false;
      Error(83);
      end; {else}
   if token.kind = ident then begin     {get the start name}
      openName := token.name;
      NextToken;
      end {if}
   else begin
      isClassicDeskAcc := false;
      Error(9);
      end; {else}
   if token.kind = ident then begin     {get the shutdown name}
      closeName := token.name;
      NextToken;
      end {if}
   else begin
      isClassicDeskAcc := false;
      Error(9);
      end; {else}
   if token.kind <> eolsy then          {make sure there is nothing else on the line}
      Error(11);
   end; {DoCDA}


   procedure DoCDev;

   { #pragma cdev START                                         }

   begin {DoCDev}
   FlagPragmas(p_cdev);
   isCDev := true;
   NextToken;                           {skip the command name}
   if token.kind = ident then begin     {get the start name}
      openName := token.name;
      NextToken;
      end {if}
   else begin
      isCDev := false;
      Error(9);
      end; {else}
   if token.kind <> eolsy then          {make sure there is nothing else on the line}
      Error(11);
   end; {DoCDev}


   procedure DoDefine;

   { #define                                                     }
   {                                                             }
   { The way parameters are handled is a bit obtuse.  Parameters }
   { have their own token type, with the token having an         }
   { associated parameter number, pnum.  Pnum is the number of   }
   { parameters to skip to get to the parameter in the parameter }
   { list.                                                       }
   {                                                             }
   { In the macro record, parameters indicates how many          }
   { parameters there are in the definition.  -1 indicates that  }
   { there is no parameter list, while 0 indicates that a list   }
   { must exist, but that there are no parameters in the list.   }
 
   label 1,2,3;
 
   type
      stringListPtr = ^stringList;
      stringList = record               {for the parameter list}
         next: stringListPtr;
         str: pString;
         end;

   var
      bPtr: ^macroRecordPtr;            {pointer to head of hash bucket}
      done: boolean;                    {used to test for loop termination}
      i: integer;                       {loop variable}
      mf: macroRecordPtr;               {pointer to existing macro record}
      mPtr: macroRecordPtr;             {pointer to new macro record}
      np: stringListPtr;                {new parameter}
      parameterList: stringListPtr;     {list of parameter names}
      parameters: integer;              {local copy of mPtr^.parameters}
      ple: stringListPtr;               {pointer to the last element in parameterList}
      pnum: integer;                    {for counting parameters}
      tPtr,tk1,tk2: tokenListRecordPtr; {pointer to a token}

                                        {for building token strings}
      sptr: longStringPtr;              {token string work pointer}
      tcp: ptr;                         {temp character pointer}
      slen: integer;                    {token string length}

   begin {DoDefine}
   expandMacros := false;               {block expansions}
   saveNumber := true;                  {save characters in numeric tokens}
   parameterList := nil;                {no parameters yet}
   NextToken;                           {get the token name}
                                        {convert reserved words to identifiers}
   if token.class = reservedWord then begin
      token.name := @reservedWords[token.kind];
      token.kind := ident;
      token.class := identifier;
      end {if}
   else if token.kind = typedef then
      token.kind := ident;

   if token.kind = ident then begin     {we have a name...}
      mPtr := pointer(GMalloc(sizeof(macroRecord))); {create a macro record}
      mPtr^.name := token.name;         {record the name}
      mPtr^.saved := false;		{not saved in symbol file}
      mPtr^.tokens := nil;              {no tokens yet}
      charKinds[ord('#')] := ch_pound;  {allow # as a token}
      if ch = '(' then begin            {scan the parameter list...}
         NextToken;                     {done with the name token...}
         NextToken;                     {skip the opening '('}
         parameters := 0;               {no parameters yet}
         ple := nil;
         repeat                         {get the parameter names}
            done := true;

	    if token.class = reservedWord then begin
	       token.name := @reservedWords[token.kind];
	       token.kind := ident;
	       token.class := identifier;
	       end {if}
	    else if token.kind = typedef then
	       token.kind := ident;

            if token.kind = ident then begin
               new(np);
               np^.next := nil;
               np^.str := token.name^;
               if ple = nil then
                  parameterList := np
               else
                  ple^.next := np;
               ple := np;
               NextToken;
               parameters := parameters+1;
               if token.kind = commach then begin
                  NextToken;
                  done := false;
                  end; {if}
               end; {if}
         until done;
         if token.kind = rparench then  {insist on a matching ')'}
            NextToken
         else
            Error(12);
         end {if}
      else begin
         parameters := -1;              {no parameter list exists}
         NextToken;                     {done with the name token...}
         end; {else}
      mPtr^.parameters := parameters;   {record the # of parameters}
      while token.kind <> eolsy do begin {place tokens in the replace list...}

	 if token.class = reservedWord then begin
	    token.name := @reservedWords[token.kind];
	    token.kind := ident;
	    token.class := identifier;
	    end {if}
	 else if token.kind = typedef then
	    token.kind := ident;

         if token.kind = ident then begin {special handling for identifiers}
            np := parameterList;        {change parameters to macroParm}
            pnum := 0;
            while np <> nil do begin
               if np^.str = token.name^ then begin
                  token.kind := macroParm;
                  token.class := macroParameter;
                  token.pnum := pnum;
                  goto 1;
                  end; {if}
               pnum := pnum+1;
               np := np^.next;
               end; {while}
            end; {if}
1:       tPtr := pointer(GMalloc(sizeof(tokenListRecord)));
         tPtr^.next := mPtr^.tokens;
         mPtr^.tokens := tPtr;
         tPtr^.token := token;
         tPtr^.tokenStart := tokenStart;
         tPtr^.tokenEnd := tokenEnd;
         tPtr^.expandEnabled := true;
         slen := ord(ord4(chPtr) - ord4(tokenStart));
         sptr := pointer(GMalloc(slen+2));
         sptr^.length := slen;
         tcp := tokenStart;
         for i := 1 to slen do begin
            sptr^.str[i] := chr(tcp^);
            tcp := pointer(ord4(tcp)+1);
            end; {for}
         tPtr^.tokenString := sptr;
         NextToken;
         end; {while}
      mPtr^.readOnly := false;
      mPtr^.algorithm := 0;
      if IsDefined(mPtr^.name) then begin
         mf := macroFound;
         if mf^.parameters = mPtr^.parameters then begin
            tk1 := mf^.tokens;
            tk2 := mPtr^.tokens;
            while (tk1 <> nil) and (tk2 <> nil) do begin
               if tk1^.token.kind <> tk2^.token.kind then
                  goto 3;
               if tk1^.token.class = tk2^.token.class then
                  case tk1^.token.class of
                     reservedWord, reservedSymbol: ;
                     identifier:
                        if tk1^.token.name^ <> tk2^.token.name^ then
                           goto 3;
                     intConstant:
                        if tk1^.token.ival <> tk2^.token.ival then
                           goto 3;
                     longConstant:
                        if tk1^.token.lval <> tk2^.token.lval then
                           goto 3;
                     doubleConstant:
                        if tk1^.token.rval <> tk2^.token.rval then
                           goto 3;
                     stringConstant: begin
                        if tk1^.token.sval^.length <> tk2^.token.sval^.length
                           then goto 3;
                        for i := 1 to tk1^.token.sval^.length do
                           if tk1^.token.sval^.str[i] <>
                              tk2^.token.sval^.str[i] then
                              goto 3;
                        end;
                     macroParameter:
                        if tk1^.token.pnum <> tk2^.token.pnum then
                           goto 3;
                     otherwise:
                        Error(57);
                     end; {case}
               tk1 := tk1^.next;
               tk2 := tk2^.next;
               end; {while}
            if (tk1 = nil) and (tk2 = nil) then
               goto 2;
            end; {if}
3:       Error(5);
         goto 2;
         end; {if}
                                        {insert the macro in the macro list}
      bPtr := pointer(ord4(macros) + Hash(mPtr^.name));
      mPtr^.next := bPtr^;
      bPtr^ := mPtr;
      end {if}
   else
      Error(9);                         {identifier expected}
2:
   expandMacros := true;                {enable expansions}
   while parameterList <> nil do begin  {dump the parameter names}
      np := parameterList;
      parameterList := np^.next;
      dispose(np);
      end; {while}
   charKinds[ord('#')] := illegal;      {don't allow # as a token}
   saveNumber := false;                 {stop saving numeric strings}
   end; {DoDefine}


   procedure DoElif;
 
   { #elif expression                                            }
 
   var
      ip: ifPtr;                        {temp; for efficiency}

   begin {DoElif}
   ip := ifList;
   if ip <> nil then begin
                                        {decide if we should be skipping}
      tSkipping := ip^.status <> skippingToElse;
      if tSkipping then
         ip^.status := skippingToEndif
      else begin
         {evaluate the condition}
         NumericDirective;              {evaluate the condition}
         if token.kind <> eolsy then    {check for extra stuff on the line}
            Error(11);
         if expressionValue = 0 then
            ip^.status := skippingToElse
         else
            ip^.status := processing;
         tSkipping := ip^.status <> processing; {decide if we should be skipping}
         end; {else}
      end
   else
      Error(20);
   end; {DoElif}


   procedure DoElse;
 
   { #else                                                       }
 
   begin {DoElse}
   NextToken;                            {skip the command name}
   if token.kind <> eolsy then           {check for extra stuff on the line}
      Error(11);
   if ifList <> nil then begin
      if ifList^.elseFound then         {check for multiple elses}
         Error(19)
      else
         ifList^.elseFound := true;
                                        {decide if we should be skipping}
      tSkipping := ifList^.status <> skippingToElse;
      if tSkipping then                 {set the status}
         ifList^.status := skippingToEndif
      else
         ifList^.status := processing;
      end
   else
      Error(20);
   end; {DoElse}


   procedure DoEndif;
 
   { #endif                                                      }
 
   var
      ip: ifPtr;                        {used to create a new if record}
 
   begin {DoEndif}
   if ifList <> nil then begin
      ip := ifList;                     {remove the top if record from the list}
      ifList := ip^.next;
      dispose(ip);
      if ifList = nil then              {decide if we should be skipping}
         tSkipping := false
      else
         tSkipping := ifList^.status <> processing;
      end {if}
   else
      Error(20);
   NextToken;                           {skip the command name}
   if token.kind <> eolsy then          {check for extra stuff on the line}
      if not allowTokensAfterEndif then
         Error(11);
   end; {DoEndif}


   procedure DoError (isError: boolean);
 
   { #error pp-tokens(opt)                                       }
 
   var
      i: integer;                       {loop variable}
      len: integer;                     {string length}
      msg: stringPtr;                   {error message ptr}
      cp: ptr;                          {character pointer}
      lFirstPtr: ptr;                   {local copy of firstPtr}

   begin {DoError}
   lFirstPtr := firstPtr;
   if isError then
      numErrors := numErrors+1;
   new(msg);
   if isError then
      msg^ := '#error:'
   else
      msg^ := '#warning:';
   NextToken;                           {skip the command name}
   while not (token.kind in [eolsy, eofsy]) do begin
      msg^ := concat(msg^, ' ');
      if token.kind = stringConst then begin
         len := token.sval^.length;
         for i := 1 to len do
            msg^ := concat(msg^, token.sval^.str[i]);
         end {if}
      else begin
         len := ord(ord4(tokenEnd) - ord4(tokenStart));
         cp := tokenStart;
         for i := 1 to len do begin
            msg^ := concat(msg^, chr(cp^));
            cp := pointer(ord4(cp)+1);
            end; {for}
         end; {else}
      NextToken;
      end; {while}
   writeln(msg^);
   if isError and terminalErrors then begin
      if enterEditor then
         ExitToEditor(msg, ord4(lFirstPtr)-ord4(bofPtr))
      else
         TermError(0);
      end; {if}
   end; {DoError}


   procedure DoFloat;

   { #pragma float NUMBER NUMBER                                }

   begin {DoFloat}
   FlagPragmas(p_float);
   NextToken;
   if token.kind in [intconst,uintconst] then begin
      floatCard := token.ival;
      NextToken;
      end {if}
   else
      Error(18);
   if token.kind in [intconst,uintconst] then begin
      floatSlot := $C080 | (token.ival << 4);
      NextToken;
      end {if}
   else
      Error(18);
   end; {DoFloat}


   procedure DoKeep;
 
   { #pragma keep FILENAME                                      }

   begin {DoKeep}
   FlagPragmas(p_keep);
   if GetFileName(false) then begin	{read the file name}
      if foundFunction then
         Error(17);
      if liDCBGS.kFlag = 0 then begin	{use the old name if there is one...}
         liDCBGS.kFlag := 1;
         outFileGS.theString.theString := workString;
         outFileGS.theString.size := length(workString);
         end; {if}
      end; {if}
   end; {DoKeep}


   procedure DoNBA;

   { #pragma nba MAIN						}

   begin {DoNBA}
   FlagPragmas(p_nba);
   isNBA := true;
   NextToken;                           {skip the command name}
   if token.kind = ident then begin     {get the open name}
      openName := token.name;
      NextToken;
      end {if}
   else begin
      isNBA := false;
      Error(9);
      end; {else}
   if token.kind <> eolsy then          {make sure there is nothing else on the line}
      Error(11);
   end; {DoNBA}


   procedure DoNDA;

   { #pragma nda OPEN CLOSE ACTION INIT PERIOD EVENTMASK MENULINE}


      function GetInteger: integer;

      { Get a signed integer constant				}

      var
         isNegative: boolean;		{is the value negative?}
         value: integer;		{value to return}

      begin {GetInteger}
      isNegative := false;
      value := 0;
      if token.kind = plusch then
         NextToken
      else if token.kind = minusch then begin
         NextToken;
         isNegative := true;
         end; {else if}
      if token.kind in [intconst,uintconst] then begin
	 value := token.ival;
	 NextToken;
	 end {if}
      else begin
	 isNewDeskAcc := false;
	 Error(18);
	 end; {else}
      if isNegative then
         GetInteger := -value
      else
         GetInteger := value;
      end; {GetInteger}


   begin {DoNDA}
   FlagPragmas(p_nda);
   isNewDeskAcc := true;
   NextToken;                           {skip the command name}
   if token.kind = ident then begin     {get the open name}
      openName := token.name;
      NextToken;
      end {if}
   else begin
      isNewDeskAcc := false;
      Error(9);
      end; {else}
   if token.kind = ident then begin     {get the close name}
      closeName := token.name;
      NextToken;
      end {if}
   else begin
      isNewDeskAcc := false;
      Error(9);
      end; {else}
   if token.kind = ident then begin     {get the action name}
      actionName := token.name;
      NextToken;
      end {if}
   else begin
      isNewDeskAcc := false;
      Error(9);
      end; {else}
   if token.kind = ident then begin     {get the init name}
      initName := token.name;
      NextToken;
      end {if}
   else begin
      isNewDeskAcc := false;
      Error(9);
      end; {else}
   refreshPeriod := GetInteger;		{get the period}
   eventMask := GetInteger;		{get the event Mask}
   if token.kind = stringconst then     {get the name}
      begin
      LongToPString(@menuLine, token.sval);
      NextToken;
      end {if}
   else begin
      isNewDeskAcc := false;
      Error(83);
      end; {else}
   if token.kind <> eolsy then          {make sure there is nothing else on the line}
      Error(11);
   end; {DoNDA}


   procedure DoUndef;
 
   { #undef                                                      }
 
   label 1;
 
   var
      bPtr: ^macroRecordPtr;            {hash bucket pointer}
      mPtr,lastPtr: macroRecordPtr;     {work pointers}
 
   begin {DoUndef}
   expandMacros := false;               {block expansions}
   NextToken;                           {get the token name}
                                        {convert reserved words to identifiers}
   if token.class = reservedWord then begin
      token.name := @reservedWords[token.kind];
      token.kind := ident;
      token.class := identifier;
      end; {if}
   if token.kind = ident then begin
                                        {find the bucket to search}
      bPtr := pointer(ord4(macros)+Hash(token.name));
      lastPtr := nil;                   {find and delete the macro entry}
      mPtr := bPtr^;
      while mPtr <> nil do begin
         if mPtr^.name^ = token.name^ then begin
            if mPtr^.readOnly then
               Error(10)
            else begin
               if lastPtr = nil then
                  bPtr^ := mPtr^.next
               else
                  lastPtr^.next := mPtr^.next;
               end; {else}
            goto 1;
            end; {if}
         lastPtr := mPtr;
         mPtr := mPtr^.next;
         end; {while}
      end {if}
   else
      Error(9);                         {identifier expected}
1:
   expandMacros := true;                {enable expansions}
   NextToken;                           {skip the macro name}
   if token.kind <> eolsy then          {make sure there's no junk on the line}
      Error(11);
   end; {DoUndef}


   procedure DoXCMD;

   { #pragma xcmd MAIN						}

   begin {DoXCMD}
   FlagPragmas(p_xcmd);
   isXCMD := true;
   NextToken;                           {skip the command name}
   if token.kind = ident then begin     {get the open name}
      openName := token.name;
      NextToken;
      end {if}
   else begin
      isXCMD := false;
      Error(9);
      end; {else}
   if token.kind <> eolsy then          {make sure there is nothing else on the line}
      Error(11);
   end; {DoXCMD}


begin {PreProcess}
lPrintMacroExpansions := printMacroExpansions; {inhibit token printing}
printMacroExpansions := false;
lReportEOL := reportEOL;                {we need to see eol's}
reportEOL := true;
tSkipping := skipping;                  {don't skip the directive name!}
skipping := false;
NextCh;                                 {skip the '#' char}
while charKinds[ord(ch)] = ch_white do  {skip white space}
   NextCh;
if ch in ['a','d','e','i','l','p','u','w'] then begin
   NextToken;
   case token.kind of
      ifsy: begin
         if not tSkipping then
            NumericDirective;
         ProcessIf(expressionValue = 0);
         goto 2;
         end;
      elsesy: begin
         DoElse;
         goto 2;
         end;
      ident: begin
         case token.name^[1] of
            'a':
               if token.name^ = 'append' then begin
                  if tskipping then goto 2;
                  DoAppend;
                  goto 2;
                  end; {if}
            'd':
               if token.name^ = 'define' then begin
                  if tskipping then goto 2;
                  DoDefine;
                  goto 2;
                  end; {if}
            'e':
               if token.name^ = 'endif' then begin
                  DoEndif;
                  goto 2;
                  end {if}
               else if token.name^ = 'else' then begin
                  DoElse;
                  goto 2;
                  end {else if}
               else if token.name^ = 'elif' then begin
                  DoElif;
                  goto 2;
                  end {else if}
               else if token.name^ = 'error' then begin
                  if tskipping then goto 2;
                  DoError(true);
                  goto 2;
                  end; {else if}
            'i':
               if token.name^ = 'if' then begin
                  if not tSkipping then
                     NumericDirective;
                  ProcessIf(expressionValue = 0);
                  goto 2;
                  end {if}
               else if token.name^ = 'ifdef' then begin
                  if tSkipping then
                     ProcessIf(false)
                  else
                     ProcessIf(not Defined);
                  goto 2;
                  end {else}
               else if token.name^ = 'ifndef' then begin
                  if tSkipping then
                     ProcessIf(false)
                  else
                     ProcessIf(Defined);
                  goto 2;
                  end {else}
               else if token.name^ = 'include' then begin
                  if tskipping then goto 2;
                  DoInclude(false);
                  goto 2;
                  end; {else}
            'l':
               if token.name^ = 'line' then begin
                  if tskipping then goto 2;
                  FlagPragmas(p_line);
                  NextToken;
                  if token.kind = intconst then begin
                     lineNumber := token.ival;
                     NextToken;
                     end {if}
                  else
                     Error(18);
                  if lineNumber < 0 then
                     lineNumber := 0;
                  if token.kind = stringconst then begin
                     LongToPString(
                        pointer(ord4(@sourceFileGS.theString)+1),
                        token.sval);
                     sourceFileGS.theString.size := token.sval^.length;
                     NextToken;
                     end; {if}
                  if token.kind <> eolsy then
                     Error(11);
                  goto 2;
                  end; {if}
            'p':
               if token.name^ = 'pragma' then begin
                  if tskipping then goto 2;
                  NextToken;
                  if token.name^ = 'keep' then
                     DoKeep
                  else if token.name^ = 'debug' then begin
                     { debug bits:                                 }
                     {     1 - range checking                      }
                     {     2 - create debug code                   }
                     {     4 - generate profiles                   }
                     {     8 - generate traceback code             }
                     {    16 - check for stack errors              }
		     FlagPragmas(p_debug);
                     NumericDirective;
                     val := long(expressionValue).lsw;
                     rangeCheck  := odd(val);
                     debugFlag   := odd(val >> 1);
                     profileFlag := odd(val >> 2);
                     traceBack   := odd(val >> 3);
                     checkStack  := odd(val >> 4);
                     debugStrFlag := odd(val >> 15);
                     profileFlag := profileFlag or debugFlag;
                     if token.kind <> eolsy then
                        Error(11);
                     goto 2;
                     end {else}
                  else if token.name^ = 'lint' then begin
		     FlagPragmas(p_lint);
                     NumericDirective;   
                     lint := long(expressionValue).lsw;
                     if token.kind <> eolsy then
                        Error(11);
                     goto 2;
                     end {else}
                  else if token.name^ = 'memorymodel' then begin
		     FlagPragmas(p_memorymodel);
                     NumericDirective;  
                     smallMemoryModel := expressionValue = 0;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'expand' then begin
		     FlagPragmas(p_expand);
                     NumericDirective;         
                     lPrintMacroExpansions := expressionValue <> 0;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'optimize' then begin
                     { optimize bits:                              }
                     {     1 - intermediate code peephole          }
                     {     2 - native peephole                     }
                     {     4 - register value tracking             }
                     {     8 - remove stack checks                 }
                     {    16 - common subexpression elimination    }
                     {    32 - loop invariant removal		   }
		     FlagPragmas(p_optimize);
                     NumericDirective;    
                     val := long(expressionValue).lsw;
                     peepHole  := odd(val);
                     npeepHole := odd(val >> 1);
                     registers := odd(val >> 2);
                     saveStack := not odd(val >> 3);
                     commonSubexpression := odd(val >> 4);
                     loopOptimizations := odd(val >> 5);
                     strictVararg := not odd(val >> 6);
                     if saveStack then
                        npeepHole := false;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'unix' then begin
                     { unix bits:                                  }
                     {     1 - int is 32 bits			   }
		     FlagPragmas(p_unix);
                     NumericDirective;    
                     val := long(expressionValue).lsw;
                     unix_1 := odd(val);
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'stacksize' then begin
		     FlagPragmas(p_stacksize);
                     NumericDirective;      
                     stackSize := long(expressionValue).lsw;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'cda' then
                     DoCDA
                  else if token.name^ = 'cdev' then
                     DoCDev
                  else if token.name^ = 'nda' then
                     DoNDA
                  else if token.name^ = 'nba' then
                     DoNBA
                  else if token.name^ = 'xcmd' then
                     DoXCMD
                  else if token.name^ = 'toolparms' then begin
		     FlagPragmas(p_toolparms);
                     NumericDirective;       
                     toolParms := expressionValue <> 0;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'databank' then begin
		     FlagPragmas(p_databank);
                     NumericDirective;       
                     dataBank := expressionValue <> 0;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'float' then
                     DoFloat
                  else if token.name^ = 'rtl' then begin
		     FlagPragmas(p_rtl);
                     rtl := true;           
                     NextToken;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'noroot' then begin
		     FlagPragmas(p_noroot);
                     noroot := true;   
                     NextToken;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
{                 else if token.name^ = 'printmacros' then begin {debug}
{                    PrintMacroTable;
                     NextToken;
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'path' then begin
                     NextToken;
		     if token.kind = stringConst then begin
                	LongToPString(workString, token.sval);
                	AddPath(workString);
                        NextToken;
			end {if}
		     else
			Error(83);
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if token.name^ = 'ignore' then begin
                     { ignore bits:                                        }
                     {     1 - don't flag illegal tokens in skipped source }
                     {     2 - allow long int character constants          }
                     {     4 - allow tokens after #endif                   }
                     {     8 - allow // comments                           }
                     FlagPragmas(p_ignore);
                     NumericDirective;    
                     val := long(expressionValue).lsw;
                     skipIllegalTokens := odd(val);
                     allowLongIntChar := odd(val >> 1);
                     allowTokensAfterEndif := odd(val >> 2);
                     allowSlashSlashComments := odd(val >> 3);
                     if token.kind <> eolsy then
                        Error(11);
                     end {else if}
                  else if (lint & lintPragmas) <> 0 then
                     Error(110);
                  goto 2;
                  end; {if}
            'u':
               if token.name^ = 'undef' then begin
                  if tskipping then goto 2;
                  DoUndef;
                  goto 2;
                  end; {if}
            'w':
               if token.name^ = 'warning' then begin
                  if tskipping then goto 2;
                  DoError(false);
                  goto 2;
                  end; {if}
            otherwise: Error(57);
            end; {case}
         end;
      otherwise: ;
      end; {case}
   end {if}
else if charKinds[ord(ch)] = ch_eol     {allow null commands}
   then begin
   NextToken;
   goto 2;
   end; {else if}
if not tSkipping then
   Error(8);                            {bad preprocessor command}
2:
charKinds[ord('#')] := ch_pound;        {allow # as a token}
expandMacros := false;                  {skip to the end of the line}
flagOverflows := false;
skipping := tSkipping;
while not (token.kind in [eolsy,eofsy]) do
   NextToken;
flagOverflows := true;
expandMacros := true;
charKinds[ord('#')] := illegal;         {don't allow # as a token}
reportEOL := lReportEOL;                {restore flags}
printMacroExpansions := lPrintMacroExpansions;
skipping := tskipping;
end; {PreProcess}

{-- Externally available routines ------------------------------}

procedure DoDefaultsDotH;

{ Handle the defaults.h file					}

var
   name: pString;			{name of the default file}

begin {DoDefaultsDotH}
name := defaultName;
if GetFileType(name) <> -1 then
   DoInclude(true);
end; {DoDefaultsDotH}


procedure Error {err: integer};

{ flag an error                                                 }
{                                                               }
{ err - error number                                            }

begin {Error}
if numErr = maxErr then                 {set the error number}
   errors[maxErr].num := 4
else begin
   numErr := numErr+1;
   numErrors := numErrors+1;
   liDCBGS.merrf := 16;
   errors[numErr].num := err;
   end; {else}
with errors[numErr] do begin            {record the position of the error}
   line := tokenLine;
   col := tokenColumn;
   end; {with}
codeGeneration := false;		{inhibit code generation}
end; {Error}


{procedure Error2 {loc, err: integer} {debug}

{ flag an error                                                 }
{                                                               }
{ loc - error location                                          }
{ err - error number                                            }

{begin {Error2}
{writeln('Error ', err:1, ' flagged at location ', loc:1);
Error(err);
end; {Error2}


procedure DoNumber {scanWork: boolean};

{  The current character starts a number - scan it            }
{                                                             }
{  Parameters:                                                }
{     scanWork - get characters from workString?              }
{                                                             }
{  Globals:                                                   }
{     ch - first character in sequence; set to first char     }
{             after sequence                                  }
{     workString - string to take numbers from                }

label 1;

var
   c2: char;                            {next character to process}
   i: integer;                          {loop index}
   isBin: boolean;                      {is the value a binary number?}
   isHex: boolean;                      {is the value a hex number?}
   isLong: boolean;                     {is the value a long number?}
   isReal: boolean;                     {is the value a real number?}
   numIndex: 0..maxLine;                {index into workString}
   sp: stringPtr;                       {for saving identifier names}
   stringIndex: 0..maxLine;             {length of the number string}
   unsigned: boolean;                   {is the number unsigned?}
   val: integer;                        {value of a digit}

   numString: pString;                  {characters in the number}


   procedure NextChar;

   {  Return the next character that is a part of the number    }

   begin {NextChar}
   if scanWork then begin
      if ord(workString[0]) <> numIndex then begin
         numIndex := numIndex+1;
         c2 := workString[numIndex];
         end {if}
      else
         c2 := ' ';
      end {if}
   else begin
      NextCh;
      c2 := ch;
      end; {else}
   end; {NextChar}


   procedure FlagError (errCode: integer);

   {  Handle an error when processing a number.  Don't report   }
   {  errors when skipping code, because pp-numbers in skipped  }
   {  code never actually get converted to numeric constants.   }
   
   begin {FlagError}
      if not skipping then
         Error(errCode);
   end; {FlagError}


   procedure GetDigits;

   {  Read in a digit stream                                    }
   {                                                            }
   {  Variables:                                                }
   {     c2 - next character to process                         }
   {     numString - digit sequence added to this string        }
   {     stringIndex - length of the string                     }

   begin {GetDigits}
   while (charKinds[ord(c2)] = digit) or
      (isHex and (c2 in ['a'..'f','A'..'F'])) do begin
      if c2 in ['a'..'f'] then
         c2 := chr(ord(c2) & $5F);
      stringIndex := stringIndex+1;
      if stringIndex > 255 then begin
         FlagError(6);
         stringIndex := 1;
         end; {if}
      numString[stringIndex] := c2;
      NextChar;
      end; {while}
   end; {GetDigits}


begin {DoNumber}
isBin := false;                         {assume it's not binary}
isHex := false;                         {assume it's not hex}
isReal := false;                        {assume it's an integer}
isLong := false;                        {assume a short integer}
unsigned := false;                      {assume signed numbers}
stringIndex := 0;                       {no digits so far...}
if scanWork then begin                  {set up the scanner}
   numIndex := 0;
   NextChar;
   end {if}
else
   c2 := ch;
if c2 = '.' then begin                  {handle the case of no leading digits}
   stringIndex := 1;
   numString[1] := '0';
   end {if}
else begin
   GetDigits;                           {read the leading digit stream}
   if c2 in ['x','X','b','B'] then      {detect hex numbers}
      if stringIndex = 1 then
         if numString[1] = '0' then begin
            stringIndex := 2;
            c2 := chr(ord(c2) & $5f);
            numString[2] := c2;
            if c2 = 'X' then isHex := true;
            if c2 = 'B' then isBin := true;
            NextChar;
            GetDigits;
            goto 1;
            end; {if}
   end;
if c2 = '.' then begin                  {handle a decimal}
   stringIndex := stringIndex+1;
   numString[stringIndex] := '.';
   NextChar;
   isReal := true;
   if charKinds[ord(c2)] = digit then
      GetDigits
   else if stringIndex = 2 then begin
      numString[3] := '0';
      stringIndex := 3;
      end; {else}
   end; {if}
if c2 in ['e','E'] then begin           {handle an exponent}
   stringIndex := stringIndex+1;
   numString[stringIndex] := 'e';
   NextChar;
   isReal := true;
   if c2 in ['+','-'] then begin
      stringIndex := stringIndex+1;
      numString[stringIndex] := c2;
      NextChar;
      end; {if}
   if c2 in ['0'..'9'] then
      GetDigits
   else begin
      stringIndex := stringIndex+1;
      numString[stringIndex] := '0';
      FlagError(101);
      end; {else}
   end; {if}
1:
while c2 in ['l','u','L','U'] do        {check for long or unsigned}
   if c2 in ['l','L'] then begin
      NextChar;
      if not isReal then
         isLong := true;
      end {if}
   else {if c2 in ['u','U'] then} begin
      NextChar;
      unsigned := true;
      if isReal then
         FlagError(91);
      end; {else}
if c2 in ['f','F'] then begin           {allow F designator on reals}
   if unsigned then
      FlagError(91);
   if not isReal then begin
      FlagError(100);
      isReal := true;
      end; {if}
   NextChar;
   end; {if}
numString[0] := chr(stringIndex);       {set the length of the string}
if isReal then begin                    {convert a real constant}
   token.kind := doubleConst;
   token.class := doubleConstant;
   if stringIndex > 80 then begin
      FlagError(6);
      token.rval := 0.0;
      end {if}
   else
      token.rval := cnvsd(numString);
   end {if}
else if numString[1] <> '0' then begin {convert a decimal integer}
   if (stringIndex > 5)
      or (not unsigned and (stringIndex = 5) and (numString > '32767'))
      or (unsigned and (stringIndex = 5) and (numString > '65535')) then
      isLong := true;
   if (stringIndex > 10) or
      ((stringIndex = 10) and (numString > '4294967295')) then begin
      numString := '0';
      if flagOverflows then
         FlagError(6);
      end; {if}
   if isLong then begin
      token.class := longConstant;
      token.lval := Convertsl(numString);
      if unsigned then
         token.kind := ulongConst
      else begin
         token.kind := longConst;
         if token.lval < 0 then
            token.kind := ulongConst;
         end; {else}
      end {if}
   else begin
      if unsigned then
         token.kind := uintConst
      else
         token.kind := intConst;
      token.class := intConstant;
      token.lval := Convertsl(numString);
      end; {else}
   end {else if}
else begin                            {hex & octal}
   token.lval := 0;
   if isHex then begin
      i := 3;
      while i <= length(numString) do begin
         if token.lval & $F0000000 <> 0 then begin
            i := maxint;
            if flagOverflows then
               FlagError(6);
            end {if}
         else begin
            if numString[i] > '9' then
               val := (ord(numString[i])-7) & $000F
            else
               val := ord(numString[i]) & $000F;
            token.lval := (token.lval << 4) | val;
            i := i+1;
            end; {else}
         end; {while}
      end {if}
   else if isBin then begin
      i := 3;
      while i <= length(numString) do begin
         if token.lval & $80000000 <> 0 then begin
            i := maxint;
            if flagOverflows then
               FlagError(6);
            end {if}
         else begin
            if not (numString[i] in ['0','1']) then
               FlagError(121);
            token.lval := (token.lval << 1) | (ord(numString[i]) & $0001);
            i := i+1;
            end; {else}
         end; {while}
      end {if}
   else begin
      i := 1;
      while i <= length(numString) do begin
         if token.lval & $E0000000 <> 0 then begin
            i := maxint;
            if flagOverflows then
               FlagError(6);
            end {if}
         else begin
            if numString[i] in ['8','9'] then
               FlagError(7);
            token.lval := (token.lval << 3) | (ord(numString[i]) & $0007);
            i := i+1;
            end; {else}
         end; {while}
      end; {else}
   if long(token.lval).msw <> 0 then
      isLong := true;
   if isLong then begin
      if unsigned then
         token.kind := ulongConst
      else
         token.kind := longConst;
      token.class := longConstant;
      end {if}
   else begin
      if (long(token.lval).lsw & $8000) <> 0 then
         unsigned := true;
      if unsigned then
         token.kind := uintConst
      else
         token.kind := intConst;
      token.class := intConstant;
      end; {else}
   end; {else}
if saveNumber then begin
   sp := pointer(GMalloc(length(numString)+1));
   CopyString(pointer(sp), @numString);
   token.numString := sp;
   end; {if}
if scanWork then                        {make sure we read all characters}
   if ord(workString[0]) <> numIndex then
      Error(63);
end; {DoNumber}


procedure InitScanner {start, end: ptr};

{ initialize the scanner                                        }
{                                                               }
{ start - pointer to the first character in the file            }
{ end - points one byte past the last character in the file     }

var
   chi: minChar..maxChar;               {loop variable}
   lch: char;                           {next command line character}
   cp: ptr;                             {character pointer}
   i: 0..hashSize;                      {loop variable}
   negative: boolean;                   {is a number nagative?}

   mp: macroRecordPtr;                  {for building the predefined macros}
   bp: ^macroRecordPtr;

   timeString: packed array[1..20] of char; {time from misc. tools}


   procedure NextCh;

   { Get the next character from the command line               }

   begin {NextCh}
   lch := chr(cp^);
   cp := pointer(ord4(cp)+1);
   tokenColumn := tokenColumn+1;
   if tokenColumn > infoStringGS.theString.size then
      lch := chr(0);
   end; {NextCh}


   function GetWord: stringPtr;

   { Read a word from the command line                          }

   var
      i: integer;                       {string index}
      sp: stringPtr;                    {string pointer}

   begin {GetWord}
   i := 0;
   while not (lch in [' ', chr(0), chr(9), '=']) do begin
      i := i+1;
      workString[i] := lch;
      NextCh;
      end; {while}
   workString[0] := chr(i);
   sp := pointer(malloc(length(workString)+1));
   CopyString(pointer(sp), @workString);
   GetWord := sp;
   end; {GetWord}


   function EscapeCh: integer;

   {  Find and return the next character in a string or char     }
   {  constant.  Handle escape sequences if they are found.      }
   {  (The character is returned as an ordinal value.)           }
   {                                                             }
   {  Globals:                                                   }
   {     lch - first character in sequence; set to first char    }
   {             after sequence                                  }
 
   label 1;
 
   var
      cnt: 0..3;                        {for counting octal escape sequences}
      dig: 0..15;                       {value of a hex digit}
      skipChar: boolean;                {get next char when done?}
      val: 0..4095;                     {hex escape code value (scaled to 0..255)}

   begin {EscapeCh}
1: skipChar := true;
   if lch = '\' then begin
      NextCh;
      if lch in ['0'..'7','a','b','t','n','v','f','p','r','x'] then
         case lch of
            '0','1','2','3','4','5','6','7': begin
               val := 0;
               cnt := 0;
               while (cnt < 3) and (lch in ['0'..'7']) do begin
                  val := (val << 3) | (ord(lch) & 7);
                  cnt := cnt+1;
                  NextCh;
                  end; {while}
               EscapeCh := val & $FF;
               skipChar := false;
               end;
            'a': EscapeCh := 7;
            'b': EscapeCh := 8;
            't': EscapeCh := 9;
            'n': EscapeCh := 10;
            'v': EscapeCh := 11;
            'f': EscapeCh := 12;
            'p': begin
               EscapeCh := ord('p');
               ispstring := true;
               end;
            'r': EscapeCh := 13;
            'x': begin
               val := 0;
               NextCh;
               while lch in ['0'..'9','a'..'f','A'..'F'] do begin
                  if lch in ['0'..'9'] then
                     dig := ord(lch) & $0F
                  else begin
                     lch := chr(ord(lch)&$5F);
                     dig := ord(lch)-ord('A')+10;
                     end; {else}
                  val := (val << 4) | dig;
                  NextCh;
                  end; {while}
               skipChar := false;
               EscapeCh := val & $FF;
               end;
            otherwise: Error(57);
            end {case}
      else
         EscapeCh := ord(lch);
      end {if}
   else
      EscapeCh := ord(lch);
   if skipChar then
      NextCh;
   end; {EscapeCh}


   procedure GetString;

   { read a string token from the command line                  }

   var
      i: integer;                       {string length}
      setLength: boolean;               {is the current string a p-string?}
      sPtr: longstringPtr;              {work string pointer}

   begin {GetString}
   token.kind := stringconst;           {set up the token}
   token.class := stringConstant;
   i := 0;                              {set up for the string scan}
   ispstring := false;
   setLength := false;
   new(sPtr);
   NextCh;                              {skip the opening "}
                                        {read the characters}
   while not (charKinds[ord(lch)] in [ch_string,ch_eol,ch_eof]) do begin
      i := i+1;
      if i = longstringlen then begin
         i := 1001;
         Error(90);
         end; {if}
      sPtr^.str[i] := chr(EscapeCh);
      if (i = 1) and ispstring then
         setLength := true;
      end; {while}
   if lch = '"' then                    {process the end of the string}
      NextCh
   else
      Error(3);
   if setLength then                    {check for a p-string}
      sPtr^.str[1] := chr(i-1);
   token.ispstring := setLength;
   sPtr^.length := i;                   {set the string length}
   token.sval := pointer(Malloc(i+3));  {put the string in the string pool}
   CopyLongString(token.sval, pointer(sPtr));
   dispose(sPtr);
   token.sval^.str[i+1] := chr(0);      {add null in case the string is extended}
   end; {GetString}


begin {InitScanner}
printMacroExpansions := false;          {don't print the token list}
skipIllegalTokens := false;		{flag illegal tokens in skipped code}
allowLongIntChar := false;		{allow long int char constants}
allowTokensAfterEndif := false;         {allow tokens after #endif}
allowSlashSlashComments := true;		{allow // comments}
foundFunction := false;                 {no functions found so far}
fileList := nil;                        {no included files}
gettingFileName := false;               {not in GetFileName}
ifList := nil;                          {no conditional comp. records}
skipping := false;                      {not skipping tokens}
flagOverflows := true;                  {flag overflow errors?}
new(macros);                            {no preprocessor macros so far}
for i := 0 to hashSize do
   macros^[i] := nil;
pathList := nil;			{no additional search paths}
charKinds[ord('#')] := illegal;         {don't allow # as a token}
tokenList := nil;                       {nothing in putback buffer}
saveNumber := false;                    {don't save numbers}
expandMacros := true;                   {enable macro expansion}
reportEOL := false;                     {report eolsy as a token?}
lineNumber := 1;                        {start the line counter}
chPtr := start;                         {set the start, end pointers}
eofPtr := endPtr;
firstPtr := start;                      {first char in line}
numErr := 0;                            {no errors so far}
numErrors := 0;
includeCount := 0;			{no pending calls to EndInclude}
lint := 0;                              {turn off lint checks}
ch := chr(RETURN);                      {set the initial character}
needWriteLine := false;                 {no lines are pending}
switchLanguages := false;               {not switching languages}
lastWasReturn := false;                 {last char was not return}
doingstring := false;                   {not doing a string}
doingPPExpression := false;             {not doing a preprocessor expression}
unix_1 := false;			{int is 16 bits}

new(mp);                                {__LINE__}
mp^.name := @'__LINE__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 1;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__FILE__}
mp^.name := @'__FILE__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 2;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__DATE__}
mp^.name := @'__DATE__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 3;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__TIME__}
mp^.name := @'__TIME__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 4;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__STDC__}
mp^.name := @'__STDC__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 5;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__ORCAC__}
mp^.name := @'__ORCAC__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 5;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
new(mp);                                {__VERSION__}
mp^.name := @'__VERSION__';
mp^.parameters := -1;
mp^.tokens := nil;
mp^.readOnly := true;
mp^.algorithm := 6;
bp := pointer(ord4(macros) + hash(mp^.name));
mp^.next := bp^;
bp^ := mp;
SetDateTime;                            {set up the macro date/time strings}
					{set up the version string}
versionStrL := pointer(GMalloc(3 + length(versionStr)));
versionStrL^.length := length(versionStr);
versionStrL^.str := versionStr;

{Scan the command line options}
cp := @infoStringGS.theString.theString;
tokenLine := 0;
tokenColumn := 0;
NextCh;
repeat
   while lch in [' ', chr(9)] do        {skip leading blanks}
      NextCh;
   if lch = '-' then begin              {see if we have found one}
      NextCh;
      if lch in ['d','D'] then begin
         NextCh;                        {yes -> get the name}
         new(mp);                       {form the macro table entry}
         mp^.name := GetWord;
         mp^.parameters := -1;
         mp^.tokens := nil;
         mp^.readOnly := false;
         bp := pointer(ord4(macros) + hash(mp^.name));
         mp^.next := bp^;
         bp^ := mp;
         if lch = '=' then begin
            NextCh;                     {record the value}
            token.numString := nil;
            if lch in ['a'..'z', 'A'..'Z', '_'] then begin
               token.kind := ident;
               token.class := identifier;
               token.name := GetWord;
               token.symbolPtr := nil;
               end {if}
            else if lch in ['+','-'] then begin
               negative := lch = '-';
               NextCh;
               if lch in ['.','0'..'9'] then begin
                  token.name := GetWord;
                  DoNumber(true);
                  if negative then
                     case token.class of
                        intConstant   : token.ival := -token.ival;
                        longConstant  : token.lval := -token.lval;
                        doubleConstant: token.rval := -token.rval;
                        otherwise: ;
                        end; {case}
                  end {if}
               else begin
                  token.kind := intconst;
                  token.numString := nil;
                  token.class := intConstant;
                  token.ival := 0;
                  end; {else}
               end {else if}
            else if lch in ['.','0'..'9'] then begin
               token.name := GetWord;
               DoNumber(true);
               end {else if}
            else if lch = '"' then 
               GetString
            else
               Error(108);
            end {if}
         else begin
            token.kind := intconst;     {create the default value}
            token.numString := nil;
            token.class := intConstant;
            token.ival := 1;
            end; {else}
         new(mp^.tokens);               {add the value to the definition}
         with mp^.tokens^ do begin
            next := nil;
            tokenString := nil;
            expandEnabled := true;
            tokenStart := nil;
            tokenEnd := nil;
            end; {with}
         mp^.tokens^.token := token;
         end {if}
      else if lch in ['i','I'] then begin
         NextCh;                        {gat the pathname}
         if lch = '"' then begin
            GetString;
            LongToPString(workString, token.sval);
            AddPath(workString);
            end {if}
         else
            Error(103);
         end {if}
      else                              {not -p, -i: flag the error}
         Error(108);
      end {if}
   else if lch <> chr(0) then begin
      Error(108);                       {unknown option: flag the error}
      lch := chr(0);
      end; {else}
until lch = chr(0);                     {if more characters, loop}
end; {InitScanner}


procedure CheckIdentifier;

{ See if an identifier is a reserved word, macro or typedef     }

label 1;

var
   bPtr: ^macroRecordPtr;               {pointer to hash bucket}
   mPtr: macroRecordPtr;                {for checking list of macros}
   rword: tokenEnum;                    {loop variable}
   sp: stringPtr;                       {for saving identifier names}
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}

begin {CheckIdentifier}
if expandMacros then                    {handle macro expansions}
   if not skipping then begin
      mPtr := FindMacro(@workstring);
      if mPtr <> nil then begin
         Expand(mPtr);
         lPrintMacroExpansions := printMacroExpansions;
         printMacroExpansions := false;
         NextToken;
         printMacroExpansions := lPrintMacroExpansions;
         goto 1;
         end;
      end; {if}
                                        {see if it's a reserved word}
if workString[1] in ['a'..'g','i','l','p','r'..'w'] then
   for rword := wordHash[ord(workString[1])-ord('a')] to
      pred(wordHash[ord(succ(workString[1]))-ord('a')]) do
      if reservedWords[rword] = workString then begin
         token.kind := rword;
         token.class := reservedWord;
         goto 1;
         end; {if}
token.symbolPtr := nil;                 {see if it's a typedef name}
if FindSymbol(token,allSpaces,false,false) <> nil then begin
   if token.symbolPtr^.class = typedefsy then
      token.kind := typedef;
   token.name := token.symbolPtr^.name; {use the old name}
   end {if}
else begin                              {record the name}
   sp := pointer(Malloc(length(workString)+1));
   CopyString(pointer(sp), @workString);
   token.name := sp;
   end; {else}
1:
end; {CheckIdentifier}


procedure NextToken;

{ Read the next token from the file.                            }

label 1,2,3,4;

type
   three = (s100,s1000,s4000);          {these declarations are used for a}
   gstringPtr = ^gstringRecord;         { variable length string record   }
   gstringRecord = record
      case three of
          s100: (len1: integer;
                 str1: packed array[1..100] of char;
                 );
         s1000: (len2: integer;
                 str2: packed array[1..1000] of char;
                 );
         s4000: (len3: integer;
                 str3: packed array[1..longstringlen] of char;
                 );
      end;

var
   done: boolean;                       {loop termination}
   expandEnabled: boolean;              {can a token be expanded?}
   i: 0..maxint;                        {loop/index counter}
   inhibit: boolean;                    {inhibit macro expansion?}
   lExpandMacros: boolean;              {local copy of expandMacros}
   lPrintMacroExpansions: boolean;      {local copy of printMacroExpansions}
   mPtr: macroRecordPtr;                {for checking list of macros}
   setLength: boolean;                  {is the current string a p-string?}
   tPtr: tokenListRecordPtr;            {for removing tokens from putback buffer}
   tToken: tokenType;                   {for merging tokens}
   sPtr,tsPtr: gstringPtr;              {for forming string constants}


   function EscapeCh: integer;
 
   {  Find and return the next character in a string or char     }
   {  constant.  Handle escape sequences if they are found.      }
   {  (The character is returned as an ordinal value.)           }
   {                                                             }
   {  Globals:                                                   }
   {     ch - first character in sequence; set to first char     }
   {             after sequence                                  }
 
   label 1;
 
   var
      cnt: 0..3;                        {for counting octal escape sequences}
      dig: 0..15;                       {value of a hex digit}
      skipChar: boolean;                {get next char when done?}
      val: 0..4095;                     {hex escape code value (scaled to 0..255)}

   begin {EscapeCh}
1: skipChar := true;
   if ch = '\' then begin
      NextCh;
      if ch in ['0'..'7','a','b','t','n','v','f','p','r','x'] then
         case ch of
            '0','1','2','3','4','5','6','7': begin
               val := 0;
               cnt := 0;
               while (cnt < 3) and (ch in ['0'..'7']) do begin
                  val := (val << 3) | (ord(ch) & 7);
                  cnt := cnt+1;
                  NextCh;
                  end; {while}
               EscapeCh := val & $FF;
               skipChar := false;
               end;
            'a': EscapeCh := 7;
            'b': EscapeCh := 8;
            't': EscapeCh := 9;
            'n': EscapeCh := 10;
            'v': EscapeCh := 11;
            'f': EscapeCh := 12;
            'p': begin
               EscapeCh := ord('p');
               ispstring := true;
               end;
            'r': EscapeCh := 13;
            'x': begin
               val := 0;
               NextCh;
               while ch in ['0'..'9','a'..'f','A'..'F'] do begin
                  if ch in ['0'..'9'] then
                     dig := ord(ch) & $0F
                  else begin
                     ch := chr(ord(ch)&$5F);
                     dig := ord(ch)-ord('A')+10;
                     end; {else}
                  val := (val << 4) | dig;
                  NextCh;
                  end; {while}
               skipChar := false;
               EscapeCh := val & $FF;
               end;
            otherwise: Error(57);
            end {case}
      else
         EscapeCh := ord(ch);
      end {if}
   else
      EscapeCh := ord(ch);
   if skipChar then
      NextCh;
   end; {EscapeCh}



   procedure CharConstant;
   
   { Scan a single-quote character constant			}
   
   var
      cnt: integer;			{number of characters scanned}
      result: longint;			{character value}
   
   begin {CharConstant}
   
   {set up locals}
   cnt := 0;
   result := 0;
      
   {skip the leading quote}
   NextCh;
   
   {read the characters in the constant}
   while (not (charKinds[ord(ch)] in [ch_char,ch_eol,ch_eof])) do begin
      if cnt < maxint then
         cnt := cnt + 1;
      result := (result << 8) | EscapeCh;
      end; {while}
   
   {skip the closing quote}
   if (charKinds[ord(ch)] = ch_char) then begin
      if (cnt = 0) and ((not skipping) or (not skipIllegalTokens)) then
         Error(2);
      NextCh;
      end {if}
   else if (not skipping) or (not skipIllegalTokens) then
      Error(2);
   
   {create the token}
   if allowLongIntChar and (cnt >= 3) then begin
      token.kind := longconst;
      token.class := longConstant;
      token.lval := result;
      end {if}
   else begin
      token.kind := intconst;
      token.class := intConstant;
      token.ival := long(result).lsw;
      end {else}
   end; {CharConstant}


begin {NextToken}
if ifList = nil then			{do pending EndInclude calls}
   while includeCount <> 0 do begin
      EndInclude(includeChPtr);
      includeCount := includeCount - 1;
      end; {while}
includeChPtr := chPtr;
3:
token.numstring := nil;			{wipe out old numstrings}
if tokenList <> nil then begin          {get a token put back by a macro}
   tPtr := tokenList;
   tokenList := tPtr^.next;
   expandEnabled := tPtr^.expandEnabled;
   tokenExpandEnabled := expandEnabled;
   token := tPtr^.token;
   tokenStart := tPtr^.tokenStart;
   tokenEnd := tPtr^.tokenEnd;
   dispose(tPtr);
   if token.kind = typedef then         {allow for typedefs in a macro}
      token.kind := ident;
   if token.kind = ident then begin
      CopyString(@workString, token.name);
      lExpandMacros := expandMacros;
      expandMacros := false;
      CheckIdentifier;
      expandMacros := lExpandMacros;
      end; {if}
{ dead code
   if token.kind = ident then
      if FindSymbol(token,allSpaces,false,false) <> nil then
         if token.symbolPtr^.class = typedefsy then
            token.kind := typedef;
}
4:
   while (token.kind = stringconst)
      and (tokenList <> nil)
      and (tokenList^.token.kind = stringconst) do begin
      Merge(token, tokenList^.token);
      tPtr := tokenList;
      tokenList := tPtr^.next;
      dispose(tPtr);
      end; {while}
   if expandMacros and expandEnabled and (not skipping) then
      if token.kind = ident then begin  {handle macro expansions}
         inhibit := false;
         if tokenList <> nil then
            if tokenList^.token.kind = poundpoundop then
               inhibit := true;
         if not inhibit then begin
            mPtr := FindMacro(token.name);
            if mPtr <> nil then begin
               Expand(mPtr);
               goto 3;
               end; {if}
            end; {if}
         end; {if}
   if tokenList <> nil then
      if tokenList^.token.kind = poundpoundop then begin
         tPtr := tokenList;
         tokenList := tPtr^.next;
         dispose(tPtr);
         if tokenList <> nil then begin
            tPtr := tokenList;
            tToken := token;
            Merge(tToken, tPtr^.token);
            tokenList := tPtr^.next;
            token := tToken;
            tokenExpandEnabled := true;
            dispose(tPtr);
            goto 4;
            end; {if}
         end; {if}
   goto 2;
   end; {if}
                                        {skip white space}
while charKinds[ord(ch)] in [illegal,ch_white,ch_eol] do begin
   if charKinds[ord(ch)] = illegal then begin
      if (ch = '#') and (lastWasReturn or (token.kind = eolsy)) then
         PreProcess                     {call the preprocessor}
      else begin
         tokenLine := lineNumber;       {record a # token}
         tokenColumn := ord(ord4(chPtr)-ord4(firstPtr));
         tokenStart := pointer(ord4(chPtr)-1);
         tokenEnd := chPtr;
         if (not skipping) or (not (skipIllegalTokens or (ch = '#'))) then
            Error(1);
         NextCh;
         end; {else}
      end {if}
   else if (charKinds[ord(ch)] = ch_eol) and reportEOL then begin
      token.class := reservedSymbol;    {record an eol token}
      token.kind := eolsy;
      tokenLine := lineNumber;
      tokenColumn := ord(ord4(chPtr)-ord4(firstPtr));
      tokenStart := pointer(ord4(chPtr)-1);
      tokenEnd := chPtr;
      NextCh;
      goto 2;
      end {if}
   else begin                           {skip white space}
      if printMacroExpansions then
         if charKinds[ord(ch)] = ch_eol then
            writeln
         else
            write(ch);
      NextCh;
      end;
   end; {while}
tokenLine := lineNumber;                {record the position of the token}
tokenColumn := ord(ord4(chPtr)-ord4(firstPtr));
tokenStart := pointer(ord4(chPtr)-1);
token.class := reservedSymbol;          {default to the most common class}
case charKinds[ord(ch)] of

   ch_special  : begin
      token.kind := charSym[ord(ch)];
      NextCh;
      end;

   ch_eof:                              {end of file}
      token.kind := eofsy;

   ch_pound : begin                     {tokens that start with '#'}
      NextCh;
      if ch = '#' then begin
         token.kind := poundpoundop;
         NextCh;
         end
      else
         token.kind := poundch;
      end;

   ch_dash  : begin                     {tokens that start with '-'}
      NextCh;
      if ch = '>' then begin
         token.kind := minusgtop;
         NextCh;
         end
      else if ch = '-' then begin
         token.kind := minusminusop;
         NextCh;
         end
      else if ch = '=' then begin
         token.kind := minuseqop;
         NextCh;
         end
      else
         token.kind := minusch;
      end;

   ch_plus  : begin                     {tokens that start with '+'}
      NextCh;
      if ch = '+' then begin
         token.kind := plusplusop;
         NextCh;
         end
      else if ch = '=' then begin
         token.kind := pluseqop;
         NextCh;
         end
      else
         token.kind := plusch;
      end;

   ch_lt    : begin                     {tokens that start with '<'}
      NextCh;
      if ch = '<' then begin
         NextCh;
         if ch = '=' then begin
            token.kind := ltlteqop;
            NextCh;
            end
         else
            token.kind := ltltop;
         end
      else if ch = '=' then begin
         token.kind := lteqop;
         NextCh;
         end
      else
         token.kind := ltch;
      end;

   ch_gt    : begin                     {tokens that start with '>'}
      NextCh;
      if ch = '>' then begin
         NextCh;
         if ch = '=' then begin
            token.kind := gtgteqop;
            NextCh;
            end
         else
            token.kind := gtgtop;
         end
      else if ch = '=' then begin
         token.kind := gteqop;
         NextCh;
         end
      else
         token.kind := gtch;
      end;

   ch_eq    : begin                     {tokens that start with '='}
      NextCh;
      if ch = '=' then begin
         token.kind := eqeqop;
         NextCh;
         end
      else
         token.kind := eqch;
      end;

   ch_exc   : begin                     {tokens that start with '!'}
      NextCh;
      if ch = '=' then begin
         token.kind := exceqop;
         NextCh;
         end
      else
         token.kind := excch;
      end;

   ch_and   : begin                     {tokens that start with '&'}
      NextCh;
      if ch = '&' then begin
         token.kind := andandop;
         NextCh;
         end
      else if ch = '=' then begin
         token.kind := andeqop;
         NextCh;
         end
      else
         token.kind := andch;
      end;

   ch_bar   : begin                     {tokens that start with '|'}
      NextCh;
      if ch = '|' then begin
         token.kind := barbarop;
         NextCh;
         end
      else if ch = '=' then begin
         token.kind := bareqop;
         NextCh;
         end
      else
         token.kind := barch;
      end;

   ch_percent: begin                      {tokens that start with '%'}
      NextCh;
      if ch = '=' then begin
         token.kind := percenteqop;
         NextCh;
         end
      else
         token.kind := percentch;
      end;

   ch_carot : begin                     {tokens that start with '^'}
      NextCh;
      if ch = '=' then begin
         token.kind := caroteqop;
         NextCh;
         end
      else
         token.kind := carotch;
      end;

   ch_asterisk: begin                   {tokens that start with '*'}
      NextCh;
      if ch = '=' then begin
         token.kind := asteriskeqop;
         NextCh;
         end
      else
         token.kind := asteriskch;
      end;

   ch_slash : begin                     {tokens that start with '/'}
      NextCh;
      if ch = '=' then begin
         token.kind := slasheqop;
         NextCh;
         end
      else
         token.kind := slashch;
      end;

   ch_dot   : begin                     {tokens that start with '.'}
      if charKinds[chPtr^] = digit then
         DoNumber(false)
      else begin
         NextCh;
         token.kind := dotch;
         end; {else}
      end;

   ch_char  : CharConstant;		{character constants}

   ch_string: begin                     {string constants}
      doingstring := true;              {change character scanning}
      token.kind := stringconst;        {set up the token}
      token.class := stringConstant;
      i := 0;                           {set up for the string scan}
      ispstring := false;
      setLength := false;
      new(sPtr,s100);
      NextCh;                           {skip the opening "}
                                        {read the characters}
      while not (charKinds[ord(ch)] in [ch_string,ch_eol,ch_eof]) do begin
         i := i+1;
         if i = 101 then begin
            sPtr^.len1 := 100;
            new(tsPtr,s1000);
            CopyLongString(pointer(tsPtr), pointer(sPtr));
            dispose(sPtr);
            sPtr := tsPtr;
            end {if}
         else if i = 1001 then begin
            sPtr^.len2 := 1000;
            new(tsPtr,s4000);
            CopyLongString(pointer(tsPtr), pointer(sPtr));
            dispose(sPtr);
            sPtr := tsPtr;
            end {else if}
         else if i = longstringlen then begin
            i := 1001;
            Error(90);
            end; {else if}
         sPtr^.str1[i] := chr(EscapeCh);
         if (i = 1) and ispstring then
            setLength := true;
         end; {while}
      doingstring := false;             {process the end of the string}
      if ch = '"' then
         NextCh
      else
         Error(3);
      if setLength then                 {check for a p-string}
         sPtr^.str1[1] := chr(i-1);
      token.ispstring := setLength;
      sPtr^.len1 := i;                  {set the string length}
      token.sval := pointer(Malloc(i+3)); {put the string in the string pool}
      CopyLongString(token.sval, pointer(sPtr));
      dispose(sPtr);
      doingstring := false;
      token.sval^.str[i+1] := chr(0);   {add null in case the string is extended}
      end;

   letter: begin                         {reserved words and identifiers}
      token.kind := ident;
      token.class := identifier;
      token.name := @workString;
      tokenExpandEnabled := true;
      i := 0;
      while charKinds[ord(ch)] in [letter,digit] do begin
         i := i+1;
         workString[i] := ch;
         NextCh;
         end; {while}
      workString[0] := chr(i);
      CheckIdentifier;
      end;

   digit :                               {numeric constants}
      DoNumber(false);

   otherwise: Error(57);
   end; {case}
tokenEnd := pointer(ord4(chPtr)-1);     {record the end of the token}
2:
if skipping then                        {conditional compilation branch}
   if not (token.kind in [eofsy,eolsy]) then
      goto 3;
if token.kind = stringconst then        {handle adjacent strings}
   repeat
      if reportEOL then begin
         while charKinds[ord(ch)] = ch_white do
            NextCh;
         if charKinds[ord(ch)] = ch_eol then
            goto 1;
         end; {if}
      tToken := token;
      lPrintMacroExpansions := printMacroExpansions;
      printMacroExpansions := false;
      NextToken;
      printMacroExpansions := lPrintMacroExpansions;
      if token.kind = stringconst then begin
         Merge(tToken, token);
         done := false;
         end {if}
      else begin
         PutBackToken(token, tokenExpandEnabled);
         done := true;
         end; {else}
      token := tToken;
   until done;
1:
if doingPPExpression then begin
   if token.class = reservedWord then begin
      token.name := @reservedWords[token.kind];
      token.kind := ident;
      token.class := identifier;
      end; {if}
   if token.kind = typedef then
      token.kind := ident;
   end; {if}
if printMacroExpansions then		{print the token stream}
   PrintToken(token);
end; {NextToken}


procedure TermScanner;

{ Shut down the scanner.                                        }

begin {TermScanner}
if ifList <> nil then
   Error(21);
if numErr <> 0 then begin               {write any pending errors}
   firstPtr := chPtr;
   WriteLine;
   end; {if}
end; {TermScanner}

end.

{$append 'scanner.asm'}
