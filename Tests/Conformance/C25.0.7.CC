/* Conformance Test 25.0.7:  Verification of code generation for STA instruct */

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
       Code:   STA     DP
               STA     DP,X
               STA     ABS
               STA     ABS,X
               STA     ABS,Y
               STA     (DP),Y
               STA     (DP,X)
               STA     (DP)
               STA     DP,S
               STA     (DP,S),Y
               STA     LONG
               STA     LONG,X
               STA     [DP]
               STA     [DP],Y
               dcb     0
       Data:   dcb     0x85
               dcb     0x02
               dcb     0x95
               dcb     0x02
               dcb     0x8D
               dcb     0x00
               dcb     0x08
               dcb     0x9D
               dcb     0x00
               dcb     0x08
               dcb     0x99
               dcb     0x00
               dcb     0x08
               dcb     0x91
               dcb     0x02
               dcb     0x81
               dcb     0x02
               dcb     0x92
               dcb     0x02
               dcb     0x83
               dcb     0x02
               dcb     0x93
               dcb     0x02
               dcb     0x8F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x9F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x87
               dcb     0x02
               dcb     0x97
               dcb     0x02
               dcb     0
       Test:   ldx     #34
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
   printf ("Passed Conformance Test 25.0.7\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.7\n");
  }
