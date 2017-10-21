/* Deviance Test 4.6.2.1:  Ensure non-constant floating-point initializers */
/*                         for static and extern variables is detected     */

static float f0 = 1.0;
static float f1 = f0 * 2.0;
static double d1 = f0 + f1;
static extended e1 = f0 / 4.6;

float f2 = (float) e1;
double d2 = f0--;
extended e2 = f0 - f1;

main ()
  {
   float f00 = 5.6 * f0;
   static float f3 = f00;
   static double d3 = 3.5 / f3;
   static extended e3 = f00;

   extern float f4 = 8.1;          /* extern + initializers are not allowed */
   extern double d4 = f0;
   extern extended e4 = (extended) 5.0;

   printf ("Failed Deviance Test 4.6.2.1\n");
  }
