/* Deviance Test 7.6.7.1:  Ensure illegal use of bitwise XOR is detected */

#include <stdio.h>

int main (void)
  {
   float f = 1.1;                    /* can only apply ^ operator to integers */
   double d = 2.2;
   extended e = 3.3;
   static float F (void);

   f = f ^ 1.0;
   d = d ^ 5;
   e = e ^ e;
   f = 88 ^ F ();

   printf ("Failed Deviance Test 7.6.7.1\n");
  }

static float F (void)
  {
   return 1.0;
  }
