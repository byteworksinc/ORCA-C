/* Conformance Test 25.0.5:  Verification of code generation for LDA instruct */

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
       Code:   LDA     #0xF
               LDA     DP
               LDA     DP,X
               LDA     ABS
               LDA     ABS,X
               LDA     ABS,Y
               LDA     (DP),Y
               LDA     (DP,X)
               LDA     (DP)
               LDA     DP,S
               LDA     (DP,S),Y
               LDA     LONG
               LDA     LONG,X
               LDA     [DP]
               LDA     [DP],Y
       Data:   dcb     0xA9
               dcb     0x0F
               dcb     0x00
               dcb     0xA5
               dcb     0x02
               dcb     0xB5
               dcb     0x02
               dcb     0xAD
               dcb     0x00
               dcb     0x08
               dcb     0xBD
               dcb     0x00
               dcb     0x08
               dcb     0xB9
               dcb     0x00
               dcb     0x08
               dcb     0xB1
               dcb     0x02
               dcb     0xA1
               dcb     0x02
               dcb     0xB2
               dcb     0x02
               dcb     0xA3
               dcb     0x02
               dcb     0xB3
               dcb     0x02
               dcb     0xAF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xBF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xA7
               dcb     0x02
               dcb     0xB7
               dcb     0x02
       Test:   ldx     #36
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
   printf ("Passed Conformance Test 25.0.5\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.5\n");
  }
