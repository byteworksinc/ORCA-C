/* Conformance Test 9.5.0.2:  Make sure assignments can be used as parms */

#include <stdio.h>

int func (int x)

{
return x*2;
}


void main(void)

{
   int i,j;

   i = j = 0;

   i = func(j = 3);

   if (i != 6) goto Fail;
   if (j != 3) goto Fail;

   printf ("Passed Conformance Test 9.5.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 9.5.0.2\n");
 }
