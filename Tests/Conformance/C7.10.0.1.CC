/* Conformance Test 7.10.0.1:  Verification of comma operator */

#include <math.h>
#include <stdio.h>

main ()
  {
   int  i  = 5;
   long L  = 32777;
   char ch = '!';

   unsigned int  ui  = 653;
   unsigned long ul  = 895;
   unsigned char uch = 0x8;

   comp     c = 4294;
   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;

   i   =  (i++ * 2, i -= 2, 88);
   L   =  (ch *= 2, ch--, 3000);
   ch  =  ('a' || 'b', ch++);
   c   =  -9, 888, f * 3.3;
   f   =  1.1 +  f, f -= 57, f+=1.0;
   d   =  (L, uch, -f);
   e   =  8 + e, e -= 0.33, e / 2;
   ui  =  ui * 3, ui--, ui;
   ul  =  ul >>= 5, ul & 0x0, ul++;
   uch =  (2 + uch, 'Y');

   if ((i != 88) || (L != 3000) || (ch != 'A') || (ui != 1958) ||
       (ul != 28) || (uch != 'Y') || (fabs(c -(- 9.0)) > 0.00001) ||
       (fabs(f - (-51.4)) > 0.00001) || (fabs(d - 51.40) > 0.00001) ||
       (fabs(e - 100.000) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.10.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.10.0.1\n");
  }
