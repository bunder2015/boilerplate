	.code
	.bank 24
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "12A"
	.endif

	.code
	.bank 25
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "12B"
	.endif

        .code
        .bank 25
        .org $BFF0

RESET_MMC12:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

