/* Conformance Test 25.0.10:  Verification of code generation for CPX, CPY */

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
       Code:   CPX     #0x1234
               CPX     DP
               CPX     ABS
               CPY     #0x1234
               CPY     DP
               CPY     ABS
       Data:   dcb     0xE0
               dcb     0x34
               dcb     0x12
               dcb     0xE4
               dcb     0x02
               dcb     0xEC
               dcb     0x00
               dcb     0x08
               dcb     0xC0
               dcb     0x34
               dcb     0x12
               dcb     0xC4
               dcb     0x02
               dcb     0xCC
               dcb     0x00
               dcb     0x08
       Test:   ldx     #14
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
   printf ("Passed Conformance Test 25.0.10\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.10\n");
  }
