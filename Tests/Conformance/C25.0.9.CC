/* Conformance Test 25.0.9:  Verification of code generation for ORA instruct */

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
       Code:   ORA     #0x1234
               ORA     DP
               ORA     DP,X
               ORA     ABS
               ORA     ABS,X
               ORA     ABS,Y
               ORA     (DP),Y
               ORA     (DP,X)
               ORA     (DP)
               ORA     DP,S
               ORA     (DP,S),Y
               ORA     [DP]
               ORA     [DP],Y
               ORA     LONG
               ORA     LONG,X
       Data:   dcb     0x09
               dcb     0x34
               dcb     0x12
               dcb     0x05
               dcb     0x02
               dcb     0x15
               dcb     0x02
               dcb     0x0D
               dcb     0x00
               dcb     0x08
               dcb     0x1D
               dcb     0x00
               dcb     0x08
               dcb     0x19
               dcb     0x00
               dcb     0x08
               dcb     0x11
               dcb     0x02
               dcb     0x01
               dcb     0x02
               dcb     0x12
               dcb     0x02
               dcb     0x03
               dcb     0x02
               dcb     0x13
               dcb     0x02
               dcb     0x07
               dcb     0x02
               dcb     0x17
               dcb     0x02
               dcb     0x0F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x1F
               dcb     0x56
               dcb     0x34
               dcb     0x12
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
   printf ("Passed Conformance Test 25.0.9\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.9\n");
  }
