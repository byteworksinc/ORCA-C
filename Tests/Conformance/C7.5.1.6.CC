/* Conformance Test 7.5.1.6:  Verification of conversion from integer to */
/*                            floating-point types using type casting    */

#include <stdio.h>

main ()
  {
   char   ch = 'D';
   short  sh = -32767;
   int    i  = 4456;
   long   L  = sh * 4;
   comp   c  = -(ch * i);

   unsigned char   uch = 0x80;
   unsigned int    ui  = 65535;
   unsigned long   ul  = ui << 2;

   float    f [8];
   double   d [8];
   extended e [8];


   /* Check conversion from integer to float. */

   f [0] = (float) ch;
   f [1] = (float) sh;
   f [2] = (float) i;
   f [3] = (float) L;
   f [4] = (float) uch;
   f [5] = (float) ui;
   f [6] = (float) ul;
   f [7] = (float) c;

   if ((f [0] != 68.0) || (f [1] != -32767.0) || (f [2] != 4456.0) ||
       (f [3] != -131068.0) || (f [4] != 128.0) || (f [5] != 65535.0) ||
       (f [6] != 262140.0) || (f [7] != -303008.0))
       goto Fail;


   /* Check conversion from double to other arithmetic types. */

   d [0] = (double) ch;
   d [1] = (double) sh;
   d [2] = (double) i;
   d [3] = (double) L;
   d [4] = (double) uch;
   d [5] = (double) ui;
   d [6] = (double) ul;
   d [7] = (double) c;

   if ((d [0] != 68.0) || (d [1] != -32767.0) || (d [2] != 4456.0) ||
       (d [3] != -131068.0) || (d [4] != 128.0) || (d [5] != 65535.0) ||
       (d [6] != 262140.0) || (d [7] != -303008.0))
       goto Fail;


   /* Check conversion from extended to other arithmetic types. */

   e [0] = (extended) ch;
   e [1] = (extended) sh;
   e [2] = (extended) i;
   e [3] = (extended) L;
   e [4] = (extended) uch;
   e [5] = (extended) ui;
   e [6] = (extended) ul;
   e [7] = (extended) c;

   if ((e [0] != 68.0) || (e [1] != -32767.0) || (e [2] != 4456.0) ||
       (e [3] != -131068.0) || (e [4] != 128.0) || (e [5] != 65535.0) ||
       (e [6] != 262140.0) || (e [7] != -303008.0))
       goto Fail;


   printf ("Passed Conformance Test 7.5.1.6\n");
   return;

Fail:
   printf ("Passed Conformance Test 7.5.1.6\n");
  }
