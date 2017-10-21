/* Conformance Test 25.0.1:  Verification of code generation for ADC instruct */

#define    DP      0x02                    /* define 1, 2, & 3 byte addresses */
#define    ABS     0x800
#define    LONG    0x123456

#include   <stdio.h>

main ()
  {
   int i;
   int count = 0;

   asm
     {
               brl     Test
       Code:   ADC     #0xF
               ADC     DP
               ADC     DP,X
               ADC     ABS
               ADC     ABS,X
               ADC     ABS,Y
               ADC     (DP),Y
               ADC     (DP,X)
               ADC     (DP)
               ADC     DP,S
               ADC     (DP,S),Y
               ADC     LONG
               ADC     LONG,X
               ADC     [DP]
               ADC     [DP],Y
       End:
       Data:   dcb     0x69
               dcb     0x0F
               dcb     0x00
               dcb     0x65
               dcb     0x02
               dcb     0x75
               dcb     0x02
               dcb     0x6D
               dcb     0x00
               dcb     0x08
               dcb     0x7D
               dcb     0x00
               dcb     0x08
               dcb     0x79
               dcb     0x00
               dcb     0x08
               dcb     0x71
               dcb     0x02
               dcb     0x61
               dcb     0x02
               dcb     0x72
               dcb     0x02
               dcb     0x63
               dcb     0x02
               dcb     0x73
               dcb     0x02
               dcb     0x6F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x7F
               dcb     0x56
               dcb     0x34
               dcb     0x12
               dcb     0x67
               dcb     0x02
               dcb     0x77
               dcb     0x02
       Test:   ldx     #36
       Lbl1:   lda     Code,X
               cmp     Data,X
               bne     Err1
               inc     count
               dex
               dex
               bpl     Lbl1
               stz     i
               bra     Out
       Err1:   lda     #1
               sta     i
       Out:
     }

/* printf (" i = %d   count = %d\n", i, count); */

   if (i)
       goto Fail;
   printf ("Passed Conformance Test 25.0.1\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.1\n");
  }
