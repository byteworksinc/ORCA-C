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
