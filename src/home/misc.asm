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
	LDA (zAuxAddresses + 6), Y
	DEY
	STA (zAuxAddresses + 2), Y
	BNE CopyBytes
	RTS
