TryLoadSaveData:
	LDA #0
	STA zSaveFileExists
	JSR CheckPrimarySaveFile
	BEQ @backup
	RTS

@backup:
	JSR CheckBackupSaveFile
	LDA zSaveFileExists
	BEQ @corrupt
	LDA #RAM_BackupPlayFile
	STA zRAMBank
	STA MMC5_PRGBankSwitch1
	RTS

@corrupt:
	RTS

CheckPrimarySaveFile:
	LDA #RAM_PrimaryPlayFile
	STA zRAMBank
	STA MMC5_PRGBankSwitch1
	LDA #SAVE_CHECK_VALUE_1
	CMP sCheckValue1
	BNE @nope
	LDA #SAVE_CHECK_VALUE_2
	CMP sCheckValue2
	BNE @nope
	INC zSaveFileExists
@nope:
	RTS

CheckBackupSaveFile:
	LDA #RAM_BackupPlayFile
	STA zRAMBank
	STA MMC5_PRGBankSwitch1
	LDA #SAVE_CHECK_VALUE_1
	CMP sBackupCheckValue1
	BNE @nope
	LDA #SAVE_CHECK_VALUE_2
	CMP sBackupCheckValue2
	BNE @nope
	INC zSaveFileExists
@nope:
	RTS

GameInit:
	JSR ClearWindowData
	JSR TryLoadSaveData
	JMP IntroSequence

IntroPals:
.incbin "src/chr/title.pal"

IntroSequence:
	JSR InspiredScreen
	JSR TitleScreen
	LDA zPPUCtrlMirror
	RSB PPU_OBJECT_RESOLUTION ; 8x8
	STA zPPUCtrlMirror
	STA PPUCTRL
	LDA zTitleScreenOption
	CMP #NUM_TITLESCREENOPTION
	BCC @Begin
	LDA #TITLESCREENOPTION_MAIN_MENU
@Begin:
	ASL A
	TAY
	LDA @DW, Y
	STA zIntroPointer
	INY
	LDA @DW, Y
	STA zIntroPointer + 1
	JMP (zIntroPointer)

@DW
	.dw IntroSequence
	.dw IntroSequence
	.dw IntroSequence

InspiredScreen:
	LDA #0
	STA zStringXOffset
	LDA #>BeginningText
	STA zAuxAddresses + 7
	LDA #<BeginningText
	STA zAuxAddresses + 6
	LDA #PRG_Start0
	STA zTextBank
	JSR InstantPrint
	LDA #<IntroPals
	STA zPalPointer
	LDA #>IntroPals
	STA zPalPointer + 1
	LDA iPals
	SSB PAL_FADE_F
	STA iPals
	SSB PAL_FADE_DIR_F
	JSR DelayFrame_s_
	LDA iPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA iPals
	JMP DelayFrame_s_

TitleScreen:
	LDY #MUSIC_TITLE
	JSR PlayMusic
	RTS
