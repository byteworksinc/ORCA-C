/* Deviance Test 25.0.1:  Ensure illegal use mini-assembler is detected */

#include <stdio.h>

main ()
  {
   int i, j;

   asm
     {
       9__A:   nop                         ; invalid label
               clcNoSuchOpcode             ; illegal op code
               lda     i * j - (j || i)    ; invalid expression

       dupLab: dcl     0x888               ; duplicate labels
       dupLab: dcb     9 + 2
     }

   printf ("Failed Deviance Test 25.0.1\n");
  }
