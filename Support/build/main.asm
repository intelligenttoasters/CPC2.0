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
	.globl _fdcUnmount
	.globl _fdcMount
	.globl _fdcInit
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
	C$main.c$34$1$73	= .
	.globl	C$main.c$34$1$73
;../src/main.c:34: memset( globals(), 0, sizeof( struct global_vars ) );
	call	_globals
	ld	b, #0x88
00103$:
	ld	(hl), #0x00
	inc	hl
	djnz	00103$
	C$main.c$37$1$73	= .
	.globl	C$main.c$37$1$73
;../src/main.c:37: stdioInit();
	call	_stdioInit
	C$main.c$40$1$73	= .
	.globl	C$main.c$40$1$73
;../src/main.c:40: puts("CPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	ld	hl,#___str_0
	push	hl
	call	_puts
	pop	af
	call	_ul
	C$main.c$41$1$73	= .
	.globl	C$main.c$41$1$73
;../src/main.c:41: console("Starting");
	ld	hl,#___str_1
	push	hl
	call	_console
	pop	af
	C$main.c$44$1$73	= .
	.globl	C$main.c$44$1$73
;../src/main.c:44: key_clear();
	call	_key_clear
	C$main.c$47$1$73	= .
	.globl	C$main.c$47$1$73
;../src/main.c:47: hdmi_init();
	call	_hdmi_init
	C$main.c$50$1$73	= .
	.globl	C$main.c$50$1$73
;../src/main.c:50: kbdInit();
	call	_kbdInit
	C$main.c$53$1$73	= .
	.globl	C$main.c$53$1$73
;../src/main.c:53: fdcInit();
	C$main.c$54$1$73	= .
	.globl	C$main.c$54$1$73
	XG$init$0$0	= .
	.globl	XG$init$0$0
	jp  _fdcInit
Fmain$__str_0$0$0 == .
___str_0:
	.ascii "CPC2.0 Boot Log - Supervisor OS, build #2410"
	.db 0x00
Fmain$__str_1$0$0 == .
___str_1:
	.ascii "Starting"
	.db 0x00
	G$main$0$0	= .
	.globl	G$main$0$0
	C$main.c$57$1$73	= .
	.globl	C$main.c$57$1$73
;../src/main.c:57: void main(void)
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
	C$main.c$62$1$75	= .
	.globl	C$main.c$62$1$75
;../src/main.c:62: init();
	call	_init
	C$main.c$67$2$76	= .
	.globl	C$main.c$67$2$76
;../src/main.c:67: while(uartAvail() == 0) processEvents();
00101$:
	call	_uartAvail
	ld	a,l
	or	a, a
	jr	NZ,00103$
	call	_processEvents
	jr	00101$
00103$:
	C$main.c$68$2$76	= .
	.globl	C$main.c$68$2$76
;../src/main.c:68: c = getchar();
	call	_getchar
	C$main.c$70$2$76	= .
	.globl	C$main.c$70$2$76
;../src/main.c:70: if( c == 'm' ) { fdcMount(); continue; }
	ld	-5 (ix), l
	ld	a, l
	sub	a, #0x6d
	jr	NZ,00105$
	call	_fdcMount
	jr	00101$
00105$:
	C$main.c$71$2$76	= .
	.globl	C$main.c$71$2$76
;../src/main.c:71: if( c == 'u' ) { fdcUnmount(); continue; }
	ld	a,-5 (ix)
	sub	a, #0x75
	jr	NZ,00107$
	call	_fdcUnmount
	jr	00101$
00107$:
	C$main.c$73$2$76	= .
	.globl	C$main.c$73$2$76
;../src/main.c:73: hdmi_write(0x96,0);
	ld	hl,#0x0096
	push	hl
	call	_hdmi_write
	C$main.c$74$2$76	= .
	.globl	C$main.c$74$2$76
;../src/main.c:74: printf("CTS Calculated : %02x %02x %02x INT:%02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06),hdmi_read(0x96));
	ld	h,#0x96
	ex	(sp),hl
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	-2 (ix),l
	ld	-1 (ix),#0x00
	ld	a,#0x06
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	-4 (ix),l
	ld	-3 (ix),#0x00
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
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	push	hl
	push	de
	push	bc
	ld	hl,#___str_2
	push	hl
	call	_printf
	ld	hl,#10
	add	hl,sp
	ld	sp,hl
	C$main.c$75$2$76	= .
	.globl	C$main.c$75$2$76
;../src/main.c:75: putchar( c );
	ld	a,-5 (ix)
	push	af
	inc	sp
	call	_putchar
	inc	sp
	C$main.c$78$1$75	= .
	.globl	C$main.c$78$1$75
	XG$main$0$0	= .
	.globl	XG$main$0$0
	jp	00101$
Fmain$__str_2$0$0 == .
___str_2:
	.ascii "CTS Calculated : %02x %02x %02x INT:%02x"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
