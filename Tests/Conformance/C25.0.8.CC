/* Conformance Test 25.0.8:  Verification of code generation for ASL instruct */

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
       Code:   ASL     A
               ASL     DP
               ASL     DP,X
               ASL     ABS
               ASL     ABS,X
               dcb     0
       Data:   dcb     0x0A
               dcb     0x06
               dcb     0x02
               dcb     0x16
               dcb     0x02
               dcb     0x0E
               dcb     0x00
               dcb     0x08
               dcb     0x1E
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
   printf ("Passed Conformance Test 25.0.8\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.8\n");
  }
