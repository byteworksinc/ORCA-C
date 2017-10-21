/* Deviance Test 7.5.4.1:  Ensure illegal use of bitwise negation is detected */

#include <stdio.h>

main ()
  {
   float f = 1.1;                    /* can only apply ~ operator to integers */
   double d = 2.2;
   extended e = 3.3;
   static float F (void);

   f = ~f;
   d = ~d;
   e = ~e;
   F = ~F ();

   printf ("Failed Deviance Test 7.5.4.1\n");
  }

static float F (void)
  {
   return 1.0;
  }
