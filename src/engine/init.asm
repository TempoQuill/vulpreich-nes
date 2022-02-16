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
	LDA #1
	JSR DelayFrame_s_
	JSR RunTitleScreen
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
	STA zAuxAddresses + 6
	INY
	LDA @DW, Y
	STA zAuxAddresses + 7
	JMP (zAuxAddresses + 6)

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
	; store the palette address
	JSR StoreText
	LDA #<IntroPals
	STA zPalPointer
	LDA #>IntroPals
	STA zPalPointer + 1
	; we can enable graphical updates now
	; inputs are barred though for the time being
	LDA #NMI_LIQUID
	STA zNMIState
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
	RSB PAL_FADE_DIR_F ; wait $cf frames (2.38 seconds)
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
	LDA #PRG_Start0
	STA zTextBank
	LDA #<(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $140)
	STA cNametableAddress + 1
	JSR StoreText
	LDA #>StartText
	STA zAuxAddresses + 7
	LDA #<StartText
	STA zAuxAddresses + 6
	LDA #PRG_Start0
	STA zTextBank
	LDA #<(NAMETABLE_MAP_0 + $2a0)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $2a0)
	STA cNametableAddress + 1
	JSR StoreText
	LDA #>ReleaseInfo
	STA zAuxAddresses + 7
	LDA #<ReleaseInfo
	STA zAuxAddresses + 6
	LDA #PRG_Start0
	STA zTextBank
	LDA #<(NAMETABLE_MAP_0 + $340)
	STA cNametableAddress
	LDA #>(NAMETABLE_MAP_0 + $340)
	STA cNametableAddress + 1
	JSR StoreText
	LDY #MUSIC_TITLE
	JSR PlayMusic
	; fade in
	LDA iPals
	SSB PAL_FADE_F
	STA iPals
	RTS

RunTitleScreen:
	; check for controller 1 input
	JSR Intro_CheckInput
	BCC @Quit
	LDA @DW, Y
	INY
	STA zAuxAddresses + 6
	LDA @DW, Y
	STA zAuxAddresses + 7
	JMP (zAuxAddresses + 6)
@Quit:
	RTS

@DW:
	.dw @Press_A_Start
	.dw @Press_B
	.dw @Press_Up_Down

@Press_A_Start:
	LDA zInputBottleNeck
	AND #1 << START_BUTTON
	BNE @CheckSelect
@Normal:
	LDA #TITLESCREENOPTION_MAIN_MENU
	STA zTitleScreenOption
	JSR ClearOAM
	LDY #MUSIC_NONE
	JSR PlayMusic
	LDY #SFX_SELECT_1
	JSR PlaySFX
	; fade out palettes
	LDA iPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA iPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	JMP DelayFrame_s_

@CheckSelect:
	LDA zInputBottleNeck
	AND #1 << SELECT_BUTTON
	BEQ @Normal
	LDA #TITLESCREENOPTION_DELETE_SAVE_FILE
	STA zTitleScreenOption
	RTS

@Press_B:
	LDY #MUSIC_NONE
	JSR PlayMusic
	JSR ClearOAM
	LDA iPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA iPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	JSR DelayFrame_s_
	RTS

@Press_Up_Down:
	LDY #SFX_CURSOR_1
	JSR PlaySFX
	RTS

Intro_CheckInput:
; c = necesary input (a, b, start, up, down)
; y = pointer offset (0 for a/start, 2 for b, 4 for up/down)
	LDY #0
	LDA zInputBottleNeck
	ASL A
	BCS @A_Start
	ASL A
	BCS @B
	ASL A
	BCS @A_Start
	ASL A
	ASL A
	BCS @Up_Down
	ASL A
	BCS @Up_Down
	RTS
@Up_Down:
	INY
	INY
@B:
	INY
	INY
@A_Start:
	RTS

LogoData:
.incbin "src/raw-data/logodata.bin"
