/* Deviance Test 25.0.2:  Ensure branching to label + expression is detected */

#include <stdio.h>

main ()
  {
   asm
     {
               bra     Lbl1 + 0x8
       Lbl1:   nop
     }

   printf ("Failed Deviance Test 25.0.2\n");
  }
