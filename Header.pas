{$optimize 7}
{---------------------------------------------------------------}
{								}
{  Header							}
{								}
{  Handles saving and reading precompiled headers.		}
{								}
{---------------------------------------------------------------}

unit Header;

interface

{$LibPrefix '0/obj/'}

uses CCommon, MM, Scanner, Symbol, CGI;

{$segment 'scanner'}

var
   inhibitHeader: boolean;		{should .sym includes be blocked?}


procedure EndInclude (chPtr: ptr);

{ Saves symbols created by the include file			}
{								}
{ Parameters:							}
{    chPtr - chPtr when the file returned			}
{								}
{ Notes:							}
{    1. Call this subroutine right after processing an		}
{       include file.						}
{    2. Declared externally in Symbol.pas			}


procedure FlagPragmas (pragma: pragmas);

{ record the effects of a pragma				}
{								}
{ parameters:							}
{    pragma - pragma to record					}
{								}
{ Notes:							}
{    1. Defined as extern in Scanner.pas			}
{    2. For the purposes of this unit, the segment statement is	}
{	treated as a pragma.					}


procedure InitHeader (var fName: gsosOutString);

{ look for a header file, reading it if it exists		}
{								}
{ parameters:							}
{    fName - source file name (var for efficiency)		}


procedure TermHeader;

{ Stop processing the header file				}
{								}
{ Note: This is called when the first code-generating		}
{    subroutine is found, and again when the compile ends.  It	}
{    closes any open symbol file, and should take no action if	}
{    called twice.						}


procedure StartInclude (name: gsosOutStringPtr);

{ Marks the start of an include file				}
{								}
{ Notes:							}
{    1. Call this subroutine right after opening an include	}
{       file.							}
{    2. Defined externally in Scanner.pas			}

{---------------------------------------------------------------}

implementation

const
   symFiletype = $5E;			{symbol file type}
   symAuxtype = $008008;

					{file buffer}
                                        {-----------}
   bufSize = 1024;			{size of output buffer}

type                   
   closeOSDCB = record
      pcount: integer;
      refNum: integer;
      end;

   createOSDCB = record
      pcount: integer;
      pathName: gsosInStringPtr;
      access: integer;
      fileType: integer;
      auxType: longint;
      storageType: integer;
      dataEOF: longint;
      resourceEOF: longint;
      end;

   destroyOSDCB = record
      pcount: integer;
      pathName: gsosInStringPtr;
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

   getMarkOSDCB = record
      pcount: integer;
      refNum: integer;
      displacement: longint;
      end;

   openOSDCB = record
      pcount: integer;
      refNum: integer;
      pathName: gsosInStringPtr;
      requestAccess: integer;
      resourceNumber: integer;
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

   readWriteOSDCB = record
      pcount: integer;
      refNum: integer;
      dataBuffer: ptr;
      requestCount: longint;
      transferCount: longint;
      cachePriority: integer;
      end;

   setMarkOSDCB = record
      pcount: integer;
      refNum: integer;
      base: integer;
      displacement: longint;
      end;

					{file buffer}
                                        {-----------}
   bufferType = array[0..bufSize] of byte; {output buffer}

var
   codeStarted: boolean;		{has code generation started?}
   includeLevel: 0..maxint;		{nexted include level}
   includeMark: boolean;		{has the mark field been written?}
   savePragmas: set of pragmas;		{pragmas to record}
   saveSource: boolean;			{save source streams?}
   symChPtr: ptr;			{chPtr at start of current source sequence}
   symEndPtr: ptr;			{points to first byte past end of file}
   symMark: longint;			{start of current block}
   symName: gsosOutString;		{symbol file name}
   symStartPtr: ptr;			{first byte in the symbol file}
   symPtr: ptr;				{next byte in the symbol file}
   symRefnum: integer;			{symName reference number}
   tokenMark: longint;			{start of last token list}

					{file buffer}
                                        {-----------}
   buffer: ^bufferType;			{output buffer}
   bufPtr: ^byte;			{next available byte}
   bufLen: 0..bufSize;			{bytes left in buffer}

{---------------------------------------------------------------}

procedure BlockMove (sourcPtr, destPtr: ptr; count: longint); tool ($02, $2B);

procedure CloseGS (var parms: closeOSDCB); prodos ($2014);

procedure CreateGS (var parms: createOSDCB); prodos ($2001);

procedure DestroyGS (var parms: destroyOSDCB); prodos ($2002);

procedure GetFileInfoGS (var parms: getFileInfoOSDCB); prodos ($2006);

procedure GetMarkGS (var parms: getMarkOSDCB); prodos ($2017);

procedure OpenGS (var parms: openOSDCB); prodos ($2010);

procedure SetEOFGS (var parms: setMarkOSDCB); prodos ($2018);

procedure SetMarkGS (var parms: setMarkOSDCB); prodos ($2016);

procedure WriteGS (var parms: readWriteOSDCB); prodos ($2013);

{---------------------------------------------------------------}

procedure DestroySymbolFile;

{ Delete any existing symbol file				}

var
   dsRec: destroyOSDCB;			{DestroyGS record}
   giRec: getFileInfoOSDCB;		{GetFileInfoGS record}

begin {DestroySymbolFile}
giRec.pCount := 4;
giRec.pathname := @symName.theString;
GetFileInfoGS(giRec);
if (giRec.filetype = symFiletype) and (giRec.auxtype = symAuxtype) then begin
   dsRec.pCount := 1;			
   dsRec.pathname := @symName.theString;
   DestroyGS(dsRec);
   end; {if}
end; {DestroySymbolFile}


procedure Purge;

{ Purge the output buffer					}

var
   clRec: closeOSDCB;			{CloseGS record}
   wrRec: readWriteOSDCB;		{WriteGS record}

begin {Purge}
wrRec.pcount := 4;
wrRec.refnum := symRefnum;
wrRec.dataBuffer := pointer(buffer);
wrRec.requestCount := (bufSize - bufLen);
WriteGS(wrRec);
if ToolError <> 0 then begin
   clRec.pCount := 1;
   clRec.refnum := symRefnum;
   CloseGS(clRec);
   DestroySymbolFile;
   saveSource := false;
   end; {if}
bufLen := bufSize;
bufPtr := pointer(buffer);
end; {Purge}


procedure CloseSymbols;

{ Close the symbol file						}

var
   clRec: closeOSDCB;			{CloseGS record}

begin {CloseSymbols}
Purge;
clRec.pCount := 1;
clRec.refnum := symRefnum;
CloseGS(clRec);
if numErrors <> 0 then
   DestroySymbolFile;
end; {CloseSymbols}


function ReadDouble: double;

{ Read a double precision real from the symbol file		}
{								}
{ Returns: value read						}

type
   doubleptr = ^double;

begin {ReadDouble}
ReadDouble := doubleptr(symPtr)^;
symPtr := pointer(ord4(symPtr)+8);
end; {ReadDouble}


function ReadLong: longint;

{ Read a long word from the symbol file				}
{								}
{ Returns: long word read					}

type
   longptr = ^longint;

begin {ReadLong}
ReadLong := longptr(symPtr)^;
symPtr := pointer(ord4(symPtr)+4);
end; {ReadLong}


function ReadLongString: longStringPtr;

{ Read a long string from the symbol file			}
{								}
{ Returns: string read						}

var
   len: 0..maxint;			{string buffer length}
   sp1, sp2: longStringPtr;		{work pointers}

begin {ReadLongString}
sp1 := longStringPtr(symPtr);
len := sp1^.length + 2;
symPtr := pointer(ord4(symPtr) + len);
sp2 := pointer(GMalloc(len));
BlockMove(sp1, sp2, len);
ReadLongString := sp2;
end; {ReadLongString}


function ReadString: stringPtr;

{ Read a string from the symbol file				}
{								}
{ Returns: string read						}

var
   len: 0..255;				{string buffer length}
   sp1, sp2: stringPtr;			{work pointers}

begin {ReadString}
sp1 := stringptr(symPtr);
len := length(sp1^) + 1;
symPtr := pointer(ord4(symPtr) + len);
sp2 := pointer(GMalloc(len));
BlockMove(sp1, sp2, len);
ReadString := sp2;
end; {ReadString}


function ReadByte: integer;

{ Read a byte from the symbol file				}
{								}
{ Returns: byte read						}

type
   intptr = ^integer;

begin {ReadByte}
ReadByte := (intptr(symPtr)^) & $00FF;
symPtr := pointer(ord4(symPtr)+1);
end; {ReadByte}


function ReadWord: integer;

{ Read a word from the symbol file				}
{								}
{ Returns: word read						}

type
   intptr = ^integer;

begin {ReadWord}
ReadWord := intptr(symPtr)^;
symPtr := pointer(ord4(symPtr)+2);
end; {ReadWord}


procedure ReadChars (var p1, p2: ptr);

{ Read a character stream from the file				}
{								}
{ parameters:							}
{    p1 - (output) pointer to first char in stream		}
{    p2 - (output) points one past last char in stream		}

var
   len: integer;			{length of the stream}

begin {ReadChars}
len := ReadWord;
p1 := pointer(GMalloc(len));
p2 := pointer(ord4(p1) + len);
BlockMove(symPtr, p1, len);
symPtr := pointer(ord4(symPtr) + len);
end; {ReadChars}


procedure WriteDouble (d: double);

{ Write a double constant to the symbol file			}
{								}
{ parameters:							}
{    d - constant to write					}

var
   dPtr: ^double;			{work pointer}

begin {WriteDouble}
if bufLen < 8 then
   Purge;
dPtr := pointer(bufPtr);
dPtr^ := d;
bufPtr := pointer(ord4(bufPtr) + 8);
bufLen := bufLen - 8;
end; {WriteDouble}


procedure WriteLong (i: longint);

{ Write a long word to the symbol file				}
{								}
{ parameters:							}
{    i - long word to write					}

var
   lPtr: ^longint;			{work pointer}

begin {WriteLong}
if bufLen < 4 then
   Purge;
lPtr := pointer(bufPtr);
lPtr^ := i;
bufPtr := pointer(ord4(bufPtr) + 4);
bufLen := bufLen - 4;
end; {WriteLong}


procedure WriteByte (i: integer);

{ Write a byte to the symbol file				}
{								}
{ parameters:							}
{    i - byte to write						}

var
   iPtr: ^byte;				{work pointer}
    
begin {WriteByte}
if bufLen = 0 then
   Purge;
iPtr := pointer(bufPtr);
iPtr^ := i;
bufPtr := pointer(ord4(bufPtr) + 1);
bufLen := bufLen - 1;
end; {WriteByte}


procedure WriteWord (i: integer);

{ Write a word to the symbol file				}
{								}
{ parameters:							}
{    i - word to write						}

var
   iPtr: ^integer;			{work pointer}
    
begin {WriteWord}
if bufLen < 2 then
   Purge;
iPtr := pointer(bufPtr);
iPtr^ := i;
bufPtr := pointer(ord4(bufPtr) + 2);
bufLen := bufLen - 2;
end; {WriteWord}


procedure WriteLongString (s: longStringPtr);

{ Write a long string to the symbol file			}
{								}
{ parameters:							}
{    s - pointer to the string to write				}

var
   i: 0..maxint;			{loop/index variables}
   len: 0..maxint;			{string length}
   wrRec: readWriteOSDCB;		{WriteGS record}
     
begin {WriteLongString}
len := s^.length;
if bufLen < len+2 then
   Purge;
if bufLen < len+2 then begin
   wrRec.pcount := 4;
   wrRec.refnum := symRefnum;
   wrRec.dataBuffer := pointer(s);
   wrRec.requestCount := s^.length + 2;
   WriteGS(wrRec);
   if ToolError <> 0 then begin
      CloseSymbols;
      DestroySymbolFile;
      saveSource := false;
      end; {if}
   end {if}
else begin
   WriteWord(len);
   for i := 1 to len do begin
      bufPtr^ := ord(s^.str[i]);
      bufPtr := pointer(ord4(bufPtr) + 1);
      end; {for}
   bufLen := bufLen - len;
   end; {else}
end; {WriteLongString}


procedure WriteChars (p1, p2: ptr);

{ Write a stream of chars as a longString			}
{								}
{ parameters:							}
{    p1 - points to the first char to write			}
{    p2 - points to the byte following the last char		}

var
   i: 0..maxint;			{loop/index variables}
   len: 0..maxint;			{char length}
   wrRec: readWriteOSDCB;		{WriteGS record}

begin {WriteChars}
len := ord(ord4(p2) - ord4(p1));
WriteWord(len);
if bufLen < len then
   Purge;
if bufLen < len then begin
   if saveSource then begin
      wrRec.pcount := 4;
      wrRec.refnum := symRefnum;
      wrRec.dataBuffer := pointer(p1);
      wrRec.requestCount := ord4(p2) - ord4(p1);
      WriteGS(wrRec);
      if ToolError <> 0 then begin
	 CloseSymbols;
	 DestroySymbolFile;
	 saveSource := false;
	 end; {if}
      end; {if}
   end {if}
else begin
   for i := 1 to len do begin
      bufPtr^ := p1^;
      bufPtr := pointer(ord4(bufPtr)+1);
      p1 := pointer(ord4(p1)+1);
      end; {for}
   bufLen := bufLen - len;
   end; {else}
end; {WriteChars}


procedure WriteString (s: stringPtr);

{ Write a string to the symbol file				}
{								}
{ parameters:							}
{    s - pointer to the string to write				}

var
   i: 0..255;				{loop/index variable}
   len: 0..255;				{length of the string}

begin {WriteString}
len := length(s^);
if bufLen < len+1 then
   Purge;
for i := 0 to len do begin
   bufPtr^ := ord(s^[i]);
   bufPtr := pointer(ord4(bufPtr)+1);
   end; {for}
bufLen := bufLen - (len + 1);
end; {WriteString}


procedure MarkBlock;

{ Mark the length of the current block				}

var
   l: longint;				{block length}
   smRec: setMarkOSDCB;			{SetMarkGS record}
   gmRec: getMarkOSDCB;			{GetMarkGS record}
   wrRec: readWriteOSDCB;		{WriteGS record}
      
begin {MarkBlock}
Purge;					{purge the buffer}
gmRec.pCount := 2;			{get the current EOF}
gmRec.refnum := symRefnum;
GetMarkGS(gmRec);
if ToolError = 0 then begin
   smRec.pcount := 3;			{set the mark to the block length field}
   smRec.refnum := symRefnum;
   smRec.base := 0;
   smRec.displacement := symMark;
   SetMarkGS(smRec);
   if ToolError = 0 then begin
      l := gmRec.displacement - smRec.displacement - 4;
      wrRec.pcount := 4;
      wrRec.refnum := symRefnum;
      wrRec.dataBuffer := @l;
      wrRec.requestCount := 4;
      WriteGS(wrRec);
      if ToolError <> 0 then begin
	 CloseSymbols;
	 DestroySymbolFile;
	 saveSource := false;
	 end; {if}
      smRec.displacement := gmRec.displacement;
      SetMarkGS(smRec);
      end; {if}
   end; {if}
if ToolError <> 0 then begin		{for errors, delete the symbol file}
   CloseSymbols;
   DestroySymbolFile;
   saveSource := false;
   end; {if}
end; {MarkBlock}


function GetMark: longint;

{ Find the current file mark					}
{								}
{ Returns: file mark						}

var
   gmRec: getMarkOSDCB;			{GetMarkGS record}

begin {GetMark}
gmRec.pCount := 2;
gmRec.refnum := symRefnum;
GetMarkGS(gmRec);
GetMark := gmRec.displacement + (bufSize - bufLen);
if ToolError <> 0 then begin
   CloseSymbols;
   DestroySymbolFile;
   saveSource := false;
   end; {else}
end; {GetMark}


procedure SetMark;

{ Mark the start of a block					}

begin {SetMark}
symMark := GetMark;
WriteLong(0);
end; {SetMark}

{---------------------------------------------------------------}

procedure EndInclude {chPtr: ptr};

{ Saves symbols created by the include file			}
{								}
{ Parameters:							}
{    chPtr - chPtr when the file returned			}
{								}
{ Notes:							}
{    1. Call this subroutine right after processing an		}
{       include file.						}
{    2. Declared externally in Scanner.pas			}


   procedure SaveMacroTable;

   { Save macros to the symbol file				}


      procedure SaveMacros;

      { Write the macros to the symbol file			}

      var
         i: 0..hashSize;		{loop/index variable}
         mp: macroRecordPtr;		{used to trace macro lists}
         tp: tokenListRecordPtr;	{used to trace token lists}


	 procedure WriteToken (var token: tokenType);

	 { Write a token in the header file				}
	 {								}
	 { parameters:							}
	 {    token - token to write					}

	 begin {WriteToken}
	 WriteByte(ord(token.kind));
	 WriteByte(ord(token.class));
         if token.numstring = nil then
            WriteByte(0)
         else begin
            WriteByte(1);
            WriteString(token.numstring);
            end; {else}
	 case token.class of
	    identifier:		WriteString(token.name);
	    intConstant:	WriteWord(token.ival);
	    longConstant:	WriteLong(token.lval);
	    doubleConstant:	WriteDouble(token.rval);
	    stringConstant:	begin
				WriteLongString(token.sval);
                		WriteByte(ord(token.ispstring));
                		end;
            macroParameter:	WriteWord(token.pnum);
	    otherwise:	;
	    end; {case}
	 end; {WriteToken}


      begin {SaveMacros}
      for i := 0 to hashSize do begin	{loop over hash buckets}
         mp := macros^[i];		{loop over macro records in hash bucket}
         while mp <> nil do begin
            if not mp^.saved then begin
               mp^.saved := true;	{mark this one as saved}
               WriteString(mp^.name);	{write the macroRecord}
               WriteByte(mp^.parameters);
               WriteByte(ord(mp^.readOnly));
               WriteByte(mp^.algorithm);
               tp := mp^.tokens;	{loop over token list}
               while tp <> nil do begin
		  WriteByte(1);		{write tokenListRecord}
        	  WriteLongString(tp^.tokenString);
        	  WriteToken(tp^.token);
        	  WriteByte(ord(tp^.expandEnabled));
        	  WriteChars(tp^.tokenStart, tp^.tokenEnd);
        	  tp := tp^.next;
        	  end; {while}
               WriteByte(0);		{mark end of token list}
               end; {if}
            mp := mp^.next;
            end; {while}
         end; {for}
      end; {SaveMacros}


   begin {SaveMacroTable}
   SetMark;				{set the macro table length mark}
   if saveSource then			{write the macro table}
      SaveMacros;
   if saveSource then			{mark the length of the table}
      MarkBlock;
   end; {SaveMacroTable}


   procedure SavePragmaEffects;

   { Save the variables effected by any pragmas encountered	}

   var
      count: 0..maxint;			{number of path names}
      i: 1..10;				{loop/index variable}
      p: pragmas;			{loop variable}
      pp: pathRecordPtr;		{used to trace pathname list}

   begin {SavePragmaEffects}
   SetMark;
   if saveSource then
      for p := succ(p_startofenum) to pred(p_endofenum) do
         if p in savePragmas then
            if saveSource then begin
               WriteByte(ord(p));
               case p of
                  p_cda: begin
                     WriteString(@menuLine);
                     WriteString(openName);
                     WriteString(closeName);
                     end;

                  p_cdev: WriteString(openName);

                  p_float: begin
                     WriteWord(floatCard);
                     WriteWord(floatSlot);
                     end;

                  p_keep: WriteLongString(@outFileGS.theString);

                  p_line: begin
                     WriteWord(lineNumber);
                     WriteLongString(@sourceFileGS.theString);
                     end;

                  p_nda: begin
                     WriteString(openName);
                     WriteString(closeName);
                     WriteString(actionName);
                     WriteString(initName);
                     WriteWord(refreshPeriod);
                     WriteWord(eventMask);
                     WriteString(@menuLine);
                     end;

                  p_nba:
                     WriteString(openName);

                  p_xcmd:
                     WriteString(openName);

                  p_debug:
                     WriteByte(ord(rangeCheck)
                        | (ord(debugFlag) << 1)
                        | (ord(profileFlag) << 2)
                        | (ord(traceBack) << 3)
                        | (ord(checkStack) << 4));

                  p_lint: WriteWord(lint);

                  p_memorymodel: WriteByte(ord(smallMemoryModel));

                  p_expand: WriteByte(ord(printMacroExpansions));

                  p_optimize:
                     WriteByte(ord(peepHole)
                        | (ord(npeepHole) << 1)
                        | (ord(registers) << 2)
                        | (ord(saveStack) << 3)
                        | (ord(commonSubexpression) << 4)
                        | (ord(loopOptimizations) << 5)
                        | (ord(strictVararg) << 6));

                  p_stacksize: WriteWord(stackSize);

                  p_toolparms: WriteByte(ord(toolParms));

                  p_databank: WriteByte(ord(dataBank));

                  p_rtl: ;

                  p_noroot: ;

                  p_path: begin
                     pp := pathList;
                     count := 0;
                     while pp <> nil do begin
                        count := count+1;
                        pp := pp^.next;
                        end; {while}
                     WriteWord(count);
                     pp := pathList;
                     while pp <> nil do begin
                        WriteString(pp^.path);
                        pp := pp^.next;
                        end; {while}
                     end; {p_path}

                  p_ignore: WriteByte(ord(skipIllegalTokens)
                                      + (ord(slashSlashComments) << 3));

                  p_segment: begin
                     for i := 1 to 10 do begin
                        WriteByte(defaultSegment[i]);
                        WriteByte(currentSegment[i]);
                        end; {for}
                     WriteWord(segmentKind);
                     end;

                  p_unix: WriteByte(ord(unix_1));

                  end; {case}
               end; {if}
   if saveSource then
      MarkBlock;
   savePragmas := [];
   end; {SavePragmaEffects}


   procedure SaveSourceStream;

   { Save the source stream for later compares			}

   var
      wrRec: readWriteOSDCB;		{WriteGS record}

   begin {SaveSourceStream}
   WriteLong(ord4(chPtr) - ord4(symChPtr));
   Purge;
   wrRec.pcount := 4;
   wrRec.refnum := symRefnum;
   wrRec.dataBuffer := pointer(symChPtr);
   wrRec.requestCount := ord4(chPtr) - ord4(symChPtr);
   WriteGS(wrRec);
   symChPtr := chPtr;
   if ToolError <> 0 then begin
      CloseSymbols;
      DestroySymbolFile;
      saveSource := false;
      end; {if}
   end; {SaveSourceStream}


   procedure SaveSymbolTable;

   { Save symbols to the symbol file				}


      procedure SaveSymbol;

      { Write the symbols to the symbol file			}

      var
         abort: boolean;		{abort due to initialized var?}
         efRec: setMarkOSDCB;		{SetEOFGS record}
         i: 0..hashSize;		{loop/index variable}
         sp: identPtr;			{used to trace symbol lists}


         procedure WriteIdent (ip: identPtr);

         { write a symbol to the symbol file				}
         {								}
         { parameters:							}
         {    ip - pointer to symbol entry				}


            procedure WriteType (tp: typePtr);

            { write a type entry to the symbol file			}
            {								}
            { parameters:						}
            {    tp - pointer to type entry				}

            var
               ip: identPtr;			{for tracing field list}


               procedure WriteParm (pp: parameterPtr);

               { write a parameter list to the symbol file		}
               {							}
               { parameters:						}
               {    pp - parameter pointer				}

               begin {WriteParm}
               while pp <> nil do begin
                  WriteByte(1);
                  WriteType(pp^.parameterType);
                  pp := pp^.next;
                  end; {while}
               WriteByte(0);
               end; {WriteParm}


            begin {WriteType}
            if tp = bytePtr then
               WriteByte(2)
            else if tp = uBytePtr then
               WriteByte(3)
            else if tp = wordPtr then
               WriteByte(4)
            else if tp = uWordPtr then
               WriteByte(5)
            else if tp = longPtr then
               WriteByte(6)
            else if tp = uLongPtr then
               WriteByte(7)
            else if tp = realPtr then
               WriteByte(8)
            else if tp = doublePtr then
               WriteByte(9)
            else if tp = extendedPtr then
               WriteByte(10)
            else if tp = stringTypePtr then
               WriteByte(11)
            else if tp = voidPtr then
               WriteByte(12)
            else if tp = voidPtrPtr then
               WriteByte(13)
            else if tp = defaultStruct then
               WriteByte(14)
            else if tp^.saveDisp <> 0 then begin
               WriteByte(1);
               WriteLong(tp^.saveDisp);
               end {if}
            else begin
               WriteByte(0);
               tp^.saveDisp := GetMark;
               WriteLong(tp^.size);
               WriteByte(ord(tp^.isConstant));
               WriteByte(ord(tp^.kind));
               case tp^.kind of
        	  scalarType:
        	     WriteByte(ord(tp^.baseType));

        	  arrayType: begin
        	     WriteLong(tp^.elements);
        	     WriteType(tp^.aType);
        	     end;

        	  pointerType:
        	     WriteType(tp^.pType);

        	  functionType: begin
        	     WriteByte((ord(tp^.varargs) << 2)
                        | (ord(tp^.prototyped) << 1) | ord(tp^.isPascal));
        	     WriteWord(tp^.toolnum);
        	     WriteLong(tp^.dispatcher);
        	     WriteType(tp^.fType);
        	     WriteParm(tp^.parameterList);
        	     end;

        	  enumConst:
        	     WriteWord(tp^.eval);

        	  definedType:
        	     WriteType(tp^.dType);

        	  structType, unionType: begin
        	     ip := tp^.fieldList;
        	     while ip <> nil do begin
                	WriteByte(1);
                	WriteIdent(ip);
                	ip := ip^.next;
                	end; {while}
        	     WriteByte(0);
        	     end;

		  otherwise: ;
               
        	  end; {case}
               end; {else}
            end; {WriteType}


	 begin {WriteIdent}
         WriteString(ip^.name);	
         WriteType(ip^.itype);
         if (ip^.disp = 0) and (ip^.bitDisp = 0) and (ip^.bitSize = 0) then
            WriteByte(0)
         else if (ip^.bitSize = 0) and (ip^.bitDisp = 0) then begin
            if ip^.disp < maxint then begin
               WriteByte(1);
               WriteWord(ord(ip^.disp));
               end {if}
            else begin
               WriteByte(2);
               WriteLong(ip^.disp);
               end; {else}
            end {else if}
         else begin
            WriteByte(3);
            WriteLong(ip^.disp);
            WriteByte(ip^.bitDisp);
            WriteByte(ip^.bitSize);
            end; {else}
         if ip^.iPtr <> nil then
            abort := true;
         WriteByte(ord(ip^.state));
         WriteByte(ord(ip^.isForwardDeclared));
         WriteByte(ord(ip^.class));
         WriteByte(ord(ip^.storage));
	 end; {WriteIdent}
         

      begin {SaveSymbol}
      abort := false;			{no reason to abort, yet}
      for i := 0 to hashSize2 do begin	{loop over hash buckets}
         sp := globalTable^.buckets[i];	{loop over symbol records in hash bucket}
         while sp <> nil do begin
            if not sp^.saved then begin
               sp^.saved := true;	{mark this one as saved}
               WriteWord(i);		{save the symbol}
               WriteIdent(sp);
               end; {if}
            sp := sp^.next;
            end; {while}
         end; {for}
      if abort then begin
         Purge;
	 efRec.pcount := 3;
	 efRec.refnum := symRefnum;
	 efRec.base := 0;
	 efRec.displacement := tokenMark;
	 SetEOFGS(efRec);
	 if ToolError <> 0 then begin
	    CloseSymbols;
	    DestroySymbolFile;
	    end; {if}
         saveSource := false;
         end; {if}
      end; {SaveSymbol}


   begin {SaveSymbolTable}
   SetMark;				{set the symbol table length mark}
   if saveSource then			{write the symbol table}
      if globalTable <> nil then
         SaveSymbol;
   if saveSource then			{mark the length of the table}
      MarkBlock;
   end; {SaveSymbolTable}


begin {EndInclude}
if not ignoreSymbols then begin
   includeLevel := includeLevel-1;
   if includeLevel = 0 then
      if saveSource then begin
	 MarkBlock;			{set the include name mark}
	 SaveSourceStream;		{save the source stream}
	 SaveMacroTable;		{save the macro table}
	 SaveSymbolTable;		{save the symbol table}
	 SavePragmaEffects;		{save the effects of pragmas}
	 tokenMark := GetMark;		{record mark for early exit}
	 includeMark := false;		{no include mark, yet}
	 end; {if}
   end; {if}
end; {EndInclude}                


procedure FlagPragmas {pragma: pragmas};

{ record the effects of a pragma				}
{								}
{ parameters:							}
{    pragma - pragma to record					}
{								}
{ Notes:							}
{    1. Defined as extern in Scanner.pas			}
{    2. For the purposes of this unit, the segment statement	}
{	and #line directive are treated as pragmas.		}

begin {FlagPragmas}
savePragmas := savePragmas + [pragma];
end; {FlagPragmas}


procedure InitHeader {var fName: gsosOutString};

{ look for a header file, reading it if it exists		}
{								}
{ parameters:							}
{    fName - source file name (var for efficiency)		}

type
   typeDispPtr = ^typeDispRecord;	{type displacement/pointer table}
   typeDispRecord = record
      next: typeDispPtr;
      saveDisp: longint;
      tPtr: typePtr;
      end;

var
   done: boolean;			{for loop termination test}
   typeDispList: typeDispPtr;		{type displacement/pointer table}


   procedure DisposeTypeDispList;

   { Dispose of the type displacement list			}

   var
      tp: typeDispPtr;			{work pointer}

   begin {DisposeTypeDispList}
   while typeDispList <> nil do begin
      tp := typeDispList;
      typeDispList := tp^.next;
      dispose(tp);
      end; {while}
   end; {DisposeTypeDispList}


   function EndOfSymbols: boolean;

   { See if we're at the end of the symbol file			}
   {								}
   { Returns: True if at the end, else false			}

   begin {EndOfSymbols}
   EndOfSymbols := ord4(symPtr) >= ord4(symEndPtr);
   end; {EndOfSymbols}


   function OpenSymbols: boolean;

   { open and initialize the symbol file			}
   {								}
   { Returns: True if successful, else false			}

   var
      crRec: createOSDCB;		{CreateGS record}
      opRec: openOSDCB;			{OpenGS record}

   begin {OpenSymbols}
   OpenSymbols := false;		{assume we will fail}
   DestroySymbolFile;			{destroy any existing file}
   crRec.pCount := 5;			{create a symbol file}
   crRec.pathName := @symName.theString;
   crRec.access := $C3;
   crRec.fileType := symFiletype;
   crRec.auxType := symAuxtype;
   crRec.storageType := 1;
   CreateGS(crRec);
   if ToolError = 0 then begin
      opRec.pCount := 3;
      opRec.pathname := @symName.theString;
      opRec.requestAccess := 3;
      OpenGS(opRec);
      if ToolError = 0 then begin           
         symRefnum := opRec.refnum;
         OpenSymbols := true;
         WriteWord(1);
         tokenMark := GetMark;
         includeMark := false;
         end; {if}
      end; {if}
   end; {OpenSymbols}


   procedure PurgeSymbols;

   { Purge the symbol input file				}

   var
      ffDCBGS: fastFileDCBGS;		{fast file DCB}
   
   begin {PurgeSymbols}
   with ffDCBGS do begin		{purge the file}
      pCount := 5;
      action := 7;
      pathName := @symName.theString;
      end; {with}
   FastFileGS(ffDCBGS);
   end; {PurgeSymbols}                                      


   function DatesMatch: boolean;

   { Make sure the create/mod dates have not changed		}

   var
      giRec: getFileInfoOSDCB;		{GetFileInfoGS record}
      i: 1..maxint;			{loop/index variable}
      len: longint;			{length of names}
      match: boolean;			{do the dates match?}

   begin {DatesMatch}
   match := true;
   len := ReadLong;
   while len > 0 do begin
      giRec.pCount := 7;
      giRec.pathname := pointer(ReadLongString);
      len := len - (giRec.pathname^.size + 18);
      GetFileInfoGS(giRec);
      if ToolError = 0 then begin
	 for i := 1 to 8 do
	    match := match and (giRec.createDateTime[i] = ReadByte);
	 for i := 1 to 8 do
	    match := match and (giRec.modDateTime[i] = ReadByte);
         end {if}
      else begin
         match := false;
         len := 0;
         end; {else}
      if match and progress then begin
	 write('Including ');
	 for i := 1 to giRec.pathname^.size do
            write(giRec.pathname^.theString[i]);
	 writeln;
	 end; {if}
      end; {while}
   DatesMatch := match;
   end; {DatesMatch}


   procedure ReadMacroTable;

   { Read macros from the symbol file				}

   var
      bp: ^macroRecordPtr;		{pointer to head of hash bucket}
      ep: tokenListRecordPtr;		{last token record}
      mePtr: ptr;			{end of macro table}
      mp: macroRecordPtr;		{new macro record}
      tlen: integer;			{length of the token name}
      tp: tokenListRecordPtr;		{new token record}
        

      procedure ReadToken (var token: tokenType);

      { read a token						}
      {								}
      { parameters:						}
      {    token - (output) token read)				}

      begin {ReadToken}
      token.kind := tokenEnum(ReadByte);
      token.class := tokenClass(ReadByte);
      if ReadByte = 0 then
         token.numString := nil
      else
         token.numstring := ReadString;
      case token.class of 
	 identifier:		token.name := ReadString;
	 intConstant:		token.ival := ReadWord;
	 longConstant:		token.lval := ReadLong;
	 doubleConstant:	token.rval := ReadDouble;
	 stringConstant:	begin
			        token.sval := ReadLongString;
                	        token.ispstring := ReadByte <> 0;
                	        end;
         macroParameter:	token.pnum := ReadWord;
	 otherwise:		;
	 end; {case}
      end; {ReadToken}


   begin {ReadMacroTable}
   mePtr := symPtr;			{read the block length}
   mePtr := pointer(ord4(mePtr) + ReadLong + 4);
   while ord4(symPtr) < ord4(mePtr) do	{process the macros}
      begin
      Spin;
      mp := pointer(GMalloc(sizeof(macroRecord)));
      mp^.saved := false;
      mp^.name := ReadString;
      bp := pointer(ord4(macros) + Hash(mp^.name));
      mp^.next := bp^;
      bp^ := mp;
      mp^.parameters := ReadByte;
      if mp^.parameters & $0080 <> 0 then
         mp^.parameters := mp^.parameters | $FF00;
      mp^.readOnly := boolean(ReadByte);
      mp^.algorithm := ReadByte;
      mp^.tokens := nil;
      ep := nil;
      while ReadByte <> 0 do begin
         tp := pointer(GMalloc(sizeof(tokenListRecord)));
         tp^.next := nil;
         tp^.tokenString := ReadLongString;
         ReadToken(tp^.token);
         tp^.expandEnabled := boolean(ReadByte);
         ReadChars(tp^.tokenStart, tp^.tokenEnd);
         if ep = nil then
            mp^.tokens := tp
         else
            ep^.next := tp;
         ep := tp;
         end; {while}
      end; {while}
   symPtr := mePtr;
   end; {ReadMacroTable}


   procedure ReadPragmas;

   { Read pragma effects					}

   var
      i: 0..maxint;			{loop/index variable}
      lsPtr: longStringPtr;		{work pointer}
      p: pragmas;			{kind of pragma being processed}
      pePtr: ptr;			{end of pragma table}
      pp, ppe: pathRecordPtr;		{used to create a path name list}
      sPtr: stringPtr;			{work pointer}
      val: integer;			{temp value}
      
   begin {ReadPragmas}
   pePtr := symPtr;			{read the block length}
   pePtr := pointer(ord4(pePtr) + ReadLong + 4);
   while ord4(symPtr) < ord4(pePtr) do	{process the pragmas}
      begin
      Spin;
      p := pragmas(ReadByte);
      case p of
         p_cda: begin
            isClassicDeskAcc := true;
            sPtr := ReadString;
            menuLine := sPtr^;
            openName := ReadString;
            closeName := ReadString;
            end;

         p_cdev: begin
            isCDev := true;
            openName := ReadString;
            end;

         p_float: begin
            floatCard := ReadWord;
            floatSlot := ReadWord;
            end;

         p_keep: begin
            liDCBGS.kFlag := 1;
            lsPtr := ReadLongString;
            outFileGS.theString.size := lsPtr^.length;
            for i := 1 to outFileGS.theString.size do
               outFileGS.theString.theString[i] := lsPtr^.str[i];
            end;

         p_line: begin
            lineNumber := ReadWord;
            lsPtr := ReadLongString;
            sourceFileGS.theString.size := lsPtr^.length;
            for i := 1 to sourceFileGS.theString.size do
               sourceFileGS.theString.theString[i] := lsPtr^.str[i];
            end;

         p_nda: begin
            isNewDeskAcc := true;
            openName := ReadString;
            closeName := ReadString;
            actionName := ReadString;
            initName := ReadString;
            refreshPeriod := ReadWord;
            eventMask := ReadWord;
            sPtr := ReadString;
            menuLine := sPtr^;
            end;

         p_nba: begin
            isNBA := true;
            openName := ReadString;
            end;

         p_xcmd: begin
            isXCMD := true;
            openName := ReadString;
            end;

         p_debug: begin
            val := ReadByte;
            rangeCheck := odd(val);
            debugFlag := odd(val >> 1);
            profileFlag := odd(val >> 2);
            traceback := odd(val >> 3);
            checkStack := odd(val >> 4);
            end;

         p_lint: lint := ReadWord;

         p_memorymodel: smallMemoryModel := boolean(ReadByte);

         p_expand: printMacroExpansions := boolean(ReadByte);

         p_optimize: begin
            val := ReadByte;
            peepHole := odd(val);
            npeepHole := odd(val >> 1);
            registers := odd(val >> 2);
            saveStack := odd(val >> 3);
            commonSubexpression := odd(val >> 4);
            loopOptimizations := odd(val >> 5);
            strictVararg := odd(val >> 6);
            end;

         p_stacksize: stackSize := ReadWord;

         p_toolparms: toolParms := boolean(ReadByte);

         p_databank: dataBank := boolean(ReadByte);

         p_rtl: rtl := true;

         p_noroot: noroot := true;

         p_path: begin
            i := ReadWord;
            pathList := nil;
            ppe := nil;
            while i <> 0 do begin
               pp := pathRecordPtr(GMalloc(sizeof(pathRecord)));
               pp^.path := ReadString;
               pp^.next := nil;
               if pathList = nil then
                  pathList := pp
               else
                  ppe^.next := pp;
               ppe := pp;
               i := i-1;
               end; {while}
            end; {p_path}

         p_ignore: begin
            i := ReadByte;
            skipIllegalTokens := odd(i);
            slashSlashComments := odd(i >> 3);
            end;
         
         p_segment: begin
            for i := 1 to 10 do begin
               defaultSegment[i] := chr(ReadByte);
               currentSegment[i] := chr(ReadByte);
               end; {for}
            segmentKind := ReadWord;
            end;

         p_unix: unix_1 := boolean(ReadByte);

         end; {case}
      end; {while}
   symPtr := pePtr;
   end; {ReadPragmas}


   procedure ReadSymbolTable;

   { Read symbols from the symbol file				}

   var
      hashPtr: ^identPtr;		{pointer to hash bucket in symbol table}
      sePtr: ptr;			{end of symbol table}
      sp: identPtr;			{identifier being constructed}


      function ReadIdent: identPtr;

      { Read an identifier from the file			}
      {								}
      { Returns: Pointer to the new identifier			}

      var
         format: 0..3;			{storage format}
	 sp: identPtr;			{identifier being constructed}


	 procedure ReadType (var tp: typePtr);

	 { read a type from the symbol file				}
	 {								}
	 { parameters:							}
	 {    tp - (output) type entry					}

	 var
            disp: longint;			{disp read from symbol file}
            ep: identPtr;			{end of list of field names}
            ip: identPtr;			{for tracing field list}
            tdisp: typeDispPtr;			{used to trace, add to typeDispList}
            val: integer;			{temp word}


            procedure ReadParm (var pp: parameterPtr);

            { read a parameter list from the symbol file		}
            {								}
            { parameters:						}
            {    pp - (output) parameter pointer			}

            var
               ep: parameterPtr;		{last parameter in list}
               np: parameterPtr;		{new parameter}

            begin {ReadParm}
            pp := nil;
            ep := nil;
            while ReadByte = 1 do begin
               np := parameterPtr(GMalloc(sizeof(parameterRecord)));
               np^.next := nil;
               np^.parameter := nil;
               ReadType(np^.parameterType);
               if ep = nil then
                  pp := np
               else
                  ep^.next := np;
               ep := np;
               end; {while}
            end; {ReadParm}


	 begin {ReadType}
         case ReadByte of
            0: begin			{read a new type}
	       tp := typePtr(GMalloc(sizeof(typeRecord)));
               new(tdisp);
               tdisp^.next := typeDispList;
               typeDispList := tdisp;
               tdisp^.saveDisp := ord4(symPtr) - ord4(symStartPtr);
               tdisp^.tPtr := tp;
	       tp^.size := ReadLong;
               tp^.saveDisp := 0;
	       tp^.isConstant := boolean(ReadByte);
	       tp^.kind := typeKind(ReadByte);
	       case tp^.kind of
        	  scalarType:
        	     tp^.baseType := baseTypeEnum(ReadByte);

        	  arrayType: begin
        	     tp^.elements := ReadLong;
        	     ReadType(tp^.aType);
        	     end;

        	  pointerType: 
        	     ReadType(tp^.pType);

        	  functionType: begin
        	     val := ReadByte;
        	     tp^.varargs := odd(val >> 2);
        	     tp^.prototyped := odd(val >> 1);
        	     tp^.isPascal := odd(val);
        	     tp^.toolnum := ReadWord;
        	     tp^.dispatcher := ReadLong;
        	     ReadType(tp^.fType);
        	     ReadParm(tp^.parameterList);
        	     end;

        	  enumConst:
        	     tp^.eval := ReadWord;

        	  definedType:
        	     ReadType(tp^.dType);

        	  structType, unionType: begin
        	     tp^.fieldList := nil;
        	     ep := nil;
        	     while ReadByte = 1 do begin
        		ip := ReadIdent;
        		if ep = nil then
                	   tp^.fieldList := ip
        		else
                	   ep^.next := ip;
        		ep := ip;
        		end; {while}
        	     end;

		  otherwise: ;
         
        	  end; {case}
               end; {case 0}

            1: begin			{read a type displacement}
               tdisp := typeDispList;
               disp := ReadLong;
               while tdisp <> nil do
        	  if tdisp^.saveDisp = disp then begin
                     tp := tdisp^.tPtr;
                     tdisp := nil;
                     end {if}
        	  else 
                     tdisp := tdisp^.next;
               end; {case 1}

            2: tp := bytePtr;
            3: tp := uBytePtr;
            4: tp := wordPtr;
            5: tp := uWordPtr;
            6: tp := longPtr;
            7: tp := uLongPtr;
            8: tp := realPtr;
            9: tp := doublePtr;
            10: tp := extendedPtr;
            11: tp := stringTypePtr;
            12: tp := voidPtr;
            13: tp := voidPtrPtr;
            14: tp := defaultStruct;
            end; {case}
	 end; {ReadType}


      begin {ReadIdent}
      sp := pointer(GMalloc(sizeof(identRecord)));
      sp^.next := nil;
      sp^.saved := false;
      sp^.name := ReadString;
      ReadType(sp^.itype);
      format := ReadByte;
      if format = 0 then begin
         sp^.disp := 0;
         sp^.bitDisp := 0;
         sp^.bitSize := 0;
         end {if}
      else if format = 1 then begin
         sp^.disp := ReadWord;
         sp^.bitDisp := 0;
         sp^.bitSize := 0;
         end {else if}
      else if format = 2 then begin
         sp^.disp := ReadLong;
         sp^.bitDisp := 0;
         sp^.bitSize := 0;
         end {else if}
      else begin
	 sp^.disp := ReadLong;
	 sp^.bitDisp := ReadByte;
	 sp^.bitSize := ReadByte;
         end; {else}
      sp^.iPtr := nil;
      sp^.state := stateKind(ReadByte);
      sp^.isForwardDeclared := boolean(ReadByte);
      sp^.class := tokenEnum(ReadByte);
      sp^.storage := storageType(ReadByte);
      ReadIdent := sp;
      end; {ReadIdent}


   begin {ReadSymbolTable}
   sePtr := symPtr;			{read the block length}
   sePtr := pointer(ord4(sePtr) + ReadLong + 4);
   while ord4(symPtr) < ord4(sePtr) do	{process the symbols}
      begin
      Spin;
      hashPtr := pointer(ord4(globalTable) + ReadWord*4);
      sp := ReadIdent;
      sp^.next := hashPtr^;
      hashPtr^ := sp;
      end; {while}
   symPtr := sePtr;
   end; {ReadSymbolTable}


   function OpenSymbolFile (var fName: gsosOutString): boolean;

   { Look for and open a symbol file				}
   {								}
   { parameters:						}
   {    fName - source file name (var for efficiency)		}
   {								}
   { Returns: True if the file was found and opened, else false	}
   {								}
   { Notes: As a side effect, this subroutine creates the	}
   {    pathname for the symbol file (symName).			}

   var
      ffDCBGS: fastFileDCBGS;		{fast file DCB}
      i: integer;			{loop/index variable}

   begin {OpenSymbolFile}
   symName := fName;			{create the symbol file name}
   i := symName.theString.size - 1;
   while not (symName.theString.theString[i] in [':', '/', '.']) do
      i := i-1;
   if symName.theString.theString[i] <> '.' then
      i := symName.theString.size;
   if i > maxPath-5 then
      i := maxPath-5;
   symName.theString.theString[i] := '.';
   symName.theString.theString[i+1] := 's';
   symName.theString.theString[i+2] := 'y';
   symName.theString.theString[i+3] := 'm';
   symName.theString.theString[i+4] := chr(0);
   symName.theString.size := i+3;
   if rebuildSymbols then begin		{rebuild any existing symbol file}
      DestroySymbolFile;
      OpenSymbolFile := false;
      end {if}
   else begin
      with ffDCBGS do begin		{read the symbol file}
	 pCount := 14;
	 action := 0;
	 flags := $C000;
	 pathName := @symName.theString;
	 end; {with}
      FastFileGS(ffDCBGS);
      if ToolError = 0 then begin
	 if (ffDCBGS.filetype = symFiletype) and (ffDCBGS.auxtype = symAuxtype) then
            OpenSymbolFile := true
	 else begin
            OpenSymbolFile := false;
            PurgeSymbols;
            end; {else}
	 symPtr := ffDCBGS.fileHandle^;
	 symStartPtr := symPtr;
	 symEndPtr := pointer(ord4(symPtr) + ffDCBGS.fileLength);
	 end {if}
      else
	 OpenSymbolFile := false;
      end; {else}
   end; {OpenSymbolFile}


   function SymbolVersion: integer;

   { Read the symbol file version number			}
   {								}
   { Returns: version number					}

   begin {SymbolVersion}
   SymbolVersion := ReadWord;
   end; {SymbolVersion}


   function SourceMatches: boolean;

   { Make sure the token streams match up to the next include	}

   type
      intPtr = ^integer;		{for faster compares}

   var
      len, len2: longint;		{size of stream to compare}
      match: boolean;			{result flag}
      p1, p2: ptr;			{work pointers}

   begin {SourceMatches}
   match := true;
   len := ReadLong;
   len2 := len;
   p1 := symPtr;
   p2 := chPtr;
   while len > 1 do
      if intPtr(p1)^ <> intPtr(p2)^ then begin
         match := false;
         len := 0;
         end {if}
      else begin
	 len := len-2;
	 p1 := pointer(ord4(p1)+2);
	 p2 := pointer(ord4(p2)+2);
         end; {else}
   if len = 1 then
      if p1^ <> p2^ then
         match := false;
   if match then begin
      symPtr := pointer(ord4(symPtr)+len2);
      symChPtr := pointer(ord4(chPtr)+len2);
      while chPtr <> symChPtr do
         NextCh;
      end; {if}
   SourceMatches := match;
   end; {SourceMatches}


begin {InitHeader}
inhibitHeader := false;			{don't block .sym files}
if not ignoreSymbols then begin
   codeStarted := false;		{code generation has not started}
   new(buffer);				{allocate an output buffer}
   bufPtr := pointer(buffer);
   bufLen := bufSize;
   includeLevel := 0;			{no nested includes}
   symChPtr := chPtr;			{record initial source location}
   if OpenSymbolFile(fName) then begin	{check for symbol file}
      if SymbolVersion = 1 then begin
	 done := EndOfSymbols;		{valid file found - process it}
	 if done then
            PurgeSymbols;
	 typeDispList := nil;
	 while not done do begin
            if DatesMatch then begin
               if SourceMatches then begin
        	  ReadMacroTable;
        	  ReadSymbolTable;
        	  ReadPragmas;
        	  if EndOfSymbols then begin
        	     done := true;
        	     PurgeSymbols;
        	     end; {if}
        	  end {if}
               else begin
        	  PurgeSymbols;
        	  DestroySymbolFile;
        	  done := true;
        	  end; {else}
               end {if}
            else begin
               PurgeSymbols;
               DestroySymbolFile;
               done := true;
               end; {else}
            end; {while}
	 DisposeTypeDispList;
	 saveSource := false;
	 end {if}
      else begin
	 PurgeSymbols;			{no file found}
	 saveSource := true;
	 end; {else}
      end {if}
   else 
      saveSource := true;
   if saveSource then begin		{start saving source}
      saveSource := OpenSymbols;
      savePragmas := [];
      DoDefaultsDotH;
      end; {if}
   end {if}
else
   DoDefaultsDotH;
end; {InitHeader}


procedure StartInclude {name: gsosOutStringPtr};

{ Marks the start of an include file				}
{								}
{ Notes:							}
{    1. Call this subroutine right after opening an include	}
{       file.							}
{    2. Defined externally in Scanner.pas			}

var
   giRec: getFileInfoOSDCB;		{GetFileInfoGS record}
   i: 1..8;				{loop/index counter}

begin {StartInclude}
if inhibitHeader then   
   TermHeader;
if not ignoreSymbols then begin
   includeLevel := includeLevel+1;
   if saveSource then begin
      if not includeMark then begin
	 includeMark := true;
	 SetMark;
	 end; {if}
      giRec.pCount := 7;
      giRec.pathname := pointer(ord4(name)+2);
      GetFileInfoGS(giRec);
      WriteLongString(pointer(giRec.pathname));
      for i := 1 to 8 do
	 WriteByte(giRec.createDateTime[i]);
      for i := 1 to 8 do
	 WriteByte(giRec.modDateTime[i]);
      end {if}
   else if not codeStarted then
      DestroySymbolFile;
   end; {if}
end; {StartInclude}


procedure TermHeader;

{ Stop processing the header file				}
{								}
{ Note: This is called when the first code-generating		}
{    subroutine is found, and again when the compile ends.  It	}
{    closes any open symbol file, and should take no action if	}
{    called twice.						}

begin {TermHeader}
if not ignoreSymbols then begin
   codeStarted := true;
   if saveSource then begin
      CloseSymbols;
      saveSource := false;
      dispose(buffer);
      end; {if}
   end; {if}
end; {TermHeader}

end.
