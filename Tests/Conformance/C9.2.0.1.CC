/* Conformance Test 9.2.0.1:  Make sure pascal functions can be called.     */

#include <stdio.h>


pascal int pasFunc (int i, int j)

{
return i+j;
}


void main(void)

{

if (pasFunc(2,5) != 7)  goto Fail;
if (pasFunc(3,0) != 3)  goto Fail;
if (pasFunc(8,1) != 9)  goto Fail;
if (pasFunc(1,1) != 2)  goto Fail;

   printf ("Passed Conformance Test 9.2.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 9.2.0.1\n");
 }
