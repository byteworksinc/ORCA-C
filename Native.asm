         mcopy native.macros
****************************************************************
*
*  Remove - remove an instruction from the peephole array
*
*  Inputs:
*        ns - index of element to remove
*
****************************************************************
*
Remove   start
elSize   equ   12                       size of an element
nPeepSize equ  128                      size of array
ns       equ   4                        array element

         lda   ns,S                     compute the source address
         cmp   #nPeepSize                (quit if nothing to move)
         bge   rtl
         asl   a
         adc   ns,S
         asl   a
         asl   a
         adc   #NPEEP
         tax
         sec                            compute the source address
         sbc   #elSize
         tay
         sec                            compute the move length
         sbc   #(nPeepSize-1)*elSize+NPEEP
         eor   #$FFFF
         mvn   NPEEP,NPEEP              move the array elements
rtl      dec   nNextSpot                nnextspot := nnextspot-1;
         lda   #1                       didone := true;
         sta   didOne
         lda   2,S                      fix stack and return
         sta   4,S
         pla
         sta   1,S
         rtl
         end

****************************************************************
*
*  Short - See if label lab is within short range of instruction n
*
*  Inputs:
*        n - instruction number
*        lab - label number
*
****************************************************************
*
Short    start
elSize   equ   12                       size of npeep array element
peep_opcode equ 0                       disp in nativeType of opcode
peep_mode equ  2                        disp in nativeType of mode
peep_operand equ 4                      disp in nativeType of operand
peep_name equ  6                        disp in nativeType of name
peep_flags equ 10                       disp in nativeType of flags

d_lab    equ   256                      label op code #

len      equ   0
i        equ   2

         subroutine (2:n,2:lab),4

         stz   len                      len := 0;
         lda   n                        i := n-1;
         dec   a                        while i > 0 do begin
         dec   a
         ldx   #elSize
         jsl   ~mul2
         tax
         bmi   lb3
lb1      lda   nPeep+peep_opcode,X        if npeep[i].opcode = d_lab then
         cmp   #d_lab
         bne   lb2
         lda   nPeep+peep_operand,X         if npeep[i].operand = lab then begin
         cmp   lab
         bne   lb2
         stz   fn                             Short := len <= 126;
         lda   len
         cmp   #127
         bge   lab1
         inc   fn
         bra   lab1                           goto 1;
lb2      anop                                 end;
         lda   nPeep+peep_opcode,X        len := len+size[npeep[i].mode];
         tay
         lda   size,Y
         and   #$00FF
         clc
         adc   len
         sta   len
         txa                              i := i-1;
         sec
         sbc   #elSize
         tax
         bpl   lb1                        end; {while}
lb3      stz   len                      len := 0;
         lda   n                        i := n+1;
         ldx   #elSize
         jsl   ~mul2
         tax
         lda   n
         inc   a
         sta   i
lb4      lda   i                        while i < nnextspot do begin
         cmp   nNextSpot
         bge   lb6
         lda   nPeep+peep_opcode,X        if npeep[i].opcode = d_lab then
         cmp   #d_lab
         bne   lb5
         lda   nPeep+peep_operand,X         if npeep[i].operand = lab then begin
         cmp   lab
         bne   lb5
         stz   fn                             Short := len < 128;
         lda   len
         cmp   #128
         bge   lab1
         inc   fn
         bra   lab1                           goto 1;
lb5      anop                                 end;
         lda   nPeep+peep_opcode,X        len := len+size[npeep[i].mode];
         tay
         lda   size,Y
         and   #$00FF
         clc
         adc   len
         sta   len
         inc   i                          i := i+1;
         txa
         clc
         adc   #elSize
         tax
         bra   lb4                        end; {while}
lb6      stz   fn                         Short := false;
lab1     anop                           1:end; {Short}
         return 2:fn

fn       ds    2                        function return value

size     dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'3,2,4,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'1,2,2,2,3,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,3,2,2,2,1,3,1,1,4,3,3,4'
         dc    i1'1,2,3,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'

         dc    i1'2,2,3,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'3,2,3,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'3,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'3,2,2,2,2,2,2,2,1,3,1,1,3,3,3,4'
         dc    i1'2,2,2,2,3,2,2,2,1,3,1,1,3,3,3,4'

         dc    i1'0,0,1,2,0,2,0,255'
         end
