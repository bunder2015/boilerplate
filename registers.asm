;;;;;;;;;;
;
; registers.asm - a list of NES CPU register addresses
;
;;;;;;;;;;

PPUCTRL		.equ $2000
PPUMASK 	.equ $2001
PPUSTATUS	.equ $2002
OAMADDR		.equ $2003
OAMDATA		.equ $2004
PPUSCROLL	.equ $2005
PPUADDR		.equ $2006
PPUDATA		.equ $2007

SQ1VOL		.equ $4000
SQ1SWEEP	.equ $4001
SQ1LOW		.equ $4002
SQ1HIGH		.equ $4003
SQ2VOL		.equ $4004
SQ2SWEEP	.equ $4005
SQ2LOW		.equ $4006
SQ2HIGH		.equ $4007
TRILINEAR	.equ $4008
; $4009 is unused
TRILOW		.equ $400A
TRIHIGH		.equ $400B
NOISEVOL	.equ $400C
; $400D is unused
NOISELOW	.equ $400E
NOISEHIGH	.equ $400F
DMCFREQ		.equ $4010
DMCRAW		.equ $4011
DMCSTART	.equ $4012
DMCLENGTH	.equ $4013
OAMDMA		.equ $4014
SNDCHAN		.equ $4015
JOY1		.equ $4016	; Reads
STROBE		.equ $4016	; Writes
JOY2		.equ $4017	; Reads
APUFRAME	.equ $4017	; Writes
