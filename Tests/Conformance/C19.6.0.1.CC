/* Conformance Test 19.6.0.1:  Verification of pow, sqrt library functions */

#include <math.h>

main ()
  {
   double d1;

   d1 = pow (-3.0, 3.0);
   if (d1 != -27.0)
       goto Fail;

   d1 = pow (555.33e+10, 0.0);
   if (d1 != 1.0)
       goto Fail;

   d1 = pow (0.0, 234.77);
   if (d1 != 0.0)
       goto Fail;

   d1 = sqrt (81.0);
   if (d1 != 9.0)
       goto Fail;


   printf ("Passed Conformance Test 19.6.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.6.0.1\n");
  }
