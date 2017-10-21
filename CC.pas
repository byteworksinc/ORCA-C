{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  ORCA/C                                                       }
{                                                               }
{  A C compiler for the Apple IIGS.                             }
{                                                               }
{  Copyright 1989,1990                                          }
{  Byte Works, Inc.                                             }
{                                                               }
{  Mike Westerfield                                             }
{                                                               }
{---------------------------------------------------------------}

{$stacksize $1800}

program cc(output);

{$LibPrefix '0/obj/'}

uses CCommon, CGI, Scanner, Header, Symbol, MM, Expression, Parser, Asm;

{$segment 'cc'}

var
   i: 1..maxPath;			{loop/index variable}
   vDCBGS: versionDCBGS;		{for checking the version number}


procedure DisposeAll (userID: integer); tool($02, $11);

procedure SystemQuitFlags (flags: integer); extern;


begin {cc}
{make sure we quit with restart set}
SystemQuitFlags($4000);

{get the command line info}
includeFileGS.maxSize := maxPath+4;
includeFileGS.theString.size := 0;
for i := 1 to maxPath do
   includeFileGS.theString.theString[i] := chr(0);
outFileGS := includeFileGS;
partialFileGS := includeFileGS;
infoStringGS := includeFileGS;
with liDCBGS do begin
   pCount := 11;
   sFile := @includeFileGS;
   dFile := @outFileGS;
   namesList := @partialFileGS;
   iString := @infoStringGS;
   end; {with}
GetLInfoGS(liDCBGS);
sourceFileGS := includeFileGS;
doingPartial := partialFileGS.theString.size <> 0;
with liDCBGS do begin
   enterEditor := pFlags & flag_e <> 0;    {enter editor on terminal errors?}
   ignoreSymbols := mFlags & flag_i <> 0;  {ignore symbol file?}
   list := pFlags & flag_l <> 0;           {list the source file?}
   memoryCompile := pflags & flag_m <> 0;  {memory based compile?}
   progress := mflags & flag_p = 0;        {write progress info?}
   rebuildSymbols := mflags & flag_r <> 0; {rebuild symbol file?}
   printSymbols := pflags & flag_s <> 0;   {print the symbol table?}
   terminalErrors := pFlags & flag_t <> 0; {all errors terminal?}
   wait := pFlags & flag_w <> 0;           {wait when an error is found?}
   cLineOptimize := pFlags & flag_o <> 0; {turn optimizations on?}
   end; {liDCB}
if list then                               {we don't need both...}
   progress := false;

{check the version number}
vDCBGS.pCount := 1;
VersionGS(vDCBGS);
if vDCBGS.version[1] < '2' then
   TermError(10);

{write the header}
if list or progress then begin
   writeln('ORCA/C ', versionStr);
   writeln;
   end; {if}

{read the source file}
ReadFile;
languageNumber := long(ffDCBGS.auxType).lsw; {set the default language number}

{initialize the various modules}
LInit;                                  {initialize the memory pools}
GInit;
useGlobalPool := true;
InitCCommon;				{initialize the common module}
                                        {initialize the scanner}
InitScanner(bofPtr,pointer(ord4(bofPtr)+ffDCBGS.fileLength));
InitParser;                             {initialize the parser}
InitExpression;                         {initialize the expression evaluator}
InitSymbol;                             {initialize the symbol table handler}
InitAsm;                                {initialize the assembler}
CodeGenScalarInit;                      {initialize the code generator}
with liDCBGS do				{generate debug code?}
   if pFlags & flag_d <> 0 then begin
      debugFlag := true;
      profileFlag := true;
      end; {if}

{compile the program}
InitHeader(includeFileGS);		{read any precompiled headers}
NextToken;                              {get the first token in the program}
while token.kind <> eofsy do begin      {compile the program}
   if doingFunction then
      DoStatement
   else if (token.kind in [autosy,externsy,registersy,staticsy,typedefsy,
                           unsignedsy,signedsy,intsy,longsy,charsy,shortsy,
                           floatsy,doublesy,compsy,extendedsy,enumsy,
                           structsy,unionsy,typedef,voidsy,volatilesy,
                           constsy,ident,asmsy,pascalsy,asmsy,segmentsy])
      then
      DoDeclaration(false)
   else begin
      Error(26);
      NextToken;
      end; {else}
   end; {while}
if doingFunction then                   {check for unclosed function}
   Error(23);
{init the code generator (if it needs it)}
if not codegenStarted and (liDCBGS.kFlag <> 0) then begin
   CodeGenInit (@outFileGS, liDCBGS.kFlag, doingPartial);
   liDCBGS.kFlag := 3;
   codegenStarted := true;
   end; {if}
DoGlobals;                              {create the ~GLOBALS and ~ARRAYS segments}

{shut down the compiler}
TermHeader;				{make sure the compiled header file is closed}
CheckStaticFunctions;                   {check for undefined functions}
ffDCBGS.action := 7;			{purge the source file}
ffDCBGS.pcount := 14;
ffDCBGS.pathName := @includeFileGS.theString;
FastFileGS(ffDCBGS);
if ToolError <> 0 then begin
   sourceFileGS := includeFileGS;
   TermError(2);
   end; {if}
TermScanner;                            {shut down the scanner}
StopSpin;
if (numErrors <> 0) or list or progress then begin
   writeln;				{write the number of errors}
   if numErrors = 1 then
      writeln('1 error found.')
   else
      writeln(numErrors:1, ' errors found.');
   end; {if}
if list or progress then                {leave a blank line}
   writeln;
if codegenStarted then                  {shut down the code generator}
   CodeGenFini;
TermParser;                             {shut down the parser}
if numErrors = 0 then begin             {set up the return parameters}
   if not switchLanguages then begin
      if liDCBGS.kFlag = 0 then
         liDCBGS.lops := 0
      else
         liDCBGS.lops := liDCBGS.lops & $FFFE;
      liDCBGS.sFile := @outFileGS;
      end; {if}
   end {if}
else
   liDCBGS.lops := 0;
MMQuit;                                 {dispose of our memory pools}
with liDCBGS do begin			{return to the shell}
   sFile := pointer(ord4(sFile)+2);
   dFile := pointer(ord4(dFile)+2);
   namesList := pointer(ord4(namesList)+2);
   iString := pointer(ord4(iString)+2);
   end; {with}
SetLInfoGS(liDCBGS);
StopSpin;
end. {cc}
