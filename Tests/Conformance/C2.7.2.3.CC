/* Conformance Test 2.7.2.3:  Test extended-precision floating-pt constants  */

#include <math.h>

main ()
  {
   long double a;

   /* Test maximum and minimum extended-precision floating-point values, */
   /* using all valid syntactic constructs.                              */
   a = 1e+4932;
   if (fabs(a - 1.E4932) > 1e4927)
       goto Fail;

   a = .1e-4931;
   if (fabs(a - 1.0e-4932) > 1e-4928)
       goto Fail;

   /* Test other miscellaneous values. */
   a = 32767l;
   if (fabs(a - 32767.000E+00000) > 0.1)
       goto Fail;

   a = 1234567890.123456789;
   if (fabs(a - 1.234567890123456789E+09) > 1000.0)
       goto Fail;

   a = 0000000000000000000;
   if (fabs(a) > 0.0000000001)
       goto Fail;

   a = .456789;
   if (fabs(a - 456789E-6) > 0.0000000001)
       goto Fail;

   /* Test negative values. */
   a = -1e+4932;
   if (fabs(a - (-1.E4932)) > 1e4920)
       goto Fail;

   a = -.1e-4943;
   if (fabs(a - (-1.0e-4932)) > 1e-4935)
       goto Fail;

   /* Test other miscellaneous values. */
   a = -32768L;
   if (fabs(a - (-32768.000E+00000)) > 0.0000000001)
       goto Fail;

   a = -123.4567890123;
   if (fabs(a - (-1.234567890123E+02)) > 0.000000001)
       goto Fail;

   a = -.456789;
   if (fabs(a - (-456789E-6)) > 0.0000000001)
       goto Fail;

   printf ("Passed Conformance Test 2.7.2.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.2.3\n");
  }
