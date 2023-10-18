InitSaveMenuBackground:
; We are assumed to be switched to RAM_PrimaryPlayFile
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
	; wait for vblank
	LDA PPUSTATUS
	BPL @VBlank

	; PPU initialization
	JSR InitNameTable
	JSR InitPals
	JSR HideSprites

	LDY #MUSIC_NONE
	STY zMusicQueue

	JSR ResetPPUAddress

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

	; if the first 128 bytes match, data's probably preserved
	LDY #$80
@Check:
	LDA wSaveMenuArea, Y
	CMP SaveMenuLayout, Y
	BNE @SetupROMtoRAM
	DEY
	BPL @Check
	BMI @DataFinished

@SetupROMtoRAM:
; copy the layout of the save menu background
	; start by loading two pointers: one to ROM, one to W/SRAM
	LDA #>SaveMenuLayout
	STA zAuxAddresses + 7
	LDA #<SaveMenuLayout
	STA zAuxAddresses + 6
	LDA #>wSaveMenuArea
	STA zPPUDataBufferPointer + 1
	LDA #<wSaveMenuArea
	STA zPPUDataBufferPointer

	; add an offset to the high byte
	LDA #>(SaveMenuLayout_END - SaveMenuLayout)
	STA wSaveMenuOffsetHI
	TAY
	CLC
	ADC zAuxAddresses + 7
	STA zAuxAddresses + 7
	TYA
	CLC
	ADC zPPUDataBufferPointer + 1
	STA zPPUDataBufferPointer + 1

	; we now copy the data until we run negative
	LDY #<(SaveMenuLayout_END - SaveMenuLayout)
@CopyData:
	JSR SendToSaveData
	DEC zAuxAddresses + 7
	DEC zPPUDataBufferPointer + 1
	DEC wSaveMenuOffsetHI
	BPL @CopyData

@DataFinished:
; now we can load whate'er save data exists to append to the background
; follows the same rules as any generic layout (xx xx yy DATA)
; in order the data goes: name, episodes, events, locations
	; We load in our data in case
	LDA #>wSaveMenuData1
	STA zPPUDataBufferPointer + 1
	LDA #<wSaveMenuData1
	STA zPPUDataBufferPointer

	; is there a string in Save Area 1?
	LDA sSaveArea1
	BEQ @SkipRAM1

	LDA #>sSaveArea1
	STA zAuxAddresses + 7
	LDA #<sSaveArea1
	STA zAuxAddresses + 6

	LDY #wSaveMenuData2 - wSaveMenuData1
	JSR SendToSaveData

	LDA #>wSaveMenuData2
	STA zPPUDataBufferPointer + 1
	LDA #<wSaveMenuData2
	STA zPPUDataBufferPointer
@SkipRAM1:
	LDA sSaveArea2
	BEQ @SkipRAM2

	LDA #>sSaveArea2
	STA zAuxAddresses + 7
	LDA #<sSaveArea2
	STA zAuxAddresses + 6

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

	LDY #>wSaveMenuArea
	STY zPPUDataBufferPointer + 1
	LDY #<wSaveMenuArea
	STY zPPUDataBufferPointer

	; sure, we can get the game to show our stuff now
	LDA #PPU_OBJ | PPU_BG
	STA PPUMASK
	STA zPPUMaskMirror

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
	LDA #0
	STA zSaveMenuOption
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

SaveMenuPals:
.incbin "src/raw-data/save-menu.pal"

SaveMenuScreen:
	JSR InitSaveMenuBackground
	JSR InitSaveMenuOptionsNSprites
@Loop:
	RTS

SendToSaveData:
	DEY
	LDA (zAuxAddresses + 6), Y
	STA (zPPUDataBufferPointer), Y
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
	RTS