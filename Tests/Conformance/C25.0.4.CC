/* Conformance Test 25.0.4:  Verification of code generation for EOR instruct */

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
       Code:   EOR     #0xF
               EOR     DP
               EOR     DP,X
               EOR     ABS
               EOR     ABS,X
               EOR     ABS,Y
               EOR     (DP),Y
               EOR     (DP,X)
               EOR     (DP)
               EOR     DP,S
               EOR     (DP,S),Y
               EOR     LONG
               EOR     LONG,X
               EOR     [DP]
               EOR     [DP],Y
       Data:   dcb     0x49
               dcb     0x0F
               dcb     0x00
               dcb     0x45
               dcb     0x02
               dcb     0x55
               dcb     0x02
               dcb     0x4D
               dcb     0x00
               dcb     0x08
               dcb     0x5D
               dcb     0x00
               dcb     0x08
               dcb     0x59
               dcb     0x00
               dcb     0x08
               dcb     0x51
               dcb     0x02
               dcb     0x41
               dcb     0x02
               dcb     0x52
               dcb     0x02
               dcb     0x43
               dcb     0x02
               dcb     0x53
               dcb     0x02
               dcb     0x4F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x5F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x47
               dcb     0x02
               dcb     0x57
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
   printf ("Passed Conformance Test 25.0.4\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.4\n");
  }
