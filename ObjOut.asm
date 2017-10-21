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
         inc   blkcnt                   blkcnt := blkcnt+1;
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
         inc   blkcnt                   blkcnt := blkcnt+2;
         inc   blkcnt
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
         inc   blkcnt                   blkcnt := blkcnt+1;
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
         bcc   lb2
	phx		   PurgeObjBuffer;
	jsl	PurgeObjBuffer
	plx
	lda	objLen	   check for segment overflow
	clc
	adc	segDisp
	bcs	lb2a
lb2      ph4   objPtr                   p := pointer(ord4(objPtr)+segDisp);
         tsc                            p^ := b;
         phd
         tcd
         ldy   segDisp
         short M
         txa
         sta   [1],Y
         long  M
         inc   segDisp                  segDisp := segDisp+1;

	pld
         tsc
         clc
         adc   #4
         tcs
         rts

lb2a     lda   #$8000	handle a segment overflow
         sta   segDisp
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
         bcc   lb2
	phx		   PurgeObjBuffer;
	jsl	PurgeObjBuffer
	plx
	lda	objLen	   check for segment overflow
	sec
	adc	segDisp
	bcs	lb3
lb2      ph4   objPtr                   p := pointer(ord4(objPtr)+segDisp);
         tsc                            p^ := b;
         phd
         tcd
         ldy   segDisp
         txa
         sta   [1],Y
         iny                            segDisp := segDisp+2;
         iny
	sty   segDisp                  save new segDisp

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
	rts
         end
