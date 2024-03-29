/********************************************
*
* Resource Manager
*
* Copyright Apple Computer, Inc.1986-92
* All Rights Reserved
*
* Copyright 1992, 1993, Byte Works, Inc.
*
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __RESOURCES__
#define __RESOURCES__

/* ResourceConverter Codes */
#define resLogOut 0x0
#define resLogIn 0x1
#define resLogApp 0x0
#define resLogSys 0x2

/* Error Codes */
#define resForkUsed 0x1E01              /* Resource fork not empty */
#define resBadFormat 0x1E02             /* Format of resource fork is unknown */
#define resNoConverter 0x1E03           /* No converter routine available for resource type */
#define resNoCurFile 0x1E04             /* there are no current open resource files */
#define resDupID 0x1E05                 /* ID is already used */
#define resNotFound 0x1E06              /* resource was not found */
#define resFileNotFound 0x1E07          /* resource file not found */
#define resBadAppID 0x1E08              /* User ID not found, please call ResourceStartup */
#define resNoUniqueID 0x1E09            /* a unique ID was not found */
#ifndef resIndexRange                   /* Index is out of range */
#define resIndexRange 0x1E0A
#endif
#define resSysIsOpen 0x1E0B             /* System file is already open */
#define resHasChanged 0x1E0C            /* Resource marked changed; specified operation not allowed */
#define resDiffConverter 0x1E0D         /* Different converter already logged in for this resource type */
#define resDiskFull 0x1E0E              /* Volume is full */
#define resInvalidShutDown 0x1E0F       /* can't shut down ID 401E */
#define resNameNotFound 0x1E10          /* no resource with given name */
#define resBadNameVers 0x1E11           /* bad version in rResName resource */
#define resDupStartUp 0x1E12            /* already started with this ID */
#define resInvalidTypeOrID 0x1E13       /* type or ID is 0 */

/* Other Constants */
#define resChanged 0x0020
#define resPreLoad 0x0040
#define resProtected 0x0080
#define resAbsLoad 0x0400
#define resConverter 0x0800
#define resMemAttr 0xC31C               /* Flags passed to the NewHandle Memory Manager call */
#define systemMap 0x0001
#define fileReadWrite 0x0001
#define mapChanged 0x0002
#define romMap 0x0004
#define resNameOffset 0x10000           /* type holding names */
#define resNameVersion 0x0001
#define sysFileID 0x0001

/* Resource Type Numbers */
#define rIcon 0x8001                    /* Icon type */
#define rPicture 0x8002                 /* Picture type */
#define rControlList 0x8003             /* Control list type */
#define rControlTemplate 0x8004         /* Control template type */
#define rC1InputString 0x8005           /* GS/OS class 1 input string */
#define rPString 0x8006                 /* Pascal string type */
#define rStringList 0x8007              /* String list type */
#define rMenuBar 0x8008                 /* MenuBar type */
#define rMenu 0x8009                    /* Menu template */
#define rMenuItem 0x800A                /* Menu item definition */
#define rTextForLETextBox2 0x800B       /* Data for LineEdit LETextBox2 call */
#define rCtlDefProc 0x800C              /* Control definition procedure type */
#define rCtlColorTbl 0x800D             /* Color table for control */
#define rWindParam1 0x800E              /* Parameters for NewWindow2 call */
#define rWindParam2 0x800F              /* Parameters for NewWindow2 call */
#define rWindColor 0x8010               /* Window Manager color table */
#define rTextBlock 0x8011               /* Text block */
#define rStyleBlock 0x8012              /* TextEdit style information */
#define rToolStartup 0x8013             /* Tool set startup record */
#define rResName 0x8014                 /* Resource name */
#define rAlertString 0x8015             /* AlertWindow input data */
#define rText 0x8016                    /* Unformatted text */
#define rCodeResource 0x8017
#define rCDEVCode 0x8018
#define rCDEVFlags 0x8019
#define rTwoRects 0x801A                /* Two rectangles */
#define rFileType 0x801B                /* Filetype descriptors--see File Type Note $42 */
#define rListRef 0x801C                 /* List member */
#define rCString 0x801D                 /* C string */
#define rXCMD 0x801E
#define rXFCN 0x801F
#define rErrorString 0x8020             /* ErrorWindow input data */
#define rKTransTable 0x8021             /* Keystroke translation table */
#define rWString 0x8022                 /* not useful--duplicates $8005 */
#define rC1OutputString 0x8023          /* GS/OS class 1 output string */
#define rSoundSample 0x8024
#define rTERuler 0x8025                 /* TextEdit ruler information */
#define rFSequence 0x8026
#define rCursor 0x8027                  /* Cursor resource type */
#define rItemStruct 0x8028              /* for 6.0 Menu Manager */
#define rVersion 0x8029
#define rComment 0x802A
#define rBundle 0x802B
#define rFinderPath 0x802C
#define rPaletteWindow 0x802D           /* used by HyperCard IIgs 1.1 */
#define rTaggedStrings 0x802E
#define rPatternList 0x802F
#define rRectList 0xC001
#define rPrintRecord 0xC002
#define rFont 0xC003

typedef long ResID;
typedef word ResType;
typedef word ResAttr;

struct ResHeaderRec {
   LongWord rFileVersion;               /* Format version of resource fork */
   LongWord rFileToMap;                 /* Offset from start to resource map record */
   LongWord rFileMapSize;               /* Number of bytes map occupies in file */
   Byte rFileMemo[128];                 /* Reserved space for application */
   };
typedef struct ResHeaderRec ResHeaderRec;

struct FreeBlockRec {
   LongWord blkOffset;
   LongWord blkSize;
   };
typedef struct FreeBlockRec FreeBlockRec;

struct ResMap {
   struct ResMap **mapNext;             /* Handle to next resource map */
   Word mapFlag;                        /* Bit Flags */
   LongWord mapOffset;                  /* Map's file position */
   LongWord mapSize;                    /* Number of bytes map occupies in file */
   Word mapToIndex;
   Word mapFileNum;
   Word mapID;
   LongWord mapIndexSize;
   LongWord mapIndexUsed;
   Word mapFreeListSize;
   Word mapFreeListUsed;
   FreeBlockRec mapFreeList[1];         /* n bytes (array of free block records) */
   };
typedef struct ResMap ResMap, *ResMapPtr, **ResMapHndl;

typedef struct ResMap MapRec, *MapRecPtr, **MapRecHndl;	/* TBR3 definition */

struct ResRefRec {
   ResType resType;
   ResID resID;
   LongWord resOffset;
   ResAttr resAttr;
   LongWord resSize;
   Handle resHandle;
   };
typedef struct ResRefRec ResRefRec, *ResRefRecPtr;

struct ResourceSpec {
   ResType resourceType;
   ResID resourceID;
   };
typedef struct ResourceSpec ResourceSpec;

struct ResNameEntry {
   ResID namedResID;
   Str255 resName;
   };
typedef struct ResNameEntry ResNameEntry, *ResNameEntryPtr;

struct ResNameRec {
   Word version;
   LongWord nameCount;
   ResNameEntry resNameEntries[1];
   };
typedef struct ResNameRec ResNameRec, *ResNameRecPtr, **ResNameRecHndl;

extern pascal void ResourceBootInit(void) inline(0x011E,dispatcher);
extern pascal void ResourceStartUp(Word) inline(0x021E,dispatcher);
extern pascal void ResourceShutDown(void) inline(0x031E,dispatcher);
extern pascal Word ResourceVersion(void) inline(0x041E,dispatcher);
extern pascal void ResourceReset(void) inline(0x051E,dispatcher);
extern pascal Boolean ResourceStatus(void) inline(0x061E,dispatcher);
extern pascal void AddResource(Handle, Word, Word, Long) inline(0x0C1E,dispatcher);
extern pascal void CloseResourceFile(Word) inline(0x0B1E,dispatcher);
extern pascal LongWord CountResources(Word) inline(0x221E,dispatcher);
extern pascal Word CountTypes(void) inline(0x201E,dispatcher);
extern pascal void CreateResourceFile(Long, Word, Word, Pointer) inline(0x091E,dispatcher);
extern pascal void DetachResource(Word, Long) inline(0x181E,dispatcher);
extern pascal Word GetCurResourceApp(void) inline(0x141E,dispatcher);
extern pascal Word GetCurResourceFile(void) inline(0x121E,dispatcher);
extern pascal ResID GetIndResource(Word, Long) inline(0x231E,dispatcher);
extern pascal ResType GetIndType(Word) inline(0x211E,dispatcher);
extern pascal ResMapHndl GetMapHandle(Word) inline(0x261E,dispatcher);
extern pascal Word GetOpenFileRefNum(Word) inline(0x1F1E,dispatcher);
extern pascal ResAttr GetResourceAttr(Word, Long) inline(0x1B1E,dispatcher);
extern pascal LongWord GetResourceSize(Word, Long) inline(0x1D1E,dispatcher);
extern pascal Word HomeResourceFile(Word, Long) inline(0x151E,dispatcher);
extern pascal LongWord LoadAbsResource(Pointer, Long, Word, Long) inline(0x271E,dispatcher);
extern pascal Handle LoadResource(Word, Long) inline(0x0E1E,dispatcher);
extern pascal void MarkResourceChange(Word, Word, Long) inline(0x101E,dispatcher);
extern pascal void MatchResourceHandle(Pointer, Handle) inline(0x1E1E,dispatcher);
extern pascal Word OpenResourceFile(Word, Pointer, Pointer) inline(0x0A1E,dispatcher);
extern pascal void ReleaseResource(Word, Word, Long) inline(0x171E,dispatcher);
extern pascal void RemoveResource(Word, Long) inline(0x0F1E,dispatcher);
extern pascal void ResourceConverter(Pointer, Word, Word) inline(0x281E,dispatcher);
extern pascal void SetCurResourceApp(Word) inline(0x131E,dispatcher);
extern pascal void SetCurResourceFile(Word) inline(0x111E,dispatcher);
extern pascal void SetResourceAttr(Word, Word, Long) inline(0x1C1E,dispatcher);
extern pascal Word SetResourceFileDepth(Word) inline(0x251E,dispatcher);
extern pascal void SetResourceID(Long, Word, Long) inline(0x1A1E,dispatcher);
extern pascal Word SetResourceLoad(Word) inline(0x241E,dispatcher);
extern pascal ResID UniqueResourceID(Word, Word) inline(0x191E,dispatcher);
extern pascal void UpdateResourceFile(Word) inline(0x0D1E,dispatcher);
extern pascal void WriteResource(Word, Long) inline(0x161E,dispatcher);

extern pascal Handle LoadResource2(Word, Ptr, Word, Long) inline(0x291E,dispatcher);
extern pascal LongWord RMFindNamedResource(Word, Ptr, Word *) inline(0x2A1E,dispatcher);
extern pascal void RMGetResourceName(Word, Long, Ptr) inline(0x2B1E,dispatcher);
extern pascal Handle RMLoadNamedResource(Word, Ptr) inline(0x2C1E,dispatcher);
extern pascal void RMSetResourceName(Word, Long, Ptr) inline(0x2D1E,dispatcher);

extern pascal Word OpenResourceFileByID(Word, Word) inline(0x2E1E,dispatcher);
extern pascal void CompactResourceFile(Word, Word) inline(0x2F1E,dispatcher);
      
#endif
