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
	LDA #<TITLE_SCREEN_DURATION
	STA zTitleScreenTimer
	LDA #>TITLE_SCREEN_DURATION
	STA zTitleScreenTimer + 1
@Loop:
	DEC zTitleScreenTimer
	JSR RunTitleScreen
	LDA #1
	JSR DelayFrame_s_
	LDA iCurrentMusic
	BEQ @SongEnds
	LDA zTitleScreenTimer
	BNE @Loop
	DEC zTitleScreenTimer + 1
	BPL @Loop
	LDA #MUSIC_NONE
	STA zMusicQueue
@SongEnds:
	LDA #10
	STA zPalFadeSpeed
	STA zPalFade
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
	LDA #40
	JSR DelayFrame_s_
	JMP IntroSequence

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

	LDY #MUSIC_NONE
	STY zMusicQueue

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
	STA PPUADDR
	LDA #0
	STA PPUADDR

	; set fade speed
	LDX #4
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
	STA zPPUDataBufferPointer + 1

	LDA #1
	JSR DelayFrame_s_
	; music 1
	LDY #MUSIC_TITLE
	STY zMusicQueue

	; sure, we can get the game to show our stuff now
	LDA #PPU_OBJ | PPU_BG | PPU_OBJ_MASKLIFT | PPU_BG_MASKLIFT
	STA PPUMASK
	STA zPPUMaskMirror

	; fade in
	LDA zPals
	AND #COLOR_INDEX
	SSB PAL_FADE_F
	STA zPals
	LDA #$15
	JMP DelayFrame_s_

RunTitleScreen:
	JSR TryTitleScreenInput
	BEQ @NoInput
	DEX
	LDY @MusicQueue, X
	STY zMusicQueue
	LDY @InputSounds, X
	JSR PlaySFX
@NoInput:
	RTS

@MusicQueue:
	.db 0
	.db 0
	.db 0
	.db MUSIC_NONE

@InputSounds:
	.db SFX_EXCLAMATION_1
	.db SFX_SELECT_1
	.db SFX_CURSOR_1
	.db SFX_SELECT_1

; OUTPUT: X:
; 0 - Invalid
; 1 - A / Start
; 2 - Up / Down
; 3 - Select + A + B
TryTitleScreenInput:
	LDX #0
	LDY zInputBottleNeck
	BEQ @Ret
	INX
	CPY #1 << SELECT_BUTTON | 1 << A_BUTTON | 1 << B_BUTTON
	BEQ @Ret
	TYA
	INX
	AND #1 << A_BUTTON | 1 << START_BUTTON
	BNE @Ret
	INX
	TYA
	AND #1 << DOWN_BUTTON | 1 << UP_BUTTON
	BNE @Ret
	INX
	TYA
	AND #1 << B_BUTTON
	BNE @Ret
	LDX #0
@Ret:
	STX iTitleInputIndex
	TXA
	RTS
