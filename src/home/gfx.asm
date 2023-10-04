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
	TAY
@AppLoop:
	JSR @Apply
	INY
	CPY #3
	BCC @AppLoop
	; cleanup
	DEC zPalFadePlacement
	LDA zPalFadeSpeed
	STA zPalFade
	RTS

@Final:
	; clear fade direction flag (we're fading in now)
	LDA zPalFadeSpeed
	STA zPalFade
	LDA zPals
	AND #COLOR_INDEX
	LDX #PALETTE_RAM_SPAN
@FinalLoop:
	; clear palettes
	DEX
	STA zPals, X
	BNE @FinalLoop
	; reset placement byte
	LDA #0
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
	LDA #PALETTE_FADE_PLACEMENT_MASK - 1
	STA zPalFadePlacement
	LDA zPals
	RSB PAL_FADE_F
	STA zPals
	RTS

@Zero:
	JMP @DoZero

@One:
	JMP @DoOne

@Two:
	JMP @DoTwo

@Apply:
	LDA zPals, Y
	AND #COLOR_INDEX
	STA zPals + $01, Y
	LDA zPals + $04, Y
	STA zPals + $05, Y
	LDA zPals + $08, Y
	STA zPals + $09, Y
	LDA zPals + $0c, Y
	STA zPals + $0d, Y
	LDA zPals + $10, Y
	STA zPals + $11, Y
	LDA zPals + $14, Y
	STA zPals + $15, Y
	LDA zPals + $18, Y
	STA zPals + $19, Y
	LDA zPals + $1c, Y
	STA zPals + $1d, Y
	RTS

@DoZero:
	INC zPalFadePlacement
	INY
	LDA iCurrentPals, Y
	STA zPals, Y
	STA zPals + $01, Y
	STA zPals + $02, Y
	LDA iCurrentPals + $04, Y
	STA zPals + $04, Y
	STA zPals + $05, Y
	STA zPals + $06, Y
	LDA iCurrentPals + $08, Y
	STA zPals + $08, Y
	STA zPals + $09, Y
	STA zPals + $0a, Y
	LDA iCurrentPals + $0c, Y
	STA zPals + $0c, Y
	STA zPals + $0d, Y
	STA zPals + $0e, Y
	LDA iCurrentPals + $10, Y
	STA zPals + $10, Y
	STA zPals + $11, Y
	STA zPals + $12, Y
	LDA iCurrentPals + $14, Y
	STA zPals + $14, Y
	STA zPals + $15, Y
	STA zPals + $16, Y
	LDA iCurrentPals + $18, Y
	STA zPals + $18, Y
	STA zPals + $19, Y
	STA zPals + $1a, Y
	LDA iCurrentPals + $1c, Y
	STA zPals + $1c, Y
	STA zPals + $1d, Y
	STA zPals + $1e, Y
	RTS

@DoOne:
	INC zPalFadePlacement
	LDY zPalFadePlacement
	LDA iCurrentPals, Y
	STA zPals, Y
	STA zPals + $01, Y
	LDA iCurrentPals + $04, Y
	STA zPals + $04, Y
	STA zPals + $05, Y
	LDA iCurrentPals + $08, Y
	STA zPals + $08, Y
	STA zPals + $09, Y
	LDA iCurrentPals + $0c, Y
	STA zPals + $0c, Y
	STA zPals + $0d, Y
	LDA iCurrentPals + $10, Y
	STA zPals + $10, Y
	STA zPals + $11, Y
	LDA iCurrentPals + $14, Y
	STA zPals + $14, Y
	STA zPals + $15, Y
	LDA iCurrentPals + $18, Y
	STA zPals + $18, Y
	STA zPals + $19, Y
	LDA iCurrentPals + $1c, Y
	STA zPals + $1c, Y
	STA zPals + $1d, Y
	RTS

@DoTwo:
	INC zPalFadePlacement
	LDY zPalFadePlacement
	LDA iCurrentPals, Y
	STA zPals, Y
	LDA iCurrentPals + $04, Y
	STA zPals + $04, Y
	LDA iCurrentPals + $08, Y
	STA zPals + $08, Y
	LDA iCurrentPals + $0c, Y
	STA zPals + $0c, Y
	LDA iCurrentPals + $10, Y
	STA zPals + $10, Y
	LDA iCurrentPals + $14, Y
	STA zPals + $14, Y
	LDA iCurrentPals + $18, Y
	STA zPals + $18, Y
	LDA iCurrentPals + $1c, Y
	STA zPals + $1c, Y
	RTS

InitPals:
; despite not being in an NMI, conventional PRG updates apparently work here
; initialize palettes
	LDA #15
	TAX
	STA zPals, X
@Loop:
	DEX
	STA zPals, X
	BNE @Loop
@Quit:
	RTS

InitNameTable:
; initialize nametables + attributes
	; set up address
	LDA PPUSTATUS
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	LDA #<NAMETABLE_MAP_0
	STA PPUADDR ; happens to be the empty tile we need
	TAX
	; write for $400 bytes
@Loop:
	DEX
	STA PPUDATA
	STA PPUDATA
	STA PPUDATA
	STA PPUDATA
	BPL @Loop
	RTS

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

GetName:
; Return name cCurrentIndex from name list cObjectType in iStringBuffer.
	; preserve registers
	PHP
	PHA
	PHX
	PHY
	JSH PRG_GFXEngine, GetNamePointer
	BEQ @NoName
	; only bank switch if we have an address to pull from
	STA MMC5_PRGBankSwitch2, X

@NoName:
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


;
; This reads from $F0/$F1 to determine where a "buffer" is.
; Basically, a buffer is like this:
;
; PPUADDR  LEN DATA ......
; $20 $04  $03 $E9 $F0 $FB
; $25 $5F  $4F $FB
; $21 $82  $84 $00 $01 $02 $03
; $00
;
; PPUADDR is two bytes (hi,lo) for the address to send to PPUADDR.
; LEN is the length, with the following two bitmasks:
;
;  - $80: Set the "draw vertically" option
;  - $40: Use ONE tile instead of a string
;
; DATA is either (LEN) bytes or one byte.
;
; After (LEN) bytes have been written, the buffer pointer
; is incremented to (LEN+2) and the function restarts.
; A byte of $00 terminates execution and returns.
;
; There is a similar function, `UpdatePPUFromBufferNMI`,
; that is called during NMI, but unlike this one,
; that one does NOT use bitmasks, nor increment the pointer.
;
UpdatePPUFromBufferWithOptions:
	; First, check if we have anything to send to the PPU
	LDY #$00
	LDA (zPPUDataBufferPointer), Y
	; If the first byte at the buffer address is #$00, we have nothing. We're done here!
	BEQ @Quit

	; Clear address latch
	LDX PPUSTATUS
	; Set the PPU address to the
	; address from the PPU buffer
	STA PPUADDR
	INY
	LDA (zPPUDataBufferPointer), Y
	STA PPUADDR
	INY
	LDA (zPPUDataBufferPointer), Y ; Data segment length byte...
	ASL A
	PHA
	; Enable NMI + Vertical increment + whatever else was already set...
	LDA zPPUCtrlMirror
	ORA #PPUCtrl_Base2000 | PPUCtrl_WriteVertical | PPUCtrl_Sprite0000 | PPUCtrl_Background0000 | PPUCtrl_SpriteSize8x8 | PPUCtrl_NMIEnabled
	; ...but only if $80 was set in the length byte. Otherwise, turn vertical incrementing back off.
	BCS @EnableVerticalIncrement

	AND #PPUCtrl_Base2C00 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite1000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled | $40

@EnableVerticalIncrement:
	STA PPUCTRL
	PLA
	; Check if the second bit ($40) in the length has been set
	ASL A
	; If not, we are copying a string of data
	BCC @CopyStringOfTiles

	; Length (A) is now (A << 2).
	; OR in #$02 now if we are copying a single tile;
	; This will be rotated out into register C momentarily
	ORA #$02
	INY

@CopyStringOfTiles:
	; Restore the data length.
	; A = (Length & #$3F)
	LSR A

	; This moves the second bit (used above to signal
	; "one tile mode") into the Carry register
	LSR A
	TAX ; Copy the length into register X

@CopyLoop:
	; If Carry is set (from above), we're only copying one tile.
	; Do not increment Y to advance copying index
	BCS @CopySingleTileSkip

	INY

@CopySingleTileSkip:
	LDA (zPPUDataBufferPointer), Y ; Load data from buffer...
	STA PPUDATA ; ...store it to the PPU.
	DEX ; Decrease remaining length.
	BNE @CopyLoop ; Are we done? If no, copy more stuff

	INY ; Y contains the amount of copied data now
	TYA ; ...and now A does
	CLC ; Clear carry bit (from earlier)
	ADC zPPUDataBufferPointer ; Add the length to the PPU data buffer
	STA zPPUDataBufferPointer
	LDA zPPUDataBufferPointer + 1
	; If the length overflowed (carry set),
	; add that to the hi byte of the pointer
	ADC #$00
	STA zPPUDataBufferPointer + 1
	; Start the cycle over again.
	; (If the PPU buffer points to a 0, it will terminate after this jump)
	JMP UpdatePPUFromBufferWithOptions

@Quit:
	RTS

; Decides if next frame is on
; Frames:
;	Odd	Even
; Start	0	0
; 1	1	4
; 2	0	3
; 3	ff	2
; 4	ff	1
; 5	ff	0
; Output: C
; 0 = On
; 1 = Off
UpdateFilmTimers:
	LDA zFilmStandardTimerOdd
	BPL @DecOdd
	DEC zFilmStandardTimerEven
	BPL @Quit
	LDA #1
	STA zFilmStandardTimerOdd
	LDA #4
	STA zFilmStandardTimerEven
@Quit:
	RTS

@DecOdd:
	DEC zFilmStandardTimerEven
	DEC zFilmStandardTimerOdd
	BMI @Quit
	RTS

CheckFilmTimers:
	LDA zFilmStandardTimerOdd
	BEQ @OnFrame
	LDA zFilmStandardTimerEven
@OnFrame:
	RTS
