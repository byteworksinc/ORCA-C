/* Conformance Test 7.5.1.2:  Verification of type casting: long types */

#include <stdio.h>

main ()
  {
   signed char  ch;
   int   i;
   short sh;
   long  L = 2147483647, LL;

   unsigned char  uch;
   unsigned int   ui;
   unsigned short ush;
   unsigned long  uL;

   extern void TestCnv  (unsigned long uL, unsigned short ush, unsigned int ui,
                         unsigned char uch, long L, short sh, int i,
                         signed char ch);

   /* Test conversion from long to other integral types. */

   uL  = (unsigned long) L;
   ush = (unsigned short) L;
   ui  = (unsigned int) L;
   uch = (unsigned char) L;
   LL  = (long) L;
   sh  = (short) L;
   i   = (int) L;
   ch  = (signed char) L;

   if ((uL != 0x7fFFffFF) || (ush != 0xffff) || (ui != 0xFFFF) ||
       (uch != 0xff) || (LL != 2147483647) || (sh != -1) || (i != -1) ||
       (ch != -1))
       goto Fail;


   L = -2139095040;

   uL  = (unsigned long) L;
   ush = (unsigned short) L;
   ui  = (unsigned int) L;
   uch = (unsigned char) L;
   LL  = (long) L;
   sh  = (short) L;
   i   = (int) L;
   ch  = (signed char) L;

   if ((uL != 0x80800000) || (ush != 0) || (ui != 0) || (uch != 0) ||
       (LL != -2139095040) || (sh != 0) || (i != 0) || (ch != 0))
       goto Fail;


   printf ("Passed Conformance Test 7.5.1.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.1.2\n");
  }
