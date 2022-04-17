InitSound:
	PHP
	PHA
	PHX
	PHY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow
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
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow
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
	LDA zAuxAddresses + 1
	JSR GetWindowIndex
	LDA zMusicBank
	STA MMC5_PRGBankSwitch2, X
	STA zCurrentWindow, X
	LDY #0
	LDA (zAuxAddresses), Y
	STA zCurrentMusicByte
	LDA zWindow1, X
	STA MMC5_PRGBankSwitch2, X
	LDX zBackupX
	RTS

PlayMusic:
	PHP
	PHA
	PHX
	PHY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow

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
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow

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
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow

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
	LSR A ; SOUND_CHANNEL_ON
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_9
	LSR A ; SOUND_CHANNEL_ON
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_A
	LSR A ; SOUND_CHANNEL_ON
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_B
	LSR A ; SOUND_CHANNEL_ON
	BCS WaitSFX

	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON
	BCS WaitSFX
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
	LDA iChannelFlagSection1 + CHAN_8
	LSR A ; SOUND_CHANNEL_ON
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_9
	LSR A ; SOUND_CHANNEL_ON
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_A
	LSR A ; SOUND_CHANNEL_ON
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_B
	LSR A ; SOUND_CHANNEL_ON
	BCS @Done

	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON
	BCS @Done

@Done:
	RTS
