/* Conformance Test 7.5.8.1:  Verification of preincrement operator */

#include <stdio.h>
#include <math.h>

main ()
  {
   int  i  = 5;
   long L  = 32777;
   char ch = 'y';

   unsigned int  ui  = 65534;
   unsigned long ul  = 0x7FFFFFFF;
   unsigned char uch = 0x80;

   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;

   ++i; ++L; ++ch; ++ui; ++ul; ++uch; ++f; ++d; ++e;
   if ((i != 6) || (L != 32778) || (ch != 'z') || (ui != 65535) ||
       (ul != 0x80000000) || (uch != 0x81) ||
       (fabs(f - 4.5) > 0.00001) || (fabs(d - 88.65) > 0.00001) ||
       (fabs(e - 93.33) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.5.8.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.8.1\n");
  }
