InitSound:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	JSR _InitSound
	JSR UpdatePRG
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS

UpdateSound:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	JSR _UpdateSound
	JSR UpdatePRG
	PLA
	TAY
	PLA
	TAX
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
	TXA
	PHA
	TYA
	PHA
	LDA MMC5_PRGBankSwitch2
	STA zWindow1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY zBackupY
	LDY zBackupY
	BEQ @NoMusic

	JSR _PlayMusic
	JMP @Continue

@NoMusic:
	JSR _InitSound

@Continue:
	JSR UpdatePRG
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS

PlayMusic2:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
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
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS

PlaySFX:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
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
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTS

WaitPlaySFX:
	JSR WaitSFX
	JMP PlaySFX

WaitSFX:
	LDA iChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA iChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA iChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX
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
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA iChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA iChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @NoCarry

@Carry:
	SEC

@NoCarry:
	RTS
