/********************************************
*
* Desk Manager
*
* Copyright Apple Computer, Inc.1986-91
* All Rights Reserved
*
* Copyright 1992, 1993, Bute Works, Inc.
*
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __DESK__
#define __DESK__


/* Error Codes */
#define daNotFound 0x0510               /* desk accessory not found */
#define notSysWindow 0x0511             /* not the system window */
#define deskBadSelector 0x0520         /* bad selector for GetDeskAccInfo */

/* NDA Action Codes */
#define eventAction 0x0001
#define runAction 0x0002
#define cursorAction 0x0003
#define undoAction 0x0005
#define cutAction 0x0006
#define copyAction 0x0007
#define pasteAction 0x0008
#define clearAction 0x0009
#define sysClickAction 0x000A
#define optionalCloseAction 0x000B
#define reOpenAction 0x000C

/* SystemEdit Codes */
#define undoEdit 0x0001
#define cutEdit 0x0002
#define copyEdit 0x0003
#define pasteEdit 0x0004
#define clearEdit 0x0005

/* constants for GetDeskAccInfo */
#define getCDAinfo 0x8000
#define getNDAinfo 0x0000
#define daRefIsWindPtr 0x0001
#define daRefIsIndex 0x0000

/* constants for GetDeskGlobal */
#define deskGlobalWindow 0x0000

/* constants for CallDeskAcc */
#define daCallCDA 0x8000
#define daCallNDA 0x0000
#define daCallInit 0x0002
#define daCallAction 0x0000

/* System Window structure for GetAuxWindInfo */

struct NDASysWindRecord {
   Word status;                         /* use 0, reserved for Desk Mgr */
   LongProcPtr openProc;                /* reserved, use nil */
   ProcPtr closeProc;                   /* pointer to your Close routine */
   ProcPtr actionProc;                  /* pointer to your Action routine */
   ProcPtr initProc;                    /* reserved, use nil */
   Word period;
   Word eventMask;                      /* your event mask, like for an NDA */
   LongWord lastServiced;               /* reserved, use 0 */
   LongWord windowPtr;                  /* reserved, use 0 */
   LongWord ndaHandle;                  /* reserved, use 0 */
   Word memoryID;                       /* your memory ID, important! */
   };
typedef struct NDASysWindRecord NDASysWindRecord, *NDASysWindRecPtr;

extern pascal void DeskBootInit(void) inline(0x0105,dispatcher);
extern pascal void DeskStartUp(void) inline(0x0205,dispatcher);
extern pascal void DeskShutDown(void) inline(0x0305,dispatcher);
extern pascal Word DeskVersion(void) inline(0x0405,dispatcher);
extern pascal void DeskReset(void) inline(0x0505,dispatcher);
extern pascal Boolean DeskStatus(void) inline(0x0605,dispatcher);
extern pascal void ChooseCDA(void) inline(0x1105,dispatcher);
extern pascal void CloseAllNDAs(void) inline(0x1D05,dispatcher);
extern pascal void CloseNDA(Word) inline(0x1605,dispatcher);
extern pascal void CloseNDAbyWinPtr(GrafPortPtr) inline(0x1C05,dispatcher);
extern pascal void CloseNDAByWinPtr(GrafPortPtr) inline(0x1C05,dispatcher);
extern pascal void FixAppleMenu(Word) inline(0x1E05,dispatcher);
extern pascal Pointer GetDAStrPtr(void) inline(0x1405,dispatcher);
extern pascal Word GetNumNDAs(void) inline(0x1B05,dispatcher);
extern pascal void InstallCDA(Handle) inline(0x0F05,dispatcher);
extern pascal void InstallNDA(Handle) inline(0x0E05,dispatcher);
extern pascal Word OpenNDA(Word) inline(0x1505,dispatcher);
extern pascal void RestAll(void) inline(0x0C05,dispatcher);
extern pascal void RestScrn(void) inline(0x0A05,dispatcher);
extern pascal void SaveAll(void) inline(0x0B05,dispatcher);
extern pascal void SaveScrn(void) inline(0x0905,dispatcher);
extern pascal void SetDAStrPtr(Handle, Pointer) inline(0x1305,dispatcher);
extern pascal void SystemClick(EventRecordPtr, GrafPortPtr, Word) inline(0x1705,dispatcher);
extern pascal Boolean SystemEdit(Word) inline(0x1805,dispatcher);
extern pascal Boolean SystemEvent(Word, Long, Long, Point, Word) inline(0x1A05,dispatcher);
extern pascal void SystemTask(void) inline(0x1905,dispatcher);

extern pascal void AddToRunQ(Pointer) inline(0x1F05,dispatcher);
extern pascal void RemoveCDA(Handle) inline(0x2105,dispatcher);
extern pascal void RemoveFromRunQ(Pointer) inline(0x2005,dispatcher);
extern pascal void RemoveNDA(Handle) inline(0x2205,dispatcher);

extern pascal Word CallDeskAcc(Word, Long, Word, Long) inline(0x2405,dispatcher);
extern pascal void GetDeskAccInfo(Word, Long, Word, Ptr) inline(0x2305,dispatcher);
extern pascal LongWord GetDeskGlobal(Word) inline(0x2505,dispatcher);

#endif
