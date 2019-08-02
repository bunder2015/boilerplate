	.code
	.bank 4
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "02A"
	.endif

	.code
	.bank 5
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "02B"
	.endif

        .code
        .bank 5
        .org $BFF0

RESET_MMC2:
        SEI
        LDX #$FF
        TXS
        STX $8000
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

