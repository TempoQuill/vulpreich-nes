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

FarJump:
	STX zBackupX
	PHX
	STY zBackupY
	PHY
	JSR GetWindowIndex
	LDA cCurrentROMBank
	STA zWindow1, X
	JMP UpdatePRG

FarCall:
	STA cCurrentROMBank
	JSR @jump
	JMP UpdatePRG

@jump:
	STX zBackupX
	PHX
	STY zBackupY
	PHY
	JSR GetWindowIndex
	LDA cCurrentROMBank
	JMP StoreIndexedBank

FourBytePointers:
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
	ADC zTableOffset
	PHA
	TYA
	ADC zTableOffset + 1
	PHA
	RTS

HideSprites:
	SEC
	LDY #$ff
	LDX #0
@Loop:
	TXA
	SBC #4
	TAX
	TYA
	STA iVirtualOAM, X
	BNE @Loop
	RTS

ClearOAM:
	LDA #0
	LDX #0
@Loop:
	DEX
	STA iVirtualOAM, X
	BNE @Loop
	RTS

GetWindowIndex:
; input -  A - $80-$df
; output - X - PRG window X
	LDX #0
	AND #>WINDOW_MASK
	SEC
	BEQ @Quit
@Loop:
	INX
	SBC #>WINDOW_SIZE
	BNE @Loop
@Quit:
	RTS

StoreIndexedBank:
; store bank A into bank window X
	STA cCurrentROMBank
	LDA MMC5_PRGBankSwitch2, X
	STA zWindow1, X
	LDA cCurrentROMBank
	STA MMC5_PRGBankSwitch2, X
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
	STA zNMIOccurred
@Halt:
	LDA zNMIOccurred
	BNE @Halt
	RTS
