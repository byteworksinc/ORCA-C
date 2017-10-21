/* Conformance Test 17.8.0.23:  Verification of scanf, f e E g G format codes */

#include <stdio.h>
#include <math.h>

main ()
  {
   float f1, f2, f3, f4;
   double d1, d2, d3;
   int i;
   FILE  *f;


   /* Redirect standard input from a file */

   f = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f == NULL)
       goto Fail1;
   fprintf(f, "23 -3.8E20  -   e-   +25e-  00002.00008e000049.9");
   fclose(f);

   stdin = freopen ("3/tmp", "r", stdin);
   if (stdin == NULL)
       goto Fail1;

   f1 = f2 = f3 = f4 = 1.0;
   d1 = d2 = d3 = 1.0;
   i  = scanf ("%*07f %e %E %lg %30lG %17lf%e", &f2, &f3, &d1, &d2,
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

   stdin = freopen (".CONSOLE", "r", stdin);   /* reset stdin and quit */
   if (stdin == NULL)
       goto Fail1;

   printf ("Passed Conformance Test 17.8.0.23\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.23\n");
   return;

Fail1:
   printf ("Unable to redirect stdin for Conformance Test 17.8.0.23\n");
   return;
  }
