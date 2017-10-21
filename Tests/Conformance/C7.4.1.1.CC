/* Conformance Test 7.4.1.1:  Verification of subscripted expressions */

#include <stdio.h>
#include <math.h>

main ()
  {
   int i [5] = { 1, 2, 3, 4, 5 }, *iptr = i;
   struct S { float f; char ch; } s = { 2.2, 'k' }, *sptr = &s;
   static double D (extended e), (*fptr) () = D, d;

   if ((iptr++ [2]) != 3)
       goto Fail;

   if (iptr != &i [1])
       goto Fail;

   if (i [4] != 5)
       goto Fail;

   d = (*fptr) (5.5);
   if (fabs(d - 11.0) > 0.00001)
       goto Fail;

   d = fptr (4.5);
   if (fabs(d - 9.0) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 7.4.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.4.1.1\n");
  }


/*****************************************************************************/

static double D (extended e)
  {
   return (e * 2.0);
  }
