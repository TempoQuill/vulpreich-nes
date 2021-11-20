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
	LDA NametableAddress + 1
	STA PPUADDR
	LDA NametableAddress
	STA PPUADDR
	RTS

ReadPPUData:
; copy 
	LDX #TEXT_BOX_WIDTH
	STX BackupX
@Loop:
	DEX
	DEC BackupX
	LDA PPUDATA
	STA StringBuffer + $30, X
	LDX BackupX
	BNE @Loop
	RTS

WritePPUData:
	LDX #TEXT_BOX_WIDTH
	STX BackupX
@Loop:
	DEX
	DEC BackupX
	STA PPUDATA
	INC NametableAddress
	LDX BackupX
	BNE @Loop
	RTS

WritePPUDataFromStringBuffer:
	LDX #TEXT_BOX_WIDTH
	STX BackupX
@Loop:
	DEX
	DEC BackupX
	LDA StringBuffer + $30, X
	STA PPUDATA
	INC NametableAddress
	LDX BackupX
	BNE @Loop
	RTS

GetNameTableOffsetLine1:
	LDA #0
	CLC
	ADC #<TEXT_COORD_1
	STA NametableAddress
	LDA #$20
	ADC #>TEXT_COORD_1
	STA NametableAddress + 1
	RTS

GetNameTableOffsetLine2:
	LDA #0
	CLC
	ADC #<TEXT_COORD_2
	STA NametableAddress
	LDA #$20
	ADC #>TEXT_COORD_2
	STA NametableAddress + 1
	RTS

GetName:
; Return name CurrentIndex from name list ObjectType in StringBuffer.
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
; Return the address of the Ath string starting from (AuxAddresses + 6)
	; return if A - 1 = 0
	BEQ @Quit
	; preserve X and Y
	STY BackupY
	STX BackupX
	; Y has to be 0 to read 
	LDY #0
	; X = (CurrentIndex) - 1
	TAX
@Loop:
	; loop if not terminator
	LDA (AuxAddresses + 6), Y
	INC AuxAddresses + 6
	BEQ @Next
	INC AuxAddresses + 7
@Next:
	CMP #"@"
	BNE @Loop
	; loop if Y dec doesn't set z
	DEY
	BNE @Loop
	; restore X and Y
	LDX BackupX
	LDY BackupY
@Quit:
	RTS
