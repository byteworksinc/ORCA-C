/*******************************************************************
*
*   Error Exit
*
*   You can call the library routines that handle run-time errors
*   from your own program.  One of these, called strerror, will
*   print a text run-time error message to standard output.  You
*   pass a single integer parameter, which is the run-time error
*   number.  This procedure is generally called from an error trap
*   subroutine - see the sample program ERRORTRAP.CC for an example
*   of how to trap errors.  In this program strerror is used to
*   list the current run-time error messages.
*
*   The two built-in macros __FILE__ and __LINE__ are used to print
*   the current line number and the name of the current source file.
*
*   The library subroutine SystemErrorLocation provides trace-back
*   information; it is further covered in the text sample program
*   ERRORTRAP.CC.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*********************************************************************/

#pragma keep "ErrorExit"
#pragma debug 8				/* enable trace-back of code */
#pragma lint -1

#include <string.h>
#include <errno.h>
#include <stdio.h>

extern pascal void SystemErrorLocation (void);
/* A library procedure that prints the current location and a traceback. */

int main (void)

{
int i;

printf ("Run-time error messages are:\n\n");
for (i = 1; i <= sys_nerr; i++)
   printf ("%3d:  %s\n", i, strerror (i));

printf ("\nCurrent line: %d\nCurrent file: %s\n", __LINE__, __FILE__);

printf ("Exiting with a traceback.\n");
SystemErrorLocation ();
}
