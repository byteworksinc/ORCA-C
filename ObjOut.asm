         mcopy objout.macros
         datachk off
****************************************************************
*
*  CnOut - write a byte to the constant buffer
*
*  Inputs:
*        i - byte to write
*
****************************************************************
*
CnOut    start CodeGen
maxCBuffLen equ 191                     max index into the constant buffer

         lda   cBuffLen                 if cBuffLen = maxCBuffLen then
         cmp   #maxCBuffLen
         bne   lb1
         jsl   Purge                       Purge;
lb1      phb                            cBuff[cBuffLen] := i;
         plx
         ply
         pla
         phy
         phx
         plb
         ldx   cBuffLen
         short M
         sta   cBuff,X
         long  M
         inc   cBuffLen                 cBuffLen := cBuffLen+1;
         rtl
         end

****************************************************************
*
*  CnOut2 - write a word to the constant buffer
*
*  Inputs:
*        i - word to write
*
****************************************************************
*
CnOut2   start CodeGen
maxCBuffLen equ 191                     max index into the constant buffer

         lda   cBuffLen                 if cBuffLen+1 >= maxCBuffLen then
         inc   A
         cmp   #maxCBuffLen
         blt   lb1
         jsl   Purge                       Purge;
lb1      phb                            cBuff[cBuffLen] := i;
         plx
         ply
         pla
         phy
         phx
         plb
         ldx   cBuffLen
         sta   cBuff,X
         inx                            cBuffLen := cBuffLen+2;
         inx
         stx   cBuffLen
         rtl
         end

****************************************************************
*
*  COut - write a code byte to the object file
*
*  Inputs:
*        b - byte to write (on stack)
*
****************************************************************
*
COut     start CodeGen

         phb                            OutByte(b);
         pla
         ply
         plx
         phy
         pha
         plb
         jsr   OutByte
         inc4  blkcnt                   blkcnt := blkcnt+1;
         inc4  pc                       pc := pc+1;
         rtl
         end

****************************************************************
*
*  Out2 - write a word to the output file
*
*  Inputs:
*        w - word to write (on stack)
*
****************************************************************
*
Out2     start CodeGen

         phb                            OutWord(w);
         pla
         ply
         plx
         phy
         pha
         plb
         jsr   OutWord
         add4  blkcnt,#2                blkcnt := blkcnt+2;
         rtl
         end

****************************************************************
*
*  Out - write a byte to the output file
*
*  Inputs:
*        b - byte to write (on stack)
*
****************************************************************
*
Out      start CodeGen

         phb                            OutByte(b);
         pla
         ply
         plx
         phy
         pha
         plb
         jsr   OutByte
         inc4  blkcnt                   blkcnt := blkcnt+1;
         rtl
         end

****************************************************************
*
*  OutByte - write a byte to the object file
*
*  Inputs:
*        X - byte to write
*
****************************************************************
*
OutByte  private CodeGen

         lda   objLen                   if objLen+segDisp >= buffSize then
         clc
         adc   segDisp
         lda   objLen+2
         adc   segDisp+2
         beq   lb2
         and   minusBuffSize+2
         beq   lb2
         phx                               MakeSpaceInObjBuffer;
         jsl   MakeSpaceInObjBuffer
         plx
         clc
lb2      anop                           carry must be clear
         lda   objPtr+2                 p := pointer(ord4(objPtr)+segDisp);
         adc   segDisp+2
         pha
         lda   objPtr
         pha
         tsc                            p^ := b;
         phd
         tcd
         ldy   segDisp
         short M
         txa
         sta   [1],Y
         long  M
         inc4  segDisp                  segDisp := segDisp+1;

         pld
         tsc
         clc
         adc   #4
         tcs
         rts
         end

****************************************************************
*
*  OutWord - write a word to the object file
*
*  Inputs:
*        X - word to write
*
****************************************************************
*
OutWord  private CodeGen

         lda   objLen                   if objLen+segDisp+1 >= buffSize then
         sec
         adc   segDisp
         lda   objLen+2
         adc   segDisp+2
         beq   lb2
         and   minusBuffSize+2
         beq   lb2
         phx                               MakeSpaceInObjBuffer;
         jsl   MakeSpaceInObjBuffer
         plx
         clc
lb2      anop                           carry must be clear
         lda   objPtr+2                 p := pointer(ord4(objPtr)+segDisp);
         adc   segDisp+2
         pha
         lda   objPtr
         pha
         tsc                            p^ := b;
         phd
         tcd
         ldy   segDisp
         txa
         sta   [1],Y
         add4  segDisp,#2               segDisp := segDisp+2;

         pld
         tsc
         clc
         adc   #4
         tcs
         rts
         end
