/* Conformance Test 25.0.3:  Verification of code generation for CMP instruct */

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
       Code:   CMP     #0xF
               CMP     DP
               CMP     DP,X
               CMP     ABS
               CMP     ABS,X
               CMP     ABS,Y
               CMP     (DP),Y
               CMP     (DP,X)
               CMP     (DP)
               CMP     DP,S
               CMP     (DP,S),Y
               CMP     LONG
               CMP     LONG,X
               CMP     [DP]
               CMP     [DP],Y
       Data:   dcb     0xC9
               dcb     0x0F
               dcb     0x00
               dcb     0xC5
               dcb     0x02
               dcb     0xD5
               dcb     0x02
               dcb     0xCD
               dcb     0x00
               dcb     0x08
               dcb     0xDD
               dcb     0x00
               dcb     0x08
               dcb     0xD9
               dcb     0x00
               dcb     0x08
               dcb     0xD1
               dcb     0x02
               dcb     0xC1
               dcb     0x02
               dcb     0xD2
               dcb     0x02
               dcb     0xC3
               dcb     0x02
               dcb     0xD3
               dcb     0x02
               dcb     0xCF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xDF
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0xC7
               dcb     0x02
               dcb     0xD7
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
   printf ("Passed Conformance Test 25.0.3\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.3\n");
  }
