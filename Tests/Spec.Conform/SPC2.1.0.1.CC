/* Special Conformance Test 2.1.0.1:  Verification of character set */

#include <stdio.h>

main ()
  {
   int c;

   /* Read chars from keyboard; echo to a device.  Tester must   */
   /* check correct output of characters.  The test should be    */
   /* repeated 3 times, with output going to console, to printer */
   /* and to a file.                                             */
   while ((c = getchar ()) != EOF)
       putchar (c);
   }
