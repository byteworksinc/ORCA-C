	mcopy table.macros
****************************************************************
*
*  Table
*
*  This segment contains the assembly language code for the
*  various initialized arrays and records in the program.  This
*  file creates the object file linked into the program.
*  TABLE.PAS creates the interface file that informs the
*  other segments in the compiler what is in this segment.
*
****************************************************************
*
root	start		dummy (.root) segment

	end

! character set
charKinds start
	enum	(illegal,ch_special,ch_dash,ch_plus,ch_lt,ch_gt,ch_eq,ch_exc),0
	enum	(ch_and,ch_bar,ch_dot,ch_white,ch_eol,ch_eof,ch_char,ch_string)
	enum	(ch_asterisk,ch_slash,ch_percent,ch_carot,ch_pound,letter,digit)

! STANDARD
	dc	i'ch_eof'	nul
	dc	i'illegal'	soh
	dc	i'illegal'	stx
	dc	i'illegal'	etx
	dc	i'illegal'	eot
	dc	i'illegal'	enq
	dc	i'illegal'	ack
	dc	i'illegal'	bel
	dc	i'ch_white'	bs
	dc	i'ch_white'	ht
	dc	i'ch_eol'	lf
	dc	i'ch_eol'	vt
	dc	i'ch_eol'	ff
	dc	i'ch_eol'	cr
	dc	i'illegal'	co
	dc	i'illegal'	si
	dc	i'illegal'	dle
	dc	i'illegal'	dc1
	dc	i'illegal'	dc2
	dc	i'illegal'	dc3
	dc	i'illegal'	dc4
	dc	i'illegal'	nak
	dc	i'illegal'	syn
	dc	i'illegal'	etb
	dc	i'illegal'	can
	dc	i'illegal'	em
	dc	i'illegal'	sub
	dc	i'illegal'	esc
	dc	i'illegal'	fs
	dc	i'illegal'	gs
	dc	i'illegal'	rs
	dc	i'illegal'	us
	dc	i'ch_white'	space
	dc	i'ch_exc'	!
	dc	i'ch_string'	"
	dc	i'illegal'	#
	dc	i'illegal'	$
	dc	i'ch_percent'	%
	dc	i'ch_and'	&
	dc	i'ch_char'	'
	dc	i'ch_special'	(
	dc	i'ch_special'	)
	dc	i'ch_asterisk'	*
	dc	i'ch_plus'	+
	dc	i'ch_special'	,
	dc	i'ch_dash'	-
	dc	i'ch_dot'	.
	dc	i'ch_slash'	/
	dc	i'digit'	0
	dc	i'digit'	1
	dc	i'digit'	2
	dc	i'digit'	3
	dc	i'digit'	4
	dc	i'digit'	5
	dc	i'digit'	6
	dc	i'digit'	7
	dc	i'digit'	8
	dc	i'digit'	9
	dc	i'ch_special'	:
	dc	i'ch_special'	;
	dc	i'ch_lt'	<
	dc	i'ch_eq'	=
	dc	i'ch_gt'	>
	dc	i'ch_special'	?
	dc	i'illegal'	@
	dc	i'letter'	A
	dc	i'letter'	B
	dc	i'letter'	C
	dc	i'letter'	D
	dc	i'letter'	E
	dc	i'letter'	F
	dc	i'letter'	G
	dc	i'letter'	H
	dc	i'letter'	I
	dc	i'letter'	J
	dc	i'letter'	K
	dc	i'letter'	L
	dc	i'letter'	M
	dc	i'letter'	N
	dc	i'letter'	O
	dc	i'letter'	P
	dc	i'letter'	Q
	dc	i'letter'	R
	dc	i'letter'	S
	dc	i'letter'	T
	dc	i'letter'	U
	dc	i'letter'	V
	dc	i'letter'	W
	dc	i'letter'	X
	dc	i'letter'	Y
	dc	i'letter'	Z
	dc	i'ch_special'	[
	dc	i'illegal'	\
	dc	i'ch_special'	]
	dc	i'ch_carot'	^
	dc	i'letter'	_
	dc	i'illegal'	`
	dc	i'letter'	a
	dc	i'letter'	b
	dc	i'letter'	c
	dc	i'letter'	d
	dc	i'letter'	e
	dc	i'letter'	f
	dc	i'letter'	g
	dc	i'letter'	h
	dc	i'letter'	i
	dc	i'letter'	j
	dc	i'letter'	k
	dc	i'letter'	l
	dc	i'letter'	m
	dc	i'letter'	n
	dc	i'letter'	o
	dc	i'letter'	p
	dc	i'letter'	q
	dc	i'letter'	r
	dc	i'letter'	s
	dc	i'letter'	t
	dc	i'letter'	u
	dc	i'letter'	v
	dc	i'letter'	w
	dc	i'letter'	x
	dc	i'letter'	y
	dc	i'letter'	z
	dc	i'ch_special'	{
	dc	i'ch_bar'	|
	dc	i'ch_special'	}
	dc	i'ch_special'	~
	dc	i'illegal'	rub
! EXTENDED
	dc	i'letter'	nul
	dc	i'letter'	soh
	dc	i'letter'	stx
	dc	i'letter'	etx
	dc	i'letter'	eot
	dc	i'letter'	enq
	dc	i'letter'	ack
	dc	i'letter'	bel
	dc	i'letter'	bs
	dc	i'letter'	ht
	dc	i'letter'	lf
	dc	i'letter'	vt
	dc	i'letter'	ff
	dc	i'letter'	cr
	dc	i'letter'	co
	dc	i'letter'	si
	dc	i'letter'	dle
	dc	i'letter'	dc1
	dc	i'letter'	dc2
	dc	i'letter'	dc3
	dc	i'letter'	dc4
	dc	i'letter'	nak
	dc	i'letter'	syn
	dc	i'letter'	etb
	dc	i'letter'	can
	dc	i'letter'	em
	dc	i'letter'	sub
	dc	i'letter'	esc
	dc	i'letter'	fs
	dc	i'letter'	gs
	dc	i'letter'	rs
	dc	i'letter'	us
	dc	i'illegal'	space
	dc	i'illegal'	!
	dc	i'illegal'	"
	dc	i'illegal'	#
	dc	i'illegal'	$
	dc	i'illegal'	%
	dc	i'illegal'	&
	dc	i'letter'	'
	dc	i'illegal'	(
	dc	i'illegal'	)
	dc	i'illegal'	*
	dc	i'illegal'	+
	dc	i'illegal'	,
	dc	i'ch_special'	-
	dc	i'letter'	.
	dc	i'letter'	/
	dc	i'illegal'	0
	dc	i'illegal'	1
	dc	i'ch_special'	2
	dc	i'ch_special'	3
	dc	i'letter'	4
	dc	i'letter'	5
	dc	i'letter'	6
	dc	i'letter'	7
	dc	i'letter'	8
	dc	i'letter'	9
	dc	i'illegal'	:
	dc	i'letter'	;
	dc	i'letter'	<
	dc	i'letter'	=
	dc	i'letter'	>
	dc	i'letter'	?
	dc	i'illegal'	@
	dc	i'illegal'	A
	dc	i'illegal'	B
	dc	i'illegal'	C
	dc	i'letter'	D
	dc	i'illegal'	E
	dc	i'letter'	F
	dc	i'ch_special'	G
	dc	i'ch_special'	H
	dc	i'illegal'	I
	dc	i'ch_white'	J
	dc	i'letter'	K
	dc	i'letter'	L
	dc	i'letter'	M
	dc	i'letter'	N
	dc	i'letter'	O
	dc	i'illegal'	P
	dc	i'illegal'	Q
	dc	i'illegal'	R
	dc	i'illegal'	S
	dc	i'illegal'	T
	dc	i'illegal'	U
	dc	i'ch_special'	V
	dc	i'illegal'	W
	dc	i'letter'	X
	dc	i'illegal'	Y
	dc	i'illegal'	Z
	dc	i'illegal'	[
	dc	i'illegal'	\
	dc	i'illegal'	]
	dc	i'letter'	^
	dc	i'letter'	_
	dc	i'illegal'	`
	dc	i'illegal'	a
	dc	i'illegal'	b
	dc	i'illegal'	c
	dc	i'illegal'	d
	dc	i'illegal'	e
	dc	i'illegal'	f
	dc	i'illegal'	g
	dc	i'illegal'	h
	dc	i'illegal'	i
	dc	i'illegal'	j
	dc	i'illegal'	k
	dc	i'illegal'	l
	dc	i'illegal'	m
	dc	i'illegal'	n
	dc	i'illegal'	o
	dc	i'illegal'	p
	dc	i'illegal'	q
	dc	i'illegal'	r
	dc	i'illegal'	s
	dc	i'illegal'	t
	dc	i'illegal'	u
	dc	i'illegal'	v
	dc	i'illegal'	w
	dc	i'illegal'	x
	dc	i'illegal'	y
	dc	i'illegal'	z
	dc	i'illegal'	{
	dc	i'illegal'	|
	dc	i'illegal'	}
	dc	i'illegal'	~
	dc	i'illegal'	rub
	end

! single character symbols
charSym	start
	enum	ident,0	identifiers
!			constants
	enum	(intconst,uintconst,longconst,ulongconst,doubleconst)
	enum	stringconst
!			reserved words
	enum	(autosy,asmsy,breaksy,casesy,charsy)
	enum	(continuesy,constsy,compsy,defaultsy,dosy)
	enum	(doublesy,elsesy,enumsy,externsy,extendedsy)
	enum	(floatsy,forsy,gotosy,ifsy,intsy)
	enum	(inlinesy,longsy,pascalsy,registersy,returnsy)
	enum	(shortsy,sizeofsy,staticsy,structsy,switchsy)
	enum	(segmentsy,signedsy,typedefsy,unionsy,unsignedsy)
	enum	(voidsy,volatilesy,whilesy)
!			reserved symbols
	enum	(excch,percentch,carotch,andch,asteriskch)
	enum	(minusch,plusch,eqch,tildech,barch)
	enum	(dotch,ltch,gtch,slashch,questionch)
	enum	(lparench,rparench,lbrackch,rbrackch,lbracech)
	enum	(rbracech,commach,semicolonch,colonch,poundch)
	enum	(minusgtop,plusplusop,minusminusop,ltltop,gtgtop)
	enum	(lteqop,gteqop,eqeqop,exceqop,andandop)
	enum	(barbarop,pluseqop,minuseqop,asteriskeqop,slasheqop)
	enum	(percenteqop,ltlteqop,gtgteqop,andeqop,caroteqop)
	enum	(bareqop,poundpoundop)
	enum	(eolsy,eofsy)	control characters
	enum	(typedef)	user types
	enum	(uminus,uand,uasterisk)	converted operations
	enum	(parameteroper,castoper,opplusplus,opminusminus)
	enum	(macroParm)	macro language

	dc	i'0,0,0,0,0,0,0,0'					nul-bel
	dc	i'0,0,0,0,0,0,0,0'					bs-si
	dc	i'0,0,0,0,0,0,0,0'					dle-etb
	dc	i'0,0,0,0,0,0,0,0'					can-us
	dc	i'0,0,0,poundch,0,0,0,0'					space-'
	dc	i'lparench,rparench,0,0,commach,0,dotch,0'		(-/
	dc	i'0,0,0,0,0,0,0,0'					0-7
	dc	i'0,0,colonch,semicolonch,0,0,0,questionch'		8-?
	dc	i'0,0,0,0,0,0,0,0'					@-G
	dc	i'0,0,0,0,0,0,0,0'					H-O
	dc	i'0,0,0,0,0,0,0,0'					P-W
	dc	i'0,0,0,lbrackch,0,rbrackch,0,0'				X-_
	dc	i'0,0,0,0,0,0,0,0'					`-g
	dc	i'0,0,0,0,0,0,0,0'					h-o
	dc	i'0,0,0,0,0,0,0,0'					p-w
	dc	i'0,0,0,lbracech,0,rbracech,tildech,0'			x-rub

	dc	i'0,0,0,0,0,0,0,0'					nul-bel
	dc	i'0,0,0,0,0,0,0,0'					bs-si
	dc	i'0,0,0,0,0,0,0,0'					dle-etb
	dc	i'0,0,0,0,0,0,0,0'					can-us
	dc	i'0,0,0,0,0,0,0,0'					space-'
	dc	i'0,0,0,0,0,exceqop,0,0'					(-/
	dc	i'0,0,lteqop,gteqop,0,0,0,0'				0-7
	dc	i'0,0,0,0,0,0,0,0'					8-?
	dc	i'0,0,0,0,0,0,0,ltltop'					@-G
	dc	i'gtgtop,0,0,0,0,0,0,0'					H-O
	dc	i'0,0,0,0,0,0,slashch,0'					P-W
	dc	i'0,0,0,0,0,0,0,0'					X-_
	dc	i'0,0,0,0,0,0,0,0'					`-g
	dc	i'0,0,0,0,0,0,0,0'					h-o
	dc	i'0,0,0,0,0,0,0,0'					p-w
	dc	i'0,0,0,0,0,0,0,0'					x-rub
	end

! in comming priority for expression
icp	start
!			assumes notAnOperation = 200
	dc	i1'200'	ident
	dc	i1'200'	intconst
	dc	i1'200'	uintconst
	dc	i1'200'	longconst
	dc	i1'200'	ulongconst
	dc	i1'200'	doubleconst
	dc	i1'200'	stringconst
	dc	i1'200'	autosy
	dc	i1'200'	asmsy
	dc	i1'200'	breaksy
	dc	i1'200'	casesy
	dc	i1'200'	charsy
	dc	i1'200'	continuesy
	dc	i1'200'	constsy
	dc	i1'200'	compsy
	dc	i1'200'	defaultsy
	dc	i1'200'	dosy
	dc	i1'200'	doublesy
	dc	i1'200'	elsesy
	dc	i1'200'	enumsy
	dc	i1'200'	externsy
	dc	i1'200'	extendedsy
	dc	i1'200'	floatsy
	dc	i1'200'	forsy
	dc	i1'200'	gotosy
	dc	i1'200'	ifsy
	dc	i1'200'	intsy
	dc	i1'200'	inlinesy
	dc	i1'200'	longsy
	dc	i1'200'	pascalsy
	dc	i1'200'	registersy
	dc	i1'200'	returnsy
	dc	i1'200'	shortsy
	dc	i1'16'	sizeofsy
	dc	i1'200'	staticsy
	dc	i1'200'	structsy
	dc	i1'200'	switchsy
	dc	i1'200'	segmentsy
	dc	i1'200'	signedsy
	dc	i1'200'	typedefsy
	dc	i1'200'	unionsy
	dc	i1'200'	unsignedsy
	dc	i1'200'	voidsy
	dc	i1'200'	volatilesy
	dc	i1'200'	whilesy
	dc	i1'16'	excch
	dc	i1'15'	percentch
	dc	i1'9'	carotch
	dc	i1'10'	andch
	dc	i1'15'	asteriskch
	dc	i1'14'	minusch
	dc	i1'14'	plusch
	dc	i1'3'	eqch
	dc	i1'16'	tildech
	dc	i1'8'	barch
	dc	i1'200'	dotch
	dc	i1'12'	ltch
	dc	i1'12'	gtch
	dc	i1'15'	slashch
	dc	i1'5'	questionch
	dc	i1'16'	lparench
	dc	i1'200'	rparench
	dc	i1'200'	lbrackch
	dc	i1'200'	rbrackch
	dc	i1'200'	lbracech
	dc	i1'200'	rbracech
	dc	i1'1'	commach
	dc	i1'200'	semicolonch
	dc	i1'5'	colonch
	dc	i1'200'	poundch
	dc	i1'200'	minusgtop
	dc	i1'16'	plusplusop
	dc	i1'16'	minusminusop
	dc	i1'13'	ltltop
	dc	i1'13'	gtgtop
	dc	i1'12'	lteqop
	dc	i1'12'	gteqop
	dc	i1'11'	eqeqop
	dc	i1'11'	exceqop
	dc	i1'7'	andandop
	dc	i1'6'	barbarop
	dc	i1'3'	pluseqop
	dc	i1'3'	minuseqop
	dc	i1'3'	asteriskeqop
	dc	i1'3'	slasheqop
	dc	i1'3'	percenteqop
	dc	i1'3'	ltlteqop
	dc	i1'3'	gtgteqop
	dc	i1'3'	andeqop
	dc	i1'3'	caroteqop
	dc	i1'3'	bareqop
	dc	i1'200'	poundpoundop
	dc	i1'200'	eolsy
	dc	i1'200'	eofsy
	dc	i1'200'	typedef
	dc	i1'16'	uminus
	dc	i1'16'	uand
	dc	i1'16'	uasterisk
	dc	i1'200'	parameteroper
	dc	i1'16'	castoper
	dc	i1'16'	opplusplus
	dc	i1'16'	opminusminus
	dc	i1'200'	macroParm
	end

! implied operand operation codes
iopcodes start

	dc	i1'$18'	 clc
	dc	i1'$D8'	 cld
	dc	i1'$58'	 cli
	dc	i1'$B8'	 clv
	dc	i1'$CA'	 dex
	dc	i1'$88'	 dey
	dc	i1'$E8'	 inx
	dc	i1'$C8'	 iny
	dc	i1'$EA'	 nop
	dc	i1'$48'	 pha
	dc	i1'$8B'	 phb
	dc	i1'$0B'	 phd
	dc	i1'$4B'	 phk
	dc	i1'$08'	 php
	dc	i1'$DA'	 phx
	dc	i1'$5A'	 phy
	dc	i1'$68'	 pla
	dc	i1'$AB'	 plb
	dc	i1'$2B'	 pld
	dc	i1'$28'	 plp
	dc	i1'$FA'	 plx
	dc	i1'$7A'	 ply
	dc	i1'$40'	 rti
	dc	i1'$6B'	 rtl
	dc	i1'$60'	 rts
	dc	i1'$38'	 sec
	dc	i1'$F8'	 sed
	dc	i1'$78'	 sei
	dc	i1'$DB'	 stp
	dc	i1'$AA'	 tax
	dc	i1'$A8'	 tay
	dc	i1'$5B'	 tcd
	dc	i1'$1B'	 tcs
	dc	i1'$7B'	 tdc
	dc	i1'$3B'	 tsc
	dc	i1'$BA'	 tsx
	dc	i1'$8A'	 txa
	dc	i1'$9A'	 txs
	dc	i1'$9B'	 txy
	dc	i1'$98'	 tya
	dc	i1'$BB'	 tyx
	dc	i1'$CB'	 wai
	dc	i1'$EB'	 xba
	dc	i1'$FB'	 xce
	end

! in stack priority for expression
isp	start
	dc	i1'0'	ident
	dc	i1'0'	intconst
	dc	i1'0'	uintconst
	dc	i1'0'	longconst
	dc	i1'0'	ulongconst
	dc	i1'0'	doubleconst
	dc	i1'0'	stringconst
	dc	i1'0'	autosy
	dc	i1'0'	asmsy
	dc	i1'0'	breaksy
	dc	i1'0'	casesy
	dc	i1'0'	charsy
	dc	i1'0'	continuesy
	dc	i1'0'	constsy
	dc	i1'0'	compsy
	dc	i1'0'	defaultsy
	dc	i1'0'	dosy
	dc	i1'0'	doublesy
	dc	i1'0'	elsesy
	dc	i1'0'	enumsy
	dc	i1'0'	externsy
	dc	i1'0'	extendedsy
	dc	i1'0'	floatsy
	dc	i1'0'	forsy
	dc	i1'0'	gotosy
	dc	i1'0'	ifsy
	dc	i1'0'	intsy
	dc	i1'0'	inlinesy
	dc	i1'0'	longsy
	dc	i1'0'	pascalsy
	dc	i1'0'	registersy
	dc	i1'0'	returnsy
	dc	i1'0'	shortsy
	dc	i1'16'	sizeofsy
	dc	i1'0'	staticsy
	dc	i1'0'	structsy
	dc	i1'0'	switchsy
	dc	i1'0'	segmentsy
	dc	i1'0'	signedsy
	dc	i1'0'	typedefsy
	dc	i1'0'	unionsy
	dc	i1'0'	unsignedsy
	dc	i1'0'	voidsy
	dc	i1'0'	volatilesy
	dc	i1'0'	whilesy
	dc	i1'16'	excch
	dc	i1'15'	percentch
	dc	i1'9'	carotch
	dc	i1'10'	andch
	dc	i1'15'	asteriskch
	dc	i1'14'	minusch
	dc	i1'14'	plusch
	dc	i1'2'	eqch
	dc	i1'16'	tildech
	dc	i1'8'	barch
	dc	i1'0'	dotch
	dc	i1'12'	ltch
	dc	i1'12'	gtch
	dc	i1'15'	slashch
	dc	i1'0'	questionch
	dc	i1'0'	lparench
	dc	i1'0'	rparench
	dc	i1'0'	lbrackch
	dc	i1'0'	rbrackch
	dc	i1'0'	lbracech
	dc	i1'0'	rbracech
	dc	i1'1'	commach
	dc	i1'0'	semicolonch
	dc	i1'4'	colonch
	dc	i1'0'	poundch
	dc	i1'0'	minusgtop
	dc	i1'16'	plusplusop
	dc	i1'16'	minusminusop
	dc	i1'13'	ltltop
	dc	i1'13'	gtgtop
	dc	i1'12'	lteqop
	dc	i1'12'	gteqop
	dc	i1'11'	eqeqop
	dc	i1'11'	exceqop
	dc	i1'7'	andandop
	dc	i1'6'	barbarop
	dc	i1'2'	pluseqop
	dc	i1'2'	minuseqop
	dc	i1'2'	asteriskeqop
	dc	i1'2'	slasheqop
	dc	i1'2'	percenteqop
	dc	i1'2'	ltlteqop
	dc	i1'2'	gtgteqop
	dc	i1'2'	andeqop
	dc	i1'2'	caroteqop
	dc	i1'2'	bareqop
	dc	i1'0'	poundpoundop
	dc	i1'0'	eolsy
	dc	i1'0'	eofsy
	dc	i1'0'	typedef
	dc	i1'16'	uminus
	dc	i1'16'	uand
	dc	i1'16'	uasterisk
	dc	i1'0'	parameteroper
	dc	i1'16'	castoper
	dc	i1'16'	opplusplus
	dc	i1'16'	opminusminus
	dc	i1'0'	macroParm
	end

! mini-assembler op code names
names	start

	dc	c'adcandaslbitcmpcopcpxcpydeceor'
	dc	c'incjmljmpjsljsrldaldxldylsrora'
	dc	c'peapeireprolrorsbcsepstastxsty'
	dc	c'stztrbtsb'
	dc	c'dcbdcwdcl'
	dc	c'brk'
	dc	c'mvnmvp'
	dc	c'bccbcsbeqbmibnebplbrabrlperbvc'
	dc	c'bvs'
	dc	c'clccldcliclvdexdeyinxinynoppha'
	dc	c'phbphdphkphpphxphyplaplbpldplp'
	dc	c'plxplyrtirtlrtssecsedseistptax'
	dc	c'taytcdtcstdctsctsxtxatxstxytya'
	dc	c'tyxwaixbaxce'
	end

nopcodes start
!		  acc     imm     dp	 dp_x	 dp_y	       operand order
!		  op      op_x    op_y	 i_dp_x	 i_dp_y
!		  dp_s    li_dp   la	 i_dp	 i_op
!		  i_la    i_op_x i_dp_s_y li_dp_y long_x

	dc	i1'0      ,$69    ,$65    ,$75    ,0       '	adc
	dc	i1'$6D    ,$7D    ,$79    ,$61    ,$71     '
	dc	i1'$63    ,$67    ,$6F    ,$72    ,0       '
	dc	i1'0      ,0      ,$73    ,$77    ,$7F     '

	dc	i1'0      ,$29    ,$25    ,$35    ,0       '	and
	dc	i1'$2D    ,$3D    ,$39    ,$21    ,$31     '
	dc	i1'$23    ,$27    ,$2F    ,$32    ,0       '
	dc	i1'0      ,0      ,$33    ,$37    ,$3F     '

	dc	i1'$0A    ,0      ,$06    ,$16    ,0       '	asl
	dc	i1'$0E    ,$1E    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$89    ,$24    ,$34    ,0       '	bit
	dc	i1'$2C    ,$3C    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$C9    ,$C5    ,$D5    ,0       '	cmp
	dc	i1'$CD    ,$DD    ,$D9    ,$C1    ,$D1     '
	dc	i1'$C3    ,$C7    ,$CF    ,$D2    ,0       '
	dc	i1'0      ,0      ,$D3    ,$D7    ,$DF     '

	dc	i1'0      ,0      ,$02    ,0      ,0       '	cop
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$E0    ,$E4    ,0      ,0       '	cpx
	dc	i1'$EC    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$C0    ,$C4    ,0      ,0       '	cpy
	dc	i1'$CC    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'$3A    ,0      ,$C6    ,$D6    ,0       '	dec
	dc	i1'$CE    ,$DE    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$49    ,$45    ,$55    ,0       '	eor
	dc	i1'$4D    ,$5D    ,$59    ,$41    ,$51     '
	dc	i1'$43    ,$47    ,$4F    ,$52    ,0       '
	dc	i1'0      ,0      ,$53    ,$57    ,$5F     '

	dc	i1'$1A    ,0      ,$E6    ,$F6    ,0       '	inc
	dc	i1'$EE    ,$FE    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,0      ,0      ,0       '	jml
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,$5C    ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,0      ,0      ,0       '	jmp
	dc	i1'$4C    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,$5C    ,0      ,$6C     '
	dc	i1'$DC    ,$7C    ,0      ,0      ,0       '

	dc	i1'0      ,0      ,0      ,0      ,0       '	jsl
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,$22    ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,0      ,0      ,0       '	jsr
	dc	i1'$20    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,$22    ,0      ,0       '
	dc	i1'0      ,$FC    ,0      ,0      ,0       '

	dc	i1'0      ,$A9    ,$A5    ,$B5    ,0       '	lda
	dc	i1'$AD    ,$BD    ,$B9    ,$A1    ,$B1     '
	dc	i1'$A3    ,$A7    ,$AF    ,$B2    ,0       '
	dc	i1'0      ,0      ,$B3    ,$B7    ,$BF     '

	dc	i1'0      ,$A2    ,$A6    ,0      ,$B6     '	ldx
	dc	i1'$AE    ,0      ,$BE    ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$A0    ,$A4    ,$B4    ,0       '	ldy
	dc	i1'$AC    ,$BC    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'$4A    ,0      ,$46    ,$56    ,0       '	lsr
	dc	i1'$4E    ,$5E    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$09    ,$05    ,$15    ,0       '	ora
	dc	i1'$0D    ,$1D    ,$19    ,$01    ,$11     '
	dc	i1'$03    ,$07    ,$0F    ,$12    ,0       '
	dc	i1'0      ,0      ,$13    ,$17    ,$1F     '

	dc	i1'0      ,0      ,0      ,0      ,0       '	pea
	dc	i1'$F4    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$D4    ,0      ,0       '	pei
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,$D4    ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$C2    ,0      ,0      ,0       '	rep
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'$2A    ,0      ,$26    ,$36    ,0       '	rol
	dc	i1'$2E    ,$3E    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'$6A    ,0      ,$66    ,$76    ,0       '	ror
	dc	i1'$6E    ,$7E    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,$E9    ,$E5    ,$F5    ,0       '	sbc
	dc	i1'$ED    ,$FD    ,$F9    ,$E1    ,$F1     '
	dc	i1'$E3    ,$E7    ,$EF    ,$F2    ,0       '
	dc	i1'0      ,0      ,$F3    ,$F7    ,$FF     '

	dc	i1'0      ,$E2    ,0      ,0      ,0       '	sep
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$85    ,$95    ,0       '	sta
	dc	i1'$8D    ,$9D    ,$99    ,$81    ,$91     '
	dc	i1'$83    ,$87    ,$8F    ,$92    ,0       '
	dc	i1'0      ,0      ,$93    ,$97    ,$9F     '

	dc	i1'0      ,0      ,$86    ,0      ,$96     '	stx
	dc	i1'$8E    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$84    ,$94    ,0       '	sty
	dc	i1'$8C    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$64    ,$74    ,0       '	stz
	dc	i1'$9C    ,$9E    ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$14    ,0      ,0       '	trb
	dc	i1'$1C    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '

	dc	i1'0      ,0      ,$04    ,0      ,0       '	tsb
	dc	i1'$0C    ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	dc	i1'0      ,0      ,0      ,0      ,0       '
	end

! reserved word names
reservedWords start
	str8	auto
	str8	asm
	str8	break
	str8	case
	str8	char
	str8	continue
	str8	const
	str8	comp
	str8	default
	str8	do
	str8	double
	str8	else
	str8	enum
	str8	extern
	str8	extended
	str8	float
	str8	for
	str8	goto
	str8	if
	str8	int
	str8	inline
	str8	long
	str8	pascal
	str8	register
	str8	return
	str8	short
	str8	sizeof
	str8	static
	str8	struct
	str8	switch
	str8	segment
	str8	signed
	str8	typedef
	str8	union
	str8	unsigned
	str8	void
	str8	volatile
	str8	while
	end

ropcodes start

	dc	i1'$90'	 bcc
	dc	i1'$B0'	 bcs
	dc	i1'$F0'	 beq
	dc	i1'$30'	 bmi
	dc	i1'$D0'	 bne
	dc	i1'$10'	 bpl
	dc	i1'$80'	 bra
	dc	i1'$82'	 brl
	dc	i1'$62'	 per
	dc	i1'$50'	 bvc
	dc	i1'$70'	 bvs
	end

! reserved word hash table
wordHash start

	enum	ident,0	identifiers
!			constants
	enum	(intconst,uintconst,longconst,ulongconst,doubleconst)
	enum	stringconst
!			reserved words
	enum	(autosy,asmsy,breaksy,casesy,charsy)
	enum	(continuesy,constsy,compsy,defaultsy,dosy)
	enum	(doublesy,elsesy,enumsy,externsy,extendedsy)
	enum	(floatsy,forsy,gotosy,ifsy,intsy)
	enum	(inlinesy,longsy,pascalsy,registersy,returnsy)
	enum	(shortsy,sizeofsy,staticsy,structsy,switchsy)
	enum	(segmentsy,signedsy,typedefsy,unionsy,unsignedsy)
	enum	(voidsy,volatilesy,whilesy,succwhilesy)

	dc	i'autosy,breaksy,casesy,defaultsy,elsesy,floatsy'
	dc	i'gotosy,ifsy,ifsy,longsy,longsy,longsy'
	dc	i'pascalsy,pascalsy,pascalsy,pascalsy,registersy,registersy'
	dc	i'shortsy,typedefsy,unionsy,voidsy,whilesy,succwhilesy'
	end
