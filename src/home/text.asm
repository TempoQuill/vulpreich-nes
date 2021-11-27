PrintText:
	SEC
	; get index according to location upper digits
	LDA #>_PrintText
	JSR GetWindowIndex
	; load bank into corresponding window
	LDA #PRG_TextEngine
	JSR StoreIndexedBank
	JSR _PrintText
	JMP UpdatePRG

GetPPUAddressFromNameTable:
; store the nametable pointer through PPU
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
	RTS

ReadPPUData:
; copy 
	LDX #TEXT_BOX_WIDTH
	STX zBackupX
@Loop:
	DEX
	DEC zBackupX
	LDA PPUDATA
	STA zStringBuffer + $60, X
	LDX zBackupX
	BNE @Loop
	RTS

WritePPUData:
	LDX #TEXT_BOX_WIDTH
	STX zBackupX
@Loop:
	DEX
	DEC zBackupX
	STA PPUDATA
	INC cNametableAddress
	LDX zBackupX
	BNE @Loop
	RTS

WritePPUDataFromStringBuffer:
	LDX #TEXT_BOX_WIDTH
	STX zBackupX
@Loop:
	DEX
	DEC zBackupX
	LDA zStringBuffer + $60, X
	STA PPUDATA
	INC cNametableAddress
	LDX zBackupX
	BNE @Loop
	RTS

GetNameTableOffsetLine1:
	LDA #0
	CLC
	ADC #<TEXT_COORD_1
	STA cNametableAddress
	LDA #$20
	ADC #>TEXT_COORD_1
	STA cNametableAddress + 1
	RTS

GetNameTableOffsetLine2:
	LDA #0
	CLC
	ADC #<TEXT_COORD_2
	STA cNametableAddress
	LDA #$20
	ADC #>TEXT_COORD_2
	STA cNametableAddress + 1
	RTS

GetName:
; Return name cCurrentIndex from name list cObjectType in zStringBuffer.
	; preserve registers
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	LDA #>GetNamePointer
	JSR GetWindowIndex
	LDA #PRG_TextEngine
	JSR StoreIndexedBank
	JSR GetNamePointer
	STA MMC5_PRGBankSwitch2, X

	LDA #>CopyCurrentIndex
	JSR GetWindowIndex
	LDA #PRG_TextEngine
	JSR StoreIndexedBank
	JSR CopyCurrentIndex

	; restore all registers
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	; bank switch
	JMP UpdatePRG

NamesPointers:
	dba PRG_Names0, ItemNames

GetNthString:
; Return the address of the Ath string starting from (zAuxAddresses + 6)
	; return if A - 1 = 0
	BEQ @Quit
	; preserve X and Y
	STY zBackupY
	STX zBackupX
	; Y has to be 0 to read 
	LDY #0
	; X = (cCurrentIndex - 1)
	TAX
@Loop:
	; loop if not terminator
	LDA (zAuxAddresses + 6), Y
	INC zAuxAddresses + 6
	BEQ @Next
	INC zAuxAddresses + 7
@Next:
	CMP #"@"
	BNE @Loop
	; loop if Y dec doesn't set z
	DEY
	BNE @Loop
	; restore X and Y
	LDX zBackupX
	LDY zBackupY
@Quit:
	RTS
