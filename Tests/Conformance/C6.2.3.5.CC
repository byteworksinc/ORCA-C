/* Conformance Test 6.2.3.5:  Verification of conversion from floating-point */
/*                            to integer types                               */

#include <stdio.h>
#include <math.h>

main ()
  {
   float    f;
   double   d;
   extended e;

   static float F (float f, double d, extended e, signed char ch, short sh,
                   int i, long L, unsigned char uch, unsigned int ui,
                   unsigned long ul);

   static double D (float f, double d, extended e, signed char ch, short sh,
                    int i, long L, unsigned char uch, unsigned int ui,
                    unsigned long ul);

   static extended E (float f, double d, extended e, signed char ch, short sh,
                      int i, long L, unsigned char uch, unsigned int ui,
                      unsigned long ul);

#if 0
   f = F (123.456, -876.443, 456.789, -127.54, 321.456, -456.77, -844.0, 4.0,
          6.0, 4.2e2);
   if (fabs(f - 18.224) > 0.00001)
       goto Fail;
#endif

   d = D (-1234.56, 4567.89977, 55555.66666, 4.5, -89.0, -4565.00, 333.88,
          42.567, 76.564, 987.98765);
   if (fabs(d - 28121.32696) > 0.00001)
       goto Fail;


   e = E (8.456e20, 3478.6e-100, 9876.43E+300, 0.00e-30, 00.00, -0.0, 0.577,
          00.33, 0.43212, 0.9876);
   if (fabs(e) > 0.00001)
       goto Fail;

   printf ("Passed Conformance Test 6.2.3.5\n");
   return;

Fail:
   printf ("Passed Conformance Test 6.2.3.5\n");
  }


/******************************************************************************/

static float F (float f, double d, extended e, signed char ch, short sh, int i,
                long L, unsigned char uch, unsigned int ui, unsigned long ul)
  {
   float f1;

   /* Check expected values of passed parameters. */

   if ((fabs(f - 123.456) > 0.00001) || (fabs(d - (-876.443)) > 0.00001) ||
       (fabs(e - 456.789) > 0.00001) || (ch != -127) ||
       (sh != 321) || (i != -456) || (L != -844) || (uch != 4) ||
       (ui != 6) || (ul != 420))
       goto Fail;

   /* Calculate a float value to return, and check expected result. */

   f1 = f + d - e + (sh / ch + i - L / uch * ui + ul);
   if (fabs(f1 - 18.224) > 0.0001)
       goto Fail;
   return f1;

Fail:
   printf ("Failure in F function in Conformance Test 6.2.3.5\n");
   exit (-1);
  }


/******************************************************************************/

static double D (float f, double d, extended e, signed char ch, short sh, int i,
                 long L, unsigned char uch, unsigned int ui, unsigned long ul)
  {
   double d1;

   /* Check expected values of passed parameters. */

   if ((fabs(f - (-1234.56)) > 0.00001) || (fabs(d - 4567.89977) > 0.00001) ||
       (fabs(e - 55555.66666) > 0.00001) ||
       (ch != 4) || (sh != -89) || (i != -4565) || (L != 333) ||
       (uch != 42) || (ui != 76) || (ul != 987))
       goto Fail;

   /* Calculate a double value to return, and check expected result. */

   d1 = e - d - f - (i / ch + ul / uch * sh - L * ui);
   if (fabs(d1 + 4294886577.673110) > 0.00001)
       goto Fail;
   return d1;

Fail:
   printf ("Failure in D function in Conformance Test 6.2.3.5\n");
   exit (-1);
  }


/******************************************************************************/

static extended E (float f, double d, extended e, signed char ch, short sh,
                   int i, long L, unsigned char uch, unsigned int ui,
                   unsigned long ul)
  {
   extended e1;

   e1 = F (8.456e20, 3478.6e-100, 9876.43E+300, 0.00e-30, 00.00, -0.0, 0.577,
          00.33, 0.43212, 0.9876);


   if ((fabs(f - 8.456e20) > 0.00001) || (fabs(d - 3478.6e-100) > 0.00001) ||
       (fabs(e - 9876.43e+300) > 0.00001) ||
       (ch != 0) || (sh != 0) || (i != 0) || (L != 0) || (uch != 0) ||
       (ui != 0) || (ul != 0))
       goto Fail;

   e1 = f / d * ch - ul;
   if (fabs(e1) > 0.00001)
       goto Fail;
   return (e1);

Fail:
   printf ("Failure in E function in Conformance Test 6.2.3.5\n");
   exit (-1);
  }
