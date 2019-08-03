	.code
	.bank 26
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "13A"
	.endif

	.code
	.bank 27
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "13B"
	.endif

        .code
        .bank 27
        .org $BFF0

RESET_MMC13:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

