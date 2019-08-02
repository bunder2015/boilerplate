	.code
	.bank 18
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "09A"
	.endif

	.code
	.bank 19
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "09B"
	.endif

        .code
        .bank 19
        .org $BFF0

RESET_MMC9:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

