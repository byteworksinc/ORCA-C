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

var
                                        {from scanner.pas}
                                        {----------------}
   charKinds: array[minChar..maxChar] of charEnum; {character kinds}
   charSym: array[minChar..maxChar] of tokenEnum; {symbols for single char symbols}
   reservedWords: array[_Alignassy..whilesy] of string[14]; {reserved word strings}
   wordHash: array[0..25] of tokenEnum; {for hashing reserved words}
   stdcVersion: array[c95..c17] of longint; {__STDC_VERSION__ values}

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
implementation

end.
