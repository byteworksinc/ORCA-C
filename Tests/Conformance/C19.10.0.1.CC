/* Conformance Test 19.10.0.1: Verification of cosh, sinh, tanh library */
/*                             functions                                */

#include <math.h>

main ()
  {
   double d1;

   d1 = sinh (0.0);
   if (d1 != 0.0)
       goto Fail;

   d1 = cosh (0.0);
   if (d1 != 1.0)
       goto Fail;

   d1 = tanh (0.0);
   if (d1 != 0.0)
       goto Fail;

   printf ("Passed Conformance Test 19.10.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.10.0.1\n");
  }
