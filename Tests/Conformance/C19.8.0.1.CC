/* Conformance Test 19.8.0.1: Verification of cos, sin, tan library functions */

#include <math.h>

main ()
  {
   double d1;

   d1 = cos (1.0);
   if (fabs(d1 - 0.540302305) > 0.00001)
       goto Fail;

   d1 = sin (1.0);
   if (fabs(d1 - 0.841470984) > 0.00001)
       goto Fail;

   d1 = tan (1.0);
   if (fabs(d1 - 1.557407725) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 19.8.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.8.0.1\n");
  }
