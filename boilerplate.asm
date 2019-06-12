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
	.ds 1			; Joypad 1 input
JOY2IN:
	.ds 1			; Joypad 2 input
PPUCADDR:
	.ds 2
PPUCINPUT:
	.ds 2
PPUCLEN:
	.ds 2
NMIREADY:
	.ds 1

	; Debugging
DBGA:
	.ds 1			; A register
DBGX:
	.ds 1			; X register
DBGY:
	.ds 1			; Y register
DBGPC:
	.ds 2			; Program counter
DBGPS:
	.ds 1			; Processor status
DBGSP:
	.ds 1			; Stack pointer

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
	LDA #$3F
	STA <PPUCADDR
	LDA #$00
	STA <PPUCADDR+1
	LDA #32
	STA <PPUCLEN+1
	LDA #LOW(PALETTES)
	STA <PPUCINPUT
	LDA #HIGH(PALETTES)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load palettes into PPU

	LDA #$21
	STA <PPUCADDR
	LDA #$C9
	STA <PPUCADDR+1
	LDA #79
	STA <PPUCLEN+1
	LDA #LOW(MENUBG)
	STA <PPUCINPUT
	LDA #HIGH(MENUBG)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG tiles into PPU

	LDA #$21
	STA <PPUCADDR
	LDA #$EA
	STA <PPUCADDR+1
	LDA #13
	STA <PPUCLEN+1
	LDA #LOW(MENUTEXT)
	STA <PPUCINPUT
	LDA #HIGH(MENUTEXT)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG text into PPU

	LDA #$22
	STA <PPUCADDR
	LDA #$4A
	STA <PPUCADDR+1
	LDA #8
	STA <PPUCLEN+1
	LDA #LOW(MENUONE)
	STA <PPUCINPUT
	LDA #HIGH(MENUONE)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG option text 1 into PPU

	LDA #$22
	STA <PPUCADDR
	LDA #$6A
	STA <PPUCADDR+1
	LDA #7
	STA <PPUCLEN+1
	LDA #LOW(MENUTWO)
	STA <PPUCINPUT
	LDA #HIGH(MENUTWO)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG option text 2 into PPU

	LDA #$23
	STA <PPUCADDR
	LDA #$DA
	STA <PPUCADDR+1
	LDA #12
	STA <PPUCLEN+1
	LDA #LOW(MENUATTR)
	STA <PPUCINPUT
	LDA #HIGH(MENUATTR)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG attributes into PPU

	LDA #$41
	STA SPR1X
	LDA #$90
	STA SPR1Y
	LDA #$1C
	STA SPR1TILE
	LDA #$00
	STA SPR1ATTR		; Draw a basic cursor sprite

	JSR NMIEN		; Enable PPU vblank NMI
	JSR VBWAIT		; Wait for next vblank - fixes attribute memory being visible on frame 4
	JSR RENDEREN		; Enable rendering

MENULOOP:
	;; TODO

	JSR VBWAIT		; Wait for next vblank
	JMP MENULOOP

	.data
	.bank 0
	.org $D000

PALETTES:
	.db $0F,$20,$10,$00	; BG palette 0
	.db $0F,$15,$10,$02	; BG palette 1
	.db $0F,$19,$10,$00	; BG palette 2
	.db $0F,$28,$10,$00	; BG palette 3

	.db $0F,$11,$10,$13	; SPR palette 0
	.db $0F,$26,$10,$2A	; SPR palette 1
	.db $0F,$25,$17,$00	; SPR palette 2
	.db $0F,$1C,$2C,$3C	; SPR palette 3

MENUATTR:
	.db $55,$55,$55,$55,$00,$00,$00,$00,$55,$55,$55,$55

MENUBG:
	.db $80,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$82,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $83,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$84,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $85,$86,$86,$86,$86,$86,$86,$86,$86,$86,$86,$86,$86,$86,$87

MENUTEXT:
	.db "BOILER PLATE!"

MENUONE:
	.db "New Game"

MENUTWO:
	.db "Options"

;;;;;;;;;;

	.code
	.bank 1
	.org $E000

	;; TODO

NMIEN:
	LDA #%10000000
	STA PPUCTRL		; Enable PPU vblank NMI

	RTS

PPUCOPY:
	LDA PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA <PPUCADDR
	STA PPUADDR
	LDA <PPUCADDR+1
	STA PPUADDR		; Read address and set PPUADDR

	LDX #$FF
	LDY #$00		; Set loop counters
.L1
	LDA [PPUCINPUT], Y	; Load data
	STA PPUDATA		; Store to PPU
	INY
	CPY <PPUCLEN+1
	BNE .L1
	LDY #$00
	INX
	CPX <PPUCLEN		; Check to see if we have finished copying
	BNE .L1			; Loop if we have not finished copying

	JSR RESETSCR		; Reset PPU scrolling

	RTS

READJOYS:
	LDA #$01
	STA STROBE		; Bring strobe latch high
	LDA #$00
	STA STROBE		; Bring strobe latch low

	LDX #8			; Set loop counter
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

RENDEREN:
	LDA #%00011110
	STA PPUMASK

	RTS

RESETSCR:
	LDA #$00
	STA PPUSCROLL
	STA PPUSCROLL		; Reset PPU scrolling to top left corner

	RTS

VBWAIT:
	INC <NMIREADY
.LOOP
	LDA <NMIREADY
	BNE .LOOP
	RTS

	.code
	.bank 1
	.org $FF00

NMI:
	PHA
	TXA
	PHA
	TYA
	PHA			; Push A/X/Y onto the stack

	;; TODO

	LDA <NMIREADY
	BEQ .OUT

	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA		; DMA transfer $0200-$02FF to PPU OAM

	JSR READJOYS		; Read controllers
	DEC <NMIREADY

.OUT
	PLA
	TAY
	PLA
	TAX
	PLA			; Pull A/X/Y from the stack

	RTI			; Exit NMI

RESET:
	SEI			; Disable IRQ
	CLD			; Disable decimal mode
	LDX #%01000000
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
	JMP MAIN		; Go to main code loop

IRQ:
	;; TODO

	RTI			; Exit IRQ

;;;;;;;;;;

	; CPU Vectors
	.data
	.bank 1
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

	.incbin "tilemap.chr"

	; End of CHR ROM
