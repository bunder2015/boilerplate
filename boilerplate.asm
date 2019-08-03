;;;;;;;;;;
;
;  boilerplate - demo NES ROM of sorts
;
;;;;;;;;;;

DEBUG				; Comment this line to disable debugging

	.ifdef DEBUG
	.list			; Generate .lst file for debugging
	.endif

	; iNES header
	.inesprg 16		; 16x16k PRG ROM (256k)
	.ineschr 16		; 16x 8k CHR ROM (128k)
	.inesprs 1		; 1 x 8k PRG RAM
	.inesmap 1		; iNES mapper 1 (MMC1)
	.inesmir 0		; Horizontal mirroring (ignored, configured with MMC1)
	.inesfsm 0		; No four-screen mirroring
	.inesbat 1		; PRG RAM save battery
	.inesreg 0		; NTSC region
	.inesbus 0		; No bus conflicts

;;;;;;;;;;

	; NES CPU register constants
	.include "./include/registers.asm"
	.include "./include/mmc1-registers.asm"

;;;;;;;;;;

	; Zero-page memory $0000-00FF
	.zp

BGPT:
	.ds 1			; BG pattern table to display
JOY1IN:
	.ds 1			; Joypad 1 input
JOY2IN:
	.ds 1			; Joypad 2 input
MMCPRG:
	.ds 1			; MMC1 selectable PRG ROM bank
MMCRAM:
	.ds 1			; MMC1 PRG RAM enable flag
NMIEN:
	.ds 1			; NMI enable
NMIREADY:
	.ds 1			; Waiting for next frame
NT:
	.ds 1			; Nametable to display
PPUCADDR:
	.ds 2			; PPUCOPY destination address
PPUCINPUT:
	.ds 2			; PPUCOPY source address
PPUCLEN:
	.ds 2			; Length of PPUCOPY source data
SPRPT:
	.ds 1			; Sprite pattern table to display
WAITFRAMES:
	.ds 1			; Number of frames to wait

	; Debugging
	.ifdef DEBUG
DBGA:
	.ds 1			; A register
DBGPC:
	.ds 2			; Program counter
DBGPS:
	.ds 1			; Processor status
DBGSP:
	.ds 1			; Stack pointer
DBGX:
	.ds 1			; X register
DBGY:
	.ds 1			; Y register
PBTEMP1:
	.ds 1
PRINTB:
	.ds 1
	.endif

;;;;;;;;;;

	; Work memory $0200-07FF
	.bss

	; Reserve first 256b chunk of WRAM for PPU OAM
	.include "./include/bss-ppu-oam.asm"

;;;;;;;;;;

	; Cartridge memory $6000-7FFF
	.sram

TEMPVAR:
	.ds 1			; Added for testing

;;;;;;;;;;

	; PRG ROM
	.include "./banks/bank0.asm"
	.include "./banks/bank1.asm"
	.include "./banks/bank2.asm"
	.include "./banks/bank3.asm"
	.include "./banks/bank4.asm"
	.include "./banks/bank5.asm"
	.include "./banks/bank6.asm"
	.include "./banks/bank7.asm"
	.include "./banks/bank8.asm"
	.include "./banks/bank9.asm"
	.include "./banks/bank10.asm"
	.include "./banks/bank11.asm"
	.include "./banks/bank12.asm"
	.include "./banks/bank13.asm"
	.include "./banks/bank14.asm"
	.include "./banks/bank15.asm"

;;;;;;;;;;

	; CHR ROM
	.data
	.bank 32
	.org $0000

	.incbin "./banks/bank16.chr"

	; End of CHR ROM
