StoreText:
; store all text as instructed
	SEC
	; get index according to upper digits of location
	; load bank into corresponding window
	JSH PRG_GFXEngine, _StoreText
	JMP SyncToCurrentWindow

PrintText:
; print text one character at a time
	LDY #0
	SEC
	LDA zTextOffset
	BNE @DoPrint
	LDA zTextOffset + 1
	BEQ @Done
@DoPrint:
	JSH PRG_GFXEngine, _PrintText
@Done:
	JMP UpdatePRG

FadePalettes:
; fade in and fade out the palettes on screen
	SEC
	JSH PRG_GFXEngine, _FadePalettes
	JMP UpdatePRG

UpdateGFXAttributes:
; update / apply current graphical attributes
	SEC
	JSH PRG_GFXEngine, _UpdateGFXAttributes
	JMP UpdatePRG

InitPals:
; initialize palettes
	SEC
	JSH PRG_GFXEngine, _InitPals
	JMP UpdatePRG

InitNameTable:
; initialize nametables + attributes
	SEC
	JSH PRG_GFXEngine, _InitNameTable
	JMP UpdatePRG

GetTextByte:
	LDA zCurrentTextAddress + 1
	JSR GetWindowIndex
	LDA zTextBank
	JSR StoreIndexedBank
	LDA (zCurrentTextAddress), Y
	STA zCurrentTextByte
	LDA #PRG_GFXEngine
	STA zWindow1
	JSR UpdatePRG
	LDA zCurrentTextByte
	RTS

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
	STA iStringBuffer + $60, X
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
	LDA iStringBuffer + $60, X
	STA PPUDATA
	INC cNametableAddress
	LDX zBackupX
	BNE @Loop
	RTS

GetNameTableOffsetLine1:
	LDA #<NAMETABLE_MAP_0
	CLC
	ADC #<TEXT_COORD_1
	STA cNametableAddress
	LDA #>NAMETABLE_MAP_0
	ADC #>TEXT_COORD_1
	STA cNametableAddress + 1
	RTS

GetNameTableOffsetLine2:
	LDA #<NAMETABLE_MAP_0
	CLC
	ADC #<TEXT_COORD_2
	STA cNametableAddress
	LDA #>NAMETABLE_MAP_0
	ADC #>TEXT_COORD_2
	STA cNametableAddress + 1
	RTS

GetName:
; Return name cCurrentIndex from name list cObjectType in iStringBuffer.
	; preserve registers
	PHP
	PHA
	PHX
	PHY
	JSH PRG_GFXEngine, GetNamePointer
	STA MMC5_PRGBankSwitch2, X

	JSH PRG_GFXEngine, CopyCurrentIndex

	; restore all registers
	PLY
	PLX
	PLA
	PLP
	; bank switch
	JMP UpdatePRG

NamesPointers:
	dba PRG_Names0, ItemNames
	dba PRG_Names0, CharacterFullNames
	dba PRG_Names0, CharacterNames

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
	CMP #text_end_cmd
	BNE @Loop
	; loop if Y dec doesn't set z
	DEY
	BNE @Loop
	; restore X and Y
	LDX zBackupX
	LDY zBackupY
@Quit:
	RTS
