PrintText:
	SEC
	LDA #>_PrintText
	JSR GetWindowIndex
	LDA MMC5_PRGBankSwitch2, X
	STA Window1, X
	LDA #PRG_TextEngine
	STA MMC5_PRGBankSwitch2, X
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

GetName::
; Return name CurrentIndex from name list ObjectType in StringBuffer.

	; preserve registers
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	; turn ObjectType into index Y
	LDA ObjectType
	CLC
	SBC #0
	STA BackupA
	LSR A
	ADC BackupA
	TAY
	; get three-byte pointer
	; high
	LDA NamesPointers + 2, Y
	STA AuxAddresses + 7
	JSR GetWindowIndex
	; low
	LDA NamesPointers + 1, Y
	STA AuxAddresses + 6
	; bank
	LDA NamesPointers, Y
	STA MMC5_PRGBankSwitch2, X

	; get current index number
	LDA CurrentIndex
	CLC
	SBC #0
	JSR GetNthString

	; copy ITEM_NAME_LENGTH bytes to string buffer
	LDY #ITEM_NAME_LENGTH + 1
	LDA #StringBuffer ; ZP RAM
	STA AuxAddresses + 2
	STA CurrentRAMAddress
	LDA #0
	STA AuxAddresses + 3
	STA CurrentRAMAddress + 1
	JSR CopyBytes

	; restore all registers
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	; bank switch
	JMP UpdatePRG

GetNthString::
; Return the address of the
; ath string starting from (AuxAddresses) + 6

	; return if a - 1 = 0
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
