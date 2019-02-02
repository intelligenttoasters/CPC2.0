; boot.asm
;
; Boot up assembly
; Part of the CPC2 project: http://intelligenttoasters.blog
; Copyright (C)2017  Intelligent.Toasters@gmail.com
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, you can find a copy here:
; https://www.gnu.org/licenses/gpl-3.0.en.html
;

	.module bootblk

	.area _VECT0 (ABS)
	.org	0x0000

	ld sp,#0h0000	; Stack is top of memory
	jp BOOTSYS
;	jp debug

	.area _VECT1 (ABS)
	.org	0x0008
	reti

	.area _VECT2 (ABS)
	.org	0x0010
	reti

	.area _VECT3 (ABS)
	.org	0x0018
	reti

	.area _VECT4 (ABS)
	.org	0x0020
	reti

	.area _VECT5 (ABS)
	.org	0x0028
	reti

	.area _VECT6 (ABS)
	.org	0x0030
	reti

	.area _VECT7 (ABS)
	.org	0x0038
	ld (#INT_SP), sp
	ld sp, #INT_STACK
	exx					; Fast swap
	ex af,af'
	call _int_handler
	ex af,af'
	exx					; Fast swap
	ld sp, (#INT_SP)
	ei
	reti

; Local stack for INT, 2 bytes to record SP and 16 stack entries
INT_SP:
	.ds		2
	.ds		22
INT_STACK:	; Stack starts here and works down

	.area _VECT_NMI (ABS)
	.org	0x0066
	ld (#NMI_SP), sp
	ld sp, #NMI_STACK
	exx					; Fast swap
	ex af,af'
	call _nmi_handler
	ex af,af'
	exx					; Fast swap
	ld sp, (#NMI_SP)
	retn

; Local stack for NMI, 2 bytes to record SP and 16 stack entries
NMI_SP:
	.ds		2
	.ds		16
NMI_STACK:	; Stack starts here and works down

; Used to move the start of the code section if the ABS sections expand
_CODE_START = .

;
; ==================================================================
;
;; Ordering of segments for the linker so that initializing vars works
	.area   _SYSTEM_CODE

	.area   _GSINIT

	.area   _INITIALIZER
s__INITIALIZER = .
	.area	_END_INITIALIZER
e__INITIALIZER = .
	.ds		256				; Ensure we're in a new page for write-protect
	.area	_DATA
s__DATA = .
	.area	_INITIALIZED
s__INITIALIZED = .
;
; ==================================================================
;
	; Leave space for all of the ABS locations
	.area	_CODE
	.ds		_CODE_START
;
; ==================================================================
;
	.area   _GSINIT
; Copy the initialized values to the working area
gsinit:
	ld		hl, #e__INITIALIZER
	ld		de, #s__INITIALIZER
	sbc		hl,de
;	inc 	hl
	push	hl
	pop 	bc
	; Got length of initializer section
	ld      a, b
	or      a, c
	jr      Z, gsinit_next
	ld      de, #s__INITIALIZED
	ld      hl, #s__INITIALIZER
	ldir
gsinit_next:
	ret
;
; ==================================================================
;
	.area   _SYSTEM_CODE

BOOTSYS:
	di

	; Write protect the memory
	ld a,#(s__DATA>>8)
	out(0x50),a				; Memory controller write protect boundary

	; Clear the interrupt register
	ld bc, #0x0010
	in a,(c)

	; Now initialize
	call CLRREG
	im 1
	call gsinit

	; Hold CPC in Reset
	ld bc, #0x03ff
	out(c),b

	; Start main process
;	ei
	call _main
	jr #BOOTSYS

; Clear out all the registers so we're not pushing unknown values onto the stack (helps modelsim!)
CLRREG:
	ld hl,#0
	ld de,#0
	ld bc,#0
	push bc
	pop af
	exx
	ld hl,#0
	ld de,#0
	ld bc,#0
	push bc
	pop af
	ld ix,#0
	ld iy,#0
	exx
	ret

; This is a native routine to do proper I/O
; First parameter is address, second is data
_OUT_:
        push af
        push bc
        push ix
        ; Add x params plus ret addr to the current stack pointer and we should be looking at the first parameter word
        ld ix,#8        ; Add 5 word parameters plus the call return word
        add ix,sp
        ld c,0(ix)      ; Get the port
        ld b,1(ix)      ; and the data
        out (c),b       ; Send the data
        pop ix
        pop bc
        pop af
        ret

; This is a native route to do proper I/O
; First parameter is the port, returning data
_IN_:
        push af
        push bc
        push ix

        ld ix, #8
        add ix,sp       ; Get parameters off stack

        ld c,0(ix)      ; Get port #
        ld b,#0xff
        in a,(c)        ; Read the port
        ld l,a          ; Returns a single character in l

        pop ix
        pop bc
        pop af
        ret

; This is a native route to do proper I/O
; First parameter is the port, second is the buffer ptr, third is the count
_OUTI:
        push af
        push bc
        push hl
        push ix
        ; Add x params plus ret addr to the current stack pointer and we should be looking at the first parameter word
        ld ix,	#10		; Skip over what we've just pushed onto the stack (inc the return address)
        add ix,sp
        ld c,0(ix)      ; Get the port
        ld l,1(ix)      ; and the data addr
        ld h,2(ix)      ; and the data addr
        ld b,3(ix)		; and the count
        otir			; Send the data
        pop ix
        pop hl
        pop bc
        pop af
        ret

; This is a native route to do proper I/O
; First parameter is the port, second is the buffer ptr, third is the count
_INI:
        push af
        push bc
        push hl
        push ix
        ; Add x params plus ret addr to the current stack pointer and we should be looking at the first parameter word
        ld ix,	#10		; Skip over what we've just pushed onto the stack (inc the return address)
        add ix,sp
        ld c,0(ix)      ; Get the port
        ld l,1(ix)      ; and the data addr
        ld h,2(ix)      ; and the data addr
        ld b,3(ix)		; and the count
        inir			; Get the data
        pop ix
        pop hl
        pop bc
        pop af
        ret

; Native memset routine for performance
_memset:
        push af
        push bc
        push de
        push hl
        push ix
        ; Add x params plus ret addr to the current stack pointer and we should be looking at the first parameter word
        ld ix, #12		; Skip over what we've just pushed onto the stack (inc the return address)
        add ix,sp
        ld e,0(ix)      ; Get the address
        ld d,1(ix)
        ld l,0(ix)      ; Get the address again
        ld h,1(ix)
        ld a,2(ix)		; Value
        ld c,3(ix)		; Count
        ld b,4(ix)
		ld (de), a		; Set first byte
		inc de
		dec bc			; Reduce BC by one (we did that byte already)
		ld a,b			; Check it's not zero
		or c
		jr z, mem_done
		ldir			; Reset memory
		jr mem_done

; Native memcpy routine for performance
_memcpy:
        push af
        push bc
        push de
        push hl
        push ix
        ; Add x params plus ret addr to the current stack pointer and we should be looking at the first parameter word
        ld ix, #12		; Skip over what we've just pushed onto the stack (inc the return address)
        add ix,sp
        ld e,0(ix)      ; Get the destination address
        ld d,1(ix)
        ld l,2(ix)      ; Get the source address
        ld h,3(ix)
        ld c,4(ix)		; Count
        ld b,5(ix)
		ld a,b			; Check it's not zero
		or c
		jr z, mem_done
		ldir			; Reset memory

mem_done:
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ret

	.globl debug
debug:
		; Set the memory write protect address
		ld bc,#0xe050
		out(c),b

		; Hold CPC in reset
		ld bc,#0x01ff
		out(c),b

		; Release reset
		ld b,#0x00
		out(c),b

		; Clear USB buffer register
		ld bc,#0x806f
		out(c),b

		ld bc,#0x4168
		out(c),b
		inc b
		out(c),b
		inc b
		out(c),b
		inc b
		out(c),b

		; Set PID
		ld bc,#0xaa6c
		out(c),b

		; Transmit
		ld bc,#0x106f
		out(c),b

		halt
usb1:	; Wait for op to complete
		in a,(c)
		bit 4,a
		jr z,usb1

		; What was the result?
		in a,(#0x60)

		; Write USB-PHY register
		ld bc,#0x1661
		out(c),b
		ld bc,#0x5a60
		out(c),b
		ld bc,#0x016f
		out(c),b

usb2:	; Wait for op to complete
		in a,(c)
		bit 4,a
		jr z,usb2

		halt

debug_old:
		; Set the memory write protect address
		ld bc,#0x7c00
		out(c),b

		; Hold CPC in reset
		ld bc,#0x01ff
		out(c),b

		; Wait for SDRAM to become ready
		ld c,#0xff
		in a,(c)
		bit 7,a
		jr z, debug

		; Release reset
		ld bc,#0x00ff
		out(c),b

		halt

		; Populate the memory with something
		ld de, #0x8050
		ld hl, #0x7e00
		ld bc, #0x0200
debug_loop:
		ld (hl),e
		inc hl
		dec bc
		ld (hl),d
		inc hl
		dec bc
		inc d
		dec e
		ld a,b
		or c
		jr nz,debug_loop


		; Mem Source address
		ld bc,#0x0064
		out (c),b
		ld bc,#0x7e65
		out (c),b
		; SD Destination address
		ld bc,#0x5060
		out (c),b
		ld bc,#0x3461
		out (c),b
		ld bc,#0x1262
		out (c),b
		ld bc,#0x0063
		out (c),b
		; Length
		ld bc, #0x0068	; Size-Lo
		out (c),b
		ld bc, #0x0269	; Size-Hi
		out (c),b
		; Now start the DMA M->S
		ld bc, #0x026f
		out (c),b
debug1:
		in a,(0x6f)
		bit 1,a
		jr z, debug1
		; DMA working now
		nop
		nop
		nop
		nop
		ld bc,#0x046f	; Abort
		out(c),b
debug2:
		; Wait for error state
		in a,(0x6f)
		bit 0,a
		jr z, debug2

		; Now restart the DMA M->S
		ld bc, #0x026f
		out (c),b

		; Wait for complete state
debug3:
		in a,(0x6f)
		bit 2,a
		jr z, debug3

		nop
		nop
		nop

		; Mem Dest address - put back to 0x7c00-0x7dff
		ld bc,#0x7c65
		out (c),b

		; Read back memory from SDRAM to mem
		; Now restart the DMA M->S
		ld bc, #0x016f
		out (c),b

		; Wait for complete state
debug4:
		in a,(0x6f)
		bit 2,a
		jr z, debug4

		; finish sim
		halt

; Export/Import global functions
	.globl _main
	.globl _OUT_
	.globl _OUTI
	.globl _IN_
	.globl _INI
	.globl _memset
	.globl _memcpy
	.globl _nmi_handler
	.globl _int_handler
