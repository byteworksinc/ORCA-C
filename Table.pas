{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Table                                                        }
{                                                               }
{  Initialized arrays and records.                              }
{                                                               }
{---------------------------------------------------------------}

unit Table;

{$LibPrefix '0/obj/'}

interface

uses CCommon;

type
   charRange = record                   {Range of Unicode chars (low 16 bits)}
      min: integer;
      max: integer;
      end;

var
                                        {from scanner.pas}
                                        {----------------}
   charKinds: array[minChar..maxChar] of charEnum; {character kinds}
   charSym: array[minChar..maxChar] of tokenEnum; {symbols for single char symbols}
   reservedWords: array[_Alignassy..whilesy] of string[14]; {reserved word strings}
   keywordCategories: array[_Alignassy..whilesy] of byte; {keyword categories}
   wordHash: array[0..25] of tokenEnum; {for hashing reserved words}
   stdcVersion: array[c95..c23] of longint; {__STDC_VERSION__ values}

                                        {from ASM.PAS}
                                        {------------}
                                        {names of the opcodes}
   names: array[opcode] of packed array[1..3] of char;

                                        {binary values for the opcodes}
   iOpcodes: array[o_clc..o_xce] of byte;
   rOpcodes: array[o_bcc..o_bvs] of byte;
   nOpcodes: array[o_adc..o_tsb,operands] of byte;

                                        {from EXPRESSION.PAS}
                                        {-------------------}
   icp: array[tokenEnum] of byte;       {in-coming priorities}
   isp: array[tokenEnum] of byte;       {in-stack priorities}

                                        {from Charset.pas}
                                        {----------------}
   macRomanToUCS: array[$80..$FF] of integer; {mapping from MacRoman charset to UCS}
                                        {Unicode data tables in CharTables.asm}
   XID_Start_Table: array[0..765] of charRange;
   XID_Continue_Table: array[0..632] of charRange;
   XID_Start_PlaneStart: array[0..17] of integer;
   XID_Continue_PlaneStart: array[0..17] of integer;

implementation

end.
