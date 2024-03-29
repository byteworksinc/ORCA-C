/********************************************
*
* GS/OS
*
* Copyright Apple Computer, Inc.1986-91
* All Rights Reserved
*
* Copyright 1992, Byte Works, Inc.
*
********************************************/

#ifndef __TYPES__
#include <TYPES.h>
#endif

#ifndef __GSOS__
#define __GSOS__

/*
 Read/Write enable bit Codes
 for CreateRec/OpenRec access and requestAccess fields
*/

#define readEnableAllowWrite 0x0000
#define readEnable 0x0001
#define writeEnable 0x0002
#define readWriteEnable 0x0003
#define fileInvisible 0x0004            /* Invisible bit */
#define backupNeeded 0x0020             /* backup needed bit: CreateRec/ OpenRec access field. (Must be 0 in requestAccess field ) */
#define renameEnable 0x0040             /* rename enable bit: CreateRec/ OpenRec access and requestAccess fields */
#define destroyEnable 0x0080            /* destroy enable bit: CreateRec/ OpenRec access and requestAccess fields */
#define startPlus 0x0000                /* base -> setMark = displacement */
#define eofMinus 0x0001                 /* base -> setMark = eof - displacement */
#define markPlus 0x0002                 /* base -> setMark = mark + displacement */
#define markMinus 0x0003                /* base -> setMark = mark - displacement */

/* cachePriority Codes */
#define cacheOff 0x0000                 /* do not cache blocks invloved in this read */
#define cacheOn 0x0001                  /* cache blocks invloved in this read if possible */

/* Error Codes */
#define badSystemCall 0x0001            /* bad system call number */
#define invalidPcount 0x0004            /* invalid parameter count */
#define gsosActive 0x0007               /* GS/OS already active */

#ifndef devNotFound                     /* device not found */
 #define devNotFound 0x0010
#endif

#define invalidDevNum 0x0011            /* invalid device number */
#define drvrBadReq 0x0020               /* bad request or command */
#define drvrBadCode 0x0021              /* bad control or status code */
#define drvrBadParm 0x0022              /* bad call parameter */
#define drvrNotOpen 0x0023              /* character device not open */
#define drvrPriorOpen 0x0024            /* character device already open */
#define irqTableFull 0x0025             /* interrupt table full */
#define drvrNoResrc 0x0026              /* resources not available */
#define drvrIOError 0x0027              /* I/O error */
#define drvrNoDevice 0x0028             /* device not connected */
#define drvrBusy 0x0029                 /* call aborted; driver is busy */
#define drvrWrtProt 0x002B              /* device is write protected */
#define drvrBadCount 0x002C             /* invalid byte count */
#define drvrBadBlock 0x002D             /* invalid block address */
#define drvrDiskSwitch 0x002E           /* disk has been switched */
#define drvrOffLine 0x002F              /* device off line/ no media present */
#define badPathSyntax 0x0040            /* invalid pathname syntax */
#define tooManyFilesOpen 0x0042         /* too many files open on server volume */
#define invalidRefNum 0x0043            /* invalid reference number */

#ifndef pathNotFound                    /* subdirectory does not exist */
 #define pathNotFound 0x0044
#endif

#define volNotFound 0x0045              /* volume not found */

#ifndef fileNotFound                    /* file not found */
 #define fileNotFound 0x0046
#endif

#define dupPathname 0x0047              /* create or rename with existing name */
#define volumeFull 0x0048               /* volume full error */
#define volDirFull 0x0049               /* volume directory full */
#define badFileFormat 0x004A            /* version error (incompatible file format) */

#ifndef badStoreType                    /* unsupported (or incorrect) storage type */
 #define badStoreType 0x004B
#endif

#ifndef eofEncountered                  /* end-of-file encountered */
 #define eofEncountered 0x004C
#endif

#define outOfRange 0x004D               /* position out of range */
#define invalidAccess 0x004E            /* access not allowed */
#define buffTooSmall 0x004F             /* buffer too small */
#define fileBusy 0x0050                 /* file is already open */
#define dirError 0x0051                 /* directory error */
#define unknownVol 0x0052               /* unknown volume type */

#ifndef paramRangeErr                   /* parameter out of range */
 #define paramRangeErr 0x0053
#endif

#define outOfMem 0x0054                 /* out of memory */
#define dupVolume 0x0057                /* duplicate volume name */
#define notBlockDev 0x0058              /* not a block device */

#ifndef invalidLevel                    /* specifield level outside legal range */
 #define invalidLevel 0x0059
#endif

#define damagedBitMap 0x005A            /* block number too large */
#define badPathNames 0x005B             /* invalid pathnames for ChangePath */
#define notSystemFile 0x005C            /* not an executable file */
#define osUnsupported 0x005D            /* Operating System not supported */

#ifndef stackOverflow                   /* too many applications on stack */
 #define stackOverflow 0x005F
#endif

#define dataUnavail 0x0060              /* Data unavailable */
#define endOfDir 0x0061                 /* end of directory has been reached */
#define invalidClass 0x0062             /* invalid FST call class */
#define resForkNotFound 0x0063          /* file does not contain required resource */
#define invalidFSTID 0x0064             /* error - FST ID is invalid */
#define invalidFSTop 0x0065             /* invalid FST operation */
#define fstCaution 0x0066               /* FST handled call, but result is weird */
#define devNameErr 0x0067               /* device exists with same name as replacement name */
#define devListFull 0x0068              /* device list is full */
#define supListFull 0x0069              /* supervisor list is full */
#define fstError 0x006a                 /* generic FST error */
#define resExistsErr 0x0070             /* cannot expand file, resource already exists */
#define resAddErr 0x0071                /* cannot add resource fork to this type file */
#define networkError 0x0088             /* generic network error */

/* fileSys IDs */
#define proDOSFSID 0x0001               /* ProDOS/SOS */
#define dos33FSID 0x0002                /* DOS 3.3 */
#define dos32FSID 0x0003                /* DOS 3.2 */
#define dos31FSID 0x0003                /* DOS 3.1 */
#define appleIIPascalFSID 0x0004        /* Apple II Pascal */
#define mfsFSID 0x0005                  /* Macintosh (flat file system) */
#define hfsFSID 0x0006                  /* Macintosh (hierarchical file system) */
#define lisaFSID 0x0007                 /* Lisa file system */
#define appleCPMFSID 0x0008             /* Apple CP/M */
#define charFSTFSID 0x0009              /* Character FST */
#define msDOSFSID 0x000A                /* MS/DOS */
#define highSierraFSID 0x000B           /* High Sierra */
#define iso9660FSID 0x000C              /* ISO 9660 */
#define appleShareFSID 0x000D           /* ISO 9660 */

/* FSTInfo.attributes Codes */
#define characterFST 0x4000             /* character FST */
#define ucFST 0x8000                    /* SCM should upper case pathnames before passing them to the FST */

/* QuitRec.flags Codes */
#define onStack 0x8000                  /* place state information about quitting program on the quit return stack */
#define restartable 0x4000              /* the quitting program is capable of being restarted from its dormant memory */

/* storageType Codes */
#define seedling 0x0001                 /* standard file with seedling structure */
#define standardFile 0x0001             /* standard file type (no resource fork) */
#define sapling 0x0002                  /* standard file with sapling structure */
#define tree 0x0003                     /* standard file with tree structure */
#define pascalRegion 0x0004             /* UCSD Pascal region on a partitioned disk */
#define extendedFile 0x0005             /* extended file type (with resource fork) */
#define directoryFile 0x000D            /* volume directory or subdirectory file */

/* version Codes */
#define minorRelNumMask 0x00FF          /* minor release number */
#define majorRelNumMask 0x7F00          /* major release number */
#define finalRelNumMask 0x8000          /* final release number */

/* Other Constants */
#define isFileExtended 0x8000           /* GetDirEntryGS */

/* DControl Codes */
#define resetDevice 0x0000
#define formatDevice 0x0001
#define eject 0x0002
#define setConfigParameters 0x0003
#define setWaitStatus 0x0004
#define setFormatOptions 0x0005
#define assignPartitionOwner 0x0006
#define armSignal 0x0007
#define disarmSignal 0x0008
#define setPartitionMap 0x0009

typedef struct ChangePathRecGS {
   Word pCount;
   GSString255Ptr pathname;
   GSString255Ptr newPathname;
   Word flags;
   } ChangePathRecGS, *ChangePathRecPtrGS;

typedef struct CreateRecGS {
   Word pCount;
   GSString255Ptr pathname;
   Word access;
   Word fileType;
   LongWord auxType;
   Word storageType;
   LongWord eof;
   LongWord resourceEOF;
   } CreateRecGS, *CreateRecPtrGS;

typedef struct DAccessRecGS {
   Word pCount;
   Word devNum;
   Word code;
   Pointer list;
   LongWord requestCount;
   LongWord transferCount;
   } DAccessRecGS, *DAccessRecPtrGS;

typedef struct DevNumRecGS {
   Word pCount;
   GSString32Ptr devName;
   Word devNum;
   } DevNumRecGS, *DevNumRecPtrGS;

typedef struct DInfoRecGS {
   Word pCount;                         /* minimum = 2 */
   Word devNum;
   ResultBuf32Ptr devName;
   Word characteristics;
   LongWord totalBlocks;
   Word slotNum;
   Word unitNum;
   Word version;
   Word deviceID;
   Word headLink;
   Word forwardLink;
   Pointer extendedDIBPtr;
   } DInfoRecGS, *DInfoRecPtrGS;

typedef struct DIORecGS {
   Word pCount;
   Word devNum;
   Pointer buffer;
   LongWord requestCount;
   LongWord startingBlock;
   Word blockSize;
   LongWord transferCount;
   } DIORecGS, *DIORecPtrGS;

typedef struct DirEntryRecGS {
   Word pCount;
   Word refNum;
   Word flags;
   Word base;
   Word displacement;
   ResultBuf255Ptr name;
   Word entryNum;
   Word fileType;
   Longint eof;
   LongWord blockCount;
   TimeRec createDateTime;
   TimeRec modDateTime;
   Word access;
   LongWord auxType;
   Word fileSysID;
   ResultBuf255Ptr optionList;
   LongWord resourceEOF;
   LongWord resourceBlocks;
   } DirEntryRecGS, *DirEntryRecPtrGS;

typedef struct DRenameRecGS {
   Word pCount;
   Word devNum;
   GSString32Ptr strPtr;
   } DRenameRecGS, *DRenameRecGSPtr;

typedef struct ExpandPathRecGS {
   Word pCount;
   GSString255Ptr inputPath;
   ResultBuf255Ptr outputPath;
   Word flags;
   } ExpandPathRecGS, *ExpandPathRecPtrGS;

typedef struct FileInfoRecGS {
   Word pCount;
   GSString255Ptr pathname;
   Word access;
   Word fileType;
   LongWord auxType;
   Word storageType;                    /* must be 0 for SetFileInfo */
   TimeRec createDateTime;
   TimeRec modDateTime;
   ResultBuf255Ptr optionList;
   LongWord eof;
   LongWord blocksUsed;                 /* must be 0 for SetFileInfo */
   LongWord resourceEOF;                /* must be 0 for SetFileInfo */
   LongWord resourceBlocks;             /* must be 0 for SetFileInfo */
   } FileInfoRecGS, *FileInfoRecPtrGS;

typedef struct FormatRecGS {
   Word pCount;
   GSString32Ptr devName;               /* device name pointer */
   GSString32Ptr volName;               /* volume name pointer */
   Word fileSysID;                      /* file system ID */
   Word reqFileSysID;                   /* in; */
   Word flags;
   ResultBuf255Ptr realVolName;
   } FormatRecGS, *FormatRecPtrGS;

typedef struct FSTInfoRecGS {
   Word pCount;
   Word fstNum;
   Word fileSysID;
   ResultBuf255Ptr fstName;
   Word version;
   Word attributes;
   Word blockSize;
   LongWord maxVolSize;
   LongWord maxFileSize;
   } FSTInfoRecGS, *FSTInfoRecPtrGS;

typedef struct InterruptRecGS {
   Word pCount;
   Word intNum;
   Word vrn;                            /* used only by BindInt */
   ProcPtr intCode;                     /* used only by BindInt */
   } InterruptRecGS, *InterruptRecPtrGS;

typedef struct IORecGS {
   Word pCount;
   Word refNum;
   Pointer dataBuffer;
   LongWord requestCount;
   LongWord transferCount;
   Word cachePriority;
   } IORecGS, *IORecPtrGS;

typedef struct JudgeNameRecGS {
   Word pCount;
   Word fileSysID;
   Word nameType;
   Pointer syntax;
   Word maxLen;
   ResultBuf255Ptr name;
   Word nameFlags;
   } JudgeNameRecGS, *JudgeNameRecPtrGS;

typedef struct LevelRecGS {
   Word pCount;
   Word level;
   Word levelMode;
   } LevelRecGS, *LevelRecPtrGS;

typedef struct NameRecGS {
   Word pCount;
   GSString255Ptr pathname;             /* full pathname or a filename depending on call */
   } NameRecGS, *NameRecPtrGS;

typedef struct NotifyProcRecGS {
   Word pCount;
   ProcPtr procPointer;
   } NotifyProcRecGS, *NotifyProcRecGSPtr;

typedef struct GetNameRecGS {
   Word pCount;
   ResultBuf255Ptr dataBuffer;          /* full pathname or a filename depending on call */
   Word userID;
   } GetNameRecGS, *GetNameRecPtrGS;

typedef struct NewlineRecGS {
   Word pCount;
   Word refNum;
   Word enableMask;
   Word numChars;
   Pointer newlineTable;
   } NewlineRecGS, *NewlineRecPtrGS;

typedef struct OpenRecGS {
   Word pCount;
   Word refNum;
   GSString255Ptr pathname;
   Word requestAccess;
   Word resourceNumber;                 /* For extended files: dataFork/resourceFork */
   Word access;                         /* Value of file's access attribute */
   Word fileType;                       /* Value of file's fileType attribute */
   LongWord auxType;
   Word storageType;
   TimeRec createDateTime;
   TimeRec modDateTime;
   ResultBuf255Ptr optionList;
   LongWord eof;
   LongWord blocksUsed;
   LongWord resourceEOF;
   LongWord resourceBlocks;
   } OpenRecGS, *OpenRecPtrGS;

typedef struct OSShutDownRecGS {
   Word pCount;
   Word shutdownFlag;
   } OSShutDownRecGS, *OSShutDownRecPtrGS;

typedef struct PositionRecGS {
   Word pCount;
   Word refNum;
   LongWord position;
   } PositionRecGS, *PositionRecPtrGS;

typedef struct EOFRecGS {
   Word pCount;
   Word refNum;
   LongWord eof;
   } EOFRecGS, *EOFRecPtrGS;

typedef struct PrefixRecGS {
   Word pCount;
   Word prefixNum;
   union {
      ResultBuf255Ptr getPrefix;
      GSString255Ptr setPrefix;
      } buffer;
   } PrefixRecGS, *PrefixRecPtrGS;

typedef struct QuitRecGS {
   Word pCount;
   GSString255Ptr pathname;             /* pathname of next app to run */
   Word flags;
   } QuitRecGS, *QuitRecPtrGS;

typedef struct RefNumRecGS {
   Word pCount;
   Word refNum;
   } RefNumRecGS, *RefnumRecPtrGS;

typedef struct GetRefNumRecGS {
   Word pCount;
   GSString255Ptr pathname;
   Word refNum;
   Word access;
   Word resNum;
   Boolean caseSense;
   Word displacement;
   } GetRefNumRecGS, *GetRefNumRecPtrGS;

typedef struct StdRefNumRecGS {
   Word pCount;
   Word prefixNum;
   Word refNum;
   } StdRefNumRecGS, *StdRefNumRecGSPtr;

typedef struct SessionStatusRecGS {
   Word pCount;                         /* in: min = 1 */
   Word status;                         /* out: */
   } SessionStatusRecGS, *SessionStatusRecPtrGS;

typedef struct SetPositionRecGS {
   Word pCount;
   Word refNum;
   Word base;
   LongWord displacement;
   } SetPositionRecGS, *SetPositionRecPtrGS;

typedef struct SysPrefsRecGS {
   Word pCount;
   Word preferences;
   } SysPrefsRecGS, *SysPrefsRecPtrGS;

typedef struct VersionRecGS {
   Word pCount;
   Word version;
   } VersionRecGS, *VersionRecPtrGS;

typedef struct VolumeRecGS {
   Word pCount;
   GSString32Ptr devName;
   ResultBuf255Ptr volName;
   LongWord totalBlocks;
   LongWord freeBlocks;
   Word fileSysID;
   Word blockSize;
   Word characteristics;
   Word deviceID;
   } VolumeRecGS, *VolumeRecPtrGS;

typedef struct RefInfoRecGS {
   Word pCount;
   Word refNum;
   Word access;
   ResultBuf255Ptr pathname;
   Word resourceNumber;
   Word level;
   } RefInfoRecGS, *RefInfoRecGSPtr;

#ifndef stackEntry
 #define stackEntry 0xE100B0
#endif

#ifndef PDosInt
extern pascal void PDosInt(unsigned, void *);
#endif

#define AddNotifyProcGS(pBlockPtr) PDosInt(0x2034,pBlockPtr)
#define BeginSessionGS(pBlockPtr) PDosInt(0x201D,pBlockPtr)
#define BindIntGS(pBlockPtr) PDosInt(0x2031,pBlockPtr)
#define ChangePathGS(pBlockPtr) PDosInt(0x2004,pBlockPtr)
#define ClearBackupBitGS(pBlockPtr) PDosInt(0x200B,pBlockPtr)
#define CloseGS(pBlockPtr) PDosInt(0x2014,pBlockPtr)
#define CreateGS(pBlockPtr) PDosInt(0x2001,pBlockPtr)
#define DControlGS(pBlockPtr) PDosInt(0x202E,pBlockPtr)
#define DelNotifyProcGS(pBlockPtr) PDosInt(0x2035,pBlockPtr)
#define DestroyGS(pBlockPtr) PDosInt(0x2002,pBlockPtr)
#define DInfoGS(pBlockPtr) PDosInt(0x202C,pBlockPtr)
#define DReadGS(pBlockPtr) PDosInt(0x202F,pBlockPtr)
#define DRenameGS(pBlockPtr) PDosInt(0x2036,pBlockPtr)
#define DStatusGS(pBlockPtr) PDosInt(0x202D,pBlockPtr)
#define DWriteGS(pBlockPtr) PDosInt(0x2030,pBlockPtr)
#define EndSessionGS(pBlockPtr) PDosInt(0x201E,pBlockPtr)
#define EraseDiskGS(pBlockPtr) PDosInt(0x2025,pBlockPtr)
#define ExpandPathGS(pBlockPtr) PDosInt(0x200E,pBlockPtr)
#define FlushGS(pBlockPtr) PDosInt(0x2015,pBlockPtr)
#define FormatGS(pBlockPtr) PDosInt(0x2024,pBlockPtr)
#define FSTSpecific(pBlockPtr) PDosInt(0x2033,pBlockPtr)
#define GetBootVolGS(pBlockPtr) PDosInt(0x2028,pBlockPtr)
#define GetDevNumberGS(pBlockPtr) PDosInt(0x2020,pBlockPtr)
#define GetDirEntryGS(pBlockPtr) PDosInt(0x201C,pBlockPtr)
#define GetEOFGS(pBlockPtr) PDosInt(0x2019,pBlockPtr)
#define GetFileInfoGS(pBlockPtr) PDosInt(0x2006,pBlockPtr)
#define GetFSTInfoGS(pBlockPtr) PDosInt(0x202B,pBlockPtr)
#define GetLevelGS(pBlockPtr) PDosInt(0x201B,pBlockPtr)
#define GetMarkGS(pBlockPtr) PDosInt(0x2017,pBlockPtr)
#define GetNameGS(pBlockPtr) PDosInt(0x2027,pBlockPtr)
#define GetPrefixGS(pBlockPtr) PDosInt(0x200A,pBlockPtr)
#define GetRefInfoGS(pBlockPtr) PDosInt(0x2039,pBlockPtr)
#define GetRefNumGS(pBlockPtr) PDosInt(0x2038,pBlockPtr)
#define GetStdRefNumGS(pBlockPtr) PDosInt(0x2037,pBlockPtr)
#define GetSysPrefsGS(pBlockPtr) PDosInt(0x200F,pBlockPtr)
#define GetVersionGS(pBlockPtr) PDosInt(0x202A,pBlockPtr)
#define JudgeNameGS(pBlockPtr) PDosInt(0x2007,pBlockPtr)
#define NewlineGS(pBlockPtr) PDosInt(0x2011,pBlockPtr)
#define NullGS(pBlockPtr) PDosInt(0x200D,pBlockPtr)
#define OpenGS(pBlockPtr) PDosInt(0x2010,pBlockPtr)
#define OSShutDownGS(pBlockPtr) PDosInt(0x2003,pBlockPtr)
#define QuitGS(pBlockPtr) PDosInt(0x2029,pBlockPtr)
#define ReadGS(pBlockPtr) PDosInt(0x2012,pBlockPtr)
#define ResetCacheGS(pBlockPtr) PDosInt(0x2026,pBlockPtr)
#define SessionStatusGS(pBlockPtr) PDosInt(0x201F,pBlockPtr)
#define SetEOFGS(pBlockPtr) PDosInt(0x2018,pBlockPtr)
#define SetFileInfoGS(pBlockPtr) PDosInt(0x2005,pBlockPtr)
#define SetLevelGS(pBlockPtr) PDosInt(0x201A,pBlockPtr)
#define SetMarkGS(pBlockPtr) PDosInt(0x2016,pBlockPtr)
#define SetPrefixGS(pBlockPtr) PDosInt(0x2009,pBlockPtr)
#define SetStdRefNumGS(pBlockPtr) PDosInt(0x203A,pBlockPtr)
#define SetSysPrefsGS(pBlockPtr) PDosInt(0x200C,pBlockPtr)
#define UnbindIntGS(pBlockPtr) PDosInt(0x2032,pBlockPtr)
#define VolumeGS(pBlockPtr) PDosInt(0x2008,pBlockPtr)
#define WriteGS(pBlockPtr) PDosInt(0x2013,pBlockPtr)

#ifndef __PRODOS__ 
 #define GetSysPrefs(arg) GetSysPrefsGS(arg)
 #define BeginSession(arg) BeginSessionGS(arg)
 #define EndSession(arg) EndSessionGS(arg)
 #define SessionStatus(arg) SessionStatusGS(arg)
 #define ResetCache(arg) ResetCacheGS(arg)
 #define ChangePath(arg) ChangePathGS(arg)
 #define ClearBackupBit(arg) ClearBackupBitGS(arg)
 #define Close(arg) CloseGS(arg)
 #define Create(arg) CreateGS(arg)
 #define DControl(arg) DControlGS(arg)
 #define Destroy(arg) DestroyGS(arg)
 #define DInfo(arg) DInfoGS(arg)
 #define DRead(arg) DReadGS(arg)
 #define DStatus(arg) DStatusGS(arg)
 #define DWrite(arg) DWriteGS(arg)
 #define EraseDisk(arg) EraseDiskGS(arg)
 #define ExpandPath(arg) ExpandPathGS(arg)
 #define Flush(arg) FlushGS(arg)
 #define Format(arg) FormatGS(arg)
 #define GetBootVol(arg) GetBootVolGS(arg)
 #define GetDevNumber(arg) GetDevNumberGS(arg)
 #define GetDirEntry(arg) GetDirEntryGS(arg)
 #define GetEOF(arg) GetEOFGS(arg)
 #define GetFileInfo(arg) GetFileInfoGS(arg) 
 #define GetFSTInfo(arg) GetFSTInfoGS(arg)
 #define GetLevel(arg) GetLevelGS(arg)
 #define GetMark(arg) GetMarkGS(arg)
 #define GetName(arg) GetNameGS(arg)
 #define GetPrefix(arg) GetPrefixGS(arg)
 #define GetVersion(arg) GetVersionGS(arg)
 #define JudgeName(arg) JudgeNameGS(arg)
 #define Newline(arg) NewlineGS(arg)
 #define Null(arg) NullGS(arg)
 #define Open(arg) OpenGS(arg)
 #define Quit(arg) QuitGS(arg)
 #define Read(arg) ReadGS(arg)
 #define SetEOF(arg) SetEOFGS(arg)
 #define SetFileInfo(arg) SetFileInfoGS(arg)
 #define SetLevel(arg) SetLevelGS(arg)
 #define SetMark(arg) SetMarkGS(arg)
 #define SetPrefix(arg) SetPrefixGS(arg)
 #define UnbindInt(arg) UnbindIntGS(arg)
 #define Volume(arg) VolumeGS(arg)
 #define Write(arg) WriteGS(arg)
 #define BindInt(arg) BindIntGS(arg)
 
 #define ChangePathRec ChangePathRecGS 
 #define CreateRec CreateRecGS 
 #define DAccessRec DAccessRecGS 
 #define DevNumRec DevNumRecGS 
 #define DInfoRec DInfoRecGS 
 #define DIORec DIORecGS 
 #define DirEntryRec DirEntryRecGS 
 #define EOFRec EOFRecGS
 #define ExpandPathRec ExpandPathRecGS 
 #define FileInfoRec FileInfoRecGS 
 #define FormatRec FormatRecGS 
 #define FSTInfoRec FSTInfoRecGS 
 #define InterruptRec InterruptRecGS 
 #define IORec IORecGS 
 #define JudgeNameRec JudgeNameRecGS
 #define LevelRec LevelRecGS 
 #define NameRec NameRecGS
 #define GetNameRec GetNameRecGS 
 #define NewlineRec NewlineRecGS 
 #define OpenRec OpenRecGS 
 #define PositionRec PositionRecGS 
 #define PrefixRec PrefixRecGS 
 #define QuitRec QuitRecGS 
 #define RefNumRec RefNumRecGS 
 #define SetPositionRec SetPositionRecGS 
 #define SysPrefRec SysPrefRecGS 
 #define VersionRec VersionRecGS 
 #define VolumeRec VolumeRecGS 
 
#endif 

#endif
