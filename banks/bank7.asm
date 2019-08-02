	.code
	.bank 14
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "07A"
	.endif

	.code
	.bank 15
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "07B"
	.endif

        .code
        .bank 15
        .org $BFF0

RESET_MMC7:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

