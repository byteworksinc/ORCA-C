/****************************************************************
*
*   Trace
*
*   ORCA/C can give you a traceback when a run-time error occurs.
*   A traceback shows the function and line number where the
*   error occurred, then gives a list of functions and line
*   numbers that show what subroutine calls were made to get to
*   the point where the error occurred.  This program illustrates
*   this by deliberately failing in the function named Fail.
*
*   By Mike Westerfield and Barbara Allred
*
*   Copyright 1987-1989
*   Byte Works, Inc.
*
******************************************************************/

#pragma keep "Trace"
#pragma debug 9
#pragma lint -1

#include <stdio.h>


/****************************************************************
*
* Fail - Subroutine that will generate a run-time error
*
****************************************************************/

static void Fail (void)
{
char ch [8000];				/* this array is too large for */
					/* the default run-time stack  */
(void)ch;				/* dummy use of ch to avoid lint msg */
}


/****************************************************************
*
* DoIt - Calls subroutine that will generate a run-time error
*
****************************************************************/

static void DoIt (void)

{
Fail();
}


/****************************************************************
*
* Main program starts here
*
****************************************************************/

int main (void)

{
printf ("This program fails.  Generating a traceback:\n");
DoIt();
}
