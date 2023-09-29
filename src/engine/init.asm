MACRO time_stamp elapse
	.dw TITLE_SCREEN_DURATION - (elapse)
ENDM

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
	; initialize the lyrical offset
	LDA #0
	STA zLyricsOffset
	JSR InitPPULineClear
	LDA LyricalPointers
	STA zPPUDataBufferPointer
	LDA LyricalPointers + 1
	STA zPPUDataBufferPointer + 1
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
	LDA #2
	STA zPalFadeSpeed
	STA zPalFade
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
@CheckPal:
	LDY zPals + 15
	CPY #$f
	BEQ @RST
	LDA #1
	JSR DelayFrame_s_
	JMP @CheckPal
@RST:
	LDA zFilmStandardTimerEven
	JSR DelayFrame_s_
	JMP IntroSequence

InspiredScreen:
	; we're initializing the PPU
	; turn off NMI & PPU
	LDA zPPUCtrlMirror
	AND #$ff ^ PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL
	LDA #0
	STA PPUMASK
	STA zPPUMaskMirror

@VBlank:
	LDA PPUSTATUS
	BPL @VBlank
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
	LDX #5
	STX zPalFade
	STX zPalFadeSpeed

	LDX #15
@PalLoop:
	LDA IntroPals, X
	STA iCurrentPals, X
	DEX
	BNE @PalLoop

	LDA #<cPPUBuffer
	STA zPPUDataBufferPointer
	LDA #>cPPUBuffer
	STA zPPUDataBufferPointer + 1

	LDY #TitldNTInitData_END - TitldNTInitData

@StringLoop:
	LDA TitldNTInitData, Y
	STA iStringBuffer, Y
	DEY
	BPL @StringLoop
	; we can enable graphical updates now
	LDA zPPUCtrlMirror
	ORA #PPU_NMI | PPU_OBJECT_RESOLUTION
	STA zPPUCtrlMirror
	STA PPUCTRL

	LDA #<iStringBuffer
	STA zPPUDataBufferPointer
	LDA #>iStringBuffer
	STA zPPUDataBufferPointer + 1

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
	EOR #$c0 ; wait $4f frames (3.29 seconds)
	JSR DelayFrame_s_
	; fade out palettes
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
@WaitForFadeOut:
	LDA zPals
	BPL @Done
	LDA #1
	JSR DelayFrame_s_
	JMP @WaitForFadeOut
@Done:
	RTS

TitleScreen:
	; disable NMI for now
	LDA zPPUCtrlMirror
	AND #$ff ^ (PPU_NMI | PPU_OBJECT_RESOLUTION)
	STA zPPUCtrlMirror
	STA PPUCTRL
	; no NMI, nothing to show
	LDA #0
	STA PPUMASK
	STA zPPUMaskMirror
@VBlank:
	LDA PPUSTATUS
	BPL @VBlank
	; clear nametable and palettes
	JSR InitNameTable
	JSR InitPals

	JSR HideSprites

	LDA PPUSTATUS

	LDA #$3F
	STA PPUADDR
	LDA #0
	STA PPUADDR

	; set fade speed
	LDX #1
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
	; increase sprite size for faster logic
	LDA zPPUCtrlMirror
	ORA #PPU_NMI | PPU_OBJECT_RESOLUTION
	STA zPPUCtrlMirror
	STA PPUCTRL

	LDA #1
	JSR DelayFrame_s_

	LDA #<iStringBuffer
	STA zPPUDataBufferPointer
	LDA #>iStringBuffer
	STA zPPUDataBufferPointer + 1

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

	LDA #<TITLE_SCREEN_DURATION
	STA zTitleScreenTimer
	LDA #>TITLE_SCREEN_DURATION
	STA zTitleScreenTimer + 1
	; fade in
	LDA zPals
	AND #COLOR_INDEX
	SSB PAL_FADE_F
	STA zPals
@WaitForFadeIn:
	LDA #1
	JSR DelayFrame_s_
	LDA zTitleScreenTimer
	BNE @NoRollover
	DEC zTitleScreenTimer + 1
@NoRollover:
	DEC zTitleScreenTimer
	LDA zPals
	BMI @WaitForFadeIn
	RTS

RunTitleScreen:
	JSR RunLyrics
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

InitPPULineClear:
	; set up the string buffer
	LDY #LyricInitStartingData_END - LyricInitStartingData
@Loop:
	LDA LyricInitStartingData, Y
	STA iStringBuffer, Y
	DEY
	BPL @Loop
	LDA #0
	STA zStringXOffset
	LDA iStringBuffer + 1
	STA zStringXConst
	RTS

RunLyrics:
	LDY zLyricsOffset
	LDA zTitleScreenTimer + 1
	CMP @TimeMarks + 1, Y
	BNE @Ready
	LDA zTitleScreenTimer
	CMP @TimeMarks, Y
	BNE @Ready
	INY
	INY
	STY zLyricsOffset
	LDA LyricalPointers, Y
	STA zPPUDataBufferPointer
	LDA LyricalPointers + 1, Y
	STA zPPUDataBufferPointer + 1
	CMP #>iStringBuffer
	BEQ InitPPULineClear
	BNE @Exit
@Ready:
	LDA LyricalPointers, Y
	STA zPPUDataBufferPointer
	LDA LyricalPointers + 1, Y
	STA zPPUDataBufferPointer + 1
@Exit:
	LDY zStringXOffset
	INY
	TYA
	AND #$1f
	STA zStringXOffset
	CLC
	ADC zStringXConst
	STA iStringBuffer + 1
	RTS

@TimeMarks:
	time_stamp 30 * 24	; gradual clear!
	time_stamp 30 * 26	; "He may look like any pet,"
	time_stamp 30 * 27 + 23	; clear!
	time_stamp 30 * 28	; "like he's another number,"
	time_stamp 30 * 29 + 26	; clear!
	time_stamp 30 * 30	; "but e'er since his owner fled,"
	time_stamp 30 * 31 + 19	; clear!
	time_stamp 30 * 31 + 23	; "it's never been the same."
	time_stamp 30 * 33 + 15	; clear!
	time_stamp 30 * 34	; "For now he'll take a walk"
	time_stamp 30 * 35 + 23	; clear!
	time_stamp 30 * 36	; "and greet his furry neighbors,"
	time_stamp 30 * 37 + 26	; clear!
	time_stamp 30 * 38	; "because when he's running out,"
	time_stamp 30 * 39 + 19	; clear!
	time_stamp 30 * 39 + 23	; "they'll always know his name."
	time_stamp 30 * 41 + 23	; clear!
	time_stamp 30 * 42	; "It's Otis, June and him"
	time_stamp 30 * 43 + 19	; clear!
	time_stamp 30 * 43 + 23	; "just venturing together."
	time_stamp 30 * 45 + 19	; clear!
	time_stamp 30 * 46	; "Who knows the mischief that"
	time_stamp 30 * 47 + 19	; clear!
	time_stamp 30 * 47 + 23	; "they'll get into today."
	time_stamp 30 * 49	; gradual clear!
	time_stamp 30 * 50 + 23	; "Come with iggy"
	time_stamp 30 * 53	; "and his friends."
	time_stamp 30 * 54 + 19	; clear!
	time_stamp 30 * 54 + 26	; "You'll be fawning"
	time_stamp 30 * 56 + 26	; "until the very end."
	time_stamp 30 * 59	; gradual clear!
	.dw 0

LyricalPointers:
	.dw cPPUBuffer
	.dw iStringBuffer
	.dw Verse1Line1
	.dw LyricInstaClear
	.dw Verse1Line2
	.dw LyricInstaClear
	.dw Verse1Line3
	.dw LyricInstaClear
	.dw Verse1Line4
	.dw LyricInstaClear
	.dw Verse1Line5
	.dw LyricInstaClear
	.dw Verse1Line6
	.dw LyricInstaClear
	.dw Verse1Line7
	.dw LyricInstaClear
	.dw Verse1Line8
	.dw LyricInstaClear
	.dw PrechorusLine1
	.dw LyricInstaClear
	.dw PrechorusLine2
	.dw LyricInstaClear
	.dw PrechorusLine3
	.dw LyricInstaClear
	.dw PrechorusLine4
	.dw iStringBuffer
	.dw ChorusLine1
	.dw ChorusLine2
	.dw LyricInstaClear
	.dw ChorusLine3
	.dw ChorusLine4
	.dw iStringBuffer
	.dw LyricInstaClear
