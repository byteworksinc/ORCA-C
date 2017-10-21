         mcopy exp.macros
****************************************************************
*
*  function lshr(x,y: longint): longint;
*
*  Inputs:
*        num1 - number to shift
*        num2 - # bits to shift by
*
*  Outputs:
*        A - result
*
****************************************************************
*
lshr     start

         subroutine (4:num1,4:num2),0

         lda   num2+2                   if num2 < 0 then
         bpl   lb2
         cmp   #$FFFF                     shift left
         bne   zero
         ldx   num2
         cpx   #-34
         blt   zero
lb1      asl   num1
         rol   num1+2
         inx
         bne   lb1
         bra   lb4
zero     stz   num1                       (result is zero)
         stz   num1+2
         bra   lb4
lb2      bne   zero                     else shift right
         ldx   num2
         beq   lb4
         cpx   #33
         bge   zero
lb3      lsr   num1+2
         ror   num1
         dex
         bne   lb3

lb4      lda   0                        fix stack and return
         sta   num2
         lda   2
         sta   num2+2

         return 4:num1
         end

****************************************************************
*
*  function udiv(x,y: longint): longint;
*
*  Inputs:
*        num1 - numerator
*        num2 - denominator
*
*  Outputs:
*        ans - result
*
****************************************************************
*
udiv     start
ans      equ   0                        answer
rem      equ   4                        remainder

         subroutine (4:num1,4:num2),8
;
;  Initialize
;
         stz   rem                      rem = 0
         stz   rem+2
         move4 num1,ans                 ans = num1
         lda   num2                     check for division by zero
         ora   num2+2
         beq   dv9

         lda   num2+2                   do 16 bit divides separately
         ora   ans+2
         beq   dv5
;
;  32 bit divide
;
         ldy   #32                      32 bits to go
dv3      asl   ans                      roll up the next number
         rol   ans+2
         rol   ans+4
         rol   ans+6
         sec                            subtract for this digit
         lda   ans+4
         sbc   num1
         tax
         lda   ans+6
         sbc   num2+2
         bcc   dv4                      branch if minus
         stx   ans+4                    turn the bit on
         sta   ans+6
         inc   ans
dv4      dey                            next bit
         bne   dv3
         bra   dv9                      go do the sign
;
;  16 bit divide
;
dv5      lda   #0                       initialize the remainder
         ldy   #16                      16 bits to go
dv6      asl   ans                      roll up the next number
         rol   a
         sec                            subtract the digit
         sbc   num2
         bcs   dv7
         adc   num2                     digit is 0
         dey
         bne   dv6
         bra   dv8
dv7      inc   ans                      digit is 1
         dey
         bne   dv6

dv8      sta   ans+4                    save the remainder
;
;  Return the result
;
dv9      return 4:ans                   move answer
         end

****************************************************************
*
*  function uge(x,y: longint): cboolean;
*
****************************************************************
*
uge      start
result   equ   0

         subroutine (4:x,4:y),4

         stz   result
         stz   result+2
         lda   x+2
         cmp   y+2
         bne   lb1
         lda   x
         cmp   y
lb1      blt   lb2
         dec   result
         dec   result+2

lb2      return 2:result
         end

****************************************************************
*
*  function ugt(x,y: longint): cboolean;
*
****************************************************************
*
ugt      start
result   equ   0

         subroutine (4:x,4:y),4

         stz   result
         stz   result+2
         lda   x+2
         cmp   y+2
         bne   lb1
         lda   x
         cmp   y
lb1      ble   lb2
         dec   result
         dec   result+2

lb2      return 2:result
         end

****************************************************************
*
*  function ule(x,y: longint): cboolean;
*
****************************************************************
*
ule      start
result   equ   0

         subroutine (4:x,4:y),4

         stz   result
         stz   result+2
         lda   x+2
         cmp   y+2
         bne   lb1
         lda   x
         cmp   y
lb1      bgt   lb2
         dec   result
         dec   result+2

lb2      return 2:result
         end

****************************************************************
*
*  function ult(x,y: longint): cboolean;
*
****************************************************************
*
ult      start
result   equ   0

         subroutine (4:x,4:y),4

         stz   result
         stz   result+2
         lda   x+2
         cmp   y+2
         bne   lb1
         lda   x
         cmp   y
lb1      bge   lb2
         dec   result
         dec   result+2

lb2      return 2:result
         end

****************************************************************
*
*  function umod(x,y: longint): longint;
*
*  Inputs:
*        num1 - numerator
*        num2 - denominator
*
*  Outputs:
*        ans+4 - result
*
****************************************************************
*
umod     start
ans      equ   0                        answer
rem      equ   4                        remainder

         subroutine (4:num1,4:num2),8
;
;  Initialize
;
         stz   rem                      rem = 0
         stz   rem+2
         move4 num1,ans                 ans = num1
         lda   num2                     check for division by zero
         ora   num2+2
         beq   dv9

         lda   num2+2                   do 16 bit divides separately
         ora   ans+2
         beq   dv5
;
;  32 bit divide
;
         ldy   #32                      32 bits to go
dv3      asl   ans                      roll up the next number
         rol   ans+2
         rol   ans+4
         rol   ans+6
         sec                            subtract for this digit
         lda   ans+4
         sbc   num1
         tax
         lda   ans+6
         sbc   num2+2
         bcc   dv4                      branch if minus
         stx   ans+4                    turn the bit on
         sta   ans+6
         inc   ans
dv4      dey                            next bit
         bne   dv3
         bra   dv9                      go do the sign
;
;  16 bit divide
;
dv5      lda   #0                       initialize the remainder
         ldy   #16                      16 bits to go
dv6      asl   ans                      roll up the next number
         rol   a
         sec                            subtract the digit
         sbc   num2
         bcs   dv7
         adc   num2                     digit is 0
         dey
         bne   dv6
         bra   dv8
dv7      inc   ans                      digit is 1
         dey
         bne   dv6

dv8      sta   ans+4                    save the remainder
;
;  Return the result
;
dv9      return 4:ans+4                 move answer
         end

****************************************************************
*
*  function umul(x,y: longint): longint;
*
*  Inputs:
*        num2,num1 - operands
*
*  Outputs:
*        ans - result
*
****************************************************************
*
umul     start
ans      equ   0                        answer

         subroutine (4:num1,4:num2),8
;
;  Initialize the sign and split on precision.
;
         stz   ans+4                    set up the multiplier
         stz   ans+6
         lda   num1
         sta   ans
         lda   num1+2
         sta   ans+2
         beq   ml3                      branch if the multiplier is 16 bit
;
;  Do a 32 bit by 32 bit multiply.
;
         ldy   #32                      32 bit multiply
         jsr   ml1
         brl   ml7

ml1      lda   ans                      SYSS1*SYSS1+2+SYSS1+2 -> SYSS1,SYSS1+2
         lsr   a
         bcc   ml2
         clc                            add multiplicand to the partial product
         lda   ans+4
         adc   num2
         sta   ans+4
         lda   ans+6
         adc   num2+2
         sta   ans+6
ml2      ror   ans+6                    shift the interem result
         ror   ans+4
         ror   ans+2
         ror   ans
         dey                            loop til done
         bne   ml1
         rts
;
;  Do and 16 bit by 32 bit multiply.
;
ml3      lda   num2+2                   branch if 16x16 is possible
         beq   ml4

         ldy   #16                      set up for 16 bits
         jsr   ml1                      do the multiply
         lda   ans+2                    move the answer
         sta   ans
         lda   ans+4
         sta   ans+2
         bra   ml7
;
;  Do a 16 bit by 16 bit multiply.
;
ml4      ldy   #16                      set the 16 bit counter
         ldx   ans                      move the low word
         stx   ans+2
ml5      lsr   ans+2                    test the bit
         bcc   ml6                      branch if the bit is off
         clc
         adc   num2
ml6      ror   a                        shift the answer
         ror   ans
         dey                            loop
         bne   ml5
         sta   ans+2                    save the high word
;
;  Return the result.
;
ml7      return 4:ans                   fix the stack
         end
