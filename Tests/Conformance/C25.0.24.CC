/* Conformance Test 25.0.24:  Verification of code generation for jump */
/*                            instructions                             */

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
       Code:   JMP     ABS
               JMP     (ABS)
               JMP     (ABS,X)
               JMP     LONG
               JMP     [ABS]
               JSR     ABS
               JSR     (ABS,X)
               JSL     LONG
       Data:   dcb     0x4C
               dcb     0x00
               dcb     0x08
               dcb     0x6C
               dcb     0x00
               dcb     0x08
               dcb     0x7C
               dcb     0x00
               dcb     0x08
               dcb     0x5C
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xDC
               dcb     0x00
               dcb     0x08
               dcb     0x20
               dcb     0x00
               dcb     0x08
               dcb     0xFC
               dcb     0x00
               dcb     0x08
               dcb     0x22
               dcb     0x56
               dcb     0x34
               dcb     0x12
       Test:   ldx     #24
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
   printf ("Passed Conformance Test 25.0.24\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.24\n");
  }
