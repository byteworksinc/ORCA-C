/* Conformance Test 7.6.1.2:  Verification of division operator */

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

   i   =  i   /  -1;
   L   =  L   /  L;
   ch  =  ch  /  3;
   c   =  c   /  -9;
   f   =  f   /  f;
   d   =  d   /  5;
   e   =  e   /  1.0;
   ui  =  ui  /  3;
   ul  =  ul  /  5;
   uch =  2   /  uch;

   if ((i != -5) || (L != 1) || (ch != '\v') || (ui != 217) ||
       (ul != 179) || (uch != 0) || (c != -477) ||
       (f != 1.0) || (d != 17.53) || (e != 92.33))
       goto Fail;


   printf ("Passed Conformance Test 7.6.1.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.1.2\n");
  }
