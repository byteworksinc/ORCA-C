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
CopyString start cc

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
Hash     start cc
hashSize equ   876                      # hash buckets - 1

disp     equ   0                        disp into hash table
length   equ   2                        length of string

         subroutine (4:sPtr),4

         lda   [sPtr]                   set the length of the string
         tax
         and   #$00FF
         sta   length
         ldy   #1                       start with char 1
         txa                            if 1st char is '~', start with char 6
         and   #$FF00
         cmp   #'~'*256
         bne   lb0
         ldy   #6

lb0      lda   #0                       initial value is 0
         bra   lb2                      while there are at least 2 chars left
lb1      asl   a                          rotate sum left one bit
         adc   [sPtr],Y                   add in next two bytes
         iny                              advance two chars
         iny
lb2      cpy   length
         blt   lb1
         bne   lb3                      if there is 1 char left then
         asl   a                          rotate sum left one bit
         sta   disp
         lda   [sPtr],Y
         and   #$00FF                     and out the high byte
         adc   disp                       add last byte to the sum
         sec
lb3      sbc   #hashSize+1              disp := (sum mod (hashSize+1)) << 2
         bcs   lb3
         adc   #hashSize+1
         asl   a
         asl   a
         sta   disp

         return 2:disp                  return disp
         end
