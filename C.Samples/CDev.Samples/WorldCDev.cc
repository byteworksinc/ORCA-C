/****************************************************************/
/*								*/
/*   Hello World CDev						*/
/*								*/
/*   Mike Westerfield						*/
/*   October 1991						*/
/*								*/
/*   Copyright 1991						*/
/*   Byte Works, Inc.						*/
/*   All Rights Reserved.					*/
/*								*/
/****************************************************************/
/*								*/
/*   This CDev displays a text message.	 It can be used as a	*/
/*   framework for developing your own CDevs.			*/
/*								*/
/*   For detailed information about CDevs, see Apple II File	*/
/*   Type Notes for file type $D8.  Apple II File Type Notes	*/
/*   are available from major online services, large users	*/
/*   groups, or from APDA.					*/
/*								*/
/****************************************************************/

#pragma keep "worldobj"
#pragma cdev Driver
#pragma lint -1

#include <types.h>
#include <control.h>
#include <quickdraw.h>


GrafPortPtr wPtr;			/* our window pointer */


/*  DoAbout - Show the help info 				*/

void DoAbout (void)

{
NewControl2(wPtr, 0x0009, 257L); 	/* draw the text (it's a stattext control) */
}


/*  DoCreate - Create the controls				*/

void DoCreate (void)

{
NewControl2(wPtr, 0x0009, 256L); 	/* create the controls */
}



/*  Driver - main entry point					*/

long Driver (long data2, long data1, int message)

#define createCDev 7			/* message numbers */
#define aboutCDev  8

{
wPtr = (void *) data1;			/* get our window pointer (most calls) */
switch (message) {
   case createCDev:	DoCreate();
			break;
   case aboutCDev:	DoAbout();
			break;
   }
return 1;
}
