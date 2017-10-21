/* Conformance Test 7.5.9.1:  Verification of predecrement operator */

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

   comp     c = 4294967295ul;
   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;

   --i; --L; --ch; --ui; --ul; --uch; --c; --f; --d; --e;
   if ((i != 4) || (L != 32776) || (ch != 'x') || (ui != 65533) ||
       (ul != 0x7fFFffFE) || (uch != 0x7f) || (c != 4294967294ul) ||
       (fabs(f - 2.5) > 0.00001) || (fabs(d - 86.65) > 0.00001) ||
       (fabs(e - 91.33) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.5.9.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.9.1\n");
  }
