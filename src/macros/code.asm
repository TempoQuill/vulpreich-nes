MACRO dba bank, label
	.db bank
	.dw label
ENDM

MACRO LTH register
	ASL register
	ASL register
	ASL register
	ASL register
ENDM

MACRO HTL register
	LSR register
	LSR register
	LSR register
	LSR register
ENDM

MACRO REV mem
	LDA mem
	EOR #$ff
	STA mem
ENDM

MACRO LDD mem, register
	IF register = Y
		LDY mem
	ELSEIF register = X
		LDX mem
	ELSE ; A
		LDA mem
	ENDIF
	DEC mem
ENDM

MACRO LDI mem, register
	IF register = Y
		LDY mem
	ELSEIF register = X
		LDX mem
	ELSE ; A
		LDA mem
	ENDIF
	INC mem
ENDM

MACRO STD mem, register
	IF register = Y
		STY mem
	ELSEIF register = X
		STX mem
	ELSE ; A
		STA mem
	ENDIF
	DEC mem
ENDM

MACRO STI mem, register
	IF register = Y
		STY mem
	ELSEIF register = X
		STX mem
	ELSE ; A
		STA mem
	ENDIF
	INC mem
ENDM
