;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.7.0 #10231 (Linux)
;--------------------------------------------------------
	.module library
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _putchar
	.globl _printf
	.globl _sdcProcessEvents
	.globl _fdcProcessEvents
	.globl _kbdProcessEvents
	.globl _hdmiProcessEvents
	.globl _uartProcessEvents
	.globl _INI
	.globl _OUTI
	.globl _globals
	.globl _processEvents
	.globl _earlyEvents
	.globl _console
	.globl _ul
	.globl _OUTIe
	.globl _INIe
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
Flibrary$global_variables$0$0==.
_global_variables:
	.ds 3989
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
Flibrary$msgno$0$0==.
_msgno:
	.ds 4
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	G$globals$0$0	= .
	.globl	G$globals$0$0
	C$library.c$34$0$138	= .
	.globl	C$library.c$34$0$138
;../src/library/library.c:34: inline struct global_vars * globals()
;	---------------------------------
; Function globals
; ---------------------------------
_globals::
	C$library.c$36$1$138	= .
	.globl	C$library.c$36$1$138
;../src/library/library.c:36: return &global_variables;
	ld	hl, #_global_variables
	C$library.c$37$1$138	= .
	.globl	C$library.c$37$1$138
;../src/library/library.c:37: }
	C$library.c$37$1$138	= .
	.globl	C$library.c$37$1$138
	XG$globals$0$0	= .
	.globl	XG$globals$0$0
	ret
	G$processEvents$0$0	= .
	.globl	G$processEvents$0$0
	C$library.c$39$1$139	= .
	.globl	C$library.c$39$1$139
;../src/library/library.c:39: void processEvents()
;	---------------------------------
; Function processEvents
; ---------------------------------
_processEvents::
	C$library.c$41$1$139	= .
	.globl	C$library.c$41$1$139
;../src/library/library.c:41: uartProcessEvents();
	call	_uartProcessEvents
	C$library.c$42$1$139	= .
	.globl	C$library.c$42$1$139
;../src/library/library.c:42: hdmiProcessEvents();
	call	_hdmiProcessEvents
	C$library.c$44$1$139	= .
	.globl	C$library.c$44$1$139
;../src/library/library.c:44: kbdProcessEvents();
	call	_kbdProcessEvents
	C$library.c$45$1$139	= .
	.globl	C$library.c$45$1$139
;../src/library/library.c:45: sdcProcessEvents();
	call	_sdcProcessEvents
	C$library.c$46$1$139	= .
	.globl	C$library.c$46$1$139
;../src/library/library.c:46: fdcProcessEvents();
	C$library.c$47$1$139	= .
	.globl	C$library.c$47$1$139
;../src/library/library.c:47: }
	C$library.c$47$1$139	= .
	.globl	C$library.c$47$1$139
	XG$processEvents$0$0	= .
	.globl	XG$processEvents$0$0
	jp  _fdcProcessEvents
	G$earlyEvents$0$0	= .
	.globl	G$earlyEvents$0$0
	C$library.c$49$1$140	= .
	.globl	C$library.c$49$1$140
;../src/library/library.c:49: void earlyEvents()
;	---------------------------------
; Function earlyEvents
; ---------------------------------
_earlyEvents::
	C$library.c$51$1$140	= .
	.globl	C$library.c$51$1$140
;../src/library/library.c:51: uartProcessEvents();
	call	_uartProcessEvents
	C$library.c$52$1$140	= .
	.globl	C$library.c$52$1$140
;../src/library/library.c:52: sdcProcessEvents();
	C$library.c$53$1$140	= .
	.globl	C$library.c$53$1$140
;../src/library/library.c:53: }
	C$library.c$53$1$140	= .
	.globl	C$library.c$53$1$140
	XG$earlyEvents$0$0	= .
	.globl	XG$earlyEvents$0$0
	jp  _sdcProcessEvents
	G$console$0$0	= .
	.globl	G$console$0$0
	C$library.c$56$1$142	= .
	.globl	C$library.c$56$1$142
;../src/library/library.c:56: void console(char *msg)
;	---------------------------------
; Function console
; ---------------------------------
_console::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	C$library.c$58$1$142	= .
	.globl	C$library.c$58$1$142
;../src/library/library.c:58: printf("[%08ld] %s\n", msgno++, msg);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #_msgno
	ld	bc, #4
	ldir
	ld	iy, #_msgno
	inc	0 (iy)
	jr	NZ,00103$
	inc	1 (iy)
	jr	NZ,00103$
	inc	2 (iy)
	jr	NZ,00103$
	inc	3 (iy)
00103$:
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	hl, #___str_0
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
	C$library.c$59$1$142	= .
	.globl	C$library.c$59$1$142
;../src/library/library.c:59: }
	ld	sp, ix
	pop	ix
	C$library.c$59$1$142	= .
	.globl	C$library.c$59$1$142
	XG$console$0$0	= .
	.globl	XG$console$0$0
	ret
Flibrary$__str_0$0$0 == .
___str_0:
	.ascii "[%08ld] %s"
	.db 0x0a
	.db 0x00
	G$ul$0$0	= .
	.globl	G$ul$0$0
	C$library.c$62$1$143	= .
	.globl	C$library.c$62$1$143
;../src/library/library.c:62: void ul()
;	---------------------------------
; Function ul
; ---------------------------------
_ul::
	C$library.c$65$1$143	= .
	.globl	C$library.c$65$1$143
;../src/library/library.c:65: for( cntr=0; cntr<_STD_WIDTH_ - 1; cntr++) putchar('=');
	ld	bc, #0x0000
00102$:
	push	bc
	ld	hl, #0x003d
	push	hl
	call	_putchar
	pop	af
	pop	bc
	inc	bc
	ld	a, c
	sub	a, #0x4f
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00102$
	C$library.c$66$1$143	= .
	.globl	C$library.c$66$1$143
;../src/library/library.c:66: putchar('\n');
	ld	hl, #0x000a
	push	hl
	call	_putchar
	pop	af
	C$library.c$67$1$143	= .
	.globl	C$library.c$67$1$143
;../src/library/library.c:67: }
	C$library.c$67$1$143	= .
	.globl	C$library.c$67$1$143
	XG$ul$0$0	= .
	.globl	XG$ul$0$0
	ret
	G$OUTIe$0$0	= .
	.globl	G$OUTIe$0$0
	C$library.c$70$1$146	= .
	.globl	C$library.c$70$1$146
;../src/library/library.c:70: void OUTIe( char port, char * buffer, uint16_t size)
;	---------------------------------
; Function OUTIe
; ---------------------------------
_OUTIe::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
	C$library.c$72$1$146	= .
	.globl	C$library.c$72$1$146
;../src/library/library.c:72: while( size > 0 )
	ld	c, 5 (ix)
	ld	b, 6 (ix)
00101$:
	ld	a, 8 (ix)
	or	a, 7 (ix)
	jr	Z,00104$
	C$library.c$74$1$146	= .
	.globl	C$library.c$74$1$146
;../src/library/library.c:74: OUTI( port, buffer, (size>255) ? 255 : size );
	ld	a, #0xff
	cp	a, 7 (ix)
	ld	a, #0x00
	sbc	a, 8 (ix)
	ld	a, #0x00
	rla
	ld	-1 (ix), a
	ld	e, 7 (ix)
	ld	d, 8 (ix)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00106$
	ld	hl, #0x00ff
	jr	00107$
00106$:
	ld	l, e
00107$:
	ld	h, l
	push	bc
	push	de
	push	hl
	inc	sp
	push	bc
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_OUTI
	pop	af
	pop	af
	pop	de
	pop	bc
	C$library.c$75$2$147	= .
	.globl	C$library.c$75$2$147
;../src/library/library.c:75: size -= (size>255) ? 255 : size;
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00108$
	ld	de, #0x00ff
00108$:
	ld	a, 7 (ix)
	sub	a, e
	ld	7 (ix), a
	ld	a, 8 (ix)
	sbc	a, d
	ld	8 (ix), a
	C$library.c$76$2$147	= .
	.globl	C$library.c$76$2$147
;../src/library/library.c:76: buffer += 255;
	ld	hl, #0x00ff
	add	hl, bc
	ld	c, l
	ld	b, h
	jr	00101$
00104$:
	C$library.c$78$1$146	= .
	.globl	C$library.c$78$1$146
;../src/library/library.c:78: }
	inc	sp
	pop	ix
	C$library.c$78$1$146	= .
	.globl	C$library.c$78$1$146
	XG$OUTIe$0$0	= .
	.globl	XG$OUTIe$0$0
	ret
	G$INIe$0$0	= .
	.globl	G$INIe$0$0
	C$library.c$80$1$149	= .
	.globl	C$library.c$80$1$149
;../src/library/library.c:80: void INIe( char port, char * buffer, uint16_t size)
;	---------------------------------
; Function INIe
; ---------------------------------
_INIe::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
	C$library.c$82$1$149	= .
	.globl	C$library.c$82$1$149
;../src/library/library.c:82: while( size > 0 )
	ld	c, 5 (ix)
	ld	b, 6 (ix)
00101$:
	ld	a, 8 (ix)
	or	a, 7 (ix)
	jr	Z,00104$
	C$library.c$84$1$149	= .
	.globl	C$library.c$84$1$149
;../src/library/library.c:84: INI( port, buffer, (size>255) ? 255 : size );
	ld	a, #0xff
	cp	a, 7 (ix)
	ld	a, #0x00
	sbc	a, 8 (ix)
	ld	a, #0x00
	rla
	ld	-1 (ix), a
	ld	e, 7 (ix)
	ld	d, 8 (ix)
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00106$
	ld	hl, #0x00ff
	jr	00107$
00106$:
	ld	l, e
00107$:
	ld	h, l
	push	bc
	push	de
	push	hl
	inc	sp
	push	bc
	ld	a, 4 (ix)
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	de
	pop	bc
	C$library.c$85$2$150	= .
	.globl	C$library.c$85$2$150
;../src/library/library.c:85: size -= (size>255) ? 255 : size;
	ld	a, -1 (ix)
	or	a, a
	jr	Z,00108$
	ld	de, #0x00ff
00108$:
	ld	a, 7 (ix)
	sub	a, e
	ld	7 (ix), a
	ld	a, 8 (ix)
	sbc	a, d
	ld	8 (ix), a
	C$library.c$86$2$150	= .
	.globl	C$library.c$86$2$150
;../src/library/library.c:86: buffer += 255;
	ld	hl, #0x00ff
	add	hl, bc
	ld	c, l
	ld	b, h
	jr	00101$
00104$:
	C$library.c$88$1$149	= .
	.globl	C$library.c$88$1$149
;../src/library/library.c:88: }
	inc	sp
	pop	ix
	C$library.c$88$1$149	= .
	.globl	C$library.c$88$1$149
	XG$INIe$0$0	= .
	.globl	XG$INIe$0$0
	ret
	.area _CODE
	.area _INITIALIZER
Flibrary$__xinit_msgno$0$0 == .
__xinit__msgno:
	.byte #0x00,#0x00,#0x00,#0x00	; 0
	.area _CABS (ABS)
