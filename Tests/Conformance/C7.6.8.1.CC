/* Conformance Test 7.6.8.1:  Verification of bitwise OR operator */

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


   /* Perform bitwise OR operation on each integer; check expected result. */

   ch  =  ch  |  0x42;
   i   =  i   |  0x1234;
   sh  =  sh  |  0x4321;
   L   =  L   |  0xa1b2c3d4;
   uch =  uch |  0x77;
   ui  =  ui  |  0x7373;
   ush =  ush |  0xabcd;
   uL  =  uL  |  0x12345678;

   if ((ch != 0x57) || (i != 0xbbfd) || (sh != 0x7335) || (L != 0xfffeebf5) ||
       (uch != 0xf7) || (ui != 0xFBFB) || (ush != 0xBBFD)
       || (uL != 0x9A76567A))
       goto Fail;


   printf ("Passed Conformance Test 7.6.8.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.8.1\n");
  }
