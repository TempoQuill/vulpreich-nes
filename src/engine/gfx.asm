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
	AND #$ff ^ PPU_NMI
	STA zPPUCtrlMirror
	STA PPUCTRL
	; set up address
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR ; happens to be the empty tile we need
	LDY #>NAMETABLE_AREA
	LDX #<NAMETABLE_AREA + 1
	; write for $400 bytes
@Loop:
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA

	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA

	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA

	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA
	DEX
	STA PPUDATA

	BNE @Loop
	DEY
	BPL @Loop
	; restore NMI
	LDA zPPUCtrlMirror
	ORA #PPU_NMI
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
