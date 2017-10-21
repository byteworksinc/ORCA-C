/* Conformance Test 7.9.2.7:  Verification of bitwise XOR assign operator */

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


   /* Perform exclusive OR operation on each integer; check expected result. */

   ch  ^=  0x42;
   i   ^=  0x1234;
   sh  ^=  0x4321;
   L   ^=  0xa1b2c3d4;
   uch ^=  0x77;
   ui  ^=  0x7373;
   ush ^=  0xabcd;
   uL  ^=  0x12345678;

   if ((ch != 0x15) || (i != 0xB9F9) || (sh != 0x7135) || (L != 0x5f6e68B1) ||
       (uch != 0xf4) || (ui != 0xb8b8) || (ush != 0xB9F9)
       || (uL != 0x8a42024a))
       goto Fail;


   printf ("Passed Conformance Test 7.9.2.7\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.9.2.7\n");
  }
