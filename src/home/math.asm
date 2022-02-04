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
