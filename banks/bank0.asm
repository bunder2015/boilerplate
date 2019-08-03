	.code
	.bank 0
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "00A"
	.endif

MAINMENU:
	JSR RENDERDIS		; Disable rendering to load PPU

	LDA #$3F
	STA <PPUCADDR
	LDA #$00
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
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
	LDA #0
	STA <PPUCLEN
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
	LDA #0
	STA <PPUCLEN
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
	LDA #0
	STA <PPUCLEN
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
	LDA #0
	STA <PPUCLEN
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
	LDA #0
	STA <PPUCLEN
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
	LDA #$01
	STA SPR1TILE
	LDA #%00000001
	STA SPR1ATTR		; Draw a basic cursor sprite

	LDA #%00000000
	STA <BGPT		; Select BG pattern table 0
	LDA #%00001000
	STA <SPRPT		; Select sprite pattern table 1
	LDA #%00000000
	STA <NT			; Select nametable 0
	JSR UPDATE2000		; Update PPU controls

	JSR VBWAIT		; Wait for next vblank

.MENULOOP:
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
	BEQ .STNEW
	LDA SPR1Y
	CMP #$97		; Check if the cursor is in the bottom position
	BNE .STNEW
	LDA #$8F
	STA SPR1Y		; Move cursor up
.STNEW:
	LDA <JOY1IN
	AND #%00010000		; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$8F		; Check if the cursor is in the top position
	BNE .STOPTS
	JSR CLEARSCREEN		; Clear screen
	JMP NEWGAME		; Go to new game
.STOPTS:
	LDA SPR1Y
	CMP #$97		; Check if the cursor is in the bottom position
	BNE .DONE
	JSR CLEARSPR		; Clear sprites
	JMP OPTIONS		; Go to game options menu
.DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP .MENULOOP

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

NEWGAME:
	JSR RENDERDIS		; Disable rendering to load PPU

	;; TODO - Display new game start

	LDA #%00000000
	STA <BGPT		; Select BG pattern table 0
	LDA #%00001000
	STA <SPRPT		; Select sprite pattern table 1
	LDA #%00000000
	STA <NT			; Select nametable 0
	JSR UPDATE2000		; Update PPU controls

	JSR VBWAIT		; Wait for next vblank

.STARTLOOP:
	;; TODO - Input
	BRK

.DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP .STARTLOOP

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

OPTIONS:
	JSR RENDERDIS		; Disable rendering to load PPU

	;; TODO - Display options menu

	LDA #%00000000
	STA <BGPT		; Select BG pattern table 0
	LDA #%00001000
	STA <SPRPT		; Select sprite pattern table 1
	LDA #%00000001
	STA <NT			; Select nametable 1
	JSR UPDATE2000		; Update PPU controls

	JSR VBWAIT		; Wait for next vblank

.OPTIONSLOOP:
	;; TODO - Input
	BRK

.DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP .OPTIONSLOOP

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif


	.code
	.bank 1
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "00B"
	.endif

MENUATTR:
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Top 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Second 2 rows of screen
	.db $00,$00,$55,$55,$55,$55,$55,$00	; Third 2 rows of screen
	.db $00,$00,$05,$05,$05,$05,$05,$00	; Fourth 2 rows of screen
	.db $00,$00,$00,$F0,$F0,$30,$00,$00	; Fifth 2 rows of screen
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

        .code
        .bank 1
        .org $BFF0

RESET_MMC0:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

	.dw NMI
	.dw RESET_MMC15
	.dw IRQ
