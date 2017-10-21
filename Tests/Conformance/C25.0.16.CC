/* Conformance Test 25.0.16:  Verification of code generation for ROL instr */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   ROL     A
               ROL     DP
               ROL     DP,X
               ROL     ABS
               ROL     ABS,X
               dcb     0
       Data:   dcb     0x2A
               dcb     0x26
               dcb     0x02
               dcb     0x36
               dcb     0x02
               dcb     0x2E
               dcb     0x00
               dcb     0x08
               dcb     0x3E
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
   printf ("Passed Conformance Test 25.0.16\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.16\n");
  }
