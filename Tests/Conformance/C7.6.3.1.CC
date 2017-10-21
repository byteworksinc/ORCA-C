/* Conformance Test 7.6.3.1:  Verification of shift operators */

#include <stdio.h>

main ()
  {
   signed char  ch = 0X57;
   int   i  = 0xabcd;
   short sh = 0x3214;
   long  L  = 0xfedcab65;

   unsigned char  uch = 0x83;
   unsigned int   ui  = 0xcbcb;
   unsigned short ush = 0x1234;
   unsigned long  uL  = 0x98765432;


   /* Shift each integer left and check expected result. */

   ch  =  ch  <<  1;
   i   =  i   <<  2;
   sh  =  sh  <<  3;
   L   =  L   <<  4;
   uch =  uch <<  6;
   ui  =  ui  <<  7;
   ush =  ush <<  8;
   uL  =  uL  <<  9;

   if ((ch != -82) || (i != -20684) || (sh != -28512) || (L != 0xedCAb650) ||
       (uch != 0xc0) || (ui != 0xe580) || (ush != 0x3400)
       || (uL != 0xeca86400))
       goto Fail;


   /* Shift each integer right and check expected result. */

   ch  =  ch  >>  2;
   i   =  i   >>  3;
   sh  =  sh  >>  4;
   L   =  L   >>  5;
   uch =  uch >>  7;
   ui  =  ui  >>  8;
   ush =  ush >>  9;
   uL  =  uL  >>  10;

   if ((ch != 0xFFEB) || (i != 0xF5e6) || (sh != 0xF90a) || (L != 0xff6e55b2) ||
       (uch != 1) || (ui != 0xe5) || (ush != 0x1A)
       || (uL != 0x3B2A19))
       goto Fail;

   printf ("Passed Conformance Test 7.6.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.3.1\n");
  }
