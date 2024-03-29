/* Conformance Test 25.0.18:  Verification of code generation for BIT instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800
#define    LONG    0x123456

#include   <stdio.h>

int main (void)
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   BIT     #0x1234
               BIT     DP
               BIT     DP,X
               BIT     ABS
               BIT     ABS,X
               dcb     0
       Data:   dcb     0x89
               dcb     0x34
               dcb     0x12
               dcb     0x24
               dcb     0x02
               dcb     0x34
               dcb     0x02
               dcb     0x2C
               dcb     0x00
               dcb     0x08
               dcb     0x3C
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
   printf ("Passed Conformance Test 25.0.18\n");
   return 0;

Fail:
   printf ("Failed Conformance Test 25.0.18\n");
  }
