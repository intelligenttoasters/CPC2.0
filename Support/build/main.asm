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
	.globl _hdmi_read
	.globl _hdmi_init
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
	.globl _sprintf
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
	C$main.c$34$1$82	= .
	.globl	C$main.c$34$1$82
;../src/main.c:34: memset( globals(), 0, sizeof( struct global_vars ) );
	call	_globals
	ld	(hl), #0x00
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x0422
	ldir
	C$main.c$37$1$82	= .
	.globl	C$main.c$37$1$82
;../src/main.c:37: stdio_init();
	call	_stdio_init
	C$main.c$40$1$82	= .
	.globl	C$main.c$40$1$82
;../src/main.c:40: hdmi_init();
	C$main.c$42$1$82	= .
	.globl	C$main.c$42$1$82
	XG$init$0$0	= .
	.globl	XG$init$0$0
	jp  _hdmi_init
	G$main$0$0	= .
	.globl	G$main$0$0
	C$main.c$45$1$82	= .
	.globl	C$main.c$45$1$82
;../src/main.c:45: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	hl,#-80
	add	hl,sp
	ld	sp,hl
	C$main.c$50$1$84	= .
	.globl	C$main.c$50$1$84
;../src/main.c:50: init();
	call	_init
	C$main.c$54$1$84	= .
	.globl	C$main.c$54$1$84
;../src/main.c:54: while(!spi_connected()) process_events();
00101$:
	call	_spi_connected
	ld	a,l
	or	a, a
	jr	NZ,00103$
	call	_process_events
	jr	00101$
00103$:
	C$main.c$57$1$84	= .
	.globl	C$main.c$57$1$84
;../src/main.c:57: puts("\033[2J\033[HCPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	ld	hl,#___str_0
	push	hl
	call	_puts
	pop	af
	call	_ul
	C$main.c$60$1$84	= .
	.globl	C$main.c$60$1$84
;../src/main.c:60: sprintf(buffer, "HDMI chip ID : 0x%02x%02x", hdmi_read( 0xf5 ), hdmi_read( 0xf6 ));
	ld	a,#0xf6
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	e,l
	ld	d,#0x00
	push	de
	ld	a,#0xf5
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	c,l
	pop	de
	ld	b,#0x00
	ld	hl,#0x0000
	add	hl,sp
	push	hl
	pop	iy
	push	hl
	push	de
	push	bc
	ld	bc,#___str_1
	push	bc
	push	iy
	call	_sprintf
	ld	hl,#8
	add	hl,sp
	ld	sp,hl
	call	_console
	C$main.c$63$1$84	= .
	.globl	C$main.c$63$1$84
;../src/main.c:63: puts("Echoing back");
	ld	hl, #___str_2
	ex	(sp),hl
	call	_puts
	C$main.c$64$1$84	= .
	.globl	C$main.c$64$1$84
;../src/main.c:64: putchari('>');
	ld	h,#0x3e
	ex	(sp),hl
	inc	sp
	call	_putchari
	inc	sp
	C$main.c$69$2$85	= .
	.globl	C$main.c$69$2$85
;../src/main.c:69: while(spi_avail() == 0) process_events();
00104$:
	call	_spi_avail
	ld	a,l
	or	a, a
	jr	NZ,00106$
	call	_process_events
	jr	00104$
00106$:
	C$main.c$70$2$85	= .
	.globl	C$main.c$70$2$85
;../src/main.c:70: putchari( getchar() );
	call	_getchar
	ld	b,l
	push	bc
	inc	sp
	call	_putchari
	inc	sp
	C$main.c$73$1$84	= .
	.globl	C$main.c$73$1$84
	XG$main$0$0	= .
	.globl	XG$main$0$0
	jr	00104$
Fmain$__str_0$0$0 == .
___str_0:
	.db 0x1b
	.ascii "[2J"
	.db 0x1b
	.ascii "[HCPC2.0 Boot Log - Supervisor OS, build #1181"
	.db 0x00
Fmain$__str_1$0$0 == .
___str_1:
	.ascii "HDMI chip ID : 0x%02x%02x"
	.db 0x00
Fmain$__str_2$0$0 == .
___str_2:
	.ascii "Echoing back"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
