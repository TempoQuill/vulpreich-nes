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
	; set up address
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR ; happens to be the empty tile we need
	LDY #>NAMETABLE_AREA
	LDX #<NAMETABLE_AREA
	; write for $400 bytes
@Loop:
	DEX
	STA PPUDATA
	BNE @Loop
	DEY
	BPL @Loop
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
	LDY cNameLength
	INY
	LDA #<iStringBuffer
	STA zAuxAddresses + 2
	STA cCurrentRAMAddress
	LDA #>iStringBuffer
	STA zAuxAddresses + 3
	STA cCurrentRAMAddress + 1
	JMP CopyBytes

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
