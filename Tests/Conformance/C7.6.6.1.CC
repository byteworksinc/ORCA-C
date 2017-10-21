/* Conformance Test 7.6.6.1:  Verification of bitwise AND operator */

#include <stdio.h>

main ()
  {
   char  ch = 0X57;
   int   i  = 0xabcd;
   short sh = 0x3214;
   long  L  = 0xfedcab65;

   unsigned char  uch = 0x83;
   unsigned int   ui  = 0xcbcb;
   unsigned short ush = 0x1234;
   unsigned long  uL  = 0x98765432;


   /* Invert each integer and check expected result. */

   ch  =  ch  &  0x42;
   i   =  i   &  0x1234;
   sh  =  sh  &  0x4321;
   L   =  L   &  0xa1b2c3d4;
   uch =  uch &  0x77;
   ui  =  ui  &  0x7373;
   ush =  ush &  0xabcd;
   uL  =  uL  &  0x12345678;

   if ((ch != 0x42) || (i != 0x204) || (sh != 0x200) || (L != 0xA0908344) ||
       (uch != 3) || (ui != 0x4343) || (ush != 0x204) ||
       (uL != 0x10345430))
       goto Fail;


   printf ("Passed Conformance Test 7.6.6.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.6.1\n");
  }
