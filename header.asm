; vulpreich header specs
; MAP: MMC5
; PRG: 1024K
; CHR: 1024K
; RAM: 128K + 2K internal + 1K Chip
; TOTAL: 2179K
	.db "NES", $1a ; NES + end of file command
	.db $40 ; 1 megabyte of PRG data
	.db $80 ; 1 megabyte of CHR data
	.db (MMC5 & $0f) * 16 | IGNORE_MIRRORING | BATTERY_RAM
	.db (MMC5 & $f0)      | NES_2_0
	.db 0, 0 ; unused
	.db $bb ; 128 kilobytes of PRG RAM
	.db 0
	.db 0 ; NTSC
	.db 0, 0, 0 ; unused
