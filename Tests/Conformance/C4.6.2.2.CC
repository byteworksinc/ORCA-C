/* Conformance Test 4.6.2.1:  Verification of floating-point initializers */
/*                            Ensure non-initialized static variables are */
/*                            zeroed, and that curly braces can enclose   */
/*                            initialization expression.                  */

/* static and extern variables are restricted to constant expressions */

#include <math.h>

static float f1 = { -1.0E2 + (float) 2 * 5.0 / 20.0 - (double) 6 };
static double d1 = { 89.76E5 * 17.6 - (extended) 1 + (float) (-3) / 8.0 };
static extended e1;
static float f0;

float f2 = 5.1 * 7 - 88 / 4 + (extended) (double) (float) 8;
double d2 = { 10.0e20 / 0.04E-6 };
extended e2 = 15.5 - .5 * 3 + 1;

main ()
  {
   static double d0;

   /* auto and register variables can use any arithmetic expression */

   float f3 = {f1 * f2 / 1};
   double d3 = 8.1;
{  extended e3 = {e1 && e2 || d3 - f3};

   register float f4 = {f3};
   register double d4 = {f3 / 2.0};
{  register extended e4 = d4 + (extended) 8.88 - f1 / 5.0;

   if (fabs(f1 - (-105.5)) > 0.0001)
       goto Fail;

   if (fabs(f2 - 21.7) > 0.0001)
       goto Fail;

   if (fabs(f3 - (-2289.35)) > 0.01)
       goto Fail;

   if (fabs(f4 - (-2289.35)) > 0.01)
       goto Fail;

   if (fabs(d1 - 157977598.625) > 1.0000)
       goto Fail;

   if (fabs(d2 - 2.5e28) > 1e23)
       goto Fail;

   if (fabs(d3 - 8.1) > 0.00001)
       goto Fail;

   if (fabs(d4 - (-1144.675)) > 0.01)
       goto Fail;

   if (fabs(e1) > 0.00001)
       goto Fail;

   if (fabs(e2 - 15.0) > 0.0001)
       goto Fail;

   if (fabs(e3 - 1.0) > 0.00001)
       goto Fail;

   if (fabs(e4 - (-1114.695)) > 0.001)
       goto Fail;

   if (fabs(f0) > 0.00001)
       goto Fail;

   if (fabs(d0) > 0.00001)
       goto Fail;

   printf ("Passed Conformance Test 4.6.2.2\n");

   return;

Fail:
   printf ("Failed Conformance Test 4.6.2.2\n");
}}}
