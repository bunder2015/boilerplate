;;;;;;;;;;
;
;  boilerplate - demo NES ROM of sorts
;
;;;;;;;;;;

	; Generate .lst file for debugging
	.list

	; iNES header
	.inesprg 1		; 1x16k PRG ROM
	.ineschr 1		; 1x 8k CHR ROM
	.inesprs 0		; 0x 8k PRG RAM
	.inesmap 0		; iNES mapper 0
	.inesmir 1		; Vertical mirroring (horizontal scrolling)
	.inesfsm 0		; No four-screen mirroring
	.inesbat 0		; No battery
	.inesreg 0		; NTSC region
	.inesbus 0		; No bus conflicts

;;;;;;;;;;

	; NES registers
	.include "registers.asm"

;;;;;;;;;;

	; Zero-page memory $0000-00FF
	.zp

JOY1INPUT:
	.ds 1
JOY2INPUT:
	.ds 1

	; Debugging
DBGA:
	.ds 1
DBGX:
	.ds 1
DBGY:
	.ds 1
DBGPC:
	.ds 2
DBGPS:
	.ds 1
DBGSP:
	.ds 1

;;;;;;;;;;

	; Work memory $0200-07FF
	.bss

	; Allocate 256b chunk of WRAM for PPU OAM
	.include "ppu-bss.asm"

;;;;;;;;;;

	; PRG ROM
	.code
	.bank 0
	.org $C000

MAIN:
	;; TODO
	JMP MAIN

;;;;;;;;;;

	.bank 1
	.org $E000

	;; TODO

	.org $FF00

RESET:
	SEI			; Disable IRQ
	CLD			; Disable decimal mode
	LDX #$40
	STX APUFRAME		; Disable APU frame IRQ
	LDX #$FF
	TXS			; Initialize stack pointer
	INX
	STX PPUCTRL		; Disable PPU vblank NMI
	STX PPUMASK		; Disable PPU rendering
	STX DMCFREQ		; Disable APU DMC IRQ
	BIT PPUSTATUS		; Clear vblank bit if console reset during a vblank

VB1:
	BIT PPUSTATUS
	BPL VB1			; Wait for first vblank

MEMCLR:
	LDA #$00
	STA $0000, X
	STA $0100, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X		; Initialize WRAM
	LDA #$FF
	STA $0200, X		; Initialize WRAM copy of PPU OAM
	INX
	BNE MEMCLR

VB2:
	BIT PPUSTATUS
	BPL VB2			; Wait for second vblank

RESETDONE:
	LDA #$00
	LDX #$00
	CLV
	JMP MAIN		; Go to main code loop

IRQ:
	;; TODO

NMI:
	;; TODO

;;;;;;;;;;

	; CPU Vectors
	.org $FFFA
	.dw NMI
	.dw RESET
	.dw IRQ

	; End of PRG ROM

;;;;;;;;;;

	; CHR ROM
	.data
	.bank 2
	.org $0000

	.incbin "tilemap.bin"

	; End of CHR ROM
