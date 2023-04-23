/*****************************************************************
*
*   Call GS/OS
*
*   This program shows how to call GS/OS directly.  You should
*   compare it with callp16.cc, which shows how to call ProDOS 16
*   (an older operating system that is now a subset of GS/OS).
*
*   This program dumps the contents of a screen image file to the
*   graphics screen.  It is assumed that the program callp16 was
*   executed prior to running this program, and that you have
*   made a note of the filename containing the screen dump that
*   was created by callp16.
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

#pragma keep "CallGSOS"
#pragma debug 1				/* check stack overflows */
#pragma lint -1

#include <types.h>
#include <stdlib.h>
#include <orca.h>
#include <quickdraw.h>
#include <gsos.h>
#include <stdio.h>
#include <string.h>

#define SCREENWIDTH 320			/* screen width in pixels */

static GSString255 filename;		/* name of file having screen contents */

					/* Data Control Blocks for GS/OS calls */
OpenRecGS openDCB = { 15, 0, NULL, 1, 0};
IORecGS readDCB = { 5, 0, (void *) 0x00E12000, 32768L, 0L, 0 };
RefNumRecGS closeDCB = { 1, 0 };

int main (void)

{
char *str;
int i;

/* Prompt user for the name of the file to load. */
printf ("Please enter the name of the file containing the screen image:\n");
scanf ("%s", filename.text);
filename.length = strlen(filename.text);

/* Initialize the pen and graphics screen. */
startgraph(SCREENWIDTH);		/* start QuickDraw II */
SetPenSize(4, 2);			/* use fatter pen */

/* Open the file and then write its contents to the graphics screen. */
openDCB.pathname = &filename;		/* open the file */
OpenGS(&openDCB);
if (i = toolerror()) {
   MoveTo(50, 100);
   SetSolidPenPat(black);
   sprintf(str, "Unable to open file for screen dump: err = %d\n", i);
   DrawCString(str);
   goto Fail;
   }

readDCB.refNum = openDCB.refNum;	/* read the file, sending */
ReadGS(&readDCB);			/*  contents to screen    */
if (i = toolerror()) {
   MoveTo(50, 100);
   SetSolidPenPat(black);
   sprintf(str, "Unable to read file for screen dump: err = %d\n", i);
   DrawCString(str);
   goto Fail;
   }

closeDCB.refNum = openDCB.refNum;	/* close the file */
CloseGS (&closeDCB);

/* Wrap up:  Wait for user to signal end, then shut down tools started. */
Fail:
SetSolidPenPat(black);			/* wait for user to signal end */
str = "Press RETURN when ready to quit program";
MoveTo(SCREENWIDTH-CStringWidth(str), 40);
DrawCString(str);
getchar(); getchar();
endgraph();
return 0;
}
