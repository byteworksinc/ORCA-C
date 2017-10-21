/* Conformance Test 19.5.0.1:  Verification of frexp, ldexp, modf functions */

#include <math.h>

main ()
  {
   double d1, d2;
   int    i;


   d1 = frexp (4.8, &i);
   if ((fabs(d1 - .60) > 0.00001) || (i != 3))
       goto Fail;

   d1 = frexp (0, &i);
   if ((fabs(d1) > 0.00001) || (i != 0))
       goto Fail;

   d1 = ldexp (3.2, 4);
   if (fabs(d1 - 51.2) > 0.00001)
       goto Fail;

   d1 = modf (-14.654, &d2);
   if ((fabs(d1 - (-0.654)) > 0.00001) || (d2 != -14.0))
       goto Fail;


   printf ("Passed Conformance Test 19.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.5.0.1\n");
  }
