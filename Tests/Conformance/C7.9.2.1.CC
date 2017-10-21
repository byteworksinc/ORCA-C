/* Conformance Test 7.9.2.1:  Verification of multiplication assign operator */

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

   i   *=  -8;
   L   *=  3;
   ch  *=  2;
   c   *=  -9;
   f   *=  1.1;
   d   *=  5;
   e   *=  8;
   ui  *=  3;
   ul  *=  7;
   uch *=  2;

   if ((i != -40) || (L != 98331) || (ch != 'B') || (ui != 1959) ||
       (ul != 6265) || (uch != 16) || (c != -38646) ||
       (fabs(f - 3.85) > 0.00001) || (fabs(d - 438.25) > 0.00001) ||
       (fabs(e - 738.64) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.9.2.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.9.2.1\n");
  }
