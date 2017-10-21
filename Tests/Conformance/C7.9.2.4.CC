/* Conformance Test 7.9.2.4:  Verification of additive assign operators */

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


   i   +=  -8;
   L   +=  3;
   ch  +=  2;
   c   +=  -9;
   f   +=  1.1;
   d   +=  5;
   e   +=  8;
   ui  +=  3;
   ul  +=  7;
   uch +=  2;

   if ((i != -3) || (L != 32780) || (ch != '#') || (ui != 656) ||
       (ul != 902) || (uch != 10) || (c != 4285) ||
       (fabs(f - 4.6) > 0.00001) || (fabs(d - 92.65) > 0.00001) ||
       (fabs(e - 100.33) > 0.00001))
       goto Fail;


   i   -=  (-2000);
   L   -=  33;
   ch  -=  -90;
   c   -=  0;
   f   -=  6.8;
   d   -=  72.1;
   e   -=  3.2;
   ui  -=  8;
   ul  -=  900;
   uch -=  uch;

   if ((i != 1997) || (L != 32747) || (ch != 125) || (ui != 648) ||
       (ul != 2) || (uch != 0) || (c != 4285) ||
       (fabs(f - (-2.2)) > 0.00001) || (fabs(d - 20.55) > 0.00001) ||
       (fabs(e - 97.13) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.9.2.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.9.2.4\n");
  }
