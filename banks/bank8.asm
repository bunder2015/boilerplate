	.code
	.bank 16
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "08A"
	.endif

	.code
	.bank 17
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "08B"
	.endif

        .code
        .bank 17
        .org $BFF0

RESET_MMC8:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

