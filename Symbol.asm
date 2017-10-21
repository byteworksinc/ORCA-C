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
ClearTable private
tableSize equ  7026                     sizeof(symbolTable)

         subroutine (4:table),0

         ldy   #tableSize-2
         lda   #0
lb1      sta   [table],Y
         dey
         dey
         bpl   lb1

         return
         end
