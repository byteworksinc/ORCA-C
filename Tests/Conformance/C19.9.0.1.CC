/* Conformance Test 19.9.0.1: Verification of acos, asin, atan, atan2 library */
/*                             functions                                      */

#include <math.h>

main ()
  {
   double d1;

   d1 = acos (0.5);
   if (fabs(d1 - 1.047197551) > 0.00001)
       goto Fail;

   d1 = asin (0.5);
   if (fabs(d1 - 0.523598775) > 0.00001)
       goto Fail;

   d1 = atan (0.5);
   if (fabs(d1 - 0.463647609) > 0.00001)
       goto Fail;

   d1 = atan2 (2.0, 1.0);
   if (fabs(d1 - 1.107148718) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 19.9.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.9.0.1\n");
  }
