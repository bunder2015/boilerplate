	.code
	.bank 30
	.org $C000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "15A"

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

	;; TODO - stop sound
	JSR RENDERDIS
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
	LDA #1
	STA <PRINTB
	JSR PRINTBYTE

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
	LDA #2
	STA <PRINTB
	JSR PRINTBYTE

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
	LDA #3
	STA <PRINTB
	JSR PRINTBYTE

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
	LDA #4
	STA <PRINTB
	JSR PRINTBYTE

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
	LDA #5
	STA <PRINTB
	JSR PRINTBYTE

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
	LDA #6
	STA <PRINTB
	JSR PRINTBYTE

	LDA #%00000000
	STA <NT			; Select nametable 0
	JSR UPDATE2000

	JSR VBWAIT
.LOOP:
	JMP .LOOP		; Infinite loop

PRINTBYTE:
	;; Prints debug registers from memory to screen (1-2 byte hex to ASCII)
	;; Input: <PRINTB <DBGPC <DBGA <DBGX <DBGY <DBGSP <DBGPS
	;; Clobbers: A
	;; TODO - Optimize this subroutine for size
	LDA <PRINTB		; Byte to print
	CMP #1			; Program Counter
	BNE .P2

	LDA <DBGPC
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A1
	CLC
	ADC #$30
	JMP .N1
.A1:
	CLC
	ADC #$37
.N1:
	STA PPUDATA

	LDA <DBGPC
	AND #%00001111
	CMP #10
	BCS .A2
	CLC
	ADC #$30
	JMP .N2
.A2:
	CLC
	ADC #$37
.N2:
	STA PPUDATA

	LDA <DBGPC+1
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A3
	CLC
	ADC #$30
	JMP .N3
.A3:
	CLC
	ADC #$37
.N3:
	STA PPUDATA

	LDA <DBGPC+1
	AND #%00001111
	CMP #10
	BCS .A4
	CLC
	ADC #$30
	JMP .N4
.A4:
	CLC
	ADC #$37
.N4:
	STA PPUDATA

	JMP .OUT
.P2:
	LDA <PRINTB		; Byte to print
	CMP #2			; A register
	BNE .P3

	LDA <DBGA
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A5
	CLC
	ADC #$30
	JMP .N5
.A5:
	CLC
	ADC #$37
.N5:
	STA PPUDATA

	LDA <DBGA
	AND #%00001111
	CMP #10
	BCS .A6
	CLC
	ADC #$30
	JMP .N6
.A6:
	CLC
	ADC #$37
.N6:
	STA PPUDATA

	JMP .OUT
.P3:
	LDA <PRINTB		; Byte to print
	CMP #3			; X register
	BNE .P4

	LDA <DBGX
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A7
	CLC
	ADC #$30
	JMP .N7
.A7:
	CLC
	ADC #$37
.N7:
	STA PPUDATA

	LDA <DBGX
	AND #%00001111
	CMP #10
	BCS .A8
	CLC
	ADC #$30
	JMP .N8
.A8:
	CLC
	ADC #$37
.N8:
	STA PPUDATA

	JMP .OUT
.P4:
	LDA <PRINTB		; Byte to print
	CMP #4			; Y register
	BNE .P5

	LDA <DBGY
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A9
	CLC
	ADC #$30
	JMP .N9
.A9:
	CLC
	ADC #$37
.N9:
	STA PPUDATA

	LDA <DBGY
	AND #%00001111
	CMP #10
	BCS .A10
	CLC
	ADC #$30
	JMP .N10
.A10:
	CLC
	ADC #$37
.N10:
	STA PPUDATA

	JMP .OUT
.P5:
	LDA <PRINTB		; Byte to print
	CMP #5			; Stack Pointer
	BNE .P6

	LDA <DBGSP
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A11
	CLC
	ADC #$30
	JMP .N11
.A11:
	CLC
	ADC #$37
.N11:
	STA PPUDATA

	LDA <DBGSP
	AND #%00001111
	CMP #10
	BCS .A12
	CLC
	ADC #$30
	JMP .N12
.A12:
	CLC
	ADC #$37
.N12:
	STA PPUDATA

	JMP .OUT
.P6:
	LDA <PRINTB		; Byte to print
	CMP #6			; CPU status flags
	BNE .OUT		; This should never happen

	LDA <DBGPS
	AND #%11110000
	STA <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LSR <PBTEMP1
	LDA <PBTEMP1
	CMP #10
	BCS .A13
	CLC
	ADC #$30
	JMP .N13
.A13:
	CLC
	ADC #$37
.N13:
	STA PPUDATA

	LDA <DBGPS
	AND #%00001111
	CMP #10
	BCS .A14
	CLC
	ADC #$30
	JMP .N14
.A14:
	CLC
	ADC #$37
.N14:
	STA PPUDATA

.OUT:
	JSR VBWAIT
	RTS

DBGATTR:
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Top 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Second 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Third 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Fourth 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Fifth 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Sixth 2 rows of screen
	.db $55,$55,$55,$55,$55,$55,$55,$55	; Seventh 2 rows of screen
	.db $05,$05,$05,$05,$05,$05,$05,$05	; Last row of screen (lower nibbles)

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

	.code
	.bank 31
	.org $E000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "15B"
	.endif

CHANGEMMCPRG:
	;; Enables/disables PRG RAM and selects the PRG ROM bank
	;; Input: <MMCRAM <MMCPRG
	;; Clobbers: A
	LDA <MMCRAM		; Read PRG RAM toggle
	ASL A
	ASL A
	ASL A
	ASL A
	ORA <MMCPRG		; Read PRG ROM bank
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG		; Change the PRG ROM+RAM settings
	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

CLEARSCREEN:
	;; Clears the tiles on the screen and all sprites
	;; Input: none
	;; Clobbers: A X Y
	JSR RENDERDIS		; Disable rendering

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
	STA PPUDATA		; Clear nametable 0 and 1 and attributes
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
	JSR UPDATE2000		; Update PPU controls
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

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

PPUCOPY:
	;; Copies lengths of data from the CPU to the PPU
	;; Input: <PPUCADDR <PPUCLEN <PPUCINPUT
	;; Clobbers: A X Y
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

RENDERDIS:
	;; Disables rendering the screen
	;; Input: none
	;; Clobbers: A
	LDA #$00000000
	STA PPUMASK		; Disable BG and SPR

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

RENDEREN:
	;; Enables rendering the screen
	;; Input: none
	;; Clobbers: A
	LDA #%00011110
	STA PPUMASK		; Enable BG and SPR

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

RESETSCR:
	;; Resets scrolling to the top left corner of nametables
	;; Input: none
	;; Clobbers: A
	LDA #$00
	STA PPUSCROLL
	STA PPUSCROLL		; Reset PPU scrolling to top left corner

	RTS

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif

UPDATE2000:
	;; Selects background/sprite pattern tables, nametables, enables/disables NMI
	;; Input: <BGPT <SPRPT <NT <NMIEN
	;; Clobbers: A X
	LDA #%00000000
	ORA <NMIEN		; Add NMI toggle to status update
	ORA <BGPT
	ORA <SPRPT		; Add pattern table selectons to status update
	ORA <NT			; Add nametable selection to status update
	LDX PPUSTATUS		; Read PPUSTATUS to clear vblank
	STA PPUCTRL		; Write update byte to PPU

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

	JSR RENDEREN		; Enable rendering
	JSR READJOYS		; Read controllers
	;; TODO - play sound

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
	INX
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
	LDA #%00001110		; Vertical mirroring, bank 15 fixed at $C000, 8kb CHR ROM banks
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL		; Initialize MMC1

	LDA #0
	STA <MMCPRG		; Bank 0 selected at $8000
	STA <MMCRAM		; PRG RAM disabled
	JSR CHANGEMMCPRG

.RESETDONE:
	LDA #%10000000
	STA <NMIEN		; Enable NMI
	JSR UPDATE2000
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
	AND #%00010000		; Check for "B flag"
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
