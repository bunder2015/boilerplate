	.code
	.bank 28
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "14A"
	.endif

	.code
	.bank 29
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "14B"
	.endif

        .code
        .bank 29
        .org $BFF0

RESET_MMC14:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

