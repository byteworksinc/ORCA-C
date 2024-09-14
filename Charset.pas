{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Character set handling routines                              }
{                                                               }
{  This module handles different character sets and performs    }
{  conversions between them.                                    }
{                                                               }
{  Externally available procedures:                             }
{                                                               }
{  ConvertMacRomanToUCS - convert MacRoman character to UCS     }
{  ConvertUCSToMacRoman - convert UCS character to MacRoman     }
{                                                               }
{---------------------------------------------------------------}

unit Charset;

{$LibPrefix '0/obj/'}

interface

{$segment 'SCANNER'}

uses CCommon, Table;

const
   maxUCSCodePoint = $10ffff;           {Maximum Unicode code point}
   maxPlane = 16;                       {Maximum Unicode plane}

type
   ucsCodePoint = 0..maxUCSCodePoint;
   utf8Rec = record
      length: integer;
      bytes: packed array [1..4] of byte;
      end;
   utf16Rec = record
      length: integer;
      codeUnits: packed array [1..2] of integer;
      end;


function ConvertMacRomanToUCS(ch: char): ucsCodePoint;

{ convert a character from MacRoman charset to UCS (Unicode)     }
{                                                                }
{ Returns UCS code point value for the character.                }


function ConvertUCSToMacRoman(ch: ucsCodePoint): integer;

{ convert a character from UCS (Unicode) to MacRoman charset     }
{                                                                }
{ Returns ordinal value of the character, or -1 if it can't be   }
{ converted.                                                     }


procedure UTF16Encode(ch: ucsCodePoint; var utf16: utf16Rec);

{ Encode a UCS code point in UTF-16                              }
{                                                                }
{ ch - the code point                                            }
{ utf16 - set to the UTF-16 representation of the code point     }


procedure UTF8Encode(ch: ucsCodePoint; var utf8: utf8Rec);

{ Encode a UCS code point in UTF-8                               }
{                                                                }
{ ch - the code point                                            }
{ utf16 - set to the UTF-8 representation of the code point      }


function ValidUCNForIdentifier(ch: ucsCodePoint; initial: boolean): boolean;

{ Check if a code point is valid for a UCN in an identifier      }
{                                                                }
{ ch - the code point                                            }
{ initial - is this UCN the initial element of the identifier?   }

{----------------------------------------------------------------}

implementation

function ConvertMacRomanToUCS{(ch: char): ucsCodePoint};

{ convert a character from MacRoman charset to UCS (Unicode)     }
{                                                                }
{ Returns UCS code point value for the character.                }

begin {ConvertMacRomanToUCS}
if ord(ch) < $80 then
   ConvertMacRomanToUCS := ord(ch)
else if ord(ch) <= $ff then
   ConvertMacRomanToUCS := ord4(macRomanToUCS[ord(ch)]) & $0000ffff
else
   ConvertMacRomanToUCS := $00fffd; {invalid input => REPLACEMENT CHARACTER}
end; {ConvertMacRomanToUCS}


function ConvertUCSToMacRoman{(ch: ucsCodePoint): integer};

{ convert a character from UCS (Unicode) to MacRoman charset     }
{                                                                }
{ Returns ordinal value of the character, or -1 if it can't be   }
{ converted.                                                     }

label 1;

var
   i: $80..$ff;                         {loop index}
   ch16bit: integer;                    {16-bit version of ch (maybe negative)}

begin {ConvertUCSToMacRoman}
if ch < $80 then
   ConvertUCSToMacRoman := ord(ch)
else begin
   if ch <= $00ffff then begin
      ch16bit := ord(ch);
      for i := $80 to $ff do begin
         if macRomanToUCS[i] = ch16Bit then begin
            ConvertUCSToMacRoman := i;
            goto 1;
            end {if}
         end; {for}
      end; {if}
   ConvertUCSToMacRoman := -1;
   end; {else}
1:
end; {ConvertUCSToMacRoman}


procedure UTF16Encode{ch: ucsCodePoint; var utf16: utf16Rec};

{ Encode a UCS code point in UTF-16                              }
{                                                                }
{ ch - the code point                                            }
{ utf16 - set to the UTF-16 representation of the code point     }

begin {UTF16Encode}
if ch <= $00ffff then begin
   utf16.length := 1;
   utf16.codeUnits[1] := ord(ch);
   end {if}
else begin
   utf16.length := 2;
   ch := ch - $010000;
   utf16.codeUnits[1] := $D800 | ord(ch >> 10);
   utf16.codeUnits[2] := $DC00 | ord(ch & $03ff);
   end; {else}
end; {UTF16Encode}


procedure UTF8Encode{ch: ucsCodePoint; var utf8: utf8Rec};

{ Encode a UCS code point in UTF-8                               }
{                                                                }
{ ch - the code point                                            }
{ utf16 - set to the UTF-8 representation of the code point      }

begin {UTF8Encode}
if ch <= $00007f then begin
   utf8.length := 1;
   utf8.bytes[1] := ord(ch);
   end {if}
else if ch <= $0007ff then begin
   utf8.length := 2;
   utf8.bytes[1] := $C0 | ord(ch >> 6);
   utf8.bytes[2] := $80 | ord(ch & $3f)
   end {else if}
else if ch <= $00ffff then begin
   utf8.length := 3;
   utf8.bytes[1] := $E0 | ord(ch >> 12);
   utf8.bytes[2] := $80 | ord((ch >> 6) & $3f);
   utf8.bytes[3] := $80 | ord(ch & $3f);
   end {else if}
else begin
   utf8.length := 4;
   utf8.bytes[1] := $F0 | ord(ch >> 18);
   utf8.bytes[2] := $80 | ord((ch >> 12) & $3f);
   utf8.bytes[3] := $80 | ord((ch >> 6) & $3f);
   utf8.bytes[4] := $80 | ord(ch & $3f);
   end; {else}
end; {UTF8Encode}


function XID_Start(ch: ucsCodePoint): boolean;

{ Check if a Unicode code point has the XID_Start property.      }

label 1;

var
   plane: integer;
   low16: longint;
   index: integer;

begin {XID_Start}
XID_Start := false;
plane := ord(ch >> 16);
low16 := ch & $0000FFFF;

if (plane < 0) or (plane > maxPlane) then
   goto 1;

for index := XID_Start_PlaneStart[plane] to XID_Start_PlaneStart[plane+1]-1 do
   begin
   if (low16 >= (XID_Start_Table[index].min & $0000FFFF))
      and (low16 <= (XID_Start_Table[index].max & $0000FFFF)) then begin
      XID_Start := true;
      goto 1;
      end; {if}
   end; {for}
1:
end; {XID_Start}


function XID_Continue(ch: ucsCodePoint): boolean;

{ Check if a Unicode code point has the XID_Continue property.   }

label 1;

var
   plane: integer;
   low16: longint;
   index: integer;

begin {XID_Continue}
if XID_Start(ch) then begin
   XID_Continue := true;
   goto 1;
   end; {if}

XID_Continue := false;
plane := ord(ch >> 16);
low16 := ch & $0000FFFF;

if (plane < 0) or (plane > maxPlane) then
   goto 1;

for index := XID_Continue_PlaneStart[plane]
   to XID_Continue_PlaneStart[plane+1]-1 do begin
   if (low16 >= (XID_Continue_Table[index].min & $0000FFFF))
      and (low16 <= (XID_Continue_Table[index].max & $0000FFFF)) then begin
      XID_Continue := true;
      goto 1;
      end; {if}
   end; {for}
1:
end; {XID_Continue}


function ValidUCNForIdentifier{(ch: ucsCodePoint; initial: boolean): boolean};

{ Check if a code point is valid for a UCN in an identifier      }
{                                                                }
{ ch - the code point                                            }
{ initial - is this UCN the initial element of the identifier?   }

begin {ValidUCNForIdentifier}
if cStd < c23 then begin
   {See C17 Annex D}
   ValidUCNForIdentifier := false;
   if    (ch = $0000A8)
      or (ch = $0000AA)
      or (ch = $0000AD)
      or (ch = $0000AF)
      or ((ch >= $0000B2) and (ch <= $0000B5))
      or ((ch >= $0000B7) and (ch <= $0000BA))
      or ((ch >= $0000BC) and (ch <= $0000BE))
      or ((ch >= $0000C0) and (ch <= $0000D6))
      or ((ch >= $0000D8) and (ch <= $0000F6))
      or ((ch >= $0000F8) and (ch <= $0000FF))
      or ((ch >= $000100) and (ch <= $00167F))
      or ((ch >= $001681) and (ch <= $00180D))
      or ((ch >= $00180F) and (ch <= $001FFF))
      or ((ch >= $00200B) and (ch <= $00200D))
      or ((ch >= $00202A) and (ch <= $00202E))
      or ((ch >= $00203F) and (ch <= $002040))
      or (ch = $002054)
      or ((ch >= $002060) and (ch <= $00206F))
      or ((ch >= $002070) and (ch <= $00218F))
      or ((ch >= $002460) and (ch <= $0024FF))
      or ((ch >= $002776) and (ch <= $002793))
      or ((ch >= $002C00) and (ch <= $002DFF))
      or ((ch >= $002E80) and (ch <= $002FFF))
      or ((ch >= $003004) and (ch <= $003007))
      or ((ch >= $003021) and (ch <= $00302F))
      or ((ch >= $003031) and (ch <= $00303F))
      or ((ch >= $003040) and (ch <= $00D7FF))
      or ((ch >= $00F900) and (ch <= $00FD3D))
      or ((ch >= $00FD40) and (ch <= $00FDCF))
      or ((ch >= $00FDF0) and (ch <= $00FE44))
      or ((ch >= $00FE47) and (ch <= $00FFFD))
      or ((ch >= $010000) and (ch <= $01FFFD))
      or ((ch >= $020000) and (ch <= $02FFFD))
      or ((ch >= $030000) and (ch <= $03FFFD))
      or ((ch >= $040000) and (ch <= $04FFFD))
      or ((ch >= $050000) and (ch <= $05FFFD))
      or ((ch >= $060000) and (ch <= $06FFFD))
      or ((ch >= $070000) and (ch <= $07FFFD))
      or ((ch >= $080000) and (ch <= $08FFFD))
      or ((ch >= $090000) and (ch <= $09FFFD))
      or ((ch >= $0A0000) and (ch <= $0AFFFD))
      or ((ch >= $0B0000) and (ch <= $0BFFFD))
      or ((ch >= $0C0000) and (ch <= $0CFFFD))
      or ((ch >= $0D0000) and (ch <= $0DFFFD))
      or ((ch >= $0E0000) and (ch <= $0EFFFD))
      then ValidUCNForIdentifier := true;
   
   if initial then
      if    ((ch >= $000300) and (ch <= $00036F))
         or ((ch >= $001DC0) and (ch <= $001DFF))
         or ((ch >= $0020D0) and (ch <= $0020FF))
         or ((ch >= $00FE20) and (ch <= $00FE2F))
         then ValidUCNForIdentifier := false;
      end {if}
else begin
   {C23 rules}
   ValidUCNForIdentifier := false;
   if ch >= $0000A0 then
      if XID_Start(ch) or (not initial and XID_Continue(ch)) then
         ValidUCNForIdentifier := true;
   end; {else}
end; {ValidUCNForIdentifier}

end.
