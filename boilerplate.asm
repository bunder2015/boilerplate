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

	; For use with ggsound - constants
	.include "./include/ggsound/ggsound_nesasm/ggsound.inc"

;;;;;;;;;;

	; Zero-page memory $0000-00FF
	.zp

BGEN:
	.ds 1			; BG render enable
BGNOCROP:
	.ds 1			; BG leftmost 8px crop disable
BGPT:
	.ds 1			; BG pattern table to display
CEMPHB:
	.ds 1			; PPU blue colour emphasis
CEMPHG:
	.ds 1			; PPU green colour emphasis
CEMPHR:
	.ds 1			; PPU red colour emphasis
COLOUREN:
	.ds 1			; Colour enable
CPUCADDR:
	.ds 2			; CPUCOPY destination address
CPUCINPUT:
	.ds 2			; CPUCOPY source address
CPUCLEN:
	.ds 2			; Length of CPUCOPY source data
JOY1IN:
	.ds 1			; Joypad 1 input
JOY2IN:
	.ds 1			; Joypad 2 input
MMCCHR0:
	.ds 1			; MMC1 selectable CHR ROM bank 0
MMCCHR1:
	.ds 1			; MMC1 selectable CHR ROM bank 1
MMCCHRMODE:
	.ds 1			; MMC1 CHR bank mode
MMCMIRROR:
	.ds 1			; MMC1 nametable mirroring mode
MMCPRG:
	.ds 1			; MMC1 selectable PRG ROM bank
MMCPRGMODE:
	.ds 1			; MMC1 PRG bank mode
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
SCROLLX:
	.ds 1			; Scroll position X
SCROLLY:
	.ds 1			; Scroll position Y
SKIPSRAMTEST:
	.ds 1			; Skip PRG RAM test
SOUNDREADY:
	.ds 1			; Status of ggsound initialization
SPREN:
	.ds 1			; SPR render enable
SPRNOCROP:
	.ds 1			; SPR leftmost 8px crop disable
SPRPT:
	.ds 1			; Sprite pattern table to display
TEMP:
	.ds 1			; Temporary variable for UPDATEPPUCTRL/UPDATEPPUMASK/UPDATEMMC1CTRL/UPDATEMMC1PRG
TEMPADDR:
	.ds 2			; Temporary address variable
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
PBINPUT:
	.ds 2			; Input to PRINT1BYTE/PRINT2BYTES
PBTEMP:
	.ds 1			; Temporary variable for PRINT1BYTE/PRINT2BYTES
	.endif

	; For use with ggsound - zero page variables
	.include "./include/ggsound/ggsound_nesasm/ggsound_zp.inc"

;;;;;;;;;;

	; Work memory $0200-07FF
	.bss

	; Reserve first 256b chunk of WRAM for PPU OAM
	.include "./include/bss-ppu-oam.asm"

	; For use with ggsound - WRAM variables
	.include "./include/ggsound/ggsound_nesasm/ggsound_ram.inc"

MUSICEN:
	.ds 1			; Music toggle

;;;;;;;;;;

	; Cartridge memory $6000-7FFF
	.sram

SRAMHEADER:
	.ds 16			; SRAM header for verification
SRAMMUSIC:
	.ds 1			; Music toggle

	.org $7FF0
SRAMFOOTER:
	.ds 16			; SRAM footer for verification

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
