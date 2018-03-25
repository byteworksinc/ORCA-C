

# How the Debugger Works

## COP Vector

The ORCA compilers and debuggers use an invasive debug mechanism that depends on the compilers inserting `COP` instructions in the code stream.  When the Apple IIGS executes a `COP` instruction it calls a `COP` handler; the debuggers insert themselves in the list of programs that are called when a `COP` instruction is encountered.

Several `COP` instructions are used.  There are separate `COP` instructions for executing a line of source code, breaking, stepping past a line, creating symbol tables, entering and leaving subroutines, and for passing messages to the debugger.  The various `COP` instructions are summarized in table A-1, and explained in detail below.

### Table A-1:  Debugger COP Instructions

    00	Indicates a new source code line.
    01	Indicates a hard-coded break point.
    02	Indicates a memory protection point.
    03	Used when a new subroutine starts.
    04	Marks the end of a subroutine.
    05	Creates a symbol table.
    06	Switches the source file.
    07	Sends a message to the debugger.

## COP 00

`COP 00` indicates that a new source line has been reached and that the debugger must take appropriate action, such as updating the source listing position and variables window.

The `COP` instruction is followed by the line number.  In assembly language, this would look like:

    	cop	$00
    	dc	i'16'

## COP 01

`COP 01`, like `COP 00`, marks the start of an executable line of source code.  The difference is that `COP 01` also indicates that the user has marked the line as a hard-coded break point, so the debugger should break at the line.

The `COP` instruction is followed by the line number.  In assembly language, this would look like:

    	cop	$01
    	dc	i'16'

## COP 02

`COP 02`, like `COP 00`, marks the start of an executable line of source code.  The difference is that `COP 02` marks a protected line, indicating that the debugger should not take the normal action of updating the debugger display.  The only reason for putting `COP 02` instructions in the code is to give the debugger a chance to override the memory protection status of a line.  For example, the ORCA/Debugger allows manual break points to override these hard-coded memory protection points.

The COP instruction is followed by the line number.  In assembly language, this would look like:

    	cop	$02
    	dc	i'16'

## COP 03

This instruction is used right after a subroutine is called, and marks entry into the subroutine.  The `COP` instruction is followed by the four byte address of the subroutine name, stored with a length-byte prefix (P-string format)

    	cop	$03
    	dc	a4'name'
    
    	...
    
    name	dc	i1'15',c'Subroutine Name'

## COP 04

This instruction marks the end of a subroutine.  It should appear right after the last executable line in the subroutine, but before the code that wipes out the stack frame and returns to the caller.

Debuggers will remove any symbol tables that have been created since the last `COP 03` instruction.

Every `COP 04` instruction must match exactly one `COP 03` instruction.  If the debugger encounters a `COP 03` and never finds a `COP 04`, or encounters a `COP 04` without first hitting a `COP 03`, it could crash or corrupt memory.

There is no operand for this instruction.  In assembly language, it looks like this:

    	cop	$04


## COP 05

`COP 05` provides access to a subroutine’s symbol table.  It can be used after a call to vectors 3 or 6, but must be used before any calls to vectors 0, 1, and 2.  The debugger’s symbol table is organized as shown in Figure A-1.

### Figure A-1:  Debugger Symbol Table Format

    $00 Displacement to the end of the table
    --- repeat for each variable
    | $02 Pointer to the variable name. The name is stored in P-string format.
    | $06 Pointer to the variable's address. If the variable is an array, then this points to the first element.
    | $0a Address flag;  0 -> direct page, 1 -> long address
    | $0b Format of value; see table A-2
    | $0c Number of subscripts; 0 if not array
    | --- repeat for each array dimension
    | | $0e Minimum subscript value
    | | $12 Maximum subscript value
    | | $16 Size of each element

The symbol table follows right after the `COP 05` instruction.

The following table shows the format used to store the variable’s current value:

### Table A-2:  Debugger Symbol Table Format Codes

    Value   Format
    0       1-byte integer
    1       2-byte integer
    2       4-byte integer
    3       single-precision real
    4       double-precision real
    5       extended-precision real
    6       C-style string
    7       Pascal-style string
    8       character
    9       boolean
    10      SANE COMP number
    11      pointer
    12      structure, union or record
    13      derived type
    14      object


One-byte integers default to unsigned, while two-byte and four-byte integers default to signed format.  `OR`ing the format code with `$40` reverses this default, giving signed one-byte integers or unsigned four-byte integers.  (The signed flag is not supported by PRIZM 1.1.3.)

A pointer to a scalar type (1-10) is indicated by `OR`ing the value’s format code with `$80`. For example, `$82` would be a pointer to a 4-byte integer.


### Value 11, Pointer

The pointer type is intended for use when a pointer to a pointer is needed.  The pointer symbol table entry is followed by a second symbol table entry that describes the value being pointed to.  For example, to describe a pointer to a pointer to a 4-byte integer, a compiler would generate two 12-byte symbol table entries.  The first would contain all of the normal address information, but have a type value of `$0B` (11).  The following entry would have a type value of `$82`.  In this second entry, the name and address fields are unneeded, and should be set to 0.  Only the format field is actually used.

While the reason for creating this type value is to allow pointers to pointers, the type will work for pointers to any other symbol table entry.  `Or`ing the type with `$80 `is still preferred, though, since it saves a symbol table entry.

### Value 12, Structure, Union or Record

This type is followed by a series of symbol table entries describing the fields within the structure, union or record (hereafter referred to as a record).  The field entries are coded exactly like normal symbol table entries, with these exceptions:

1. The address field is a displacement to the field within the record, not the actual address.

2. The one-byte address flag, normally used to tell if the address is a direct page displacement or absolute address, is now used as a flag indicating if there are more entries in the record.  If the byte is 0, the symbol table entry is the last one in the record.  If the byte is 1, the symbol table entry is followed by another field.

There are no restrictions on the type of symbol table entries that can appear as a field.  Specifically, records can contain other records, pointers, or even pointers to other records.

Variant records (C unions) are supported by the pragmatic approach of allowing fields to overlap.  The debugger is perfectly willing to display each and every variant at the same time.  This can lead to some very strange results when variant records are used for their intended purpose of overlapping radically different types of data, but it is also a very useful feature for the other common use of variant records: treating the same binary data as two different kinds of data.  Because the debugger allows all of the fields to be displayed, even if they overlap, a programmer can actually see all of the data formats at the same time.

For an array of records, the array size and subscript information follows the symbol, and the field entries follow the array subscript information.

### Value 13, Derived Type

A derived type is a space-saver.  In a derived type, the subscript field is a displacement past the first symbol table entry.  The debugger uses the type for the symbol table entry at the given displacement.

For example, assume there are three variables in the symbol table, p1, p2 and p3.  Each is a record containing two real values.  It's perfectly legal to create three separate symbol table entries, each with a record.  To save space, though, the best choice is to create a symbol table entry for p1 in the normal way.  Then, for p2 and p3, use a derived type and substitute the displacement of p1 in the symbol table for the subscript count, rather than duplicating the entire record declaration.

Derived types can be used for any type in the symbol table, but for efficiency, they should only be used when the type referred to is one of the multi-entry types (11, pointer; 12, struct; or an array).


### Value 14, Object

Internally, an object is a pointer to a record.  When the user types entries in the debugger, though, accessing an object looks and works just like accessing a record.  The debugger will also allow you to type the name of the object itself, while it will not allow you to type the name of a record P in that case, the debugger prints the actual pointer value for the object.


## COP 06

`COP 06` is used at the start of all subroutines, right after the `COP 03` that marks the start of the subroutine.  (You can put the `COP 06` before or after any `COP 05`, so long as it comes before any `COP 00`, `COP 01` or `COP 02` instructions).  This instruction flags the source file for the subroutine, giving the debugger a chance to switch to the correct source file if it is not already being displayed.  You can also imbed other `COP 06` instructions inside of the subroutine if the subroutine spans several source files.

The `COP 06` instruction is followed by the four-byte address of the full path name of the source file.  The path name is given as a P-string.  The ORCA/Debugger supports path names up to 255 characters long, and allows either / or : characters as separators.  Here’s what the instruction might look like in assembly language:

    	cop	$06
    	dc	a4'name'
    
    	...
    
    name	dc	i1'23',c'/hd/programs/source.pas'


## COP 07

`COP 07` is used to send messages to the debugger.  The first four bytes following the `COP 07` have a fixed format, but the remaining bytes vary from message to message.

The two bytes right after the `COP 07` instruction are the total length of the debugger message, in bytes.  This will always be at least 4.  The next two bytes are the message number.  The message number can be followed by more bytes.

Three messages are currently defined and supported by ORCA/Debugger.  None uses any optional fields, so the length word should be four for all three of these messages.

Message 0 tells the debugger to start patching all debugger `COP` instructions with `JMP` instructions.  This is the message sent by the `DebugFast` utility.  This message must be sent before a program starts to execute – sending this message after a program with debug code starts, but before it finishes, can cause memory corruption or crashes.

Message 1 tells the debugger to stop patching `COP` instructions, reversing the effect of message 0.  The `DebugNoFast` utility sends this message.

Message 2 tells the debugger to treat the next `COP 00` as if it were a `COP 01`.  The `DebugBreak` utility sends this message.

## COP 08

This coprocessor instruction is used to enter global symbols in a top-level symbol table.  For the purpose of debugging, a global symbol is any symbol the compiler writer feels should be available to the programmer for the duration of the debugging session.  For example, in Modula-2, this would be any symbol defined at the top level in a module.

When a debugger encounters the first `COP 08` instruction, it will create a new stack frame above all current stack frames, placing all of the symbols from the symbol table in that stack frame.  Unlike symbols entered with the COP 05 instruction, these symbols will survive a return from the subroutine.  In fact, they will remain available until the program stops executing.

Multiple `COP 08` instructions can be used.  When the debugger encounters a subsequent `COP 08` instruction, any symbols in the symbol table are added to the symbols currently displayed in the top-level table.

While multiple `COP 08` instructions can be used, duplicate symbol tables must not be entered.  The compiler is responsible for insuring that, once symbols from a unit or module have been entered, they are not entered into the debuggers symbol table a second time, even if the subroutine that actually contained the `COP 08` instruction is called again.

PRIZM has no way to resolve multiple symbols with the same name.  For example, if `COP 08` instructions from two different units each enter a symbol with the same name, there is no way to see both of these values, and there isn't even a good way to determine which of the symbols the debugger will actually show when the user examines the symbol.  In general, it is expected that this issue will simply be pointed out to the user.  If the user wants to see both values, one of the names will have to be changed.

In ORCA/Debugger, all of the symbols are displayed, even if there are two symbols with the same name.

While there is no direct prohibition against entering some global variables with COP 05 and some with `COP 08`, debugger displays will be a lot cleaner if all global variables are entered using `COP 08`, and all local variables are entered using `COP 05`.
