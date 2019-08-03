	.code
	.bank 10
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "05A"
	.endif

	.code
	.bank 11
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "05B"
	.endif

        .code
        .bank 11
        .org $BFF0

RESET_MMC5:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

