/* Conformance Test 25.0.19:  Verification of code generation for branch */
/*                            instructions                               */

#include   <stdio.h>

main ()
  {
   int i = 0;

   asm
     {
               brl     Test
       Code:
       D1:     BCC     D1
       D2:     BCC     D2
       D3:     BCS     D3
       D4:     BCS     D4
       D5:     BEQ     D5
       D6:     BMI     D6
       D7:     BNE     D7
       D8:     BPL     D8
       D9:     BVC     D9
       D10:    BVS     D10
       D11:    BRA     D11
       D12:    BRL     D12
               dcb     0
       Data:   dcb     0x90
               dcb     0xFE
               dcb     0x90
               dcb     0xFE
               dcb     0xB0
               dcb     0xFE
               dcb     0xB0
               dcb     0xFE
               dcb     0xF0
               dcb     0xFE
               dcb     0x30
               dcb     0xFE
               dcb     0xD0
               dcb     0xFE
               dcb     0x10
               dcb     0xFE
               dcb     0x50
               dcb     0xFE
               dcb     0x70
               dcb     0xFE
               dcb     0x80
               dcb     0xFE
               dcb     0x82
               dcb     0xFD
               dcb     0xFF
               dcb     0x00
       Test:   ldx     #24
       Lbl1:   lda     Code,X
               cmp     Data,X
               bne     Err1
               dex
               dex
               bpl     Lbl1
               bra     Out
       Err1:   inc     i
       Out:
     }

   if (i)
       goto Fail;
   printf ("Passed Conformance Test 25.0.19\n");
   return;

Fail:
   printf ("Failed Conformance Test 25.0.19\n");
  }
