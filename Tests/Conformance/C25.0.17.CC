/* Conformance Test 25.0.17:  Verification of code generation for ROR instr */

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
       Code:   ROR     A
               ROR     DP
               ROR     DP,X
               ROR     ABS
               ROR     ABS,X
               dcb     0
       Data:   dcb     0x6A
               dcb     0x66
               dcb     0x02
               dcb     0x76
               dcb     0x02
               dcb     0x6E
               dcb     0x00
               dcb     0x08
               dcb     0x7E
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
   printf ("Passed Conformance Test 25.0.17\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.17\n");
  }
