/* Conformance Test 7.6.1.1:  Verification of multiplication operator */

#include <stdio.h>
#include <math.h>

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

   i   =  i   *  -8;
   L   =  3   *  L;
   ch  =  2   *  ch;
   c   =  -9  *  c;
   f   =  1.1 *  f;
   d   =  d   *  5;
   e   =  8   *  e;
   ui  =  ui  *  3;
   ul  =  7   *  ul;
   uch =  2   *  uch;

   if ((i != -40) || (L != 98331) || (ch != 'B') || (ui != 1959) ||
       (ul != 6265) || (uch != 16) || (c != -38646) ||
       (fabs(f - 3.85) > 0.00001) || (fabs(d - 438.25) > 0.00001) ||
       (fabs(e - 738.64) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.6.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.1.1\n");
  }
