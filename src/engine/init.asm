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
@Loop:
	JSR RunTitleScreen
	BCS @Loop
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
	LDX #0
	JSR StoreText
	; store the palette address
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
	; disable video for now
	LDA #NMI_SOUND
	STA zNMIState
	LDY #MUSIC_NONE
	JSR PlayMusic
	JSR InitNameTable
	; set up nametable and text
	LDY #0
	LDA #>NAMETABLE_MAP_0
	STA zCurrentTileNametableAddress
	LDA #<NAMETABLE_MAP_0
	STA zCurrentTileNametableAddress + 1
	LDA #<LogoData
	STA zCurrentTileAddress
	LDA #>LogoData
	STA zCurrentTileAddress
	LDA #11
	STA zTileOffset
	LDA #1
	STA zTileOffset + 1
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
	LDX #0
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
	LDX #2
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
	LDX #4
	JSR StoreText
	LDY #MUSIC_TITLE
	JSR PlayMusic
	; enable everything now
	LDA #NMI_NORMAL
	STA zNMIState
	; fade in
	LDA iPals
	SSB PAL_FADE_F
	STA iPals
	RTS

RunTitleScreen:
	LDA zJumpTableIndex
	BMI @Done
	ASL A
	STA zTableOffset
	LDA zTableOffset + 1
	ADC #0
	STA zTableOffset + 1
	LDY #<@DW
	LDA #>@DW
	JMP JumpTable
@Done:
	SEC
	RTS

@DW:
	.dw TitleScreenTimer
	.dw TitleScreenMain
	.dw TitleScreenEnd

TitleScreenTimer:
	; next scene
	INC zJumpTableIndex
	; set timer for $1000 frames (about 1:08)
	LDA #0
	STA zTitleScreenTimer
	LDA #$10
	STA zTitleScreenTimer + 1
	CLC
	RTS

TitleScreenMain:
	; has our timer concluded?
	LDA zTitleScreenTimer
	ORA zTitleScreenTimer + 1
	BEQ @End
	; it's still a non-zero
	LDA zTitleScreenTimer
	BNE @Skip
	DEC zTitleScreenTimer + 1
@Skip:
	DEC zTitleScreenTimer
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
	CLC
	RTS

@End:
	INC zJumpTableIndex
	STA zMusicID
	INC zTitleScreenTimer
	CLC
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
	SEC
	JMP DelayFrame_s_

@CheckSelect:
	LDA zInputBottleNeck
	AND #1 << SELECT_BUTTON
	BEQ @Normal
	LDA #TITLESCREENOPTION_DELETE_SAVE_FILE
	STA zTitleScreenOption
	SEC
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
	SEC
	RTS

@Press_Up_Down:
	LDY #SFX_CURSOR_1
	JSR PlaySFX
	CLC
	RTS

TitleScreenEnd:
; Wait until the music is queued
	INC zTitleScreenTimer
	LDA iChannelID
	BEQ @Continue
	CLC
	RTS

@Continue:
	LDA #TITLESCREENOPTION_RESTART
	STA zTitleScreenSelectedOption
	; return to the inspired screen
	LDA zJumpTableIndex
	SSB 7
	STA zJumpTableIndex
	CLC
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
	ASL A
	BCS @A_Start
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
