	.code
	.bank 20
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "10A"
	.endif

	.code
	.bank 21
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "10B"
	.endif

        .code
        .bank 21
        .org $BFF0

RESET_MMC10:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

