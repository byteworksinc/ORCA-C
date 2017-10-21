{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  ORCA Code Generator Common                                   }
{                                                               }
{  This unit contains the command constants, types,             }
{  variables and procedures used throughout the code            }
{  generator, but which are not available to the compiler.      }
{                                                               }
{---------------------------------------------------------------}
{                                                               }
{  These routines are defined in the compiler, but used from    }
{  the code generator.                                          }
{                                                               }
{  Error - flag an error                                        }
{  CMalloc - Clear and allocate memory from a pool.             }
{  Malloc - Allocate memory from a pool.                        }
{                                                               }
{---------------------------------------------------------------}

unit CGC;

interface

{$LibPrefix '0/obj/'}

uses CCommon, CGI;

{$segment 'cg'}

type
                                        {pcode code generation}
                                        {---------------------}
   realrec = record                     {used to convert from real to in-SANE}
      itsReal: double;
      inSANE: packed array[1..10] of byte;
      inCOMP: packed array[1..8] of byte;
      end;

var
                                        {msc}
                                        {---}
   blkcnt: integer;                     {number of bytes in current segment}

                                        {buffers}
                                        {-------}
   cbufflen: 0..maxcbuff;               {number of bytes now in cbuff}
   segDisp: integer;                    {disp in the current segment}

{-- Global subroutines -----------------------------------------}

procedure CnvSC (rec: realrec); extern;

{ convert a real number to SANE comp format                     }
{                                                               }
{ parameters:                                                   }
{       rec - record containing the value to convert; also      }
{               has space for the result                        }


procedure CnvSX (rec: realrec); extern;

{ convert a real number to SANE extended format                 }
{                                                               }
{ parameters:                                                   }
{       rec - record containing the value to convert; also      }
{               has space for the result                        }


procedure InitLabels; extern;

{ initialize the labels array for a procedure                   }
{								}
{ Note: also defined in CGI.pas					}

{-- These routines are defined in the compiler, but used from cg --}

function Calloc (bytes: integer): ptr; extern;

{ Allocate memory from a pool and clear it.                     }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }
{                                                               }
{ Globals:                                                      }
{       useGlobalPool - should the memory come from the global  }
{               (or local) pool                                 }


procedure Error (err: integer); extern;

{ flag an error                                                 }
{                                                               }
{ err - error number                                            }


{procedure Error2 (loc, err: integer); extern; {debug} {in scanner.pas}

{ flag an error                                                 }
{                                                               }
{ loc - error location                                          }
{ err - error number                                            }


function Malloc (bytes: integer): ptr; extern;

{ Allocate memory from a pool.                                  }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }
{                                                               }
{ Globals:                                                      }
{       useGlobalPool - should the memory come from the global  }
{               (or local) pool                                 }

{---------------------------------------------------------------}

implementation

end.

{$append 'CGC.asm'}
