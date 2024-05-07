MACRO collision hor, ver
h = hor << 4
v = ver
IF (hor | ver) > COL_BLOCK_DEFAULT
	ERROR "Offset mapping must fit within a nybble"
ENDIF
	db h | v
ENDM

MACRO col_condition claus, hi, lo
h = hi << COL_JUMP_HI
l = lo << COL_JUMP_LO
IF (hi | lo) > 7
	ERROR "Jump must be an integer < 8"
ENDIF
	db claus | h | l
ENDM
