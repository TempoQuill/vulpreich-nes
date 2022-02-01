
	.db $4e, $45, $53, $4d, $1a ; handshake
	.db $1 ; version
	.db $2 ; songs
	.db $1 ; starting song
	.dw LOAD
	.dw INIT
	.dw PLAY
	.db "VULPREICH"
	.dsb $17, $0
	.db "TEMPO QUILL"
	.dsb $15, $0
	.db "2022 Free use active postsale"
	.dsb $3, $0
	.dw $411a ; NTSC
	.db PRG_Audio, PRG_Audio + 1, PRG_Music0, PRG_Music0 + 1, PRG_DPCM0, PRG_DPCM0 + 1, PRG_Home + 7, PRG_Home
	.dw $4e20 ; PAL, unused
	.db 0 ; this is an NTSC file
	.db 0 ; no extra chip (North American settings)
	.dsb 4, 0 ; proceeding data is program data
