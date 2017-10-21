/* Conformance Test 7.5.1.5:  Verification of conversion from floating-point */
/*                            to integer types using type casting            */

#include <stdio.h>

main ()
  {
   char   ch;
   short  sh;
   int    i;
   long   L;

   unsigned char   uch;
   unsigned int    ui;
   unsigned long   ul;

   float    f [10] = { 123.456, -876.443, 456.789, -127.54, 321.456,
                       -456.77, -844.0, 4.0, 6.0, 4.2e2 }, ff;
   double   d [10] = { -1234.56, 4567.89977, 55555.66666, 4.5, -89.0, -4565.00,
                       333.88, 42.567, 76.564, 987.98765 }, dd;
   extended e [10] = { 8.456e20, 3478.6e-100, 9876.43E+300, 0.00e-30, 00.00,
                       -0.0, 0.577, 00.33, 0.43212, 0.9876}, ee;


   /* Check conversion from float to other arithmetic types. */

   ff  = (float)    f [0];
   dd  = (double)   f [1];
   ee  = (extended) f [2];
   ch  = (char)     f [3];
   sh  = (short)    f [4];
   i   = (int)      f [5];
   L   = (long)     f [6];
   uch = (unsigned char) f [7];
   ui  = (unsigned int)  f [8];
   ul  = (unsigned long) f [9];

   if ((ff != 123.456) || (dd != -876.443) || (ee != 456.789) || (ch != -127) ||
       (sh != 321) || (i != -456) || (L != -844) || (uch != 4) ||
       (ui != 6) || (ul != 420))
       goto Fail;


   /* Check conversion from double to other arithmetic types. */

   ff  = (float)    d [0];
   dd  = (double)   d [1];
   ee  = (extended) d [2];
   ch  = (char)     d [3];
   sh  = (short)    d [4];
   i   = (int)      d [5];
   L   = (long)     d [6];
   uch = (unsigned char) d [7];
   ui  = (unsigned int)  d [8];
   ul  = (unsigned long) d [9];

   if ((ff != -1234.56) || (dd != 4567.89977) || (ee != 55555.66666) ||
       (ch != 4) || (sh != -89) || (i != -4565) || (L != 333) ||
       (uch != 42) || (ui != 76) || (ul != 987))
       goto Fail;


   /* Check conversion from extended to other arithmetic types. */

   ff  = (float)    e [0];
   dd  = (double)   e [1];
   ee  = (extended) e [2];
   ch  = (char)     e [3];
   sh  = (short)    e [4];
   i   = (int)      e [5];
   L   = (long)     e [6];
   uch = (unsigned char) e [7];
   ui  = (unsigned int)  e [8];
   ul  = (unsigned long) e [9];

   if ((ff != 8.456e20) || (dd != 3478.6e-100) || (ee != 9876.43e+300) ||
       (ch != 0) || (sh != 0) || (i != 0) || (L != 0) || (uch != 0) ||
       (ui != 0) || (ul != 0))
       goto Fail;


   printf ("Passed Conformance Test 7.5.1.5\n");
   return;

Fail:
   printf ("Passed Conformance Test 7.5.1.5\n");
  }
