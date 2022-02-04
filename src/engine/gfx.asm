_InitPals:
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
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR
	LDY #>((NAMETABLE_MAP_1 - NAMETABLE_MAP_0) * 4) + 1
	LDX #<((NAMETABLE_MAP_1 - NAMETABLE_MAP_0) * 4)
@Loop:
	DEX
	STA PPUDATA
	BNE @Loop
	DEY
	BNE @Loop
	RTS

GetNamePointer:
	; turn cObjectType into index Y
	LDA cObjectType
	CLC
	SBC #0
	STA zBackupA
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
	RTS

CopyCurrentIndex:
	; get current index number
	LDA cCurrentIndex
	CLC
	SBC #0
	JSR GetNthString

	; copy ITEM_NAME_LENGTH bytes to string buffer
	LDY #ITEM_NAME_LENGTH + 1
	LDA #<iStringBuffer
	STA zAuxAddresses + 2
	STA cCurrentRAMAddress
	LDA #>iStringBuffer
	STA zAuxAddresses + 3
	STA cCurrentRAMAddress + 1
	JMP CopyBytes

_InstantPrint:
; Current character = (zAuxAddresses + 6) + Y
; Text Command Pointer = zAuxAddresses 2
; PPUADDR input = cNametableAddress
	JSR _InitPals
	JSR GetTextByte
	PHA
	BMI @GetCommand
	STA cTextBuffer, Y
	INC cNametableAddress
	BNE @CopyToPPU
	INC cNametableAddress + 1
@CopyToPPU:
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
	PLA
	STA PPUDATA
	INY
	JMP _InstantPrint

@GetCommand:
	PLA
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
; only valid when printing one character at a time
	JMP _InstantPrint

@Line:
; print at textbox line 2
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	INY
	JMP _InstantPrint

@Para:
; only valid when printing one character at a time
	JMP _InstantPrint

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
	JMP _InstantPrint

_PrintText:
	JSR GetTextByte
	PHA
	BMI @GetCommand
	STA cTextBuffer, Y
	INC cNametableAddress
	BNE @CopyToPPU
	INC cNametableAddress + 1
@CopyToPPU:
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
	PLA
	STA PPUDATA
	INY
	RTS

@GetCommand:
	PLA
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
; effectively extends text beyond 256 bytes per string
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
	BMI @Fading
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
	PHA
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
	PLA
	STA iPals
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

_UpdateGFXAttributes:
	LDX #0
	LDA #>NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_0
	JSR ApplyGFXAttributes
	LDX #0
	LDA #>NAMETABLE_ATTRIBUTE_1
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_1
	JSR ApplyGFXAttributes
	LDX #0
	LDA #>NAMETABLE_ATTRIBUTE_2
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_2
	JSR ApplyGFXAttributes
	LDX #0
	LDA #>NAMETABLE_ATTRIBUTE_3
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_3

ApplyGFXAttributes:
	STA PPUADDR
@Loop:
	LDA iPalAttributes, X
	STA PPUDATA
	INX
	CPX #GFX_ATTRIBUTE_SIZE
	BCC @Loop
	RTS
