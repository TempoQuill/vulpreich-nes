InitSaveMenuBackground:
; We are assumed to be switched to RAM_PrimaryPlayFile
	; we're initializing the PPU
	; turn off NMI & PPU
	JSR InitPPU_FullScreenUpdate

	LDY #MUSIC_NONE
	STY zMusicQueue

	; store the palette data
	LDY #1
	STY zPalFade
	STY zPalFadeSpeed

	LDY #$1f
@PalLoop:
	LDA SaveMenuPals, Y
	STA iCurrentPals, Y
	DEY
	BNE @PalLoop

	; initialize background
	JSR InitSaveMenuData

	; switch to main save file
	LDA #RAM_PrimaryPlayFile
	STA MMC5_PRGBankSwitch1
	STA zRAMBank
; copy the layout of the save menu background
	; start by loading two pointers: one to ROM, one to W/SRAM
	LDA #>SaveMenuLayout
	STA zSaveMenuROMPointer + 1
	LDA #<SaveMenuLayout
	STA zSaveMenuROMPointer
	LDA #>wSaveMenuArea
	STA zSaveMenuRAMPointer + 1
	LDA #<wSaveMenuArea
	STA zSaveMenuRAMPointer

	; add an offset to the high byte
	LDA #>(SaveMenuLayout_END - SaveMenuLayout)
	STA wSaveMenuOffsetHI
	TAY
	CLC
	ADC zSaveMenuROMPointer + 1
	STA zSaveMenuROMPointer + 1
	TYA
	CLC
	ADC zSaveMenuRAMPointer + 1
	STA zSaveMenuRAMPointer + 1

	; we now copy the data until we run negative
	LDY #<(SaveMenuLayout_END - SaveMenuLayout)
@CopyData:
	JSR SendToSaveData
	DEC zSaveMenuROMPointer + 1
	DEC zSaveMenuRAMPointer + 1
	DEC wSaveMenuOffsetHI
	BPL @CopyData

@DataFinished:
; now we can load whate'er save data exists to append to the background
; follows the same rules as any generic layout (xx xx yy DATA)
; in order the data goes: name, episodes, events, locations
	; We load in our data in case
	LDA #>wSaveMenuData1
	STA zSaveMenuRAMPointer + 1
	LDA #<wSaveMenuData1
	STA zSaveMenuRAMPointer

	; is there a string in Save Area 1?
	LDA sSaveArea1
	BEQ @SkipRAM1

	LDA #>sSaveArea1
	STA zSaveMenuRAMPointer + 1
	LDA #<sSaveArea1
	STA zSaveMenuRAMPointer

	LDY #wSaveMenuData2 - wSaveMenuData1
	JSR SendToSaveData

	LDA #>wSaveMenuData2
	STA zSaveMenuRAMPointer + 1
	LDA #<wSaveMenuData2
	STA zSaveMenuRAMPointer
@SkipRAM1:
	LDA sSaveArea2
	BEQ @SkipRAM2

	LDA #>sSaveArea2
	STA zSaveMenuRAMPointer + 1
	LDA #<sSaveArea2
	STA zSaveMenuRAMPointer

	LDY #wSaveMenuData2 - wSaveMenuData1
	JSR SendToSaveData

@SkipRAM2:
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
	; increase sprite size for faster logic
	LDA zPPUCtrlMirror
	ORA #PPU_NMI | PPU_OBJ_RES
	STA zPPUCtrlMirror
	STA PPUCTRL

	LDA #1
	JSR DelayFrame_s_

	JSR SetUpStringBuffer

	LDY #>wSaveMenuArea
	STY zPPUDataBufferPointer + 1
	LDY #<wSaveMenuArea
	STY zPPUDataBufferPointer

	LDA #1
	JSR DelayFrame_s_

	JSR InitSaveMenuOptionsNSprites

	JSR ShowNewScreen

	LDA #MUSIC_SAVE_MENU
	STA zMusicQueue

	; fade in
	LDA zPals
	AND #COLOR_INDEX
	SSB PAL_FADE_F
	STA zPals
@WaitForFadeIn:
	LDA #1
	JSR DelayFrame_s_
	LDA zPals
	BMI @WaitForFadeIn
	RTS

InitSaveMenuOptionsNSprites:
	LDX #0
	STX zSaveMenuOption
	STX zCursorFrame
	DEX
	STX zSaveMenuSelectedOption
	LDA #<SaveMenuLayoutNormalAttributes
	STA zPPUDataBufferPointer
	LDA #>SaveMenuLayoutNormalAttributes
	STA zPPUDataBufferPointer + 1
	LDY #(SaveMenuBGSprites_END - SaveMenuBGSprites) - 1
@Loop1:
	LDA SaveMenuBGSprites, Y
	STA iVirtualOAM + SAVE_MENU_DECO_OFFS, Y
	DEY
	BPL @Loop1
	LDA #$68
	STA zCursorXPos
	LDA #$0b
	STA zCursorYPos
	RTS

RunCursor_SaveMenu:
	LDA zFilmStandardTimerOdd
	BPL @NoUpdate
	LDY zCursorFrame
	TYA
	AND #%00000100
	STA zCursorFrame
	INY
	TYA
	AND #%00000011
	ORA zCursorFrame
	STA zCursorFrame
@NoUpdate:
	LDX #OAM_16_16_WIDTH
	LDY zCursorFrame
	LDA CursorMetspriteOffsets_SaveMenu, Y
	TAY
@Loop:
	; X Position
	LDA zCursorXPos
	JSR @Coord
	; attribute
	JSR @TileAttr
	; tile no.
	JSR @TileAttr
	; Y position
	LDA zCursorYPos
	JSR @Coord
	BNE @Loop
	RTS

@TileAttr:
	DEY
	LDA CursorMetaspriteData_SaveMenu, Y
	DEX
	STA iVirtualOAM + SAVE_MENU_CURSOR_OFFS, X
	RTS

@Coord:
	DEY
	CLC
	ADC CursorMetaspriteData_SaveMenu, Y
	DEX
	STA iVirtualOAM + SAVE_MENU_CURSOR_OFFS, X
	RTS

SaveMenuPals:
.incbin "src/raw-data/save-menu.pal"

SaveMenuScreen:
	JSR InitSaveMenuBackground
@Run:
	JSR TrySaveMenuInput
	JSR AlignSaveMenuOptions
	JSR RunCursor_SaveMenu
	; was B just pressed?
	LDA zInputBottleNeck
	TSB B_BUTTON
	BNE @Back
	; Nope.  We're still running.
	LDA #1
	JSR DelayFrame_s_
	JMP @Run
@Back:
	; B was pressed.
	; Run sound queues
	LDY #SFX_SELECT_1
	JSR PlaySFX
	LDA #$FF
	STA zMusicQueue
	; Update palette fade speed
	LDA #1
	STA zPalFadeSpeed
	; fade out
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
	JSR WaitForFadeOut
	; update CHR windows
	LDA #CHR_TitleBG
	STA zCHRWindow2
	LDA #CHR_TitleOBJ2
	STA zCHRWindow1
	LDA #CHR_TitleOBJ1
	STA zCHRWindow0
	; aaaand JUMP!
	JMP IntroSequence_TitleOnly

AlignSaveMenuOptions:
	; curosr
	LDY zSaveMenuOption
	LDA SaveMenuCursr_YPositions, Y
	STA zCursorYPos
	LDA SaveMenuCursr_FrameSet, Y
	BNE @Add
	LDA zCursorFrame
	AND #3
	STA zCursorFrame
	BPL @Attr
@Add:
	ORA zCursorFrame
	STA zCursorFrame
@Attr:
	; attribute data
	LDY zSaveMenuOption
	LDA @AttrPointersLO, Y
	STA zPPUDataBufferPointer
	LDA @AttrPointersHI, Y
	STA zPPUDataBufferPointer + 1
	RTS

@AttrPointersLO:
	dl SaveMenuLayoutNormalAttributes
	dl SaveMenuLayoutNormalAttributes
	dl SaveMenuHighlight1
	dl SaveMenuHighlight2
	dl SaveMenuLayoutNormalAttributes

@AttrPointersHI:
	dh SaveMenuLayoutNormalAttributes
	dh SaveMenuLayoutNormalAttributes
	dh SaveMenuHighlight1
	dh SaveMenuHighlight2
	dh SaveMenuLayoutNormalAttributes

SaveMenuCursr_YPositions:
	.db $0b, $0b, $f8, $f8

SaveMenuCursr_FrameSet:
	.db 4, 0, 4, 4

SendToSaveData:
	DEY
	LDA (zSaveMenuROMPointer), Y
	STA (zSaveMenuRAMPointer), Y
	TYA
	BNE SendToSaveData
	RTS

InitSaveMenuData:
	LDY #wSaveMenuEnd - wSaveMenuData1
	LDA #0
@Loop:
	DEY
	STA wSaveMenuData1, Y
	BNE @Loop
	LDA #CHR_SaveMenuBG
	STA zCHRWindow2
	LDA #CHR_TitleOBJ2
	STA zCHRWindow1
	LDA #CHR_TitleOBJ1
	STA zCHRWindow0
	RTS

TrySaveMenuInput:
	JSR GetInputAction
	; 0 - do nothing
	BEQ @NoUpdate
	; 1 - switch betwen cursor & attributes
	DEX
	BEQ @OptionBit1
	; 2 - switch cursor / attributes position
	DEX
	BEQ @OptionBit0
	; 3 - select current option
	DEX
	BEQ @Select
	; 4 - back to title screen
	DEX
	BEQ @NoUpdate
	; > 4 - invalid
@NoUpdate;
	RTS

@Select:
	LDA zSaveMenuOption
	STA zSaveMenuSelectedOption
	LDY #SFX_SELECT_1
	JMP PlaySFX

@Back:
	LDA #$4
	STA zSaveMenuOption
	STA zSaveMenuSelectedOption
	LDY #SFX_SELECT_1
	JMP PlaySFX

@OptionBit1:
	TYA
	AND #1 << UP_BUTTON | 1 << DOWN_BUTTON
	CMP #1 << UP_BUTTON
	LDA #%00000010
	BCC @BitUp
	BCS @BitDown

@OptionBit0:
	TYA
	AND #1 << LEFT_BUTTON | 1 << RIGHT_BUTTON
	CMP #1 << LEFT_BUTTON
	LDA #%00000001
	BCS @BitDown
@BitUp:
	ORA zSaveMenuOption
	STA zSaveMenuOption
	LDY #SFX_CURSOR_1
	JMP PlaySFX

@BitDown:
	FAB
	AND zSaveMenuOption
	STA zSaveMenuOption
	LDY #SFX_CURSOR_1
	JMP PlaySFX

; 0 - do nothing
; 1 - switch between cursor & attributes
; 2 - switch cursor / attributes position
; 3 - select current option
; 4 - back to title screen
GetInputAction:
	LDX #0
	LDY zInputBottleNeck
	BEQ @Done
	TYA
	INX
	AND #1 << UP_BUTTON | 1 << DOWN_BUTTON
	BNE @Done
	INX
	TYA
	AND #1 << LEFT_BUTTON | 1 << RIGHT_BUTTON
	BNE @Done
	INX
	TYA
	AND #1 << A_BUTTON | 1 << START_BUTTON
	BNE @Done
	INX
	TYA
	TSB B_BUTTON
	BNE @Done
	LDX #0
@Done:
	TXA
	RTS
