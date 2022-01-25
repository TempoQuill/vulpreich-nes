MACRO text_end
	.db $80
ENDM

MACRO next text
	.db $81, text
ENDM

MACRO para text
	.db $82, text
ENDM

MACRO line text
	.db $83, text
ENDM

MACRO cont text
	.db $84, text
ENDM

MACRO done
	.db $85
ENDM
