; vulpreich header specs
; MAP: MMC5
; PRG: 1024K
; CHR: 1024K
; RAM: 128K + 2K internal
; TOTAL: 2178K
	.db $4e, $45, $53, $1a ; NES + end of file command
	.db $40 ; 1 megabyte of PRG data
	.db $80 ; 1 megabyte of CHR data
	.db MMC5 & %00001111 << 4 | IGNORE_MIRRORING | BATTERY_RAM
	.db MMC5 & %11110000      | NES_2_0
	.db 0, 0 ; unused
	.db $0b ; 128 kilobytes of PRG RAM
	.db 0
	.db 0 ; NTSC
	.db 0, 0, 0 ; unused
