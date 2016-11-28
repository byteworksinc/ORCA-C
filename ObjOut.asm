         mcopy objout.macros
****************************************************************
*
*  CnOut - write a byte to the constant buffer
*
*  Inputs:
*        i - byte to write
*
****************************************************************
*
CnOut    start
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
CnOut2   start
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
COut     start

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
Out2     start

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
Out      start

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
OutByte  private

         lda   objLen                   if objLen+segDisp = buffSize then
         clc
         adc   segDisp
         lda   objLen+2
         adc   segDisp+2
         and   #$FFFE
         beq   lb2
	phx		   PurgeObjBuffer;
	jsl	PurgeObjBuffer
	plx
	lda	objLen	   check for segment overflow
	clc
	adc	segDisp
         lda   objLen+2
         adc   segDisp+2
         and   #$FFFE
         bne   lb2a
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

lb2a     lda   #$8000	handle a segment overflow
         sta   segDisp
         stz   segDisp+2
         ph2   #112
         jsl   Error
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
OutWord  private

         lda   objLen                   if objLen+segDisp+1 = buffSize then
         sec
         adc   segDisp
         lda   objLen+2
         adc   segDisp+2
         and   #$FFFE
         beq   lb2
	phx		   PurgeObjBuffer;
	jsl	PurgeObjBuffer
	plx
	lda	objLen	   check for segment overflow
	sec
	adc	segDisp
         lda   objLen+2
         adc   segDisp+2
         and   #$FFFE
         bne   lb3
lb2      anop                          carry must be clear
         lda   objPtr+2                p := pointer(ord4(objPtr)+segDisp);
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

lb3      ph2   #112                     flag segment overflow error
         jsl   Error
         lda   #$8000
	sta	segDisp
         stz   segDisp+2
	rts
         end
