SimpleMultiply:
; multiply zFactorBuffer * a
	TAB
	BEQ @Quit
@Loop:
	CLC
	ADC zFactorBuffer
	DEC zFactorBuffer + 1
	BNE @Loop
@Quit:
	RTS

MMC5Multiply:
; multiplies two 8-bit numbers
; returns number XA
	LDA zFactorBuffer
	LDX zFactorBuffer + 1
	STA MMC5_Multiplier1
	STX MMC5_Multiplier2
	LDA MMC5_Multiplier1
	LDX MMC5_Multiplier2
	RTS

SimpleDivide:
	LDX #0
	STX zDividerBuffer + 1
@Loop:
	SEC
	INC zDividerBuffer + 1
	SBC zDividerBuffer
	BCS @Loop
	DEC zDividerBuffer + 1
	ADC zDividerBuffer
	RTS

Purchase:
	RTS
