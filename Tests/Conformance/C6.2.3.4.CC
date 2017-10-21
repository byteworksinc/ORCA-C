/* Conformance Test 6.2.3.4:  Verification of type equivalence:  long types */

#include <stdio.h>

main ()
  {
   signed char  ch = 0x87;
   int   i  = -32767;
   short sh = -12345;
   long  L;

   unsigned char  uch = 0x95;
   unsigned int   ui  = 0xabcd;
   unsigned short ush = 0x8765;
   unsigned long  uL;

   static long TestLong (long ush, long ui, long uch, long sh, long i, long ch);

   static unsigned long TestULong (unsigned long ush, unsigned long ui,
                                   unsigned long uch, unsigned long sh,
                                   unsigned long i,   unsigned long ch);


   L = TestLong (ush, ui, uch, sh, i, ch);
   if (L != 3952611)
       goto Fail;

   uL = TestULong (ush, ui, uch, sh, i, ch);
   if (uL != 0xFFFE7BFA)
       goto Fail;


   printf ("Passed Conformance Test 6.2.3.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 6.2.3.4\n");
  }


/*****************************************************************************/

static long TestLong (long ush, long ui, long uch, long sh, long i, long ch)
  {
   long L;

   /* Ensure parameters have not been changed during usual conversions. */

   if ((ush != 0x8765) || (ui != 0xaBcD) || (uch != 149) || (sh != -12345) ||
       (i != -32767) || (ch != -121))
       goto Fail;

   /* Compute integral expression and check expected result. */

   L = i * ch - ush / ui + uch + sh;
   if (L != 3952611)
       goto Fail;
   return L;

Fail:
   printf ("Failure in TestLong function in Conformance Test 6.2.3.4\n");
   exit (-1);
  }


/*****************************************************************************/

static unsigned long TestULong  (unsigned long ush, unsigned long ui,
                                 unsigned long uch, unsigned long sh,
                                 unsigned long i,   unsigned long ch)
  {
   unsigned long ul;

   /* Check converted values passed to function. */

   if ((ush != 0x8765) || (ui != 0xaBcD) || (uch != 0x95) ||
       (sh != 0xFFFFcfc7) || (i != 0xffff8001) || (ch != 0xffffff87))
       goto Fail;

   /* Use values to compute expression, and then check expected result. */

   ul = ch - sh - ui - ush + i - uch;
   if (ul != 0xFFFE7BFA)
       goto Fail;
   return ul;

Fail:
   printf ("Failure in TestULong function in Conformance Test 6.2.3.4\n");
   exit (-1);
  }
