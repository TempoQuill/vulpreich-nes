_InitPals:
; clear palette RAM
	LDA #15
	TAX
	STA zPals, X
@Loop:
	DEX
	STA zPals, X
	BNE @Loop
@Quit:
	RTS

_InitNameTable:
; clear a nametable including attributes
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
;	X                 - offset #
;	zAuxAddresses + 6 - base address
;	zTextBank         - base bank
; output
;	zTextOffset         - text size
;	zCurrentTextAddress - output address
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

InstantPrint:
; print all text at once
	; read the status
	LDA PPUSTATUS
	; update address
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
@Loop:
	; parse until a command is read
	JSR DisplayTextRow
	INC zCurrentTextAddress
	BNE @SkipCarry
	INC zCurrentTextAddress + 1
@SkipCarry:
	TAX
	DEX
	BPL @End
	DEX
	BPL @Next

@End:
	RTS

@Next:
	; raise to the nearest multiple of 64
	LDA cNametableAddress
	AND #$c0
	ASL A
	ROL A
	ROL A
	TAX
	INX ; next vertically even tile
	TXA
	LDX cNametableAddress + 1
	LSR A
	ROR A
	ROR A
	BCC @NextWrite
	CLC
	INX
@NextWrite:
	ADC zStringXOffset
	; update address
	STX cNametableAddress + 1
	STA cNametableAddress
	STX PPUADDR
	STA PPUADDR
	BCC @Loop

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
	BNE @SkipCarry
	INC cNametableAddress + 1
@SkipCarry:
	INC zCurrentTextAddress
	BNE @CopyToPPU
	INC zCurrentTextAddress + 1
@CopyToPPU:
	; update PPU address
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
	PLA ; place the character
	STA PPUDATA
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
	LDA cNametableAddress
	AND #$c0
	ASL A
	ROL A
	ROL A
	TAX
	INX ; next vertically even tile
	TXA
	LDX cNametableAddress + 1
	LSR A
	ROR A
	ROR A
	BNE @NextWrite
	CLC
	INX
@NextWrite:
	ADC zStringXOffset
	STX cNametableAddress + 1
	STA cNametableAddress
	STX PPUADDR
	STA PPUADDR
	JMP _PrintText

_FadePalettes:
; fade palletes out/in
; used for title screen
	; zPals initial byte contains two bitwise commands
	; 6 (o) = fade direction, 7 (s) = fade power
	LDA zPals
	BIT zPals
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
	LDA zPals, X
	PHA
	LDA zPals + 4, X
	PHA
	LDA zPals + 8, X
	PHA
	LDY zPals + 12, X
	TXA
	; does x = 0? Skip if so.
	BEQ @Final
	; else, let's apply the colors
	INX
	TYA
	STA zPals + 12, X
	PLA
	STA zPals + 8, X
	PLA
	STA zPals + 4, X
	PLA
	STA zPals, X
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
	LDA zPals
	RSB PAL_FADE_DIR_F
	PHA ; save this for later
	AND #COLOR_INDEX
	LDX #NUM_PALETTES
@FinalLoop:
	; clear palettes
	DEX
	STA zPals + 12, X
	STA zPals + 8, X
	STA zPals + 4, X
	STA zPals, X
	BNE @FinalLoop
	; apply the flags
	PLA
	STA zPals
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
	LDA iCurrentPals, Y
	LDY #PALETTE_FADE_PLACEMENT_MASK
@InLoop:
	; apply to palette
	STA zPals, Y
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
	; reset placement byte
	LDA #PALETTE_FADE_PLACEMENT_MASK
	STA zPalFadePlacement
	LDA zPals
	RSB PAL_FADE_F
	STA zPals
	RTS

_UpdateBackground:
; apply the current background map chosen
	; can't update without vblank
	LDA PPUSTATUS
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
	LDX #GFX_ATTRIBUTE_SIZE
	LDA cNametableAddress + 1
	ORA #>NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
@Loop:
	LDA zPalAttributes, X
	STA PPUDATA
	DEX
	BNE @Loop
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
