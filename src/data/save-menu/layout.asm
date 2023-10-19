SaveMenuLayout:
	; general bg
	.db $22, $c1, $5f, $83
	.db $22, $e1, $5f, $82
	.db $23, $09, $57, $81
	.db $23, $29, $57, $80
	.db $23, $48, $46, $7f
	.db $23, $68, $45, $7e
	.db $23, $87, $59, $7d
	.db $23, $a7, $59, $7e
	.db $23, $4f, $51, $92
	.db $23, $6f, $51, $91
	; bg details
	.db $21, $db, $83 ; June's house
	.db $c1, $c4, $c7

	.db $21, $dc, $85
	.db $c2, $c5, $c8, $ca, $cc

	.db $21, $dd, $84
	.db $c3, $c6, $c9, $cb

	.db $20, $83, $83 ; pointing to save data
	.db $be, $bf, $c0

	.db $21, $c6, $05 ; street lamp
	.db $b8, $b9, $b7, $b7, $b6
	.db $21, $ea, $c7, $b5

	.db $22, $67, $02 ; street details
	.db $ba, $bb

	.db $22, $c3, $08
	.db $9d, $00, $a0, $a1, $a2, $00, $96, $b4

	.db $22, $e2, $08
	.db $9e, $00, $00, $a3, $a4, $a5, $00, $97

	.db $23, $01, $05
	.db $9f, $00, $00, $ce, $cf

	.db $23, $08, $82
	.db $98, $99

	.db $23, $43, $05
	.db $cd, $00, $00, $00, $9a

	.db $23, $61, $07
	.db $a8, $a9, $aa, $00, $00, $00, $9b

	.db $23, $81, $06
	.db $ab, $ac, $ad, $00, $00, $9c

	.db $23, $a1, $01
	.db $cd
	.db $23, $a6, $01
	.db $9b
	.db $22, $75, $04 ; mailbox
	.db $8c, $8d, $8e, $8f
	.db $22, $95, $04
	.db $8a, $90, $90, $8b
	.db $22, $b5, $04
	.db $86, $87, $88, $89
	.db $22, $d6, $c3, $84
	.db $22, $d7, $c3, $85
	.db $23, $36, $08
	.db $bc, $bd, $ae, $af, $b0, $b1, $b2, $b3
	.db $23, $4e, $82 ; sidewalk border
	.db $93, $95
	.db $23, $6d, $01
	.db $94
	; default text
	text $2044, "New game"
	text $2050, "No-save mode"
	text $2084, "Load a pre-existing game"
	text $20ce, "1."
	text $20d6, "2."
	text $20e3, "Name:"
	text $20ef, "------- -------"
	text $2122, "Episodes done:--/27   --/27"
	text $2162, "Event tally:   ---"
	text $21a1, "Locations seen: ---"
	.db $21, $79, $43, "-"
	.db $21, $b9, $43, "-"

SaveMenuLayoutNormalAttributes:
	; attributes
	.db $23, $c0, $48, $00
	.db $23, $c8, $31
	.db $cc, $fa, $0a, $8a, $aa, $aa, $aa, $20
	.db $cc, $ff, $ff, $3f, $aa, $02, $aa, $02
	.db $0f, $0f, $ff, $0f, $0a, $00, $8a, $20
	.db $00, $80, $ec, $00, $00, $50, $18, $22
	.db $f0, $a0, $fc, $f0, $f0, $75, $f1, $f0
	.db $af, $fe, $ff, $bf, $af, $a7, $af, $af
	.db $0a
	.db $23, $f9, $47, $0f
	.db $00

SaveMenuLayout_END:
	.db $00
