/* Conformance Test 9.3.0.1:  Parameters, functions must be defined in time */
/*                            to call the function recursively.             */

#include <stdio.h>


int iexp (int x, int y)

{
if (x == 0)
   return 1;
if (y <= 1)
   return x;
return iexp(x,y-1)*x;
}


void main(void)

{

if (iexp(2,5) != 32)    goto Fail;
if (iexp(3,3) != 27)    goto Fail;
if (iexp(1,50) != 1)    goto Fail;
if (iexp(7,3) != 343)   goto Fail;

   printf ("Passed Conformance Test 9.3.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 9.3.0.1\n");
 }
