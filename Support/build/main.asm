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
	.globl _kbdInit
	.globl _key_clear
	.globl _hdmi_write
	.globl _hdmi_read
	.globl _hdmi_init
	.globl _uartAvail
	.globl _getchar
	.globl _putchar
	.globl _stdioInit
	.globl _ul
	.globl _console
	.globl _processEvents
	.globl _globals
	.globl _puts
	.globl _printf
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
	C$main.c$34$1$71	= .
	.globl	C$main.c$34$1$71
;../src/main.c:34: memset( globals(), 0, sizeof( struct global_vars ) );
	call	_globals
	ld	b, #0x88
00103$:
	ld	(hl), #0x00
	inc	hl
	djnz	00103$
	C$main.c$37$1$71	= .
	.globl	C$main.c$37$1$71
;../src/main.c:37: stdioInit();
	call	_stdioInit
	C$main.c$40$1$71	= .
	.globl	C$main.c$40$1$71
;../src/main.c:40: puts("CPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	ld	hl,#___str_0
	push	hl
	call	_puts
	pop	af
	call	_ul
	C$main.c$41$1$71	= .
	.globl	C$main.c$41$1$71
;../src/main.c:41: console("Starting");
	ld	hl,#___str_1
	push	hl
	call	_console
	pop	af
	C$main.c$44$1$71	= .
	.globl	C$main.c$44$1$71
;../src/main.c:44: key_clear();
	call	_key_clear
	C$main.c$47$1$71	= .
	.globl	C$main.c$47$1$71
;../src/main.c:47: hdmi_init();
	call	_hdmi_init
	C$main.c$50$1$71	= .
	.globl	C$main.c$50$1$71
;../src/main.c:50: kbdInit();
	C$main.c$51$1$71	= .
	.globl	C$main.c$51$1$71
	XG$init$0$0	= .
	.globl	XG$init$0$0
	jp  _kbdInit
Fmain$__str_0$0$0 == .
___str_0:
	.ascii "CPC2.0 Boot Log - Supervisor OS, build #1880"
	.db 0x00
Fmain$__str_1$0$0 == .
___str_1:
	.ascii "Starting"
	.db 0x00
	G$main$0$0	= .
	.globl	G$main$0$0
	C$main.c$54$1$71	= .
	.globl	C$main.c$54$1$71
;../src/main.c:54: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
	C$main.c$59$1$73	= .
	.globl	C$main.c$59$1$73
;../src/main.c:59: init();
	call	_init
	C$main.c$85$2$74	= .
	.globl	C$main.c$85$2$74
;../src/main.c:85: while(uartAvail() == 0) processEvents();
00101$:
	call	_uartAvail
	ld	a,l
	or	a, a
	jr	NZ,00103$
	call	_processEvents
	jr	00101$
00103$:
	C$main.c$86$2$74	= .
	.globl	C$main.c$86$2$74
;../src/main.c:86: c = getchar();
	call	_getchar
	ld	-5 (ix),l
	C$main.c$87$2$74	= .
	.globl	C$main.c$87$2$74
;../src/main.c:87: hdmi_write(0x96,0);
	ld	hl,#0x0096
	push	hl
	call	_hdmi_write
	C$main.c$88$2$74	= .
	.globl	C$main.c$88$2$74
;../src/main.c:88: printf("CTS Calculated : %02x %02x %02x INT:%02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06),hdmi_read(0x96));
	ld	h,#0x96
	ex	(sp),hl
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	-4 (ix),l
	ld	-3 (ix),#0x00
	ld	a,#0x06
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	-2 (ix),l
	ld	-1 (ix),#0x00
	ld	a,#0x05
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	e,l
	ld	d,#0x00
	push	de
	ld	a,#0x04
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	c,l
	pop	de
	ld	b,#0x00
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	push	de
	push	bc
	ld	hl,#___str_2
	push	hl
	call	_printf
	ld	hl,#10
	add	hl,sp
	ld	sp,hl
	C$main.c$89$2$74	= .
	.globl	C$main.c$89$2$74
;../src/main.c:89: putchar( c );
	ld	a,-5 (ix)
	push	af
	inc	sp
	call	_putchar
	inc	sp
	C$main.c$92$1$73	= .
	.globl	C$main.c$92$1$73
	XG$main$0$0	= .
	.globl	XG$main$0$0
	jr	00101$
Fmain$__str_2$0$0 == .
___str_2:
	.ascii "CTS Calculated : %02x %02x %02x INT:%02x"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
