	.code
	.bank 12
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "06A"
	.endif

	.code
	.bank 13
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "06B"
	.endif

        .code
        .bank 13
        .org $BFF0

RESET_MMC6:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

