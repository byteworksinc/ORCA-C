/* Conformance Test 7.5.1.4:  Verification of type casting: int to long */

#include <stdio.h>

main ()
  {
   signed char  ch = 0x87;
   int   i  = -32767;
   short sh = -12345;
   long  L [6];

   unsigned char  uch = 0x95;
   unsigned int   ui  = 0xabcd;
   unsigned short ush = 0x8765;
   unsigned long  uL [6];


   /* Test conversion from shorter integer to long. */

   L [0] = (long) ush;
   L [1] = (long) ui;
   L [2] = (long) uch;
   L [3] = (long) sh;
   L [4] = (long) i;
   L [5] = (long) ch;

   if ((L [0] != 0x8765) || (L [1] != 0xaBcD) || (L [2] != 149) ||
       (L [3] != -12345) || (L [4] != -32767) || (L [5] != -121))
       goto Fail;


   /* Test conversion from shorter integer to unsigned long. */

   uL [0] = (unsigned long) ush;
   uL [1] = (unsigned long) ui;
   uL [2] = (unsigned long) uch;
   uL [3] = (unsigned long) sh;
   uL [4] = (unsigned long) i;
   uL [5] = (unsigned long) ch;

   if ((uL [0] != 0x8765) || (uL [1] != 0xaBcD) || (uL [2] != 0x95) ||
       (uL [3] != 0xFFFFcfc7) || (uL [4] != 0xffff8001) ||
       (uL [5] != 0xffffff87))
       goto Fail;


   printf ("Passed Conformance Test 7.5.1.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.1.4\n");
  }
