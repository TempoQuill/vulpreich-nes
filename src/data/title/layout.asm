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
	.db $21, $e0, $60, $1b
	.db $22, $00, $60, $0f
	.db $22, $20, $60, $18 ; Otis' Y Coord + $80
	.db $22, $40, $60, $19 ; Iggy's Y Coord + $80
	.db $22, $60, $60, $1a ; June's Y Coord + $80
	.db $21, $b3, $03 ; Crow's Y coord + $80
	.db $10, $11, $12
	.db $21, $d3, $03
	.db $13, $14, $15
	.db $21, $f1, $06
	.db $1c, $00, $16, $17, $00, $1d

	; Attributes
	; ...starring Iggy Reich
	.db $23, $d0, $48, $f0
	; field
	.db $23, $d8, $08
	.db $f0, $f0, $f0, $f0, $b8, $e2, $f0, $f0
	; grass
	.db $23, $e0, $48, $ff
	.db $23, $f0, $08
	; @2025 Tempo Quill
	; free to air/use when sales end
	.db $50, $58, $5a, $5a, $5a, $5a, $50, $50

	text $2166, "_starring Iggy Reich"

	text $228b, "Save Menu"
	text $22cc, "Options"

	text $2327, "@2025 Tempo Quill"
	text $2361, "free to air/use when sales end"
	text_end

BeginningText:
	text $2142, "_inspired by Doug Tennapel&"
	text $218b, "CATSCRATCH_"
	text_end

TitleNTInitData:
	.db $20, $00, $7F, $00
	.db $20, $3F, $7F, $00
	.db $20, $7E, $7F, $00
	.db $20, $BD, $7F, $00
	.db $20, $FC, $7F, $00
	.db $21, $3B, $7F, $00
	.db $21, $7A, $7F, $00
	.db $21, $B9, $7F, $00
	.db $21, $F8, $7F, $00
	.db $22, $37, $7F, $00
	.db $22, $76, $7F, $00
	.db $22, $B5, $7F, $00
	.db $22, $F4, $7F, $00
	.db $23, $33, $7F, $00
	.db $23, $72, $7F, $00
	.db $23, $B1, $4F, $00
	.db $23, $C0, $7F, $00
	.db $23, $FF, $01, $00
TitleNTInitData_END:
	.db $00

TitleJuniorFey:
	text $216b, "_Junior Fey"
	text_end

TitleAndOtisReren:
	text $2169, "_and Otis Reren"
	text_end
