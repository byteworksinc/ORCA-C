/* Conformance Test 25.0.12:  Verification of code generation for INC instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800
#define    LONG    0x123456

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   INC     A
               INC     DP
               INC     DP,X
               INC     ABS
               INC     ABS,X
               dcb     0
       Data:   dcb     0x1A
               dcb     0xE6
               dcb     0x02
               dcb     0xF6
               dcb     0x02
               dcb     0xEE
               dcb     0x00
               dcb     0x08
               dcb     0xFE
               dcb     0x00
               dcb     0x08
               dcb     0x00
       Test:   ldx     #10
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
   printf ("Passed Conformance Test 25.0.12\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.12\n");
  }
