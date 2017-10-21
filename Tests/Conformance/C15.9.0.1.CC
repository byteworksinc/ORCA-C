/* Conformance Test 15.9.0.1:  Verification of atof, atoi, atol functions */

#include <stdlib.h>

main ()
  {
   double d1;
   int    i;
   long   L;


   d1 = atof ("3.5e-22");
   if (d1 != 3.5e-22)
       goto Fail;

   i = atoi ("-32765");
   if (i != -32765)
       goto Fail;

   L = atol ("100000");
   if (L != 100000)
       goto Fail;

   printf ("Passed Conformance Test 15.9.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 15.9.0.1\n");
  }
