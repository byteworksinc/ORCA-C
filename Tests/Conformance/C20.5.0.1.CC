/* Conformance Test 20.5.0.1:  Verification of difftime function */

#include <stddef.h>
#include <time.h>

main ()
  {
   double d1;
   time_t t1, t0;
   long   L;


   t0 = time (NULL);
   for (L = 0; L < 50000; L++)
       ;
   t1 = time (NULL);
   d1 = difftime (t1, t0);
   if (d1 < 0)
       goto Fail;

   printf ("Passed Conformance Test 20.5.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 20.5.0.1\n");
  }
