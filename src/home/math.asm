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
; Subract current price from balance
; convert to decimal for display purposes
; final balance = $(Y)(X)(A)
	SEC
	LDX #0
	STX zBackupX ; decimal placeholder
	LDA zCurrentCardBalance
	SBC zCurrentPrice
	STA zCurrentCardBalance
	LDA zCurrentCardBalance + 1
	SBC zCurrentPrice + 1
	STA zCurrentCardBalance + 1
	TAX
	LDA zCurrentCardBalance + 2
	SBC zCurrentPrice + 2
	STA zCurrentCardBalance + 2
	TAY

	; bcd code
	; clear buffer
	LDA #0
	STA zDividerBuffer
	STA zDividerBuffer + 1
	STA zDividerBuffer + 2
	STA zDividerBuffer + 3

	; convert balance to decimal for display
	LDA zCurrentCardBalance

@BCDLoop:
	SBC #10
	; c = 0 means zCurrentCardBalance rolled over
	BCS @BCDInc

	; dec X in a way that clobbers the carry flag exactly once
	STA zBackupA
	TXA
	SBC #0
	TAX
	LDA zBackupA
	BCS @BCDInc ; if still clear skip parameter

	; dec Y in a way that clobbers the carry flag exactly once
	STA zBackupA
	TYA
	SBC #0
	TAY
	LDA zBackupA
	BCC @BCDSubExit ; if still clear branch to subexit

@BCDInc:
	INC zDividerBuffer
	BNE @BCDLoop
	INC zDividerBuffer + 1
	BNE @BCDLoop
	INC zDividerBuffer + 2
	JMP @BCDLoop

@BCDSubExit:
	LDA zDividerBuffer + 2
	STA zCurrentCardBalance + 2
	LDA zDividerBuffer + 1
	STA zCurrentCardBalance + 1
	LDA zDividerBuffer
	STA zCurrentCardBalance

	LDA zDividerBuffer + 2
	BNE @BCDLoop
	LDA zDividerBuffer + 1
	BNE @BCDLoop
	LDA zDividerBuffer
	CMP #10
	BCC @BCDLoop
	LDX zBackupX
	STA zCurrentCardBalanceBCD, X
	INX
	CPX #7
	BEQ @Done
	JSR @Backup
	JMP @BCDLoop
@Done:
	RTS

@Backup:
	STX zBackupX
	TXA
	ASL A
	ADC zBackupX
	TAX
	LDA zCurrentCardBalance + 2
	STA zDecimalPlaceBuffer + 2, X
	LDA zCurrentCardBalance + 1
	STA zDecimalPlaceBuffer + 1, X
	LDA zCurrentCardBalance
	STA zDecimalPlaceBuffer, X
	LDA zBackupA
	LDX zCurrentCardBalance + 1
	RTS
