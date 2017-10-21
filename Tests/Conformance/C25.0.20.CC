/* Conformance Test 25.0.20: Verification of code generation for instructions */
/*                           whose only addressing mode is implied            */

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:   CLC
               CLD
               CLI
               CLV
               DEX
               DEY
               INX
               INY
               NOP
               PHA
               PHP
               PLA
               PLP
               RTI
               RTS
               SEC
               SED
               SEI
               TAX
               TAY
               TSX
               TXA
               TXS
               TYA
               PHX
               PHY
               PLX
               PLY
               PHB
               PHD
               PHK
               PLB
               PLD
               RTL
               STP
               TCD
               TCS
               TDC
               TSC
               TXY
               TYX
               WAI
               XCE
               XBA
       Data:   dcb     0x18
               dcb     0xD8
               dcb     0x58
               dcb     0xB8
               dcb     0xCA
               dcb     0x88
               dcb     0xE8
               dcb     0xC8
               dcb     0xEA
               dcb     0x48
               dcb     0x08
               dcb     0x68
               dcb     0x28
               dcb     0x40
               dcb     0x60
               dcb     0x38
               dcb     0xF8
               dcb     0x78
               dcb     0xAA
               dcb     0xA8
               dcb     0xBA
               dcb     0x8A
               dcb     0x9A
               dcb     0x98
               dcb     0xDA
               dcb     0x5A
               dcb     0xFA
               dcb     0x7A
               dcb     0x8B
               dcb     0x0B
               dcb     0x4B
               dcb     0xAB
               dcb     0x2B
               dcb     0x6B
               dcb     0xDB
               dcb     0x5B
               dcb     0x1B
               dcb     0x7B
               dcb     0x3B
               dcb     0x9B
               dcb     0xBB
               dcb     0xCB
               dcb     0xFB
               dcb     0xEB
       Test:   ldx     #42
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
   printf ("Passed Conformance Test 25.0.20\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.20\n");
  }
