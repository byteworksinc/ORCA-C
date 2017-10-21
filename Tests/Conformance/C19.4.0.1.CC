/* Conformance Test 19.4.0.1:  Verification of exp, log, log10 functions */

#include <math.h>

main ()
  {
   double d1;

   d1 = exp (0);
   if (fabs(d1 - 1.0) > 0.00001)
       goto Fail;

   d1 = log (1.0);
   if (fabs(d1) > 0.00001)
       goto Fail;

   d1 = log10 (100.00);
   if (fabs(d1 - 2.0) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 19.4.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.4.0.1\n");
  }
