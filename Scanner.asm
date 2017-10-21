         mcopy scanner.macros
****************************************************************
*
*  Convertsl - Convert a string to a long integer
*
*  Inputs:
*        str - pointer to the string
*
*  Outputs:
*        Returns the value.
*
*  Notes:
*        Assumes the string is valid.
*
****************************************************************
*
Convertsl start

val      equ   0                        return value

         subroutine (4:str),4

         stz   val                      initialize the number to zero
         stz   val+2
         lda   [str]                    set X to the number of characters
         and   #$00FF
         tax
         ldy   #1                       Y is the disp into the string
lb1      asl   val                      val := val*10
         rol   val+2
         ph2   val+2
         lda   val
         asl   val
         rol   val+2
         asl   val
         rol   val+2
         adc   val
         sta   val
         pla
         adc   val+2
         sta   val+2
         lda   [str],Y                  add in the new digit
         and   #$000F
         adc   val
         sta   val
         bcc   lb2
         inc   val+2
lb2      iny                            next character
         dex
         bne   lb1

         return 4:val
         end

****************************************************************
*
*  KeyPress - Has a key been presed?
*
*  If a key has not been pressed, this function returns
*  false.  If a key has been pressed, it clears the key
*  strobe.  If the key was an open-apple ., a terminal exit
*  is performed; otherwise, the function returns true.
*
****************************************************************
*
KeyPress start

	KeyPressGS kpRec
	lda	kpAvailable
	beq	rts
	ReadKeyGS rkRec
	lda	rkKey
	cmp	#'.'
	bne	lb1
	lda	rkModifiers
	and	#$0100
	beq	lb1
         ph2   #4
         jsl   TermError

lb1	lda	#1
rts	rtl

kpRec	dc	i'3'
kpKey	ds	2
kpModifiers ds	2
kpAvailable ds	2
                  
rkRec	dc	i'2'
rkKey	ds	2
rkModifiers ds	2
         end

****************************************************************
*
*  NextCh - Read the next character from the file, skipping comments
*
*  Outputs:
*        ch - character read
*
****************************************************************
*
NextCh   start
eofChar  equ   0                        end of file character
eolChar	equ	13	end of line character

stackFrameSize equ 14                   size of the work space
maxPath	equ	255	max length of a path name

fp       equ   1                        file record pointer; work pointer
p1       equ   5                        work pointer
p2       equ   9
cch	equ	13

         enum  (illegal,ch_special,ch_dash,ch_plus,ch_lt,ch_gt,ch_eq,ch_exc),0
         enum  (ch_and,ch_bar,ch_dot,ch_white,ch_eol,ch_eof,ch_char,ch_string)
         enum  (ch_asterisk,ch_slash,ch_percent,ch_carot,ch_pound,letter,digit)

         tsc                            create stack frame
         sec
         sbc   #stackFrameSize
         tcs
         phd
         tcd
! {flag for preprocessor check}
! if lastWasReturn then
!    lastWasReturn := charKinds[ord(ch)] in [ch_eol,ch_white]
! else
!    lastWasReturn := charKinds[ord(ch)] = ch_eol;
         lda   ch
         asl   A
         tax
         lda   charKinds,X
         ldy   #1
         cmp   #ch_eol
         beq   pf2
         ldx   lastWasReturn
         beq   pf1
         cmp   #ch_white
         beq   pf2
pf1      dey
pf2      sty   lastWasReturn
! 1:
lab1     anop
! if chPtr = eofPtr then begin          {flag end of file if we're there}
         lda   chPtr
         cmp   eofPtr
         bne   la1
         lda   chPtr+2
         cmp   eofPtr+2
         beq   la2
la1      brl   lb5
la2      anop
!    if not lastWasReturn then begin
!      lastWasReturn := true;
!      needWriteLine := true;
!      ch := chr(eolChar);
!      goto le2;
!      end; {if}
	lda	lastWasReturn
	bne	la3
	lda	#1
	sta	lastWasReturn
         sta   needWriteLine
	lda	#eolChar
	sta	ch
	brl	le2
!    ch := chr(eofChar);
la3	stz   ch

!    if needWriteLine then begin        {do eol processing}
!       WriteLine;
!       lineNumber := lineNumber+1;
!       firstPtr := chPtr;
!       end; {if}
         lda   needWriteLine
         beq   lb1
         jsl   WriteLine
         inc   lineNumber
         move4 chPtr,firstPtr
lb1      anop

!    if fileList = nil then begin
         lda   fileList
         ora   fileList+2
         bne   lb3
lb2      anop
!       skipping := false;
         sta   skipping
!       end {if}
         brl   le2
!    else begin
lb3      anop
!       {purge the current source file}
!       with ffDCBGS do begin
!          pCount := 5;
	lda	#5
	sta	ffDCBGS
!          action := 7;
         lda   #7
         sta   ffDCBGS+2
!          name := @includeFileGS.theString
         lla   ffDCBGS+12,includeFileGS+2
!          end; {with}
!       FastFileGS(ffDCBGS);
         FastFileGS ffDCBGS
!       fp := fileList;                   {open the file that included this one}
         move4 fileList,fp
!       fileList := fp^.next;
         ldy   #2
         lda   [fp]
         sta   fileList
         lda   [fp],Y
         sta   fileList+2
!       includeFileGS := fp^.name;
!       sourceFileGS := fp^.sname;
         add4  fp,#4,p1
         add4  fp,#4+maxPath+4,p2
         short M
         ldy   #maxPath+3
lb4      lda   [p1],Y
         sta   includeFileGS,Y
         lda   [p2],Y
         sta   sourceFileGS,Y
         dey
         bpl   lb4
         long  M
!       lineNumber := fp^.lineNumber;
         ldy   #4+maxPath+4+maxPath+4
         lda   [fp],Y
         sta   lineNumber
!       ReadFile;
         jsl   ReadFile
!       eofPtr := pointer(ord4(bofPtr) + ffDCBGS.fileLength);
         add4  bofPtr,ffDCBGS+46,eofPtr
!       chPtr := pointer(ord4(bofPtr) + fp^.disp);
!       includeChPtr := chPtr;
!       firstPtr := chPtr;
         ldy   #4+maxPath+4+maxPath+4+2
         clc
         lda   bofPtr
         adc   [fp],Y
         sta   chPtr
         sta   firstPtr
         sta   includeChPtr
         lda   bofPtr+2
         iny
         iny
         adc   [fp],Y
         sta   chPtr+2
         sta   firstPtr+2
         sta   includeChPtr+2
!       needWriteLine := false;
         stz   needWriteLine
!       dispose(fp);
         ph4   fp
         jsl   ~Dispose
!       includeCount := includeCount + 1;
	inc	includeCount
!       goto 1;
         brl   lab1
!       end; {if}
!    end {if}

! else begin
lb5      anop
!    ch := chr(chPtr^);                 {fetch the character}
         move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         sta   ch

!    if needWriteLine then begin        {do eol processing}
!       WriteLine;
!       lineNumber := lineNumber+1;
!       firstPtr := chPtr;
!       end; {if}
         lda   needWriteLine
         beq   lb6
         jsl   WriteLine
         inc   lineNumber
         move4 chPtr,firstPtr
lb6      anop
!    needWriteLine := charKinds[ord(ch)] = ch_eol;
         stz   needWriteLine
         lda   ch
         asl   A
         tax
         lda   charKinds,X
         cmp   #ch_eol
         bne   lb7
         inc   needWriteLine
lb7      anop
!    chPtr := pointer(ord4(chPtr) + 1);
         inc4  chPtr
! 2: if (ch = '\') and (charKinds[chPtr^] = ch_eol) then begin
!       chPtr := pointer(ord4(chPtr) + 1);
!       DebugCheck;
!       needWriteLine := true;
!       goto 1;
!       end; {if}
lab2     lda   ch
         cmp   #'\'
         bne   lb8
         move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         asl   A
         tax
         lda   charKinds,X
         cmp   #ch_eol
         bne   lb8
         inc4  chPtr
         jsr   DebugCheck
         lda   #1
         sta   needWriteLine
         brl   lab1
lb8      anop
!    {check for debugger code}
!    if needWriteLine then
!       DebugCheck;
         lda   needWriteLine
         beq   lb9
         jsr   DebugCheck
lb9      anop
!
!    {if it's a comment, skip the comment }
!    {characters and return a space.      }
!    if (not doingstring) and (ch = '/') and (chPtr <> eofPtr)
!       and ((chr(chPtr^) = '*')
!       or ((chr(chPtr^) = '/') and slashSlashComments))then begin
         lda   doingstring
         jne   lc6
         lda   ch
         cmp   #'/'
         jne   lc7
         lda   chPtr
         cmp   eofPtr
         bne   lc1
         lda   chPtr+2
         cmp   eofPtr+2
         jeq   lc6
lc1      move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         cmp   #'*'
	beq	lc1a
	cmp	#'/'
         jne   lc6
	ldx	slashSlashComments
	jeq	lc6
!       cch := chr(chPtr^);
lc1a	sta	cch
!       chPtr := pointer(ord4(chPtr)+1);  {skip the '*' or '/'}
	inc4  chPtr
!       done := false;
!       repeat
lc2      anop
!          if chPtr = eofPtr then         {if at eof, we're done}
!             done := true
         lda   chPtr
         cmp   eofPtr
         bne   lc2a
         lda   chPtr+2
         cmp   eofPtr+2
         jeq   lc5
!          else if (cch = '/') and (chPtr^ = return) then begin
lc2a	lda	cch
	cmp	#'/'
	bne	lc2b
!             if charKinds[ord(ch)] = ch_eol then
!                done := true
!             else
!                chPtr := pointer(ord4(chPtr)+1);
	move4	chPtr,p1
	lda	[p1]
	and	#$00FF
         asl   A
	tax
	lda	charKinds,X
	cmp	#ch_eol
	jeq	lc5
	inc4	chPtr
	bra	lc2
!             end {else if}
!          else begin
!             ch := chr(chPtr^);          {check for terminating */}
lc2b     move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         sta   ch
!             if charKinds[ord(ch)] = ch_eol then begin
!                WriteLine;
!                lineNumber := lineNumber+1;
!                firstPtr := pointer(ord4(chPtr)+1);
!                end; {if}
         asl   A
         tax
         lda   charKinds,X
         cmp   #ch_eol
         bne   lc3
         jsl   WriteLine
         inc   lineNumber
         add4  chPtr,#1,firstPtr
lc3      anop
!             chPtr := pointer(ord4(chPtr)+1);
         inc4  chPtr
!             if ch = '*' then
!                if (chr(chPtr^) = '/') and (chPtr <> eofPtr) then begin
!                   chPtr := pointer(ord4(chPtr)+1);
!                   done := true;
!                   end; {if}
         lda   ch
         cmp   #'*'
         jne   lc2
         lda   chPtr
         cmp   eofPtr
         bne   lc4
         lda   chPtr+2
         cmp   eofPtr+2
         jeq   lc2
lc4      move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         cmp   #'/'
         jne   lc2
         inc4  chPtr
!             end; {else}
!       until done;
lc5      anop
!       {return a space as the result}
!       ch := ' ';
         lda   #' '
         sta   ch
!       end {if}
         brl   le2
!    else if (ch = '?') and (chPtr <> eofPtr) and (chr(chPtr^) = '?') then begin
lc6      lda   ch
lc7      cmp   #'?'
         jne   le2
         lda   chPtr
         cmp   eofPtr
         bne   lc8
         lda   chPtr+2
         cmp   eofPtr+2
         jeq   le2
lc8      move4 chPtr,p1
         lda   [p1]
         and   #$00FF
         cmp   #'?'
         jne   le2
!       chPtr2 := pointer(ord4(chPtr) + 1);
         inc4  p1
!       if (chPtr2 <> eofPtr)
         lda   p1
         cmp   eofPtr
         bne   ld1
         lda   p1+2
         cmp   eofPtr+2
         beq   le2
ld1      anop
!          and (chr(chPtr2^) in ['(','<','/','''','=',')','>','!','-']) then begin
!          case chr(chPtr2^) of
!             '(': ch := '[';
         lda   [p1]
         and   #$00FF
         cmp   #'('
         bne   ld2
         lda   #'['
         bra   le1
!             '<': ch := '{';
ld2      cmp   #'<'
         bne   ld3
         lda   #'{'
         bra   le1
!             '/': ch := '\';
ld3      cmp   #'/'
         bne   ld4
         lda   #'\'
         bra   le1
!            '''': ch := '^';
ld4      cmp   #''''
         bne   ld5
         lda   #'^'
         bra   le1
!             '=': ch := '#';
ld5      cmp   #'='
         bne   ld6
         lda   #'#'
         bra   le1
!             ')': ch := ']';
ld6      cmp   #')'
         bne   ld7
         lda   #']'
         bra   le1
!             '>': ch := '}';
ld7      cmp   #'>'
         bne   ld8
         lda   #'}'
         bra   le1
!             '!': ch := '|';
ld8      cmp   #'!'
         bne   ld9
         lda   #'|'
         bra   le1
!             '-': ch := '~';
ld9      cmp   #'-'
         bne   le2
         lda   #'~'
!             end; {case}
le1      sta   ch
!          chPtr := pointer(ord4(chPtr2) + 1);
         add4  chPtr,#2
!          goto 2;
         brl   lab2
!          end; {if}
!       end; {if}
!    end; {else}
le2      anop
         pld
         tsc
         clc
         adc   #stackFrameSize
         tcs
         rtl
! end; {NextCh}

;
;  Local subroutine
;
         enum  (stop,break,autogo),0    line number debug types
! procedure DebugCheck;
!
! {Check for debugger characters; process if found             }
!
! begin {DebugCheck}
DebugCheck anop
! if chPtr = eofPtr then
!    debugType := stop
         lda   chPtr
         ldx   chPtr+2
         cmp   eofPtr
         bne   db1
         cpx   eofPtr+2
         bne   db1
         stz   debugType
         bra   db5
! else if ord(chPtr^) = $07 then begin
db1      sta   p1
         stx   p1+2
         lda   [p1]
         and   #$00FF
	cmp	#$07
         bne   db2
!   debugType := break
         lda   #break
         sta   debugType
         bra   db3
! else if ord(chPtr^) = $06 then
db2      cmp   #$06
         bne   db4
!   debugType := autoGo;
         lda   #autoGo
         sta   debugType
!    chPtr := pointer(ord4(chPtr) + 1);
db3      inc4  chPtr
!    end {if}
         bra   db5
! else
!   debugType := stop;
db4      stz   debugType
! end; {DebugCheck}
db5      rts
         end

****************************************************************
*
*  SetDateTime - set up the date/time strings
*
*  Outputs:
*        dateStr - date
*        timeStr - time string
*
****************************************************************
*
SetDateTime private

         pha                            get the date/time
         pha
         pha
         pha
         _ReadTimeHex
         lda   1,S                      set the minutes
         xba
         jsr   convert
         sta   time+5
         pla                            set the seconds
         jsr   convert
         sta   time+8
         lda   1,S                      set the hour
         jsr   convert
         sta   time+2
         pla                            set the year
         xba
         jsr   convert
         sta   date+11
         lda   1,S                      set the day
         inc   A
         jsr   convert
         sta   date+6
         pla                            set the month
         xba
         and   #$00FF
         asl   A
         asl   A
         tax
         lda   month,X
         sta   date+2
         lda   month+1,X
         sta   date+3
         pla
         lla   timeStr,time             set the addresses
         lla   dateStr,date
         rtl

month    dc    c'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
date     dc    i'12',c'mmm dd 19yy',i1'0'
time     dc    i'9',c'hh:mm:ss',i1'0'

convert  and   #$00FF
         ldx   #0
cv1      sec
         sbc   #10
         bcc   cv2
         inx
         bra   cv1
cv2      clc
         adc   #10
         ora   #'0'
         xba
         pha
         txa
         ora   #'0'
         ora   1,S
         plx
         rts
         end
