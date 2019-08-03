	.code
	.bank 2
	.org $8000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "01A"
	.endif

	.code
	.bank 3
	.org $A000

	.ifdef DEBUG
	BRK			; Catch runaway execution
	.db "01B"
	.endif

        .code
        .bank 3
        .org $BFF0

RESET_MMC1:
        SEI
        LDX #$FF
        TXS
        STX MMC1CTRL
        JMP RESET		; This should never happen, but lets pad the bytes

        .dw NMI
        .dw RESET_MMC15
        .dw IRQ

