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
	LDA #zStringBuffer
	STA zAuxAddresses + 2
	STA cCurrentRAMAddress
	LDA #0
	STA zAuxAddresses + 3
	STA cCurrentRAMAddress + 1
	JMP CopyBytes

_PrintText:
; Current character = (zAuxAddresses + 6) + Y
; Text Command Pointer = zAuxAddresses 2
; PPUADDR input = cNametableAddress
	JSR GetTextByte
	CMP #"@"
	PHA
	BCS @ReadCommand
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

@ReadCommand:
	PLA
	SBC #"@"
	ASL A ; only sets c if A ≥ $80 at this point
	TAX
	LDA @CommandTable, X
	STA zAuxAddresses + 2
	INX
	LDA @CommandTable, X
	STA zAuxAddresses + 3
	JMP (zAuxAddresses + 2)

@CommandTable:
; text commands 50-cf
; d0-ff are the same as 50-7f, except c = 1
	.dw @TextEnd  ; 50 "@"
	.dw @Next     ; 51
	.dw @Para     ; 52
	.dw @Line     ; 53
	.dw @Continue ; 54
	.dw @TextEnd  ; 55 done

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
	LDA #" "
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
	CLC ; only needed if we're on command $d2
	ADC zAuxAddresses + 6
	STA zAuxAddresses + 6
	LDA #0
	ADC zAuxAddresses + 7
	STA zAuxAddresses + 7
	; clear y
	LDY #0
	; use x to clear the text buffer
	LDX #0
	LDA #" "
@ParaLoop:
	DEX
	STA cTextBuffer, X
	BNE @ParaLoop
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	LDA #" "
	JSR WritePPUData
	JSR GetNameTableOffsetLine1
	JSR GetPPUAddressFromNameTable
	LDA #" "
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
