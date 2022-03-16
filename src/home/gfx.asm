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
	BNE @DoPrint
	RTS
@DoPrint:
	; we have text to print now
	; which way? CHR by CHR or instant?
	LDA zTextSpeed
	BEQ @Instant
	JSH PRG_GFXEngine, _PrintText
	JMP UpdatePRG

@Instant:
	; read the status
	LDA PPUSTATUS
	; update address
	LDA cNametableAddress + 1
	STA PPUADDR
	LDA cNametableAddress
	STA PPUADDR
@Loop:
	; parse until a command is read
	LDA (zCurrentTextAddress), Y
	BMI @Command
	STA PPUDATA
	INC zCurrentTextAddress
	BNE @Loop
	INC zCurrentTextAddress + 1
	BNE @Loop
@Command:
	STA zCurrentTextByte
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
	; do some cleanup
	LDA #0
	STA zTextOffset
	STA zTextOffset + 1
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

FadePalettes:
; fade in and fade out the palettes on screen
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
	BEQ @Act
	; dec timer if we got here
	DEC zPalFade
	RTS
@Act:
	; zPalFadePlacement is 2-bit (0-3)
	LDA zPalFadePlacement
	BEQ @Final
	LDY #2
@AppLoop:
	JSR @Apply
	DEY
	BPL @AppLoop
	; cleanup
	DEC zPalFadePlacement
	LDA zPalFadeSpeed
	STA zPalFade
	RTS

@Apply:
	LDA zPals, Y
	AND #COLOR_INDEX
	STA zPals + 1, Y
	LDA zPals + 4, Y
	STA zPals + 5, Y
	LDA zPals + 8, Y
	STA zPals + 9, Y
	LDA zPals + 12, Y
	STA zPals + 13, Y
	RTS

@Final:
	; clear fade direction flag (we're fading in now)
	LDA zPalFadeSpeed
	STA zPalFade
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
	BEQ @InAct
	; dec timer if we got here
	DEC zPalFade
	RTS
@InAct:
	; reset counter
	LDA zPalFadeSpeed
	STA zPalFade
	; choose what to do
	LDA zPalFadePlacement
	AND #PALETTE_FADE_PLACEMENT_MASK
	TAY
	BEQ @Zero
	DEY
	BEQ @One
	DEY
	BEQ @Two
	; we're done
	; do cleanup
	; reset placement byte
	LDA #PALETTE_FADE_PLACEMENT_MASK
	STA zPalFadePlacement
	LDA zPals
	RSB PAL_FADE_F
	STA zPals
	RTS

@Zero:
	INC zPalFadePlacement
	INY
	LDA iCurrentPals, Y
	STA zPals, Y
	STA zPals + 1, Y
	STA zPals + 2, Y
	LDA iCurrentPals + 4, Y
	STA zPals + 4, Y
	STA zPals + 5, Y
	STA zPals + 6, Y
	LDA iCurrentPals + 8, Y
	STA zPals + 8, Y
	STA zPals + 9, Y
	STA zPals + 10, Y
	LDA iCurrentPals + 12, Y
	STA zPals + 12, Y
	STA zPals + 13, Y
	STA zPals + 14, Y
	RTS

@One:
	INC zPalFadePlacement
	LDY zPalFadePlacement
	LDA iCurrentPals, Y
	STA zPals, Y
	STA zPals + 1, Y
	LDA iCurrentPals + 4, Y
	STA zPals + 4, Y
	STA zPals + 5, Y
	LDA iCurrentPals + 8, Y
	STA zPals + 8, Y
	STA zPals + 9, Y
	LDA iCurrentPals + 12, Y
	STA zPals + 12, Y
	STA zPals + 13, Y
	RTS

@Two:
	INC zPalFadePlacement
	LDY zPalFadePlacement
	LDA iCurrentPals, Y
	STA zPals, Y
	LDA iCurrentPals + 4, Y
	STA zPals + 4, Y
	LDA iCurrentPals + 8, Y
	STA zPals + 8, Y
	LDA iCurrentPals + 12, Y
	STA zPals + 12, Y
	RTS

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
	LDA PPUSTATUS
	; are we pointing to PRG?
	LDA zCurrentTileAddress + 1
	BPL @Quit ; PRG never branches
	; apply background address
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
; increment tilemap
	INC zCurrentTileAddress
	BNE @Dec
	INC zCurrentTileAddress + 1
@Dec:
; decrement offset
	LDA zTileOffset + 1
	BEQ @Done
	DEC zTileOffset + 1
@Done:
	DEC zTileOffset
; compound bitfields to return the state of zero
; no bits active, zero flag is set
	LDA zTileOffset
	ORA zTileOffset + 1
	STX PPUDATA
	BNE @Loop
@Quit:
	STY PPUADDR
	STY PPUADDR
	RTS

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
