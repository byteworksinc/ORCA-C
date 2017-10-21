{$optimize 7}
{---------------------------------------------------------------}
{								}
{  Header							}
{								}
{  Handles saving and reading precompiled headers.		}
{								}
{---------------------------------------------------------------}

unit Header;

{$LibPrefix '0/obj/'}

interface

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

procedure EndInclude {chPtr: ptr};

{ Saves symbols created by the include file			}
{								}
{ Parameters:							}
{    chPtr - chPtr when the file returned			}
{								}
{ Notes:							}
{    1. Call this subroutine right after processing an		}
{       include file.						}
{    2. Declared externally in Symbol.pas			}

begin {EndInclude}
end; {EndInclude}                


procedure FlagPragmas {pragma: pragmas};

{ record the effects of a pragma				}
{								}
{ parameters:							}
{    pragma - pragma to record					}
{								}
{ Notes:							}
{    1. Defined as extern in Scanner.pas			}
{    2. For the purposes of this unit, the segment statement is	}
{	treated as a pragma.					}
          
begin {FlagPragmas}
end; {FlagPragmas}


procedure InitHeader {var fName: gsosOutString};

{ look for a header file, reading it if it exists		}
{								}
{ parameters:							}
{    fName - source file name (var for efficiency)		}

begin {InitHeader}
end; {InitHeader}


procedure StartInclude {name: gsosOutStringPtr};

{ Marks the start of an include file				}
{								}
{ Notes:							}
{    1. Call this subroutine right after opening an include	}
{       file.							}
{    2. Defined externally in Scanner.pas			}

begin {StartInclude}
end; {StartInclude}


procedure TermHeader;

{ Stop processing the header file				}
{								}
{ Note: This is called when the first code-generating		}
{    subroutine is found, and again when the compile ends.  It	}
{    closes any open symbol file, and should take no action if	}
{    called twice.						}

begin {TermHeader}
end; {TermHeader}

end.
