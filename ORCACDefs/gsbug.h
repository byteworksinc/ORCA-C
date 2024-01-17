/********************************************
; File: GSBug.h
;
;
; Copyright Apple Computer, Inc. 1991
; All Rights Reserved
;
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __GSBUG__
#define __GSBUG__

/* Error Codes */
#define debugUnImpErr 0xFF01
#define debugBadSelErr 0xFF02
#define debugDupBreakErr 0xFF03
#define debugBreakNotSetErr 0xFF04
#define debugTableFullErr 0xFF05
#define debugTableEmptyErr 0xFF06
#define debugBreaksInErr 0xFF07

#define dgiProgramCounter 0  /* for DebugGetInfo */

extern pascal Word DebugVersion(void) inline(0x04FF,dispatcher);
extern pascal Word DebugStatus(void) inline(0x06FF,dispatcher);
extern pascal void DebugStr(Pointer) inline(0x09FF,dispatcher);
extern pascal void SetMileStone(Pointer) inline(0x0AFF,dispatcher);
extern pascal void DebugSetHook(VoidProcPtr) inline(0x0BFF,dispatcher);
extern pascal LongWord DebugGetInfo(Word) inline(0x0CFF,dispatcher);

#endif
