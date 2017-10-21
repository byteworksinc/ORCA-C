/* Conformance Test 6.2.3.3:  Verification of type equivalence:  long types */

#include <stdio.h>

main ()
  {
   signed char  ch;
   int   i;
   short sh;
   long  L;

   unsigned char  uch;
   unsigned int   ui;
   unsigned short ush;
   unsigned long  uL = 65535;

   static long TestULong (unsigned long uL, unsigned short ush, unsigned int ui,
                          unsigned char uch, long L, short sh, int i,
                          signed char ch);

   static void TestCnv  (unsigned long uL, unsigned short ush, unsigned int ui,
                         unsigned char uch, long L, short sh, int i,
                         signed char ch);


   uL = TestULong (uL, uL, uL, uL, uL, uL, uL, uL);
   if (uL != 0xffFf0000)
       goto Fail;

   TestCnv (uL, uL, uL, uL, uL, uL, uL, uL);

   printf ("Passed Conformance Test 6.2.3.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 6.2.3.3\n");
  }


/*****************************************************************************/

static long TestULong (unsigned long uL, unsigned short ush, unsigned int ui,
                      unsigned char uch, long L, short sh, int i,
                      signed char ch)
  {
   unsigned long UL;

   /* Ensure parameters have not been changed during usual conversions. */

   if ((uL != 0x0000ffFF) || (ush != 0xffff) || (ui != 0xFFFF) ||
       (uch != 0xff) || (L != 65535) || (sh != -1) || (i != -1) ||
       (ch != -1))
       goto Fail;

   /* Compute integral expression and check expected result. */

   UL = ((uL >> 8 ^ ush >> 8) - (L + ch * sh)) | 0x80000000;
   if (UL != 0xFFFF0000)
       goto Fail;
   return UL;

Fail:
   printf ("Failure in TestULong function in Conformance Test 6.2.3.3\n");
   exit (-1);
  }


/*****************************************************************************/

static void TestCnv  (unsigned long uL, unsigned short ush, unsigned int ui,
                      unsigned char uch, long L, short sh, int i,
                      signed char ch)
  {
   if ((uL != 0xFFFF0000) || (ush != 0) || (ui != 0) ||
       (uch != 0) || (L != -65536) || (sh != 0) || (i != 0) ||
       (ch != 0))
       goto Fail;
   return;

Fail:
   printf ("Failure in TestCnv function in Conformance Test 6.2.3.3\n");
   exit (-1);
  }
