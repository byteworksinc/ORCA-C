/* Conformance Test 25.0.14:  Verification of code generation for LDY instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   LDY     #0x1234
               LDY     DP
               LDY     DP,X
               LDY     ABS
               LDY     ABS,X
               dcb     0
       Data:   dcb     0xA0
               dcb     0x34
               dcb     0x12
               dcb     0xA4
               dcb     0x02
               dcb     0xB4
               dcb     0x02
               dcb     0xAC
               dcb     0x00
               dcb     0x08
               dcb     0xBC
               dcb     0x00
               dcb     0x08
               dcb     0x00
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
   printf ("Passed Conformance Test 25.0.14\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.14\n");
  }
