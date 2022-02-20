.base $e080
LOAD:
INIT:
	PHA
	JSR _InitSound
	PLY
IFDEF NSF_SFX
	JMP _PlaySFX
ELSE
	INY
	JMP _PlayMusic
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
UpdatePRG_Loop:
	LDA iNSFBanks, X
	STA NSF_PRGBank0, X ; bank register
	DEX
	CPX #$ff
	BCC UpdatePRG_Loop
	RTS

.pad $f000, 0

	.dsb $1000, 0