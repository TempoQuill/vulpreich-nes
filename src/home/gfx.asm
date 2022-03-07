StoreText:
; store all text as instructed: unlike the subs below, we aren't in an NMI
; so we can't use the conventional update when returning
	; JSH means we are accessing a subroutine in a different bank
	; since we're already home, we can just bankswitch from here
	JSH PRG_GFXEngine, _StoreText
	JMP SyncToCurrentWindow

PrintText:
; print text one character at a time
	LDY #0
	; check for active byte queue
	LDA zTextOffset
	ORA zTextOffset + 1
	BEQ @Done
@DoPrint:
	; we have text to print now
	; which way? CHR by CHR or instant?
	LDA zTextSpeed
	BEQ @Instant
	JSH PRG_GFXEngine, _PrintText
@Done:
	JMP UpdatePRG
@Instant:
	JSH PRG_GFXEngine, InstantPrint
	JMP UpdatePRG

FadePalettes:
; fade in and fade out the palettes on screen
	JSH PRG_GFXEngine, _FadePalettes
	JMP UpdatePRG

UpdateGFXAttributes:
; update / apply current graphical attributes
	LDX #GFX_ATTRIBUTE_SIZE
	LDA cNametableAddress + 1
	ORA #>NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
	LDA #<NAMETABLE_ATTRIBUTE_0
	STA PPUADDR
@Loop:
	LDA zPalAttributes - 1, X
	DEX
	STA PPUDATA
	LDA zPalAttributes - 1, X
	DEX
	STA PPUDATA
	BNE @Loop
	RTS

UpdateBackground:
; write to bg. zCurrentTileNametableAddress according to zCurrentTileAddress
; update for zTileOffset bytes
	JSH PRG_GFXEngine, _UpdateBackground
	JMP UpdatePRG

InitPals:
; despite not being in an NMI, conventional PRG updates apparently work here
; initialize palettes
	JSH PRG_GFXEngine, _InitPals
	JMP UpdatePRG

InitNameTable:
; initialize nametables + attributes
	JSH PRG_GFXEngine, _InitNameTable
	JMP UpdatePRG

GetTextByte:
; snatch a byte from zCurrentTextAddress in zTextBank
	LDA zCurrentTextAddress + 1
	JSR GetWindowIndex
	LDA zTextBank
	STA MMC5_PRGBankSwitch2, X
	STA zCurrentWindow, X
	LDA (zCurrentTextAddress), Y
	STA zCurrentTextByte
	LDA #PRG_GFXEngine
	STA zWindow1
	JSR UpdatePRG ; restore old bank
	LDA zCurrentTextByte
	RTS

DisplayTextRow:
	LDA zCurrentTextAddress + 1
	JSR GetWindowIndex
	LDA zTextBank
	STA MMC5_PRGBankSwitch2, X
	STA zCurrentWindow, X
@Loop:
	LDA (zCurrentTextAddress), Y
	BMI @Command
	STA PPUDATA
	INC zCurrentTextAddress
	BNE @Loop
	INC zCurrentTextAddress + 1
	BNE @Loop
@Command:
	STA zCurrentTextByte
	LDA #PRG_GFXEngine
	STA zWindow1
	JSR UpdatePRG ; restore old bank
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
	JMP SyncToCurrentWindow

NamesPointers:
	dba PRG_Names0, ItemNames
	dba PRG_Names0, CharacterFullNames
	dba PRG_Names0, CharacterNames
	dba PRG_Names0, LocationNames
	dba PRG_Names0, EpisodeNames ; do not use

GetNthString:
; Return the address of the Ath string starting from (zAuxAddresses + 6)
	; return if A - 1 = 0
	BEQ @Quit
	PHA
	LDA cObjectType
	CMP #EPISODE_NAMES
	BEQ @Episode
	PLA
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

@Episode:
	PLA
	JMP GetEpisodeName
