/* Conformance Test 2.7.2.2:  Test double-precision floating-point constants */

#include <math.h>

main ()
  {
   double a;

   /* Test maximum and minimum double-precision floating-point values, using */
   /* all valid syntactic constructs.                                        */
   a = 1e+308;
   if (fabs(a - 1.E308) > 1e302)
       goto Fail;

   a = .1e-307;
   if (fabs(a - 1.0e-308) > 1e-302)
       goto Fail;

   /* Test other miscellaneous values. */
   a = 32767.f;
   if (fabs(a - 32767.000E+00000) > 0.1)
       goto Fail;

   a = 1234567.89012345;
   if (fabs(a - 1.23456789012345E+06) > 1.0)
       goto Fail;

   a = 000000000000000;
   if (fabs(a - 0) > 0.00001)
       goto Fail;

   a = .456789;
   if (fabs(a - 456789E-6) > 0.00001)
       goto Fail;

   /* Test negative values. */
   a = -1e+308;
   if (fabs(a - (-1.E308)) > 1e-302)
       goto Fail;

   a = -.1e-307;
   if (fabs(a - (-1.0e-308)) > 1e-302)
       goto Fail;

   /* Test other miscellaneous values. */
   a = -32768.F;
   if (fabs(a - (-32768.000E+00000)) > 0.1)
       goto Fail;

   a = -123.4567890123;
   if (fabs(a - (-1.234567E+02)) > 0.001)
       goto Fail;

   a = -.456789;
   if (fabs(a - (-456789E-6)) > 0.00001)
       goto Fail;

   printf ("Passed Conformance Test 2.7.2.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 2.7.2.2\n");
  }
