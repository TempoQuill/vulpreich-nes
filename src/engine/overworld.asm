InitOverworld:
	JSR InitPPU_FullScreenUpdate
	LDA #MUSIC_NONE
	STA zMusicQueue
	; store the palette data
	LDA #3
	STA zPalFade
	STA zPalFadeSpeed
	JSR IggysRoomPaletteAndNametableSetup

	LDY #OverworldInstaClear_END - OverworldInstaClear


@StringLoop:
	LDA OverworldInstaClear, Y
	STA iStringBuffer, Y
	DEY
	BPL @StringLoop
	; we can enable graphical updates now
	LDA zPPUCtrlMirror
	ORA #PPU_NMI | PPU_OBJ_RES
	STA zPPUCtrlMirror
	STA rCTRL

	LDA #1
	JSR DelayFrame_s_

	JSR SetUpStringBuffer

	LDA #<IggysRoomLayout
	STA zPPUDataBufferPointer
	LDA #>IggysRoomLayout
	STA zPPUDataBufferPointer + 1

	LDA #1
	JSR DelayFrame_s_

	JSR ShowNewScreen

	LDA #<cPPUBuffer
	STA zPPUDataBufferPointer
	LDA #>cPPUBuffer
	STA zPPUDataBufferPointer + 1

	; fade in palettes
	LDA zPals
	SSB PAL_FADE_F
	STA zPals
@WaitForFadeIn:
	LDA #1
	JSR DelayFrame_s_
	LDA zPals
	BMI @WaitForFadeIn
	RTS

StartOverworld:
	JSR InitOverworld
@Run:
	LDA #1
	JSR DelayFrame_s_
	JMP @Run

IggysRoomPals:
.incbin "src/raw-data/iggysroom.pal

IggysRoomPaletteAndNametableSetup:
	LDX #$1f
@PalLoop:
	LDA IggysRoomPals, X
	STA iCurrentPals, X
	DEX
	BPL @PalLoop
	; set up nametable and text
	LDA #<cPPUBuffer
	STA zPPUDataBufferPointer
	LDA #>cPPUBuffer
	STA zPPUDataBufferPointer + 1
	RTS

OverworldInstaClear:
	.db $20, $00, $7F, $00
	.db $20, $3F, $7F, $00
	.db $20, $7E, $7F, $00
	.db $20, $BD, $7F, $00
	.db $20, $FC, $7F, $00
	.db $21, $3B, $7F, $00
	.db $21, $7A, $7F, $00
	.db $21, $B9, $7F, $00
	.db $21, $F8, $7F, $00
	.db $22, $37, $7F, $00
	.db $22, $76, $7F, $00
	.db $22, $B5, $7F, $00
	.db $22, $F4, $7F, $00
	.db $23, $33, $7F, $00
	.db $23, $72, $7F, $00
	.db $23, $B1, $4F, $00
	.db $23, $C0, $7F, $00
	.db $23, $FF, $01, $00
OverworldInstaClear_END:
	.DB $00
