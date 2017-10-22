/********************************************
*
* Scrap Manager
*
* Copyright Apple Computer, Inc. 1986-91
* All Rights Reserved
*
* Copyright 1992, 1993, Byte Works, Inc.
*
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __SCRAP__
#define __SCRAP__

/* Error Codes */
#define badScrapType 0x1610             /* No scrap of this type. */

/* Scrap Types */
#define textScrap 0x0000
#define picScrap 0x0001
#define sampledSoundScrap 0x0002
#define teStyleScrap 0x0064
#define iconScrap 0x4945
#define maskScrap 0x8001
#define colorTableScrap 0x8002
#define resourceRefScrap 0x8003

/* ShowClipboard flag values */
#define cpOpenWindow 0x8000
#define cpCloseWindow 0x4000

typedef struct scrapInfo {
   Word scrapType;
   LongWord scrapSize;
   Handle scrapHandle;
   };
typedef struct scrapInfo scrapInfo, *scrapInfoPtr, **scrapInfoHndl;

extern pascal void ScrapBootInit(void) inline(0x0116,dispatcher);
extern pascal void ScrapStartUp(void) inline(0x0216,dispatcher);
extern pascal void ScrapShutDown(void) inline(0x0316,dispatcher);
extern pascal Word ScrapVersion(void) inline(0x0416,dispatcher);
extern pascal void ScrapReset(void) inline(0x0516,dispatcher);
extern pascal Boolean ScrapStatus(void) inline(0x0616,dispatcher);
extern pascal void GetScrap(Handle, Word) inline(0x0D16,dispatcher);
extern pascal Word GetScrapCount(void) inline(0x1216,dispatcher);
extern pascal handle GetScrapHandle(Word) inline(0x0E16,dispatcher);
extern pascal Pointer GetScrapPath(void) inline(0x1016,dispatcher);
extern pascal LongWord GetScrapSize(Word) inline(0x0F16,dispatcher);
extern pascal Word GetScrapState(void) inline(0x1316,dispatcher);
extern pascal void LoadScrap(void) inline(0x0A16,dispatcher);
extern pascal void PutScrap(LongWord, Word, Pointer) inline(0x0C16,dispatcher);
extern pascal void SetScrapPath(Pointer) inline(0x1116,dispatcher);
extern pascal void UnloadScrap(void) inline(0x0916,dispatcher);
extern pascal void ZeroScrap(void) inline(0x0B16,dispatcher);

extern pascal void GetIndScrap(Word, Ptr) inline(0x1416,dispatcher);

extern pascal GrafPortPtr ShowClipboard(Word, Rect *) inline(0x1516,dispatcher);
      
#endif
