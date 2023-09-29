TitleScreenLayout:
	; Tiles
	; logo
	.db $20, $23, $0f
	.db $7d, $7e, $00, $7f, $80, $81, $00, $82
	.db $00, $00, $00, $83, $84, $85, $86
	.db $20, $38, $01, $87
	.db $20, $43, $16
	.db $88, $89, $00, $8a, $8b, $8c, $00, $8d
	.db $00, $00, $00, $8e, $8f, $90, $91, $92
	.db $00, $93, $94, $00, $00, $95
	.db $20, $63, $17
	.db $96, $97, $00, $98, $99, $00, $00, $9a
	.db $9b, $00, $00, $8e, $9c, $9d, $9e, $9f
	.db $00, $a0, $a1, $00, $00, $a2, $a3
	.db $20, $83, $19
	.db $a4, $a5, $a6, $a7, $a8, $00, $a9, $aa
	.db $ab, $ac, $ad, $8e, $ae, $af, $b0, $b1
	.db $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9
	.db $ba
	.db $20, $a3, $19
	.db $bb, $bc, $bd, $be, $bf, $c0, $c1, $c2
	.db $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca
	.db $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2
	.db $d3
	.db $20, $c4, $18
	.db $d4, $d5, $d6, $d7, $d8, $d9, $da, $db
	.db $dc, $dd, $de, $df, $e0, $e1, $e2, $e3
	.db $e4, $e5, $e6, $e7, $e8, $00, $8e, $e9
	.db $20, $e4, $18
	.db $ea, $eb, $ec, $ed, $ee, $ef, $f0, $f1
	.db $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9
	.db $fa, $fb, $fc, $fd, $fe, $00, $ff, $01
	.db $21, $04, $0b
	.db $02, $03, $00, $04, $05, $06, $07, $08
	.db $00, $09, $0a
	.db $21, $28, $04
	.db $0b, $0c, $0d, $0e
	; field
	.db $21, $b3, $03
	.db $10, $11, $12
	.db $21, $d3, $03
	.db $13, $14, $15
	.db $21, $f3, $02
	.db $16, $17
	.db $22, $00, $60, $0f
	.db $22, $20, $60, $18
	.db $22, $40, $60, $19
	.db $22, $60, $60, $1a

	; Attributes
	; ...starring Iggy Reich
	.db $23, $d0, $48, $f0
	; field
	.db $23, $dc, $02
	.db $88, $22
	; grass
	.db $23, $e0, $48, $ff
	.db $23, $f0, $08
	; @2024 Tempo Quill
	; free to air/use when sales end
	.db $50, $58, $5a, $5a, $5a, $5a, $50, $50

	.db $3f, $10, $10
	.db $0f, $17, $10, $30
	.db $0f, $17, $28, $38
	.db $0f, $02, $16, $39
	.db $0f, $0c, $0a, $05

	text $2166, "_starring Iggy Reich"

	text $228d, "Begin"
	text $22cc, "Options"

	text $2327, "@2024 Tempo Quill"
	text $2361, "free to air/use when sales end"
	text_end

BeginningText:
	.db $3f, $10, $50, $0f
	text $2142, "_inspired by Doug Tennapel&"
	text $218b, "CATSCRATCH_"
	text_end

TitldNTInitData:
	.db $20, $00, $60, $00
	.db $20, $20, $60, $00
	.db $20, $40, $60, $00
	.db $20, $60, $60, $00
	.db $20, $80, $60, $00
	.db $20, $a0, $60, $00
	.db $20, $c0, $60, $00
	.db $20, $e0, $60, $00
	.db $21, $00, $60, $00
	.db $21, $20, $60, $00
	.db $21, $40, $60, $00
	.db $21, $60, $60, $00
	.db $21, $80, $60, $00
	.db $21, $a0, $60, $00
	.db $21, $c0, $60, $00
	.db $21, $e0, $60, $00
	.db $22, $00, $60, $00
	.db $22, $20, $60, $00
	.db $22, $40, $60, $00
	.db $22, $60, $60, $00
	.db $22, $80, $60, $00
	.db $22, $a0, $60, $00
	.db $22, $c0, $60, $00
	.db $22, $e0, $60, $00
	.db $23, $00, $60, $00
	.db $23, $20, $60, $00
	.db $23, $40, $60, $00
	.db $23, $60, $60, $00
	.db $23, $80, $60, $00
	.db $23, $a0, $60, $00
	.db $23, $c0, $60, $00
	.db $23, $e0, $60, $00
TitldNTInitData_END:
	.db $00

LyricInitStartingData:
	.db $21, $60, $01, $00
LyricInitStartingData_END:
	.db $00

LyricInstaClear:
	.db $21, $60, $60, $00
	.db $00

Verse1Line1:
	text $2164, "He may look like any pet,"
	text_end

Verse1Line2:
	text $2164, "like he& another number,"
	text_end

Verse1Line3:
	text $2162, "but e<r since his owner fled,"
	text_end

Verse1Line4:
	text $2164, "it& never been the same."
	text_end

Verse1Line5:
	text $2164, "For now,he*l walk about"
	text_end

Verse1Line6:
	text $2161, "and greet his furry neighbors,"
	text_end

Verse1Line7:
	text $2162, "because when he& running out,"
	text_end

Verse1Line8:
	text $2162, "they*l always know his name."
	text_end

PrechorusLine1:
	text $2165, "It& Otis,June and him"
	text_end

PrechorusLine2:
	text $2164, "just venturing together."
	text_end

PrechorusLine3:
	text $2162, "Who knows the mischief that"
	text_end

PrechorusLine4:
	text $2165, "they*l get into today."
	text_end

ChorusLine1:
	text $2169, "Come with Iggy"
	text_end

ChorusLine2:
	text $2168, "and his friends;"
	text_end

ChorusLine3:
	text $2168, "you*l be fawning"
	text_end

ChorusLine4:
	text $2167, "until the very end."
	text_end
