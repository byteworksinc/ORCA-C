/* Conformance Test 25.0.23: Verification of code generation for STZ instruct */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               bra     Test
       Code:   STZ     DP
               STZ     DP,X
               STZ     ABS
               STZ     ABS,X
       Data:   dcb     0x64
               dcb     0x02
               dcb     0x74
               dcb     0x02
               dcb     0x9C
               dcb     0x00
               dcb     0x08
               dcb     0x9E
               dcb     0x00
               dcb     0x08
       Test:   ldx     #8
       Lbl1:   lda     Code,X
               cmp     Data,X
               bne     Err1
               dex
               dex
               bpl     Lbl1
               bra     Out
       Err1:   inc     i
       Out:    nop
     }

   if (i)
       goto Fail;
   printf ("Passed Conformance Test 25.0.23\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.23\n");
  }
