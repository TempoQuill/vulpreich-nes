; general purpose code:
;  NMI typically only has access to PRG related subs, and not even all of them

ClearWindowData:
	LDA #<cWindowStackPointer
	LDY #>cWindowStackPointer
	JSR @bytefill
	LDA #<cMenuHeader
	LDY #>cMenuHeader
	JSR @bytefill
	LDA #<cMenuDataFlags
	LDY #>cMenuDataFlags
	JSR @bytefill
	LDA #<c2DMenuCursorInitY
	LDY #>c2DMenuCursorInitY
	JSR @bytefill

	LDA #RAM_Scratch
	STA zRAMBank
	STA MMC5_PRGBankSwitch1

	PHA
	LDA #<sWindowStackTop
	LDY #>sWindowStackTop
	STA zAuxAddresses + 6
	STY zAuxAddresses + 7
	PLA
	STD zAuxAddresses + 6
	LDA zAuxAddresses + 6
	STA cWindowStackPointer
	LDA zAuxAddresses + 7
	STA cWindowStackPointer + 1
	RTS

@bytefill:
	STA zAuxAddresses + 6
	STY zAuxAddresses + 7
	LDA #0
	LDY #$10
	JMP ByteFill

UnreferencedFarJump:
; jump to a subroutine according to A:YX
	STA cCurrentROMBank
	STX zBackupX
	PHX
	STY zBackupY
	PHY
	JSR GetWindowIndex
	LDA cCurrentROMBank
	STA zWindow1, X
	STA zCurrentWindow, X
	JMP UpdatePRG

FarCallJump:
; access a subroutine according to A:YX
	; save PRG # for later
	STA cCurrentROMBank
	JSR @Store
	; we're typically not in an NMI here
	JMP SyncToCurrentWindow

@Store:
	; push address to stack
	STY zBackupY
	PHY
	STX zBackupX
	PHX
	; index based on Y
	TYA
	JSR GetWindowIndex
	; grab/store PRG #
	LDA cCurrentROMBank
	STA MMC5_PRGBankSwitch2, X
	STA zCurrentWindow, X
	RTS

FourBytePointers:
; entry  - y
; offset - zTableOffset
	LDA #0
	STA zTableOffset + 1
	TYA
	ASL A
	ROL zTableOffset + 1
	ASL A
	ROL zTableOffset + 1
	STA zTableOffset
	RTS

ThreeBytePointers:
; entry  - y
; offset - zTableOffset
	LDA #0
	STA zTableOffset + 1
	TYA
	ASL A
	STA zTableOffset
	ROL zTableOffset + 1
	TYA
	ADC zTableOffset
	STA zTableOffset
	BCC @Done
	INC zTableOffset + 1
@Done:
	RTS

JumpTable:
; general purpose jumptable
; jumps to addres AY
	STY zBackupY
	LDY zBackupY
	BNE @Normal
	SBC #0
	CLC
@Normal:
	DEY
	ADC zTableOffset
	PHA
	TYA
	ADC zTableOffset + 1
	PHA
	RTS

; y, tile, attr, x
HideSprites:
	LDY #$f8
	LDX #0
	TXA
@Loop:
	CLC
	ADC #$fc
	TAX
	LDA #0
	STA iVirtualOAM + 3, X
	STA iVirtualOAM + 2, X
	STA iVirtualOAM + 1, X
	TYA
	STA iVirtualOAM, X
	TXA
	BNE @Loop
	RTS

ClearOAM:
	LDA #0
	TAX
@Loop:
	DEX
	STA iVirtualOAM, X
	BNE @Loop
	RTS

GetWindowIndex:
; input -  A - $80-$bf
; output - X - PRG window X
	LDX #0
	AND #>WINDOW_MASK
	BEQ @Quit
	INX
@Quit:
	RTS

StoreIndexedBank:
; store bank A into bank window X
; we only come here if we aren't already home
	STA MMC5_PRGBankSwitch2, X
	STA zCurrentWindow, X
	RTS

CopyBytes:
; copy Y bytes from (zAuxAddresses + 6) to (zAuxAddresses + 2)
	INY ; we bail the moment y = 0
	DEY
	BEQ @Quit
@Loop:
	LDA (zAuxAddresses + 6), Y
	STA (zAuxAddresses + 2), Y
	DEY
	BNE @Loop
@Quit:
	RTS

ByteFill:
; fill Y bytes at (zAuxAddresses + 6)
	INY ; we bail the moment y = 0
@Loop:
	DEY
	BEQ @Quit
	STA (zAuxAddresses + 6), Y
	BNE @Loop
@Quit:
	RTS

DelayFrame_s_:
; stop for A frames
	STA zNMITimer
@Halt:
	LDA zNMITimer
	BNE @Halt
	RTS
