	keep	stdio
	mcopy stdio.macros
	case	on

****************************************************************
*
*  StdIO - Standard I/O Library
*
*  This code implements the tables and subroutines needed to
*  support the standard C library STDIO.
*
*  November 1988
*  Mike Westerfield
*
*  Copyright 1988
*  Byte Works, Inc.
*
*  Note: Portions of this library appear in SysFloat.
*
****************************************************************
*
StdIO	start		dummy segment
	copy	equates.asm

	end

****************************************************************
*
*  void clearerr(stream)
*	FILE *stream;
*
*  Clears the error flag for the givin stream.
*
*  Inputs:
*	stream - file to clear
*
****************************************************************
*
clearerr start
stream	equ	4	input stream

	tsc
	phd
	tcd
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	bcs	lb1
	ldy	#FILE_flag	clear the error flag
	lda	[stream],Y
	and	#$FFFF-_IOERR-_IOEOF
	sta	[stream],Y
lb1	pld
	lda	2,S
	sta	6,S
	pla
	sta	3,S
	pla
	rtl
	end

****************************************************************
*
*  int fclose(stream)
*	FILE *stream;
*
*  Inputs:
*	stream - pointer to the file buffer to close
*
*  Outputs:
*	A - EOF for an error; 0 if there was no error
*
****************************************************************
*
fclose	start
nameBuffSize equ 8*1024	pathname buffer size

err	equ	1	return value
p	equ	3	work pointer
stdfile	equ	7	is this a standard file?

	csubroutine (4:stream),8
	phb
	phk
	plb

	lda	#EOF	assume we will get an error
	sta	err
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rts

	ph4	stream	do any pending I/O
	jsl	fflush
	tax
	jne	rts

	stz	stdfile	not a standard file
	lda	stream+2	bypass file disposal if the file is
	cmp	#^stdin+4	 one of the standard ones
	bne	cl0
	lda	stream
	cmp	#stdin+4
	beq	lb1
	cmp	#stdout+4
	beq	lb1
	cmp	#stderr+4
	bne	cl0
lb1	inc	stdfile
	bra	cl3a

cl0	lla	p,stderr+4	find the file record that points to this
	ldy	#2	 one
cl1	lda	[p]
	ora	[p],Y
	jeq	rts
	lda	[p],Y
	tax
	lda	[p]
	cmp	stream
	bne	cl2
	cpx	stream+2
	beq	cl3
cl2	stx	p+2
	sta	p
	bra	cl1

cl3	lda	[stream]	remove stream from the file list
	sta	[p]
	lda	[stream],Y
	sta	[p],Y
cl3a	ldy	#FILE_flag	if the file was opened by tmpfile then
	lda	[stream],Y
	and	#_IOTEMPFILE
	beq	cl3d
	ph4	#nameBuffSize	  p = malloc(nameBuffSize)
	jsl	malloc	  grPathname = p
	sta	p	  dsPathname = p+2
	stx	p+2
	sta	grPathname
	stx	grPathname+2
	clc
	adc	#2
	bcc	cl3b
	inx
cl3b	sta	dsPathname
	stx	dsPathname+2
	lda	#nameBuffSize	  p->size = nameBuffSize
	sta	[p]
	ldy	#FILE_file	  clRefnum = grRefnum = stream->_file
	lda	[stream],Y
	beq	cl3e
	sta	grRefnum
	GetRefInfoGS gr	  GetRefInfoGS(gr)
	bcs	cl3c
	lda	grRefnum	  OSClose(cl)
	sta	clRefNum
	OSClose cl
	DestroyGS ds	  DestroyGS(ds)
cl3c	ph4	p	  free(p)
	jsl	free
	bra	cl3e	else
cl3d	ldy	#FILE_file	  close the file
	lda	[stream],Y
	beq	cl3e
	sta	clRefNum
	OSClose cl
cl3e	ldy	#FILE_flag	if the buffer was allocated by fopen then
	lda	[stream],Y
	and	#_IOMYBUF
	beq	cl4
	ldy	#FILE_base+2	  dispose of the file buffer
	lda	[stream],Y
	pha
	dey
	dey
	lda	[stream],Y
	pha
	jsl	free
cl4	lda	stdfile	if this is not a standard file then
	bne	cl5
	ph4	stream	  dispose of the file buffer
	jsl	free
	bra	cl7	else
cl5	add4	stream,#sizeofFILE-4,p	  reset the standard out stuff
	ldy	#sizeofFILE-2
cl6	lda	[p],Y
	sta	[stream],Y
	dey
	dey
	cpy	#2
	bne	cl6
cl7	stz	err	no error found
rts	plb
	creturn   2:err

cl	dc	i'1'	parameter block for OSclose
clRefNum ds	2

gr	dc	i'3'	parameter block for GetRefInfoGS
grRefnum	ds	2
	ds	2
grPathname ds	4

ds	dc	i'1'	parameter block for DestroyGS
dsPathname ds	4
	end

****************************************************************
*
*  int feof(stream)
*	FILE *stream;
*
*  Inputs:
*	stream - file to check
*
*  Outputs:
*	Returns _IOEOF if an end of file has been reached; else
*	0.
*
****************************************************************
*
feof	start
stream	equ	4	input stream

	tsc
	phd
	tcd
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	ldx	#_IOEOF
	bcs	lb1
	ldy	#FILE_flag	check for eof
	lda	[stream],Y
	and	#_IOEOF
	tax
lb1	pld
	lda	2,S
	sta	6,S
	pla
	sta	3,S
	pla
	txa
	rtl
	end

****************************************************************
*
*  int ferror(stream)
*	FILE *stream;
*
*  Inputs:
*	stream - file to check
*
*  Outputs:
*	Returns _IOERR if an end of file has been reached; else
*	0.
*
****************************************************************
*
ferror	start
stream	equ	4	input stream

	tsc
	phd
	tcd
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	ldx	#_IOERR
	bcs	lb1
	ldy	#FILE_flag	return the error status
	lda	[stream],Y
	and	#_IOERR
	tax
lb1	pld
	lda	2,S
	sta	6,S
	pla
	sta	3,S
	pla
	txa
	rtl
	end

****************************************************************
*
*  int fflush(steam)
*	FILE *stream;
*
*  Write any pending characters to the output file
*
*  Inputs:
*	stream - file buffer
*
*  Outputs:
*	A - EOF for an error; 0 if there was no error
*
****************************************************************
*
fflush	start
err	equ	1	return value
sp	equ	3	stream work pointer

	csubroutine (4:stream),6
	phb
	phk
	plb

	lda	stream	if stream = nil then
	ora	stream+2
	bne	fa3
	lda	stderr+4	  sp = stderr.next
	sta	sp
	lda	stderr+6
	sta	sp+2
	stz	err	  err = 0
fa1	lda	sp	  while sp <> nil
	ora	sp+2
	jeq	rts
	ph4	sp	    fflush(sp);
	jsl	fflush
	tax		    if returned value <> 0 then
	beq	fa2
	sta	err	      err = returned value
fa2	ldy	#2	    sp = sp^.next
	lda	[sp],Y
	tax
	lda	[sp]
	sta	sp
	stx	sp+2
	bra	fa1	  endwhile

fa3	lda	#EOF	assume there is an error
	sta	err
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rts
	ldy	#FILE_flag	if the mode is not writting, quit
	lda	[stream],Y
	and	#_IOWRT
	beq	fl1
	ldy	#FILE_file	set the reference number
	lda	[stream],Y
	sta	wrRefNum
	ldy	#FILE_base	set the starting location
	lda	[stream],Y
	sta	wrDataBuffer
	iny
	iny
	lda	[stream],Y
	sta	wrDataBuffer+2
	sec		set the # of bytes to write
	ldy	#FILE_ptr
	lda	[stream],Y
	sbc	wrDataBuffer
	sta	wrRequestCount
	iny
	iny
	lda	[stream],Y
	sbc	wrDataBuffer+2
	sta	wrRequestCount+2
	ora	wrRequestCount	skip the write if there are no
	beq	fl1	 characters
	OSwrite wr	write the info
	bcc	fl1
	ph4	stream
	jsr	~ioerror
	bra	rts

fl1	ldy	#FILE_flag	if the file is open for read/write then
	lda	[stream],Y
	bit	#_IORW
	beq	fl3
	bit	#_IOREAD	  if the file is being read then
	beq	fl2
	ph4	stream	    use ftell to set the mark
	jsl	ftell
	ldy	#FILE_flag
	lda	[stream],Y
fl2	and	#$FFFF-_IOWRT-_IOREAD	  turn off the reading and writing flags
	sta	[stream],Y
fl3	ph4	stream	prepare file for output
	jsl	~InitBuffer
	stz	err	no error found
rts	plb
	creturn 2:err

wr	dc	i'5'	parameter block for OSwrite
wrRefNum ds	2
wrDataBuffer ds 4
wrRequestCount ds 4
	ds	4
	dc	i'1'
	end

****************************************************************
*
*  int fgetc(stream)
*	FILE *stream;
*
*  Read a character from a file
*
*  Inputs:
*	stream - file to read from
*
*  Outputs:
*	A - character read; EOF for an error
*
****************************************************************
*
fgetc	start
getc	entry

c	equ	1	character read
p	equ	3	work pointer

	csubroutine (4:stream),6
	phb
	phk
	plb

	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	bcs	lb0
	ldy	#FILE_flag	quit with error if the end of file
	lda	[stream],Y	 has been reached or an error has been
	and	#_IOEOF+_IOERR	 encountered
	beq	lb1
lb0	lda	#EOF
	sta	c
	brl	gc9

lb1	ldy	#FILE_pbk	if there is a char in the putback buffer
	lda	[stream],Y
	bmi	lb2
	and	#$00FF	  return it
	sta	c
	ldy	#FILE_pbk+2	  pop the putback buffer
	lda	[stream],Y
	tax
	lda	#$FFFF
	sta	[stream],Y
	ldy	#FILE_pbk
	txa
	sta	[stream],Y
	brl	gc9

lb2	ldy	#FILE_file	branch if this is a disk file
	lda	[stream],Y
	bpl	gc2

	cmp	#stdinID	if stream = stdin then
	bne	gc1
	jsl	SYSKEYIN	  get a character
	tax		  branch if not eof
	bne	st1
	lda	#_IOEOF	  set EOF flag
	ora	>stdin+4+FILE_flag
	sta	>stdin+4+FILE_flag
	jsl	SYSKEYIN	  read the closing cr
	lda	#EOF	  return EOF
st1	sta	c
	brl	gc9

gc1	ph4	stream	else flag the error
	jsr	~ioerror
	lda	#EOF
	sta	c
	brl	gc9

gc2	ldy	#FILE_flag	if the file is not read enabled then
	lda	[stream],Y
	bit	#_IOREAD
	bne	gc2a
	bit	#_IOWRT	  it is an error if it is write enabled
	bne	gc1
	bra	gc2b
gc2a	ldy	#FILE_cnt	we're ready if there are characters
	lda	[stream],Y	 left
	iny
	iny
	ora	[stream],Y
	jne	gc8

gc2b	ldy	#FILE_flag	  if input is unbuffered then
	lda	[stream],Y
	bit	#_IONBF
	beq	gc3
	stz	rdDataBuffer+2	    set up to read one char to c
	tdc
	clc
	adc	#c
	sta	rdDataBuffer
	lla	rdRequestCount,1
	bra	gc4
gc3	ldy	#FILE_base	else set up to read a buffer full
	lda	[stream],Y
	sta	rdDataBuffer
	iny
	iny
	lda	[stream],Y
	sta	rdDataBuffer+2
	ldy	#FILE_size
	lda	[stream],Y
	sta	rdRequestCount
	iny
	iny
	lda	[stream],Y
	sta	rdRequestCount+2
gc4	ldy	#FILE_file	set the file reference number
	lda	[stream],Y
	sta	rdRefNum
	OSRead rd	read the data
	bcc	gc7	if there was a read error then
	ldy	#FILE_flag
	cmp	#$4C	  if it was eof then
	bne	gc5
	lda	#_IOEOF	    set the EOF flag
	bra	gc6	  else
gc5	lda	#_IOERR	    set the error flag
gc6	ora	[stream],Y
	sta	[stream],Y
	lda	#EOF	  return EOF
	sta	c
	brl	gc9

gc7	ldy	#FILE_flag	we're done if the read is unbuffered
	lda	[stream],Y
	and	#_IONBF
	jne	gc9
	clc		set the end of the file buffer
	ldy	#FILE_end
	lda	rdDataBuffer
	adc	rdTransferCount
	sta	[stream],Y
	iny
	iny
	lda	rdDataBuffer+2
	adc	rdTransferCount+2
	sta	[stream],Y
	ldy	#FILE_base	reset the file pointer
	lda	[stream],Y
	tax
	iny
	iny
	lda	[stream],Y
	ldy	#FILE_ptr+2
	sta	[stream],Y
	dey
	dey
	txa
	sta	[stream],Y
	ldy	#FILE_cnt	set the # chars in the buffer
	lda	rdTransferCount
	sta	[stream],Y
	iny
	iny
	lda	rdTransferCount+2
	sta	[stream],Y
	ldy	#FILE_flag	note that the file is read enabled
	lda	[stream],Y
	ora	#_IOREAD
	sta	[stream],Y

gc8	ldy	#FILE_ptr	get the next character
	lda	[stream],Y
	sta	p
	clc
	adc	#1
	sta	[stream],Y
	iny
	iny
	lda	[stream],Y
	sta	p+2
	adc	#0
	sta	[stream],Y
	lda	[p]
	and	#$00FF
	sta	c
	ldy	#FILE_cnt	dec the # chars in the buffer
	sec
	lda	[stream],Y
	sbc	#1
	sta	[stream],Y
	bcs	gc8a
	iny
	iny
	lda	[stream],Y
	dec	A
	sta	[stream],Y

gc8a	ldy	#FILE_flag	if the file is read/write
	lda	[stream],Y
	and	#_IORW
	beq	gc9
	ldy	#FILE_cnt	and the buffer is empty then
	lda	[stream],Y
	iny
	iny
	ora	[stream],Y
	bne	gc9
	ldy	#FILE_flag	  note that no chars are left
	lda	[stream],Y
	eor	#_IOREAD
	sta	[stream],Y

gc9	lda	c	if c = \r then
	cmp	#13
	bne	gc10
	ldy	#FILE_flag	  if this is a text file then
	lda	[stream],Y
	and	#_IOTEXT
	beq	gc10
	lda	#10
	sta	c

gc10	plb
	creturn 2:c
;
;  Local data
;
rd	dc	i'4'	parameter block for OSRead
rdRefNum ds	2
rdDataBuffer ds 4
rdRequestCount ds 4
rdTransferCount ds 4
	end

****************************************************************
*
*  char *fgets(s, n, stream)
*	char *s;
*	int n;
*	FILE *stream;
*
*  Reads a line into the string s.
*
*  Inputs:
*	s - location to put the string read.
*	n - size of the string
*	stream - file to read from
*
*  Outputs:
*	Returns NULL if an EOF is encountered, placing any
*	characters read before the EOF into s.	 Returns S if
*	a line or part of a line is read.
*
****************************************************************
*
fgets	start
RETURN	equ	13	RETURN key code
LF	equ	10	newline

disp	equ	1	disp in s

	csubroutine (4:s,2:n,4:stream),2

	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	bcs	err1
	ph4	stream	quit with NULL if at EOF
	jsl	feof
	tax
	beq	lb0
err1	stz	s
	stz	s+2
	bra	rts
lb0	stz	disp	no characters processed so far
	lda	#0
	sta	[s]
	dec	n	leave room for the null terminator
	bmi	err
	beq	err
lb1	ph4	stream	get a character
	jsl	fgetc
	tax		quit with error if it is an EOF
	bpl	lb2
err	stz	s
	stz	s+2
	bra	rts
lb2	cmp	#RETURN	if the char is a return, switch to lf
	bne	lb3
	lda	#LF
lb3	ldy	disp	place the char in the string
	sta	[s],Y	 (null terminates automatically)
	inc	disp
	cmp	#LF	quit if it was an LF
	beq	rts
	dec	n	next character
	bne	lb1
rts	creturn 4:s
	end

****************************************************************
*
*  int fgetpos(FILE *stream, fpos_t *pos);
*
*  Inputs:
*	stream - pointer to stream to get position of
*	pos - pointer to location to place position
*
*  Outputs:
*	A - 0 if successful; else -1 if not
*	errno - if unsuccessful, errno is set to EIO
*
****************************************************************
*
fgetpos	start
err	equ	1	error code

	csubroutine (4:stream,4:pos),2

	ph4	stream	get the position
	jsl	ftell
	cmp	#-1	if the position = -1 then
	bne	lb1
	cpx	#-1
	bne	lb1
	sta	err	  err = -1
	bra	lb2	  return
lb1	sta	[pos]	else
	txa		  *pos = position
	ldy	#2
	sta	[pos],Y
	stz	err	  err = 0
lb2	anop		endif

	creturn 2:err
	end

****************************************************************
*
*  FILE *fopen(filename, type)
*	char *filename, *type;
*
*  Inputs:
*	filename - pointer to the file name
*	type - pointer to the type string
*
*  Outputs:
*	X-A - pointer to the file variable; NULL for an error
*
****************************************************************
*
fopen	start
BIN	equ	6	file type for BIN files
TXT	equ	4	file type for TXT files

fileType equ	1	file type letter
fileBuff equ	3	pointer to the file buffer
buffStart equ	7	start of the file buffer
OSname	equ	11	pointer to the GS/OS file name
;
;  initialization
;
	csubroutine (4:filename,4:type),14

	phb		use our data bank
	phk
	plb

	stz	fileBuff	no file so far
	stz	fileBuff+2

	lda	[type]	make sure the file type is in ['a','r','w']
	and	#$00FF
	sta	fileType
	ldx	#$0003
	cmp	#'a'
	beq	cn1
	ldx	#$0002
	cmp	#'w'
	beq	cn1
	ldx	#$0001
	cmp	#'r'
	beq	cn1
	lda	#EINVAL
	sta	>errno
	brl	rt2
;
;  create a GS/OS file name
;
cn1	stx	opAccess	set the access flags
	ph4	filename	get the length of the name buffer
	jsl	~osname
	sta	OSname
	stx	OSname+2
	ora	OSname+2
	jeq	rt2
;
;  check for file modifier characters + and b
;
	lda	#TXT	we must open a new file - determine it's
	sta	crFileType	 type by looking for the 'b' designator
	ldy	#1
	lda	[type],Y
	jsr	Modifier
	bcc	cm1
	iny
	lda	[type],Y
	jsr	Modifier
cm1	anop
;
;  open the file
;
	move4 OSname,opName	try to open an existing file
	OSopen op
	bcc	of2

	lda	fileType	if the type is 'r', flag an error
	cmp	#'r'
	bne	of1
	lda	#ENOENT
	sta	>errno
	brl	rt1

of1	move4 OSname,crPathName	create the file
	OScreate cr
	bcs	errEIO
	OSopen op	open the file
	bcc	of2
errEIO	lda	#EIO
	sta	>errno
	brl	rt1

of2	lda	fileType	if the file type is 'w' then
	cmp	#'w'
	bne	of3
	lda	opRefNum	  reset it
	sta	efRefNum
	OSSet_EOF ef
	bcc	ar1	  allow "not a block device error"
	cmp	#$0058
	beq	ar1
	bra	errEIO	  flag the error
of3	cmp	#'a'	else if the file type is 'a' then
	bne	ar1
	lda	opRefNum
	sta	gfRefNum
	sta	smRefNum
	OSGet_EOF gf	  append to it
	bcs	errEIO
	move4 gfEOF,smDisplacement
	OSSet_Mark sm
	bcs	errEIO
;
;  allocate and fill in the file record
;
ar1	ph4	#sizeofFILE	get space for the file record
	jsl	malloc
	sta	fileBuff
	stx	fileBuff+2
	ora	fileBuff+2
	beq	ar2
	ph4	#BUFSIZ	get space for the file buffer
	jsl	malloc
	sta	buffStart
	stx	buffStart+2
	ora	buffStart+2
	bne	ar3
	ph4	fileBuff	memory error
	jsl	free
ar2	lda	#ENOMEM
	sta	>errno
	brl	rt1

ar3	ldy	#2	insert the record right after stderr
	lda	>stderr+4
	sta	[fileBuff]
	lda	>stderr+6
	sta	[fileBuff],Y
	lda	fileBuff
	sta	>stderr+4
	lda	fileBuff+2
	sta	>stderr+6
	lda	buffStart	set the start of the buffer
	ldy	#FILE_base
	sta	[fileBuff],Y
	iny
	iny
	lda	buffStart+2
	sta	[fileBuff],Y
	ldy	#FILE_ptr+2
	sta	[fileBuff],Y
	dey
	dey
	lda	buffStart
	sta	[fileBuff],Y
	ldy	#FILE_size	set the buffer size
	lda	#BUFSIZ
	sta	[fileBuff],Y
	iny
	iny
	lda	#^BUFSIZ
	sta	[fileBuff],Y
	ldy	#1	set the flags
	lda	[type],Y
	and	#$00FF
	cmp	#'+'
	beq	ar3a
	cmp	#'b'
	bne	ar4
	iny
	lda	[type],Y
	and	#$00FF
	cmp	#'+'
	bne	ar4
ar3a	lda	#_IOFBF+_IORW+_IOMYBUF
	bra	ar6
ar4	lda	fileType
	cmp	#'r'
	beq	ar5
	lda	#_IOFBF+_IOWRT+_IOMYBUF
	bra	ar6
ar5	lda	#_IOFBF+_IOREAD+_IOMYBUF
ar6	ldy	#FILE_flag
	ldx	crFileType
	cpx	#BIN
	beq	ar6a
	ora	#_IOTEXT
ar6a	sta	[fileBuff],Y
	ldy	#FILE_cnt	no chars in buffer
	lda	#0
	sta	[fileBuff],Y
	iny
	iny
	sta	[fileBuff],Y
	ldy	#FILE_pbk	nothing in the putback buffer
	lda	#$FFFF
	sta	[fileBuff],Y
	ldy	#FILE_pbk+2
	sta	[fileBuff],Y
	ldy	#FILE_file	set the file ID
	lda	opRefNum
	sta	[fileBuff],Y
;
;  return the result
;
rt1	ph4	OSname	dispose of the file name buffer
	jsl	free
rt2	plb		restore caller's data bank
	creturn 4:fileBuff	return
;
;  Modifier - local subroutine to check modifier character
;
;  Returns: C=0 if no modifier found, else C=1
;
Modifier and	#$00FF
	beq	md3
	cmp	#'+'
	bne	md1
	lda	#$0003
	sta	opAccess
	sec
	rts
md1	cmp	#'b'
	bne	md2
	lda	#BIN
	sta	crFileType
md2	sec
	rts

md3	clc
	rts
;
;  local data areas
;
op	dc	i'3'	parameter block for OSopen
opRefNum ds	2
opName	ds	4
opAccess ds	2

gf	dc	i'2'	GetEOF record
gfRefNum ds	2
gfEOF	ds	4

sm	dc	i'3'	SetMark record
smRefNum ds	2
smBase	dc	i'0'
smDisplacement ds 4

ef	dc	i'3'	parameter block for OSSet_EOF
efRefNum ds	2
	dc	i'0'
	dc	i4'0'

cr	dc	i'7'	parameter block for OScreate
crPathName ds	4
	dc	i'$C3'
crFileType ds	2
	dc	i4'0'
	dc	i'1'
	dc	i4'0'
	dc	i4'0'
	dc	r'fgetc'
	dc	r'fputc'
	dc	r'fclose'
	end

****************************************************************
*
*  FILE *freopen(filename, type, stream)
*	char *filename, *type;
*	FILE *stream;
*
*  Inputs:
*	filename - pointer to the file name
*	type - pointer to the type string
*	stream - file buffer to use
*
*  Outputs:
*	X-A - pointer to the file variable; NULL for an error
*
****************************************************************
*
freopen	start
BIN	equ	6	file type for BIN files
TXT	equ	4	file type for TXT files

fileType equ	1	file type letter
buffStart equ	3	start of the file buffer
OSname	equ	7	pointer to the GS/OS file name
fileBuff equ	11	file buffer to return
;
;  initialization
;
	csubroutine (4:filename,4:type,4:stream),14

	phb		use our data bank
	phk
	plb

	stz	fileBuff	the open is not legal, yet
	stz	fileBuff+2

	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rt2
	lda	[type]	make sure the file type is in ['a','r','w']
	and	#$00FF
	sta	fileType
	cmp	#'a'
	beq	cl1
	cmp	#'w'
	beq	cl1
	cmp	#'r'
	beq	cl1
	lda	#EINVAL
	sta	>errno
	brl	rt2
;
;  close the old file
;
cl1	ldy	#FILE_file	branch if the file is not a disk file
	lda	[stream],Y
	bmi	cn1

	ph4	stream	do any pending I/O
	jsl	fflush
	ldy	#FILE_file	close the file
	lda	[stream],Y
	sta	clRefNum
	OSclose cl
	ldy	#FILE_flag	if the buffer was allocated by fopen then
	lda	[stream],Y
	and	#_IOMYBUF
	beq	cn1
	ldy	#FILE_base+2	  dispose of the file buffer
	lda	[stream],Y
	pha
	dey
	dey
	lda	[stream],Y
	pha
	jsl	free
;
;  create a GS/OS file name
;
cn1	ph4	filename	get the length of the name buffer
	jsl	~osname
	sta	OSname
	stx	OSname+2
	ora	OSname+2
	jeq	rt2
;
;  open the file
;
	lda	#TXT	we must open a new file - determine it's
	sta	crFileType	 type by looking for the 'b' designator
	ldy	#1
	lda	[type],Y
	and	#$00FF
	cmp	#'+'
	bne	nl1
	iny
	lda	[type],Y
	and	#$00FF
nl1	cmp	#'b'
	bne	nl2
	lda	#BIN
	sta	crFileType

nl2	move4 OSname,opName	try to open an existing file
	OSopen op
	bcc	of2

	lda	fileType	if the type is 'r', flag an error
	cmp	#'r'
	bne	of1
errEIO	ph4	stream
	jsr	~ioerror
	brl	rt1

of1	move4 OSname,crPathName	create the file
	OScreate cr
	bcs	errEIO
	OSopen op	open the file
	bcs	errEIO

of2	lda	fileType	if the file type is 'w', reset it
	cmp	#'w'
	bne	ar1
	lda	opRefNum
	sta	efRefNum
	OSSet_EOF ef
	bcs	errEIO
;
;  fill in the file record
;
ar1	ph4	#BUFSIZ	get space for the file buffer
	jsl	malloc
	sta	buffStart
	stx	buffStart+2
	ora	buffStart+2
	bne	ar3
	lda	#ENOMEM	memory error
	sta	>errno
	brl	rt1

ar3	move4 stream,fileBuff	set the file buffer address
	lda	buffStart	set the start of the buffer
	ldy	#FILE_base
	sta	[fileBuff],Y
	iny
	iny
	lda	buffStart+2
	sta	[fileBuff],Y
	ldy	#FILE_ptr+2
	sta	[fileBuff],Y
	dey
	dey
	lda	buffStart
	sta	[fileBuff],Y
	ldy	#FILE_size	set the buffer size
	lda	#BUFSIZ
	sta	[fileBuff],Y
	iny
	iny
	lda	#^BUFSIZ
	sta	[fileBuff],Y
	ldy	#1	set the flags
	lda	[type],Y
	and	#$00FF
	cmp	#'+'
	bne	ar4
	lda	#_IOFBF+_IORW+_IOMYBUF
	bra	ar6
ar4	lda	fileType
	cmp	#'r'
	beq	ar5
	lda	#_IOFBF+_IOWRT+_IOMYBUF
	bra	ar6
ar5	lda	#_IOFBF+_IOREAD+_IOMYBUF
ar6	ldy	#FILE_flag
	ldx	crFileType
	cpx	#BIN
	beq	ar6a
	ora	#_IOTEXT
ar6a	sta	[fileBuff],Y
	ldy	#FILE_cnt	no chars in buffer
	lda	#0
	sta	[fileBuff],Y
	iny
	iny
	sta	[fileBuff],Y
	ldy	#FILE_pbk	nothing in the putback buffer
	lda	#$FFFF
	sta	[fileBuff],Y
	ldy	#FILE_pbk+2
	sta	[fileBuff],Y
	ldy	#FILE_file	set the file ID
	lda	opRefNum
	sta	[fileBuff],Y
;
;  return the result
;
rt1	ph4	OSname	dispose of the file name buffer
	jsl	free
rt2	plb		restore caller's data bank
	creturn 4:fileBuff	return
;
;  local data areas
;
op	dc	i'2'	parameter block for OSopen
opRefNum ds	2
opName	ds	4

ef	dc	i'3'	parameter block for OSSet_EOF
efRefNum ds	2
	dc	i'0'
	dc	i4'0'

cr	dc	i'7'	parameter block for OScreate
crPathName ds	4
	dc	i'$C3'
crFileType ds	2
	dc	i4'0'
	dc	i'1'
	dc	i4'0'
	dc	i4'0'

cl	dc	i'1'	parameter block for OSclose
clRefNum ds	2
;
;  Patch for standard out
;
stdoutFile jmp stdoutPatch

stdoutPatch phb
	plx
	ply
	pla
	pha
	pha
	pha
	phy
	phx
	plb
	lda	>stdout
	sta	6,S
	lda	>stdout+2
	sta	8,S
	brl	fputc
;
;  Patch for standard in
;
stdinFile jmp stdinPatch

stdinPatch ph4 #stdin+4
	jsl	fgetc
	rtl
	end

****************************************************************
*
*  int fprintf(stream, char *format, additional arguments)
*
*  Print the format string to standard out.
*
****************************************************************
*
fprintf	start
	using ~printfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	stream
	pla
	sta	stream+2
	phy		restore return address/data bank
	phx
	plb
	lda	>stream+2	verify that stream exists
	pha
	lda	>stream
	pha
	jsl	~VerifyStream
	bcc	lb1
	lda	#EIO
	sta	>errno
	lda	#EOF
	bra	rts
lb1	lda	#put	set up output routine
	sta	>~putchar+4
	lda	#>put
	sta	>~putchar+5
	tsc		find the argument list address
	clc
	adc	#8
	sta	>args
	pea	0
	pha
	jsl	~printf	call the formatter
	sec		compute the space to pull from the stack
	pla
	sbc	>args
	clc
	adc	#4
	sta	>args
	pla
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	>args
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return

put	phb		remove the char from the stack
	phk
	plb
	plx
	pla
	ply
	pha
	phx
	plb
	lda	stream+2	write to a file
	pha
	lda	stream
	pha
	phy
	jsl	fputc
rts	rtl

args	ds	2	original argument address
stream	ds	4	stream address
	end

****************************************************************
*
*  int fputc(c, stream)
*	char c;
*	FILE *stream;
*
*  Write a character to a file
*
*  Inputs:
*	c - character to write
*	stream - file to write to
*
*  Outputs:
*	A - character written; EOF for an error
*
****************************************************************
*
fputc	start
putc	entry

c2	equ	5	output char
p	equ	1	work pointer

	csubroutine (2:c,4:stream),6

	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	bcs	lb0
	ldy	#FILE_flag	quit with error if the end of file
	lda	[stream],Y	 has been reached or an error has been
	and	#_IOEOF+_IOERR	 encountered
	beq	lb1
lb0	lda	#EOF
	sta	c
	brl	pc8

lb1	ldy	#FILE_flag	if the file is not prepared for
	lda	[stream],Y	 writing then
	bit	#_IOWRT
	bne	lb2
	bit	#_IOREAD	  if it is being read then
	bne	pc2	    flag the error
	ora	#_IOWRT	  set the writting flag
	sta	[stream],Y
lb2	ldy	#FILE_file	branch if this is a disk file
	lda	[stream],Y
	bpl	pc3

	cmp	#stdoutID	if stream = stdout then
	bne	pc1
	ph2	c	  write the character
	jsl	~stdout
	brl	pc8
pc1	cmp	#stderrID	else if stream = stderr then
	bne	pc2
	lda	c	  (for \n, write \r)
	cmp	#10
	bne	pc1a
	lda	#13
pc1a	pha		  write to error out
	jsl	SYSCHARERROUT
	brl	pc8
pc2	ph4	stream	else stream = stdin; flag the error
	jsr	~ioerror
	lda	#EOF
	sta	c
	brl	pc8

pc3	lda	c	set the output char
	sta	c2
	ldy	#FILE_flag	if this is a text file then
	lda	[stream],Y
	and	#_IOTEXT
	beq	pc3a
	lda	c	  if the char is lf then
	cmp	#10
	bne	pc3a
	lda	#13	    substitute a cr
	sta	c2
pc3a	ldy	#FILE_cnt	if the buffer is full then
	lda	[stream],Y
	iny
	iny
	ora	[stream],Y
	bne	pc4
pc3b	ldy	#FILE_flag	  purge it
	lda	[stream],Y
	pha
	ph4	stream
	jsl	fflush
	ldy	#FILE_flag
	pla
	sta	[stream],Y

pc4	ldy	#FILE_ptr	deposit the character in the buffer,
	lda	[stream],Y	 incrementing the buffer pointer
	sta	p
	clc
	adc	#1
	sta	[stream],Y
	iny
	iny
	lda	[stream],Y
	sta	p+2
	adc	#0
	sta	[stream],Y
	short M
	lda	c2
	sta	[p]
	long	M
	ldy	#FILE_cnt	dec the buffer counter
	sec
	lda	[stream],Y
	sbc	#1
	sta	[stream],Y
	bcs	pc5
	iny
	iny
	lda	[stream],Y
	dec	A
	sta	[stream],Y

pc5	ldy	#FILE_cnt	if the buffer is full
	lda	[stream],Y
	iny
	iny
	ora	[stream],Y
	beq	pc7
	lda	c2	  or if (c = '\n') and (flag & _IOLBF)
	cmp	#13
	beq	pc5a
	cmp	#10
	bne	pc6
pc5a	ldy	#FILE_flag
	lda	[stream],Y
	and	#_IOLBF
	bne	pc7
pc6	ldy	#FILE_flag	  or is flag & _IONBF then
	lda	[stream],Y
	and	#_IONBF
	beq	pc8
pc7	ldy	#FILE_flag	  flush the stream
	lda	[stream],Y
	pha
	ph4	stream
	jsl	fflush
	ldy	#FILE_flag
	pla
	sta	[stream],Y

pc8	creturn 2:c
	end

****************************************************************
*
*  int fputs(s,stream)
*     char *s;
*
*  Print the string to standard out.
*
****************************************************************
*
fputs	start
err	equ	1	return code

	csubroutine (4:s,4:stream),2

	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	lda	#EOF
	sta	err
	bcs	lb4
	stz	err	no error so far
	bra	lb2	skip initial increment
lb1	inc4	s	next char
lb2	ph4	stream	push the stream, just in case...
	lda	[s]	exit loop if at end of string
	and	#$00FF
	beq	lb3
	pha		push char to write
	jsl	fputc	write the character
	cmp	#EOF	loop if no error
	bne	lb1

	sta	err	set the error code
	bra	lb4

lb3	pla		remove stream from the stack
	pla
lb4	creturn 2:err
	end

****************************************************************
*
*  size_t fread(ptr, element_size, count, stream)
*	void *ptr;
*	size_t element_size;
*	size_t count;
*	FILE *stream;
*
*  Reads element*count bytes to stream, putting the bytes in
*  ptr.
*
*  Inputs:
*	ptr - location to store the bytes read
*	element_size - size of each element
*	count - number of elements
*	stream - file to read from
*
*  Outputs:
*	Returns the number of elements actually read.
*
****************************************************************
*
fread	start
temp	equ	1

	csubroutine (4:ptr,4:element_size,4:count,4:stream),4
	phb
	phk
	plb

	stz	rdTransferCount	set the # of elements read
	stz	rdTransferCount+2
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	lb6
	ph4	stream	reset file pointer
	jsl	~SetFilePointer
	mul4	element_size,count,rdRequestCount set the # of bytes
	lda	rdRequestCount	quit if the request count is 0
	ora	rdRequestCount+2
	jeq	lb6
	ldy	#FILE_file	set the file ID number
	lda	[stream],Y
	bpl	lb2	branch if it is a file

	cmp	#stdinID	if the file is stdin then
	jne	lb6
	stz	rdTransferCount
	stz	rdTransferCount+2
	lda	>stdin+4+FILE_flag
	and	#_IOEOF
	jne	lb6
lb1	jsl	SYSKEYIN	  read the bytes
	tax		  branch if not eof
	bne	lb1a
	lda	#_IOEOF	  set EOF flag
	ora	>stdin+4+FILE_flag
	sta	>stdin+4+FILE_flag
	jsl	SYSKEYIN	  read the closing cr
	brl	lb6
lb1a	short M	  set character
	sta	[ptr]
	long	M
	inc4	rdTransferCount
	inc4	ptr
	dec4	rdRequestCount
	lda	rdRequestCount
	ora	rdRequestCount+2
	bne	lb1
	bra	lb6

lb2	sta	rdRefNum	set the reference number
	move4 ptr,rdDataBuffer	set the start address
	OSRead rd	read the bytes
	bcc	lb5
	cmp	#$4C	if the error was $4C then
	bne	lb3
	jsr	SetEOF	  set the EOF flag
	bra	lb5
lb3	ph4	stream	I/O error
	jsr	~ioerror
!			set the # records read
lb5	div4	rdTransferCount,element_size
	lda	count	if there were too few elements read then
	cmp	rdTransferCount
	bne	lb5a
	lda	count+2
	cmp	rdTransferCount+2
	beq	lb6
lb5a	jsr	SetEOF	  set the EOF flag
lb6	move4 rdTransferCount,temp
	plb

	creturn 4:temp
;
;  Local data
;
rd	dc	i'5'	parameter block for OSRead
rdRefNum ds	2
rdDataBuffer ds 4
rdRequestCount ds 4
rdTransferCount ds 4
	dc	i'1'
;
;  Set the EOF flag
;
SetEOF	ldy	#FILE_flag	  set the eof flag
	lda	[stream],Y
	ora	#_IOEOF
	sta	[stream],Y
	rts
	end

****************************************************************
*
*  int fscanf(stream, format, additional arguments)
*     char *format;
*     FILE *stream;
*
*  Read a string from a string.
*
****************************************************************
*
fscanf	start
	using ~scanfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	stream
	pla
	sta	stream+2
	phy		restore return address/data bank
	phx
	plb

	ph4	>stream	verify that stream exists
	jsl	~VerifyStream
	bcc	lb1
	lda	#EOF
	rtl
lb1	lda	#get	set up our routines
	sta	>~getchar+10
	lda	#>get
	sta	>~getchar+11

	lda	#unget
	sta	>~putback+12
	lda	#>unget
	sta	>~putback+13

	brl	~scanf

get	ph4	stream	get a character
	jsl	fgetc
	rtl

unget	ldx	stream+2	put a character back
	phx
	ldx	stream
	phx
	pha
	jsl	ungetc
	rtl

stream	ds	4
	end

****************************************************************
*
*  int fseek(stream,offset,wherefrom)
*	FILE *stream;
*	long int offset;
*	int wherefrom;
*
*  Change the read/write location for the stream.
*
*  Inputs:
*	stream - file to change
*	offset - position to move to
*	wherefrom - move relative to this location
*
*  Outputs:
*	Returns non-zero for error
*
****************************************************************
*
fseek	start
	jmp	__fseek
	end

__fseek	start

err	equ	1	return value

	csubroutine (4:stream,4:offset,2:wherefrom),2
	phb
	phk
	plb

	lda	#-1	assume we will get an error
	sta	err
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rts
	ph4	stream	purge the file
	jsl	fflush
	ldy	#FILE_file	set the file reference
	lda	[stream],Y
	jmi	lb6
	sta	gpRefNum
	sta	spRefNum
	lda	wherefrom	if position is relative to the end then
	cmp	#SEEK_END
	bne	lb2
	OSGet_EOF gp	  get the eof
	jcs	erEIO
	add4	offset,gpPosition	  add it to the offset
	bra	lb3
lb2	cmp	#SEEK_CUR	else if relative to current position then
	bne	lb3
	ph4	stream	  get the current position
	jsl	ftell
	clc		  add it to the offset
	adc	offset
	sta	offset
	txa
	adc	offset+2
	sta	offset+2
lb3	OSGet_EOF gp	get the end of the file
	jcs	erEIO
	lda	offset+2	if the offset is >= EOF then
	cmp	gpPosition+2
	bne	lb4
	lda	offset
	cmp	gpPosition
lb4	ble	lb5
	move4 offset,spPosition	  extend the file
	OSSet_EOF sp
	bcs	erEIO
lb5	move4 offset,spPosition
	OSSet_Mark sp
	bcs	erEIO

lb6	ldy	#FILE_flag	clear the EOF , READ, WRITE flags
	lda	#$FFFF-_IOEOF-_IOREAD-_IOWRT
	and	[stream],Y
	sta	[stream],Y
	ldy	#FILE_cnt	clear the character count
	lda	#0
	sta	[stream],Y
	iny
	iny
	sta	[stream],Y
	ldy	#FILE_base+2	reset the file pointer
	lda	[stream],Y
	tax
	dey
	dey
	lda	[stream],Y
	ldy	#FILE_ptr
	sta	[stream],Y
	iny
	iny
	txa
	sta	[stream],Y
	ldy	#FILE_pbk	nothing in the putback buffer
	lda	#$FFFF
	sta	[stream],Y
	ldy	#FILE_pbk+2
	sta	[stream],Y

	stz	err
rts	plb
	creturn 2:err

erEIO	ph4	stream	flag an IO error
	jsr	~ioerror
	bra	rts

gp	dc	i'2'	parameter block for OSGet_EOF
gpRefNum ds	2
gpPosition ds	4

sp	dc	i'3'	parameter block for OSSet_EOF
spRefNum ds	2	 and OSSet_Mark
	dc	i'0'
spPosition ds	4
	end

****************************************************************
*
*  int fsetpos(FILE *stream, fpos_t *pos);
*
*  Inputs:
*	stream - pointer to stream to set position of
*	pos - pointer to location to set position
*
*  Outputs:
*	A - 0 if successful; else -1 if not
*	errno - if unsuccessful, errno is set to EIO
*
****************************************************************
*
fsetpos	start
err	equ	1	error code

	csubroutine (4:stream,4:pos),2

	ph2	#SEEK_SET
	ldy	#2
	lda	[pos],Y
	pha
	lda	[pos]
	pha
	ph4	stream
	jsl	fseek
	sta	err

	creturn 2:err
	end

****************************************************************
*
*  long int ftell(stream)
*	FILE *stream;
*
*  Find the number of characters already passed in the file.
*
*  Inputs:
*	stream - strem to find the location in
*
*  Outputs:
*	Returns the position, or -1L for an error.
*
****************************************************************
*
ftell	start

pos	equ	1	position in the file

	csubroutine (4:stream),4
	phb
	phk
	plb

	lda	#-1	assume an error
	sta	pos
	sta	pos+2
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rts
	ldy	#FILE_flag	if the file is being written then
	lda	[stream],Y
	bit	#_IOWRT
	beq	lb0
	ph4	stream	  do any pending writes
	jsl	fflush
	tax
	bne	rts
lb0	ldy	#FILE_file	get the file's mark
	lda	[stream],Y
	sta	gmRefNum
	OSGet_Mark gm
	bcc	lb1
	ph4	stream
	jsr	~ioerror
	bra	rts

lb1	move4 gmPosition,pos	set the position
	ldy	#FILE_flag	if the file is being read then
	lda	[stream],Y
	bit	#_IOREAD
	beq	rts
	sec		  subtract off characters left to be
	ldy	#FILE_cnt	    read
	lda	pos
	sbc	[stream],Y
	sta	pos
	iny
	iny
	lda	pos+2
	sbc	[stream],Y
	sta	pos+2
	ldy	#FILE_pbk	  dec pos by 1 for each char in the
	lda	[stream],Y	    putback buffer then
	bmi	lb2
	dec4	pos
	ldy	#FILE_pbk+2
	lda	[stream],Y
	bmi	lb2
	dec4	pos
lb2	ldy	#FILE_file	  set the file's mark
	lda	[stream],Y
	sta	spRefNum
	move4	pos,spPosition
	OSSet_Mark sp

rts	plb
	creturn 4:pos

sp	dc	i'3'	parameter block for OSSet_Mark
spRefNum ds	2
	dc	i'0'
spPosition ds	4

gm	dc	i'2'	parameter block for OSGetMark
gmRefNum ds	2
gmPosition ds	4
	end

****************************************************************
*
*  size_t fwrite(ptr, element_size, count, stream)
*	void *ptr;
*	size_t element_size;
*	size_t count;
*	FILE *stream;
*
*  Writes element*count bytes to stream, taking the bytes from
*  ptr.
*
*  Inputs:
*	ptr - pointer to the bytes to write
*	element_size - size of each element
*	count - number of elements
*	stream - file to write to
*
*  Outputs:
*	Returns the number of elements actually written.
*
****************************************************************
*
fwrite	start

	csubroutine (4:ptr,4:element_size,4:count,4:stream),0
	phb
	phk
	plb

	stz	wrTransferCount	set the # of elements written
	stz	wrTransferCount+2
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	lb6
	mul4	element_size,count,wrRequestCount set the # of bytes
	lda	wrRequestCount	quit if the request count is 0
	ora	wrRequestCount+2
	jeq	lb6
	ldy	#FILE_file	set the file ID number
	lda	[stream],Y
	bpl	lb4	branch if it is a file

	cmp	#stdoutID	if the file is stdout then
	bne	lb2
lb1	lda	[ptr]	  write the bytes
	pha
	jsl	~stdout
	inc4	ptr
	dec4	wrRequestCount
	lda	wrRequestCount
	ora	wrRequestCount+2
	bne	lb1
	move4 count,wrTransferCount	set the # of elements written
	bra	lb6

lb2	cmp	#stderrID	if the file is stderr then
	bne	lb6
lb3	lda	[ptr]	  write the bytes
	pha
	jsl	SYSCHARERROUT
	inc4	ptr
	dec4	wrRequestCount
	lda	wrRequestCount
	ora	wrRequestCount+2
	bne	lb3
	move4 count,wrTransferCount	set the # of elements written
	bra	lb6

lb4	sta	wrRefNum	set the reference number
	ph4	stream	purge the file
	jsl	fflush
	move4 ptr,wrDataBuffer	set the start address
	OSWrite wr	write the bytes
	bcc	lb5
	ph4	stream	I/O error
	jsr	~ioerror
!			set the # records written
lb5	div4	wrTransferCount,element_size,count
lb6	plb
	creturn 4:count	return

wr	dc	i'4'	parameter block for OSWrite
wrRefNum ds	2
wrDataBuffer ds 4
wrRequestCount ds 4
wrTransferCount ds 4
	end

****************************************************************
*
*  int getchar()
*
*  Read a character from standard in.  No errors are possible.
*
*  The character read is returned in A.	 The null character
*  is mapped into EOF.
*
****************************************************************
*
getchar	start
;
;  Determine which method to use
;
	lda	>stdin	use fgetc if stdin has changed
	cmp	#stdin+4
	bne	fl1
	lda	>stdin+2
	cmp	#^stdin+4
	bne	fl1
	lda	>stdin+4+FILE_file	use fgetc if stdio has a bogus file ID
	cmp	#stdinID
	bne	fl1
;
;  get the char from the keyboard
;
	lda	>stdin+4+FILE_pbk	if there is a char in the putback
	bmi	lb1	 buffer then
	and	#$00FF	  save it in X
	tax
	lda	>stdin+4+FILE_pbk+2	  pop the buffer
	sta	>stdin+4+FILE_pbk
	lda	#$FFFF
	sta	>stdin+4+FILE_pbk+2
	txa		  restore the char
	bra	lb2

lb1	jsl	SYSKEYIN	else get a char from the keyboard
	tax		  branch if not eof
	bne	lb2
	lda	#_IOEOF	  set EOF flag
	ora	>stdin+4+FILE_flag
	sta	>stdin+4+FILE_flag
	jsl	SYSKEYIN	  read the closing cr
	lda	#EOF	  return EOF
lb2	cmp	#13	if the char is \r then
	bne	lb3
	lda	#10	  return \n
lb3	rtl
;
;  Call fgetc
;
fl1	ph4	>stdin
	dc	i1'$22',s3'fgetc'	jsl   fgetc
	rtl
	end

****************************************************************
*
*  char *gets(s)
*	char s;
*
*  Read a line from standard in.
*
*  Inputs:
*	s - string to read to.
*
*  Outputs:
*	Returns a pointer to the string
*
****************************************************************
*
gets	start
LF	equ	10	\n key code

disp	equ	1	disp in s

	csubroutine (4:s),2

	stz	disp	no characters processed so far
lb1	jsl	getchar	get a character
	tax		quit with error if it is an EOF
	bpl	lb2
	stz	s
	stz	s+2
	bra	rts
lb2	cmp	#LF	quit if it was a \n
	beq	lb3
	ldy	disp	place the char in the string
	sta	[s],Y
	inc	disp
	bra	lb1	next character
lb3	ldy	disp	null terminate
	short	M
	lda	#0
	sta	[s],Y
	long	M

rts	creturn 4:s
	end

****************************************************************
*
*  void perror(s);
*	char *s;
*
*  Prints the string s and the error in errno to standard out.
*
****************************************************************
*
perror	start
maxErr	equ	ENOSPC	max error in sys_errlist

s	equ	4	string address

	tsc		set up DP addressing
	phd
	tcd

	ph4	>stderr	write the error string
	ph4	s
	jsl	fputs
	ph4	>stderr	write ': '
	pea	':'
	jsl	fputc
	ph4	>stderr
	pea	' '
	jsl	fputc
	ph4	>stderr	write the error message
	lda	>errno
	cmp	#maxErr+1
	blt	lb1
	lda	#0
lb1	asl	A
	asl	A
	tax
	lda	>sys_errlist+2,X
	pha
	lda	>sys_errlist,X
	pha
	jsl	fputs
	ph4	>stderr	write lf, cr
	pea	10
	jsl	fputc
	ph4	>stderr
	pea	13
	jsl	fputc

	pld		remove parm and return
	lda	2,S
	sta	6,S
	pla
	sta	3,S
	pla
	rtl
	end

****************************************************************
*
*  int printf(format, additional arguments)
*     char *format;
*
*  Print the format string to standard out.
*
****************************************************************
*
printf	start
	using ~printfCommon

	lda	#putchar
	sta	>~putchar+4
	lda	#>putchar
	sta	>~putchar+5
	tsc		find the argument list address
	clc
	adc	#8
	sta	>args
	pea	0
	pha   
	jsl	~printf	call the formatter
	sec		compute the space to pull from the stack
	pla
	sbc	>args
	clc
	adc	#4
	sta	>args
	pla
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	>args
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return

args	ds	2	original argument address
	end	

****************************************************************
*
*  int putchar(c)
*     char c;
*
*  Print the character to standard out.	 The character is
*  returned.  No errors are possible.
*
*  The character \n is automatically followed by a $0D, which
*  causes the IIGS to respond the way \n works on other machines.
*
****************************************************************
*
putchar	start
	using ~printfCommon
_n	equ	10	linefeed character
_r	equ	13	RETURN key code
;
;  Determine which method to use
;
	lda	>stdout	use fgetc if stdin has changed
	cmp	#stdout+4
	bne	fl1
	lda	>stdout+1
	cmp	#>stdout+4
	bne	fl1
	lda	>stdout+4+FILE_file	use fgetc if stdio has a bogus file ID
	cmp	#stdoutID
	bne	fl1
;
;  Write to the CRT
;
~stdout	entry
	php		remove the parameter from the stack
	plx
	ply
	pla
	phy
	phx
	plp
	pha		save the parameter
	cmp	#_n	if this is a line feed, do a
	bne	lb1	 carriage return, instead.
	lda	#_r
lb1	pha   	write the character
	jsl   SYSCHAROUT
	pla		return the input character
	rtl
;
;  Use fputc
;
fl1	ph4	>stdout
	lda	8,S
	pha
	dc	i1'$22'	jsl   fputc
	dc	s3'fputc'
	phb
	plx
	ply
	pla
	phy
	phx
	plb
	rtl
	end

****************************************************************
*
*  int puts(s)
*     char *s;
*
*  Print the string to standard out.  A zero is returned; no
*  error is possible.
*
****************************************************************
*
puts	start
LINEFEED equ	10	linefeed character

err	equ	1	erro code

	csubroutine (4:s),2

	stz	err	no error
lb1	lda	[s]	print the string
	and	#$00FF
	beq	lb2
	pha
	jsl	putchar
	inc4	s
	bra	lb1
lb2	pea	LINEFEED	print the linefeed
	jsl	putchar

	creturn 2:err
	end

****************************************************************
*
*  int remove(filename)
*	char *filename;
*
*  Inputs:
*	filename - name of the file to delete
*
*  Outputs:
*	Returns zero if successful, GS/OS error code if not.
*
****************************************************************
*
remove	start
err	equ	1	return code

	csubroutine (4:filename),2
	phb
	phk
	plb

	ph4	filename	convert to a GS/OS file name
	jsl	~osname
	sta	dsPathName
	stx	dsPathName+2
	ora	dsPathName+2
	bne	lb1
	lda	#$FFFF
	sta	err
	bra	lb2
lb1	OSDestroy ds	delete the file
	sta	err	set the error code
	bcc	lb1a
	lda	#ENOENT
	sta	>errno
lb1a	ph4	dsPathName	dispose of the name buffer
	jsl	free

lb2	plb
	creturn 2:err

ds	dc	i'1'	parameter block for OSDestroy
dsPathName ds	4
	end

****************************************************************
*
*  int rename(oldname,newname)
*	char *filename;
*
*  Inputs:
*	filename - name of the file to delete
*
*  Outputs:
*	Returns zero if successful, GS/OS error code if not.
*
****************************************************************
*
rename	start
err	equ	1	return code

	csubroutine (4:oldname,4:newname),2
	phb
	phk
	plb

	ph4	oldname	convert oldname to a GS/OS file name
	jsl	~osname
	sta	cpPathName
	stx	cpPathName+2
	ora	cpPathName+2
	bne	lb1
	lda	#$FFFF
	sta	err
	bra	lb4
lb1	ph4	newname	convert newname to a GS/OS file name
	jsl	~osname
	sta	cpNewPathName
	stx	cpNewPathName+2
	ora	cpNewPathName+2
	bne	lb2
	lda	#$FFFF
	sta	err
	bra	lb3
lb2	OSChange_Path cp	rename the file
	sta	err	set the error code
	ph4	cpNewPathName	dispose of the new name buffer
	jsl	free
lb3	ph4	cpPathName	dispose of the old name buffer
	jsl	free

lb4	plb
	creturn 2:err

cp	dc	i'2'	parameter block for OSChange_Path
cpPathName ds	4
cpNewPathName ds 4
	end

****************************************************************
*
*  int rewind(stream)
*	FILE *stream;
*
*  Change the read/write location for the stream.
*
*  Inputs:
*	stream - file to change
*
*  Outputs:
*	Returns non-zero for error
*
****************************************************************
*
rewind	start
err	equ	1	return code

	csubroutine (4:stream),2

	ph2	#SEEK_SET
	ph4	#0
	ph4	stream
	jsl	__fseek
	sta	err

	creturn 2:err
	end

****************************************************************
*
*  int scanf(format, additional arguments)
*     char *format;
*
*  Read a string from standard in.
*
****************************************************************
*
scanf	start
	using ~scanfCommon

	lda	#getchar
	sta	>~getchar+10
	lda	#>getchar
	sta	>~getchar+11

	lda	#unget
	sta	>~putback+12
	lda	#>unget
	sta	>~putback+13

	brl	~scanf

unget	tax
	lda	>stdin+2
	pha
	lda	>stdin
	pha
	phx
	jsl	ungetc
	rtl
	end

****************************************************************
*
*  int setbuf (FILE *stream, char *)
*
*  Set the buffer type and size.
*
*  Inputs:
*	stream - file to set the buffer for
*	buf - buffer to use, or NULL for automatic buffer
*
*  Outputs:
*	Returns zero if successful, -1 for an error
*
****************************************************************
*
setbuf	start
err	equ	1	return code

	csubroutine (4:stream,4:buf),2

	lda	buf
	ora	buf+2
	bne	lb1
	ph4	#0
	ph2	#_IONBF
	bra	lb2
lb1	ph4	#BUFSIZ
	ph2	#_IOFBF
lb2	ph4	buf
	ph4	stream
	jsl	__setvbuf
	sta	err

	creturn 2:err
	end

****************************************************************
*
*  int setvbuf(stream,buf,type,size)
*	FILE *stream;
*	char *buf;
*	int type,size;
*
*  Set the buffer type and size.
*
*  Inputs:
*	stream - file to set the buffer for
*	buf - buffer to use, or NULL for automatic buffer
*	type - buffer type; _IOFBF, _IOLBF or _IONBF
*	size - size of the buffer
*
*  Outputs:
*	Returns zero if successful, -1 for an error
*
****************************************************************
*
setvbuf	start
	jmp	__setvbuf
	end

__setvbuf start
err	equ	1	return code

	csubroutine (4:stream,4:buf,2:type,4:size),2

	phb
	phk
	plb
	lda	#-1	assume we will get an error
	sta	err
	ph4	stream	verify that stream exists
	jsl	~VerifyStream
	jcs	rts
	ldy	#FILE_ptr	make sure the buffer is not in use
	lda	[stream],Y
	ldy	#FILE_base
	cmp	[stream],Y
	jne	rts
	ldy	#FILE_ptr+2
	lda	[stream],Y
	ldy	#FILE_base+2
	cmp	[stream],Y
	jne	rts
cb1	lda	size	if size is zero then
	ora	size+2
	bne	lb1
	lda	type	  if ~(type & _IONBF) then
	and	#_IONBF
	jeq	rts	    flag the error
	inc	size	  else size = 1
lb1	lda	type	error if type is not one of these
	cmp	#_IOFBF
	beq	lb2
	cmp	#_IOLBF
	beq	lb2
	cmp	#_IONBF
	bne	rts
lb2	lda	buf	if the buffer is not supplied by the
	ora	buf+2	  caller then
	bne	sb1
	ph4	size	  allocate a buffer
	jsl	malloc
	sta	buf
	stx	buf+2
	ora	buf+2	  quit if there was no memory
	beq	rts
	lda	type	  set the buffer flag
	ora	#_IOMYBUF
	sta	type

sb1	ldy	#FILE_flag	if the buffer was allocated by fopen then
	lda	[stream],Y
	bit	#_IOMYBUF
	beq	sb2
	ldy	#FILE_base+2	  dispose of the old buffer
	lda	[stream],Y
	pha
	dey
	dey
	lda	[stream],Y
	pha
	jsl	free
sb2	ldy	#FILE_flag	clear the old buffering flags
	lda	#$FFFF-_IOFBF-_IOLBF-_IONBF-_IOMYBUF
	and	[stream],Y
	ora	type	set the new buffer flag
	sta	[stream],Y

	lda	buf	set the start of the buffer
	ldy	#FILE_base
	sta	[stream],Y
	iny
	iny
	lda	buf+2
	sta	[stream],Y
	ldy	#FILE_ptr+2
	sta	[stream],Y
	dey
	dey
	lda	buf
	sta	[stream],Y
	ldy	#FILE_size	set the buffer size
	lda	size
	sta	[stream],Y
	iny
	iny
	lda	size+2
	sta	[stream],Y
	ldy	#FILE_cnt	no chars in buffer
	lda	#0
	sta	[stream],Y
	iny
	iny
	sta	[stream],Y
	stz	err	no error

rts	plb
	creturn 2:err
	end

****************************************************************
*
*  int sprintf(s, format, additional arguments)
*     char *format;
*
*  Print the format string to a string.
*
****************************************************************
*
sprintf	start
	using ~printfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	string
	pla
	sta	string+2
	phy		restore return address/data bank
	phx
	plb
	lda	#put	set up output routine
	sta	>~putchar+4
	lda	#>put
	sta	>~putchar+5

	tsc		find the argument list address
	clc
	adc	#8
	sta	>args
	pea	0
	pha   
	jsl	~printf	call the formatter
	sec		compute the space to pull from the stack
	pla
	sbc	>args
	clc
	adc	#4
	sta	>args
	pla
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	>args
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return
		
put	phb		remove the char from the stack
	plx
	pla
	ply
	pha
	phx
	plb
	ldx	string+2	write to a file
	phx
	ldx	string
	phx
	phd
	tsc
	tcd
	tya
	and	#$00FF
	sta	[3]
	pld
	pla
	pla
	phb
	phk
	plb
	inc4	string
	plb
	rtl

args	ds	2	original argument address
string	ds	4	string address
	end

****************************************************************
*
*  int sscanf(s, format, additional arguments)
*     char *s, *format;
*
*  Read a string from a string.
*
****************************************************************
*
sscanf	start
	using ~scanfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	string
	pla
	sta	string+2
	phy		restore return address/data bank
	phx
	plb

	lda	#get	set up our routines
	sta	>~getchar+10
	lda	#>get
	sta	>~getchar+11

	lda	#unget
	sta	>~putback+12
	lda	#>unget
	sta	>~putback+13

	brl	~scanf

get	ph4	string	get a character
	phd
	tsc
	tcd
	lda	[3]
	and	#$00FF
	bne	gt1
	dec4	string
	lda	#EOF
gt1	pld
	ply
	ply
	inc4	string
	rtl

unget	cmp	#EOF	put a character back
	beq	ug1
	dec4	string
ug1	rtl

string	ds	4
	end

****************************************************************
*
*  sys_errlist - array of pointers to messages
*
****************************************************************
*
sys_errlist start
	dc	a4'EUNDEF'	0th message is undefined
	dc	a4'EDOM'	(if the size of this list changes,
	dc	a4'ERANGE'	 change sys_nerr in VARS.ASM)
	dc	a4'ENOMEM'
	dc	a4'ENOENT'
	dc	a4'EIO'
	dc	a4'EINVAL'
	dc	a4'EBADF'
	dc	a4'EMFILE'
	dc	a4'EACCESS'
	dc	a4'EEXISTS'
	dc	a4'ENOSPC'

! Note: if more errors are added, change maxErr in perror().

EUNDEF	cstr	'invalid error number'
EDOM	cstr	'domain error'
ERANGE	cstr	'# too large, too small, or illegal'
ENOMEM	cstr	'not enough memory'
ENOENT	cstr	'no such file or directory'
EIO	cstr	'I/O error'
EINVAL	cstr	'invalid argument'
EBADF	cstr	'bad file descriptor'
EMFILE	cstr	'too many files are open'
EACCESS	cstr	'access bits prevent the operation'
EEXISTS	cstr	'the file exists'
ENOSPC	cstr	'the file is too large'
	end

****************************************************************
*
*  char *tmpnam(buf)
*	char *buf;
*
*  Inputs:
*	buf - Buffer to write the name to.  Buf is assumed to
*		be at least L_tmpnam characters long.  It may be
*		NULL, in which case the name is not written to
*		a buffer.
*
*  Outputs:
*	Returns a pointer to the name, which is changed on the
*	next call to tmpnam or tmpfile.
*
*  Notes:
*	If the work prefix is set, and is less than or equal
*	to 15 characters in length, the file name returned is
*	in the work prefix (3); otherwise, it is a partial path
*	name.
*
****************************************************************
*
tmpnam	start

	csubroutine (4:buf),0
	phb
	phk
	plb

lb1	OSGet_Prefix pr	get the prefix
	bcc	lb2
	stz	name+2
lb2	short M
	ldx	name+2
	stz	cname,X
	ldx	#7	update the file number
lb3	inc	syscxxxx,X
	lda	syscxxxx,X
	cmp	#'9'+1
	bne	lb4
	lda	#'0'
	sta	syscxxxx,X
	dex
	cpx	#3
	bne	lb3
lb4	long	M	append the two strings
	ph4	#syscxxxx
	ph4	#cname
	jsl	strcat

	ph4	#cname	if the file exists then
	jsl	strlen
	sta	name+2
	OSGet_File_Info GIParm
	bcc	lb1	   get a different name

	lda	buf	if buf != NULL then
	ora	buf+2
	beq	lb5
	ph4	#cname	   move the string
	ph4	buf
	jsl	strcpy

lb5	lla	buf,cname	return the string pointer
	plb
	creturn 4:buf

pr	dc	i'2'	parameter block for OSGet_Prefix
	dc	i'3'
	dc	a4'name'

name	dc	i'16,0'	GS/OS name buffer
cname	ds	26	part of name; also C buffer
GS_OSname dc	i'8'	used for OSGet_File_Info
syscxxxx dc	c'SYSC0000',i1'0'	for creating unique names

GIParm	dc	i'2'	used to see if the file exists
	dc	a4'name+2'
	dc	i'0'
	end

****************************************************************
*
*  FILE *tmpfile()
*
*  Outputs:
*	Returns a pointer to a temp file; NULL for error.
*
****************************************************************
*
tmpfile	start
f	equ	1	file pointer

	csubroutine ,4

	ph4	#type	open a file with a temp name
	ph4	#0
	jsl	tmpnam
	phx
	pha
	jsl	fopen
	sta	f
	stx	f+2
	ora	f+2	if sucessful then
	beq	lb1
	ldy	#FILE_flag	  f->_flag |= _IOTEMPFILE
	lda	[f],Y
	ora	#_IOTEMPFILE
	sta	[f],Y
	
lb1	creturn 4:f

type	cstr	'w+b'
	end

****************************************************************
*
*  int ungetc(c, stream)
*	char c;
*	FILE *stream;
*
*  Return a character to the input stream.
*
*  Inputs:
*	c - character to return
*	stream - stream to put it back in
*
*  Outputs:
*	Returns EOF if the attempt was unsuccessful; c if the
*	attempt succeeded.
*
****************************************************************
*
ungetc	start

char	equ	1	characater to return

	csubroutine (2:c,4:stream),2

	lda	#EOF	assume we will fail
	sta	char
	ldy	#FILE_flag	error if the file is open for output
	lda	[stream],Y
	bit	#_IOWRT
	bne	rts
	lda	c	error if EOF is pushed
	cmp	#EOF
	beq	rts
	ldy	#FILE_pbk+2	error if the buffer is full
	lda	[stream],Y
	bpl	rts
	ldy	#FILE_pbk	push the old character (if any)
	lda	[stream],Y
	ldy	#FILE_pbk+2
	sta	[stream],Y
	ldy	#FILE_pbk	put back the character
	lda	c
	and	#$00FF
	sta	[stream],Y
	sta	char
rts	long	M
	creturn 2:char
	end

****************************************************************
*
*  int vfprintf(stream, char *format, va_list arg)
*
*  Print the format string to standard out.
*
****************************************************************
*
vfprintf	start
	using ~printfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	stream
	pla
	sta	stream+2
	phy		restore return address/data bank
	phx
	plb
	lda	>stream+2	verify that stream exists
	pha
	lda	>stream
	pha
	jsl	~VerifyStream
	bcc	lb1
	lda	#EIO
	sta	>errno
	lda	#EOF
	bra	rts
lb1	lda	#put	set up output routine
	sta	>~putchar+4
	lda	#>put
	sta	>~putchar+5
	phd		find the argument list address
	tsc
	tcd
	lda	[10]
	pld
	pea	0
	pha   
	jsl	~printf	call the formatter
	ply		update the argument list pointer
	plx
	phd
	tsc
	tcd
	tya
	sta	[10]
	pld
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	#8
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return

put	phb		remove the char from the stack
	phk
	plb
	plx
	pla
	ply
	pha
	phx
	plb
	lda	stream+2	write to a file
	pha
	lda	stream
	pha
	phy
	jsl	fputc
rts	rtl

stream	ds	4	stream address
	end

****************************************************************
*
*  int vprintf (const char *format, va_list arg)
*
*  Print the format string to standard out.
*
****************************************************************
*
vprintf	start
	using ~printfCommon

	lda	#putchar	set up the output hooks
	sta	>~putchar+4
	lda	#>putchar
	sta	>~putchar+5
	phd		find the argument list address
	tsc
	tcd
	lda	[10]
	pld
	pea	0
	pha   
	jsl	~printf	call the formatter
	ply		update the argument list pointer
	plx
	phd
	tsc
	tcd
	tya
	sta	[10]
	pld
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	#8
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return
	end	

****************************************************************
*
*  int vsprintf(char *s, char *format, va_list arg)
*
*  Print the format string to a string.
*
****************************************************************
*
vsprintf	start
	using ~printfCommon

	phb		use local addressing
	phk
	plb
	plx		remove the return address
	ply
	pla		save the stream
	sta	string
	pla
	sta	string+2
	phy		restore return address/data bank
	phx
	plb
	lda	#put	set up output routine
	sta	>~putchar+4
	lda	#>put
	sta	>~putchar+5

	phd		find the argument list address
	tsc
	tcd
	lda	[10]
	pld
	pea	0
	pha   
	jsl	~printf	call the formatter
	ply		update the argument list pointer
	plx
	phd
	tsc
	tcd
	tya
	sta	[10]
	pld
	phb		remove the return address
	plx
	ply
	tsc		update the stack pointer
	clc
	adc	#8
	tcs
	phy		restore the return address
	phx
	plb
	lda	>~numChars	return the value
	rtl		return
		
put	phb		remove the char from the stack
	plx
	pla
	ply
	pha
	phx
	plb
	ldx	string+2	write to a file
	phx
	ldx	string
	phx
	phd
	tsc
	tcd
	tya
	and	#$00FF
	sta	[3]
	pld
	pla
	pla
	phb
	phk
	plb
	inc4	string
	plb
	rtl

string	ds	4	string address
	end

****************************************************************
*
*  ~Format_c - format a '%' character
*
*  Inputs:
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*
****************************************************************
*
~Format_c private
	using ~printfCommon
argp	equ	7	argument pointer

	dec	~fieldWidth	account for the width of the value
	jsr	~RightJustify	handle right justification
	lda	[argp]	print the character
	pha
	jsl	~putchar
	inc	argp	remove the parameter from the stack
	inc	argp
	brl	~LeftJustify	handle left justification
	end

****************************************************************
*
*  ~Format_d - format a signed decimal number
*  ~Format_u - format an unsigned decimal number
*
*  Inputs:
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*	~isLong - is the operand long?
*	~precision - precision of output
*	~precisionSpecified - was the precision specified?
*	~sign - char to use for positive sign
*
*  Note: The ~Format_IntOut entry point is used by other number
*  formatting routines to write their number strings.
*
****************************************************************
*
~Format_d private
	using ~printfCommon
argp	equ	7	argument pointer
;
;  For signed numbers, if the value is negative, use the sign flag
;
	lda	~isLong	handle long values
	beq	sn1
	ldy	#2
	lda	[argp],Y
	bpl	cn0
	sec
	lda	#0
	sbc	[argp]
	sta	[argp]
	lda	#0
	sbc	[argp],Y
	sta	[argp],Y
	bra	sn2
sn1	lda	[argp]	handle int values
	bpl	cn0
	eor	#$FFFF
	inc	a
	sta	[argp]
sn2	lda	#'-'
	sta	~sign

~Format_u entry
;
;  Convert the number to an ASCII string
;
cn0	stz	~hexPrefix	don't lead with 0x
	lda	~isLong	if the value is long then
	beq	cn1
	ldy	#2	  push a long value
	lda	[argp],Y
	pha
!	lda	[argp]
!	pha
!	bra	cn2	else
cn1	lda	[argp]	  push an int value
	pha
cn2	ph4	#~str	push the string addr
	ph2	#l:~str	push the string buffer length
	ph2	#0	do an unsigned conversion
	lda	~isLong	do the proper conversion
	beq	cn3
	_Long2Dec
	bra	pd1
cn3	_Int2Dec
;
;  Padd with the proper number of zeros
;
~Format_IntOut entry
pd1	lda	~precisionSpecified	if the precision was not specified then
	bne	pd2
	lda	#1	  use a precision of 1
	sta	~precision
pd2	ldx	~precision	if the precision is zero then
	bne	pd2a
	lda	~str+l:~str-2	  if the result is ' 0' then
	cmp	#'0 '
	bne	dp0
	lda	#'  '	    set the result to the null string
	sta	~str+l:~str-2
	stz	~hexPrefix	    erase any hex prefix
	bra	dp0
pd2a	ldy	#0	skip leading blanks
	short M
	lda	#' '
pd3	cmp	~str,Y
	bne	pd4
	iny
	cpy	#l:~str
	bne	pd3
	bra	pd6
pd4	cmp	~str,Y	deduct any characters from the precision
	beq	pd5
	dex
	beq	pd5
	iny
	cpy	#l:~str
	bne	pd4
pd5	stx	~precision
pd6	long	M
;
;  Determine the padding and do left padding
;
dp0	sub2	~fieldWidth,~precision	subtract off any remaining 0 padds
	lda	~sign	if the sign is non-zero, allow for it
	beq	dp1
	dec	~fieldWidth
dp1	lda	~hexPrefix	if there is a hex prefix, allow for it
	beq	dp1a
	dec	~fieldWidth
	dec	~fieldWidth
dp1a	ldx	#0	determine the length of the buffer
	ldy	#l:~str-1
	short M
	lda	#' '
dp2	cmp	~str,Y
	beq	dp3
	inx
	dey
	bpl	dp2
dp3	long	M
	sec		subtract it from ~fieldWidth
	txa
	sbc	~fieldWidth
	eor	#$FFFF
	inc	a
	sta	~fieldWidth
	lda	~paddChar	skip justification if we are padding
	cmp	#'0'
	beq	pn0
	jsr	~RightJustify	  handle right justification
;
;  Print the number
;
pn0	lda	~sign	if there is a sign character then
	beq	pn1
	pha		  print it
	jsl	~putchar
pn1	lda	~hexPrefix	if there is a hex prefix then
	beq	pn1a
	pha		  print it
	jsl	~putchar
	ph2	~hexPrefix+1
	jsl	~putchar
pn1a	lda	~paddChar	if the number needs 0 padding then
	cmp	#'0'
	bne	pn1c
	lda	~fieldWidth
	bmi	pn1c
	beq	pn1c
pn1b	ph2	~paddChar	  print padd zeros
	jsl	~putchar
	dec	~fieldWidth
	bne	pn1b
pn1c	lda	~precision	if the number needs more padding then
	beq	pn3
pn2	ph2	#'0'	  print padd characters
	jsl	~putchar
	dec	~precision
	bne	pn2
pn3	ldy	#-1	skip leading blanks in the number
pn4	iny
	lda	~str,Y
	and	#$00FF
	cmp	#' '
	beq	pn4

pn5	cpy	#l:~str	quit if we're at the end of the ~str
	beq	rn1
	phy		save Y
	lda	~str,Y	print the character
	and	#$00FF
	pha
	jsl	~putchar
	ply		next character
	iny
	bra	pn5
;
;  remove the number from the argument list
;
rn1	lda	~isLong
	beq	rn2
	inc	argp
	inc	argp
rn2	inc	argp
	inc	argp
;
;  Handle left justification
;
	brl	~LeftJustify	handle left justification
	end

****************************************************************
*
*  ~Format_n - return the number of characters printed
*
*  Inputs:
*	~numChars - characters written
*	~isLong - is the operand long?
*
****************************************************************
*
~Format_n private
	using ~printfCommon
argp	equ	7	argument pointer

	ph4	argp	save the original argp
	ldy	#2	dereference argp
	lda	[argp],Y
	tax
	lda	[argp]
	sta	argp
	stx	argp+2
	lda	~numChars	return the value
	sta	[argp]
	lda	~isLong	if long, set the high word
	beq	lb1
	ldy	#2
	lda	#0
	sta	[argp],Y
lb1	clc		restore the original argp+4
	pla
	adc	#4
	sta	argp
	pla
	sta	argp+2
	rts
	end

****************************************************************
*
*  ~Format_o - format an octal number
*
*  Inputs:
*	~altForm - use a leading '0'?
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*	~isLong - is the operand long?
*	~precision - precision of output
*	~precisionSpecified - was the precision specified?
*
****************************************************************
*
~Format_o private
	using ~printfCommon
argp	equ	7	argument pointer
;
;  Initialization
;
	stz	~sign	ignore the sign flag
	lda	#'  '	initialize the string to blanks
	sta	~str
	move	~str,~str+1,#l:~str-1
	stz	~num+2	get the value to convert
	lda	~isLong
	beq	cn2
	ldy	#2
	lda	[argp],Y
	sta	~num+2
cn2	lda	[argp]
	sta	~num
;
;  Convert the number to an ASCII string
;
	short I,M
	ldy	#l:~str-1	set up the character index
cn3	lda	~num+3	quit if the number is zero
	ora	~num+2
	ora	~num+1
	ora	~num
	beq	al1
	lda	#0	roll off 3 bits
	ldx	#3
cn4	lsr	~num+3
	ror	~num+2
	ror	~num+1
	ror	~num
	ror	A
	dex
	bne	cn4
	lsr	A	form a character
	lsr	A
	lsr	A
	lsr	A
	lsr	A
	ora	#'0'
	sta	~str,Y	save the character
	dey
	bra	cn3
;
;  If a leading zero is required, be sure we include one
;
al1	cpy	#l:~str-1	include a zero if no characters have
	beq	al2	 been placed in the string
	lda	~altForm	branch if no leading zero is required
	beq	al3
al2	lda	#'0'
	sta	~str,Y
al3	long	I,M
;
;  Piggy back off of ~Format_d for output
;
	stz	~hexPrefix	don't lead with 0x
	brl	~Format_IntOut
	end

****************************************************************
*
*  ~Format_s - format a c-string
*  ~Format_b - format a p-string
*
*  Inputs:
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*
****************************************************************
*
~Format_s private
	using ~printfCommon
argp	equ	7	argument pointer

	ph4	argp	save the original argp
	ldy	#2	dereference argp
	lda	[argp],Y
	tax
	lda	[argp]
	sta	argp
	stx	argp+2
	short M	determine the length of the string
	ldy	#-1
lb1	iny
	lda	[argp],Y
	bne	lb1
	long	M
	tya
	bra	lb1a

~Format_b entry
	ph4	argp	save the original argp
	ldy	#2	dereference argp
	lda	[argp],Y
	tax
	lda	[argp]
	sta	argp
	stx	argp+2
	lda	[argp]	get the length of the string
	and	#$00FF
	inc4	argp

lb1a	ldx	~precisionSpecified	if the precision is specified then
	beq	lb2
	cmp	~precision	  if the precision is smaller then
	blt	lb2
	lda	~precision	    process only precision characters
lb2	sta	~num	save the length in the temp variable area
	sub2	~fieldWidth,~num	account for the width of the value
	jsr	~RightJustify	handle right justification
	ldx	~num	skip printing if the length is 0
	beq	lb4
	ldy	#0	print the characters
lb3	phy
	lda	[argp],Y
	and	#$00FF
	pha
	jsl	~putchar
	ply
	iny
	dec	~num
	bne	lb3
lb4	clc		restore and increment argp
	pla
	adc	#4
	sta	argp
	pla
	sta	argp+2
	brl	~LeftJustify	handle left justification
	end

****************************************************************
*
*  ~Format_x - format a hexadecimal number (lowercase output)
*  ~Format_X - format a hexadecimal number (uppercase output)
*  ~Format_p - format a pointer
*
*  Inputs:
*	~altForm - use a leading '0x'?
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*	~isLong - is the operand long?
*	~precision - precision of output
*	~precisionSpecified - was the precision specified?
*
****************************************************************
*
~Format_x private
	using ~printfCommon
argp	equ	7	argument pointer
;
;  Set the "or" value; this is used to set the case of character results
;
	lda	#$20
	sta	orVal
	bra	cn0

~Format_p entry
	lda	#1
	sta	~isLong
~Format_X entry
	stz	orVal
;
;  Initialization
;
cn0	stz	~sign	ignore the sign flag
	lda	#'  '	initialize the string to blanks
	sta	~str
	move	~str,~str+1,#l:~str-1
	stz	~num+2	get the value to convert
	lda	~isLong
	beq	cn2
	ldy	#2
	lda	[argp],Y
	sta	~num+2
cn2	lda	[argp]
	sta	~num
	stz	~hexPrefix	assume we won't lead with 0x
;
;  Convert the number to an ASCII string
;
	short I,M
	ldy	#l:~str-1	set up the character index
cn3	lda	#0	roll off 4 bits
	ldx	#4
cn4	lsr	~num+3
	ror	~num+2
	ror	~num+1
	ror	~num
	ror	A
	dex
	bne	cn4
	lsr	A	form a character
	lsr	A
	lsr	A
	lsr	A
	ora	#'0'
	cmp	#'9'+1	if the character should be alpha,
	blt	cn5	 adjust it
	adc	#6
	ora	orVal
cn5	sta	~str,Y	save the character
	dey
	lda	~num+3	loop if the number is not zero
	ora	~num+2
	ora	~num+1
	ora	~num
	bne	cn3
;
;  If a leading '0x' is required, be sure we include one
;
	lda	~altForm	branch if no leading '0x' is required
	beq	al3
al2	lda	#'X'	insert leading '0x'
	ora	orVal
	sta	~hexPrefix+1
	lda	#'0'
	sta	~hexPrefix
al3	long	I,M
;
;  Piggy back off of ~Format_d for output
;
	brl	~Format_IntOut
;
;  Local data
;
orVal	ds	2	for setting the case of characters
	end

****************************************************************
*
*  ~Format_Percent - format the '%' character
*
*  Inputs:
*	~fieldWidth - output field width
*	~paddChar - padd character
*	~leftJustify - left justify the output?
*
****************************************************************
*
~Format_Percent private
	using ~printfCommon

	dec	~fieldWidth	account for the width of the value
	jsr	~RightJustify	handle right justification
	pea	'%'	print the character
	jsl	~putchar
	brl	~LeftJustify	handle left justification
	end

****************************************************************
*
*  ~InitBuffer - prepare a file buffer for output
*
*  Inputs:
*	stream - buffer to prepare
*
****************************************************************
*
~InitBuffer start

	csubroutine (4:stream),0

	ldy	#FILE_base+2	set the next buffer location
	lda	[stream],Y
	tax
	dey
	dey
	lda	[stream],Y
	ldy	#FILE_ptr
	sta	[stream],Y
	iny
	iny
	txa
	sta	[stream],Y
	ldy	#FILE_base	  set the end of buffer mark
	lda	[stream],Y
	ldy	#FILE_size
	clc
	adc	[stream],Y
	pha
	txa
	iny
	iny
	adc	[stream],Y
	ldy	#FILE_end+2
	sta	[stream],Y
	pla
	dey
	dey
	sta	[stream],Y
	ldy	#FILE_size	  set the number of chars the buffer
	lda	[stream],Y	   can hold
	tax
	iny
	iny
	lda	[stream],Y
	ldy	#FILE_cnt+2
	sta	[stream],Y
	dey
	dey
	txa
	sta	[stream],Y

	creturn
	end

****************************************************************
*
*  ~ioerror - flag an I/O error
*
*  Inputs:
*	stream - file to clear
*
*  Outputs:
*	errno - set to EIO
*	stream->flag - error flag set
*
****************************************************************
*
~ioerror start
stream	equ	3	input stream

	tsc
	phd
	tcd
	ldy	#FILE_flag
	lda	[stream],Y
	ora	#_IOERR
	sta	[stream],Y
	lda	#EIO
	sta	>errno
	pld
	pla
	ply
	ply
	pha
	rts
	end

****************************************************************
*
*  ~LeftJustify - print padd characters for left justification
*  ~RightJustify - print padd characters for right justification
*
*  Inputs:
*	~fieldWidth - # chars to print ( <= 0 prints none)
*	~leftJustify - left justify the output?
*
****************************************************************
*
~LeftJustify start
	using ~printfCommon

	lda	~leftJustify	padd if we are to left justify the field
	bne	padd
rts	rts

~RightJustify entry

	lda	~leftJustify	quit if we are to left justify the field
	bne	rts
padd	lda	~fieldWidth	quit if the field width is <= 0
	bmi	rts
	beq	rts
lb1	ph2	#' '	write the proper # of padd characters
	jsl	~putchar
	dec	~fieldWidth
	bne	lb1
	rts
	end

****************************************************************
*
*  ~osname - convert a c string to a GS/OS file name
*
*  Inputs:
*	filename - ptr to the c string
*
*  Outputs:
*	X-A - ptr to GS/OS file name
*
*  Notes:
*	1. Returns nil for error.
*	2. Caller must dispose of the name with a free call.
*
****************************************************************
*
~osname	private
namelen	equ	1	length of the string
ptr	equ	3	pointer to return

	csubroutine (4:filename),6

	ph4	filename	get the length of the name buffer
	jsl	strlen
	sta	namelen
	inc	A
	inc	A
	pea	0	reserve some memory
	pha
	jsl	malloc
	sta	ptr
	stx	ptr+2
	ora	ptr+2
	bne	lb1
	lda	#ENOMEM
	sta	>errno
	brl	lb3
lb1	lda	namelen	set the name length
	sta	[ptr]
	pea	0	copy the file name to the OS name buffer
	pha
	ph4	filename
	clc
	lda	ptr
	ldx	ptr+2
	adc	#2
	bcc	lb2
	inx
lb2	phx
	pha
	jsl	memcpy
lb3	creturn 4:ptr
	end

****************************************************************
*
*  int ~printf(char *format, additional arguments)
*
*  Print the format string by calling ~putchar indirectly.  If a
*  '%' is found, it is interpreted as follows:
*
*  Optional Flag Characters
*  ------------------------
*
*  '-'	Left justify the output.
*  '0'	Use '0' for the pad character rather than ' '.	 This
*	flag is ignored if the '-' flag is also used.
*  '+'	Only used for conversion operations 'd' 'e' 'E' 'f' 'g' 'G'.
*	Specifies that a leading sign is to be printed for
*	positive values.
*  ' '	Only used for conversion operations 'd' 'e' 'E' 'f' 'g' 'G'.
*	Ignored if '+' is specified.  For positive values, this
*	causes a padd space to be written where the sign would
*	appear.
*  '#'	Modify the conversion operation.
*
*  Optional Min Field Width
*  ------------------------
*
*  This field is either a number or *.	If it is *, an integer
*  argument is consumed from the stack and used as the field
*  width.  In either case, the output value is printed in a field
*  that is NUMBER characters wide.  By default, the value is
*  right justified and blank padded.
*
*  Optional Precision
*  ------------------
*
*  This field is a number, *, or is ommitted.  If it is an integer,
*  an argument is removed from the stack and used as the precision.
*  The precision is used to describe how many digits to print.
*
*  Long Size Specification
*  -----------------------
*
*  An 'l' indicates that the 'd', 'o', 'u', 'x' or 'X' argument is
*  long.	 'L' and 'u' are also accepted for compliance with ANSI C,
*  but have no effect in this implementation.
*
*  Conversion Specifier
*  --------------------
*
*  d,i	Signed decimal conversion from type int or long.
*  u	Signed decmal conversion from type unsigned or unsigned long.
*  o	Octal conversion.
*  x,X	Hexadecomal conversion.  'x' generates lowercase hex digits,
*	while 'X' generates uppercase hex digits.
*  c	Character.
*  s	String.
*  p	Pascal string.
*  n	The argument is (int *); the number of characters written so
*	far is written to the location.
*  f	Signed decimal floating point.
*  e,E	Exponential format floating point.
*  g,G	Use f,e or E, as appropriate.
*  %	Write a '%' character.
*
****************************************************************
*
~printf	private
	using ~printfCommon

argp	equ	7	pointer to first argument
format	equ	14	pointer to format code
;
;  Set up the stack frame
;
	phb		save the caller's B
	phk		use local addressing
	plb
	phd		save the caller's DP
	tsc		set up a DP
	tcd
;
;  Process the format string
;
	stz	~numChars	initialize the character counter
ps1	lda	[format]	get a character
	and	#$00FF
	beq	rt1	branch if at the end of the format string
	cmp	#'%'	branch if this is a conversion
	beq	fm1	 specification
	pha		write the character
	jsl	~putchar
	inc4	format
	bra	ps1
;
;  Remove the format parameter and return
;
rt1	lda	format-2	move the return address
	sta	format+2
	lda	format-3
	sta	format+1
	pld		restore DP
	plb		restore B
	rtl		return to top level formatter
;
;  Handle a format specification
;
fm1	inc4	format	skip the '%'

	stz	~removeZeros	not a G specifier
	stz	~fieldWidth	use only the space required
	stz	~precision	use the default precision
	stz	~precisionSpecified
	stz	~isLong	assume short operands
	lda	#' '	use a blank for padding
	sta	~paddChar
	stz	~leftJustify	right justify the output
	stz	~sign	don't print the sign unless arg < 0
	stz	~altForm	use the primary output format

fm2	jsr	Flag	read and interpret flag characters
	bcs	fm2
	jsr	GetSize	get the field width (if any)
	sta	~fieldWidth
	lda	[format]	if format == '.' then
	and	#$00FF
	cmp	#'.'
	bne	fm3
	inc4	format	  skip the '.'
	inc	~precisionSpecified	  note that the precision is specified
	jsr	GetSize	  get the precision
	sta	~precision
	lda	[format]	if *format == 'l' then
	and	#$00FF
fm3	cmp	#'l'
	bne	fm4
	inc	~isLong	  ~isLong = true
	bra	fm5	  ++format
fm4	cmp	#'L'	else if *format in ['L','h'] then
	beq	fm5
	cmp	#'h'
	bne	fm6
fm5	inc4	format	  ++format
	lda	[format]	find the proper format character
	and	#$00FF
fm6	inc4	format
	ldx	#fListEnd-fList-4
fm7	cmp	fList,X
	beq	fm8
	dex
	dex
	dex
	dex
	bpl	fm7
	brl	ps1	none found - continue
fm8	pea	ps1-1	push the return address
	inx		call the subroutine
	inx
	jmp	(fList,X)
;
;  Flag - Read and process a flag character
;
;  If a flag character was found, the carry flag is set.
;
Flag	lda	[format]	get the character
	and	#$00FF
	cmp	#'-'	if it is a '-' then
	bne	fl1
	lda	#1	  left justify the output
	sta	~leftJustify
	bra	fl5

fl1	cmp	#'0'	if it is a '0' then
	bne	fl2
	sta	~paddChar	  padd with '0' characters
	bra	fl5

fl2	cmp	#'+'	if it is a '+' or ' ' then
	beq	fl3
	cmp	#' '
	bne	fl4
	ldx	~sign
	cpx	#'+'
	beq	fl5
fl3	sta	~sign	  set the sign flag
	bra	fl5

fl4	cmp	#'#'	if it is a '#' then
	bne	fl6
	lda	#1	  use the alternate output form
	sta	~altForm
fl5	inc4	format	  skip the format character
	sec
	rts

fl6	clc		no flag was found
	rts
;
;  GetSize - get a numeric value
;
;  The value is returned in A
;
GetSize	stz	val	assume a value of 0
	lda	[format]	if the format character is '*' then
	and	#$00FF
	cmp	#'*'
	bne	gs1
	inc4	format	  skip the '*' char
	lda	[argp]	  fetch the value
	sta	val
	inc	argp	  remove it from the argument list
	inc	argp
gs0	lda	val
	rts

gs1	lda	[format]	while the character stream had digits do
	and	#$00FF
	cmp	#'0'
	blt	gs0
	cmp	#'9'+1
	bge	gs0
gs2	and	#$000F	  save the ordinal value
	pha
	asl	val	  A := val*10
	lda	val
	asl	a
	asl	a
	adc	val
	adc	1,S	  A := A+ord([format])
	plx
	sta	val	  val := A
	inc4	format	  skip the character
	bra	gs1

val	ds	2	value
;
;  List of format specifiers and the equivalent subroutines
;
fList	dc	c'%',i1'0',a'~Format_Percent'	%
	dc	c'n',i1'0',a'~Format_n'		n
	dc	c's',i1'0',a'~Format_s'		s
	dc	c'b',i1'0',a'~Format_b'		b
	dc	c'p',i1'0',a'~Format_p'		p
	dc	c'c',i1'0',a'~Format_c'		c
	dc	c'X',i1'0',a'~Format_X'		X
	dc	c'x',i1'0',a'~Format_x'		x
	dc	c'o',i1'0',a'~Format_o'		o
	dc	c'u',i1'0',a'~Format_u'		u
	dc	c'd',i1'0',a'~Format_d'		d
	dc	c'i',i1'0',a'~Format_d'		i
	dc	c'f',i1'0',a'~Format_f'		f
	dc	c'e',i1'0',a'~Format_e'		e
	dc	c'E',i1'0',a'~Format_E'		E
	dc	c'g',i1'0',a'~Format_g'		g
	dc	c'G',i1'0',a'~Format_G'		G
fListEnd anop
	end

****************************************************************
*
*  ~printfCommon - common data for formatted output
*
****************************************************************
*
~printfCommon data
;
;  ~putchar is a vector to the proper output routine.
;
~putchar dc	h'EE',i'~numChars'	inc ~numChars
	dc	h'5C 00 00 00'
;
;  Format options
;
~altForm ds	2	use alternate output format?
~fieldWidth ds 2	output field width
~hexPrefix ds	2	hex 0x prefix characters (if present)
~isLong	 ds	2	is the operand long?
~leftJustify ds 2	left justify the output?
~paddChar ds	2	output padd character
~precision ds	2	precision of output
~precisionSpecified ds 2	was the precision specified?
~removeZeros ds 2	remove insignificant zeros? (g specifier)
~sign	ds	2	char to use for positive sign
;
;  Work buffers
;
~num	ds	4	long integer
~numChars ds	2	number of characters printed with this printf
~str	ds	83	string buffer
;
;  Real formatting
;
~decForm anop		controls SANE's formatting styles
~style	ds	2	0 -> exponential; 1 -> fixed
~digits	ds	2	sig. digits; decimal digits

~decRec	anop		decimal record
~sgn	ds	2	sign
~exp	ds	2	exponent
~sig	ds	29	significant digits
	end

****************************************************************
*
*  ~RemoveWord - remove Y words from the stack for printf
*
*  Inputs:
*	Y - number of words to remove (must be >0)
*
****************************************************************
*
~RemoveWord start

lb1	lda	13,S	move the critical values
	sta	15,S
	lda	11,S
	sta	13,S
	lda	9,S
	sta	11,S
	lda	7,S
	sta	9,S
	lda	5,S
	sta	7,S
	lda	3,S
	sta	5,S
	pla
	sta	1,S

	tdc		update the direct page location
	inc	a
	inc	a
	tcd

	dey		next word
	bne	lb1
	rts
	end

****************************************************************
*
*  ~Scan_c - read a character or multiple characters
*
*  Inputs:
*	~scanWidth - # of characters to read (0 implies one)
*	~suppress - suppress save?
*
****************************************************************
*
~Scan_c	private
	using ~scanfCommon
arg	equ	11	argument

	lda	~scanWidth	if ~scanWidth == 0 then
	bne	lb1
	inc	~scanWidth	  ~scanWidth = 1

lb1	jsl	~getchar	get the character
	cmp	#EOF	if at EOF then
	bne	lb1a
	sta	~eofFound	   ~eofFound = EOF
	lda	~suppress	   if input is not suppressed then
	bne	lb3
	dec	~assignments	      no assignment made
	bra	lb3	   bail out

lb1a	ldx	~suppress	if input is not suppressed then
	bne	lb2
	short M	  save the value
	sta	[arg]
	long	M
	inc4	arg	  update the pointer
lb2	dec	~scanWidth	next character
	bne	lb1
lb3	lda	~suppress	if input is not suppressed then
	bne	lb4
	ldy	#2
	jsr	~RemoveWord	remove the parameter from the stack
lb4	rts
	end

****************************************************************
*
*  ~Scan_d - read an integer
*  ~Scan_i - read a based integer
*
*  Inputs:
*	~scanError - has a scan error occurred?
*	~scanWidth - max input length
*	~suppress - suppress save?
*	~size - size specifier
*
****************************************************************
*
~Scan_d	private
	using ~scanfCommon
arg	equ	11	argument

	stz	based	always use base 10
	bra	bs1
~Scan_i	entry
	lda	#1	allow base 8, 10, 16
	sta	based

bs1	stz	read	no chars read
	lda	#10	assume base 10
	sta	base
	stz	val	initialize the value to 0
	stz	val+2
lb1	jsl	~getchar	skip leading whitespace...
	cmp	#EOF	if EOF then
	bne	ef1
	sta	~eofFound	   ~eofFound = EOF
	lda	~suppress	   if input is not suppressed then
	bne	lb6l
	dec	~assignments	      no assignment made
lb6l	brl	lb6	   bail out
ef1	tax		{...back to skipping whitespace}
	lda	__ctype+1,X
	and	#_space
	bne	lb1
	inc	read
	txa
	stz	minus	assume positive number
	cmp	#'+'	skip leading +
	beq	sg1
	cmp	#'-'	if - then set minus flag
	bne	sg2
	inc	minus
sg1	jsl	~getchar
	inc	read
sg2	ldx	based	if base 8, 16 are allowed then
	beq	lb2
	cmp	#'0'	  if the digit is '0' then
	bne	lb2
	lda	#8	    assume base 8
	sta	base
	dec	~scanWidth	    get the next character
	jeq	lb4a
	bpl	lb1a
	stz	~scanWidth
lb1a	jsl	~getchar
	inc	read
	cmp	#'X'	    if it is X then
	beq	lb1b
	cmp	#'x'
	bne	lb2
lb1b	asl	base	      use base 16
	dec	~scanWidth	      get the next character
	beq	lb4a
	bpl	lb1c
	stz	~scanWidth
lb1c	jsl	~getchar
	inc	read

lb2	cmp	#'0'	if the char is a digit then
	blt	lb4
	cmp	#'7'+1
	blt	lb2a
	ldx	base
	cpx	#8
	beq	lb4
	cmp	#'9'+1
	blt	lb2a
	cpx	#16
	bne	lb4
	and	#$00DF
	cmp	#'A'
	blt	lb4
	cmp	#'F'+1
	bge	lb4
	sbc	#6
lb2a	and	#$000F	  convert it to a value
	pha		  save the value
	ph4	val	  update the old value
	lda	base
	ldx	#0
	jsl	~UMUL4
	pl4	val
	pla		  add in the new digit
	clc
	adc	val
	sta	val
	bcc	lb3
	inc	val+2
lb3	dec	~scanWidth	  quit if the max # chars have been
	beq	lb4a	    scanned
	bpl	lb3a	  make sure 0 stays a 0
	stz	~scanWidth
lb3a	jsl	~getchar	  next char
	inc	read
	bra	lb2

lb4	jsl	~putback	put the last character back
	dec	read
lb4a	lda	read	if no chars read then
	bne	lb4b
	inc	~scanError	  ~scanError = true
	lda	~suppress	  if input is not suppressed then
	bne	lb6
	dec	~assignments	    no assignment made
	bra	lb6	  skip the save
lb4b	lda	~suppress	if input is not suppressed then
	bne	lb7
	lda	minus	  if minus then
	beq	lb4c
	sub4	#0,val,val	    negate the value
lb4c	lda	val	  save the value
	sta	[arg]
	dec	~size
	bmi	lb6
	ldy	#2
	lda	val+2
	sta	[arg],Y
lb6	lda	~suppress	if input is not suppressed then
	bne	lb7
	ldy	#2	  remove the parameter from the stack
	jsr	~RemoveWord
lb7	rts

val	ds	4	value
base	dc	i4'10'	constant for mul4
based	ds	2	based conversion?
minus	ds	2	is the value negative?
read	ds	2	# chars read
	end

****************************************************************
*
*  ~Scan_lbrack - read character in a set
*
*  Inputs:
*	~scanWidth - max input length
*	~suppress - suppress save?
*	~size - size specifier
*
****************************************************************
*
~Scan_lbrack private
	using ~scanfCommon
	using ~printfCommon
arg	equ	11	argument
format	equ	7	pointer to format code

	stz	read	no characters read into the set
	stz	didOne	no characters scanned from the stream
	move	#0,~str,#32	clear the set
	stz	negate	don't negate the set
	lda	[format]	if the first char is '^' then
	and	#$00FF
	cmp	#'^'
	bne	lb2
	dec	negate	  negate the set
lb1	inc4	format	  skip the ^
lb2	lda	[format]	while *format != ']' do
	and	#$00FF
	ldx	read	  but wait: ']' as the first char is
	beq	lb2a	    allowed!
	cmp	#']'
	beq	lb3
lb2a	inc	read
	jsr	Set	  set the char's bit
	ora	~str,X
	sta	~str,X
	bra	lb1	  next char
lb3	inc4	format	skip the ']'
	ldy	#30	negate the set (if needed)
lb4	lda	~str,Y
	eor	negate
	sta	~str,Y
	dey
	dey
	bpl	lb4

lb5	jsl	~getchar	get a character
	cmp	#EOF	quit if at EOF
	beq	lb8
	pha		quit if not in the set
	jsr	Set
	ply
	and	~str,X
	beq	lb7
	sty	didOne	note that we scanned a character
	ldx	~suppress	if output is not suppressed then
	bne	lb6
	tya
	short M	  save the character
	sta	[arg]
	long	M
	inc4	arg	  update the argument
lb6	dec	~scanWidth	note that we processed one
	beq	lb8
	bpl	lb5
	stz	~scanWidth
	bra	lb5	next char

lb7	tya		put back the last char scanned
	jsl	~putback

lb8	lda	didOne	if no chars read then
	bne	lb8a
	inc	~scanError	  ~scanError = true
	lda	~suppress	  if input is not suppressed then
	bne	lb9
	dec	~assignments	    no assignment made
	bra	lb8b	  skip the save
lb8a	lda	~suppress	if output is not suppressed then
	bne	lb9
	short M	  set the terminating null
	lda	#0
	sta	[arg]
	long	M

lb8b	ldy	#2	  remove the parameter from the stack
	jsr	~RemoveWord
lb9	rts
;
;  Set - form a set disp/bit pattern from a character value
;
Set	ldx	#1
	stx	disp
st1	bit	#$0007
	beq	st2
	asl	disp
	dec	A
	bra	st1
st2	lsr	A
	lsr	A
	lsr	A
	tax
	lda	disp
	rts

negate	ds	2	negate the set?
disp	ds	2	used to form the set disp
read	ds	2	number of characters in the scan set
didOne	ds	2	non-zero if we have scanned a character
	end

****************************************************************
*
*  ~Scan_n - return the # of characters scanned so far
*
*  Inputs:
*	~suppress - suppress save?
*
*  Notes:
*	Decrements ~assignments so the increment in scanf will
*	leave the assignment count unaffected by this call.
*
****************************************************************
*
~Scan_n	private
	using ~scanfCommon
arg	equ	11	argument

	ldx	~suppress	if output is not suppressed then
	bne	lb1
	lda	~scanCount	  save the count
	sta	[arg]
	dec	~assignments	  fix assignment count
lb1	ldy	#2	remove the parameter from the stack
	jsr	~RemoveWord
	rts
	end

****************************************************************
*
*  ~Scan_b - read a pascal string
*  ~Scan_s - read a c string
*
*  Inputs:
*	~scanError - has a scan error occurred?
*	~scanWidth - max input length
*	~suppress - suppress save?
*	~size - size specifier
*
****************************************************************
*
~Scan_b	private
	using ~scanfCommon
arg	equ	11	argument

	move4 arg,length	save the location to store the length
	inc4	arg	increment to the first char position
	lda	#1
	sta	pString	set the p-string flag
	bra	lb1
~Scan_s	entry
	stz	pString	clear the p-string flag

lb1	jsl	~getchar	skip leading whitespace
	cmp	#EOF
	bne	lb2
	inc	~scanError
	lda	~suppress	(no assignment made)
	bne	lb6
	dec	~assignments
	bra	lb6
lb2	tax
	lda	__ctype+1,X
	and	#_space
	bne	lb1

lb2a	txa
	ldx	~suppress	if output is not suppressed then
	bne	lb3
	short M	  save the character
	sta	[arg]
	long	M
	inc4	arg	  update the argument
lb3	dec	~scanWidth	note that we processed one
	beq	lb5
	bpl	lb4
	stz	~scanWidth
lb4	jsl	~getchar	next char
	cmp	#EOF	quit if at EOF
	beq	lb5
	and	#$00FF	loop if not whitespace
	tax
	lda	__ctype+1,X
	and	#_space
	beq	lb2a
	txa		whitespace: put it back
	jsl	~putback

lb5	lda	~suppress	if output is not suppressed then
	bne	lb6
	short M	  set the terminating null
	lda	#0
	sta	[arg]
	long	M
	lda	pString	  if this is a p-string then
	beq	lb6
	sec		    compute the length
	lda	arg
	sbc	length
	dec	A
	ldx	length	    set up the address
	stx	arg
	ldx	length+2
	stx	arg+2
	short M	    save the length
	sta	[arg]
	long	M

lb6	lda	~suppress	if output is not suppressed then
	bne	lb7
	ldy	#2	  remove the parameter from the stack
	jsr	~RemoveWord
lb7	rts

length	ds	4	ptr to the length byte (p string only)
pString	ds	2	is this a p string?
	end

****************************************************************
*
*  ~Scan_percent - read a % character
*
*  Inputs:
*	~scanWidth - max input length
*	~suppress - suppress save?
*	~size - size specifier
*
****************************************************************
*
~Scan_percent private
	using ~scanfCommon
arg	equ	11	argument

	jsl	~getchar	get the character
	cmp	#'%'	if it is not a percent then
	beq	lb1
	jsl	~putback	  put it back
	inc	~scanError	  note the error
	lda	~suppress	  if input is not suppressed then
	bne	lb1
	dec	~assignments	    no assignment done
lb1	rts
	end

****************************************************************
*
*  ~Scan_u - read an unsigned integer
*  ~Scan_o - read an unsigned octal integer
*  ~Scan_x - read an unsigned hexadecimal integer
*  ~Scan_p - read a pointer
*
*  Inputs:
*	~scanWidth - max input length
*	~suppress - suppress save?
*	~size - size specifier
*
****************************************************************
*
~Scan_u	private
	using ~scanfCommon
arg	equ	11	argument

	jsr	Init
	lda	#10	base 10
	bra	bs1

~Scan_o	entry
	jsr	Init
	lda	#8	base 8
	bra	bs1

~Scan_p	entry
	lda	#1
	sta	~size
~Scan_x	entry
	jsr	Init
	jsl	~getchar	if the initial char is a '0' then
	inc	read
	sta	ch
	cmp	#'0'
	bne	hx2
	dec	~scanWidth	  get the next character
	jeq	lb4a
	bpl	hx1
	stz	~scanWidth
hx1	jsl	~getchar
	inc	read
	sta	ch
	cmp	#'x'	  if it is an 'x' or 'X' then
	beq	hx1a
	cmp	#'X'
	bne	hx2
hx1a	dec	~scanWidth	    accept the character
	jeq	lb4a
	bpl	hx3
	stz	~scanWidth
	bra	hx3
hx2	jsl	~putback	put back the character
	dec	read
hx3	lda	#16	base 16

bs1	sta	base	set the base

lb2	jsl	~getchar	if the char is a digit then
	inc	read
	sta	ch
	cmp	#'0'
	blt	lb4
	cmp	#'7'+1
	blt	lb2a
	ldx	base
	cpx	#8
	beq	lb4
	cmp	#'9'+1
	blt	lb2a
	cpx	#16
	bne	lb4
	and	#$00DF
	cmp	#'A'
	blt	lb4
	cmp	#'F'+1
	bge	lb4
	sbc	#6
lb2a	and	#$000F	  convert it to a value
	pha		  save the value
	ph4	val	  update the old value
	lda	base
	ldx	base+2
	jsl	~UMUL4
	pl4	val
	pla		  add in the new digit
	clc
	adc	val
	sta	val
	bcc	lb3
	inc	val+2
lb3	dec	~scanWidth	  quit if the max # chars have been
	beq	lb4a	    scanned
	bpl	lb2	  make sure 0 stays a 0
	stz	~scanWidth
	bra	lb2

lb4	lda	ch	put the last character back
	jsl	~putback
	dec	read
lb4a	lda	read	if no chars read then
	bne	lb4b
	inc	~scanError	  ~scanError = true
	lda	~suppress	  if input is not suppressed then
	bne	lb6
	dec	~assignments	    no assignment made
	bra	lb6	  remove the parameter
lb4b	lda	~suppress	if input is not suppressed then
	bne	lb7
	lda	val	  save the value
	sta	[arg]
	dec	~size
	bmi	lb6
	ldy	#2
	lda	val+2
	sta	[arg],Y
lb6	lda	~suppress	if input is not suppressed then
	bne	lb7
	ldy	#2	  remove the parameter from the stack
	jsr	~RemoveWord
lb7	rts
;
;  Initialization
;
Init	stz	read	no chars read
	stz	val	initialize the value to 0
	stz	val+2
in1	jsl	~getchar	skip leading whitespace...
	cmp	#EOF	if at EOF then
	bne	in2
	lda	~suppress	   if input is not suppressed then
	bne	in1a
	dec	~assignments	      no assignment made
in1a	sta	~eofFound	   eofFound = EOF
	pla		   pop stack
	bra	lb6	   bail out
in2	tax		...back to slipping whitespace
	lda	__ctype+1,X
	and	#_space
	bne	in1
	txa
	jsl	~putback
	rts

ch	ds	2	char buffer
val	ds	4	value
base	dc	i4'10'	constant for mul4
based	ds	2	based conversion?
read	ds	2	# chars read
	end

****************************************************************
*
*  int ~scanf(format, additional arguments)
*     char *format;
*
*  Scan by calling ~getchar indirectly.	 If a '%' is found, it
*  is interpreted as follows:
*
*  Assignment Suppression Flag
*  ---------------------------
*
*  '*'	Do everyting but save the result and remove a pointer from
*	the stack.
*
*  Max Field Width
*  ---------------
*
*  No more than this number of characters are removed from the
*  input stream.
*
*  Size Specification
*  ------------------
*
*  'h'	Used with 'd', 'u', 'o' or 'x' to indicate a short store.
*  'l'	Used with 'd', 'u', 'o' or 'x' to indicate a four-byte store.
*	Also used with 'e', 'f' or 'g' to indicate double reals.
*
*  Conversion Specifier
*  --------------------
*
*  d,i	Signed decimal conversion to type int or long.
*  u	Signed decmal conversion to type unsigned short, unsigned or
*	unsigned long.
*  o	Octal conversion.
*  x,X	Hexadecomal conversion.
*  c	Character.
*  s	String.
*  p	Pascal string.
*  n	The argument is (int *); the number of characters written so
*	far is written to the location.
*  f,e,E,g,G Signed floating point conversion.
*  %	Read a '%' character.
*  [	Scan and included characters and place them in a string.
*
****************************************************************
*
~scanf	private
	using ~scanfCommon

arg	equ	format+4	first argument
format	equ	7	pointer to format code
;
;  Set up the stack frame
;
	phb		save the caller's B
	phk		use local addressing
	plb
	phd		save the caller's DP
	tsc		set up a DP
	tcd
;
;  Process the format string
;
	stz	~assignments	no assignments yet
	stz	~scanCount	no characters scanned
	stz	~scanError	no scan error so far
	stz	~eofFound	eof was not the first char
	jsl	~getchar	test for eof
	cmp	#EOF
	bne	ps0
	sta	~eofFound
ps0	jsl	~putback

ps1	lda	~scanError	quit if a scan error has occurred
	bne	rm1
	lda	[format]	get a character
	and	#$00FF
	jeq	rt1	branch if at the end of the format string

	tax		if this is a whitespace char then
	lda	__ctype+1,X
	and	#_space
	beq	ps4
ps2	inc4	format	  skip whitespace in the format string
	lda	[format]
	and	#$00FF
	tax
	lda	__ctype+1,X
	and	#_space
	bne	ps2
ps3	jsl	~getchar	  skip whitespace in the input stream
	tax
	cpx	#EOF
	beq	ps3a
	lda	__ctype+1,X
	and	#_space
	bne	ps3
ps3a	txa
	jsl	~putback
	bra	ps1

ps4	cpx	#'%'	branch if this is a conversion
	beq	fm1	 specification

	stx	ch	make sure the char matches the format
	inc4	format	 specifier
	jsl	~getchar
	cmp	ch
	beq	ps1
	jsl	~putback	put the character back
;
;  Remove the parameters for remaining conversion specifications
;
rm1	lda	[format]	if this is a format specifier then
	and	#$00FF
	beq	rt1
	cmp	#'%'
	bne	rm4
	inc4	format	  if it is not a '%' or '*' then
	lda	[format]
	and	#$00FF
	beq	rt1
	cmp	#'%'
	beq	rm4
	cmp	#'*'
	beq	rm4
	cmp	#'['	    if it is a '[' then
	bne	rm3
rm2	inc4	format	      skip up to the closing ']'
	lda	[format]
	and	#$00FF
	beq	rt1
	cmp	#']'
	bne	rm2
rm3	ldy	#2	    remove an addr from the stack
	jsr	~RemoveWord
rm4	inc4	format	next format character
	bra	rm1
;
;  Remove the format parameter and return
;
rt1	lda	format-2	move the return address
	sta	format+2
	lda	format-3
	sta	format+1
	pld		restore DP
	plb		restore B
	pla		remove the extra 4 bytes from the stack
	pla
	lda	>~assignments	return the number of assignments
	bne	rt2
	lda	>~eofFound	return EOF if no characters scanned
rt2	rtl
;
;  Handle a format specification
;
fm1	inc4	format	skip the '%'
	inc	~assignments	another one made...

	stz	~suppress	assignment is not suppressed
	stz	~size	default operand size

	lda	[format]	if the char is an '*' then
	and	#$00FF
	cmp	#'*'
	bne	fm2
	inc	~suppress	  suppress the output
	dec	~assignments	  no assignment made
	inc4	format	  skip the '*'

fm2	jsr	GetSize	get the field width specifier
	sta	~scanWidth

	lda	[format]	if the character is an 'l' then
	and	#$00FF
	cmp	#'l'
	bne	fm3
	inc	~size	  long specifier
	bra	fm4
fm3	cmp	#'h'	else if it is an 'h' then
	bne	fm5
fm4	inc4	format	  ignore the character

fm5	lda	[format]	find the proper format character
	and	#$00FF
	inc4	format
	ldx	#fListEnd-fList-4
fm7	cmp	fList,X
	beq	fm8
	dex
	dex
	dex
	dex
	bpl	fm7
	brl	ps1	none found - continue
fm8	pea	ps1-1	push the return address
	inx		call the subroutine
	inx
	jmp	(fList,X)
;
;  GetSize - get a numeric value
;
;  The value is returned in A
;
GetSize	stz	val	assume a value of 0
gs1	lda	[format]	while the character stream had digits do
	and	#$00FF
	cmp	#'0'
	blt	gs3
	cmp	#'9'+1
	bge	gs3
gs2	and	#$000F	  save the ordinal value
	pha
	asl	val	  A := val*10
	lda	val
	asl	a
	asl	a
	adc	val
	adc	1,S	  A := A+ord([format])
	plx
	sta	val	  val := A
	inc4	format	  skip the character
	bra	gs1
gs3	lda	val
	rts

val	ds	2	value
;
;  List of format specifiers and the equivalent subroutines
;
fList	dc	c'd',i1'0',a'~Scan_d'		d
	dc	c'i',i1'0',a'~Scan_i'		i
	dc	c'u',i1'0',a'~Scan_u'		u
	dc	c'o',i1'0',a'~Scan_o'		o
	dc	c'x',i1'0',a'~Scan_x'		x
	dc	c'X',i1'0',a'~Scan_x'		X
	dc	c'p',i1'0',a'~Scan_p'		p
	dc	c'c',i1'0',a'~Scan_c'		c
	dc	c's',i1'0',a'~Scan_s'		s
	dc	c'b',i1'0',a'~Scan_b'		b
	dc	c'n',i1'0',a'~Scan_n'		n
	dc	c'f',i1'0',a'~Scan_f'		f
	dc	c'e',i1'0',a'~Scan_f'		e
	dc	c'E',i1'0',a'~Scan_f'		E
	dc	c'g',i1'0',a'~Scan_f'		g
	dc	c'G',i1'0',a'~Scan_f'		G
	dc	c'%',i1'0',a'~Scan_percent'	%
	dc	c'[',i1'0',a'~Scan_lbrack'	[
fListEnd anop
;
;  Other local data
;
ch	ds	2	temp storage
	end

****************************************************************
*
*  ~scanfCommon - common data for formatted input
*
****************************************************************
*
~scanfCommon data
;
;  ~getchar is a vector to the proper input routine.
;
~getchar dc	h'AF',a3'~scanCount'	lda   >~scanCount
	dc	h'1A'	inc   A
	dc	h'8F',a3'~scanCount'	sta   >~scanCount
	dc	h'5C 00 00 00'
;
;  ~putback is a vector to the proper putback routine.
;
~putback dc	h'48'	pha
	dc	h'AF',a3'~scanCount'	lda   >~scanCount
	dc	h'3A'	dec   A
	dc	h'8F',a3'~scanCount'	sta   >~scanCount
	dc	h'68'	pla
	dc	h'5C 00 00 00'
;
;  global variables
;
~assignments ds 2	# of assignments made
~eofFound ds	2	was EOF found during the scan?
~suppress ds	2	suppress assignment?
~scanCount ds	2	# of characters scanned
~scanError ds	2	set to 1 by scaners if an error occurs
~scanWidth ds	2	max # characters to scan
~size	 ds	2	size specifier; -1 -> short, 1 -> long,
!			 0 -> default
	end

****************************************************************
*
*  ~SetFilePointer - makes sure nothing is in the input buffer
*
*  Inputs:
*	stream - stream to check
*
****************************************************************
*
~SetFilePointer private

	csubroutine (4:stream),0

	ldy	#FILE_pbk	if stream->FILE_pbk != -1
	lda	[stream],Y
	inc	A
	ldy	#FILE_cnt	  or stream->FILE_cnt != 0 then
	ora	[stream],Y
	iny
	iny
	ora	[stream],Y
	beq	lb1
	ph2	#SEEK_CUR	  fseek(stream, 0L, SEEK_CUR)
	ph4	#0
	ph4	stream
	jsl	fseek

lb1	anop
	creturn
	end

****************************************************************
*
*  ~VerifyStream - insures that a stream actually exists
*
*  Inputs:
*	stream - stream to check
*
*  Outputs:
*	C - set for error; clear if the stream exists
*
****************************************************************
*
~VerifyStream private
stream	equ	9	stream to check
ptr	equ	1	stream pointer

	phb		set up the stack frame
	phk
	plb
	ph4	#stdin+4
	tsc
	phd
	tcd

lb1	lda	ptr	error if the list is exhausted
	ora	ptr+2
	beq	err
	lda	ptr	OK if the steams match
	cmp	stream
	bne	lb2
	lda	ptr+2
	cmp	stream+2
	beq	OK
lb2	ldy	#2	next pointer
	lda	[ptr],Y
	tax
	lda	[ptr]
	sta	ptr
	stx	ptr+2
	bra	lb1

err	lda	#EIO	set the error code
	sta	>errno
	sec		return with error
	bra	OK2

OK	clc		return with no error
OK2	pld
	pla
	pla
	plx
	ply
	pla
	pla
	phy
	phx
	plb
	rtl
	end
