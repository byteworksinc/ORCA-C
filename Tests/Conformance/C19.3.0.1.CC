/* Conformance Test 19.3.0.1:  Verification of ceil, floor, fmod functions */

#include <math.h>

int printf(const char *, ...);

int main (void)
  {
   double d1;

   d1 = ceil (-3.26);
   if (fabs(d1 - (-3.0)) > 0.00001)
       goto Fail;

   d1 = floor (-3.26);
   if (fabs(d1 - (-4.0)) > 0.00001)
       goto Fail;

   d1 = fmod (-4.4, 2.0);
   if (fabs(d1 - (-0.4)) > 0.00001)
       goto Fail;

   d1 = fmod (-4.4, 0.0);
   if (fabs(d1 - (-4.4)) > 0.00001)
       goto Fail;


   printf ("Passed Conformance Test 19.3.0.1\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 19.3.0.1\n");
  }
