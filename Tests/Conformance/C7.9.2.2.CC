/* Conformance Test 7.9.2.2:  Verification of division assign operator */

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

   i   /=  -1;
   L   /=  L;
   ch  /=  3;
   c   /=  -9;
   f   /=  f;
   d   /=  5;
   e   /=  1.0;
   ui  /=  3;
   ul  /=  5;
   uch /=  2;

   if ((i != -5) || (L != 1) || (ch != '\v') || (ui != 217) ||
       (ul != 179) || (uch != 4) || (c != -477) ||
       (fabs(f - 1.0) > 0.00001) || (fabs(d - 17.53) > 0.00001) ||
       (fabs(e - 92.33) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.9.2.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.9.2.2\n");
  }
