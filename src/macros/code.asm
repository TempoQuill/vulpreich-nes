MACRO dba bank, label
	.db bank
	.dw label
ENDM

; push x
MACRO PHX
	TXA
	PHA
ENDM

; push y
MACRO PHY
	TYA
	PHA
ENDM

; pull x
MACRO PLX
	PLA
	TAX
ENDM

; pull y
MACRO PLY
	PLA
	TAY
ENDM

; test single bit
MACRO TSB bit
	AND #1 << bit
ENDM

; set single bit
MACRO SSB bit
	ORA #1 << bit
ENDM

; reset single bit
MACRO RSB bit
	AND #$ff ^ (1 << bit)
ENDM

; jump subroutine home
MACRO JSH bank, memory
	LDA #>memory
	JSR GetWindowIndex
	LDA #bank
	JSR StoreIndexedBank
	JSR memory
ENDM

; jump home
MACRO JPH bank, memory
	LDA #>memory
	JSR GetWindowIndex
	LDA #bank
	STA zWindow1, X
	JSR UpdatePRG
	JMP memory
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

; complement
MACRO CPL mem
	LDA mem
	EOR #$ff
	STA mem
ENDM

; sign byte
MACRO SIB mem
	LDA mem
	EOR #$ff
	ADC #1
	STA mem
ENDM

; sign carry byte
MACRO SCB mem
	LDA mem
	EOR #$ff
	ADC #0
	STA mem
ENDM

; sign word
MACRO SIW mem
	LDA mem + 1
	EOR #$ff
	STA mem + 1
	LDA mem
	EOR #$ff
	ADC #1
	STA mem
ENDM

; sign carry word
MACRO SCW mem
	LDA mem + 1
	EOR #$ff
	STA mem + 1
	LDA mem
	EOR #$ff
	ADC #0
	STA mem
ENDM

; load + decrement
MACRO LDD mem
	LDA mem
	DEC mem
ENDM

; load + increment
MACRO LDI mem
	LDA mem
	INC mem
ENDM

; store + decrement
MACRO STD mem
	STA mem
	DEC mem
ENDM

; store + increment
MACRO STI mem
	STA mem
	INC mem
ENDM
