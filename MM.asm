         mcopy mm.macros
****************************************************************
*
*  Calloc - Allocate memory from a pool and set it to 0.
*
*  Inputs:
*        bytes - number of bytes to allocate
*        useGlobalPool - should the memory come from the global
*               (or local) pool
*
*  Outputs:
*        ptr - points to the first byte of the allocated memory
*
****************************************************************
*
Calloc   start

ptr      equ   0                        pointer to reserved memory

         subroutine (2:bytes),4

         ph2   bytes                    reserve the memory
         jsl   Malloc
         sta   ptr                      save the pointer to the memory
         stx   ptr+2
         lda   bytes                    if there are an odd number of bytes then
         tay
         lsr   a
         bcc   lb1
         short M                          zero the first byte
         lda   #0
         dey
         sta   [ptr],Y
         long  M
lb1      tyx                            done if there are no more bytes
         beq   lb4
         lda   #0
         dey                            branch if the next word is the zeroth
         dey
         beq   lb3
lb2      sta   [ptr],Y                  zero full words
         dey
         dey
         bne   lb2
lb3      sta   [ptr]                    zero the last word

lb4      return 4:ptr                   return the pointer
         end

****************************************************************
*
*  GCalloc - Allocate and clear memory from the global pool.
*
*  Inputs:
*        bytes - number of bytes to allocate
*
*  Outputs:
*        ptr - points to the first byte of the allocated memory
*
****************************************************************
*
GCalloc  start

ptr      equ   0                        pointer to reserved memory

         subroutine (2:bytes),4

         ph2   bytes                    reserve the memory
         jsl   GMalloc
         sta   ptr                      save the pointer to the memory
         stx   ptr+2
         lda   bytes                    if there are an odd number of bytes then
         tay
         lsr   a
         bcc   lb1
         short M                          zero the first byte
         lda   #0
         dey
         sta   [ptr],Y
         long  M
lb1      tyx                            done if there are no more bytes
         beq   lb4
         lda   #0
         dey                            branch if the next word is the zeroth
         dey
         beq   lb3
lb2      sta   [ptr],Y                  zero full words
         dey
         dey
         bne   lb2
lb3      sta   [ptr]                    zero the last word

lb4      return 4:ptr                   return the pointer
         end

****************************************************************
*
*  Malloc - Allocate memory from a pool.
*
*  Inputs:
*        bytes - number of bytes to allocate
*        useGlobalPool - should the memory come from the global
*               (or local) pool
*
*  Outputs:
*        ptr - points to the first byte of the allocated memory
*
****************************************************************
*
Malloc   start

         lda   useGlobalPool
         jne   GMalloc
         jmp   LMalloc
         end
