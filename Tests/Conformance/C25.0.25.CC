/* Conformance Test 25.0.25:  Verification of code generation for upper and */
/*                            lower limits of all addressing modes          */

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
       Code:   ADC     0x0
               ADC     0xFF
               LDA     0x0,X
               LDA     0xFF,X
               LDX     0x0,Y
               LDX     0xFF,Y
               ROR     |0x0000
               ROR     0xFFFF
               ROL     |0x0000,X
               ROL     0xFFFF,X
               STA     |0x0000,Y
               STA     0xFFFF,Y
               JMP     (|0x0000)
               JMP     (0xFFFF)
               ORA     (0x0),Y
               ORA     (0xFF),Y
               CMP     (0x0,X)
               CMP     (0xFF,X)
               BEQ     LBL4
       LBL4:   BEQ     LBL4
               AND     (0x0)
               AND     (0xFF)
               JMP     (|0x0000,X)
               JMP     (0xFFFF,X)
               SBC     0x0,S
               SBC     0xFF,S
               ADC     (0x0,S),Y
               ADC     (0xFF,S),Y
               AND     >0x000000
               AND     0xFFFFFF
               CMP     >0x000000,X
               CMP     0xFFFFFF,X
               EOR     [0x0]
               EOR     [0xFF]
               LDA     [0x0],Y
               LDA     [0xFF],Y
               JMP     [|0x0]
               JMP     [0xFFFF]
               BRL     LBL5
       LBL5:   BRL     LBL5
       Data:   dcb     0x65
               dcb     0x00
               dcb     0x65
               dcb     0xFF
               dcb     0xB5
               dcb     0x00
               dcb     0xB5
               dcb     0xFF
               dcb     0xB6
               dcb     0x00
               dcb     0xB6
               dcb     0xFF
               dcb     0x6E
               dcb     0x00
               dcb     0x00
               dcb     0x6E
               dcb     0xFF
               dcb     0xFF
               dcb     0x3E
               dcb     0x00
               dcb     0x00
               dcb     0x3E
               dcb     0xFF
               dcb     0xFF
               dcb     0x99
               dcb     0x00
               dcb     0x00
               dcb     0x99
               dcb     0xFF
               dcb     0xFF
               dcb     0x6C
               dcb     0x00
               dcb     0x00
               dcb     0x6C
               dcb     0xFF
               dcb     0xFF
               dcb     0x11
               dcb     0x00
               dcb     0x11
               dcb     0xFF
               dcb     0xC1
               dcb     0x00
               dcb     0xC1
               dcb     0xFF
               dcb     0xF0
               dcb     0x00
               dcb     0xF0
               dcb     0xFE
               dcb     0x32
               dcb     0x00
               dcb     0x32
               dcb     0xFF
               dcb     0x7C
               dcb     0x00
               dcb     0x00
               dcb     0x7C
               dcb     0xFF
               dcb     0xFF
               dcb     0xE3
               dcb     0x00
               dcb     0xE3
               dcb     0xFF
               dcb     0x73
               dcb     0x00
               dcb     0x73
               dcb     0xFF
               dcb     0x2F
               dcb     0x00
               dcb     0x00
               dcb     0x00
               dcb     0x2F
               dcb     0xFF
               dcb     0xFF
               dcb     0xFF
               dcb     0xDF
               dcb     0x00
               dcb     0x00
               dcb     0x00
               dcb     0xDF
               dcb     0xFF
               dcb     0xFF
               dcb     0xFF
               dcb     0x47
               dcb     0x00
               dcb     0x47
               dcb     0xFF
               dcb     0xB7
               dcb     0x00
               dcb     0xB7
               dcb     0xFF
               dcb     0xDC
               dcb     0x00
               dcb     0x00
               dcb     0xDC
               dcb     0xFF
               dcb     0xFF
               dcb     0x82
               dcb     0x00
               dcb     0x00
               dcb     0x82
               dcb     0xFD
               dcb     0xFF
       Test:   ldx     #100
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
   printf ("Passed Conformance Test 25.0.25\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.25\n");
  }
