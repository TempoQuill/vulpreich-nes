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
	LDA #PPU_OBJ | PPU_BG | PPU_OBJ_MASKLIFT | PPU_BG_MASKLIFT
	STA PPUMASK
	STA zPPUMaskMirror
	LDA #1
	JSR DelayFrame_s_
@Loop:
	JSR RunTitleScreen
	BCS @Loop
	LDA zPPUCtrlMirror
	AND #$ff ^ PPU_OBJECT_RESOLUTION ; 8x8
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
	; we're initializing the PPU
	; turn off NMI
	LDA zPPUCtrlMirror
	AND #$ff ^ PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL

	JSR InitNameTable
	JSR InitPals

	JSR HideSprites

	LDA PPUSTATUS

	LDA #$3F
	STA PPUADDR
	LDA #0
	STA PPUADDR

	; store the palette data
	LDX #15
	STX zPalFade
	STX zPalFadeSpeed
@PalLoop:
	LDA IntroPals, X
	STA iCurrentPals, X
	DEX
	BNE @PalLoop

	LDA #<cPPUBuffer
	STA zPPUDataBufferPointer
	LDA #>cPPUBuffer
	STA zPPUDataBufferPointer + 1

	; we can enable graphical updates now
	LDA zPPUCtrlMirror
	ORA #PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL

	LDA #1
	JSR DelayFrame_s_

	LDA #<BeginningText
	STA zPPUDataBufferPointer
	LDA #>BeginningText
	STA zPPUDataBufferPointer + 1

	; sure, we can get the game to show our stuff now
	LDA #PPU_OBJ | PPU_BG | PPU_OBJ_MASKLIFT | PPU_BG_MASKLIFT
	STA PPUMASK
	STA zPPUMaskMirror
	; fade in palettes
	LDA zPals
	SSB PAL_FADE_F
	STA zPals
	SSB PAL_FADE_DIR_F ; wait $cf frames (3.45 seconds)
	JSR DelayFrame_s_
	; fade out palettes
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	JMP DelayFrame_s_

TitleScreen:
	LDA #1
	JSR DelayFrame_s_
	; disable NMI for now
	LDA zPPUCtrlMirror
	AND #$ff ^ PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL
	; no NMI, nothing to show
	LDA #0
	STA PPUMASK
	STA zPPUMaskMirror
	; clear nametable and palettes
	JSR InitNameTable
	JSR InitPals

	LDA PPUSTATUS

	LDA #$3F
	LDX #0
	STA PPUADDR
	STX PPUADDR

	; set fade speed
	INX
	STX zPalFade
	STX zPalFadeSpeed

	LDX #15
@PalLoop:
	LDA IntroPals, X
	STA iCurrentPals, X
	DEX
	BPL @PalLoop
	; set up nametable and text
	LDA #<cPPUBuffer
	STA zPPUDataBufferPointer
	LDA #>cPPUBuffer
	STA zPPUDataBufferPointer + 1

	; we can enable graphical updates now
	LDA zPPUCtrlMirror
	ORA #PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL

	LDA #1
	JSR DelayFrame_s_

	LDA #<TitleScreenLayout
	STA zPPUDataBufferPointer
	LDA #>TitleScreenLayout
	STA zPPUDataBufferPointer

	LDA #1
	JSR DelayFrame_s_
	; music 1
	LDY #MUSIC_NONE
	JSR PlayMusic
	LDY #MUSIC_TITLE
	JSR PlayMusic

	; sure, we can get the game to show our stuff now
	LDA #PPU_OBJ | PPU_BG | PPU_OBJ_MASKLIFT | PPU_BG_MASKLIFT
	STA PPUMASK
	STA zPPUMaskMirror

	; fade in
	LDA zPals
	AND #COLOR_INDEX
	SSB PAL_FADE_F
	STA zPals
	LDA #6
	JSR DelayFrame_s_

RunTitleScreen:
	LDA zJumpTableIndex
	BMI @Done
	ASL A
	TAY
	LDA @DW, Y
	STA zAuxAddresses + 2
	INY
	LDA @DW, Y
	STA zAuxAddresses + 3
	JMP (zAuxAddresses + 2)
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
	SEC
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
	LDA #1
	JSR DelayFrame_s_
	SEC
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
	TSB START_BUTTON
	BNE @CheckSelect
@Normal:
	LDA #TITLESCREENOPTION_MAIN_MENU
	STA zTitleScreenOption
	JSR ClearOAM
	; music 0
	LDY #MUSIC_NONE
	JSR PlayMusic
	; sfx 6
	LDY #SFX_SELECT_1
	JSR PlaySFX
	; fade out palettes
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	CLC
	JMP DelayFrame_s_

@CheckSelect:
	LDA zInputBottleNeck
	AND #1 << SELECT_BUTTON
	BEQ @Normal
	LDA #TITLESCREENOPTION_DELETE_SAVE_FILE
	STA zTitleScreenOption
	CLC
	RTS

@Press_B:
	; music 0
	LDY #MUSIC_NONE
	JSR PlayMusic
	JSR ClearOAM
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
	RSB PAL_FADE_DIR_F ; wait $8f frames (2.38 seconds)
	JSR DelayFrame_s_
	CLC
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
