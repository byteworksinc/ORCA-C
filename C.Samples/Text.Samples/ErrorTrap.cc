/******************************************************************
*
*   Error Trap
*
*   You can trap run-time errors with ORCA/C.  There are several
*   reasons to do this, including:
*
*        1.  Error messages take up space.  By replacing the
*            system error handler with your own, you can cut
*            out the space needed to store the run-time error
*            messages.
*        2.  You may want to trap some kinds of run-time
*            errors, like file not found or out of memory,
*            and handle them yourself.  If you do not, the
*            error will cause the program to stop executing,
*            which may not be the desired result.
*
*   This program shows how to intercept and handle run-time
*   errors.  This is done by placing a function in your program
*   called SYSTEMERROR.  The function has a single parameter,
*   which is an integer error number.  SYSTEMERROR replaces a
*   function by the same name that is normally linked in from
*   the libraries.  Another library function, SystemErrorLocation,
*   provides the name of the function and the line number where
*   the run-time error occurred.
*
*   Note that if you do not want to handle a particular error,
*   you can call the system error handlers from your program.
*   See the sample program ERROREXIT.CC for an example.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
*******************************************************************/

#pragma keep "ErrorTrap"
#pragma debug 9				/* enable range checking + trace-back */
#pragma lint -1

#include <stdio.h>

extern pascal void SystemErrorLocation (void);
/* A library procedure that prints the current location and a traceback. */

/****************************************************************
*
* BadFunction - Subroutine that will generate a run-time error
*
****************************************************************/

static void BadFunction (void)

{
char ch [8000];				/* this array is too large for */
					/* the default run-time stack  */
(void)ch;				/* dummy use of ch to avoid lint msg */
}


/****************************************************************
*
* DoIt - Calls function that will generate a run-time error
*
****************************************************************/

static void DoIt (void)
{
BadFunction();				/* call function with large array */
}


/****************************************************************
*
* SystemError - Replaces SYSTEMERROR function in the ORCA library
*
****************************************************************/

static void SYSTEMERROR (int errorNumber)

{
printf ("Run-time error detected.  error number = %d\n", errorNumber);
}


/****************************************************************
*
* Main program starts here
*
****************************************************************/

int main(void)
{
DoIt();
SystemErrorLocation();
}
