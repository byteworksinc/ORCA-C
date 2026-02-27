         mcopy symbol.macros
****************************************************************
*
*  ClearTable - set the symbol table to zeros
*
*  Inputs:
*        table - symbol table address
*
****************************************************************
*
ClearTable private cc
hashSize2 equ  1753                     # hash buckets * 2 - 1
sizeofBuckets equ 4*(hashSize2+1)       sizeof(symbolTable.buckets)

         subroutine (4:table),0

         ldy   #sizeofBuckets-2
         lda   #0
lb1      sta   [table],Y
         dey
         dey
         bpl   lb1

         return
         end

****************************************************************
*
*  function Ge65(a,b: i65): boolean;
*
****************************************************************
*
Ge65     start exp
result   equ   0

         subroutine (4:a,4:b),2

         stz   result
         ldy   #8
         lda   [a],y
         eor   [b],y
         bpl   lb0
         lda   [b],y
         cmp   [a],y
         bra   lb1

lb0      dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         lda   [a]
         cmp   [b]
lb1      blt   lb2
         inc   result

lb2      return 2:result
         end

****************************************************************
*
*  function Le65(a,b: i65): boolean;
*
****************************************************************
*
Le65     start exp
result   equ   0

         subroutine (4:a,4:b),2

         stz   result
         ldy   #8
         lda   [a],y
         eor   [b],y
         bpl   lb0
         lda   [b],y
         cmp   [a],y
         bra   lb1

lb0      dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         dey
         dey
         lda   [a],y
         cmp   [b],y
         bne   lb1
         lda   [a]
         cmp   [b]
lb1      bgt   lb2
         inc   result

lb2      return 2:result
         end

****************************************************************
*
*  SaveBF - save a value to a bit-field
*
*  Inputs:
*        addr - address to copy to
*        bitdisp - displacement past the address
*        bitsize - number of bits
*        val - value to copy
*
****************************************************************
*
SaveBF   private cc
         jml   ~SaveBF                  call ~SaveBF in ORCALib
         end
