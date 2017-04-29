;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module library
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _putchar
	.globl _printf
	.globl _hdmiProcessEvents
	.globl _spiProcessEvents
	.globl _globals
	.globl _process_events
	.globl _console
	.globl _ul
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
Flibrary$global_variables$0$0==.
_global_variables:
	.ds 1059
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
	C$library.c$34$0$0	= .
	.globl	C$library.c$34$0$0
;../src/library/library.c:34: inline struct global_vars * globals()
;	---------------------------------
; Function globals
; ---------------------------------
_globals::
	C$library.c$36$1$62	= .
	.globl	C$library.c$36$1$62
;../src/library/library.c:36: return &global_variables;
	ld	hl,#_global_variables
	C$library.c$37$1$62	= .
	.globl	C$library.c$37$1$62
	XG$globals$0$0	= .
	.globl	XG$globals$0$0
	ret
	G$process_events$0$0	= .
	.globl	G$process_events$0$0
	C$library.c$39$1$62	= .
	.globl	C$library.c$39$1$62
;../src/library/library.c:39: inline void process_events()
;	---------------------------------
; Function process_events
; ---------------------------------
_process_events::
	C$library.c$41$1$63	= .
	.globl	C$library.c$41$1$63
;../src/library/library.c:41: spiProcessEvents();
	call	_spiProcessEvents
	C$library.c$42$1$63	= .
	.globl	C$library.c$42$1$63
;../src/library/library.c:42: hdmiProcessEvents();
	C$library.c$43$1$63	= .
	.globl	C$library.c$43$1$63
	XG$process_events$0$0	= .
	.globl	XG$process_events$0$0
	jp  _hdmiProcessEvents
	G$console$0$0	= .
	.globl	G$console$0$0
	C$library.c$46$1$63	= .
	.globl	C$library.c$46$1$63
;../src/library/library.c:46: void console(char *msg)
;	---------------------------------
; Function console
; ---------------------------------
_console::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	C$library.c$48$1$65	= .
	.globl	C$library.c$48$1$65
;../src/library/library.c:48: printf("[%08ld] %s\n", msgno++, msg);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #_msgno
	ld	bc, #4
	ldir
	ld	iy,#_msgno
	inc	0 (iy)
	jr	NZ,00103$
	inc	1 (iy)
	jr	NZ,00103$
	inc	2 (iy)
	jr	NZ,00103$
	inc	3 (iy)
00103$:
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	hl,#___str_0
	push	hl
	call	_printf
	ld	hl,#8
	add	hl,sp
	ld	sp,hl
	ld	sp, ix
	pop	ix
	C$library.c$49$1$65	= .
	.globl	C$library.c$49$1$65
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
	C$library.c$52$1$65	= .
	.globl	C$library.c$52$1$65
;../src/library/library.c:52: void ul()
;	---------------------------------
; Function ul
; ---------------------------------
_ul::
	C$library.c$55$1$66	= .
	.globl	C$library.c$55$1$66
;../src/library/library.c:55: for( cntr=0; cntr<_STD_WIDTH_ - 1; cntr++) putchar('=');
	ld	bc,#0x0000
00102$:
	push	bc
	ld	a,#0x3d
	push	af
	inc	sp
	call	_putchar
	inc	sp
	pop	bc
	inc	bc
	ld	a,c
	sub	a, #0x4f
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00102$
	C$library.c$56$1$66	= .
	.globl	C$library.c$56$1$66
;../src/library/library.c:56: putchar('\n');
	ld	a,#0x0a
	push	af
	inc	sp
	call	_putchar
	inc	sp
	C$library.c$57$1$66	= .
	.globl	C$library.c$57$1$66
	XG$ul$0$0	= .
	.globl	XG$ul$0$0
	ret
	.area _CODE
	.area _INITIALIZER
Flibrary$__xinit_msgno$0$0 == .
__xinit__msgno:
	.byte #0x00,#0x00,#0x00,#0x00	; 0
	.area _CABS (ABS)
