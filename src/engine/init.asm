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
	; initialize sprite animations
	JSR StartInitializingSprites
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

	LDX #$1f
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
	ORA #PPU_NMI | PPU_OBJ_RES
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
	LDA #PPU_OBJ | PPU_BG
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
	AND #$ff ^ (PPU_NMI | PPU_OBJ_RES)
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

	LDX #$1f
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
	ORA #PPU_NMI | PPU_OBJ_RES
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
	LDA #PPU_OBJ | PPU_BG
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
	JSR InitNextSprite
	JSR RunAnimations
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
	CMP LyricsTimeStamps + 1, Y
	BNE @Ready
	LDA zTitleScreenTimer
	CMP LyricsTimeStamps, Y
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

RunAnimations:
	; monitor film timer (odd) to run on 2's
	LDA zFilmStandardTimerOdd
	BPL @Quit
	; run sprite 1 (Iggy, Otis)
	JSR RunObject1
	; run sprite 2 (June, a crow)
	JSR RunObject2
	JSR RunSoundQueues
@Quit:
	RTS

LocalObject2Eject:
	RTS

RunObject2:
	; did we reach our starting point yet?
	LDA zTitleScreenTimer + 1
	CMP zTitleObj2StartingPoint + 1
	BEQ @Low
	BCC @AlreadyPassed
	BCS LocalObject2Eject
@Low:
	LDA zTitleScreenTimer
	CMP zTitleObj2StartingPoint
	BCS LocalObject2Eject
@AlreadyPassed:
	; decrement the title object timer
	; reset the timer to 4 when branching
	DEC zTitleObj2Timer
	BMI @Reset
	; nab the animation offset
	LDY zTitleObj2Timer
@Logic:
	; apply movement and deduce direction
	JSR ApplySprite2Movement
	; set up the logic
	LDA (zTitleObj2IndexPointer), Y
	STA zTitleObj2PointerIndex
	TAY
	LDA (zTitleObj2PointerAddresses), Y
	STA zTitleObj2FramePointer
	LDA (zTitleObj2PointerAddresses + 2), Y
	STA zTitleObj2FramePointer + 1
	LDY zTitleObj2Resolution
	DEY

@MainLoop1:
	; copy data from current resolution to zero
	JSR CopySprite2DataDescending
	BPL @MainLoop1
	JSR IsAtEdge_TitleOBJ2
	BCS @On
	RTS

@Reset:
	; loop the pointer every 4 frames
	LDY zTitleObjLoopPoint2
	STY zTitleObj2Timer
	DEC zTitleObj2Timer
	DEY
	BNE @Logic ; always branches

@On:
	LDA zTitleObj2XCoord
	AND #$18
	SBC zTitleObj2Resolution
	EOR #$ff
	TAY
	INY
	BNE @NonZero
	LDA #$ff
	BIT zTitleObj2ScreenEdgeFlags
	BMI @Quit
@NonZero:
	LDA #$ff
	BIT zTitleObj2ScreenEdgeFlags
	BMI @Entering
	CLC
	LDA zTitleObj2XCoord
	ADC zTitleObj2Resolution
	BCS @Exiting
	JMP ClearSprite2
@Exiting:
	LDA #$ff
	BIT zTitleObj2ScreenEdgeFlags
	BVS @ToTheLeft
@FromTheRight:
	CPY zTitleObj2Resolution
	BCS @Quit
	JMP Sprite2ExitMask
@Entering:
	BVS @FromTheRight
@ToTheLeft:
	JMP Sprite2EntranceMask
@Quit:
	RTS

LocalObject1Eject:
	RTS

RunObject1:
	; did we reach our starting point yet?
	LDA zTitleScreenTimer + 1
	CMP zTitleObj1StartingPoint + 1
	BEQ @Low
	BCC @AlreadyPassed
	BCS LocalObject1Eject
@Low:
	LDA zTitleScreenTimer
	CMP zTitleObj1StartingPoint
	BCS LocalObject1Eject
@AlreadyPassed:
	; decrement the title object timer
	; reset the timer to 4 when branching
	DEC zTitleObj1Timer
	BMI @Reset
	; nab the animation offset
	LDY zTitleObj1Timer
@Logic:
	; apply movement and deduce direction
	JSR ApplySprite1Movement
	; set up the logic
	LDA (zTitleObj1IndexPointer), Y
	STA zTitleObj1PointerIndex
	TAY
	LDA (zTitleObj1PointerAddresses), Y
	STA zTitleObj1FramePointer
	LDA (zTitleObj1PointerAddresses + 2), Y
	STA zTitleObj1FramePointer + 1
	LDY zTitleObj1Resolution
	DEY

@MainLoop1:
	; copy data from current resolution to zero
	JSR CopySprite1DataDescending
	BPL @MainLoop1
	JSR IsAtEdge_TitleOBJ1
	BCS @On
	RTS

@Reset:
	; loop the pointer every 4 frames
	LDY zTitleObjLoopPoint1
	STY zTitleObj1Timer
	DEC zTitleObj1Timer
	DEY
	BNE @Logic ; always branches

@On:
	LDA zTitleObj1XCoord
	AND #$18
	SBC zTitleObj1Resolution
	EOR #$ff
	TAY
	INY
	BNE @NonZero
	LDA #$ff
	BIT zTitleObj1ScreenEdgeFlags
	BMI @Quit
@NonZero:
	LDA #$ff
	BIT zTitleObj1ScreenEdgeFlags
	BMI @Entering
	CLC
	LDA zTitleObj1XCoord
	ADC zTitleObj1Resolution
	BCS @Exiting
	JMP ClearSprite1
@Exiting:
	LDA #$ff
	BIT zTitleObj1ScreenEdgeFlags
	BVS @ToTheLeft
@FromTheRight:
	CPY zTitleObj1Resolution
	BCS @Quit
	JMP Sprite1ExitMask
@Entering:
	BVS @FromTheRight
@ToTheLeft:
	JMP Sprite1EntranceMask
@Quit:
	RTS

IsAtEdge_TitleOBJ1:
; input:
; c = activity
; v = direction
; s = action
; output:
; c = 0 - off, not at edge yet | on, cleared the edge
; c = 1 - on,  still on edge   | off, entered the edge
	LDA zTitleObj1ScreenEdgeFlags
	LSR A
	BCC @Off
	AND #%00000001
	BNE @Clear
	LDA zTitleObj1XCoord
	CLC
	ADC zTitleObj1Resolution
	BCS @Eject
	LDA zTitleObj1ScreenEdgeFlags
	BPL @Done
	EOR #1 << ENTER_EXIT_ACT_F
	STA zTitleObj1ScreenEdgeFlags
	RTS

@Clear:
	LDA #0
	STA zTitleObj1ScreenEdgeFlags
	RTS

@Done:
	LDA #%00000011
	STA zTitleObj1ScreenEdgeFlags
	SEC
@Eject:
	RTS

@Off:
	LDA zTitleObj1XCoord
	CLC
	ADC zTitleObj1Resolution
	BCC @Eject
	LDA zTitleObj1ScreenEdgeFlags
	EOR #1 << ENTER_EXIT_ACT_F | 1 << ENTER_EXIT_F
	STA zTitleObj1ScreenEdgeFlags
	RTS

IsAtEdge_TitleOBJ2:
	LDA zTitleObj2ScreenEdgeFlags
	LSR A
	BCC @Off
	AND #%00000001
	BNE @Clear
	LDA zTitleObj2XCoord
	CLC
	ADC zTitleObj2Resolution
	BCS @Eject
	LDA zTitleObj2ScreenEdgeFlags
	BPL @Done
	EOR #1 << ENTER_EXIT_ACT_F
	STA zTitleObj2ScreenEdgeFlags
	RTS

@Clear:
	LDA #0
	STA zTitleObj2ScreenEdgeFlags
	RTS

@Done:
	LDA #%00000011
	STA zTitleObj2ScreenEdgeFlags
	SEC
@Eject:
	RTS

@Off:
	LDA zTitleObj2XCoord
	CLC
	ADC zTitleObj2Resolution
	BCC @Eject
	LDA zTitleObj2ScreenEdgeFlags
	EOR #1 << ENTER_EXIT_ACT_F | 1 << ENTER_EXIT_F
	STA zTitleObj2ScreenEdgeFlags
	RTS

Sprite1EntranceMask:
ClearObj1:
	LDA #0
	DEY
	STA (zTitleObj1OAMPointer), Y
	DEY
	STA (zTitleObj1OAMPointer), Y
	DEY
	STA (zTitleObj1OAMPointer), Y
	LDA #$F8
	DEY
	STA (zTitleObj1OAMPointer), Y
	BEQ @Done
	BPL Sprite1EntranceMask
@Done:
	RTS

Sprite1ExitMask:
	LDA #$F8
	STA (zTitleObj1OAMPointer), Y
	LDA #0
	INY
	STA (zTitleObj1OAMPointer), Y
	INY
	STA (zTitleObj1OAMPointer), Y
	INY
	STA (zTitleObj1OAMPointer), Y
	INY
	CPY zTitleObj1Resolution
	BCC Sprite1ExitMask
	RTS

ClearSprite1:
	INC zTitleObjFinished
	LDY zTitleObj1Resolution
	BNE ClearObj1

Sprite2EntranceMask:
ClearObj2:
	LDA #0
	DEY
	STA (zTitleObj2OAMPointer), Y
	DEY
	STA (zTitleObj2OAMPointer), Y
	DEY
	STA (zTitleObj2OAMPointer), Y
	LDA #$F8
	DEY
	STA (zTitleObj2OAMPointer), Y
	BEQ @Done
	BPL Sprite2EntranceMask
@Done:
	RTS

Sprite2ExitMask:
	LDA #$F8
	STA (zTitleObj2OAMPointer), Y
	LDA #0
	INY
	STA (zTitleObj2OAMPointer), Y
	INY
	STA (zTitleObj2OAMPointer), Y
	INY
	STA (zTitleObj2OAMPointer), Y
	INY
	CPY zTitleObj2Resolution
	BCC Sprite2ExitMask
	RTS

ClearSprite2:
	LDA #2
	ORA zTitleObjFinished
	STA zTitleObjFinished
	LDY zTitleObj2Resolution
	BNE ClearObj2

InitIggyAnimation:
	JSR SetUpCommonIggyPointers
	LDA #IggyFrames_IndexSequence_START - IggyFrames_IndexSequence
	STA zTitleObj1Timer
	LDA #>IggyFrames_IndexSequence
	STA zTitleObj1IndexPointer + 1
	LDA #<IggyFrames_IndexSequence
	STA zTitleObj1IndexPointer
	LDA #>IggyFrames_Movement
	STA zTitleObj1MovementPointer + 1
	LDA #<IggyFrames_Movement
	STA zTitleObj1MovementPointer
	LDA #>TITLE_SCREEN_IGGY_ENTRANCE_1 ; $07
	STA zTitleObj1StartingPoint + 1
	LDA #<TITLE_SCREEN_IGGY_ENTRANCE_1 ; $dc
	STA zTitleObj1StartingPoint
	JMP SpriteSetup_LargeLeft

InitIggy2Animation:
	JSR SetUpCommonIggyPointers
	LDA #IggyFrames_LeftRunningCycle_START - IggyFrames_LeftRunningCycle
	STA zTitleObj1Timer
	LDA #>IggyFrames_LeftRunningCycle
	STA zTitleObj1IndexPointer + 1
	LDA #<IggyFrames_LeftRunningCycle
	STA zTitleObj1IndexPointer
	LDA #>IggyFrames_LeftMovement
	STA zTitleObj1MovementPointer + 1
	LDA #<IggyFrames_LeftMovement
	STA zTitleObj1MovementPointer
	LDA #>TITLE_SCREEN_IGGY_ENTRANCE_2 ; $01
	STA zTitleObj1StartingPoint + 1
	LDA #<TITLE_SCREEN_IGGY_ENTRANCE_2 ; $fc
	STA zTitleObj1StartingPoint
	LDA #OAM_32_32_WIDTH
	STA zTitleObj1Resolution
	; entering from the right
	LDA #1 << ENTER_EXIT_ACT_F | 1 << ENTER_EXIT_F | 1 << ENTER_EXIT_DIR_F
	STA zTitleObj1ScreenEdgeFlags
	LDA #$FF
	JMP GenericSpriteSetup

InitCrowAnimation:
	LDA #<CrowFrames_pointersLO
	STA zTitleObj2PointerAddresses
	LDA #>CrowFrames_pointersLO
	STA zTitleObj2PointerAddresses + 1
	LDA #<CrowFrames_pointersHI
	STA zTitleObj2PointerAddresses + 2
	LDA #>CrowFrames_pointersHI
	STA zTitleObj2PointerAddresses + 3
	LDA #TITLE_CROW_OFFSET
	STA zTitleObj2OAMPointer
	LDA #$4d
	STA zTitleObj2YCoord
	LDA #4
	STA zTitleObjLoopPoint2
	LDA #CrowFrames_IndexSequence_START - CrowFrames_IndexSequence
	STA zTitleObj2Timer
	LDA #>CrowFrames_IndexSequence
	STA zTitleObj2IndexPointer + 1
	LDA #<CrowFrames_IndexSequence
	STA zTitleObj2IndexPointer
	LDA #>CrowFrames_Movement
	STA zTitleObj2MovementPointer + 1
	LDA #<CrowFrames_Movement
	STA zTitleObj2MovementPointer
	LDA #>TITLE_SCREEN_CROW_ENTRANCE_1 ; $08
	STA zTitleObj2StartingPoint + 1
	LDA #<TITLE_SCREEN_CROW_ENTRANCE_1 ; $14
	STA zTitleObj2StartingPoint
	LDA #OAM_24_32_WIDTH
	STA zTitleObj2Resolution
	; entering from the left
	; but movement should already take care of that
	LDA #1 << ENTER_EXIT_ACT_F | 1 << ENTER_EXIT_F
	STA zTitleObj2ScreenEdgeFlags
	LDA #$e9
	STA zTitleObj2XCoord
	LDA #0
	STA zTitleObj2PointerIndex
	STA zTitleObj2FramePointer
	STA zTitleObj2FramePointer + 1
	LDA #>iVirtualOAM
	STA zTitleObj2OAMPointer + 1
	RTS

InitCrow2Animation:
	RTS

InitJuneAnimation:
	RTS

InitOtisAnimation:
	LDA #<OtisFrames_pointersLO
	STA zTitleObj1PointerAddresses
	LDA #>OtisFrames_pointersLO
	STA zTitleObj1PointerAddresses + 1
	LDA #<OtisFrames_pointersHI
	STA zTitleObj1PointerAddresses + 2
	LDA #>OtisFrames_pointersHI
	STA zTitleObj1PointerAddresses + 3
	LDA #OtisFrames_IndexSequence_START - OtisFrames_IndexSequence
	STA zTitleObj1Timer
	LDA #>OtisFrames_IndexSequence
	STA zTitleObj1IndexPointer + 1
	LDA #<OtisFrames_IndexSequence
	STA zTitleObj1IndexPointer
	LDA #>OtisFrames_Movement
	STA zTitleObj1MovementPointer + 1
	LDA #<OtisFrames_Movement
	STA zTitleObj1MovementPointer
	LDA #>TITLE_SCREEN_OTIS_ENTRANCE_1 ; $07
	STA zTitleObj1StartingPoint + 1
	LDA #<TITLE_SCREEN_OTIS_ENTRANCE_1 ; $40
	STA zTitleObj1StartingPoint
	LDA #TITLE_OTIS_OFFSET
	STA zTitleObj1OAMPointer
	LDA #$67
	STA zTitleObj1YCoord
	LDA #6
	STA zTitleObjLoopPoint1

SpriteSetup_LargeLeft:
	LDA #OAM_32_32_WIDTH
	STA zTitleObj1Resolution

SpriteSetup_Left:
	; entering from the left
	; but movement should already take care of that
	LDA #1 << ENTER_EXIT_ACT_F | 1 << ENTER_EXIT_F
	STA zTitleObj1ScreenEdgeFlags
	LDA #$e1

GenericSpriteSetup:
	STA zTitleObj1XCoord
	LDA #0
	STA zTitleObj1PointerIndex
	STA zTitleObj1FramePointer
	STA zTitleObj1FramePointer + 1
	LDA #>iVirtualOAM
	STA zTitleObj1OAMPointer + 1
	RTS

SetUpCommonIggyPointers:
	LDA #<IggyFrames_pointersLO
	STA zTitleObj1PointerAddresses
	LDA #>IggyFrames_pointersLO
	STA zTitleObj1PointerAddresses + 1
	LDA #<IggyFrames_pointersHI
	STA zTitleObj1PointerAddresses + 2
	LDA #>IggyFrames_pointersHI
	STA zTitleObj1PointerAddresses + 3
	LDA #TITLE_IGGY_OFFSET
	STA zTitleObj1OAMPointer
	LDA #$6d
	STA zTitleObj1YCoord
	LDA #4
	STA zTitleObjLoopPoint1
	RTS

ClearTitleAnim1Area:
	LDA #0
	LDY #zTitleObj1End - zTitleObj1
@Loop:
	DEY
	STA zTitleObj1, Y
	BPL @Loop
	RTS

ClearTitleAnim2Area:
	LDA #0
	LDY #zTitleObj2End - zTitleObj2
@Loop:
	DEY
	STA zTitleObj2, Y
	BPL @Loop
	RTS

Anim2InitPointersLO:
	dl InitCrowAnimation
	dl ClearTitleAnim2Area

Anim2InitPointersHI:
	dh InitCrowAnimation
	dh ClearTitleAnim2Area

Anim1InitPointersLO:
	dl InitIggyAnimation
	dl InitOtisAnimation
	dl InitIggy2Animation
	dl ClearTitleAnim1Area

Anim1InitPointersHI:
	dh InitIggyAnimation
	dh InitOtisAnimation
	dh InitIggy2Animation
	dh ClearTitleAnim1Area

CopySprite1DataDescending:
	; byte 3 - x coordinate
	LDA (zTitleObj1FramePointer), Y
	CLC
	ADC zTitleObj1XCoord
	STA (zTitleObj1OAMPointer), Y
	DEY
	; byte 2 - tile attribute (palette, reversal, priority)
	LDA (zTitleObj1FramePointer), Y
	STA (zTitleObj1OAMPointer), Y
	DEY
	; byte 1 - tile pair number & $FE (bit 0 determines the current bank)
	LDA (zTitleObj1FramePointer), Y
	STA (zTitleObj1OAMPointer), Y
	DEY
	; byte 0 - y coordinate
	LDA (zTitleObj1FramePointer), Y
	CLC
	ADC zTitleObj1YCoord
	STA (zTitleObj1OAMPointer), Y
	DEY
	RTS

CopySprite2DataDescending:
	; byte 3 - x coordinate
	LDA (zTitleObj2FramePointer), Y
	CLC
	ADC zTitleObj2XCoord
	STA (zTitleObj2OAMPointer), Y
	DEY
	; byte 2 - tile attribute (palette, reversal, priority)
	LDA (zTitleObj2FramePointer), Y
	STA (zTitleObj2OAMPointer), Y
	DEY
	; byte 1 - tile pair number & $FE (bit 0 determines the current bank)
	LDA (zTitleObj2FramePointer), Y
	STA (zTitleObj2OAMPointer), Y
	DEY
	; byte 0 - y coordinate
	LDA (zTitleObj2FramePointer), Y
	CLC
	ADC zTitleObj2YCoord
	STA (zTitleObj2OAMPointer), Y
	DEY
	RTS

ApplySprite1Movement:
	; get change in movement
	LDA (zTitleObj1MovementPointer), Y
	CLC
	ADC zTitleObj1XCoord
	STA zTitleObj1XCoord
	; determine which direction we're going
	LDA (zTitleObj1MovementPointer), Y
	BPL @Left
	; right = 1
	LDA zTitleObj1ScreenEdgeFlags
	SSB ENTER_EXIT_DIR_F
	STA zTitleObj1ScreenEdgeFlags
	RTS
@Left:
	; left = 0
	LDA zTitleObj1ScreenEdgeFlags
	RSB ENTER_EXIT_DIR_F
	STA zTitleObj1ScreenEdgeFlags
	RTS

ApplySprite2Movement:
	; get change in movement
	LDA (zTitleObj2MovementPointer), Y
	CLC
	ADC zTitleObj2XCoord
	STA zTitleObj2XCoord
	; determine which direction we're going
	LDA (zTitleObj2MovementPointer), Y
	BPL @Left
	; right = 1
	LDA zTitleObj2ScreenEdgeFlags
	SSB ENTER_EXIT_DIR_F
	STA zTitleObj2ScreenEdgeFlags
	RTS
@Left:
	; left = 0
	LDA zTitleObj2ScreenEdgeFlags
	RSB ENTER_EXIT_DIR_F
	STA zTitleObj2ScreenEdgeFlags
	RTS

InitNextSprite:
	LDA zTitleObjFinished
	BEQ @Quit
	LDY #0
	STY zTitleObjFinished
	CMP #2
	BEQ @Obj2
	BCS @BothSprites
@Obj1:
	INC zTitle1ObjIndex
	LDY zTitle1ObjIndex
	BPL InitTitleObj1
@Obj2:
	INC zTitle2ObjIndex
	LDY zTitle2ObjIndex
	BPL InitTitleObj2
@BothSprites:
	INC zTitle1ObjIndex
	INC zTitle2ObjIndex
	LDY zTitle1ObjIndex
	LDX zTitle2ObjIndex
	BPL InitSprites
@Quit:
	RTS

InitTitleObj1:
	LDA Anim1InitPointersLO, Y
	STA zTitleObj1InitPointer
	LDA Anim1InitPointersHI, Y
	STA zTitleObj1InitPointer + 1
	JMP (zTitleObj1InitPointer)

InitTitleObj2:
	LDA Anim2InitPointersLO, Y
	STA zTitleObj2InitPointer
	LDA Anim2InitPointersHI, Y
	STA zTitleObj2InitPointer + 1
InitTitleObj2Preset:
	JMP (zTitleObj2InitPointer)

InitSprites:
	LDA Anim1InitPointersLO, Y
	STA zTitleObj1InitPointer
	LDA Anim1InitPointersHI, Y
	STA zTitleObj1InitPointer + 1
	LDA Anim2InitPointersLO, X
	STA zTitleObj2InitPointer
	LDA Anim2InitPointersHI, X
	STA zTitleObj2InitPointer + 1
	JSR InitTitleObj2Preset
	JMP (zTitleObj1InitPointer)

StartInitializingSprites:
	LDA #3
	STA zTitleObjFinished
	LDA #$ff
	STA zTitle1ObjIndex
	STA zTitle2ObjIndex
	TAY
	TAX
	LDA Anim1InitPointersLO - $ff, Y
	STA zTitleObj1InitPointer
	LDA Anim1InitPointersHI - $ff, Y
	STA zTitleObj1InitPointer + 1
	LDA Anim2InitPointersLO - $ff, X
	STA zTitleObj2InitPointer
	LDA Anim2InitPointersHI - $ff, X
	STA zTitleObj2InitPointer + 1
	RTS

RunSoundQueues:
	JSR RunSound1

RunSound2:
	LDA zTitleObj2PointerAddresses
	CMP #<CrowFrames_pointersLO
	BNE @Bail
	LDA zTitleObj2PointerAddresses + 1
	CMP #>CrowFrames_pointersLO
	BNE @Bail
	LDY zTitleObj2PointerIndex
	LDA TitleScreenCrowSoundQueues, Y
	BEQ @Bail
	TAY
	LDA zCurrentDPCMSFX
	BNE @Bail
	JSR PlaySFX
@Bail:
	RTS

RunSound1:
	LDA zTitleObj1PointerAddresses
	CMP #<IggyFrames_pointersLO
	BNE @Bail
	LDA zTitleObj1PointerAddresses + 1
	CMP #>IggyFrames_pointersLO
	BNE @Bail
	LDY zTitleObj1PointerIndex
	LDA TitleScreenIggySoundQueues, Y
	BEQ @Bail
	TAY
	LDA zCurrentDPCMSFX
	BNE @Bail
	JSR PlaySFX
@Bail:
	RTS

TitleScreenCrowSoundQueues:
	.db 0
	.db 0
	.db SFX_JUMP
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db SFX_FLAP
	.db 0
	.db 0
	.db 0
	.db SFX_FLAP
	.db 0
	.db 0
	.db 0
	.db 0
	.db SFX_FLAP
	.db 0
	.db 0

TitleScreenIggySoundQueues:
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db SFX_STOP
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db SFX_IGGY_TALKING
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0
