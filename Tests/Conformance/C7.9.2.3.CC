/* Conformance Test 7.9.2.3:  Verification of remainder assign operator */

#include <stdio.h>

main ()
  {
   char  ch = 87;
   int   i  = 32767;
   short sh = 12345;
   long  L  = 98765;

   unsigned char  uch = 130;
   unsigned int   ui  = 3579;
   unsigned short ush = 15234;
   unsigned long  uL  = 863112;


   /* Apply remainder operation to each integer and check expected result. */

   ch  %=  2;
   i   %=  3;
   sh  %=  4;
   L   %=  5;
   uch %=  7;
   ui  %=  8;
   ush %=  9;
   uL  %=  10;

   if ((ch != 1) || (i != 1) || (sh != 1) || (L != 0) ||
       (uch != 4) || (ui != 3) || (ush != 6) || (uL != 2))
       goto Fail;


   printf ("Passed Conformance Test 7.9.2.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.9.2.3\n");
  }
