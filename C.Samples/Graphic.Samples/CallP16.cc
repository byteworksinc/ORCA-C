/*****************************************************************
*
*   Call ProDOS 16
*
*   This program draws ovals on the 16 color screen.  It then
*   dumps the contents of the graphics screen to a file.  If the
*   file is loaded and then stored to the graphics screen, the
*   image dumped is displayed.
*
*   DO NOT EXECUTE THIS PROGRAM FROM THE DESKTOP.  It uses non-
*   standard mechanisms for accessing the graphics screen.
*
*   By Barbara Allred and Mike Westerfield
*
*   Copyright 1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "CallP16"
#pragma debug 1				/* check stack overflows */

#include <prodos.h>

#pragma lint -1

#include <quickdraw.h>
#include <stdio.h>
#include <string.h>
#include <orca.h>

Rect ovalRect, *ovalPtr = &ovalRect;	/* bounds rectangle for ovals */

					/* Data Control Blocks for ProDOS 16 calls */
FileRec createDCB = { NULL, 0x00E3, 0x06, 0, 0x01, 0, 0 };
OpenRec openDCB;
FileIORec writeDCB;


int main (void)

{
#define SCREENWIDTH 320			/* screen width in pixels */

int x = 40;				/* horizontal location in global coords */
int y = 20;				/* vertical location in global coords */
int color;				/* initial pen color */
char *str;				/* work pointer */

char filename [L_tmpnam+1] = "";	/* name of file receiving screen dump */
char *fn;

/* Start Quick Draw II */
startgraph(SCREENWIDTH);
SetPenSize(4, 2);			/* use fatter pen */

/* Draw ovals in different colors on the screen. */
for (color = 0; color < 15; color++) {
   ovalRect.v1 = x;        ovalRect.h1 = y;
   ovalRect.v2 = x + 15;   ovalRect.h2 = y + 15;
   SetSolidPenPat(color+1);
   MoveTo(y, x);
   PaintOval(ovalPtr);
   SetSolidPenPat(color);
   MoveTo(y, x);
   FrameOval(ovalPtr);
   if (toolerror()) {
      DrawCString("Failure in drawing routine\n");
      goto Fail;
      }
   y += 10;    x += 10;
   }

/* Dump contents of screen to a file. */
fn = tmpnam(&filename[1]);		/* get unique filename for dump */
if (fn == NULL) {
   MoveTo (100, 50);
   SetSolidPenPat(black);
   DrawCString("Unable to obtain unique filename for screen dump");
   goto Fail;
   }
filename[0] = strlen(&filename[1]);	/* convert C-string to P-string */

createDCB.pathname = filename;		/* create screen dump file */
CREATE(&createDCB);
if (toolerror()) {
   MoveTo(50, 100);
   SetSolidPenPat(black);
   DrawCString("Unable to create file for screen dump");
   goto Fail;
   }
openDCB.openPathname = filename;	/* open the screen dump file */
OPEN(&openDCB);
if (toolerror()) {
   MoveTo(50, 100);
   SetSolidPenPat(black);
   DrawCString("Unable to open file for screen dump");
   goto Fail;
   }
writeDCB.fileRefNum = openDCB.openRefNum; /* write screen contents to file */
writeDCB.dataBuffer = (void *) 0x00E12000;
writeDCB.requestCount = 32768L;
WRITE(&writeDCB);
if (toolerror()) {
   MoveTo(50, 100);
   SetSolidPenPat(black);
   DrawCString("Unable to write screen contents to file");
   goto Fail;
   }
CLOSE(&openDCB);			/* close the screen dump file   */

/* Wrap up:  Wait for key press and then shut down QuickDraw II. */
Fail:
SetSolidPenPat(black);			/* wait for user to signal end */
str = "Press return when ready to quit program";
MoveTo(SCREENWIDTH-CStringWidth(str), 40);
DrawCString(str);
getchar();
endgraph();
printf("The name of the file containing the screen dump is:\n%b", filename);
}
