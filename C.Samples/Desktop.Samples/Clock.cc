/**************************************************************
*
*  This desk accessory brings up a simple clock.  It can be
*  used as an outline when creating more complex desk accessories.
*
*  Original Pascal version by Phil Montoya
*  C Translation by Mike Westerfield
*
*  Copyright 1987,1989
*  Byte Works, Inc.
*
**************************************************************/

#pragma keep "Clock"
#pragma nda Open Close Action Init 60 0xFFFF "--Clock\\H**"
#pragma lint -1

#include <stddef.h>

#include <quickdraw.h>
#include <misctool.h>
#include <event.h>
#include <desk.h>
#include <window.h>

#define TRUE	1			/* boolean constants */
#define FALSE	0

int clockActive = 0;			/* are we already active flag */
GrafPortPtr clockWinPtr; 		/* window pointer */

char title[] = "\pClock";		/* window title */
ParamList clockWin = {			/* new window record */
   78,					/* paramLength */
   0xC0A0,				/* wFrameBits */
   title,				/* wTitle */
   0L,					/* wRefCon */
   {0,0,0,0},				/* wZoom */
   NULL, 				/* wColor */
   0,0,					/* wYOrigin,wXOrigin */
   0,0,					/* wDataH,wDataW */
   0,0,					/* wMaxH,wMaxW */
   0,0,					/* wScrollVer,wScrollHor */
   0,0,					/* wPageVer,wPageHor */
   0,					/* wInfoRefCon */
   0,					/* wInfoHeight */
   NULL, 				/* wFrameDefProc */
   NULL, 				/* wInfoDefProc */
   NULL, 				/* wContDefProc */
   {50,50,62,200},			/* wPosition */
   (void *) -1L, 			/* wPlane */
   NULL					/* wStorage */
   };

/***************************************************************
*
*  DrawTime - Reads the time and draws it in the window
*
***************************************************************/

void DrawTime (void)

{
int i;					/* index variable */
char timeString[21];			/* string to hold time */

ReadAsciiTime(timeString);
timeString[20] = 0;
for (i = 0; i < 20; i++)
    timeString[i] &= 0x7F;
MoveTo(7, 10);
DrawCString(timeString);
}

/***************************************************************
*
*  Open - opens the desk accessory if it is not already active
*
*  Outputs:
*	GrafPortPtr - pointer to desk accessory window
*
***************************************************************/

GrafPortPtr Open (void)

{
if (!clockActive) {
   clockWinPtr = NewWindow(&clockWin);	/* open a window */
   SetSysWindow(clockWinPtr);		/* set it to the system window */
   clockActive = TRUE;			/* we are now active */
   return clockWinPtr;			/* return our window pointer */
   }
}

/***************************************************************
*
*  Close - closes the desk accessory if it is active
*
***************************************************************/

void Close(void)

{
if (clockActive) {
   CloseWindow(clockWinPtr);
   clockActive = FALSE;
   }
}

/***************************************************************
*
*  Action - Handle an action call
*
***************************************************************/

void Action (long param, int code)

{
EventRecordPtr evPtr;
GrafPortPtr currPort;

switch (code) {

   case eventAction: {
      evPtr = (EventRecordPtr) param;
      if (evPtr->what == updateEvt) {
	 BeginUpdate(clockWinPtr);
	 DrawTime();
	 EndUpdate(clockWinPtr);
	 }
      return;
      }

   case runAction: {
      currPort = GetPort();
      SetPort(clockWinPtr);
      DrawTime();
      SetPort(currPort);
      return;
      }

   default:
      return;

   }
}

/***************************************************************
*
*  Initialization
*
***************************************************************/

void Init(int code)

{
if (code == 0) {
   if (clockActive)
      Close();
   }
else
   clockActive = FALSE;
}
