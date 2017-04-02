;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _init
	.globl _spi_connected
	.globl _spi_avail
	.globl _getchar
	.globl _putchari
	.globl _stdio_init
	.globl _ul
	.globl _console
	.globl _process_events
	.globl _globals
	.globl _puts
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
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
	G$init$0$0	= .
	.globl	G$init$0$0
	C$main.c$31$0$0	= .
	.globl	C$main.c$31$0$0
;../src/main.c:31: void init()
;	---------------------------------
; Function init
; ---------------------------------
_init::
	C$main.c$34$1$77	= .
	.globl	C$main.c$34$1$77
;../src/main.c:34: memset( globals(), 0, sizeof( struct global_vars ) );
	call	_globals
	ld	(hl), #0x00
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x0422
	ldir
	C$main.c$37$1$77	= .
	.globl	C$main.c$37$1$77
;../src/main.c:37: stdio_init();
	C$main.c$38$1$77	= .
	.globl	C$main.c$38$1$77
	XG$init$0$0	= .
	.globl	XG$init$0$0
	jp  _stdio_init
	G$main$0$0	= .
	.globl	G$main$0$0
	C$main.c$41$1$77	= .
	.globl	C$main.c$41$1$77
;../src/main.c:41: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	C$main.c$44$1$79	= .
	.globl	C$main.c$44$1$79
;../src/main.c:44: init();
	call	_init
	C$main.c$48$1$79	= .
	.globl	C$main.c$48$1$79
;../src/main.c:48: while(!spi_connected()) process_events();
00101$:
	call	_spi_connected
	ld	a,l
	or	a, a
	jr	NZ,00103$
	call	_process_events
	jr	00101$
00103$:
	C$main.c$51$1$79	= .
	.globl	C$main.c$51$1$79
;../src/main.c:51: puts("\033[2J\033[HCPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	ld	hl,#___str_0
	push	hl
	call	_puts
	pop	af
	call	_ul
	C$main.c$52$1$79	= .
	.globl	C$main.c$52$1$79
;../src/main.c:52: console("Bringing up video controller");
	ld	hl,#___str_1
	push	hl
	call	_console
	pop	af
	C$main.c$57$2$80	= .
	.globl	C$main.c$57$2$80
;../src/main.c:57: while(spi_avail() == 0) process_events();
00104$:
	call	_spi_avail
	ld	a,l
	or	a, a
	jr	NZ,00106$
	call	_process_events
	jr	00104$
00106$:
	C$main.c$58$2$80	= .
	.globl	C$main.c$58$2$80
;../src/main.c:58: putchari( getchar() );
	call	_getchar
	ld	b,l
	push	bc
	inc	sp
	call	_putchari
	inc	sp
	C$main.c$60$1$79	= .
	.globl	C$main.c$60$1$79
	XG$main$0$0	= .
	.globl	XG$main$0$0
	jr	00104$
Fmain$__str_0$0$0 == .
___str_0:
	.db 0x1b
	.ascii "[2J"
	.db 0x1b
	.ascii "[HCPC2.0 Boot Log - Supervisor OS, build #446"
	.db 0x00
Fmain$__str_1$0$0 == .
___str_1:
	.ascii "Bringing up video controller"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
