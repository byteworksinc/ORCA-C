/* Conformance Test 2.7.2.1:  Test single-precision floating-point constants */

#include <math.h>

main ()
  {
   float  a;

   /* Test maximum and minimum single-precision floating-point values, using */
   /* all valid syntactic constructs.                                        */
   a = 1e+38;
   if (fabs(a - 1.E38) > 1e32)
       goto Fail;

   a = .1e-37;
   if (fabs(a - 0.1e-37) > 1e-42)
       goto Fail;

   /* Test other miscellaneous values. */
   a = 32767.F;
   if (fabs(a - 32767.000E+00000) > 0.01)
       goto Fail;

   a = 123.4567;
   if (fabs(a - 1.234567E+02) > 0.001)
       goto Fail;

   a = 00000000;
   if (a != 0)
       goto Fail;

   a = .456789;
   if (fabs(a - 456789E-6) > 0.00001)
       goto Fail;

   /* Test negative values. */
   a = -1e+38;
   if (fabs(a - (-1.E38)) > 1e33)
       goto Fail;

   a = -.1e-37;
   if (fabs(a - (-1.0e-38)) > 1e-42)
       goto Fail;

   /* Test other miscellaneous values. */
   a = -32768.f;
   if (fabs(a - (-32768.000E+00000)) > 0.01)
       goto Fail;

   a = -123.4567;
   if (fabs(a - (-1.234567E+02)) > 0.001)
       goto Fail;

   a = -.456789;
   if (fabs(a - (-456789E-6)) > 0.00001)
       goto Fail;

   /* Test floating-point constant with many characters in a digit string */
   a = \
000000000000000000000000000000000000000000000000000000000000000000000000000007.0
;

   if (fabs(a - 7.0) > 0.00001)
       goto Fail;

   printf ("Passed Conformance Test 2.7.2.1\n");
   return;

Fail:
   printf("Failed Conformance Test 2.7.2.1\n");
  }
