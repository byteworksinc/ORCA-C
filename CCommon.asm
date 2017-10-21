         mcopy ccommon.macros
****************************************************************
*
*  CopyString - copy a string
*
*  Inputs:
*        toPtr - location to copy to
*        fromPtr - location to copy from
*
****************************************************************
*
CopyString start

         subroutine (4:toPtr,4:fromPtr),0

         short I,M
         lda   [fromPtr]
         sta   [toPtr]
         tay
lb1      lda   [fromPtr],Y
         sta   [toPtr],Y
         dey
         bne   lb1
         long  I,M

         return
         end

****************************************************************
*
*  Hash - find hash displacement
*
*  Finds the displacement into an array of pointers using a
*  hash function.
*
*  Inputs:
*        sPtr - points to string to find hash for
*
*  Outputs:
*        Returns the disp into the hash table
*
****************************************************************
*
Hash     start
hashSize equ   876                      # hash buckets - 1

sum      equ   0                        hash
length   equ   2                        length of string

         subroutine (4:sPtr),4

         stz   sum                      default to bucket 0
         lda   [sPtr]                   set the length of the string
         and   #$00FF
         sta   length
         ldy   #1                       start with char 1
         lda   [sPtr]                   if 1st char is '~', start with char 6
         and   #$FF00
         cmp   #'~'*256
         bne   lb1
         ldy   #6

lb1      lda   [sPtr],Y                 get the value to add in
         and   #$3F3F
         cpy   length                   if there is only 1 char left then
         bne   lb2
         and   #$00FF                     and out the high byte
lb2      clc                            add it to the sum
         adc   sum
         sta   sum
         iny                            next char
         iny
         cpy   length
         ble   lb1
         mod2  sum,#hashSize+1          return disp
         asl   sum
         asl   sum

         return 2:sum
         end
