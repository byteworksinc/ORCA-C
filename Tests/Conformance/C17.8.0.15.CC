/* Conformance Test 17.8.0.15:  Verification of fscanf, f e E g G format codes */

#include <stdio.h>
#include <math.h>

main ()
  {
   char  sstr [] = " 23 -3.8E20  -   e-   +25e-  00002.00008e000049.9 ";
   float f1, f2, f3, f4;
   double d1, d2, d3;
   int i;


   f1 = f2 = f3 = f4 = 1.0;
   d1 = d2 = d3 = 1.0;
   i  = sscanf (&sstr[0], "%*07f %e %E %lg %30lG %17lf%e", &f2, &f3, &d1, &d2,
                &d3, &f4);
   if (i != 6)
       goto Fail;
   if ((fabs(f1 - 1.0) > 0.00001) ||
       (fabs(f2 - (-3.8E20)) > 1e15) ||
       (fabs(f3) > 0.00001) ||
       (fabs(f4 - 9.9) > 0.00001) ||
       (fabs(d1) > 0.00001) ||
       (fabs(d2 - 25.0) > 0.00001) ||
       (fabs(d3 - 2.00008e4) > 0.00001))
       goto Fail;

   printf ("Passed Conformance Test 17.8.0.15\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.15\n");
   return;
  }
