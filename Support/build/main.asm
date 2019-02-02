;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.7.0 #10231 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _dumpdata
	.globl _init
	.globl _configNew
	.globl _configInit
	.globl _fatPutConfig
	.globl _fatGetDescription
	.globl _fatSetContent
	.globl _fatFindFree
	.globl _fatWriteBlock
	.globl _fatReformat
	.globl _fatOpen
	.globl _fatInit
	.globl _sdcGetLastBlk
	.globl _sdcWriteBlock
	.globl _sdcReadBlock
	.globl _sdcInit
	.globl _romInit
	.globl _cpcResetRelease
	.globl _cpcResetHold
	.globl _cpcReset
	.globl _sramReady
	.globl _fdcChanged
	.globl _fdcMounted
	.globl _fdcUnmount
	.globl _fdcMount
	.globl _fdcInit
	.globl _keyCapture
	.globl _kbdInit
	.globl _key_clear
	.globl _hdmi_write
	.globl _hdmi_read
	.globl _hdmi_init
	.globl _outboundFlush
	.globl _uartAvail
	.globl _getchar
	.globl _putchar
	.globl _stdioInit
	.globl _ul
	.globl _console
	.globl _earlyEvents
	.globl _processEvents
	.globl _globals
	.globl _IN_
	.globl _puts
	.globl _sprintf
	.globl _printf
	.globl _rom_data
	.globl _dummy
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
G$dummy$0$0==.
_dummy::
	.ds 4
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
G$rom_data$0$0==.
_rom_data::
	.ds 315
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
	C$main.c$35$0$158	= .
	.globl	C$main.c$35$0$158
;../src/main.c:35: void init()
;	---------------------------------
; Function init
; ---------------------------------
_init::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-512
	add	hl, sp
	ld	sp, hl
	C$main.c$43$1$158	= .
	.globl	C$main.c$43$1$158
;../src/main.c:43: cpcResetHold();
	call	_cpcResetHold
	C$main.c$46$1$158	= .
	.globl	C$main.c$46$1$158
;../src/main.c:46: memset( globals(), 0, sizeof( struct global_vars ) );
	call	_globals
	ld	(hl), #0x00
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x0f94
	ldir
	C$main.c$49$1$158	= .
	.globl	C$main.c$49$1$158
;../src/main.c:49: stdioInit();
	call	_stdioInit
	C$main.c$52$1$158	= .
	.globl	C$main.c$52$1$158
;../src/main.c:52: puts("\033[2J\033[H");
	ld	hl, #___str_0
	push	hl
	call	_puts
	C$main.c$53$1$158	= .
	.globl	C$main.c$53$1$158
;../src/main.c:53: puts("CPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	ld	hl, #___str_1
	ex	(sp),hl
	call	_puts
	pop	af
	call	_ul
	C$main.c$54$1$158	= .
	.globl	C$main.c$54$1$158
;../src/main.c:54: console("Starting");
	ld	hl, #___str_2
	push	hl
	call	_console
	C$main.c$56$1$158	= .
	.globl	C$main.c$56$1$158
;../src/main.c:56: sprintf(buffer, "Write protect below %04x", IN(0x50)<< 8);
	ld	h,#0x50
	ex	(sp),hl
	inc	sp
	call	_IN_
	inc	sp
	ld	b, l
	ld	c, #0x00
	ld	hl, #0x0000
	add	hl, sp
	ld	e, l
	ld	d, h
	push	hl
	push	bc
	ld	bc, #___str_3
	push	bc
	push	de
	call	_sprintf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	call	_console
	C$main.c$60$1$158	= .
	.globl	C$main.c$60$1$158
;../src/main.c:60: console( "Waiting for SRAM1+2" );
	ld	hl, #___str_4
	ex	(sp),hl
	call	_console
	pop	af
	C$main.c$61$1$158	= .
	.globl	C$main.c$61$1$158
;../src/main.c:61: while( !sramReady() ) NOP();
00101$:
	call	_sramReady
	ld	a, l
	or	a, a
	jr	NZ,00103$
	nop
	jr	00101$
00103$:
	C$main.c$64$1$158	= .
	.globl	C$main.c$64$1$158
;../src/main.c:64: sdcInit(&globals()->sd_buf);
	call	_globals
	ld	bc, #0x0804
	add	hl, bc
	push	hl
	call	_sdcInit
	pop	af
	C$main.c$67$1$158	= .
	.globl	C$main.c$67$1$158
;../src/main.c:67: while( globals()->sd_buf.state != IDLE) earlyEvents();
00104$:
	call	_globals
	ld	bc, #0x0804
	add	hl, bc
	ld	de, #0x00bc
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z,00106$
	call	_earlyEvents
	jr	00104$
00106$:
	C$main.c$70$1$158	= .
	.globl	C$main.c$70$1$158
;../src/main.c:70: fatInit();
	call	_fatInit
	C$main.c$71$1$158	= .
	.globl	C$main.c$71$1$158
;../src/main.c:71: while( !globals()->fat.ready ) earlyEvents();
00107$:
	call	_globals
	ld	de, #0x08d7
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	NZ,00109$
	call	_earlyEvents
	jr	00107$
00109$:
	C$main.c$74$1$158	= .
	.globl	C$main.c$74$1$158
;../src/main.c:74: configInit();
	call	_configInit
	C$main.c$77$1$158	= .
	.globl	C$main.c$77$1$158
;../src/main.c:77: hdmi_init();
	call	_hdmi_init
	C$main.c$80$1$158	= .
	.globl	C$main.c$80$1$158
;../src/main.c:80: romInit();
	call	_romInit
	C$main.c$83$1$158	= .
	.globl	C$main.c$83$1$158
;../src/main.c:83: fdcInit();
	call	_fdcInit
	C$main.c$92$1$158	= .
	.globl	C$main.c$92$1$158
;../src/main.c:92: key_clear();
	call	_key_clear
	C$main.c$95$1$158	= .
	.globl	C$main.c$95$1$158
;../src/main.c:95: kbdInit();
	call	_kbdInit
	C$main.c$98$1$158	= .
	.globl	C$main.c$98$1$158
;../src/main.c:98: cpcResetRelease();
	call	_cpcResetRelease
	C$main.c$100$1$158	= .
	.globl	C$main.c$100$1$158
;../src/main.c:100: }
	ld	sp, ix
	pop	ix
	C$main.c$100$1$158	= .
	.globl	C$main.c$100$1$158
	XG$init$0$0	= .
	.globl	XG$init$0$0
	ret
Fmain$__str_0$0$0 == .
___str_0:
	.db 0x1b
	.ascii "[2J"
	.db 0x1b
	.ascii "[H"
	.db 0x00
Fmain$__str_1$0$0 == .
___str_1:
	.ascii "CPC2.0 Boot Log - Supervisor OS, build #5874"
	.db 0x00
Fmain$__str_2$0$0 == .
___str_2:
	.ascii "Starting"
	.db 0x00
Fmain$__str_3$0$0 == .
___str_3:
	.ascii "Write protect below %04x"
	.db 0x00
Fmain$__str_4$0$0 == .
___str_4:
	.ascii "Waiting for SRAM1+2"
	.db 0x00
	G$dumpdata$0$0	= .
	.globl	G$dumpdata$0$0
	C$main.c$102$1$160	= .
	.globl	C$main.c$102$1$160
;../src/main.c:102: void dumpdata(char * buffer)
;	---------------------------------
; Function dumpdata
; ---------------------------------
_dumpdata::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-6
	add	hl, sp
	ld	sp, hl
	C$main.c$106$1$160	= .
	.globl	C$main.c$106$1$160
;../src/main.c:106: outboundFlush();
	call	_outboundFlush
	C$main.c$108$4$163	= .
	.globl	C$main.c$108$4$163
;../src/main.c:108: for( cntr=0; cntr<512; cntr+=16) {
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00108$:
	C$main.c$109$3$162	= .
	.globl	C$main.c$109$3$162
;../src/main.c:109: printf("%04x ", cntr);
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
	C$main.c$110$1$160	= .
	.globl	C$main.c$110$1$160
;../src/main.c:110: for(cntr2=0; cntr2<16; cntr2++)
	ld	-4 (ix), #0x00
	ld	-3 (ix), #0x00
00104$:
	C$main.c$111$4$163	= .
	.globl	C$main.c$111$4$163
;../src/main.c:111: printf("%02x ", buffer[cntr+cntr2]);
	ld	a, -2 (ix)
	add	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, -3 (ix)
	ld	-5 (ix), a
	ld	a, 4 (ix)
	add	a, -6 (ix)
	ld	-6 (ix), a
	ld	a, 5 (ix)
	adc	a, -5 (ix)
	ld	-5 (ix), a
	pop	hl
	push	hl
	ld	c, (hl)
	ld	b, #0x00
	push	bc
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
	pop	af
	C$main.c$110$4$163	= .
	.globl	C$main.c$110$4$163
;../src/main.c:110: for(cntr2=0; cntr2<16; cntr2++)
	inc	-4 (ix)
	jr	NZ,00151$
	inc	-3 (ix)
00151$:
	ld	a, -4 (ix)
	sub	a, #0x10
	ld	a, -3 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00104$
	C$main.c$112$3$162	= .
	.globl	C$main.c$112$3$162
;../src/main.c:112: putchar(32);
	ld	hl, #0x0020
	push	hl
	call	_putchar
	pop	af
	C$main.c$113$1$160	= .
	.globl	C$main.c$113$1$160
;../src/main.c:113: for(cntr2=0; cntr2<16; cntr2++)
	ld	bc, #0x0000
00106$:
	C$main.c$114$4$164	= .
	.globl	C$main.c$114$4$164
;../src/main.c:114: printf("%c", ((buffer[cntr+cntr2]>32) && (buffer[cntr+cntr2]<127)) ? buffer[cntr+cntr2] : 32);
	ld	a, -2 (ix)
	add	a, c
	ld	e, a
	ld	a, -1 (ix)
	adc	a, b
	ld	d, a
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, de
	ld	e, (hl)
	ld	a, #0x20
	sub	a, e
	jr	NC,00112$
	ld	a, e
	sub	a, #0x7f
	jr	NC,00112$
	ld	d, #0x00
	jr	00113$
00112$:
	ld	de, #0x0020
00113$:
	push	bc
	push	de
	ld	hl, #___str_7
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
	C$main.c$113$4$164	= .
	.globl	C$main.c$113$4$164
;../src/main.c:113: for(cntr2=0; cntr2<16; cntr2++)
	inc	bc
	ld	a, c
	sub	a, #0x10
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00106$
	C$main.c$115$3$162	= .
	.globl	C$main.c$115$3$162
;../src/main.c:115: printf("\n");
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
	C$main.c$116$3$162	= .
	.globl	C$main.c$116$3$162
;../src/main.c:116: outboundFlush();
	call	_outboundFlush
	C$main.c$108$2$161	= .
	.globl	C$main.c$108$2$161
;../src/main.c:108: for( cntr=0; cntr<512; cntr+=16) {
	ld	a, -2 (ix)
	add	a, #0x10
	ld	-2 (ix), a
	jr	NC,00152$
	inc	-1 (ix)
00152$:
	ld	a, -1 (ix)
	xor	a, #0x80
	sub	a, #0x82
	jp	C, 00108$
	C$main.c$118$1$160	= .
	.globl	C$main.c$118$1$160
;../src/main.c:118: printf("\n");
	ld	hl, #___str_8
	push	hl
	call	_printf
	C$main.c$119$1$160	= .
	.globl	C$main.c$119$1$160
;../src/main.c:119: }
	ld	sp,ix
	pop	ix
	C$main.c$119$1$160	= .
	.globl	C$main.c$119$1$160
	XG$dumpdata$0$0	= .
	.globl	XG$dumpdata$0$0
	ret
Fmain$__str_5$0$0 == .
___str_5:
	.ascii "%04x "
	.db 0x00
Fmain$__str_6$0$0 == .
___str_6:
	.ascii "%02x "
	.db 0x00
Fmain$__str_7$0$0 == .
___str_7:
	.ascii "%c"
	.db 0x00
Fmain$__str_8$0$0 == .
___str_8:
	.db 0x0a
	.db 0x00
	G$main$0$0	= .
	.globl	G$main$0$0
	C$main.c$122$1$166	= .
	.globl	C$main.c$122$1$166
;../src/main.c:122: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-527
	add	hl, sp
	ld	sp, hl
	C$main.c$125$1$166	= .
	.globl	C$main.c$125$1$166
;../src/main.c:125: uint32_t x = 0;
	xor	a, a
	ld	-13 (ix), a
	ld	-12 (ix), a
	ld	-11 (ix), a
	ld	-10 (ix), a
	C$main.c$127$1$166	= .
	.globl	C$main.c$127$1$166
;../src/main.c:127: struct fat_sys_block * b = (struct fat_sys_block *) CB;
	call	_globals
	C$main.c$130$1$166	= .
	.globl	C$main.c$130$1$166
;../src/main.c:130: init();
	call	_init
	C$main.c$151$2$167	= .
	.globl	C$main.c$151$2$167
;../src/main.c:151: while(uartAvail() == 0) processEvents();
00101$:
	call	_uartAvail
	ld	a, l
	or	a, a
	jr	NZ,00103$
	call	_processEvents
	jr	00101$
00103$:
	C$main.c$152$2$167	= .
	.globl	C$main.c$152$2$167
;../src/main.c:152: c = getchar();
	call	_getchar
	C$main.c$153$2$167	= .
	.globl	C$main.c$153$2$167
;../src/main.c:153: if( c == 'M' ) { fdcMount(FDC_A, FDC_BLANK_2S80,"Empty 2S82"); continue; }	// Mount existing disk
	ld	-1 (ix), l
	ld	a, l
	sub	a, #0x4d
	jr	NZ,00105$
	ld	hl, #___str_9
	push	hl
	ld	hl, #0x8003
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_fdcMount
	pop	af
	pop	af
	inc	sp
	jr	00101$
00105$:
	C$main.c$154$2$167	= .
	.globl	C$main.c$154$2$167
;../src/main.c:154: if( c == 'm' ) { fdcMount(FDC_A, 0, NULL); continue; }	// Mount existing disk
	ld	a, -1 (ix)
	sub	a, #0x6d
	jr	NZ,00107$
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_fdcMount
	pop	af
	pop	af
	inc	sp
	jr	00101$
00107$:
	C$main.c$155$2$167	= .
	.globl	C$main.c$155$2$167
;../src/main.c:155: if( c == 'u' ) { fdcUnmount(FDC_A); continue; }
	ld	a, -1 (ix)
	sub	a, #0x75
	jr	NZ,00109$
	xor	a, a
	push	af
	inc	sp
	call	_fdcUnmount
	inc	sp
	jr	00101$
00109$:
	C$main.c$156$2$167	= .
	.globl	C$main.c$156$2$167
;../src/main.c:156: if( c == '?' ) { console(fdcMounted(FDC_A)?"Mounted":"Unmounted"); continue; }
	ld	a, -1 (ix)
	sub	a, #0x3f
	jr	NZ,00111$
	xor	a, a
	push	af
	inc	sp
	call	_fdcMounted
	inc	sp
	ld	a, l
	or	a, a
	jr	Z,00163$
	ld	de, #___str_10+0
	jr	00164$
00163$:
	ld	de, #___str_11+0
00164$:
	push	de
	call	_console
	pop	af
	jr	00101$
00111$:
	C$main.c$157$2$167	= .
	.globl	C$main.c$157$2$167
;../src/main.c:157: if( c == 'c' ) { console(fdcChanged(FDC_A)?"Changed":"Unchanged"); continue; }
	ld	a, -1 (ix)
	sub	a, #0x63
	jr	NZ,00113$
	xor	a, a
	push	af
	inc	sp
	call	_fdcChanged
	inc	sp
	ld	a, l
	or	a, a
	jr	Z,00165$
	ld	bc, #___str_12+0
	jr	00166$
00165$:
	ld	bc, #___str_13+0
00166$:
	push	bc
	call	_console
	pop	af
	jp	00101$
00113$:
	C$main.c$158$2$167	= .
	.globl	C$main.c$158$2$167
;../src/main.c:158: if( c == 'r' ) { cpcReset(); continue; }
	ld	a, -1 (ix)
	sub	a, #0x72
	jr	NZ,00115$
	call	_cpcReset
	jp	00101$
00115$:
	C$main.c$159$2$167	= .
	.globl	C$main.c$159$2$167
;../src/main.c:159: if( c == 'R' ) { __asm__("jp 0"); }
	ld	a, -1 (ix)
	sub	a, #0x52
	jp	Z,0
	jr	00117$
	jp	0
00117$:
	C$main.c$160$2$167	= .
	.globl	C$main.c$160$2$167
;../src/main.c:160: if( c == 'k' ) { keyCapture(); continue; }
	ld	a, -1 (ix)
	sub	a, #0x6b
	jr	NZ,00119$
	call	_keyCapture
	jp	00101$
00119$:
	C$main.c$161$2$167	= .
	.globl	C$main.c$161$2$167
;../src/main.c:161: if( c == 'l' ) {
	ld	a, -1 (ix)
	sub	a, #0x6c
	jr	NZ,00121$
	C$main.c$162$3$176	= .
	.globl	C$main.c$162$3$176
;../src/main.c:162: x=sdcGetLastBlk();
	call	_sdcGetLastBlk
	ld	-13 (ix), l
	ld	-12 (ix), h
	ld	-11 (ix), e
	ld	-10 (ix), d
00121$:
	C$main.c$164$2$167	= .
	.globl	C$main.c$164$2$167
;../src/main.c:164: if( c == 'n' ) {
	ld	a, -1 (ix)
	sub	a, #0x6e
	jr	NZ,00123$
	C$main.c$165$3$177	= .
	.globl	C$main.c$165$3$177
;../src/main.c:165: x = globals()->fat.section_ptr[FAT_BLKID_DISKDESC];
	call	_globals
	ld	-14 (ix), h
	ld	-15 (ix), l
	ld	a, l
	add	a, #0xd7
	ld	-15 (ix), a
	ld	a, -14 (ix)
	adc	a, #0x08
	ld	-14 (ix), a
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	ld	de, #0x0621
	add	hl, de
	ld	a, (hl)
	ld	-13 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-12 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-11 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-10 (ix), a
	C$main.c$166$2$167	= .
	.globl	C$main.c$166$2$167
;../src/main.c:166: DBG("Repositioned over names, go for read");
00123$:
	C$main.c$168$2$167	= .
	.globl	C$main.c$168$2$167
;../src/main.c:168: if( c == '0' ) {
	ld	a, -1 (ix)
	sub	a, #0x30
	jr	NZ,00125$
	C$main.c$169$3$178	= .
	.globl	C$main.c$169$3$178
;../src/main.c:169: x = globals()->fat.section_ptr[FAT_BLKID_DISKDATA];
	call	_globals
	ld	-14 (ix), h
	ld	-15 (ix), l
	ld	a, l
	add	a, #0xd7
	ld	-15 (ix), a
	ld	a, -14 (ix)
	adc	a, #0x08
	ld	-14 (ix), a
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	ld	de, #0x0625
	add	hl, de
	ld	a, (hl)
	ld	-13 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-12 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-11 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-10 (ix), a
	C$main.c$170$2$167	= .
	.globl	C$main.c$170$2$167
;../src/main.c:170: DBG("Repositioned over data, go for read");
00125$:
	C$main.c$172$2$167	= .
	.globl	C$main.c$172$2$167
;../src/main.c:172: if( c == '1' ) {
	ld	a, -1 (ix)
	sub	a, #0x31
	jr	NZ,00130$
	C$main.c$174$3$179	= .
	.globl	C$main.c$174$3$179
;../src/main.c:174: memset( buffer, 0, 512 );
	ld	hl, #0x0000
	add	hl, sp
	ld	-15 (ix), l
	ld	-14 (ix), h
	ld	(hl), #0x00
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
	C$main.c$175$3$179	= .
	.globl	C$main.c$175$3$179
;../src/main.c:175: if( sdcReadBlock(&globals()->sd_buf, x, buffer) )
	ld	c, -15 (ix)
	ld	b, -14 (ix)
	push	bc
	call	_globals
	ex	de,hl
	pop	bc
	ld	hl, #0x0804
	add	hl, de
	ex	de, hl
	push	bc
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	push	de
	call	_sdcReadBlock
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jr	Z,00127$
	C$main.c$176$3$179	= .
	.globl	C$main.c$176$3$179
;../src/main.c:176: dumpdata(buffer); else {
	ld	c, -15 (ix)
	ld	b, -14 (ix)
	push	bc
	call	_dumpdata
	pop	af
	jr	00128$
00127$:
	C$main.c$177$4$180	= .
	.globl	C$main.c$177$4$180
;../src/main.c:177: DBG("Error %08lx", globals()->sd_buf.last_response);
	call	_globals
00128$:
	C$main.c$179$3$179	= .
	.globl	C$main.c$179$3$179
;../src/main.c:179: memset( buffer, 0xff, 512 ); continue;
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	ld	(hl), #0xff
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
	jp	00101$
00130$:
	C$main.c$181$2$167	= .
	.globl	C$main.c$181$2$167
;../src/main.c:181: if( c == '-' ) {
	ld	a, -1 (ix)
	sub	a, #0x2d
	jr	NZ,00132$
	C$main.c$182$3$181	= .
	.globl	C$main.c$182$3$181
;../src/main.c:182: x -= 1;
	ld	a, -13 (ix)
	add	a, #0xff
	ld	-13 (ix), a
	ld	a, -12 (ix)
	adc	a, #0xff
	ld	-12 (ix), a
	ld	a, -11 (ix)
	adc	a, #0xff
	ld	-11 (ix), a
	ld	a, -10 (ix)
	adc	a, #0xff
	ld	-10 (ix), a
	C$main.c$184$3$181	= .
	.globl	C$main.c$184$3$181
;../src/main.c:184: continue;
	jp	00101$
00132$:
	C$main.c$186$2$167	= .
	.globl	C$main.c$186$2$167
;../src/main.c:186: if( c == '+' ) {
	ld	a, -1 (ix)
	sub	a, #0x2b
	jr	NZ,00134$
	C$main.c$187$3$182	= .
	.globl	C$main.c$187$3$182
;../src/main.c:187: x += 1;
	inc	-13 (ix)
	jp	NZ,00101$
	inc	-12 (ix)
	jp	NZ,00101$
	inc	-11 (ix)
	jp	NZ,00101$
	inc	-10 (ix)
	C$main.c$189$3$182	= .
	.globl	C$main.c$189$3$182
;../src/main.c:189: continue;
	jp	00101$
00134$:
	C$main.c$191$2$167	= .
	.globl	C$main.c$191$2$167
;../src/main.c:191: if( c == '2' ) {
	ld	a, -1 (ix)
	sub	a, #0x32
	jr	NZ,00139$
	C$main.c$193$3$183	= .
	.globl	C$main.c$193$3$183
;../src/main.c:193: memset( buffer, 0xff, 512 );
	ld	hl, #0x0000
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	push	de
	ld	(hl), #0xff
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
	pop	de
	C$main.c$194$3$183	= .
	.globl	C$main.c$194$3$183
;../src/main.c:194: sprintf(buffer, "Hello world");
	ld	hl, #___str_20+0
	ld	c, e
	ld	b, d
	push	de
	push	hl
	push	bc
	call	_sprintf
	pop	af
	pop	af
	pop	de
	C$main.c$195$3$183	= .
	.globl	C$main.c$195$3$183
;../src/main.c:195: sprintf(buffer+(512-11),"end of sec");
	ld	bc, #___str_21+0
	ld	hl, #0x01f5
	add	hl, de
	push	de
	push	bc
	push	hl
	call	_sprintf
	pop	af
	pop	af
	call	_globals
	ld	c, l
	ld	b, h
	pop	de
	ld	hl, #0x0804
	add	hl, bc
	ld	c, l
	ld	b, h
	push	de
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	push	hl
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	push	hl
	push	bc
	call	_sdcWriteBlock
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jp	NZ, 00101$
	C$main.c$200$4$185	= .
	.globl	C$main.c$200$4$185
;../src/main.c:200: DBG("Error %08lx", globals()->sd_buf.last_response);
	call	_globals
	C$main.c$202$3$183	= .
	.globl	C$main.c$202$3$183
;../src/main.c:202: continue;
	jp	00101$
00139$:
	C$main.c$204$2$167	= .
	.globl	C$main.c$204$2$167
;../src/main.c:204: if( c == 'T' ) {
	ld	a, -1 (ix)
	sub	a, #0x54
	jp	NZ,00145$
	C$main.c$206$3$186	= .
	.globl	C$main.c$206$3$186
;../src/main.c:206: DBG("Finding free : %d", x = fatFindFree(&globals()->fat, FAT_ROM));
	call	_globals
	ld	bc, #0x08d7
	add	hl, bc
	xor	a, a
	push	af
	inc	sp
	push	hl
	call	_fatFindFree
	pop	af
	inc	sp
	C$main.c$207$3$186	= .
	.globl	C$main.c$207$3$186
;../src/main.c:207: DBG("Populate :%d", fatSetContent(&globals()->fat,FAT_ROM, x, "Debug ROM" ));
	push	hl
	call	_globals
	pop	bc
	ld	de, #0x08d7
	add	hl, de
	push	bc
	ld	de, #___str_26
	push	de
	push	bc
	xor	a, a
	push	af
	inc	sp
	push	hl
	call	_fatSetContent
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	call	_globals
	pop	bc
	ld	de, #0x08d7
	add	hl, de
	ld	a, #0x01
	push	af
	inc	sp
	push	bc
	xor	a, a
	push	af
	inc	sp
	push	hl
	call	_fatOpen
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	C$main.c$209$3$186	= .
	.globl	C$main.c$209$3$186
;../src/main.c:209: DBG("Ptr:%08lx, cnt: %u", globals()->fat.open_file_ptr, globals()->fat.open_file_cntr);
	call	_globals
	call	_globals
	C$main.c$212$5$188	= .
	.globl	C$main.c$212$5$188
;../src/main.c:212: for( x=0; x<32; x++)
	ld	-7 (ix), #0x00
	ld	-6 (ix), #0x00
	xor	a, a
	ld	-5 (ix), a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	-2 (ix), a
00159$:
	C$main.c$214$5$188	= .
	.globl	C$main.c$214$5$188
;../src/main.c:214: if( y < sizeof(rom_data) ) memcpy(globals()->fat.buffer, &rom_data[y], 512);
	ld	a, -7 (ix)
	sub	a, #0x3b
	ld	a, -6 (ix)
	sbc	a, #0x01
	jr	NC,00141$
	call	_globals
	ld	bc, #0x08d7
	add	hl, bc
	inc	hl
	ex	de,hl
	ld	a, #<(_rom_data)
	add	a, -7 (ix)
	ld	l, a
	ld	a, #>(_rom_data)
	adc	a, -6 (ix)
	ld	h, a
	ld	bc, #0x0200
	ldir
	jr	00142$
00141$:
	C$main.c$215$5$188	= .
	.globl	C$main.c$215$5$188
;../src/main.c:215: else memset( globals()->fat.buffer, 255, 512 );
	call	_globals
	ld	bc, #0x08d7
	add	hl, bc
	inc	hl
	ld	(hl), #0xff
	ld	e, l
	ld	d, h
	inc	de
	ld	bc, #0x01ff
	ldir
00142$:
	C$main.c$216$5$188	= .
	.globl	C$main.c$216$5$188
;../src/main.c:216: y += 512;
	ld	a, -7 (ix)
	ld	-7 (ix), a
	ld	a, -6 (ix)
	add	a, #0x02
	ld	-6 (ix), a
	C$main.c$217$5$188	= .
	.globl	C$main.c$217$5$188
;../src/main.c:217: fatWriteBlock( &globals()->fat, (char*) globals()->fat.buffer);
	call	_globals
	ld	bc, #0x08d7
	add	hl, bc
	inc	hl
	push	hl
	call	_globals
	pop	bc
	ld	de, #0x08d7
	add	hl, de
	push	bc
	push	hl
	call	_fatWriteBlock
	pop	af
	pop	af
	C$main.c$212$4$187	= .
	.globl	C$main.c$212$4$187
;../src/main.c:212: for( x=0; x<32; x++)
	inc	-5 (ix)
	jr	NZ,00321$
	inc	-4 (ix)
	jr	NZ,00321$
	inc	-3 (ix)
	jr	NZ,00321$
	inc	-2 (ix)
00321$:
	ld	a, -5 (ix)
	sub	a, #0x20
	ld	a, -4 (ix)
	sbc	a, #0x00
	ld	a, -3 (ix)
	sbc	a, #0x00
	ld	a, -2 (ix)
	sbc	a, #0x00
	jp	C, 00159$
	C$main.c$220$1$166	= .
	.globl	C$main.c$220$1$166
;../src/main.c:220: continue;
	ld	hl, #514
	add	hl, sp
	ex	de, hl
	ld	hl, #522
	add	hl, sp
	ld	bc, #4
	ldir
	jp	00101$
00145$:
	C$main.c$222$2$167	= .
	.globl	C$main.c$222$2$167
;../src/main.c:222: if( c == 't' ) {
	ld	a, -1 (ix)
	sub	a, #0x74
	jp	NZ,00147$
	C$main.c$224$3$189	= .
	.globl	C$main.c$224$3$189
;../src/main.c:224: DBG("Get descr :%d", fatGetDescription(&globals()->fat,FAT_ROM, 0, buffer ));
	ld	hl, #0x0000
	add	hl, sp
	ld	-15 (ix), l
	ld	-14 (ix), h
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0xd7
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x08
	ld	-8 (ix), a
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	push	hl
	ld	hl, #0x0000
	push	hl
	xor	a, a
	push	af
	inc	sp
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	call	_fatGetDescription
	ld	hl, #7
	add	hl, sp
	ld	sp, hl
	C$main.c$226$3$189	= .
	.globl	C$main.c$226$3$189
;../src/main.c:226: CONFIG.roms[33] = (uint16_t) -1;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x47
	ld	-9 (ix), a
	jr	NC,00324$
	inc	-8 (ix)
00324$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0xff
	inc	hl
	ld	(hl), #0xff
	C$main.c$227$3$189	= .
	.globl	C$main.c$227$3$189
;../src/main.c:227: CONFIG.roms[63] = ROMMGR_SDC | 0;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x83
	ld	-9 (ix), a
	jr	NC,00325$
	inc	-8 (ix)
00325$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x80
	C$main.c$228$3$189	= .
	.globl	C$main.c$228$3$189
;../src/main.c:228: CONFIG_UPDATE;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	hl, #0x0087
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	call	_fatPutConfig
	pop	af
	pop	af
00147$:
	C$main.c$231$2$167	= .
	.globl	C$main.c$231$2$167
;../src/main.c:231: if( c == 'X' ) {
	ld	a, -1 (ix)
	sub	a, #0x58
	jr	NZ,00149$
	C$main.c$232$3$190	= .
	.globl	C$main.c$232$3$190
;../src/main.c:232: configNew( &globals()->config );
	call	_globals
	ld	bc, #0x0f0e
	add	hl, bc
	push	hl
	call	_configNew
	pop	af
	C$main.c$233$3$190	= .
	.globl	C$main.c$233$3$190
;../src/main.c:233: CONFIG_UPDATE;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	hl, #0x0087
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	call	_fatPutConfig
	pop	af
	pop	af
	C$main.c$235$3$190	= .
	.globl	C$main.c$235$3$190
;../src/main.c:235: continue;
	jp	00101$
00149$:
	C$main.c$238$2$167	= .
	.globl	C$main.c$238$2$167
;../src/main.c:238: if( c == 'x' ) {
	ld	a, -1 (ix)
	sub	a, #0x78
	jp	NZ,00151$
	C$main.c$239$3$191	= .
	.globl	C$main.c$239$3$191
;../src/main.c:239: configNew( &globals()->config );
	call	_globals
	ld	bc, #0x0f0e
	add	hl, bc
	push	hl
	call	_configNew
	pop	af
	C$main.c$240$3$191	= .
	.globl	C$main.c$240$3$191
;../src/main.c:240: CONFIG.roms[ROM_LOWER] = ROMMGR_ASMI | ROM_6128;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x85
	ld	-9 (ix), a
	jr	NC,00330$
	inc	-8 (ix)
00330$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x01
	inc	hl
	ld	(hl), #0x00
	C$main.c$241$3$191	= .
	.globl	C$main.c$241$3$191
;../src/main.c:241: CONFIG.roms[0] = ROMMGR_ASMI | ROM_BASIC11;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x05
	ld	-9 (ix), a
	jr	NC,00331$
	inc	-8 (ix)
00331$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x03
	inc	hl
	ld	(hl), #0x00
	C$main.c$242$3$191	= .
	.globl	C$main.c$242$3$191
;../src/main.c:242: CONFIG.roms[7] = ROMMGR_ASMI | ROM_AMSDOS;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x13
	ld	-9 (ix), a
	jr	NC,00332$
	inc	-8 (ix)
00332$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x04
	inc	hl
	ld	(hl), #0x00
	C$main.c$243$3$191	= .
	.globl	C$main.c$243$3$191
;../src/main.c:243: CONFIG.roms[6] = ROMMGR_ASMI | ROM_MAXAM;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x11
	ld	-9 (ix), a
	jr	NC,00333$
	inc	-8 (ix)
00333$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x05
	inc	hl
	ld	(hl), #0x00
	C$main.c$244$3$191	= .
	.globl	C$main.c$244$3$191
;../src/main.c:244: CONFIG.roms[5] = ROMMGR_ASMI | ROM_PROTEXT;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x0f
	ld	-9 (ix), a
	jr	NC,00334$
	inc	-8 (ix)
00334$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x0e
	inc	hl
	ld	(hl), #0x00
	C$main.c$245$3$191	= .
	.globl	C$main.c$245$3$191
;../src/main.c:245: CONFIG.roms[4] = ROMMGR_ASMI | ROM_RODOS;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x0d
	ld	-9 (ix), a
	jr	NC,00335$
	inc	-8 (ix)
00335$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x0f
	inc	hl
	ld	(hl), #0x00
	C$main.c$246$3$191	= .
	.globl	C$main.c$246$3$191
;../src/main.c:246: CONFIG.roms[3] = ROMMGR_ASMI | ROM_HARVEY;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x0b
	ld	-9 (ix), a
	jr	NC,00336$
	inc	-8 (ix)
00336$:
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	(hl), #0x0b
	inc	hl
	ld	(hl), #0x00
	C$main.c$247$3$191	= .
	.globl	C$main.c$247$3$191
;../src/main.c:247: CONFIG_UPDATE;
	call	_globals
	ld	-8 (ix), h
	ld	-9 (ix), l
	ld	a, l
	add	a, #0x0e
	ld	-9 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x0f
	ld	-8 (ix), a
	ld	hl, #0x0087
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	call	_fatPutConfig
	pop	af
	pop	af
	C$main.c$249$3$191	= .
	.globl	C$main.c$249$3$191
;../src/main.c:249: continue;
	jp	00101$
00151$:
	C$main.c$252$2$167	= .
	.globl	C$main.c$252$2$167
;../src/main.c:252: if( c == 'E' ) { fatReformat(&globals()->fat, 0xdeadbeef); continue; }
	ld	a, -1 (ix)
	sub	a, #0x45
	jr	NZ,00153$
	call	_globals
	ld	bc,#0x08d7
	add	hl,bc
	ex	de, hl
	ld	hl, #0xdead
	push	hl
	ld	hl, #0xbeef
	push	hl
	push	de
	call	_fatReformat
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	jp	00101$
00153$:
	C$main.c$254$2$167	= .
	.globl	C$main.c$254$2$167
;../src/main.c:254: if( c == 'h' ) {
	ld	a, -1 (ix)
	sub	a, #0x68
	jp	NZ,00101$
	C$main.c$255$3$193	= .
	.globl	C$main.c$255$3$193
;../src/main.c:255: hdmi_write(0x96,0);
	ld	hl, #0x0096
	push	hl
	call	_hdmi_write
	C$main.c$256$3$193	= .
	.globl	C$main.c$256$3$193
;../src/main.c:256: DBG("CTS Calculated : %02x %02x %02x INT:%02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06),hdmi_read(0x96));
	ld	h,#0x04
	ex	(sp),hl
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	a, #0x05
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	a, #0x06
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	ld	a, #0x96
	push	af
	inc	sp
	call	_hdmi_read
	inc	sp
	C$main.c$257$3$193	= .
	.globl	C$main.c$257$3$193
;../src/main.c:257: HALT();//while(1) processEvents();
	halt
	C$main.c$261$1$166	= .
	.globl	C$main.c$261$1$166
;../src/main.c:261: }
	C$main.c$261$1$166	= .
	.globl	C$main.c$261$1$166
	XG$main$0$0	= .
	.globl	XG$main$0$0
	jp	5
Fmain$__str_9$0$0 == .
___str_9:
	.ascii "Empty 2S82"
	.db 0x00
Fmain$__str_10$0$0 == .
___str_10:
	.ascii "Mounted"
	.db 0x00
Fmain$__str_11$0$0 == .
___str_11:
	.ascii "Unmounted"
	.db 0x00
Fmain$__str_12$0$0 == .
___str_12:
	.ascii "Changed"
	.db 0x00
Fmain$__str_13$0$0 == .
___str_13:
	.ascii "Unchanged"
	.db 0x00
Fmain$__str_14$0$0 == .
___str_14:
	.ascii "Repositioned over names, go for read"
	.db 0x00
Fmain$__str_15$0$0 == .
___str_15:
	.ascii "Repositioned over data, go for read"
	.db 0x00
Fmain$__str_16$0$0 == .
___str_16:
	.ascii "Starting read %lu"
	.db 0x00
Fmain$__str_17$0$0 == .
___str_17:
	.ascii "Error %08lx"
	.db 0x00
Fmain$__str_18$0$0 == .
___str_18:
	.ascii "New block ID: %ld"
	.db 0x00
Fmain$__str_19$0$0 == .
___str_19:
	.ascii "Starting write %lu"
	.db 0x00
Fmain$__str_20$0$0 == .
___str_20:
	.ascii "Hello world"
	.db 0x00
Fmain$__str_21$0$0 == .
___str_21:
	.ascii "end of sec"
	.db 0x00
Fmain$__str_22$0$0 == .
___str_22:
	.ascii "Written new sector"
	.db 0x00
Fmain$__str_23$0$0 == .
___str_23:
	.ascii "Testing function - WRITE"
	.db 0x00
Fmain$__str_24$0$0 == .
___str_24:
	.ascii "Finding free : %d"
	.db 0x00
Fmain$__str_25$0$0 == .
___str_25:
	.ascii "Populate :%d"
	.db 0x00
Fmain$__str_26$0$0 == .
___str_26:
	.ascii "Debug ROM"
	.db 0x00
Fmain$__str_27$0$0 == .
___str_27:
	.ascii "Open file %d"
	.db 0x00
Fmain$__str_28$0$0 == .
___str_28:
	.ascii "Ptr:%08lx, cnt: %u"
	.db 0x00
Fmain$__str_29$0$0 == .
___str_29:
	.ascii "Done"
	.db 0x00
Fmain$__str_30$0$0 == .
___str_30:
	.ascii "Testing function - READ"
	.db 0x00
Fmain$__str_31$0$0 == .
___str_31:
	.ascii "Get descr :%d"
	.db 0x00
Fmain$__str_32$0$0 == .
___str_32:
	.ascii "Result: >%s<"
	.db 0x00
Fmain$__str_33$0$0 == .
___str_33:
	.ascii "Reset config"
	.db 0x00
Fmain$__str_34$0$0 == .
___str_34:
	.ascii "Added ROMs to config"
	.db 0x00
Fmain$__str_35$0$0 == .
___str_35:
	.ascii "CTS Calculated : %02x %02x %02x INT:%02x"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
Fmain$__xinit_rom_data$0$0 == .
__xinit__rom_data:
	.db #0x01	; 1
	.db #0x01	; 1
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x09	; 9
	.db #0xc0	; 192
	.db #0xc3	; 195
	.db #0x1b	; 27
	.db #0xc0	; 192
	.db #0x45	; 69	'E'
	.db #0x6d	; 109	'm'
	.db #0x62	; 98	'b'
	.db #0x65	; 101	'e'
	.db #0x64	; 100	'd'
	.db #0x64	; 100	'd'
	.db #0x65	; 101	'e'
	.db #0x64	; 100	'd'
	.db #0x20	; 32
	.db #0x52	; 82	'R'
	.db #0x4f	; 79	'O'
	.db #0x4d	; 77	'M'
	.db #0x20	; 32
	.db #0x54	; 84	'T'
	.db #0x65	; 101	'e'
	.db #0x73	; 115	's'
	.db #0xf4	; 244
	.db #0x00	; 0
	.db #0xd5	; 213
	.db #0xe5	; 229
	.db #0xc5	; 197
	.db #0xf5	; 245
	.db #0x21	; 33
	.db #0x22	; 34
	.db #0xc1	; 193
	.db #0xcd	; 205
	.db #0x41	; 65	'A'
	.db #0xc0	; 192
	.db #0xcd	; 205
	.db #0x12	; 18
	.db #0xb9	; 185
	.db #0xe6	; 230
	.db #0x0f	; 15
	.db #0xcd	; 205
	.db #0xfb	; 251
	.db #0xc0	; 192
	.db #0x21	; 33
	.db #0x29	; 41
	.db #0xc1	; 193
	.db #0xcd	; 205
	.db #0x41	; 65	'A'
	.db #0xc0	; 192
	.db #0x21	; 33
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xcd	; 205
	.db #0x41	; 65	'A'
	.db #0xc0	; 192
	.db #0xcd	; 205
	.db #0x07	; 7
	.db #0xc1	; 193
	.db #0xcd	; 205
	.db #0x07	; 7
	.db #0xc1	; 193
	.db #0x18	; 24
	.db #0x0d	; 13
	.db #0x7e	; 126
	.db #0x23	; 35
	.db #0xfe	; 254
	.db #0x00	; 0
	.db #0xc8	; 200
	.db #0xfe	; 254
	.db #0xff	; 255
	.db #0xc8	; 200
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0x18	; 24
	.db #0xf3	; 243
	.db #0x11	; 17
	.db #0x00	; 0
	.db #0x40	; 64
	.db #0x21	; 33
	.db #0x00	; 0
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x40	; 64
	.db #0xed	; 237
	.db #0xb0	; 176
	.db #0x21	; 33
	.db #0x00	; 0
	.db #0x40	; 64
	.db #0x06	; 6
	.db #0x40	; 64
	.db #0xcd	; 205
	.db #0xd1	; 209
	.db #0xc0	; 192
	.db #0xcd	; 205
	.db #0x07	; 7
	.db #0xc1	; 193
	.db #0x21	; 33
	.db #0x00	; 0
	.db #0x40	; 64
	.db #0x01	; 1
	.db #0xc4	; 196
	.db #0x7a	; 122	'z'
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x1a	; 26
	.db #0x01	; 1
	.db #0xc5	; 197
	.db #0x7b	; 123
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x2b	; 43
	.db #0x01	; 1
	.db #0xc6	; 198
	.db #0x7c	; 124
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x3c	; 60
	.db #0x01	; 1
	.db #0xc7	; 199
	.db #0x7d	; 125
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x4d	; 77	'M'
	.db #0x01	; 1
	.db #0xcc	; 204
	.db #0x7e	; 126
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x5e	; 94
	.db #0x01	; 1
	.db #0xcd	; 205
	.db #0x7f	; 127
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0x36	; 54	'6'
	.db #0x6f	; 111	'o'
	.db #0x21	; 33
	.db #0x00	; 0
	.db #0x40	; 64
	.db #0x01	; 1
	.db #0xc4	; 196
	.db #0x7a	; 122	'z'
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xc5	; 197
	.db #0x7b	; 123
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xc6	; 198
	.db #0x7c	; 124
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xc7	; 199
	.db #0x7d	; 125
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xcc	; 204
	.db #0x7e	; 126
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xcd	; 205
	.db #0x7f	; 127
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x01	; 1
	.db #0xc0	; 192
	.db #0x7f	; 127
	.db #0xed	; 237
	.db #0x49	; 73	'I'
	.db #0xcd	; 205
	.db #0x07	; 7
	.db #0xc1	; 193
	.db #0xf1	; 241
	.db #0xc1	; 193
	.db #0xe1	; 225
	.db #0xd1	; 209
	.db #0xc9	; 201
	.db #0x7e	; 126
	.db #0x23	; 35
	.db #0xcd	; 205
	.db #0xe1	; 225
	.db #0xc0	; 192
	.db #0x3e	; 62
	.db #0x20	; 32
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0x10	; 16
	.db #0xf1	; 241
	.db #0xc9	; 201
	.db #0xe5	; 229
	.db #0xf5	; 245
	.db #0x7e	; 126
	.db #0xf5	; 245
	.db #0xcb	; 203
	.db #0x1f	; 31
	.db #0xcb	; 203
	.db #0x1f	; 31
	.db #0xcb	; 203
	.db #0x1f	; 31
	.db #0xcb	; 203
	.db #0x1f	; 31
	.db #0xe6	; 230
	.db #0x0f	; 15
	.db #0xcd	; 205
	.db #0xfb	; 251
	.db #0xc0	; 192
	.db #0xf1	; 241
	.db #0xe6	; 230
	.db #0x0f	; 15
	.db #0xcd	; 205
	.db #0xfb	; 251
	.db #0xc0	; 192
	.db #0xf1	; 241
	.db #0xe1	; 225
	.db #0xc9	; 201
	.db #0x11	; 17
	.db #0x12	; 18
	.db #0xc1	; 193
	.db #0x26	; 38
	.db #0x00	; 0
	.db #0x6f	; 111	'o'
	.db #0x19	; 25
	.db #0x7e	; 126
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0xc9	; 201
	.db #0x3e	; 62
	.db #0x0a	; 10
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0x3e	; 62
	.db #0x0d	; 13
	.db #0xcd	; 205
	.db #0x5a	; 90	'Z'
	.db #0xbb	; 187
	.db #0xc9	; 201
	.db #0x30	; 48	'0'
	.db #0x31	; 49	'1'
	.db #0x32	; 50	'2'
	.db #0x33	; 51	'3'
	.db #0x34	; 52	'4'
	.db #0x35	; 53	'5'
	.db #0x36	; 54	'6'
	.db #0x37	; 55	'7'
	.db #0x38	; 56	'8'
	.db #0x39	; 57	'9'
	.db #0x41	; 65	'A'
	.db #0x42	; 66	'B'
	.db #0x43	; 67	'C'
	.db #0x44	; 68	'D'
	.db #0x45	; 69	'E'
	.db #0x46	; 70	'F'
	.db #0x20	; 32
	.db #0x52	; 82	'R'
	.db #0x6f	; 111	'o'
	.db #0x6d	; 109	'm'
	.db #0x20	; 32
	.db #0x28	; 40
	.db #0x00	; 0
	.db #0x29	; 41
	.db #0x20	; 32
	.db #0x53	; 83	'S'
	.db #0x74	; 116	't'
	.db #0x61	; 97	'a'
	.db #0x72	; 114	'r'
	.db #0x74	; 116	't'
	.db #0x20	; 32
	.db #0x76	; 118	'v'
	.db #0x32	; 50	'2'
	.db #0x32	; 50	'2'
	.db #0x36	; 54	'6'
	.db #0x35	; 53	'5'
	.db #0x0d	; 13
	.db #0x0a	; 10
	.db #0x0a	; 10
	.db #0x00	; 0
	.db #0x00	; 0
	.area _CABS (ABS)
