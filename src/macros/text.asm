MACRO text_end
	.db $50
ENDM

MACRO next text
	.db $51, text
ENDM

MACRO para text
	.db $52, text
ENDM

MACRO line text
	.db $53, text
ENDM

MACRO cont text
	.db $54, text
ENDM

MACRO done
	.db $55
ENDM

MACRO ascii text
	IF text = " "
		.db (text + 20)
	ELSEIF text < "9"
		.db (text - 48)
	ELSE
		.db (text + 31)
	ENDIF
ENDM
