UpdateSound:
	PHP
	PHA
	PHX
	PHY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow
	LDA zMusicBank
	STA MMC5_PRGBankSwitch3
	STA zCurrentWindow + 1
	JSR StartProcessingSoundQueue
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

PlaySFX:
	PHP
	PHA
	PHX
	PHY
	TAX
	DEY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	LDA SoundEffectDestinations, Y
	STA zCurrentMusicPointer
	LDY #0
	STY zCurrentMusicPointer + 1
	TXA
	STA (zCurrentMusicPointer), Y
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

WaitPlaySFX:
	JSR WaitSFX
	JMP PlaySFX

WaitSFX:
	LDA zCurrentDPCMSFX
	ORA zCurrentNoiseSFX
	BNE WaitSFX
	RTS

SkipMusic:
	TAB
	BNE @Update
	RTS
@Update:
	SBC #1
	JSR UpdateSound
	JMP SkipMusic

CheckSFX:
	LDA zCurrentDPCMSFX
	ORA zCurrentNoiseSFX
	BNE @On
	CLC
	RTS

@On:
	SEC
	RTS
