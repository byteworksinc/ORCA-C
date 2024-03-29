/********************************************
*
* Window Manager
*
* Copyright Apple Computer, Inc. 1986-92
* All Rights Reserved
*
* Copyright 1992, 1993, Byte Works, Inc.
*
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __WINDOW__
#define __WINDOW__

/* Error Codes */
#define paramLenErr 0x0E01              /* first word of parameter list is the wrong size */
#define allocateErr 0x0E02              /* unable to allocate window record */
#define taskMaskErr 0x0E03              /* reserved bits are not clear in wmTaskMask */
#define compileTooLarge 0x0E04		/* Compiled text is larger than 64 KB */
#define cantUpdateErr 0x0E05		/* window couldn't be updated */

/* Axis Parameters */
#define wNoConstraint 0x0000            /* No constraint on movement */
#define wHAxisOnly 0x0001               /* Horizontal axis only */
#define wVAxisOnly 0x0002               /* Vertical axis only */

/* Desktop Command Codes */
#define FromDesk 0x00                   /* Subtract region from desktop */
#define ToDesk 0x1                      /* Add region to desktop */
#define GetDesktop 0x2                  /* Get Handle of Desktop region */
#define SetDesktop 0x3                  /* Set Handle of Desktop region */
#define GetDeskPat 0x4                  /* Address of pattern or drawing routine */
#define SetDeskPat 0x5                  /* Change Address of pattern or drawing routine */
#define GetVisDesktop 0x6               /* Get destop region less visible windows */
#define BackGroundRgn 0x7               /* For drawing directly on desktop */
#define CheckForNewDeskMsg 0x8          /* Force rechecking message #2 */

/* SendBehind Values */
#define toBottom 0xFFFFFFFEL            /* To send window to bottom */
#define topMost 0xFFFFFFFFL             /* To make window top */
#define bottomMost 0x0000L              /* To make window bottom */

/* Task Masks */
#define tmMenuKey 0x00000001L
#define tmUpdate 0x00000002L
#define tmFindW 0x00000004L
#define tmMenuSel 0x0008L
#define tmOpenNDA 0x0010L
#define tmSysClick 0x0020L
#define tmDragW 0x0040L
#define tmContent 0x0080L
#define tmClose 0x0100L
#define tmZoom 0x0200L
#define tmGrow 0x0400L
#define tmScroll 0x0800L
#define tmSpecial 0x1000L
#define tmCRedraw 0x2000L
#define tmInactive 0x4000L
#define tmInfo 0x8000L
#define tmContentControls 0x00010000L
#define tmControlKey 0x00020000L
#define tmControlMenu 0x00040000L
#define tmMultiClick 0x00080000L
#define tmIdleEvents 0x00100000L
#define tmNoGetNextEvent 0x00200000L

/* TaskMaster Codes */
#define wNoHit 0x0000                   /* retained for back compatibility */
#define inNull 0x0000                   /* retained for back compatibility */
#define inKey 0x0003                    /* retained for back compatibility */
#define inButtDwn 0x0001                /* retained for back compatibility */
#define inUpdate 0x0006                 /* retained for back compatibility */
#define wInDesk 0x0010                  /* On Desktop */
#define wInMenuBar 0x0011               /* On system menu bar */
#define wClickCalled 0x0012             /* system click called */
#define wInContent 0x0013               /* In content region */
#define wInDrag 0x0014                  /* In drag region */
#define wInGrow 0x0015                  /* In grow region, active window only */
#define wInGoAway 0x0016                /* In go-away region, active window only */
#define wInZoom 0x0017                  /* In zoom region, active window only */
#define wInInfo 0x0018                  /* In information bar */
#define wInSpecial 0x0019               /* Item ID selected was 250 - 255 */
#define wInDeskItem 0x001A              /* Item ID selected was 1 - 249 */
#define wInFrame 0x1B                   /* in Frame, but not on anything else */
#define wInactMenu 0x1C                 /* 'selection' of inactive menu item */
#define wClosedNDA 0x001D               /* desk accessory closed */
#define wCalledSysEdit 0x001E           /* inactive menu item selected */
#define wInSysWindow 0x8000             /* hi bit set for system windows */

/* VarCode */
#define wDraw 0x00                      /* Draw window frame command */
#define wHit 0x01                       /* Hit test command */
#define wCalcRgns 0x02                  /* Compute regions command */
#define wNew 0x03                       /* Initialization command */
#define wDispose 0x04                   /* Dispose command */
#define wGetDrag 5                      /* Return address of outline drawing handler */
#define wGrowFrame 6                    /* Draw outline of window being resized */
#define wRecSize 7                      /* Return size of additional space neeed in the windrec */
#define wPos 8                          /* Return RECT that is the window's portRect */
#define wBehind 9                       /* Return where the window should be placed in the list */
#define wCallDefProc 10                 /* Generic call to the defproc */

/* WFrame */
#define fHilited 0x0001                 /* Window is highlighted */
#define fZoomed 0x0002                  /* Window is zoomed */
#define fAllocated 0x0004               /* Window record was allocated */
#define fCtlTie 0x0008                  /* Window state tied to controls */
#define fInfo 0x0010                    /* Window has an information bar */
#define fVis 0x0020                     /* Window is visible */
#define fQContent 0x0040
#define fMove 0x0080                    /* Window is movable */
#define fZoom 0x0100                    /* Window is zoomable */
#define fFlex 0x0200
#define fGrow 0x0400                    /* Window has grow box */
#define fBScroll 0x0800                 /* Window has horizontal scroll bar */
#define fRScroll 0x1000                 /* Window has vertical scroll bar */
#define fAlert 0x2000
#define fClose 0x4000                   /* Window has a close box */
#define fTitle 0x8000                   /* Window has a title bar */

/* DoModalWindow flag values */
#define mwMovable 0x8000
#define mwUpdateAll 0x4000
#define mwDeskAcc 0x0010
#define mwIBeam 0x0008
#define mwMenuKey 0x0004
#define mwMenuSelect 0x0002
#define mwNoScrapForLE 0x0001

/* HandleDiskInsert flag values (bit flags) */
#define hdiScan 0x8000
#define hdiHandle 0x4000
#define hdiUpdate 0x2000
#define hdiReportEjects 0x1000
#define hdiNoDelay 0x0800
#define hdiDupDisk 0x0400
#define hdiCheckTapeDrives 0x0200
#define hdiUnreadable 0x0100
#define hdiMarkOffline 0x0001

/* HandleDiskInsert result flag values (bit flags) */
#define hdiFormatted 0x0002
#define hdiEjection 0x0001

/* constants for AlertWindow alertFlags */
#define awCString 0x0000
#define awPString 0x0001
#define awPointer 0x0000
#define awHandle 0x0002
#define awResource 0x0004
#define awTextFullWidth 0x0008
#define awForceBeep 0x0010
#define awButtonLayout 0x0020
#define awNoDevScan 0x0040
#define awNoDisposeRes 0x0080
#define awWatchForDisk 0x0100
#define awIconIsResource 0x0200
#define awFullColor 0x0400

/* UpdateWindow flag values */
#define uwBackground 0x8000
#define uwGSOSnotAvail 0x4000

/* Other Constants */
#define windSize 0x00D4                 /* Size of WindRec */
#define wmTaskRecSize 0x002E            /* Size of WmTaskRec */
#define wTrackZoom 0x001F
#define wHitFrame 0x0020
#define wInControl 0x0021
#define wInControlMenu 0x0022

/* custom defproc dRequest codes (from TN #42) */
#define wSetOrgMask 0
#define wSetMaxGrow 1
#define wSetScroll 2
#define wSetPage 3
#define wSetInfoRefCon 4
#define wSetInfoDraw 5
#define wSetOrigin 6
#define wSetDataSize 7
#define wSetZoomRect 8
#define wSetTitle 9
#define wSetColorTable 10
#define wSetFrameFlag 11
#define wGetOrgMask 12
#define wGetMaxGrow 13
#define wGetScroll 14
#define wGetPage 15
#define wGetInfoRefCon 16
#define wGetInfoDraw 17
#define wGetOrigin 18
#define wGetDataSize 19
#define wGetZoomRect 20
#define wGetTitle 21
#define wGetColorTable 22
#define wGetFrameFlag 23
#define wGetInfoRect 24
#define wGetDrawInfo 25
#define wGetStartInfoDraw 26
#define wGetEndInfoDraw 27
#define wZoomWindow 28
#define wStartDrawing 29
#define wStartMove 30
#define wStartGrow 31
#define wNewSize 32
#define wTask 33

typedef struct WindColor {
   Word frameColor;                     /* Color of window frame */
   Word titleColor;                     /* Color of title and bar */
   Word tBarColor;                      /* Color/pattern of title bar */
   Word growColor;                      /* Color of grow box */
   Word infoColor;                      /* Color of information bar */
   } WindColor, *WindColorPtr, **WindColorHndl;

typedef struct WindRec {
   /* struct WindRec *wNext; not included in record returned by ToolBox calls */
   GrafPort port;                       /* Window's port */
   ProcPtr wDefProc;
   LongWord wRefCon;
   ProcPtr wContDraw;
   LongWord wReserved;                  /* Space for future expansion */
   RegionHndl wStrucRgn;                /* Region of frame plus content */
   RegionHndl wContRgn;                 /* Content region */
   RegionHndl wUpdateRgn;               /* Update region */
   CtlRecHndl wControls;                /* Window's control list */
   CtlRecHndl wFrameCtrls;              /* Window frame's control list */
   Word wFrame;
   } WindRec, *WindRecPtr;

typedef struct ParamList {
   Word paramLength;
   Word wFrameBits;
   Pointer wTitle;
   LongWord wRefCon;
   Rect wZoom;
   WindColorPtr wColor;
   Word wYOrigin;
   Word wXOrigin;
   Word wDataH;
   Word wDataW;
   Word wMaxH;
   Word wMaxW;
   Word wScrollVer;
   Word wScrollHor;
   Word wPageVer;
   Word wPageHor;
   LongWord wInfoRefCon;
   Word wInfoHeight;                    /* height of information bar */
   LongProcPtr wFrameDefProc;
   VoidProcPtr wInfoDefProc;
   VoidProcPtr wContDefProc;
   Rect wPosition;
   WindowPtr wPlane;
   WindRecPtr wStorage;
   } ParamList, *ParamListPtr, **ParamListHndl;

typedef struct WindParam1 {
   Word p1Length;
   Word p1Frame;
   Pointer p1Title;
   LongWord p1RefCon;
   Rect p1ZoomRect;
   WindColorPtr p1ColorTable;
   Word p1YOrigin;
   Word p1XOrigin;
   Word p1DataHeight;
   Word p1DataWidth;
   Word p1MaxHeight;
   Word p1MaxWidth;
   Word p1VerScroll;
   Word p1HorScroll;
   Word p1VerPage;
   Word p1HorPage;
   LongWord p1InfoText;
   Word p1InfoHeight;
   LongProcPtr p1DefProc;
   VoidProcPtr p1InfoDraw;
   VoidProcPtr p1ContentDraw;
   Rect p1Position;
   WindowPtr p1Plane;
   Long p1ControlList;
   Word p1InDesc;
   } WindParam1, *WindParam1Ptr, **WindParam1Hndl;

typedef struct DeskMessageRecord {
   LongWord reserved;
   Word messageType;
   Word drawType;
   } DeskMessageRecord, *DeskMessageRecordPtr;

typedef struct AuxWindInfoRecord {
   Word recordSize;
   Word reservedForBank;
   Word reservedForDP;
   Word reservedForResApp;
   LongWord reservedForUpdateHandle;
   LongWord reservedForEndUpdatePort;
   LongWord reservedForWindoidLayer;
   Word sysWindMinHeight;
   Word sysWindMinWidth;
   Ptr NDASysWindPtr;
   } AuxWindInfoRecord, *AuxWindInfoPtr;

typedef struct WindGlobalsRec {
   Word  lineW;
   Word  titleHeight;
   Word  titleYPos;
   Word  closeHeight;
   Word  closeWidth;
   LongWord defWindClr;
   LongWord windIconFont;
   Word  screenMode;
   Byte  pattern[32];
   Word  callerDPage;
   Word  callerDataB;
   } WindGlobalsRec, *WindGlobalsRecPtr, **WindGlobalsRecHndl;

extern pascal void WindBootInit(void) inline(0x010E,dispatcher);
extern pascal void WindStartUp(Word) inline(0x020E,dispatcher);
extern pascal void WindShutDown(void) inline(0x030E,dispatcher);
extern pascal Word WindVersion(void) inline(0x040E,dispatcher);
extern pascal void WindReset(void) inline(0x050E,dispatcher);
extern pascal Boolean WindStatus(void) inline(0x060E,dispatcher);
extern pascal void BeginUpdate(GrafPortPtr) inline(0x1E0E,dispatcher);
extern pascal void BringToFront(GrafPortPtr) inline(0x240E,dispatcher);
extern pascal Boolean CheckUpdate(EventRecordPtr) inline(0x0A0E,dispatcher);
extern pascal void CloseWindow(GrafPortPtr) inline(0x0B0E,dispatcher);
extern pascal Pointer Desktop(Word, LongWord) inline(0x0C0E,dispatcher);
extern pascal void DragWindow(Word, Integer, Integer, Word, Rect *, GrafPortPtr) inline(0x1A0E,dispatcher);
extern pascal void EndInfoDrawing(void) inline(0x510E,dispatcher);
extern pascal void EndUpdate(GrafPortPtr) inline(0x1F0E,dispatcher);
extern pascal Word FindWindow(GrafPortPtr *, Integer, Integer) inline(0x170E,dispatcher);
extern pascal WindowPtr FrontWindow(void) inline(0x150E,dispatcher);
extern pascal VoidProcPtr GetContentDraw(GrafPortPtr) inline(0x480E,dispatcher);
extern pascal Long GetContentOrigin (GrafPortPtr) inline(0x3E0E,dispatcher);
extern pascal RegionHndl GetContentRgn(GrafPortPtr) inline(0x2F0E,dispatcher);
extern pascal LongWord GetDataSize(GrafPortPtr) inline(0x400E,dispatcher);
extern pascal LongProcPtr GetDefProc(GrafPortPtr) inline(0x310E,dispatcher);
extern pascal WindowPtr GetFirstWindow(void) inline(0x520E,dispatcher);
extern pascal void GetFrameColor(WindColorPtr, GrafPortPtr) inline(0x100E,dispatcher);
extern pascal VoidProcPtr GetInfoDraw(GrafPortPtr) inline(0x4A0E,dispatcher);
extern pascal LongWord GetInfoRefCon(GrafPortPtr) inline(0x350E,dispatcher);
extern pascal LongWord GetMaxGrow(GrafPortPtr) inline(0x420E,dispatcher);
extern pascal WindowPtr GetNextWindow(GrafPortPtr) inline(0x2A0E,dispatcher);
extern pascal LongWord GetPage(GrafPortPtr) inline(0x460E,dispatcher);
extern pascal void GetRectInfo(Rect *, GrafPortPtr) inline(0x4F0E,dispatcher);
extern pascal LongWord GetScroll(GrafPortPtr) inline(0x440E,dispatcher);
extern pascal RegionHndl GetStructRgn(GrafPortPtr) inline(0x2E0E,dispatcher);
extern pascal Boolean GetSysWFlag(GrafPortPtr) inline(0x4C0E,dispatcher);
extern pascal RegionHndl GetUpdateRgn(GrafPortPtr) inline(0x300E,dispatcher);
extern pascal CtlRecHndl GetWControls(GrafPortPtr) inline(0x330E,dispatcher);
extern pascal Word GetWFrame(GrafPortPtr) inline(0x2C0E,dispatcher);
extern pascal Word GetWKind(GrafPortPtr) inline(0x2B0E,dispatcher);
extern pascal WindowPtr GetWMgrPort(void) inline(0x200E,dispatcher);
extern pascal LongWord GetWRefCon(GrafPortPtr) inline(0x290E,dispatcher);
extern pascal Pointer GetWTitle(GrafPortPtr) inline(0x0E0E,dispatcher);
extern pascal Rect *GetZoomRect(GrafPortPtr) inline(0x370E,dispatcher);
extern pascal LongWord GrowWindow(Word, Word, Integer, Integer, GrafPortPtr) inline(0x1B0E,dispatcher);
extern pascal void HideWindow(GrafPortPtr) inline(0x120E,dispatcher);
extern pascal void HiliteWindow(Boolean, GrafPortPtr) inline(0x220E,dispatcher);
extern pascal void InvalRect(Rect *) inline(0x3A0E,dispatcher);
extern pascal void InvalRgn(Handle) inline(0x3B0E,dispatcher);
extern pascal void MoveWindow(Integer, Integer, GrafPortPtr) inline(0x190E,dispatcher);
extern pascal WindowPtr NewWindow(ParamListPtr) inline(0x090E,dispatcher);
extern pascal Point PinRect(Integer, Integer, Rect *) inline(0x210E,dispatcher);
extern pascal void RefreshDesktop(Rect *) inline(0x390E,dispatcher);
extern pascal void SelectWindow(GrafPortPtr) inline(0x110E,dispatcher);
extern pascal void SendBehind(GrafPortPtr, GrafPortPtr) inline(0x140E,dispatcher);
extern pascal void SetContentDraw(VoidProcPtr, GrafPortPtr) inline(0x490E,dispatcher);
extern pascal void SetContentOrigin(Word, Word, GrafPortPtr) inline(0x3F0E,dispatcher);
extern pascal void SetContentOrigin2(Word, Word, Word, GrafPortPtr) inline(0x570E,dispatcher);
extern pascal void SetDataSize(Word, Word, GrafPortPtr) inline(0x410E,dispatcher);
extern pascal void SetDefProc(LongProcPtr, GrafPortPtr) inline(0x320E,dispatcher);
extern pascal void SetFrameColor(WindColorPtr, GrafPortPtr) inline(0x0F0E,dispatcher);
extern pascal void SetInfoDraw(VoidProcPtr, GrafPortPtr) inline(0x160E,dispatcher);
extern pascal void SetInfoRefCon(LongWord, GrafPortPtr) inline(0x360E,dispatcher);
extern pascal void SetMaxGrow(Word, Word, GrafPortPtr) inline(0x430E,dispatcher);
extern pascal void SetOriginMask(Word, GrafPortPtr) inline(0x340E,dispatcher);
extern pascal void SetPage(Word, Word, GrafPortPtr) inline(0x470E,dispatcher);
extern pascal void SetScroll(Word, Word, GrafPortPtr) inline(0x450E,dispatcher);
extern pascal void SetSysWindow(GrafPortPtr) inline(0x4B0E,dispatcher);
extern pascal void SetWFrame(Word, GrafPortPtr) inline(0x2D0E,dispatcher);
extern pascal FontHndl SetWindowIcons(FontHndl) inline(0x4E0E,dispatcher);
extern pascal void SetWRefCon(Longint, GrafPortPtr) inline(0x280E,dispatcher);
extern pascal void SetWTitle(Pointer, GrafPortPtr) inline(0x0D0E,dispatcher);
extern pascal void SetZoomRect(Rect *, GrafPortPtr) inline(0x380E,dispatcher);
extern pascal void ShowHide(Boolean, GrafPortPtr) inline(0x230E,dispatcher);
extern pascal void ShowWindow(GrafPortPtr) inline(0x130E,dispatcher);
extern pascal void SizeWindow(Word, Word, GrafPortPtr) inline(0x1C0E,dispatcher);
extern pascal void StartDrawing(GrafPortPtr) inline(0x4D0E,dispatcher);
extern pascal void StartInfoDrawing(Rect *, GrafPortPtr) inline(0x500E,dispatcher);
extern pascal Word TaskMaster(Word, WmTaskRecPtr) inline(0x1D0E,dispatcher);
extern pascal Boolean TrackGoAway(Integer, Integer, GrafPortPtr) inline(0x180E,dispatcher);
extern pascal Boolean TrackZoom(Integer, Integer, GrafPortPtr) inline(0x260E,dispatcher);
extern pascal void ValidRect(Rect *) inline(0x3C0E,dispatcher);
extern pascal void ValidRgn(Handle) inline(0x3D0E,dispatcher);
extern pascal LongWord WindDragRect(VoidProcPtr, Pattern, Integer, Integer, Rect *, Rect *, Rect *, Word) inline(0x530E,dispatcher);
extern pascal void WindNewRes(void) inline(0x250E,dispatcher);
extern pascal Word WindowGlobal(Word) inline(0x560E,dispatcher);
extern pascal void ZoomWindow(GrafPortPtr) inline(0x270E,dispatcher);

extern pascal Word AlertWindow(Word, Pointer, Ref) inline(0x590E,dispatcher);
extern pascal Handle CompileText(Word, Pointer, Pointer, Word) inline(0x600E,dispatcher);
extern pascal void DrawInfoBar(GrafPortPtr) inline(0x550E,dispatcher);
extern pascal void EndFrameDrawing(void) inline(0x5B0E,dispatcher);
extern pascal Word ErrorWindow(Word, Pointer, Word) inline(0x620E,dispatcher);
extern pascal Ptr GetWindowMgrGlobals(void) inline(0x580E,dispatcher);
extern pascal WindowPtr NewWindow2(Pointer, Long, VoidProcPtr, LongProcPtr, Word, Ref, Word) inline(0x610E,dispatcher);
extern pascal void ResizeWindow(Boolean, Rect *, GrafPortPtr) inline(0x5C0E,dispatcher);
extern pascal void StartFrameDrawing(GrafPortPtr) inline(0x5A0E,dispatcher);
extern pascal Word TaskMasterDA(Word, WmTaskRecPtr) inline(0x5F0E,dispatcher);

extern pascal LongWord DoModalWindow(EventRecordPtr, VoidProcPtr, VoidProcPtr, VoidProcPtr, Word) inline(0x640E,dispatcher);
extern pascal Word FindCursorCtl(CtlRecHndlPtr, Integer, Integer, GrafPortPtr) inline(0x690E,dispatcher);
extern pascal AuxWindInfoPtr GetAuxWindInfo(GrafPortPtr) inline(0x630E,dispatcher);
extern pascal LongWord HandleDiskInsert(Word, Word) inline(0x6B0E,dispatcher);
extern pascal Word MWGetCtlPart(void) inline(0x650E,dispatcher);
extern pascal VoidProcPtr MWSetMenuProc(VoidProcPtr) inline(0x660E,dispatcher);
/* old spelling of MWSetMenuProc */
extern pascal VoidProcPtr SetMenuProc(VoidProcPtr) inline(0x660E,dispatcher);
extern pascal void MWSetUpEditMenu(void) inline(0x680E,dispatcher);
extern pascal void MWStdDrawProc(void) inline(0x670E,dispatcher);
extern pascal void ResizeInfoBar(Word, Word, GrafPortPtr) inline(0x6A0E,dispatcher);

extern pascal void UpdateWindow(Word, GrafPortPtr) inline(0x6C0E,dispatcher);
      
/* The parameters for these calls are not documented.
extern pascal void GDRPrivate() inline(0x540E,dispatcher);
extern pascal void TaskMasterContent() inline(0x5D0E,dispatcher);
extern pascal void TaskMasterKey() inline(0x5E0E,dispatcher);
*/

#endif
