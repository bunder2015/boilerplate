	.code
	.bank 6
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "03A"
	.endif

	.code
	.bank 7
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "03B"
	.endif

        .code
        .bank 7
        .org $BFF0

RESET_MMC3:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

