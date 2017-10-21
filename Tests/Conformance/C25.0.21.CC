/* Conformance Test 25.0.21:  Verification of code generation for STX, STY */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   STX     DP
               STX     DP,Y
               STX     ABS
               STY     DP
               STY     DP,X
               STY     ABS
       Data:   dcb     0x86
               dcb     0x02
               dcb     0x96
               dcb     0x02
               dcb     0x8E
               dcb     0x00
               dcb     0x08
               dcb     0x84
               dcb     0x02
               dcb     0x94
               dcb     0x02
               dcb     0x8C
               dcb     0x00
               dcb     0x08
       Test:   ldx     #12
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
   printf ("Passed Conformance Test 25.0.21\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.21\n");
  }
