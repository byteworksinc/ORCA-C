/*****************************************************************
*
*  Ackermann
*
*  This program implements a famous mathematical function that
*  is often used to examine recursion.  It is deceptively
*  simple, but can take enormous amounts of time and stack
*  space for relatively small arguments.  For that reason,
*  rangechecking has been enabled to ensure the integrity of the
*  stack.
*
*  By Mike Westerfield
*
*  Copyright 1987-1989
*  Byte Works, Inc.
*
*****************************************************************/

#pragma keep "Ackermann"
#pragma debug 0x0001
#pragma lint -1

#include <stdio.h>

/* Constants */
#define maxm 2				/* max value of 1st argument */
#define maxn 3				/* max value of 2nd argument */

/* Global variables */
int a, m, n, depth, maxdepth;

/****************************************************************
*
* Ackermann - Demonstrates recursion in ORCA/C
*
****************************************************************/

int Ackermann (int m, int n)

{
depth++;
if (depth > maxdepth)
   maxdepth = depth;
if (m == 0)
   return (n + 1);
if (n == 0)
   return (Ackermann (m-1, 1));
return (Ackermann (m-1, Ackermann (m, n-1)));
depth--;
}


int main (void)

{
for (m = 0; m <= maxm; m++)
   for (n = 0; n <= maxn; n++) {
       depth    = 0;
       maxdepth = 0;
       a = Ackermann (m, n);
       printf ("Ackermann(%d, %d) = %-4d     ", m, n, a);
       printf ("Max recursion depth was %d\n", maxdepth);
       }
}
