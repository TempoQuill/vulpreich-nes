IFNDEF NSF_FILE
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
ELSE
	.db "NESM", $1a ; handshake
	.db $1 ; version
	IFDEF NSF_SFX
		.db $1d ; sfx
	ELSE
		.db $2 ; songs
	ENDIF
	.db $1 ; starting song
	.dw LOAD
	.dw INIT
	.dw PLAY
	.db "VULPREICH"
	.dsb 23, 0
	.db "TEMPO QUILL"
	.dsb 21, 0
	.db "2022 Free to use when sales end"
	.db 0
	.dw $411a ; NTSC
	.db PRG_Audio, PRG_Audio + 1, PRG_Music0, PRG_Music0 + 1, PRG_DPCM0, PRG_DPCM0 + 1, PRG_Home, PRG_Home + 1
	.dw $4e20 ; PAL, unused
	.db 0 ; this is an NTSC file
	.db 0 ; no extra chip (North American settings)
	.dsb 4, 0 ; proceeding data is program data

ENDIF