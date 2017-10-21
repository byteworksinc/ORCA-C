/* Conformance Test 7.6.2.1:  Verification of additive operators */

#include <stdio.h>
#include <math.h>

main ()
  {
   int  i  = 5;
   long L  = 32777;
   signed char ch = '!';

   unsigned int  ui  = 653;
   unsigned long ul  = 895;
   unsigned char uch = 0x8;

   comp     c = 4294;
   float    f = 3.5;
   double   d = 87.65;
   extended e = 92.33;

   i   =  i   +  -8;
   L   =  3   +  L;
   ch  =  2   +  ch;
   c   =  -9  +  c;
   f   =  1.1 +  f;
   d   =  d   +  5;
   e   =  8   +  e;
   ui  =  ui  +  3;
   ul  =  7   +  ul;
   uch =  2   +  uch;

   if ((i != -3) || (L != 32780) || (ch != '#') || (ui != 656) ||
       (ul != 902) || (uch != 10) || (c != 4285) ||
       (fabs(f - 4.6) > 0.00001) || (fabs(d - 92.65) > 0.00001) ||
       (fabs(e - 100.33) > 0.00001))
       goto Fail;


   i   =  i   -  (-2000);
   L   =  33  -  L;
   ch  =  -90 -  ch;
   c   =  0   -  c;
   f   =  6.8 -  f;
   d   =  d   -  72.1;
   e   =  3.2 -  e;
   ui  =  ui  -  8;
   ul  =  999 -  ul;
   uch =  uch -  uch;

   if ((i != 1997) || (L != -32747) || (ch != -125) || (ui != 648) ||
       (ul != 97) || (uch != 0) || (c != -4285) ||
       (fabs(f - 2.2) > 0.00001) || (fabs(d - 20.55) > 0.00001) ||
       (fabs(e + 97.13) > 0.00001))
       goto Fail;


   printf ("Passed Conformance Test 7.6.2.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.2.1\n");
  }
