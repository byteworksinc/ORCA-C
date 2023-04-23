/****************************************************************
*
*  Frame
*
*  This desktop program is about as simple as they get.	 It
*  brings up the Apple menu, a file menu with Quit and Close,
*  and an edit menu with Undo, Cut, Copy, Paste and Clear.
*  This is the minimum configuration for supporting desk
*  accessories.	 (All of these menus have pre-assigned numbers,
*  assigned by Apple.)
*
*  The purpose of this rather simple program is to show how
*  easy a desktop program can be to write, and to give you a
*  framework to use in developing your own programs.
*
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************/

#pragma keep "Frame"
#pragma lint -1

#include <orca.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

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

#define apple_About 257			/* Menu ID numbers */
#define file_Quit   256

enum alertKind {norml, stop, note, caution}; /* kinds of alerts */

typedef	  int BOOL;			/* simulate boolean types */
BOOL	  done;				/* tells if the program should stop */
WmTaskRec lastEvent;			/* last event returned in event loop */


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
static ItemTemplate button =		/* button item */
       { 1, 36, 15, 0, 0, buttonItem, "\pOK", 0, 0, NULL };

static ItemTemplate message =		/* message item */
       { 100, 5, 100, 90, 280, itemDisable+statText, NULL, 0, 0, NULL };

static AlertTemplate alertRec =		/* alert box */
       { 50, 180, 107, 460, 2, 0x80, 0x80, 0x80, 0x80, NULL, NULL, NULL };


SetForeColor (0);			/* set text colors */
SetBackColor (15);

message.itemDescr = msg; 			 /* init. non-constant */
alertRec.atItemList [0] = (ItemTempPtr) &button; /* template fields    */
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


/****************************************************************
*
* MenuAbout - Create the About menu
*
****************************************************************/

void MenuAbout (void)

{
DoAlert (note, "\pFrame 1.0\r"
	       "Copyright 1989\r"
	       "Byte Works, Inc.\r\r"
	       "By Mike Westerfield");
}


/****************************************************************
*
* HandleMenu - Handle a menu selection
*
****************************************************************/

void HandleMenu (int menuNum)

{
switch (menuNum) {
   case apple_About:   MenuAbout ();
		       break;

   case file_Quit:     done = TRUE;
		       break;

   default:	       break;
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
		     "--Close\\N255V\r"
		     "--Quit\\N256*Qq\r"
		     ".\r"), 0);

InsertMenu (NewMenu (">>@\\XN1\r"	/* create the Apple menu */
		     "--About Frame\\N257V\r"
		     ".\r"), 0);

FixAppleMenu (1);			/* add desk accessories */
FixMenuBar ();				/* draw the completed menu bar */
DrawMenuBar ();
}

 
/****************************************************************
*
* Main Program
*
****************************************************************/

int main (void)

{
int event;				/* event # returned by TaskMaster */

startdesk (640);
InitMenus ();				/* set up the menu bar */
lastEvent.wmTaskMask = 0x1FFFL;		/* let Task Master do most stuff */
ShowCursor ();				/* show the cursor */

done = FALSE;				/* main event loop */
do {
   event = TaskMaster (0x076E, &lastEvent);
   switch (event) {			/* handle the events we need to */
       case wInSpecial:
       case wInMenuBar:	   HandleMenu ((int) lastEvent.wmTaskData);
       default:		   break;
       }
   }
while (!done);
enddesk ();
}
