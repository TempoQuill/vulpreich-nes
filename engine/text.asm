_PrintText:
; Current character = (AuxAddresses + 6) + Y
; Text Command Pointer = AuxAddresses 2
; PPUADDR input = NametableAddress
	LDA (AuxAddresses + 6), Y
	CMP #"@"
	PHA
	BCS @ReadCommand
	STA TextBuffer, Y
	INC NametableAddress
	BNE @CopyToPPU
	INC NametableAddress + 1
@CopyToPPU:
	LDA NametableAddress + 1
	STA PPUADDR
	LDA NametableAddress
	STA PPUADDR
	PLA
	STA PPUDATA
	INY
	BCC PrintText

@ReadCommand:
	PLA
	SBC #"@"
	ASL A ; only sets c if A ≥ $80 at this point
	TAX
	LDA @CommandTable, X
	STA AuxAddresses + 2
	INX
	LDA @CommandTable, X
	STA AuxAddresses + 3
	JMP (AuxAddresses + 2)

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
	LDA NametableAddress
	SBC #$40
	STA AuxAddresses + 2
	LDA NametableAddress + 1
	SBC #0
	STA AuxAddresses + 3
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
	JMP PrintText

@Line:
; print at textbox line 2
	JSR GetNameTableOffsetLine2
	JSR GetPPUAddressFromNameTable
	INY
	JMP PrintText

@Para:
; start new paragraph
; effectively extends text beyond 256 bytes per string
	; zipper Y with (AuxAddresses + 6)
	TYA
	CLC ; only needed if we're on command $d2
	ADC AuxAddresses + 6
	STA AuxAddresses + 6
	LDA #0
	ADC AuxAddresses + 7
	STA AuxAddresses + 7
	; clear y
	LDY #0
	; use x to clear the text buffer
	LDX #0
	LDA #" "
@ParaLoop:
	DEX
	STA TextBuffer, X
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
	JMP PrintText

@TextEnd:
; terminate printing routine
	RTS

@Next:
; print at next line, offset by StringXOffset
	INC NametableAddress
	LDA NametableAddress
	BEQ @NextByte
	AND #$3f
	BEQ @NextWrite
	JMP @Next
@NextByte:
	INC NametableAddress + 1
@NextWrite:
	LDA NametableAddress + 1
	STA PPUADDR
	LDA NametableAddress
	ADC StringXOffset
	STA PPUADDR
	JMP PrintText