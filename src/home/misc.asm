FarJump:
	STX zBackupX
	TXA
	PHA
	STY zBackupY
	TYA
	PHA
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
	TXA
	PHA
	STY zBackupY
	TYA
	PHA
	JSR GetWindowIndex
	LDA cCurrentROMBank
	JMP StoreIndexedBank

ThreeBytePointers:
	TYA
	ASL A
	STA zTableOffset
	LDA #0
	ADC #0
	STA zTableOffset + 1
	TYA
	ADC zTableOffset
	STA zTableOffset
	LDA #0
	ADC zTableOffset + 1
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
	STY iVirtualOAM, X
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
	AND #$60
	SEC
	BEQ @Quit
@Loop:
	INX
	SBC #$20
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
