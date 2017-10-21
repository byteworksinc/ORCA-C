/* Conformance Test 19.2.0.1:  Verification of div, ldiv library functions */

#include <stdlib.h>

main ()
  {
   div_t  d1;
   ldiv_t ld1;

   d1 = div (-9, 3);
   if ((d1.quot != -3) || (d1.rem != 0))
       goto Fail;

   ld1 = ldiv (-80, 7);
   if ((ld1.quot != -11) || (ld1.rem != -3))
       goto Fail;


   printf ("Passed Conformance Test 19.2.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 19.2.0.1\n");
  }
