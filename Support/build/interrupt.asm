;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module interrupt
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _int_handler
	.globl _nmi_handler
	.globl _IN
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
	G$nmi_handler$0$0	= .
	.globl	G$nmi_handler$0$0
	C$interrupt.c$27$0$0	= .
	.globl	C$interrupt.c$27$0$0
;../src/interrupt.c:27: void nmi_handler(void)
;	---------------------------------
; Function nmi_handler
; ---------------------------------
_nmi_handler::
	C$interrupt.c$30$0$0	= .
	.globl	C$interrupt.c$30$0$0
;../src/interrupt.c:30: }
	C$interrupt.c$30$0$0	= .
	.globl	C$interrupt.c$30$0$0
	XG$nmi_handler$0$0	= .
	.globl	XG$nmi_handler$0$0
	ret
	G$int_handler$0$0	= .
	.globl	G$int_handler$0$0
	C$interrupt.c$35$0$0	= .
	.globl	C$interrupt.c$35$0$0
;../src/interrupt.c:35: void int_handler(void)
;	---------------------------------
; Function int_handler
; ---------------------------------
_int_handler::
	C$interrupt.c$39$1$46	= .
	.globl	C$interrupt.c$39$1$46
;../src/interrupt.c:39: int_src = IN(INTERRUPT_CONTROLLER_BASE);
	ld	a,#0x10
	push	af
	inc	sp
	call	_IN
	inc	sp
	C$interrupt.c$41$1$46	= .
	.globl	C$interrupt.c$41$1$46
;../src/interrupt.c:41: if( int_src & INT_UART )
	C$interrupt.c$44$1$46	= .
	.globl	C$interrupt.c$44$1$46
	XG$int_handler$0$0	= .
	.globl	XG$int_handler$0$0
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
