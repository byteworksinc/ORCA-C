/********************************************
*
* Miscelaneous Tool Set
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

#ifndef __MISCTOOL__
#define __MISCTOOL__

/* Error codes */
#define badInputErr 0x0301              /* bad input parameter */
#define noDevParamErr 0x0302            /* no device for input parameter */
#define taskInstlErr 0x0303             /* task already installed error */
#define noSigTaskErr 0x0304             /* no signature in task header */
#define queueDmgdErr 0x0305             /* queue has been damaged error */
#define taskNtFdErr 0x0306              /* task was not found error */
#define firmTaskErr 0x0307              /* firmware task was unsuccessful */
#define hbQueueBadErr 0x0308            /* heartbeat queue damaged */
#define unCnctdDevErr 0x0309            /* attempted to dispatch to unconnected device */
#define idTagNtAvlErr 0x030B            /* ID tag not available */
#define notInList 0x0380
#define invalidTag 0x0381               /* correct signature value not found in header */
#define alreadyInQueue 0x0382
#define badTimeVerb 0x0390
#define badTimeData 0x0391

/* System Fail Codes */
#define pdosUnClmdIntErr 0x0001         /* ProDOS unclaimed interrupt error */
#define divByZeroErr 0x0004             /* divide by zero error */
#define pdosVCBErr 0x000A               /* ProDOS VCB unusable */
#define pdosFCBErr 0x000B               /* ProDOS FCB unusable */
#define pdosBlk0Err 0x000C              /* ProDOS block zero allocated illegally */
#define pdosIntShdwErr 0x000D           /* ProDOS interrupt w/ shadowing off */
#define stupVolMntErr 0x0100            /* can't mount system startup volume */

/* Battery Ram Parameter Reference Numbers */
#define p1PrntModem 0x0000
#define p1LineLnth 0x0001
#define p1DelLine 0x0002
#define p1AddLine 0x0003
#define p1Echo 0x0004
#define p1Buffer 0x0005
#define p1Baud 0x0006
#define p1DtStpBits 0x0007
#define p1Parity 0x0008
#define p1DCDHndShk 0x0009
#define p1DSRHndShk 0x000A
#define p1XnfHndShk 0x000B
#define p2PrntModem 0x000C
#define p2LineLnth 0x000D
#define p2DelLine 0x000E
#define p2AddLine 0x000F
#define p2Echo 0x0010
#define p2Buffer 0x0011
#define p2Baud 0x0012
#define p2DtStpBits 0x0013
#define p2Parity 0x0014
#define p2DCDHndShk 0x0015
#define p2DSRHndShk 0x0016
#define p2XnfHndShk 0x0017
#define dspColMono 0x0018
#define dsp40or80 0x0019
#define dspTxtColor 0x001A
#define dspBckColor 0x001B
#define dspBrdColor 0x001C
#define hrtz50or60 0x001D
#define userVolume 0x001E
#define bellVolume 0x001F
#define sysSpeed 0x0020
#define slt1intExt 0x0021
#define slt2intExt 0x0022
#define slt3intExt 0x0023
#define slt4intExt 0x0024
#define slt5intExt 0x0025
#define slt6intExt 0x0026
#define slt7intExt 0x0027
#define startupSlt 0x0028
#define txtDspLang 0x0029
#define kyBdLang 0x002A
#define kyBdBuffer 0x002B
#define kyBdRepSpd 0x002C
#define kyBdRepDel 0x002D
#define dblClkTime 0x002E
#define flashRate 0x002F
#define shftCpsLCas 0x0030
#define fstSpDelKey 0x0031
#define dualSpeed 0x0032
#define hiMouseRes 0x0033
#define dateFormat 0x0034
#define clockFormat 0x0035
#define rdMinRam 0x0036
#define rdMaxRam 0x0037
#define langCount 0x0038
#define lang1 0x0039
#define lang2 0x003A
#define lang3 0x003B
#define lang4 0x003C
#define lang5 0x003D
#define lang6 0x003E
#define lang7 0x003F
#define lang8 0x0040
#define layoutCount 0x0041
#define layout1 0x0042
#define layout2 0x0043
#define layout3 0x0044
#define layout4 0x0045
#define layout5 0x0046
#define layout6 0x0047
#define layout7 0x0048
#define layout8 0x0049
#define layout9 0x004A
#define layout10 0x004B
#define layout11 0x004C
#define layout12 0x004D
#define layout13 0x004E
#define layout14 0x004F
#define layout15 0x0050
#define layout16 0x0051
#define aTalkNodeNo 0x0080

/* GetAddr Parameter Reference Numbers */
#define irqIntFlag 0x0000
#define irqDataReg 0x0001
#define irqSerial1 0x0002
#define irqSerial2 0x0003
#define irqAplTlkHi 0x0004
#define tickCnt 0x0005
#define irqVolume 0x0006
#define irqActive 0x0007
#define irqSndData 0x0008
#define brkVar 0x0009
#define evMgrData 0x000A
#define mouseSlot 0x000B
#define mouseClamps 0x000C
#define absClamps 0x000D
#define sccIntFlag 0x000E

/* Hardware Interrupt Status Numbers; these are returned by GetIRQEnable */
#define extVGCInt 0x01
#define scanLineInt 0x02
#define adbDataInt 0x04
#define ADTBDataInt 0x04                /* maintained for compatiblity with old interfaces */
#define oneSecInt 0x10
#define quartSecInt 0x20
#define vbInt 0x40
#define kbdInt 0x80

/* Interrupt Reference Numbers; these are parameters to IntSource */
#define kybdEnable 0x0000
#define kybdDisable 0x0001
#define vblEnable 0x0002
#define vblDisable 0x0003
#define qSecEnable 0x0004
#define qSecDisable 0x0005
#define oSecEnable 0x0006
#define oSecDisable 0x0007
#define adbEnable 0x000A
#define adbDisable 0x000B
#define scLnEnable 0x000C
#define scLnDisable 0x000D
#define exVCGEnable 0x000E
#define exVCGDisable 0x000F

/* Mouse Mode Values */
#define mouseOff 0x0000
#define transparent 0x0001
#define transParnt 0x0001  /* (old name) */
#define moveIntrpt 0x0003
#define bttnIntrpt 0x0005
#define bttnOrMove 0x0007
#define mouseOffVI 0x0008
#define transParntVI 0x0009  /* (old name) */
#define transparentVI 0x0009
#define moveIntrptVI 0x000B
#define bttnIntrptVI 0x000D
#define bttnOrMoveVI 0x000F

/* Vector Reference Numbers */
#define toolLoc1 0x0000
#define toolLoc2 0x0001
#define usrTLoc1 0x0002
#define usrTLoc2 0x0003
#define intrptMgr 0x0004
#define copMgr 0x0005
#define abortMgr 0x0006
#define _sysFailMgr 0x0007
#define aTalkIntHnd 0x0008
#define sccIntHnd 0x0009
#define scLnIntHnd 0x000A
#define sndIntHnd 0x000B
#define vblIntHnd 0x000C
#define mouseIntHnd 0x000D
#define qSecIntHnd 0x000E
#define kybdIntHnd 0x000F
#define adbRBIHnd 0x0010
#define adbSRQHnd 0x0011
#define deskAccHnd 0x0012
#define flshBufHnd 0x0013
#define kybdMicHnd 0x0014
#define oneSecHnd 0x0015
#define extVCGHnd 0x0016
#define otherIntHnd 0x0017
#define crsrUpdtHnd 0x0018
#define incBsyFlag 0x0019
#define decBsyFlag 0x001A
#define bellVector 0x001B
#define breakVector 0x001C
#define traceVector 0x001D
#define stepVector 0x001E
#define ctlYVector 0x0028
#define proDOSVector 0x002A
#define proDOSVctr 0x002A               /* for backward compatibility */
#define osVector 0x002B
#define msgPtrVector 0x002C
#define msgPtrVctr 0x002C               /* for backward compatibility */
#define memMoverVector 0x0080
#define sysSpeedVector 0x0081
#define slotArbiterVector 0x0082
#define hiInterruptVector 0x0086
#define midiInterruptVector 0x0087

/* ConvSeconds verbs */
#define secs2TimeRec 0
#define TimeRec2Secs 1
#define secs2Text 2
#define secs2ProDOS 4
#define ProDOS2Secs 5
#define getCurrTimeInSecs 6
#define setCurrTimeInSecs 7
#define ProDOS2TimeRec 8
#define TimeRec2ProDOS 9
#define secs2HCard 10
#define HCard2Secs 11

/* SysBeep2 constants */
#define sbSilence 0x8000
#define sbDefer 0x4000
#define sbAlertStage0 0x0000
#define sbAlertStage1 0x0001
#define sbAlertStage2 0x0002
#define sbAlertStage3 0x0003
#define sbOutsideWindow 0x0004
#define sbOperationComplete 0x0005
#define sbBadKeypress 0x0008
#define sbBadInputValue 0x0009
#define sbInputFieldFull 0x000A
#define sbOperationImpossible 0x000B
#define sbOperationFailed 0x000C
#define sbGSOStoP8 0x0011
#define sbP8toGSOS 0x0012
#define sbDiskInserted 0x0013
#define sbDiskEjected 0x0014
#define sbSystemShutdown 0x0015
#define sbDiskRequest 0x0030
#define sbSystemStartup 0x0031
#define sbSystemRestart 0x0032
#define sbBadDisk 0x0033
#define sbKeyClick 0x0034
#define sbReturnKey 0x0035
#define sbSpaceKey 0x0036
#define sbWhooshOpen 0x0040
#define sbWhooshClosed 0x0041
#define sbFillTrash 0x0042
#define sbEmptyTrash 0x0043
#define sbAlertWindow 0x0050
#define sbAlertStop 0x0052
#define sbAlertNote 0x0053
#define sbAlertCaution 0x0054
#define sbScreenBlanking 0x0060
#define sbScreenUnblanking 0x0061
#define sbBeginningLongOperation 0x0070
#define sbYouHaveMail 0x0100
#define sbErrorWindowBase 0x0E00 /* uses $0Exx */
#define sbErrorWindowOther 0x0EFF
#define sbFileTransferred 0x0F80
#define sbRealtimeMessage 0x0F81
#define sbConnectedToService 0x1000
#define sbDisconnectedFromService 0x1001
#define sbEnteredRealtimeChat 0x1002
#define sbLeftRealtimeChat 0x1003
#define sbFeatureEnabled 0x1010
#define sbFeatureDisabled 0x1011

/* StringToText constants */
#define fAllowMouseText 0x8000
#define fAllowLongerSubs 0x4000
#define fForceLanguage 0x2000
#define fPassThru 0x1000

struct ClampRec {
   Word yMaxClamp;
   Word yMinClamp; 
   Word xMaxClamp; 
   Word xMinClamp; 
   };
typedef struct ClampRec ClampRec, *ClampRecPtr, **ClampRecHndl;

struct FWRec {
   Word yRegExit; 
   Word xRegExit; 
   Word aRegExit; 
   Word status; 
   };
typedef struct FWRec FWRec, *FWRecPtr, **FWRecHndl;

struct MouseRec {
   Byte mouseMode; 
   Byte mouseStatus; 
   Word yPos; 
   Word xPos; 
   };
typedef struct MouseRec MouseRec, *MouseRecPtr, **MouseRecHndl;

struct InterruptStateRec {
   Word irq_A;
   Word irq_X;
   Word irq_Y;
   Word irq_S;
   Word irq_D;
   Byte irq_P;
   Byte irq_DB;
   Byte irq_e;
   Byte irq_K;
   Word irq_PC;
   Byte irq_state;
   Word irq_shadow;
   Byte irq_mslot;
   };
typedef struct InterruptStateRec InterruptStateRec, *InterruptStateRecPtr, **InterruptStateRecHndl;

struct QueueHeaderRec {
   struct QueueHeaderRec *qNext;
   Word reserved;
   Word signature;                      /* Validates header - must be $A55A  */
   };
typedef struct QueueHeaderRec QueueHeaderRec, *QueueHeaderRecPtr;

struct HexTime {
   byte second;
   byte minute;
   byte hour;
   byte curYear;
   byte day;
   byte month;
   };
typedef struct HexTime HexTime;

extern pascal void MTBootInit(void) inline(0x0103,dispatcher);
extern pascal void MTStartUp(void) inline(0x0203,dispatcher);
extern pascal void MTShutDown(void) inline(0x0303,dispatcher);
extern pascal Word MTVersion(void) inline(0x0403,dispatcher);
extern pascal void MTReset(void) inline(0x0503,dispatcher);
extern pascal Boolean MTStatus(void) inline(0x0603,dispatcher);
extern pascal void WriteBRam(Pointer) inline(0x0903,dispatcher);
extern pascal void ReadBRam(Pointer) inline(0x0A03,dispatcher);
extern pascal void WriteBParam(Word, Word) inline(0x0B03,dispatcher);
extern pascal Word ReadBParam(Word) inline(0x0C03,dispatcher);
extern TimeRec ReadTimeHex(void);
extern pascal void WriteTimeHex(HexTime) inline(0x0E03,dispatcher);
extern pascal void ReadAsciiTime(Pointer) inline(0x0F03,dispatcher);
extern FWRec FWEntry(Word, Word, Word, Word);
extern pascal Pointer GetAddr(Word) inline(0x1603,dispatcher);
extern pascal LongWord GetTick(void) inline(0x2503,dispatcher);
extern pascal Word GetIRQEnable(void) inline(0x2903,dispatcher);
extern pascal void IntSource(Word) inline(0x2303,dispatcher);
extern pascal void ClampMouse(Word, Word, Word, Word) inline(0x1C03,dispatcher);
extern pascal void ClearMouse(void) inline(0x1B03,dispatcher);
extern ClampRec GetMouseClamp(void);
extern pascal void HomeMouse(void) inline(0x1A03,dispatcher);
extern pascal void InitMouse(Word) inline(0x1803,dispatcher);
extern pascal void PosMouse(Integer, Integer) inline(0x1E03,dispatcher);
extern MouseRec ReadMouse(void);
extern pascal Word ServeMouse(void) inline(0x1F03,dispatcher);
extern pascal void SetMouse(Word) inline(0x1903,dispatcher);
extern pascal void SetAbsClamp(Word, Word, Word, Word) inline (0x2A03,dispatcher);
extern ClampRec GetAbsClamp(void);
extern pascal Word PackBytes(Handle, Word *, Pointer, Word) inline(0x2603,dispatcher);
extern pascal Word UnPackBytes(Pointer, Word, Handle, Word *) inline(0x2703,dispatcher);
extern pascal Word Munger(Handle, Word *, Pointer, Word, Pointer, Word, Pointer) inline(0x2803,dispatcher);
extern pascal void SetHeartBeat(Pointer) inline(0x1203,dispatcher);
extern pascal void DelHeartBeat(Pointer) inline(0x1303,dispatcher);
extern pascal void ClrHeartBeat(void) inline(0x1403,dispatcher);
extern pascal void SysBeep(void) inline(0x2C03,dispatcher);
extern pascal void SysFailMgr(Word, Pointer) inline(0x1503,dispatcher);
extern pascal Word GetNewID(Word) inline(0x2003,dispatcher);
extern pascal void DeleteID(Word) inline(0x2103,dispatcher);
extern pascal void StatusID(Word) inline(0x2203,dispatcher);
extern pascal void SetVector(Word, Pointer) inline(0x1003,dispatcher);
extern pascal Pointer GetVector(Word) inline(0x1103,dispatcher);

extern pascal void AddToQueue(Pointer, Pointer) inline(0x2E03,dispatcher);
extern pascal void DeleteFromQueue(Pointer, Pointer) inline(0x2F03,dispatcher);
extern pascal ProcPtr GetCodeResConverter(void) inline(0x3403,dispatcher);
extern pascal void GetInterruptState(Pointer, Word) inline(0x3103,dispatcher);
extern pascal Word GetIntStateRecSize(void) inline(0x3203,dispatcher);
/* extern pascal Pointer GetRomResource() inline(0x3503,dispatcher); */
extern MouseRec ReadMouse2(void);
/* extern pascal void ReleaseROMResource() inline(0x3603,dispatcher); */
extern pascal void SetInterruptState(Pointer, Word) inline(0x3003,dispatcher);

extern pascal LongWord ConvSeconds(Word, Long, Pointer) inline(0x3703,dispatcher);
extern pascal Word ScanDevices(void) inline(0x3D03,dispatcher);
extern pascal void ShowBootInfo(Pointer, Pointer) inline(0x3C03,dispatcher);
extern pascal LongWord StringToText(Word, Ptr, Word, Ptr) inline(0x3B03,dispatcher);
extern pascal void SysBeep2(Word) inline(0x3803,dispatcher);
extern pascal void VersionString(Word, Long, Ptr) inline(0x3903,dispatcher);
extern pascal Word WaitUntil(Word, Word) inline(0x3A03,dispatcher);

extern pascal Word AlertMessage(Ptr, Word, Ptr) inline(0x3E03,dispatcher);
extern pascal Word DoSysPrefs(Word, Word) inline(0x3F03,dispatcher);
      
#endif
