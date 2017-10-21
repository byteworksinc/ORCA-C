{$optimize 7}
{---------------------------------------------------------------}
{                                                               }
{  Memory Manager                                               }
{                                                               }
{  This memory manager provides a stack-based memory allocation }
{  and deallocation mechanism to allow compact symbol tables    }
{  that can be disposed of with a single call after a function  }
{  has been compiled.  Two separate stacks, or pools, are       }
{  available.  The local pool is typically disposed of when     }
{  the compilation of a function is complete.  It is used for   }
{  local memory allocations such as local strings and symbols.  }
{  The global pool is used for global values like macro         }
{  definitions and global symbols.                              }
{                                                               }
{  External Variables:                                          }
{       localID - userID for the local pool                     }
{       globalID - userID for the global pool                   }
{                                                               }
{  External Subroutines:                                        }
{       DisposeLocalPool - dump the local memory pool           }
{       Calloc - clear and allocate memory                      }
{       GCalloc - allocate & clear memory from the global pool  }
{       GInit - initialize a global pool                        }
{       GMalloc - allocate memory from the global pool          }
{       LInit - initialize a local pool                         }
{       LMalloc - allocate memory from the local pool           }
{       Malloc - allocate memory                                }
{       MMQuit - Dispose of memory allocated with private user  }
{               IDs                                             }
{                                                               }
{---------------------------------------------------------------}

unit MM;

{$LibPrefix '0/obj/'}

interface

uses CCommon;

var
   localID,globalID: integer;           {user ID's for the local & global pools}

{---------------------------------------------------------------}

function Calloc (bytes: integer): ptr; extern;

{ Allocate memory from a pool and set it to 0.                  }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }
{                                                               }
{ Globals:                                                      }
{       useGlobalPool - should the memory come from the global  }
{               (or local) pool                                 }


function GCalloc (bytes: integer): ptr; extern;

{ Allocate and clear memory from the global pool.               }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }


procedure GInit;

{ Initialize a global pool                                      }


function GMalloc (bytes: integer): ptr;

{ Allocate memory from the global pool.                         }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }


procedure LInit;

{ Initialize a local pool                                       }


function LMalloc (bytes: integer): ptr;

{ Allocate memory from the local pool.                          }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }


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


procedure MMQuit;

{ Dispose of memory allocated with private user IDs             }

{---------------------------------------------------------------}

implementation

const
   poolSize      = 4096;                {size of a memory pool}

var
   globalPtr: ptr;                      {pointer to the next free global byte}
   globalSize: integer;                 {bytes remaining in the global pool}
   localPtr: ptr;                       {pointer to the next free local byte}
   localSize: integer;                  {bytes remaining in the local pool}

{---------------------------------------------------------------}

                                        {GS memory manager}
                                        {-----------------}

 procedure DisposeAll (userID: integer); tool($02, $11);
 
 function NewHandle (blockSize: longint; userID, memAttributes: integer;
                     memLocation: ptr): handle; tool($02, $09);

{---------------------------------------------------------------}

procedure GInit;

{ Initialize a global pool                                      }

var
   myhandle: handle;                    {for dereferencing the block}

begin {GInit}
globalID := UserID | $0200;             {set the global user ID}
DisposeAll(globalID);                   {dump any old pool areas}
globalSize := poolSize;                 {allocate a new pool}
myhandle := NewHandle(poolSize, globalID, $C010, nil);
if ToolError <> 0 then TermError(5);
globalPtr := myhandle^;
end; {GInit}


function GMalloc {bytes: integer): ptr};

{ Allocate memory from the global pool.                         }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }

var
   myhandle: handle;                    {for dereferencing the block}

begin {GMalloc}
if bytes > globalSize then begin        {allocate a new pool, if needed}
   globalSize := poolSize;
   myhandle := NewHandle(poolSize, globalID, $C010, nil);
   if ToolError <> 0 then TermError(5);
   globalPtr := myhandle^;
   end; {if}
GMalloc := globalPtr;                   {allocate memory from the pool}
globalSize := globalSize - bytes;
globalPtr := pointer(ord4(globalPtr) + bytes);
end; {GMalloc}


procedure LInit;

{ Initialize a local pool                                       }

var
   myhandle: handle;                    {for dereferencing the block}

begin {LInit}
localID := UserID | $0400;              {set the local user ID}
DisposeAll(localID);                    {dump any old pool areas}
localSize := poolSize;                  {allocate a new pool}
myhandle := NewHandle(poolSize, localID, $C010, nil);
if ToolError <> 0 then TermError(5);
localPtr := myhandle^;
end; {LInit}


function LMalloc {bytes: integer): ptr};

{ Allocate memory from the local pool.                          }
{                                                               }
{ Parameters:                                                   }
{       bytes - number of bytes to allocate                     }
{       ptr - points to the first byte of the allocated memory  }

var
   myhandle: handle;                    {for dereferencing the block}

begin {LMalloc}
if bytes > localSize then begin         {allocate a new pool, if needed}
   localSize := poolSize;
   myhandle := NewHandle(poolSize, localID, $C010, nil);
   if ToolError <> 0 then TermError(5);
   localPtr := myhandle^;
   end; {if}
LMalloc := localPtr;                    {allocate memory from the pool}
localSize := localSize - bytes;
localPtr := pointer(ord4(localPtr) + bytes);
end; {LMalloc}


procedure MMQuit;

{ Dispose of memory allocated with private user IDs             }

begin {MMQuit}
DisposeAll(globalID);
DisposeAll(localID);
end; {MMQuit}

end.

{$append 'mm.asm'}
