{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  ObjOut                                                       }
{                                                               }
{  This unit has the primitive routines used to actually        }
{  create and write to object modules.  A few low-level         }
{  subroutines that need to be in assembly language for speed   }
{  are also included here.                                      }
{                                                               }
{  External Subroutines:                                        }
{                                                               }
{  CloseObj - close the current obj file                        }
{  CloseSeg - close out the current segment                     }
{  COut - write a code byte to the object file                  }
{  CnOut - write a byte to the constant buffer                  }
{  CnOut2 - write a word to the constant buffer                 }
{  DestroySuffixes - destroy the .a, .b, etc suffixes           }
{  FindSuffix - find the next available alphabetic suffix       }
{  Header - write a segment header to the output file           }
{  OpenObj - open a new obj file with the indicated file name   }
{  OpenSeg - create a new segment and mark its beginning        }
{  Out - write a byte to the output file                        }
{  Out2 - write a word to the output file                       }
{  Purge - write any constant bytes to the output buffer        }
{                                                               }
{---------------------------------------------------------------}

unit CCommon;

interface

{$LibPrefix '0/obj/'}

uses CCommon, CGI, CGC;

{$segment 'CodeGen'}


procedure CloseObj;

{ close the current obj file                                    }
{								}
{ Note: Declared as extern in CGI.pas				}


procedure COut (b: integer); extern;

{ write a code byte to the object file                          }
{                                                               }
{ parameters:                                                   }
{       b - byte to write                                       }


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


procedure DestroySuffixes (var name: gsosOutString);

{ destroy the .a, .b, etc suffixes                              }
{                                                               }
{ parameters:                                                   }
{       name - root name of file sequence to destroy            }


procedure CloseSeg;

{ close out the current segment                                 }


procedure FindSuffix (var name: gsosOutString; var ch: char);

{ find the next available alphabetic suffix                     }
{                                                               }
{ parameters:                                                   }
{       ch - addr to place suffix character                     }
{       name - root name of suffix to find                      }


procedure Header (name: stringPtr; kind: integer; lengthCode: integer);

{ write a segment header to the output file                     }
{                                                               }
{ parameters:                                                   }
{       name - name of the segment                              }
{       kind - segment kind                                     }
{       lengthCode - code bank size code; bank size div $10000  }


procedure OpenSeg;

{ create a new segment and mark its beginning                   }


procedure OpenObj (var name: gsosOutString);

{ open a new obj file with the indicated file name              }
{                                                               }
{ parameters:                                                   }
{       name - object file name                                 }


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


procedure Purge;

{ write any constant bytes to the output buffer                 }

{---------------------------------------------------------------}

implementation

const
					{NOTE: OutByte and Outword assume }
                                        { buffSize is 16K		  }
   buffSize = 16384;			{size of the obj buffer}
   maxCBuffLen  = 191;                  {length of the constant buffer}
   OBJ = $B1;                           {object file type}

type
   closeOSDCB = record			{Close DCB}
      pcount: integer;
      refNum: integer;
      end;

   createOSDCB = record			{Create DCB}
      pcount: integer;
      pathName: gsosInStringPtr;
      access: integer;
      fileType: integer;
      auxType: longint;
      storageType: integer;
      dataEOF: longint;
      resourceEOF: longint;
      end;

   destroyOSDCB = record		{Destroy DCB}
      pcount: integer;
      pathName: gsosInStringPtr;
      end;

   getFileInfoOSDCB = record		{GetFileInfo DCB}
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

   openOSDCB = record			{Open DCB}
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
      
   readWriteOSDCB = record		{WriteGS DCB}
      pcount: integer;
      refNum: integer;
      dataBuffer: ptr;
      requestCount: longint;
      transferCount: longint;
      cachePriority: integer;
      end;

{---------------------------------------------------------------}

var
   cBuff: array[0..maxCBuffLen] of byte; {constant buffer}

   objLen: longint;                     {# bytes used in obj buffer}
   objHandle: handle;                   {handle of the obj buffer}
   objPtr: ptr;                         {pointer to the next spot in the obj buffer}

   segStart: ptr;			{points to first byte in current segment}
   spoolRefnum: integer;		{reference number for open file}

{---------------------------------------------------------------}

                                        {memory manager calls}
                                        {--------------------}

procedure BlockMove (sourcPtr, destPtr: ptr; count: longint); tool ($02, $2B);

function NewHandle (blockSize: longint; userID, memAttributes: integer;
                    memLocation: ptr): handle; tool($02, $09);

procedure SetHandleSize (newSize: longint; theHandle: handle); tool ($02, $19);

procedure HUnLock (theHandle: handle); tool ($02, $22);

procedure HLock (theHandle: handle); tool ($02, $20);

                                        {ProDOS calls}
                                        {------------}

procedure CloseGS (var parms: closeOSDCB); prodos ($2014);
           
procedure CreateGS (var parms: createOSDCB); prodos ($2001);
   
procedure DestroyGS (var parms: destroyOSDCB); prodos ($2002);

procedure GetFileInfoGS (var parms: getFileInfoOSDCB); prodos ($2006);

procedure OpenGS (var parms: openOSDCB); prodos ($2010);

procedure WriteGS (var parms: readWriteOSDCB); prodos ($2013);
                                                        
{---------------------------------------------------------------}

procedure PurgeObjBuffer;

{ Spool any completed segments to the object file               }

var
   len: longint;			{# bytes to write}
   sPtr: ptr;				{start of object buffer}
   wrRec: readWriteOSDCB;		{WriteGS record}


   procedure InitSpoolFile;

   { Set up the spool file					}

   var
      dsRec: destroyOSDCB;		{DestroyGS record}
      crRec: createOSDCB;		{CreateGS record}
      opRec: openOSDCB;			{OpenGS record}
      
   begin {InitSpoolFile}
   if memoryCompile then		{make sure this is a disk-based compile}
      TermError(11);
   dsRec.pCount := 1;			{destroy any old file}
   dsRec.pathname := @objFile.theString;
   DestroyGS(dsRec);
   crRec.pCount := 5;			{create a new file}
   crRec.pathName := @objFile.theString;
   crRec.access := $C3;
   crRec.fileType := OBJ;
   crRec.auxType := $0000;
   crRec.storageType := 1;
   CreateGS(crRec);
   if ToolError <> 0 then                    
      TermError(9);
   opRec.pCount := 3;			{open the file}
   opRec.pathname := @objFile.theString;
   opRec.requestAccess := 3;
   OpenGS(opRec);
   if ToolError <> 0 then
      TermError(9);
   spoolRefnum := opRec.refnum;
   end; {InitSpoolFile}


begin {PurgeObjBuffer}
if spoolRefnum = 0 then			{make sure the spool file exists}
   InitSpoolFile;
sPtr := objHandle^;			{determine size of completed segments}
len := ord4(segStart) - ord4(sPtr);
if len <> 0 then begin
   wrRec.pcount := 4;			{write completed segments}
   wrRec.refnum := spoolRefnum;
   wrRec.dataBuffer := pointer(sPtr);
   wrRec.requestCount := len;
   WriteGS(wrRec);
   if ToolError <> 0 then		{check for write errors}
      TermError(9);
   objLen := 0;				{adjust file pointers}
   BlockMove(segStart, sPtr, segDisp);
   objPtr := sPtr;
   segStart := sPtr;
   end; {if}                      
end; {PurgeObjBuffer}


{---------------------------------------------------------------}

procedure CloseObj;

{ close the current obj file                                    }
{								}
{ Note: Declared as extern in CGI.pas				}

var
   clRec: closeOSDCB;			{CloseGS record}
   ffDCBGS: fastFileDCBGS;		{dcb for fastfile call}
   i: integer;				{loop/index variable}

begin {CloseObj}
if spoolRefnum <> 0 then begin
   PurgeObjBuffer;
   clRec.pCount := 1;
   clRec.refnum := spoolRefnum;
   CloseGS(clRec);
   end {if}
else if objLen <> 0 then begin
   {resize the buffer}
   HUnLock(objHandle);
   SetHandleSize(objLen, objHandle);
   HLock(objHandle);

   {save the file}
   ffDCBGS.pCount := 14;
   ffDCBGS.fileHandle := objHandle;
   ffDCBGS.pathName := @objFile.theString;
   ffDCBGS.access := $C3;
   ffDCBGS.fileType := OBJ;
   ffDCBGS.auxType := 0;
   ffDCBGS.storageType := 1;
   for i := 1 to 8 do
      ffDCBGS.createDate[i] := 0;
   ffDCBGS.modDate := ffDCBGS.createDate;
   ffDCBGS.option := nil;
   ffDCBGS.fileLength := objLen;
   if memoryCompile then begin
      ffDCBGS.flags := 0;
      ffDCBGS.action := 4;
      end {if}
   else begin
      ffDCBGS.flags := $C000;
      ffDCBGS.action := 3;
      end; {else}
   FastFileGS(ffDCBGS);
   if ToolError <> 0 then
      TermError(9)
   else begin
      ffDCBGS.PATHName := @objFile.theString;
      ffDCBGS.action := 7;
      FastFileGS(ffDCBGS);
      end; {else}
   end; {if}
end; {CloseObj}


procedure DestroySuffixes {var name: gsosOutString};

{ destroy the .a, .b, etc suffixes                              }
{                                                               }
{ parameters:                                                   }
{       name - root name of file sequence to destroy            }

var
   done: boolean;                       {loop termination flag}
   dsDCBGS: destroyOSDCB;		{dcb for destroy call}
   giDCBGS: getFileInfoOSDCB;		{dcb for Get_File_Info call}
   suffix: char;                        {current suffix character}

   fName: gsosInString;                 {work file name}

begin {DestroySuffixes}
suffix := 'a';
done := false;
repeat
   fName := name.theString;
   if fName.size > maxPath-2 then
      fName.size := maxPath-2;
   fName.theString[fName.size+1] := '.';
   fName.theString[fName.size+2] := suffix;
   fName.size := fName.size + 2;
   giDCBGS.pCount := 12;
   giDCBGS.optionList := nil;
   giDCBGS.pathName := @fName;
   GetFileInfoGS(giDCBGS);
   if ToolError = 0 then begin
      if giDCBGS.fileType = OBJ then begin
         dsDCBGS.pCount := 1;
         dsDCBGS.pathName := @fName;
         DestroyGS(dsDCBGS);
         end; {if}
      end {if}
   else
      done := true;
   suffix := succ(suffix);
until done;
end; {DestroySuffixes}


procedure CloseSeg;

{ close out the current segment                                 }
{                                                               }
{ variables:                                                    }
{       objHandle - segment handle                              }
{       objLen - used bytes in the segment                      }
{       objPtr - set to point to a fresh segment                }

var
   longPtr: ^longint;                   {used to set the block count}

begin {CloseSeg}
longPtr := pointer(objPtr);             {set the block count}
longPtr^ := segDisp;
objLen := objLen + segDisp;             {update the length of the obj file}
objPtr := pointer(ord4(objHandle^)+objLen); {set objPtr}
segStart := objPtr;
if objLen = buffSize then
   PurgeObjBuffer;
end; {CloseSeg}


procedure FindSuffix {var name: gsosOutString; var ch: char};
          
{ find the next available alphabetic suffix                     }
{                                                               }
{ parameters:                                                   }
{       ch - addr to place suffix character                     }
{       name - root name of suffix to find                      }

var
   done: boolean;                       {loop termination test}
   giDCBGS: getFileInfoOSDCB;		{dcb for Get_File_Info call}

   fName: gsosInString;			{work file name}

begin {FindSuffix}
ch := 'a';
done := false;
repeat
   fName := name.theString;
   if fName.size > maxPath-2 then
      fName.size := maxPath-2;
   fName.theString[fName.size+1] := '.';
   fName.theString[fName.size+2] := ch;
   fName.size := fName.size + 2;
   giDCBGS.pCount := 12;
   giDCBGS.optionList := nil;
   giDCBGS.pathName := @fName;
   GetFileInfoGS(giDCBGS);
   if ToolError = 0 then
      ch := succ(ch)
   else
      done := true;
until done;
end; {FindSuffix}


procedure Header {name: stringPtr; kind: integer; lengthCode: integer};

{ write a segment header to the output file                     }
{                                                               }
{ parameters:                                                   }
{       name - name of the segment                              }
{       kind - segment kind                                     }
{       lengthCode - code bank size code; bank size div $10000  }


var
   i: integer;                          {loop var}
   len: integer;                        {length of string}

begin {Header}
OpenSeg;                                {start the new segment}
blkcnt := 0; segdisp := 0;
for i := 1 to 12 do                     {blkcnt,resspc,length}
   Out(0);
Out(0);					{unused}
Out(0);                                 {lablen}
Out(4);                                 {numlen}
Out(2);                                 {version}
Out2(0); Out2(ord(lengthcode=0));       {cbanksize}
Out2(kind|segmentKind);			{kind}
for i := 1 to 9 do                 {unused,org,align,numsex,unused,segnum,entry}
   Out2(0);
len := length(name^);                   {dispname,dispdata}
Out2($30); Out2($3B+len);
Out2(0); Out2(0);			{temporg}
for i := 1 to 10 do                     {write the segment name}
   Out(ord(currentSegment[i]));
currentSegment := defaultSegment;       {revert to default segment name}
Out(len);                               {segname}
for i := 1 to len do
   Out(ord(name^[i]));
end; {Header}


procedure OpenSeg;

{ create a new segment and mark its beginning                   }

begin {OpenSeg}
segDisp := 0;
segStart := objPtr;
end; {OpenSeg}


procedure OpenObj {var name: gsosOutString};

{ open a new obj file with the indicated file name              }
{                                                               }
{ parameters:                                                   }
{       name - object file name                                 }

var
   dsDCBGS: destroyOSDCB;		{dcb for Destroy call}
   giDCBGS: getFileInfoOSDCB;		{dcb for Get_File_Info call}

begin {OpenObj}
{the file is not spooled (yet)}
spoolRefnum := 0;

{if there is an existing file, delete it}
if memoryCompile then begin
   giDCBGS.pCount := 12;
   giDCBGS.pathName := @name.theString;
   GetFileInfoGS(giDCBGS);
   if ToolError = 0 then
      if giDCBGS.fileType = OBJ then begin
         dsDCBGS.pCount := 1;
         dsDCBGS.pathName := @name.theString;
         DestroyGS(dsDCBGS);
         end; {if}
   end; {if}

{allocate memory for an initial buffer}
objHandle := pointer(NewHandle(buffSize, userID, $8000, nil));

{set up the buffer variables}
if ToolError = 0 then begin
   objLen := 0;
   objPtr := objHandle^;
   end {if}
else
   TermError(5);

{save the object file name}
objFile := name;
end; {OpenObj}


procedure Purge;

{ write any constant bytes to the output buffer                 }

var
   i: integer;                          {loop variable}

begin {Purge}
if cBuffLen <> 0 then begin
   Out(cBuffLen);
   for i := 0 to cBuffLen-1 do
      COut(cBuff[i]);
   cBuffLen := 0;
   end; {if}
end; {Purge}

end.

{$append 'objout2.asm'}
