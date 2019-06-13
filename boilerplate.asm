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
NT:
	.ds 1
WAITFRAMES:
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
	JSR RENDERDIS		; Disable rendering to load PPU

	LDA #$3F
	STA <PPUCADDR
	LDA #$00
	STA <PPUCADDR+1
	LDA #32
	STA <PPUCLEN+1
	LDA #LOW(MENUPALS)
	STA <PPUCINPUT
	LDA #HIGH(MENUPALS)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load palettes into PPU

	LDA #$21
	STA <PPUCADDR
	LDA #$00
	STA <PPUCADDR+1
	LDA #153
	STA <PPUCLEN+1
	LDA #LOW(MENUBG)
	STA <PPUCINPUT
	LDA #HIGH(MENUBG)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG tiles into PPU

	LDA #$21
	STA <PPUCADDR
	LDA #$4A
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
	LDA #$4D
	STA <PPUCADDR+1
	LDA #8
	STA <PPUCLEN+1
	LDA #LOW(MENUTEXT1)
	STA <PPUCINPUT
	LDA #HIGH(MENUTEXT1)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG option text 1 into PPU

	LDA #$22
	STA <PPUCADDR
	LDA #$6D
	STA <PPUCADDR+1
	LDA #7
	STA <PPUCLEN+1
	LDA #LOW(MENUTEXT2)
	STA <PPUCINPUT
	LDA #HIGH(MENUTEXT2)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG option text 2 into PPU

	LDA #$23
	STA <PPUCADDR
	LDA #$C0
	STA <PPUCADDR+1
	LDA #64
	STA <PPUCLEN+1
	LDA #LOW(MENUATTR)
	STA <PPUCINPUT
	LDA #HIGH(MENUATTR)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG attributes into PPU

	LDA #$60
	STA SPR1X
	LDA #$8F
	STA SPR1Y
	LDA #$1C
	STA SPR1TILE
	LDA #$01
	STA SPR1ATTR		; Draw a basic cursor sprite

MENULOOP:
	LDA <JOY1IN
	AND #%00000100		; Check if player 1 is pressing down
	BEQ .UP
	LDA SPR1Y
	CMP #$8F		; Check if the cursor is in the top position
	BNE .UP
	LDA #$97
	STA SPR1Y		; Move cursor down
.UP:
	LDA <JOY1IN
	AND #%00001000		; Check if player 1 is pressing up
	BEQ .START
	LDA SPR1Y
	CMP #$97		; Check if the cursor is in the bottom position
	BNE .START
	LDA #$8F
	STA SPR1Y		; Move cursor up
.START:
	LDA <JOY1IN
	AND #%00010000		; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$8F		; Check if the cursor is in the top position
	BNE .STOPTS
	JSR CLEARSCREEN		; Clear screen
	JMP START		; Go to new game
.STOPTS:
	LDA SPR1Y
	CMP #$97		; Check if the cursor is in the bottom position
	BNE .DONE
	JSR CLEARSPR		; Clear sprites from screen
	JMP OPTIONS		; Go to game options menu
.DONE:
	LDA #$00
	STA <NT			; Select nametable 0

	JSR NMIEN		; Enable PPU vblank NMI
	JSR VBWAIT		; Wait for next vblank

	JMP MENULOOP

OPTIONS:
	JSR RENDERDIS		; Disable rendering to load PPU
	JSR NMIDIS
	;; TODO
	; Display options menu

OPTIONSLOOP:
	;; TODO
	; Input
.DONE:
	LDA #$01
	STA <NT			; Select nametable 1

	JSR NMIEN		; Enable PPU vblank NMI
	JSR VBWAIT		; Wait for next vblank

	JMP OPTIONSLOOP

START:
	JSR RENDERDIS		; Disable rendering to load PPU
	;; TODO
	; Display new game start

STARTLOOP:
	;; TODO
	; Input
.DONE:
	LDA #$00
	STA <NT			; Select nametable 0

	JSR NMIEN		; Enable PPU vblank NMI
	JSR VBWAIT		; Wait for next vblank

	JMP STARTLOOP

	.data
	.bank 0
	.org $D000

MENUATTR:
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Top 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Second 2 rows of screen
	.db $00,$55,$55,$55,$55,$55,$55,$00	; Third 2 rows of screen
	.db $00,$55,$55,$55,$55,$55,$55,$00	; Fourth 2 rows of screen
	.db $00,$00,$00,$FF,$FF,$FF,$00,$00	; Fifth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Sixth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Seventh 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Last row of screen (lower nibbles)

MENUBG:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$80,$81,$81,$81,$81,$81,$81,$81
	.db $81,$81,$81,$81,$81,$81,$81,$81,$82,$00,$00,$00,$00,$00,$00,$00	; Row 1 of title
	.db $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 2 of title
	.db $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 3 of title
	.db $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 4 of title
	.db $00,$00,$00,$00,$00,$00,$00,$00,$85,$86,$86,$86,$86,$86,$86,$86
	.db $86,$86,$86,$86,$86,$86,$86,$86,$87					; Row 5 of title

MENUPALS:
	.db $0F,$20,$10,$00	; BG palette 0
	.db $0F,$15,$10,$02	; BG palette 1
	.db $0F,$19,$10,$00	; BG palette 2
	.db $0F,$28,$10,$00	; BG palette 3

	.db $0F,$11,$10,$13	; SPR palette 0
	.db $0F,$26,$10,$2A	; SPR palette 1
	.db $0F,$25,$17,$00	; SPR palette 2
	.db $0F,$1C,$2C,$3C	; SPR palette 3

MENUTEXT:
	.db "BOILER PLATE!"

MENUTEXT1:
	.db "New Game"

MENUTEXT2:
	.db "Options"

;;;;;;;;;;

	.code
	.bank 1
	.org $E000

	;; TODO

CLEARSCREEN:
	JSR RENDERDIS		; Disable rendering
	JSR NMIDIS		; Disable PPU vblank NMI

	LDA PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA #$20
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$08
	STA <PPUCLEN
	LDA #$00
	STA <PPUCLEN+1

	LDA #$00
	LDX #$FF
	LDY #$00
.L1:
	STA PPUDATA		; Clear nametable 0 and 1
	INY
	CPY <PPUCLEN+1
	BNE .L1
	LDY #$00
	INX
	CPX <PPUCLEN
	BNE .L1

	LDA PPUSTATUS
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$20
	STA <PPUCLEN+1

	LDA #$00
	LDY #$00
.L2:
	STA PPUDATA		; Clear attribute table
	INY
	CPY <PPUCLEN+1
	BNE .L2

	JSR CLEARSPR		; Clear sprites from screen
	JSR RESETSCR		; Reset PPU scrolling
	JSR NMIEN		; Enable PPU vblank NMI
	JSR VBWAIT		; Wait for next vblank

	RTS

CLEARSPR:
	LDA #$FF
	LDX #$00
.L1:
	STA $0200, X		; Remove all sprites from screen
	INX
	BNE .L1

	RTS

NMIDIS:
	LDA #%00000000
	ORA <NT			; Add nametable selection to NMI disable flag
	LDX PPUSTATUS		; Read PPUSTATUS to clear vblank
	STA PPUCTRL		; Disable PPU vblank NMI

	RTS

NMIEN:
	LDA #%10000000
	ORA <NT			; Add nametable selection to NMI enable flag
	LDX PPUSTATUS		; Read PPUSTATUS to clear vblank
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
.L1:
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

RENDERDIS:
	LDA #$00000000
	STA PPUMASK		; Disable BG and SPR

	RTS

RENDEREN:
	LDA #%00011110
	STA PPUMASK		; Enable BG and SPR

	RTS

RESETSCR:
	LDA #$00
	STA PPUSCROLL
	STA PPUSCROLL		; Reset PPU scrolling to top left corner

	RTS

VBWAIT:
	INC <NMIREADY		; Store waiting status
.L1:
	LDA <NMIREADY		; Load waiting status
	BNE .L1			; Loop if still waiting
	LDX <WAITFRAMES
	BEQ .OUT		; Loop if we need to wait more frames
	INC <NMIREADY
	JMP .L1
.OUT:
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

	LDA <NMIREADY		; Load waiting status
	BEQ .OUT		; if we are not waiting, bail out of NMI

	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA		; DMA transfer $0200-$02FF to PPU OAM

	JSR RENDEREN		; Enable rendering
	JSR READJOYS		; Read controllers

	DEC <NMIREADY		; Reset waiting status
	LDA <WAITFRAMES
	BEQ .OUT
	DEC <WAITFRAMES

.OUT:
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
	LDA #$FF
	STA $0200, X		; Initialize WRAM copy of PPU OAM
	LDA #$00
	STA $0000, X
	STA $0100, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X		; Initialize WRAM
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
