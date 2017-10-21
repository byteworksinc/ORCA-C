/* Conformance Test 7.5.1.3:  Verification of type equivalence:  long types */

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
   unsigned long  ul = 65535, uLL;


   /* Test conversion from unsigned long to other integral types. */

   uLL = (unsigned long) ul;
   ush = (unsigned short) ul;
   ui  = (unsigned int) ul;
   uch = (unsigned char) ul;
   L   = (long) ul;
   sh  = (short) ul;
   i   = (int) ul;
   ch  = (signed char) ul;

   if ((uLL != 0x0000ffFF) || (ush != 0xffff) || (ui != 0xFFFF) ||
       (uch != 0xff) || (L != 65535) || (sh != -1) || (i != -1) ||
       (ch != -1))
       goto Fail;


   ul = 0xffF20000;

   uLL = (unsigned long) ul;
   ush = (unsigned short) ul;
   ui  = (unsigned int) ul;
   uch = (unsigned char) ul;
   L   = (long) ul;
   sh  = (short) ul;
   i   = (int) ul;
   ch  = (signed char) ul;

   if ((uLL != 0xFFF20000) || (ush != 0) || (ui != 0) || (uch != 0) ||
       (L != -917504) || (sh != 0) || (i != 0) || (ch != 0))
       goto Fail;

   printf ("Passed Conformance Test 7.5.1.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.1.3\n");
  }
