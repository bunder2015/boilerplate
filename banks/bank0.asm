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
	JSR PPUCOPY		; Load menu BG new game text into PPU

	LDA #$22
	STA <PPUCADDR
	LDA #$8D
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #7
	STA <PPUCLEN+1
	LDA #LOW(MENUTEXT2)
	STA <PPUCINPUT
	LDA #HIGH(MENUTEXT2)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG option text into PPU

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

RETMAINMENU:
	LDA #$58
	STA SPR1X
	LDA #$90
	STA SPR1Y
	LDA #$01
	STA SPR1TILE
	LDA #%00000000
	STA SPR1ATTR		; Draw a basic cursor sprite

	LDA #%00000000
	STA <BGPT		; Select BG pattern table 0
	LDA #%00001000
	STA <SPRPT		; Select sprite pattern table 1
	LDA #%00000000
	STA <NT			; Select nametable 0
	JSR UPDATE2000		; Update PPU controls

	LDA #5
	STA <WAITFRAMES
	JSR VBWAIT		; Wait for next vblank

.MENULOOP:
	LDA <JOY1IN
	AND #%00000100		; Check if player 1 is pressing down
	BEQ .UP
	LDA SPR1Y
	CMP #$90		; Check if the cursor is in the top position
	BNE .UP
	LDA #$A0
	STA SPR1Y		; Move cursor down
.UP:
	LDA <JOY1IN
	AND #%00001000		; Check if player 1 is pressing up
	BEQ .STNEW
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .STNEW
	LDA #$90
	STA SPR1Y		; Move cursor up
.STNEW:
	LDA <JOY1IN
	AND #%00010000		; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$90		; Check if the cursor is in the top position
	BNE .STOPTS
	JSR CLEARSCREEN		; Clear screen
	JMP NEWGAME		; Go to new game
.STOPTS:
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
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

	LDA #5
	STA <WAITFRAMES
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

	LDA #$24
	STA <PPUCADDR
	LDA #$AA
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #11
	STA <PPUCLEN+1
	LDA #LOW(OPTIONSTEXT)
	STA <PPUCINPUT
	LDA #HIGH(OPTIONSTEXT)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load options title text into PPU

	LDA #$25
	STA <PPUCADDR
	LDA #$68
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #15
	STA <PPUCLEN+1
	LDA #LOW(OPTIONSTEXT1)
	STA <PPUCINPUT
	LDA #HIGH(OPTIONSTEXT1)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load options music text into PPU

	LDA #$26
	STA <PPUCADDR
	LDA #$86
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #20
	STA <PPUCLEN+1
	LDA #LOW(OPTIONSTEXT2)
	STA <PPUCINPUT
	LDA #HIGH(OPTIONSTEXT2)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load options return text into PPU

	LDA #$27
	STA <PPUCADDR
	LDA #$C0
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #64
	STA <PPUCLEN+1
	LDA #LOW(OPTIONSATTR)
	STA <PPUCINPUT
	LDA #HIGH(OPTIONSATTR)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG attributes into PPU

	;; TODO - We use the main menus palettes

	LDA #$30
	STA SPR1X
	LDA #$58
	STA SPR1Y
	LDA #$01
	STA SPR1TILE
	LDA #%00000000
	STA SPR1ATTR		; Draw the options cursor

	;; TODO - Load music toggle and place music cursor accordingly
	LDA #$78
	STA SPR2X
	LDA #$58
	STA SPR2Y
	LDA #$01
	STA SPR2TILE
	LDA #$00000001
	STA SPR2ATTR		; Draw the music cursor

	LDA #%00000000
	STA <BGPT		; Select BG pattern table 0
	LDA #%00001000
	STA <SPRPT		; Select sprite pattern table 1
	LDA #%00000001
	STA <NT			; Select nametable 1
	JSR UPDATE2000		; Update PPU controls

	LDA #5
	STA <WAITFRAMES
	JSR VBWAIT		; Wait for next vblank

.OPTIONSLOOP:
	; 30,58 "music" cursor position
	; 20,A0 "return" cursor position
	LDA <JOY1IN
	AND #%00000100		; Check if player 1 is pressing down
	BEQ .UP
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .UP
	LDA #$20
	STA SPR1X
	LDA #$A0
	STA SPR1Y		; Move cursor down
.UP:
	LDA <JOY1IN
	AND #%00001000		; Check if player 1 is pressing up
	BEQ .LMUSIC
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .LMUSIC
	LDA #$30
	STA SPR1X
	LDA #$58
	STA SPR1Y		; Move cursor up
.LMUSIC:
	; 78,58 "on" music cursor position
	; 98,58 "off" music cursor position
	LDA <JOY1IN
	AND #%00000010		; Check if player 1 is pressing left
	BEQ .RMUSIC
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .RMUSIC
	LDA SPR2X
	CMP #$98		; Check if the music cursor is in the right position
	BNE .RMUSIC
	;; TODO - Enable music
	LDA #$78
	STA SPR2X		; Move music cursor left
.RMUSIC:
	LDA <JOY1IN
	AND #%00000001		; Check if player 1 is pressing right
	BEQ .STRETURN
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .STRETURN
	LDA SPR2X
	CMP #$78		; Check if the music cursor is in the left position
	BNE .STRETURN
	;; TODO - Disable music
	LDA #$98
	STA SPR2X		; Move music cursor right
.STRETURN:
	LDA <JOY1IN
	AND #%00010000		; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .DONE
	;; TODO - Save options
	JSR CLEARSPR
	JMP RETMAINMENU

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
	.db $00,$00,$55,$55,$55,$55,$11,$00	; Third 2 rows of screen
	.db $00,$00,$05,$05,$05,$05,$01,$00	; Fourth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Fifth 2 rows of screen
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
	.db $0F,$30,$10,$00	; BG palette 0
	.db $0F,$2C,$21,$11	; BG palette 1
	.db $0F,$30,$10,$00	; BG palette 2
	.db $0F,$30,$10,$00	; BG palette 3

	.db $0F,$13,$10,$00	; SPR palette 0
	.db $0F,$15,$10,$00	; SPR palette 1
	.db $0F,$30,$10,$00	; SPR palette 2
	.db $0F,$30,$10,$00	; SPR palette 3

MENUTEXT:
	.db "BOILER PLATE!"
MENUTEXT1:
	.db "New game"
MENUTEXT2:
	.db "Options"

OPTIONSATTR:
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Top 2 rows of screen
	.db $00,$00,$04,$05,$05,$01,$00,$00	; Second 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Third 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Fourth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Fifth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Sixth 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Seventh 2 rows of screen
	.db $00,$00,$00,$00,$00,$00,$00,$00	; Last 2 rows of screen (lower nibbles)

OPTIONSTEXT:
	.db "- Options -"
OPTIONSTEXT1:
	.db "Music:  On  Off"
OPTIONSTEXT2:
	.db "Return to main menu"

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
