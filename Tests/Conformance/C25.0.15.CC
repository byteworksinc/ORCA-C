/* Conformance Test 25.0.15:  Verification of code generation for LSR instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   LSR     A
               LSR     DP
               LSR     DP,X
               LSR     ABS
               LSR     ABS,X
               dcb     0
       Data:   dcb     0x4A
               dcb     0x46
               dcb     0x02
               dcb     0x56
               dcb     0x02
               dcb     0x4E
               dcb     0x00
               dcb     0x08
               dcb     0x5E
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
   printf ("Passed Conformance Test 25.0.15\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.15\n");
  }
