/* Conformance Test 25.0.22:  Verification of code generation for BRK, COP, */
/*                            MVN, MVP, PEA, PEI, PER, REP, SEP, TRB, and   */
/*                            TSB instructions.                             */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   BRK     0
               BRK     DP
               COP     DP
               MVN     DP,DP
               MVP     DP,DP
               PEA     ABS
               PEI     DP
               PER     Data
               REP     #0xF
               SEP     #0xF
               TRB     DP
               TRB     ABS
               TSB     DP
               TSB     ABS
       Data:   dcb     0x00
               dcb     0x00
               dcb     0x00
               dcb     0x02
               dcb     0x02
               dcb     0x02
               dcb     0x54
               dcb     0x00
               dcb     0x00
               dcb     0x44
               dcb     0x00
               dcb     0x00
               dcb     0xF4
               dcb     0x00
               dcb     0x08
               dcb     0xD4
               dcb     0x02
               dcb     0x62
               dcb     0x0E
               dcb     0x00
               dcb     0xC2
               dcb     0x0F
               dcb     0xE2
               dcb     0x0F
               dcb     0x14
               dcb     0x02
               dcb     0x1C
               dcb     0x00
               dcb     0x08
               dcb     0x04
               dcb     0x02
               dcb     0x0C
               dcb     0x00
               dcb     0x08
       Test:   ldx     #32
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
   printf ("Passed Conformance Test 25.0.22\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.22\n");
  }
