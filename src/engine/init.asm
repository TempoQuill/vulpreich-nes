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
.incbin "src/raw-data/title.pal"

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
	JSR InitNameTable
	LDA #0
	STA zStringXOffset
	LDA #>BeginningText
	STA zAuxAddresses + 7
	LDA #<BeginningText
	STA zAuxAddresses + 6
	LDA #PRG_Start0
	STA zTextBank
	LDA #<(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress + 1
	JSR InstantPrint
	LDA #<IntroPals
	STA zPalPointer
	LDA #>IntroPals
	STA zPalPointer + 1
	; fade in palettes
	LDA iPals
	SSB PAL_FADE_F
	STA iPals
	SSB PAL_FADE_DIR_F ; wait $cf frames (3.45 seconds)
	JSR DelayFrame_s_
	; fade out palettes
	LDA iPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA iPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	JMP DelayFrame_s_

TitleScreen:
	LDY #MUSIC_NONE
	JSR PlayMusic
	JSR InitNameTable
	; set up nametable and text
	LDY #0
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR
	LDA LogoData, Y
	STA zAuxAddresses + 6
	INY
	LDA LogoData, Y
	STA zAuxAddresses + 7
	DEY
@Loop1:
	LDA (zAuxAddresses + 6), Y
	STA PPUDATA
	INY
	BNE @Loop1
	INC zAuxAddresses + 7
@Loop2:
	LDA (zAuxAddresses + 6), Y
	STA PPUDATA
	INY
	CPY #11 ; effective length of data is $10b
	BCC @Loop2
	LDA #>StarringText
	STA zAuxAddresses + 7
	LDA #<StarringText
	STA zAuxAddresses + 6
	LDA #<(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress + 1
	JSR InstantPrint
	LDA #>StartText
	STA zAuxAddresses + 7
	LDA #<StartText
	STA zAuxAddresses + 6
	LDA #<(NAMETABLE_MAP_0 + $2a0)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $2a0)
	STA cNametableAddress + 1
	JSR InstantPrint
	LDA #>ReleaseInfo
	STA zAuxAddresses + 7
	LDA #<ReleaseInfo
	STA zAuxAddresses + 6
	LDA #<(NAMETABLE_MAP_0 + $340)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $340)
	STA cNametableAddress + 1
	JSR InstantPrint
	LDY #MUSIC_TITLE
	JSR PlayMusic
	; fade in
	LDA iPals
	SSB PAL_FADE_F
	STA iPals
	SSB PAL_FADE_DIR_F
	JSR DelayFrame_s_
	RTS

LogoData:
.incbin "src/raw-data/logodata.bin"
