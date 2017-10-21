/* Conformance Test 25.0.6:  Verification of code generation for SBC instruct */

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
       Code:   SBC     #0xF
               SBC     DP
               SBC     DP,X
               SBC     ABS
               SBC     ABS,X
               SBC     ABS,Y
               SBC     (DP),Y
               SBC     (DP,X)
               SBC     (DP)
               SBC     DP,S
               SBC     (DP,S),Y
               SBC     LONG
               SBC     LONG,X
               SBC     [DP]
               SBC     [DP],Y
       Data:   dcb     0xE9
               dcb     0x0F
               dcb     0x00
               dcb     0xE5
               dcb     0x02
               dcb     0xF5
               dcb     0x02
               dcb     0xED
               dcb     0x00
               dcb     0x08
               dcb     0xFD
               dcb     0x00
               dcb     0x08
               dcb     0xF9
               dcb     0x00
               dcb     0x08
               dcb     0xF1
               dcb     0x02
               dcb     0xE1
               dcb     0x02
               dcb     0xF2
               dcb     0x02
               dcb     0xE3
               dcb     0x02
               dcb     0xF3
               dcb     0x02
               dcb     0xEF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xFF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xE7
               dcb     0x02
               dcb     0xF7
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
   printf ("Passed Conformance Test 25.0.6\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.6\n");
  }
