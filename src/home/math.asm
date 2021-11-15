Purchase:
; Subract current price from balance
; convert to decimal for display purposes
; final balance = $(Y)(X)(A)
	SEC
	LDX #0
	STX BackupX ; decimal placeholder
	LDA CurrentCardBalance
	SBC CurrentPrice
	STA CurrentCardBalance
	LDA CurrentCardBalance + 1
	SBC CurrentPrice + 1
	STA CurrentCardBalance + 1
	TAX
	LDA CurrentCardBalance + 2
	SBC CurrentPrice + 2
	STA CurrentCardBalance + 2
	TAY

	; bcd code
	; clear buffer
	LDA #0
	STA DividerBuffer
	STA DividerBuffer + 1
	STA DividerBuffer + 2
	STA DividerBuffer + 3

	; convert balance to decimal for display
	LDA CurrentCardBalance

@BCDLoop:
	SBC #10
	; c = 0 means CurrentCardBalance rolled over
	BCS @BCDInc

	; dec X in a way that clobbers the carry flag exactly once
	STA BackupA
	TXA
	SBC #0
	TAX
	LDA BackupA
	BCS @BCDInc ; if still clear skip parameter

	; dec Y in a way that clobbers the carry flag exactly once
	STA BackupA
	TYA
	SBC #0
	TAY
	LDA BackupA
	BCC @BCDSubExit ; if still clear branch to subexit

@BCDInc:
	INC DividerBuffer
	BNE @BCDLoop
	INC DividerBuffer + 1
	BNE @BCDLoop
	INC DividerBuffer + 2
	JMP @BCDLoop

@BCDSubExit:
	LDA DividerBuffer + 2
	STA CurrentCardBalance + 2
	LDA DividerBuffer + 1
	STA CurrentCardBalance + 1
	LDA DividerBuffer
	STA CurrentCardBalance

	LDA DividerBuffer + 2
	BNE @BCDLoop
	LDA DividerBuffer + 1
	BNE @BCDLoop
	LDA DividerBuffer
	CMP #10
	BCC @BCDLoop
	LDX BackupX
	STA CurrentCardBalanceBCD, X
	INX
	CPX #7
	BEQ @Done
	JSR @Backup
	JMP @BCDLoop
@Done:
	RTS

@Backup:
	STX BackupX
	TXA
	ASL A
	ADC BackupX
	TAX
	LDA CurrentCardBalance + 2
	STA DecimalPlaceBuffer + 2, X
	LDA CurrentCardBalance + 1
	STA DecimalPlaceBuffer + 1, X
	LDA CurrentCardBalance
	STA DecimalPlaceBuffer, X
	LDA BackupA
	LDX CurrentCardBalance + 1
	RTS
