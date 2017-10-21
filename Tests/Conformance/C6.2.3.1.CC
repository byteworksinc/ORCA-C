/* Conformance Test 5.11.0.1:  Verification of type equivalence:  int types */

#include <stdio.h>

main ()
  {
   char  ch = 'Z';
   int   i  = 80, k;
   short sh = 5;
   enum  E { a, b, c } e = b;
   unsigned char  uch = 'm';
   unsigned int   ui  = 0xff;
   unsigned short ush = 0x80;

   static void TestCnv (unsigned int ch, unsigned int i, int ui);
   static int TestInt (int ch, int i, int e, int sh, int ui, int ush, int uch);
   static unsigned int TestUnsigned (unsigned int ush, unsigned int ui,
                                     unsigned int uch, unsigned int e,
                                     unsigned int sh, unsigned int i,
                                     unsigned int ch);


   k = TestInt (ch, i, e, sh, ui, ush, uch);
   if (k != 0x703)
       goto Fail;

   k = TestUnsigned (ush, ui, uch, e, sh, i, ch);
   if (k != 0x3739)
       goto Fail;

   ch = 131;
   i  = -32767;
   ui = 0xa123;
   TestCnv (ch, i, ui);


   printf ("Passed Conformance Test 6.2.3.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 6.2.3.1\n");
  }


/*****************************************************************************/

static int TestInt (int ch, int i, int e, int sh, int ui, int ush, int uch)
  {
   int j;

   /* Ensure parameters have not been changed during usual conversions. */

   if ((ch != 90) || (i != 80) || (e != 1) || (sh != 5) || (ui != 255) ||
       (ush != 128) || (uch != 109))
       goto Fail;

   /* Compute integral expression and check expected result. */

   j = (ch + i * e - ui / sh << 4 | ush >> 1) - (uch);
   if (j != 1795)
       goto Fail;
   return j;

Fail:
   printf ("Failure in TestInt function in Conformance Test 5.11.0.1\n");
   exit (-1);
  }


/*****************************************************************************/

static unsigned int TestUnsigned (unsigned int ush, unsigned int ui,
                                  unsigned int uch, unsigned int e,
                                  unsigned int sh,  unsigned int i,
                                  unsigned int ch)
  {
   unsigned int j;

   /* Ensure parameters have not been changed during usual conversions. */

   if ((ush != 128) || (ui != 255) || (sh != 5) || (e != 1) || (i != 80) ||
       (ch != 90) || (uch != 109))
       goto Fail;

   /* Compute integral expression and check expected result. */

   j = ((ush ^ e) * uch) - (ch / sh >> 2) + (i & ui);
   if (j != 14137)
       goto Fail;
   return j;

Fail:
   printf ("Failure in TestUnsigned function in Conformance Test 6.2.3.1\n");
   exit (-1);
  }


/*****************************************************************************/

static void TestCnv (unsigned int ch, unsigned int i, int ui)
  {
   if ((ch != 0x0083) || (i != 0x8001) || (ui != -24285))
       goto Fail;
   return;
Fail:
   printf ("Failure in TestCnv function in Conformance Test 6.2.3.1\n");
   exit (-1);
  }
