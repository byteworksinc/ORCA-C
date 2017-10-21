/* Conformance Test 25.0.13:  Verification of code generation for LDX instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   LDX     #0x1234
               LDX     DP
               LDX     DP,Y
               LDX     ABS
               LDX     ABS,Y
               dcb     0
       Data:   dcb     0xA2
               dcb     0x34
               dcb     0x12
               dcb     0xA6
               dcb     0x02
               dcb     0xB6
               dcb     0x02
               dcb     0xAE
               dcb     0x00
               dcb     0x08
               dcb     0xBE
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
   printf ("Passed Conformance Test 25.0.13\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.13\n");
  }
