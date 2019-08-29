	.code
	.bank 2
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "01A"
	.endif

NEWGAME:
	LDA #REND_DIS
	STA <SPREN
	STA <BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	;; TODO - Display new game start

	LDA #BG_PT0
	STA <BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA <SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL0
	STA <NT			; Select nametable 0
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDA #15
	STA <WAITFRAMES
	JSR VBWAIT		; Wait for 15 frames

.STARTLOOP:
	;; TODO - Input
	BRK

.DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP .STARTLOOP

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.endif


	.code
	.bank 3
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "01B"
	.endif

        .code
        .bank 3
        .org $BFF0

RESET_MMC1:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

