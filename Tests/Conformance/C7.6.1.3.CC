/* Conformance Test 7.6.1.3:  Verification of remainder operator */

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

   ch  =  ch  %  2;
   i   =  i   %  3;
   sh  =  sh  %  4;
   L   =  L   %  5;
   uch =  uch %  7;
   ui  =  ui  %  8;
   ush =  ush %  9;
   uL  =  uL  %  10;

   if ((ch != 1) || (i != 1) || (sh != 1) || (L != 0) ||
       (uch != 4) || (ui != 3) || (ush != 6) || (uL != 2))
       goto Fail;


   printf ("Passed Conformance Test 7.6.1.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.6.1.3\n");
  }
