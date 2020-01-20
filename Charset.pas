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
   maxUCSCodePoint = $10ffff;

type
   ucsCodePoint = 0..maxUCSCodePoint;


function ConvertMacRomanToUCS(ch: char): ucsCodePoint;

{ convert a character from MacRoman charset to UCS (Unicode)     }
{                                                                }
{ Returns UCS code point value for the character.                }

function ConvertUCSToMacRoman(ch: ucsCodePoint): integer;

{ convert a character from UCS (Unicode) to MacRoman charset     }
{                                                                }
{ Returns ordinal value of the character, or -1 if it can't be   }
{ converted.                                                     }

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

end.
