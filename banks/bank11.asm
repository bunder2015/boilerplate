	.code
	.bank 22
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "11A"
	.endif

	.code
	.bank 23
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "11B"
	.endif

        .code
        .bank 23
        .org $BFF0

RESET_MMC11:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

