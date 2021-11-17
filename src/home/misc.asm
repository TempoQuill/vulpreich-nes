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
@Quit
	RTS

StoreIndexedBank:
	STA CurrentROMBank
	LDA MMC5_PRGBankSwitch2, X
	STA Window1, X
	LDA CurrentROMBank
	STA MMC5_PRGBankSwitch2, X
	RTS

CopyBytes:
; copy Y bytes from (AuxAddresses + 6) to (AuxAddresses + 2)
	LDA (AuxAddresses + 6), Y
	DEY
	STA (AuxAddresses + 2), Y
	BNE CopyBytes
	RTS
