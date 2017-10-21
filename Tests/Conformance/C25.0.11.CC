/* Conformance Test 25.0.11: Verification of code generation for DEC instruct */

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
       Code:   DEC     A
               DEC     DP
               DEC     DP,X
               DEC     ABS
               DEC     ABS,X
               dcb     0
       Data:   dcb     0x3A
               dcb     0xC6
               dcb     0x02
               dcb     0xD6
               dcb     0x02
               dcb     0xCE
               dcb     0x00
               dcb     0x08
               dcb     0xDE
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
   printf ("Passed Conformance Test 25.0.11\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.11\n");
  }
