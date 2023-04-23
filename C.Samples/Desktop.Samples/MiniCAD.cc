/****************************************************************
*
*  MiniCAD
*
*  MiniCAD is a (very) simple CAD program based on the Frame
*  program.  With MiniCAD, you can open new windows, close
*  windows that are on the desktop, and draw lines using the
*  mouse.  Multiple windows are supported.
*
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "MiniCAD"
#pragma lint -1

#include <orca.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include <types.h>
#include <quickdraw.h>
#include <misctool.h>
#include <event.h>
#include <control.h>
#include <window.h>
#include <menu.h>
#include <desk.h>
#include <lineedit.h>
#include <dialog.h>

#define apple_About 257			/* Menu ID #s */
#define file_Quit   256
#define file_New    258
#define file_Close  255

#define maxWindows  4			/* max # of drawing windows */
#define maxLines    50			/* max # of lines in a window */

typedef int BOOL;			/* simulate boolean types */
typedef struct { Point p1, p2; } lineRecord; /* line defined by its endpts */

					/* holds info about 1 window */
struct windowRecord { GrafPortPtr wPtr; /*   ptr to the window's port */
		      char  *name;	/*   name of the window */
		      int numLines;	/*   # lines in this window */
		      lineRecord lines [maxLines]; /* lines in drawing */
		      };

enum alertKind {norml, stop, note, caution}; /* kinds of alerts */

BOOL	  done;				/* tells if the program should stop  */
WmTaskRec lastEvent;			/* last event returned in event loop */

static struct windowRecord windows [maxWindows] = /* drawing windows */
       { { NULL, "\pPaint 1" }, { NULL, "\pPaint 2" },
	 { NULL, "\pPaint 3" }, { NULL, "\pPaint 4" } };

static ParamList wParms =		/* parameters for NewWindow */
       { 78, 0xDDA7, NULL, 0, 0, 615, 25, 188, NULL, 0, 0, 0, 0, 0, 0, 10, 10,
	 0, 0, 0, 0, NULL, NULL, NULL, 25, 0, 188, 615, NULL, NULL };

static ItemTemplate button =		/* button item */
       { 1, 36, 15, 0, 0, buttonItem, "\pOK", 0, 0, NULL };

static ItemTemplate message =		/* message item */
       { 100, 5, 100, 90, 280, itemDisable+statText, NULL, 0, 0, NULL };

static AlertTemplate alertRec =		/* alert box */
       { 50, 180, 107, 460, 2, 0x80, 0x80, 0x80, 0x80, NULL, NULL, NULL };


/****************************************************************
*
* DoAlert - Create an alert box
*
* Input:
*      kind - kind of alert
*      msg  - alert message
*
****************************************************************/

void DoAlert (enum alertKind kind, char *msg)

{
SetForeColor (0);			/* set text colors */
SetBackColor (15);

message.itemDescr	= msg;			 /* init. non-constant */
alertRec.atItemList [0] = (ItemTempPtr) &button; /*   template fields  */
alertRec.atItemList [1] = (ItemTempPtr) &message;

switch (kind) {
   case norml:	   Alert (&alertRec, NULL);
		   break;

   case stop:	   StopAlert (&alertRec, NULL);
		   break;

   case note:	   NoteAlert (&alertRec, NULL);
		   break;

   case caution:   CautionAlert (&alertRec, NULL);
		   break;

   default:	   printf ("Error in DoAlert\n");
		   exit (-1);
		   break;
   }
}


#pragma databank 1
/****************************************************************
*
* DrawWindow - Draw the contents of the current window
*
****************************************************************/

void DrawWindow (void)

{
int i;					/* window's index */
int j;					/* loop variable */

struct windowRecord *wp; 		/* work pointers */
lineRecord *lp;

i = GetWRefCon (GetPort());
if (windows [i].numLines) {		/* skip the work if there */
					/*   aren't any lines     */
   SetPenMode (modeCopy);		/* set up to draw */
   SetSolidPenPat (0);
   SetPenSize (2, 1);
   wp = &windows [i];			/* draw each of the lines */
   for (j = 0; j < wp->numLines; ++j) {
       lp = &(wp->lines [j]);
       MoveTo (lp->p1.h, lp->p1.v);
       LineTo (lp->p2.h, lp->p2.v);
       }
   }
}
#pragma databank 0


/****************************************************************
*
* DoClose - Close the front drawing window, if there is one
*
****************************************************************/

void DoClose (void)

{
int i;

if (FrontWindow () != NULL) {
   i = GetWRefCon (FrontWindow ());
   CloseWindow (windows [i].wPtr);
   windows [i].wPtr = NULL;
   EnableMItem (file_New);
   }
}

 
/****************************************************************
*
* MenuAbout - Create the About alert box
*
****************************************************************/

void MenuAbout (void)

{
DoAlert (note, "\pMini-CAD 1.0\r"
	       "Copyright 1989\r"
	       "Byte Works, Inc.\r\r"
	       "By Mike Westerfield");
}


/****************************************************************
*
* DoNew - Open a new drawing window
*
****************************************************************/

void DoNew (void)

{
int i;					/* index variable */

i = 0;					/* find an empty record */
while (windows[i].wPtr != NULL)
   ++i;
windows[i].numLines = 0; 		/* no lines drawn yet */

wParms.wTitle = (Pointer) windows[i].name; /* init. non-constant */
wParms.wRefCon = i;			/* wParms fields */
wParms.wContDefProc = (VoidProcPtr) DrawWindow;
wParms.wPlane = (GrafPortPtr) topMost;

windows[i].wPtr = NewWindow (&wParms);	/* open the window */
if (toolerror()) {
   DoAlert (stop, "\pError opening the window.");
   windows [i].wPtr = NULL;
   }
else if (i == 3) 			/* don't allow more than 4 open windows */
   DisableMItem (file_New);
}


/****************************************************************
*
* HandleMenu - Handle a menu selection
*
****************************************************************/

void HandleMenu (int menuNum)

{
switch (menuNum) {
   case apple_About:   MenuAbout();
		       break;

   case file_Quit:     done = TRUE;
		       break;

   case file_New:      DoNew ();
		       break;

   case file_Close:    DoClose ();
   }
HiliteMenu (FALSE, (int) (lastEvent.wmTaskData >> 16));
}


/****************************************************************
*
* InitMenus - Initialize the menu bar
*
****************************************************************/

void InitMenus (void)

{
InsertMenu (NewMenu (">> Edit \\N3\r"	/* create the edit menu */
		     "--Undo\\N250V*Zz\r"
		     "--Cut\\N251*Xx\r"
		     "--Copy\\N252*Cc\r"
		     "--Paste\\N253*Vv\r"
		     "--Clear\\N254\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>  File \\N2\r"	/* create the file menu */
		     "--New\\N258*Nn\r"
		     "--Close\\N255V\r"
		     "--Quit\\N256*Qq\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>@\\XN1\r"	/* create the Apple menu */
		     "--About...\\N257V\r"
		     ".\r"), 0);

FixAppleMenu (1);			/* add desk accessories */
FixMenuBar ();				/* draw the completed menu bar */
DrawMenuBar ();
}

 
/****************************************************************
*
* Sketch - Track the mouse, drawing lines to connect the points
*
****************************************************************/

void Sketch (void)

{
Point endPoint;				/* the end point of the line */
Point firstPoint;			/* the initial point */
int i;					/* window index */
int numLines;				/* copy of windows [i].numLines */
EventRecord sEvent;			/* last event returned in event loop */

/* get the window's index */
i = GetWRefCon (FrontWindow());

/* check for too many lines */
if (windows [i].numLines == maxLines)
   DoAlert (stop, "\pThe window is full -\rmore lines cannot be\radded.");
else {
   /* initialize the pen */
   StartDrawing (FrontWindow());
   SetSolidPenPat (15);
   SetPenSize (2, 1);
   SetPenMode (modeXOR);

   /* record the initial pen location */
   firstPoint = lastEvent.where;
   GlobalToLocal (&firstPoint);
   MoveTo (firstPoint.h, firstPoint.v);
   LineTo (firstPoint.h, firstPoint.v);
   endPoint = firstPoint;

   /* follow the pen, rubber-banding the line */
   while (!GetNextEvent (mUpMask, &sEvent)) {
       GlobalToLocal (&sEvent.where);
       if ((endPoint.h != sEvent.where.h) || (endPoint.v != sEvent.where.v)) {
	   MoveTo (firstPoint.h, firstPoint.v);
	   LineTo (endPoint.h, endPoint.v);
	   MoveTo (firstPoint.h, firstPoint.v);
	   LineTo (sEvent.where.h, sEvent.where.v);
	   endPoint.h = sEvent.where.h;
	   endPoint.v = sEvent.where.v;
	   }
       }

   /* erase the last XORed line */
   MoveTo (firstPoint.h, firstPoint.v);
   LineTo (endPoint.h, endPoint.v);

   /* if we have a line (not a point), record it in window's line list */
   if ((firstPoint.h != endPoint.h) || (firstPoint.v != endPoint.v)) {
       numLines = windows[i].numLines++;
       windows [i].lines [numLines].p1 = firstPoint;
       windows [i].lines [numLines].p2 = endPoint;
       SetPenMode (modeCopy);
       SetSolidPenPat (0);
       MoveTo (firstPoint.h, firstPoint.v);
       LineTo (endPoint.h, endPoint.v);
       }
   }
}


/****************************************************************
*
* Program begins here
*
****************************************************************/

int main (void)

{
int event;				/* event #; returned by TaskMaster */

startdesk (640);
InitMenus ();				/* set up the menu bar */
lastEvent.wmTaskMask = 0x1FFFL;		/* let task master do most stuff */
ShowCursor ();				/* show the cursor */

done = FALSE;				/* main event loop */
do {
   event = TaskMaster (0x076E, &lastEvent);
   switch (event) {			/* handle the events we need to */
       case wInSpecial:
       case wInMenuBar:	   HandleMenu ((int) lastEvent.wmTaskData);
			   break;

       case wInGoAway :	   DoClose ();
			   break;

       case wInContent:	   Sketch ();
       }
   }
while (!done);
enddesk ();
return 0;
}
