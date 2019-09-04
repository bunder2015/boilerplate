	.code
	.bank 0
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "00A"
	.endif

MAINMENU:
	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	LDA #REND_CROP_DIS
	STA <BGNOCROP
	STA <SPRNOCROP
	JSR UPDATEPPUMASK	; Disable rendering

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
	; We return here from the options screen since the main menu screen should already be
	; drawn from the initial startup
	LDA #BG_PT0
	STA <BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA <SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL0
	STA <NT			; Select nametable 0
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDA #0
	STA <SCROLLX
	STA <SCROLLY		; Set initial scroll to top left corner

	LDA <SKIPSRAMTEST
	BNE .SKIPSRAMTEST	; Skip test if we have already run it

	JSR SHOWSAVEICON	; Show the save icon while PRG RAM is active

	LDA #MMC1_PRGRAM_EN
	STA <MMCRAM
	JSR UPDATEMMC1PRG	; Enable PRG RAM

	JSR SRAMTESTA		; Verify header and footer
	BNE .SRAMTESTRUNC
	JMP .SRAMTESTFAIL

.SRAMTESTRUNC:
	JSR SRAMTESTC		; Verify option variable bounds
	BNE .SRAMTESTPASS
	;; TODO - additional tests here (checksum/etc)

.SRAMTESTFAIL:
	; We failed a test, wipe PRG RAM
	JSR SHOWERRORICON	; Show the error icon
	JSR SRAMWIPE		; Wipe PRG RAM

.SRAMTESTPASS:
	LDA SRAMMUSIC
	STA MUSICEN		; Load music toggle from PRG RAM and store to WRAM

.SRAMTESTDONE:
	LDA #MMC1_PRGRAM_DIS
	STA <MMCRAM
	JSR UPDATEMMC1PRG	; Disable PRG RAM until we need it again

	JSR HIDESAVEICON	; Hide the save icon

	LDA #1
	STA <SKIPSRAMTEST	; Mark tests as done so we can skip them if we run the main menu again
	STA <SOUNDREADY

	LDA #SOUND_REGION_NTSC
	STA <sound_param_byte_0

	LDA #LOW(song_list)
	STA <sound_param_word_0
	LDA #HIGH(song_list)
	STA <sound_param_word_0+1

	;LDA #LOW(sfx_list)
	;STA <sound_param_word_1
	;LDA #HIGH(sfx_list)
	;STA <sound_param_word_1+1

	LDA #LOW(instrument_list)
	STA <sound_param_word_2
	LDA #HIGH(instrument_list)
	STA <sound_param_word_2+1

	;LDA #LOW(dpcm_list)
	;STA <sound_param_word_3
	;LDA #HIGH(dpcm_list)
	;STA <sound_param_word_3+1

	JSR sound_initialize	; Initialize the sound hardware

	LDA #song_index_New20song
	STA <sound_param_byte_0

	LDA MUSICEN
	BEQ .SKIPSRAMTEST	; Check if music is enabled

	JSR play_song		; Start music

.SKIPSRAMTEST:
	LDA #$58
	STA SPR1X
	LDA #$90
	STA SPR1Y
	LDA #$01
	STA SPR1TILE
	LDA #SPR_PALETTE0
	STA SPR1ATTR		; Draw a basic cursor sprite

	LDA #15
	STA <WAITFRAMES
	JSR VBWAIT		; Wait for 15 frames

.MENULOOP:
	LDA <JOY1IN
	BNE .DOWN
	JMP .DONE		; Skip loop if player 1 is not pressing buttons

.DOWN:
	LDA <JOY1IN
	AND #BUTTON_DOWN	; Check if player 1 is pressing down
	BEQ .UP
	LDA SPR1Y
	CMP #$90		; Check if the cursor is in the top position
	BNE .MENUDOUT
	LDA #$A0
	STA SPR1Y		; Move cursor down
.MENUDOUT:
	JMP .DONE

.UP:
	LDA <JOY1IN
	AND #BUTTON_UP		; Check if player 1 is pressing up
	BEQ .STNEW
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .MENUUOUT
	LDA #$90
	STA SPR1Y		; Move cursor up
.MENUUOUT:
	JMP .DONE

.STNEW:
	LDA <JOY1IN
	AND #BUTTON_START	; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$90		; Check if the cursor is in the top position
	BNE .STOPTS
	JSR pause_song		; Stop music
	JSR CLEARSCREEN		; Clear screen
	JMP STARTNEWGAME	; Go to new game
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

OPTIONS:
	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering

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
	LDA #$66
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #19
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

	LDA #BG_PT0
	STA <BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA <SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL1
	STA <NT			; Select nametable 1
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDA #$20
	STA SPR1X
	LDA #$58
	STA SPR1Y
	LDA #$01
	STA SPR1TILE
	LDA #SPR_PALETTE0
	STA SPR1ATTR		; Draw the options cursor

	LDA MUSICEN		; Check if music is disabled
	BEQ .MUSICOFF

	LDA #LOW(MUSICATTRON)
	STA <PPUCINPUT
	LDA #HIGH(MUSICATTRON)
	STA <PPUCINPUT+1

	JMP .MUSICDONE
.MUSICOFF:
	LDA #LOW(MUSICATTROFF)
	STA <PPUCINPUT
	LDA #HIGH(MUSICATTROFF)
	STA <PPUCINPUT+1

.MUSICDONE:
	LDA #$27
	STA <PPUCADDR
	LDA #$D4
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	JSR PPUCOPY		; Change attributes of music toggle based on state

	LDA #15
	STA <WAITFRAMES
	JSR VBWAIT		; Wait for 15 frames

.OPTIONSLOOP:
	; 20,58 "music" cursor position
	; 20,A0 "return" cursor position
	LDA <JOY1IN
	BNE .DOWN
	JMP .DONE		; Skip loop if player 1 is not pressing buttons
.DOWN:
	LDA <JOY1IN
	AND #BUTTON_DOWN	; Check if player 1 is pressing down
	BEQ .UP
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .OPTIONSDOUT
	LDA #$A0
	STA SPR1Y		; Move cursor down
.OPTIONSDOUT:
	JMP .DONE

.UP:
	LDA <JOY1IN
	AND #BUTTON_UP		; Check if player 1 is pressing up
	BEQ .LMUSIC
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .OPTIONSUOUT
	LDA #$58
	STA SPR1Y		; Move cursor up
.OPTIONSUOUT:
	JMP .DONE

.LMUSIC:
	LDA <JOY1IN
	AND #BUTTON_LEFT	; Check if player 1 is pressing left
	BEQ .RMUSIC
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .OPTIONSLOUT
	LDA MUSICEN		; Check if music is disabled
	BNE .OPTIONSLOUT
	LDA #1			; Turn music toggle on
	STA MUSICEN

	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering
	JSR VBWAIT

	LDA #$27
	STA <PPUCADDR
	LDA #$D4
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	LDA #LOW(MUSICATTRON)
	STA <PPUCINPUT
	LDA #HIGH(MUSICATTRON)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Change attributes of music toggle

	LDA #song_index_New20song
	STA <sound_param_byte_0
	JSR play_song		; Start music
.OPTIONSLOUT:
	JMP .DONE

.RMUSIC:
	LDA <JOY1IN
	AND #BUTTON_RIGHT	; Check if player 1 is pressing right
	BEQ .STRETURN
	LDA SPR1Y
	CMP #$58		; Check if the cursor is in the top position
	BNE .OPTIONSROUT
	LDA MUSICEN		; Check if music is enabled
	BEQ .OPTIONSROUT
	LDA #0
	STA MUSICEN		; Turn music toggle off

	JSR pause_song		; Stop music

	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering
	JSR VBWAIT

	LDA #$27
	STA <PPUCADDR
	LDA #$D4
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	LDA #LOW(MUSICATTROFF)
	STA <PPUCINPUT
	LDA #HIGH(MUSICATTROFF)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Change attributes of music toggle
.OPTIONSROUT:
	JMP .DONE

.STRETURN:
	LDA <JOY1IN
	AND #BUTTON_START	; Check if player 1 is pressing start
	BEQ .DONE
	LDA SPR1Y
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE .DONE

	JSR SHOWSAVEICON

	LDA #MMC1_PRGRAM_EN
	STA <MMCRAM
	JSR UPDATEMMC1PRG	; Enable PRG RAM

	LDA MUSICEN
	STA SRAMMUSIC		; Save music toggle to PRG RAM

	LDA #MMC1_PRGRAM_DIS
	STA <MMCRAM
	JSR UPDATEMMC1PRG	; Disable PRG RAM

	JSR HIDESAVEICON

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
	.db $0F,$13,$10,$00	; BG palette 2
	.db $0F,$30,$10,$00	; BG palette 3

	.db $0F,$13,$10,$00	; SPR palette 0
	.db $0F,$30,$10,$00	; SPR palette 1
	.db $0F,$30,$10,$00	; SPR palette 2
	.db $0F,$11,$16,$10	; SPR palette 3

MENUTEXT:
	.db "BOILER PLATE!"
MENUTEXT1:
	.db "New game"
MENUTEXT2:
	.db "Options"

MUSICATTRON:
	.db $20,$00,$00

MUSICATTROFF:
	.db $00,$80,$20

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
	.db "Music:    On    Off"
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
