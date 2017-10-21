/* Conformance Test 25.0.2:  Verification of code generation for AND instruct */

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
       Code:   AND     #0xF
               AND     DP
               AND     DP,X
               AND     ABS
               AND     ABS,X
               AND     ABS,Y
               AND     (DP),Y
               AND     (DP,X)
               AND     (DP)
               AND     DP,S
               AND     (DP,S),Y
               AND     LONG
               AND     LONG,X
               AND     [DP]
               AND     [DP],Y
       Data:   dcb     0x29
               dcb     0x0F
               dcb     0x00
               dcb     0x25
               dcb     0x02
               dcb     0x35
               dcb     0x02
               dcb     0x2D
               dcb     0x00
               dcb     0x08
               dcb     0x3D
               dcb     0x00
               dcb     0x08
               dcb     0x39
               dcb     0x00
               dcb     0x08
               dcb     0x31
               dcb     0x02
               dcb     0x21
               dcb     0x02
               dcb     0x32
               dcb     0x02
               dcb     0x23
               dcb     0x02
               dcb     0x33
               dcb     0x02
               dcb     0x2F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x3F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x27
               dcb     0x02
               dcb     0x37
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
   printf ("Passed Conformance Test 25.0.2\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.2\n");
  }
