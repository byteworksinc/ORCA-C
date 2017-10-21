/* Conformance Test 7.5.5.1:  Verification of bitwise negation operator */

#include <stdio.h>

main ()
  {
   char  ch = 0x87;
   int   i  = -32767;
   short sh = -12345;
   long  L  = 2147483647;

   unsigned char  uch = 0x95;
   unsigned int   ui  = 0xabcd;
   unsigned short ush = 0x8765;
   unsigned long  uL  = 0xffFFffaa;


   /* Invert each integer and check expected result. */

   ch = ~ch;
   i  = ~i;
   sh = ~sh;
   L  = ~L;
   uch = ~uch;
   ui  = ~ui;
   ush = ~ush;
   uL  = ~uL;

   if ((ch != 'x') || (i != 32766) || (sh != 12344) || (L != 0x80000000) ||
       (uch != 106) || (ui != 21554) ||
       (ush != 0x789a) || (uL != 85))
       goto Fail;


   printf ("Passed Conformance Test 7.5.5.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.5.1\n");
  }
