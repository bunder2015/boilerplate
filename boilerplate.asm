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

	; NES CPU register variables
	.include "registers.asm"

;;;;;;;;;;

	; Zero-page memory $0000-00FF
	.zp

JOY1IN:
	.ds 1
JOY2IN:
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

	; Reserve 256b chunk of WRAM for PPU OAM
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

LOADPALS:
	LDA PPUSTATUS		; Read PPU status to reset PPUADDR latch
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR		; Set PPUADDR to $3F00

	LDX #$00		; Set loop counter
.L1:
	LDA PALETTES, X		; Read palette colour
	STA PPUDATA		; Store to PPU
	INX
	CPX #$20
	BNE .L1			; Loop through 4 BG and SPR palettes

	RTS

READJOYS:
	LDA #$01
	STA STROBE		; Bring strobe latch high
	LDA #$00
	STA STROBE		; Bring strobe latch low

	LDX #$08		; Set loop counter
.L1:
	LDA JOY1		; Read Joypad 1
	LSR A			; Shift bit into carry
	ROL <JOY1IN		; Rotate carry into storage
	LDA JOY2		; Read Joypad 2
	LSR A			; Shift bit into carry
	ROL <JOY2IN		; Rotate carry into storage
	DEX
	BNE .L1			; Loop through 8 joypad buttons

	RTS

	.org $F000

PALETTES:
	.db $0F,$20,$10,$00	; BG palette 0
	.db $0F,$20,$10,$00	; BG palette 1
	.db $0F,$20,$10,$00	; BG palette 2
	.db $0F,$20,$10,$00	; BG palette 3

	.db $0F,$20,$10,$00	; SPR palette 0
	.db $0F,$20,$10,$00	; SPR palette 1
	.db $0F,$20,$10,$00	; SPR palette 2
	.db $0F,$20,$10,$00	; SPR palette 3

TITLETEXT:
	.db "BOILERPLATE", $00

STARTTEXT:
	.db "PRESS START", $00

PAUSETEXT:
	.db "PAUSE", $00

	.org $FF00

NMI:
	PHA
	TXA
	PHA
	TYA
	PHA			; Push A/X/Y onto the stack

	;; TODO

	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA		; DMA transfer $0200-$02FF to PPU OAM

	JSR READJOY1		; Read controller 1
	JSR READJOY2		; Read controller 2

	PLA
	TAY
	PLA
	TAX
	PLA			; Pull A/X/Y from the stack

	RTI			; Exit NMI

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
	JSR LOADPALS		; Load palettes

	JMP MAIN		; Go to main code loop

IRQ:
	;; TODO

	RTI			; Exit IRQ

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
