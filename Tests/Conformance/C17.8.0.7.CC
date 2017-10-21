/* Conformance Test 17.8.0.7:  Verification of fscanf, e format codes */

#include <stdio.h>
#include <math.h>

main ()
  {
   FILE *f;
   float f1, f2, f3, f4;
   double d1, d2, d3;
   int i;


   f = fopen ("3/tmp", "wb+");            /* open input file for test */
   if (f == NULL)
       goto Fail1;
   fprintf(f, "23 -3.8E20  -   e-   +25e-  00002.00008e000049.9");
   rewind(f);

   f1 = f2 = f3 = f4 = 1.0;
   d1 = d2 = d3 = 1.0;
   i  = fscanf (f, "%*07f %e %E %lg %30lG %17lf%e", &f2, &f3, &d1, &d2,
                &d3, &f4);
   if (i != 6)
       goto Fail;
   if ((fabs(f1 - 1.0) > 0.00001) ||
       (fabs(f2 - (-3.8E20)) > 1e15) ||
       (fabs(f3) > 0.00001) ||
       (fabs(f4 - 9.9) > 0.00001) ||
       (fabs(d1) > 0.00001) ||
       (fabs(d2 - 25.0) > 0.00001) ||
       (fabs(d3 - 2.00008e4) > 0.0000001))
       goto Fail;

   i = fclose (f);                             /* close the file and quit */
   if (i == EOF)
       goto Fail2;

   printf ("Passed Conformance Test 17.8.0.7\n");
   return;

Fail:
   printf ("Failed Conformance Test 17.8.0.7\n");
   return;

Fail1:
   printf ("Unable to open input file for Conformance Test 17.8.0.7\n");
   return;

Fail2:
   printf ("Unable to close input file for Conformance Test 17.8.0.7\n");
   return;
  }
