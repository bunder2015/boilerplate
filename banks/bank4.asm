	.code
	.bank 8
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "04A"
	.endif

	.code
	.bank 9
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "04B"
	.endif

        .code
        .bank 9
        .org $BFF0

RESET_MMC4:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

