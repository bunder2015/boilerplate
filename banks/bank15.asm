	.code
	.bank 30
	.org $C000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "15A"
	.endif

	; For use with ggsound - main ggsound code and game soundtrack
	.include "./include/ggsound/ggsound_nesasm/ggsound.asm"
	.include "./include/test.asm"

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

STARTNEWGAME:
	LDA #MMC1_PRG_BANK1
	STA <MMCPRG
	JSR UPDATEMMC1PRG

	JMP NEWGAME

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

	.ifdef DEBUG
DBGPALS:
	.db $01,$20,$10,$00	; BG palette 0

DBGTEXT1:
	.db "BREAK AT PC: "

DBGTEXT2:
	.db "A: "

DBGTEXT3:
	.db "X: "

DBGTEXT4:
	.db "Y: "

DBGTEXT5:
	.db "SP: "

DBGTEXT6:
	.db "PS: "
	.endif

SRAMFOOTERTEXT:
	.db "DISCOMBOBULATION"

SRAMHEADERTEXT:
	.db "THERMOTELEPHONIC"

	.code
	.bank 31
	.org $E000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "15B"
	.endif

	.ifdef DEBUG
BREAK:
	;; BRK debugger - store debug registers to memory, stop game execution, then display registers
	STY <DBGY		; Stash Y register
	TSX
	INX
	INX
	INX
	STX <DBGSP		; Stash stack pointer
	PLA			; Pull processor status from the stack
	STA <DBGPS		; Stash processor status
	PLA
	STA <DBGPC+1
	PLA			; Pull program counter from the stack
	STA <DBGPC		; Stash program counter
	DEC <DBGPC+1
	DEC <DBGPC+1		; Return program counter to address that caused the BRK

	LDA #0
	STA MUSICEN
	JSR sound_stop		; Stop sound

	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	JSR CLEARSCREEN

	LDA #$3F
	STA <PPUCADDR
	LDA #$00
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #4
	STA <PPUCLEN+1
	LDA #LOW(DBGPALS)
	STA <PPUCINPUT
	LDA #HIGH(DBGPALS)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load palettes into PPU

	LDA #$20
	STA <PPUCADDR
	LDA #$41
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #13
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT1)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT1)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 1 into PPU
	LDA <DBGPC
	STA <PBINPUT
	LDA <DBGPC+1
	STA <PBINPUT+1
	JSR PRINT2BYTES

	LDA #$20
	STA <PPUCADDR
	LDA #$61
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT2)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT2)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 2 into PPU
	LDA <DBGA
	STA <PBINPUT+1
	JSR PRINT1BYTE

	LDA #$20
	STA <PPUCADDR
	LDA #$69
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT3)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT3)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 3 into PPU
	LDA <DBGX
	STA <PBINPUT+1
	JSR PRINT1BYTE

	LDA #$20
	STA <PPUCADDR
	LDA #$71
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #3
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT4)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT4)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 4 into PPU
	LDA <DBGY
	STA <PBINPUT+1
	JSR PRINT1BYTE

	LDA #$20
	STA <PPUCADDR
	LDA #$81
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #4
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT5)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT5)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 5 into PPU
	LDA <DBGSP
	STA <PBINPUT+1
	JSR PRINT1BYTE

	LDA #$20
	STA <PPUCADDR
	LDA #$89
	STA <PPUCADDR+1
	LDA #0
	STA <PPUCLEN
	LDA #4
	STA <PPUCLEN+1
	LDA #LOW(DBGTEXT6)
	STA <PPUCINPUT
	LDA #HIGH(DBGTEXT6)
	STA <PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 6 into PPU
	LDA <DBGPS
	STA <PBINPUT+1
	JSR PRINT1BYTE

	LDA #NT_SEL0
	STA <NT			; Select nametable 0
	JSR UPDATEPPUCTRL

	JSR VBWAIT
.LOOP:
	JMP .LOOP		; Infinite loop
	.endif

CLEARSCREEN:
	;; Clears the tiles on the screen and all sprites
	;; Input: none
	;; Clobbers: A X Y
	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
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
	STA PPUDATA		; Clear nametable 0 and 1 and attributes
	INY
	CPY <PPUCLEN+1
	BNE .L1
	LDY #$00
	INX
	CPX <PPUCLEN
	BNE .L1

	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #32
	STA <PPUCLEN+1

	LDA #$0F		; 0F sets the palette colours to all black
	LDY #$00
.L2:
	STA PPUDATA		; Clear palette table
	INY
	CPY <PPUCLEN+1
	BNE .L2

	JSR CLEARSPR		; Clear sprites from screen
	JSR RESETSCR		; Reset PPU scrolling
	JSR UPDATEPPUCTRL	; Update PPU controls
	JSR VBWAIT		; Wait for next vblank

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

CLEARSPR:
	;; Clears the sprites from the screen
	;; Input: none
	;; Clobbers: A X
	LDA #$FF		; FF moves the sprites off the screen
	LDX #$00
.L1:
	STA $0200, X		; Remove all sprites from screen
	INX
	BNE .L1

	JSR VBWAIT

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

CPUCOPY:
	;; Copies lengths of data within the CPU address space
	;; Input: <CPUCADDR <CPUCLEN <CPUCINPUT
	;; Clobbers: A X Y
	LDX #$FF
	LDY #$00		; Set loop counters

.L1:
	LDA [CPUCINPUT], Y	; Load data
	STA [CPUCADDR], Y	; Store data
	INY
	CPY <CPUCLEN+1
	BNE .L1
	LDY #$00
	INX
	CPX <CPUCLEN		; Check to see if we have finished copying
	BNE .L1			; Loop if we have not finished copying

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

HIDESAVEICON:
	;; Removes the save icon from the screen
	;; Input: None
	;; Clobbers: A Y
	LDA #$FF
	LDY #0
.L1:
	STA SPR60Y, Y
	INY
	CPY #16
	BNE .L1

	JSR VBWAIT

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

PPUCOPY:
	;; Copies lengths of data from the CPU to the PPU
	;; Input: <PPUCADDR <PPUCLEN <PPUCINPUT
	;; Clobbers: A X Y
	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
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

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

PRINT2BYTES:
	; Prints two hex bytes to the screen, assumes PPUADDR has already been set
	; This must be placed before PRINT1BYTE as we fall through to print the other byte
	; Input: <PBINPUT
	; Clobbers: A
	LDA <PBINPUT			; Left side byte
	AND #%11110000			; Left side bits
	STA <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP			; Shift left side bits into right side bits
	LDA <PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS .ALPHALEFT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP .PRINTLEFT
.ALPHALEFT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
.PRINTLEFT:
	STA PPUDATA			; Write to PPU

	LDA <PBINPUT			; Left side byte
	AND #%00001111			; Right side bits
	STA <PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS .ALPHARIGHT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP .PRINTRIGHT
.ALPHARIGHT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
.PRINTRIGHT:
	STA PPUDATA			; Write to PPU

	; Intentionally falls through

PRINT1BYTE:
	; Prints one hex byte to the screen, assumes PPUADDR has already been set
	; Input: <PBINPUT
	; Clobbers: A
	LDA <PBINPUT+1			; Right side byte
	AND #%11110000			; Left side bits
	STA <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP
	LSR <PBTEMP			; Shift left side bits into right side bits
	LDA <PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS .ALPHALEFT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP .PRINTLEFT
.ALPHALEFT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
.PRINTLEFT:
	STA PPUDATA			; Write to PPU

	LDA <PBINPUT+1			; Right side byte
	AND #%00001111			; Right side bits
	STA <PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS .ALPHARIGHT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP .PRINTRIGHT
.ALPHARIGHT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
.PRINTRIGHT:
	STA PPUDATA			; Write to PPU

	JSR VBWAIT
	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

READJOYS:
	;; Reads the controllers and saves the buttons pressed
	;; Input: none
	;; Clobbers: A X
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

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

RESETSCR:
	;; Resets scrolling to the correct position
	;; Input: <SCROLLX <SCROLLY
	;; Clobbers: A
	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch

	LDA <SCROLLX
	STA PPUSCROLL
	LDA <SCROLLY
	STA PPUSCROLL		; Reset PPU scrolling

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

SHOWERRORICON:
	;; Shows an error icon on the screen
	;; Input: None
	;; Clobbers: A
	LDA #$D8
	STA SPR56X
	LDA #$D8
	STA SPR56Y
	LDA #$E0
	STA SPR56TILE
	LDA #SPR_PALETTE3
	STA SPR56ATTR		; Top left

	LDA #$E0
	STA SPR57X
	LDA #$D8
	STA SPR57Y
	LDA #$E1
	STA SPR57TILE
	LDA #SPR_PALETTE3
	STA SPR57ATTR		; Top right

	LDA #$D8
	STA SPR58X
	LDA #$E0
	STA SPR58Y
	LDA #$F0
	STA SPR58TILE
	LDA #SPR_PALETTE3
	STA SPR58ATTR		; Bottom left

	LDA #$E0
	STA SPR59X
	LDA #$E0
	STA SPR59Y
	LDA #$F1
	STA SPR59TILE
	LDA #SPR_PALETTE3
	STA SPR59ATTR		; Bottom right

	JSR VBWAIT

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

SHOWSAVEICON:
	;; Shows a save icon on the screen
	;; Input: None
	;; Clobbers: A
	LDA #$E8
	STA SPR60X
	LDA #$D8
	STA SPR60Y
	LDA #$E2
	STA SPR60TILE
	LDA #SPR_PALETTE3
	STA SPR60ATTR		; Top left

	LDA #$F0
	STA SPR61X
	LDA #$D8
	STA SPR61Y
	LDA #$E3
	STA SPR61TILE
	LDA #SPR_PALETTE3
	STA SPR61ATTR		; Top right

	LDA #$E8
	STA SPR62X
	LDA #$E0
	STA SPR62Y
	LDA #$F2
	STA SPR62TILE
	LDA #SPR_PALETTE3
	STA SPR62ATTR		; Bottom left

	LDA #$F0
	STA SPR63X
	LDA #$E0
	STA SPR63Y
	LDA #$F3
	STA SPR63TILE
	LDA #SPR_PALETTE3
	STA SPR63ATTR		; Bottom right

	JSR VBWAIT

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

SRAMTESTA:
	;; Verifies the PRG RAM header and footer, returns 1 on success
	;; Input: none
	;; Clobbers: A Y
	LDY #$00
.L1:
	LDA SRAMHEADERTEXT, Y
	CMP SRAMHEADER, Y
	BNE .BAD
	INY
	CPY #16
	BNE .L1

	LDY #0
.L2:
	LDA SRAMFOOTERTEXT, Y
	CMP SRAMFOOTER, Y
	BNE .BAD
	INY
	CPY #16
	BNE .L2

	LDA #1
	RTS
.BAD:
	LDA #0
	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

SRAMTESTC:
	;; Verifies the PRG RAM option variable bounds, returns 1 on success
	;; Input: none
	;; Clobbers: A
	LDA SRAMMUSIC
	CMP #2			; SRAMMUSIC range is 0-1
	BCS .BAD		; Carry will be set if higher than 1
	LDA #1
	RTS
.BAD:
	LDA #0
	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

SRAMWIPE:
	;; Wipes the PRG RAM located at $6000-7FFF and places a new header/footer
	;; Input: none
	;; Clobbers: A X Y
	LDA #$00
	STA <TEMPADDR
	LDA #$60
	STA <TEMPADDR+1		; Set TEMPADDR to $6000

	LDA #$00
	TAX
	TAY			; Clear A/X/Y
.L1:
	STA [TEMPADDR], Y
	INY
	BNE .L1			; Wipe PRG RAM

	INC <TEMPADDR+1
	INX
	CPX #$20
	BNE .L1

	LDA #$00
	STA <CPUCADDR
	LDA #$60
	STA <CPUCADDR+1
	LDA #0
	STA <CPUCLEN
	LDA #16
	STA <CPUCLEN+1
	LDA #LOW(SRAMHEADERTEXT)
	STA <CPUCINPUT
	LDA #HIGH(SRAMHEADERTEXT)
	STA <CPUCINPUT+1
	JSR CPUCOPY		; Write header to PRG RAM

	LDA #$F0
	STA <CPUCADDR
	LDA #$7F
	STA <CPUCADDR+1
	LDA #0
	STA <CPUCLEN
	LDA #16
	STA <CPUCLEN+1
	LDA #LOW(SRAMFOOTERTEXT)
	STA <CPUCINPUT
	LDA #HIGH(SRAMFOOTERTEXT)
	STA <CPUCINPUT+1
	JSR CPUCOPY		; Write footer to PRG RAM

	LDA #1
	STA SRAMMUSIC		; Set the default music value

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEMMC1CHR0:
	;; Selects the first CHR ROM bank
	;; Input: <MMCCHR0
	;; Clobbers: A
	LDA <MMCCHR0
	AND #MMC1_CHR_BANKS

	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0		; Write bitfield to MMC1CHR0

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEMMC1CHR1:
	;; Selects the second CHR ROM bank
	;; Input: <MMCCHR1
	;; Clobbers: A
	LDA <MMCCHR1
	AND #MMC1_CHR_BANKS

	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1		; Write bitfield to MMC1CHR1

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEMMC1CTRL:
	;; Sets PRG ROM and CHR ROM bank modes and nametable mirroring mode
	;; Input: <MMCCHRMODE <MMCPRGMODE <MMCMIRROR
	;; Clobbers: A
	LDA <MMCCHRMODE
	AND #MMC1_CHR_MODE1
	STA <TEMP		; Bit 4 - MMC1 CHR ROM bank mode

	LDA <MMCPRGMODE
	AND #MMC1_PRG_MODE3
	ORA <TEMP
	STA <TEMP		; Bits 3 and 2 - MMC1 PRG ROM bank mode

	LDA <MMCMIRROR
	AND #MMC1_MIRROR_H
	ORA <TEMP
	STA <TEMP		; Bits 1 and 0 - MMC1 mirroring mode

	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL		; Write combined bitfield to MMC1CTRL

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEMMC1PRG:
	;; Enables/disables PRG RAM and selects the PRG ROM bank
	;; Input: <MMCRAM <MMCPRG
	;; Clobbers: A
	LDA <MMCRAM
	AND #MMC1_PRGRAM_DIS
	STA <TEMP		; Bit 4 - PRG RAM toggle

	LDA <MMCPRG
	AND #MMC1_PRG_BANK15
	ORA <TEMP
	STA <TEMP		; Bits 3 to 0 - PRG ROM bank

	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG		; Write combined bitfield to MMC1PRG

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEPPUCTRL:
	;; Selects background/sprite pattern tables, nametables, enables/disables NMI
	;; Input: <BGPT <SPRPT <NT <NMIEN
	;; Clobbers: A
	LDA <NMIEN
	AND #NMI_EN
	STA <TEMP		; Bit 7 - NMI enable toggle

	; TODO - bit 5

	LDA <BGPT
	AND #BG_PT1
	ORA <TEMP
	STA <TEMP		; Bit 4 - BG pattern table selection

	LDA <SPRPT
	AND #SPR_PT1
	ORA <TEMP
	STA <TEMP		; Bit 3 - SPR pattern table selection

	; TODO - bit 2

	LDA <NT
	AND #NT_SEL3
	ORA <TEMP
	STA <TEMP		; Bits 1 and 0 - Nametable selection

	BIT PPUSTATUS		; Read PPUSTATUS to clear vblank
	STA PPUCTRL		; Write combined bitfield to PPUCTRL

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATEPPUMASK:
	;; Sets b+w/colour modes, enables leftmost 8px cropping, enables rendering, and colour emphasis
	;; Input: <COLOUREN <BGNOCROP <SPRNOCROP <BGEN <SPREN <CEMPHR <CEMPHG <CEMPHB
	;; Clobbers: A
	LDA <CEMPHB
	AND #CLR_EMPH_BLUE
	STA <TEMP		; Bit 7 - Colour emphasis blue

	LDA <CEMPHG
	AND #CLR_EMPH_GREEN
	ORA <TEMP
	STA <TEMP		; Bit 6 - Colour emphasis green

	LDA <CEMPHR
	AND #CLR_EMPH_RED
	ORA <TEMP
	STA <TEMP		; Bit 5 - Colour emphasis red

	LDA <SPREN
	AND #SPR_REND_EN
	ORA <TEMP
	STA <TEMP		; Bit 4 - SPR rendering enable

	LDA <BGEN
	AND #BG_REND_EN
	ORA <TEMP
	STA <TEMP		; Bit 3 - BG rendering enable

	LDA <SPRNOCROP
	AND #SPR_REND_NOCROP
	ORA <TEMP
	STA <TEMP		; Bit 2 - SPR leftmost 8px cropping

	LDA <BGNOCROP
	AND #BG_REND_NOCROP
	ORA <TEMP
	STA <TEMP		; Bit 1 - BG leftmost 8px cropping

	LDA <COLOUREN
	AND #CLR_EN
	ORA <TEMP
	STA <TEMP		; Bit 0 - Colour enable

	STA PPUMASK		; Write combined bitfield to PPUMASK

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

VBWAIT:
	;; Waits for the next vblank, or a number of vblanks
	;; Input: <WAITFRAMES
	;; Clobbers: A X
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

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

;;;;;;;;;;

	.code
	.bank 31
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

	LDA #SPR_REND_EN
	STA <SPREN
	LDA #BG_REND_EN
	STA <BGEN
	JSR UPDATEPPUMASK	; Enable rendering

	JSR READJOYS		; Read controllers

	LDA <SOUNDREADY
	BEQ .SOUNDNOTINIT
	soundengine_update	; Play sound

.SOUNDNOTINIT:
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

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

RESET:
	SEI			; Disable IRQ
	CLD			; Disable decimal mode
	LDX #%01000000
	STX APUFRAME		; Disable APU frame IRQ
	LDX #$FF
	TXS			; Initialize stack pointer
	INX			; Roll X over back to #$00
	STX PPUCTRL		; Disable PPU vblank NMI
	STX PPUMASK		; Disable PPU rendering
	STX DMCFREQ		; Disable APU DMC IRQ
	BIT PPUSTATUS		; Clear vblank bit if console reset during a vblank

.VB1:
	BIT PPUSTATUS
	BPL .VB1		; Wait for first vblank

.MEMCLR:
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
	BNE .MEMCLR

.VB2:
	BIT PPUSTATUS
	BPL .VB2		; Wait for second vblank

.MMC1INIT:
	LDA #MMC1_CHR_MODE1
	STA <MMCCHRMODE		; CHR mode 1 (2x4k switchable pattern tables)
	LDA #MMC1_MIRROR_V
	STA <MMCMIRROR		; Vertical mirroring selected
	LDA #MMC1_PRG_MODE3
	STA <MMCPRGMODE		; PRG mode 3 (bank 15 fixed to CPU $C000, switchable $8000)
	JSR UPDATEMMC1CTRL

	LDA #MMC1_PRG_BANK0
	STA <MMCPRG		; PRG bank 0 selected at CPU $8000
	LDA #MMC1_PRGRAM_DIS
	STA <MMCRAM		; PRG RAM disabled
	JSR UPDATEMMC1PRG

	LDA #MMC1_CHR_BANK0
	STA <MMCCHR0		; CHR bank 0 selected at PPU $0000
	JSR UPDATEMMC1CHR0

	LDA #MMC1_CHR_BANK1
	STA <MMCCHR1		; CHR bank 1 selected at PPU $1000
	JSR UPDATEMMC1CHR1

.RESETDONE:
	LDA #NMI_EN
	STA <NMIEN		; Enable NMI
	JSR UPDATEPPUCTRL
	JSR CLEARSCREEN		; Clear the screen
	JMP MAINMENU		; Go to main menu

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

IRQ:
	.ifdef DEBUG
	STA <DBGA		; Stash accumulator
	PLA			; Pull processor status from the stack
	PHA			; Return processor status to the stack
	AND #CPU_FLAG_B		; Check for "B flag"
	BEQ .NOBRK		; Branch if not set
	JMP BREAK		; Jump to break handler
.NOBRK:
	LDA <DBGA		; Restore accumulator
	.endif
	;; TODO - sound code IRQ

	RTI			; Exit IRQ

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

	.code
	.bank 31
	.org $FFF0

RESET_MMC15:
	SEI
	LDX #$FF
	TXS
	STX MMC1CTRL
	JMP RESET

	.dw NMI
	.dw RESET_MMC15
	.dw IRQ
