
	.db $4e, $45, $53, $4d, $1a ; handshake
	.db $1 ; version
	.db $2 ; songs
	.db $1 ; starting song
	.dw LOAD
	.dw INIT
	.dw PLAY
	ascii "VULPREICH"
	.dsb $17, $0
	ascii "TEMPO QUILL"
	.dsb $15, $0
	ascii "2022 Free use active postsale"
	.dsb $3, $0
	.dw $411a ; NTSC
	.db PRG_Audio, PRG_Audio + 1, PRG_Music0, PRG_Music0 + 1, PRG_DPCM0, PRG_DPCM0 + 1, PRG_Home + 7, PRG_Home
	.dw $4e20 ; PAL, unused

.base $e080
LOAD:
INIT:
	PHA
	JSR _InitSound
	PLA
	TAY
IFNDEF SFX
	INY
	JMP _PlayMusic
ELSE
	JMP _PlaySFX
ENDIF

PLAY:
	JMP _UpdateSound

_LoadMusicByte:
	STX zBackupX
	STY zBackupY
	LDY zBackupX
	LDA iChannelAddress + 16, X
	STA zAuxAddresses + 1
	JSR GetWindowIndex
	LDA iChannelBank, Y
	JSR StoreIndexedBank
	LDA iChannelAddress, Y
	STA zAuxAddresses
	LDY #0
	LDA (zAuxAddresses), Y
	STA zCurrentMusicByte
	JSR UpdatePRG ; restore old bank
	LDX zBackupX
	RTS

GetWindowIndex:
; input -  A - $80-$df
; output - X - PRG window X
	AND #$70
	LSR A
	LSR A
	LSR A
	TAX
	RTS

StoreIndexedBank:
	STA iNSFBanks, X
	INX
	ADC #1
	STA iNSFBanks, X
	RTS

UpdatePRG:
	LDX #5
@Loop:
	LDA iNSFBanks, X
	STA $5ff8, X ; bank register
	DEX
	CPX #$ff
	BCC @loop
	RTS
