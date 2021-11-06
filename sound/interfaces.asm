InitSound:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	LDA #>_InitSound
	AND #$60 ; A will always be zero
	LDA MMC5_PRGBankSwitch2
	STA Window1
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
	LDA #>_UpdateSound
	AND #$60
	LDA MMC5_PRGBankSwitch2
	STA Window1
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
	STX BackupX
	STY BackupY
	LDY BackupX
	LDA ChannelAddress + 16, X
	STA AuxAddresses + 1
	LDX #0
	AND #$60
	BEQ @Switch
@Loop:
	INX
	SBC #$20
	BNE @Loop
@Switch:
	LDA MMC5_PRGBankSwitch2, X
	STA Window1, X ; preserve old bank
	LDA ChannelBank, Y
	STA MMC5_PRGBankSwitch2, X
	LDA ChannelAddress, Y
	STA AuxAddresses
	LDA (AuxAddresses)
	STA CurrentMusicByte
	JSR UpdatePRG ; restore old bank
	LDX BackupX
	RTS

PlayMusic:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	LDA #>_PlayMusic
	AND #$60
	LDA MMC5_PRGBankSwitch2
	STA Window1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY BackupY
	LDY BackupY
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
	LDA #>_PlayMusic
	AND #$60
	LDA MMC5_PRGBankSwitch2
	STA Window1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY BackupY
	LDY #0
	JSR _PlayMusic

	LDY BackupY
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

	LDA CurrentSFX
	STY BackupY
	CMP BackupY
	BEQ @Play
	BCS @Done

@Play:
	LDA #>_PlaySFX
	AND #$60
	LDA MMC5_PRGBankSwitch2
	STA Window1
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2

	STY CurrentSFX
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
	LDA ChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA ChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA ChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE WaitSFX

	LDA ChannelFlagSection1 + CHAN_C
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
	LDA ChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA ChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA ChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE @Carry

	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @NoCarry

@Carry:
	SEC

@NoCarry:
	RTS
