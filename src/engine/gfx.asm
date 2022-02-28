_InitPals:
; clear palette RAM
	LDA #15
	TAX
	STA iPals, X
@Loop:
	DEX
	STA iPals, X
	BNE @Loop
@Quit:
	RTS

_InitNameTable:
; clear a nametable including attributes
	LDA PPUSTATUS
	; turn off NMI
	LDA zPPUCtrlMirror
	RSB PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL
	; set up address
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR ; happens to be the empty tile we need
	LDY #>(NAMETABLE_AREA * 4) + 1
	LDX #<(NAMETABLE_AREA * 4) + 1
	; write for $400 bytes
@Loop:
	DEX
	STA PPUDATA
	BNE @Loop
	DEY
	BNE @Loop
	; restore NMI
	LDA zPPUCtrlMirror
	SSB PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL
	RTS

GetNamePointer:
	; turn cObjectType into index Y
	LDA cObjectType
	SBC #1
	STA zBackupA
	TAY
	LDA NameLengths, Y
	STA cNameLength
	CPY #EPISODE_NAMES - 1
	BEQ @Quit
	TYA
	LSR A
	ADC zBackupA
	TAY
	; get three-byte pointer
	; high
	INY
	INY
	LDA NamesPointers, Y
	STA zAuxAddresses + 7
	JSR GetWindowIndex
	; low
	DEY
	LDA NamesPointers, Y
	STA zAuxAddresses + 6
	; bank
	DEY
	LDA NamesPointers, Y
@Quit:
	RTS

NameLengths:
	.db ITEM_NAME_LENGTH
	.db CHR_FULL_NAME_LENGTH
	.db CHR_NAME_LENGTH
	.db LOC_NAME_LENGTH
	.db TEXT_BOX_WIDTH

CopyCurrentIndex:
	; get current index number
	; c = 1 at this point
	LDA cCurrentIndex
	SBC #1
	JSR GetNthString

	; copy cNameLength bytes to string buffer
	LDY #cNameLength
	INY
	LDA #<iStringBuffer
	STA zAuxAddresses + 2
	STA cCurrentRAMAddress
	LDA #>iStringBuffer
	STA zAuxAddresses + 3
	STA cCurrentRAMAddress + 1
	JMP CopyBytes

_StoreText:
; load zTextOffset bytes to print
; input
;	X
;	zAuxAddresses + 6
;	zTextBank
; output
;	zTextOffset
;	zCurrentTextAddress
	; initialize offset / addresses
	LDY #0
	STY zTextOffset, X
	STY zTextOffset + 1, X
	LDA zAuxAddresses + 6
	STA zCurrentTextAddress, X
	LDA zAuxAddresses + 7
	STA zCurrentTextAddress + 1, X
@Loop:
	; sift and add to offset until text_end_cmd is encountered
	JSR GetTextByte
	CMP #text_end_cmd
	BEQ @Done
	INC zTextOffset
	BNE @NoCarry
	INC zTextOffset + 1
@NoCarry:
	INC zCurrentTextAddress, X
	BNE @Loop
	INC zCurrentTextAddress + 1, X
	BNE @Loop
@Done:
	; revert zCurrentTextAddress to its state before the loop
	LDA zAuxAddresses + 6
	STA zCurrentTextAddress, X
	LDA zAuxAddresses + 7
	STA zCurrentTextAddress + 1, X
	JSR GetWindowIndex
	; we should return to the bank we came from when we're done
	LDA zTextBank
	JMP StoreIndexedBank

_PrintText:
; print a letter once per frame
	; read status
	LDA PPUSTATUS
	; parse a byte
	JSR GetTextByte
	PHA ; save the byte
	; branch if a command was encountered
	; we'll be back here to get another byte in that case
	; UNLESS $80 or $85 was encountered, we exit from there
	BMI @GetCommand
	; increment address
	INC cNametableAddress
	BNE @CopyToPPU
	INC cNametableAddress + 1
@CopyToPPU:
	; update PPU address
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
	PLA ; place the character
	STA PPUDATA
	LDX #0
	LDA zTextOffset, X
	INX
	ORA zTextOffset, X
	BNE @Dec
	INX
	LDA zTextOffset, X
	ORA zTextOffset + 1, X
	BEQ @NoCarry
	LDY #0
	LDA zTextOffset, X
	STA zTextOffset, Y
	LDA zCurrentTextAddress, X
	LDA zCurrentTextAddress, Y
	INY
	INX
	LDA zTextOffset, X
	STA zTextOffset, Y
	LDA zCurrentTextAddress, X
	LDA zCurrentTextAddress, Y
	INY
	INX
	LDA zTextOffset, X
	ORA zTextOffset + 1, X
	BEQ @NoCarry
	LDA zTextOffset, X
	STA zTextOffset, Y
	LDA zCurrentTextAddress, X
	LDA zCurrentTextAddress, Y
	INY
	INX
	LDA zTextOffset, X
	STA zTextOffset, Y
	LDA zCurrentTextAddress, X
	LDA zCurrentTextAddress, Y
@Dec:
	DEC zTextOffset
	BNE @NoCarry
	DEC zTextOffset + 1
@NoCarry:
	RTS

@GetCommand:
; generate a pointer offset to branch to
	PLA ; we need the byte here
	EOR #$80 ; discard sign
	ASL A ; only sets c if A ≥ $80 at this point (it won't be)
	TAX
	LDA @CommandTable, X
	STA zAuxAddresses + 2
	INX
	LDA @CommandTable, X
	STA zAuxAddresses + 3
	JMP (zAuxAddresses + 2)

@CommandTable:
; text commands 80-ff
	.dw @TextEnd  ; 80
	.dw @Next     ; 81
	.dw @Para     ; 82
	.dw @Line     ; 83
	.dw @Continue ; 84
	.dw @TextEnd  ; 85 done

@Continue:
; move line 2 to line 1 and print on line 2
	JSR GetNameTableOffsetLine2
	SEC
	LDA cNametableAddress
	SBC #$40
	STA zAuxAddresses + 2
	LDA cNametableAddress + 1
	SBC #0
	STA zAuxAddresses + 3
	JSR GetPPUAddressFromNameTable
	JSR ReadPPUData
	JSR GetNameTableOffsetLine1
	JSR WritePPUDataFromStringBuffer
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	LDA #$20 ; spacebar
	JSR WritePPUData
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	INY
	JMP _PrintText

@Line:
; print at textbox line 2
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	INY
	JMP _PrintText

@Para:
; start new paragraph
	; zipper Y with (zAuxAddresses + 6)
	TYA
	CLC
	ADC zAuxAddresses + 6
	STA zAuxAddresses + 6
	LDA #0
	ADC zAuxAddresses + 7
	STA zAuxAddresses + 7
	; clear y
	LDY #0
	; use x to clear the text buffer
	LDX #0
	LDA #$20 ; spacebar
@ParaLoop:
	DEX
	STA cTextBuffer, X
	BNE @ParaLoop
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	LDA #$20 ; spacebar
	JSR WritePPUData
	JSR GetNameTableOffsetLine1
	JSR GetPPUAddressFromNameTable
	LDA #$20 ; spacebar
	JSR WritePPUData
	JSR GetNameTableOffsetLine1
	JSR GetPPUAddressFromNameTable
	JMP _PrintText

@TextEnd:
; terminate printing routine
	RTS

@Next:
; print at next line, offset by zStringXOffset
	INC cNametableAddress
	LDA cNametableAddress
	BEQ @NextByte
	AND #$3f
	BEQ @NextWrite
	JMP @Next
@NextByte:
	INC cNametableAddress + 1
@NextWrite:
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	ADC zStringXOffset
	STA PPUADDR
	JMP _PrintText

_FadePalettes:
; fade palletes out/in
; used for title screen
	; iPals initial byte contains two bitwise commands
	; 6 (o) = fade direction, 7 (s) = fade power
	LDA iPals
	BIT iPals
	BMI @Fading ; only branch if power is on
	RTS

@Fading:
	BVC @In
	; zPalFade timer is 4-bit (0-15)
	LDA zPalFade
	AND #PALETTE_FADE_SPEED_MASK
	BNE @Dec
	; zPalFadePlacement is 2-bit (0-3)
	LDX zPalFadePlacement
	DEX
	; ready colors
	LDA iPals, X
	PHA
	LDA iPals + 4, X
	PHA
	LDA iPals + 8, X
	PHA
	LDY iPals + 12, X
	TXA
	; does x = 0? Skip if so.
	BEQ @Final
	; else, let's apply the colors
	INX
	TYA
	STA iPals + 12, X
	PLA
	STA iPals + 8, X
	PLA
	STA iPals + 4, X
	PLA
	STA iPals, X
	; cleanup
	DEC zPalFadePlacement
	LDA zPalFadeSpeed
	STA zPalFade
	RTS
@Dec:
	; dec timer if we got here
	DEC zPalFade
	RTS

@Final:
	; skip color application
	PLA
	PLA
	PLA
	; clear fade direction flag (we're fading in now)
	LDA iPals
	RSB PAL_FADE_DIR_F
	PHA ; save this for later
	AND #COLOR_INDEX
	LDX #NUM_PALETTES
@FinalLoop:
	; clear palettes
	DEX
	STA iPals + 12, X
	STA iPals + 8, X
	STA iPals + 4, X
	STA iPals, X
	BNE @FinalLoop
	; apply the flags
	PLA
	STA iPals
	; reset placement byte
	LDA #PALETTE_FADE_PLACEMENT_MASK
	STA zPalFadePlacement
	RTS

@In:
	; check timer
	LDA zPalFade
	AND #PALETTE_FADE_SPEED_MASK
	BNE @InDec
	; formulate offset
	LDA zPalFadePlacement
	EOR #PALETTE_FADE_PLACEMENT_MASK
	ADC #0
	TAY
	STA zPalFadeOffset
	; get a byte directed by pointer
	LDA (zPalPointer), Y
	LDY #PALETTE_FADE_PLACEMENT_MASK
@InLoop:
	; apply to palette
	STA iPals, Y
	DEY
	; does y < zPalFadeOffset?
	CPY zPalFadeOffset
	BEQ @InSubExit
	BCS @InLoop
@InSubExit:
	; application done
	LDA zPalFadeSpeed
	STA zPalFade
	; are we done?
	LDA zPalFadePlacement
	BEQ @InFinal
	DEC zPalFadePlacement
	RTS
@InDec:
	; dec timer if we got here
	DEC zPalFade
	RTS

@InFinal:
	; we're done
	; do cleanup
	LDA iPals
	RSB PAL_FADE_F
	STA iPals
	RTS

_UpdateBackground:
; apply the current background map chosen
	; apply background address
	LDA zCurrentTileAddress
	ORA zCurrentTileAddress + 1
	BEQ @Quit
	LDY zCurrentTileNametableAddress + 1
	STY PPUADDR
	LDY zCurrentTileNametableAddress
	STY PPUADDR
	; y needs to be constant
	LDY #0
@Loop:
	; start writing
	LDA (zCurrentTileAddress), Y
	TAX
	JSR @Inc
	STX PPUDATA
	BNE @Loop
@Quit:
	RTS

@Inc:
; increment tilemap
	INC zCurrentTileAddress
	BNE @Dec
	INC zCurrentTileAddress + 1
@Dec:
; decrement offset
	DEC zTileOffset
	BNE @Done
	DEC zTileOffset + 1
@Done:
; compound bitfields to return the state of zero
; no bits active, zero flag is set
	LDA zTileOffset
	ORA zTileOffset + 1
	RTS

_UpdateGFXAttributes:
; apply attributes for all nametables
	LDX #0
	LDA cNametableAddress + 1
	AND #>NAMETABLE_ATTRIBUTE_3
	ORA #>NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
@Loop:
	LDA iPalAttributes, X
	STA PPUDATA
	INX
	CPX #GFX_ATTRIBUTE_SIZE
	BCC @Loop
	RTS

GetEpisodeName:
	LDA #PRG_Names0
	STA zTextBank
	LDA cCurrentIndex
	ASL A
	TAY
	LDA EpisodeNamePointers, Y
	STA zCurrentTextAddress
	INY
	LDA EpisodeNamePointers, Y
	STA zCurrentTextAddress + 1
	LDY #0
@Loop:
	JSR GetTextByte
	CMP #text_end_cmd
	BEQ @Quit
	CMP #text_done_cmd
	BEQ @Quit
	STA iStringBuffer, Y
	INY
	BCC @Loop
@Quit:
	RTS

EpisodeNamePointers:
	.dw VR_101
	.dw VR_102
	.dw VR_103
	.dw VR_104
	.dw VR_105
	.dw VR_106
	.dw VR_107
	.dw VR_108
	.dw VR_109
	.dw VR_110
	.dw VR_111
	.dw VR_112
	.dw VR_113
	.dw VR_114
	.dw VR_115
	.dw VR_116
	.dw VR_117
	.dw VR_118
	.dw VR_119
	.dw VR_120
	.dw VR_121
	.dw VR_122
	.dw VR_123
	.dw VR_124
	.dw VR_125
	.dw VR_126
	.dw VR_127
