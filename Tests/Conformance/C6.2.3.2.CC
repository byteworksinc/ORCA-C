/* Conformance Test 6.2.3.2:  Verification of type equivalence:  long types */

#include <stdio.h>

main ()
  {
   signed char  ch;
   int   i;
   short sh;
   long  L = 2147483647;

   unsigned char  uch;
   unsigned int   ui;
   unsigned short ush;
   unsigned long  uL;

   static long TestLong (unsigned long uL, unsigned short ush, unsigned int ui,
                         unsigned char uch, long L, short sh, int i,
                         signed char ch);

   static void TestCnv  (unsigned long uL, unsigned short ush, unsigned int ui,
                         unsigned char uch, long L, short sh, int i,
                         signed char ch);


   L = TestLong (L, L, L, L, L, L, L, L);
   if (L != -2139095296)
       goto Fail;

   TestCnv (L, L, L, L, L, L, L, L);

   printf ("Passed Conformance Test 6.2.3.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 6.2.3.2\n");
  }


/*****************************************************************************/

static long TestLong (unsigned long uL, unsigned short ush, unsigned int ui,
                      unsigned char uch, long L, short sh, int i,
                      signed char ch)
  {
   long LL;

   /* Ensure parameters have not been changed during usual conversions. */

   if ((uL != 0x7fFFffFF) || (ush != 0xffff) || (ui != 0xFFFF) ||
       (uch != 0xff) || (L != 2147483647) || (sh != -1) || (i != -1) ||
       (ch != -1))
       goto Fail;

   /* Compute integral expression and check expected result. */

   LL = (uL >> 8 ^ ush >> 8) - (L + ch * sh);
   if (LL != -2139095296)
       goto Fail;
   return LL;

Fail:
   printf ("Failure in TestLong function in Conformance Test 6.2.3.2\n");
   exit (-1);
  }


/*****************************************************************************/

static void TestCnv  (unsigned long uL, unsigned short ush, unsigned int ui,
                      unsigned char uch, long L, short sh, int i,
                      signed char ch)
  {
   if ((uL != 0x807FFF00) || (ush != 0xFF00) || (ui != 0xFF00) || (uch != 0) ||
       (L != -2139095296) || (sh != -256) || (i != -256) || (ch != 0))
       goto Fail;
   return;

Fail:
   printf ("Failure in TestCnv function in Conformance Test 6.2.3.2\n");
   exit (-1);
  }
