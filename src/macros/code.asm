MACRO dba bank, label
	.db bank
	.dw label
ENDM

; jump subroutine far
MACRO JSF bank, memory
	LDA #bank
	LDX #<memory
	LDY #>memory
	JSR FarCall
ENDM

; jump far
MACRO JPF bank, memory
	LDA #bank
	LDX #<memory
	LDY #>memory
	JMP FarCall
ENDM

; low to high nybble
MACRO LTH register
	ASL register
	ASL register
	ASL register
	ASL register
ENDM

; high to low nybble
MACRO HTL register
	LSR register
	LSR register
	LSR register
	LSR register
ENDM

; reverse memory
MACRO REV mem
	LDA mem
	EOR #$ff
	STA mem
ENDM

; load + decrement
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

; load + increment
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

; store + decrement
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

; store + increment
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
