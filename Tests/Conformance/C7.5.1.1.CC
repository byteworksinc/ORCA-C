/* Conformance Test 7.5.1.1:  Verification of type casting: int, char types */

#include <stdio.h>

main ()
  {
   signed char  ch = 'Z';
   int   i  = 80, j, k [7];
   short sh = 5;
   enum  E { a, b, c } e = b;
   unsigned char  uch = 'm';
   unsigned int   ui  = 0xff, n [7];
   unsigned short ush = 0x80;

   /* Conversion from integer to integer. */

   k [0] = (int) ch;
   k [1] = (int) i;
   k [2] = (int) sh;
   k [3] = (int) ui;
   k [4] = (int) ush;
   k [5] = (int) uch;
   k [6] = (int) e;

   if ((k [0] != 90) || (k [1] != 80) || (k [2] != 5) || (k [3] != 255) ||
       (k [4] != 128) || (k [5] != 109) || (k [6] != 1))
       goto Fail;


   /* Conversion from integer to unsigned integer. */

   n [0] = (unsigned int) ch;
   n [1] = (unsigned int) i;
   n [2] = (unsigned int) sh;
   n [3] = (unsigned int) ui;
   n [4] = (unsigned int) ush;
   n [5] = (unsigned int) uch;
   n [6] = (unsigned int) e;

   if ((n [4] != 128) || (n [3] != 255) || (n [2] != 5) || (n [6] != 1) ||
       (n [1] != 80) || (n [0] != 90) || (n [5] != 109))
       goto Fail;


   /* Test conversion from negative integer to unsigned integer. */

   ch = -125;
   i  = -32767;
   ui = 0xa123;
   n [0] = (unsigned int) ch;  n [1] = (unsigned int) i;  j = (int) ui;
   if ((n [0] != 0xFF83) || (n [1] != 0x8001) || (j != -24285))
       goto Fail;

   printf ("Passed Conformance Test 7.5.1.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 7.5.1.1\n");
  }
