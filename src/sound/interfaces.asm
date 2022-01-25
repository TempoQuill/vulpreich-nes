InitSound:
	PHP
	PHA
	PHX
	PHY
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	JSR _InitSound
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

UpdateSound:
	PHP
	PHA
	PHX
	PHY
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	JSR _UpdateSound
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

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

PlayMusic:
	PHP
	PHA
	PHX
	PHY
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	TYA ; does Y = 0?
	BEQ @NoMusic

	JSR _PlayMusic
	BNE @Continue ; always branches

@NoMusic:
	JSR _InitSound

@Continue:
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

PlayMusic2:
	PHP
	PHA
	PHX
	PHY
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY zBackupY
	LDY #0
	JSR _PlayMusic

	LDY zBackupY
	JSR _PlayMusic

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
	JSR CheckSFX
	BCC @Play

	LDA zCurrentSFX
	STY zBackupY
	CMP zBackupY
	BEQ @Play
	BCS @Done

@Play:
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY zCurrentSFX
	JSR _PlaySFX
	JSR UpdatePRG

@Done:
	PLY
	PLX
	PLA
	PLP
	RTS

WaitPlaySFX:
	JSR WaitSFX
	JMP PlaySFX

WaitSFX:
	LDA iChannelFlagSection1 + CHAN_8
	LSR A
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_9
	LSR A
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_A
	LSR A
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_B
	LSR A
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_C
	LSR A
	BCS WaitSFX
	RTS

SkipMusic:
	AND #$ff
	BNE @Update
	RTS
@Update:
	SBC #1
	JSR UpdateSound
	JMP SkipMusic

CheckSFX:
	LDA iChannelFlagSection1 + CHAN_8
	LSR A
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_9
	LSR A
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_A
	LSR A
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_B
	LSR A
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_C
	LSR A
	BCS @Done

@Done:
	RTS
