
	.db "NESM", $1a ; handshake
	.db $1 ; version
IFNDEF SFX
	.db $2 ; songs
ELSE
	.db $1d ; sfx
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
	.db PRG_Audio, PRG_Audio + 1, PRG_Music0, PRG_Music0 + 1, PRG_DPCM0, PRG_DPCM0 + 1, PRG_Home, PRG_Home + 7
	.dw $4e20 ; PAL, unused
	.db 0 ; this is an NTSC file
	.db 0 ; no extra chip (North American settings)
	.dsb 4, 0 ; proceeding data is program data
