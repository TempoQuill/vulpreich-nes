; Collision index for Iggy's Room
; Tied to non-ASCII tiles from $7d-$1f, 0 goes unused
; Collision is handled by pixel offsets on a per tile basis
; Runs on two modes:
;	exclusive - limited to stay in both boundaries
;	inclusive - can stay in horizontal or vertical boundaries
; If tile is granted unlimited access in either native dimension,
; collision is automatically inclusive
; If the jump flag is set, the nybble chosen sets the vertical pixel offset for
; each tile in the condition index
IggysRoomCollisionIndex:
	db COL_BLOCK_ALL		; $7d
	db COL_NO_LIMITS		; $7e
	db COL_NO_LIMITS		; $7f
	db COL_BLOCK_ALL		; $80
	db COL_BLOCK_ALL		; $81
	db COL_BLOCK_ALL		; $82
	db COL_BLOCK_ALL		; $83
	db COL_BLOCK_ALL		; $84
	db COL_BLOCK_ALL		; $85
	db COL_BLOCK_ALL		; $86
	db COL_BLOCK_ALL		; $87
	db COL_BLOCK_ALL		; $88
	db COL_BLOCK_ALL		; $89
	db COL_BLOCK_ALL		; $8a
	db COL_BLOCK_ALL		; $8b
	db COL_BLOCK_ALL		; $8c
	db COL_BLOCK_ALL		; $8d
	db COL_BLOCK_ALL		; $8e
	db COL_BLOCK_ALL		; $8f
	db COL_BLOCK_ALL		; $90
	db COL_BLOCK_ALL		; $91
	db COL_BLOCK_ALL		; $92
	db COL_BLOCK_ALL		; $93
	db COL_BLOCK_ALL		; $94
	db COL_BLOCK_ALL		; $95
	db COL_BLOCK_ALL		; $96
	db COL_BLOCK_ALL		; $97
	db COL_BLOCK_ALL		; $98
	db COL_BLOCK_ALL		; $99
	db COL_BLOCK_ALL		; $9a
	db COL_BLOCK_ALL		; $9b
	db COL_BLOCK_ALL		; $9c
	db COL_BLOCK_ALL		; $9d
	db COL_BLOCK_ALL		; $9e
	db COL_BLOCK_ALL		; $9f
	db COL_BLOCK_ALL		; $a0
	db COL_BLOCK_ALL		; $a1
	db COL_BLOCK_ALL		; $a2
	db COL_BLOCK_ALL		; $a3
	db COL_BLOCK_ALL		; $a4
	db COL_BLOCK_ALL		; $a5
	db COL_BLOCK_ALL		; $a6
	db COL_BLOCK_ALL		; $a7
	db COL_BLOCK_ALL		; $a8
	db COL_BLOCK_ALL		; $a9
	db COL_BLOCK_ALL		; $aa
	db COL_BLOCK_ALL		; $ab
	db COL_BLOCK_ALL		; $ac
	db COL_BLOCK_ALL		; $ad
	db COL_BLOCK_ALL		; $ae
	db COL_BLOCK_ALL		; $af
	db COL_BLOCK_ALL		; $b0
	db COL_BLOCK_ALL		; $b1
	db COL_BLOCK_ALL		; $b2
	db COL_BLOCK_ALL		; $b3
	db COL_BLOCK_ALL		; $b4
	db COL_BLOCK_ALL		; $b5
	db COL_BLOCK_ALL		; $b6
	db COL_BLOCK_ALL		; $b7
	db COL_BLOCK_ALL		; $b8
	db COL_BLOCK_ALL		; $b9
	db COL_BLOCK_ALL		; $ba
	db COL_BLOCK_ALL		; $bb
	db COL_BLOCK_ALL		; $bc
	db COL_BLOCK_ALL		; $bd
	db COL_BLOCK_ALL		; $be
	collision COL_6_7, COL_6_7	; $bf
	db COL_BLOCK_ALL		; $c0
	db COL_BLOCK_ALL		; $c1
	db COL_BLOCK_ALL		; $c2
	db COL_BLOCK_ALL		; $c3
	db COL_BLOCK_ALL		; $c4
	db COL_BLOCK_ALL		; $c5
	db COL_BLOCK_ALL		; $c6
	db COL_BLOCK_ALL		; $c7
	collision COL_4_7, COL_6_7	; $c8
	collision COL_0_7, COL_6_7	; $c9 inclusive
	collision COL_0_3, COL_6_7	; $ca
	db COL_BLOCK_ALL		; $cb
	collision COL_2_7, COL_6_7	; $cc
	collision COL_2_7, COL_2_7	; $cd inclusive
	db COL_BLOCK_ALL		; $ce
	db COL_BLOCK_ALL		; $cf
	db COL_BLOCK_ALL		; $d0
	db COL_BLOCK_ALL		; $d1
	collision COL_4_7, COL_0_7	; $d2 inclusive
	collision COL_0_5, COL_2_7	; $d3
	collision COL_0_1, COL_6_7	; $d4
	collision COL_4_7, COL_0_5	; $d5
	collision COL_0_7, COL_0_5	; $d6 inclusive
	collision COL_0_7, COL_0_5	; $d7 inclusive
	collision COL_0_1, COL_2_5	; $d8
	db COL_NO_LIMITS		; $d9
	db COL_BLOCK_ALL		; $da
	db COL_BLOCK_ALL		; $db
	db COL_BLOCK_ALL		; $dc
	db COL_BLOCK_ALL		; $dd
	collision COL_2_7, COL_0_7	; $de inclusive
	collision COL_0_1, COL_6_7	; $df inclusive
	collision COL_0_7, COL_6_7	; $e0 inclusive
	collision COL_0_7, COL_6_7	; $e1 inclusive
	collision COL_0_7, COL_6_7	; $e2 inclusive
	collision COL_0_7, COL_2_7	; $e3 inclusive
	collision COL_6_7, COL_2_7	; $e4 inclusive
	db COL_BLOCK_ALL		; $e5
	db COL_BLOCK_ALL		; $e6
	db COL_BLOCK_ALL		; $e7
	db COL_BLOCK_ALL		; $e8
	db COL_BLOCK_ALL		; $e9
	db COL_BLOCK_ALL		; $ea
	db COL_BLOCK_ALL		; $eb
	db COL_BLOCK_ALL		; $ec
	db COL_BLOCK_ALL		; $ed
	db COL_BLOCK_ALL		; $ee
	db COL_BLOCK_ALL		; $ef
	db COL_BLOCK_ALL		; $f0
	db COL_BLOCK_ALL		; $f1
	db COL_BLOCK_ALL		; $f2
	db COL_BLOCK_ALL		; $f3
	db COL_BLOCK_ALL		; $f4
	db COL_BLOCK_ALL		; $f5
	db COL_BLOCK_ALL		; $f6
	db COL_BLOCK_ALL		; $f7
	db COL_BLOCK_ALL		; $f8
	db COL_BLOCK_ALL		; $f9
	db COL_BLOCK_ALL		; $fa
	db COL_BLOCK_ALL		; $fb
	db COL_BLOCK_ALL		; $fc
	db COL_BLOCK_ALL		; $fd
	db COL_BLOCK_ALL		; $fe
	db COL_BLOCK_ALL		; $ff
	db COL_BLOCK_ALL		; $00
	db COL_BLOCK_ALL		; $01
	db COL_BLOCK_ALL		; $02
	db COL_BLOCK_ALL		; $03
	db COL_BLOCK_ALL		; $04
	db COL_BLOCK_ALL		; $05
	db COL_BLOCK_ALL		; $06
	db COL_BLOCK_ALL		; $07
	db COL_BLOCK_ALL		; $08
	db COL_BLOCK_ALL		; $09
	db COL_BLOCK_ALL		; $0a
	db COL_BLOCK_ALL		; $0b
	db COL_BLOCK_ALL		; $0c
	db COL_BLOCK_ALL		; $0d
	db COL_BLOCK_ALL		; $0e
	db COL_BLOCK_ALL		; $0f
	db COL_BLOCK_ALL		; $10
	db COL_BLOCK_ALL		; $11
	db COL_BLOCK_ALL		; $12
	db COL_BLOCK_ALL		; $13
	db COL_BLOCK_ALL		; $14
	db COL_BLOCK_ALL		; $15
	db COL_BLOCK_ALL		; $16
	db COL_BLOCK_ALL		; $17
	db COL_BLOCK_ALL		; $18
	db COL_BLOCK_ALL		; $19
	db COL_BLOCK_ALL		; $1a
	db COL_BLOCK_ALL		; $1b
	db COL_BLOCK_ALL		; $1c
	db COL_BLOCK_ALL		; $1d
	db COL_BLOCK_ALL		; $1e
	db COL_BLOCK_ALL		; $1f

IggysRoomCollisionConditions:
	col_condition COL_EXCLUSIVE, 0, 0	; $7d
	col_condition COL_EXCLUSIVE, 0, 0	; $7e
	col_condition COL_EXCLUSIVE, 0, 0	; $7f
	col_condition COL_EXCLUSIVE, 0, 0	; $80
	col_condition COL_EXCLUSIVE, 0, 0	; $81
	col_condition COL_EXCLUSIVE, 0, 0	; $82
	col_condition COL_EXCLUSIVE, 0, 0	; $83
	col_condition COL_EXCLUSIVE, 0, 0	; $84
	col_condition COL_EXCLUSIVE, 0, 0	; $85
	col_condition COL_EXCLUSIVE, 0, 0	; $86
	col_condition COL_EXCLUSIVE, 0, 0	; $87
	col_condition COL_EXCLUSIVE, 0, 0	; $88
	col_condition COL_EXCLUSIVE, 0, 0	; $89
	col_condition COL_EXCLUSIVE, 0, 0	; $8a
	col_condition COL_EXCLUSIVE, 0, 0	; $8b
	col_condition COL_EXCLUSIVE, 0, 0	; $8c
	col_condition COL_EXCLUSIVE, 0, 0	; $8d
	col_condition COL_EXCLUSIVE, 0, 0	; $8e
	col_condition COL_EXCLUSIVE, 0, 0	; $8f
	col_condition COL_EXCLUSIVE, 0, 0	; $90
	col_condition COL_EXCLUSIVE, 0, 0	; $91
	col_condition COL_EXCLUSIVE, 0, 0	; $92
	col_condition COL_EXCLUSIVE, 0, 0	; $93
	col_condition COL_EXCLUSIVE, 0, 0	; $94
	col_condition COL_EXCLUSIVE, 0, 0	; $95
	col_condition COL_EXCLUSIVE, 0, 0	; $96
	col_condition COL_EXCLUSIVE, 0, 0	; $97
	col_condition COL_EXCLUSIVE, 0, 0	; $98
	col_condition COL_EXCLUSIVE, 0, 0	; $99
	col_condition COL_EXCLUSIVE, 0, 0	; $9a
	col_condition COL_EXCLUSIVE, 0, 0	; $9b
	col_condition COL_EXCLUSIVE, 0, 0	; $9c
	col_condition COL_EXCLUSIVE, 0, 0	; $9d
	col_condition COL_EXCLUSIVE, 0, 0	; $9e
	col_condition COL_EXCLUSIVE, 0, 0	; $9f
	col_condition COL_EXCLUSIVE, 0, 0	; $a0
	col_condition COL_EXCLUSIVE, 0, 0	; $a1
	col_condition COL_EXCLUSIVE, 0, 0	; $a2
	col_condition COL_EXCLUSIVE, 0, 0	; $a3
	col_condition COL_EXCLUSIVE, 0, 0	; $a4
	col_condition COL_EXCLUSIVE, 0, 0	; $a5
	col_condition COL_EXCLUSIVE, 0, 0	; $a6
	col_condition COL_EXCLUSIVE, 0, 0	; $a7
	col_condition COL_EXCLUSIVE, 0, 0	; $a8
	col_condition COL_EXCLUSIVE, 0, 0	; $a9
	col_condition COL_EXCLUSIVE, 0, 0	; $aa
	col_condition COL_EXCLUSIVE, 0, 0	; $ab
	col_condition COL_EXCLUSIVE, 0, 0	; $ac
	col_condition COL_EXCLUSIVE, 0, 0	; $ad
	col_condition COL_EXCLUSIVE, 0, 0	; $ae
	col_condition COL_EXCLUSIVE, 0, 0	; $af
	col_condition COL_EXCLUSIVE, 0, 0	; $b0
	col_condition COL_EXCLUSIVE, 0, 0	; $b1
	col_condition COL_EXCLUSIVE, 0, 0	; $b2
	col_condition COL_EXCLUSIVE, 0, 0	; $b3
	col_condition COL_EXCLUSIVE, 0, 0	; $b4
	col_condition COL_EXCLUSIVE, 0, 0	; $b5
	col_condition COL_EXCLUSIVE, 0, 0	; $b6
	col_condition COL_EXCLUSIVE, 0, 0	; $b7
	col_condition COL_EXCLUSIVE, 0, 0	; $b8
	col_condition COL_EXCLUSIVE, 0, 0	; $b9
	col_condition COL_EXCLUSIVE, 0, 0	; $ba
	col_condition COL_EXCLUSIVE, 0, 0	; $bb
	col_condition COL_EXCLUSIVE, 0, 0	; $bc
	col_condition COL_EXCLUSIVE, 0, 0	; $bd
	col_condition COL_EXCLUSIVE, 0, 0	; $be
	col_condition COL_EXCLUSIVE, 0, 0	; $bf
	col_condition COL_EXCLUSIVE, 0, 0	; $c0
	col_condition COL_EXCLUSIVE, 0, 0	; $c1
	col_condition COL_EXCLUSIVE, 0, 0	; $c2
	col_condition COL_EXCLUSIVE, 0, 0	; $c3
	col_condition COL_EXCLUSIVE, 0, 0	; $c4
	col_condition COL_EXCLUSIVE, 0, 0	; $c5
	col_condition COL_EXCLUSIVE, 0, 0	; $c6
	col_condition COL_EXCLUSIVE, 0, 0	; $c7
	col_condition COL_EXCLUSIVE, 0, 0	; $c8
	col_condition COL_INCLUSIVE, 0, 0	; $c9
	col_condition COL_EXCLUSIVE, 0, 0	; $ca
	col_condition COL_EXCLUSIVE, 0, 0	; $cb
	col_condition COL_EXCLUSIVE, 0, 0	; $cc
	col_condition COL_INCLUSIVE, 0, 0	; $cd
	col_condition COL_EXCLUSIVE, 0, 0	; $ce
	col_condition COL_EXCLUSIVE, 0, 0	; $cf
	col_condition COL_EXCLUSIVE, 0, 0	; $d0
	col_condition COL_EXCLUSIVE, 0, 0	; $d1
	col_condition COL_INCLUSIVE, 0, 0	; $d2
	col_condition COL_EXCLUSIVE, 0, 0	; $d3
	col_condition COL_EXCLUSIVE, 0, 0	; $d4
	col_condition COL_JUMP_EXC,  4, 0	; $d5
	col_condition COL_JUMP_INC,  4, 0	; $d6
	col_condition COL_JUMP_INC,  5, 0	; $d7
	col_condition COL_JUMP_EXC,  5, 0	; $d8
	col_condition COL_EXCLUSIVE, 0, 0	; $d9
	col_condition COL_EXCLUSIVE, 0, 0	; $da
	col_condition COL_EXCLUSIVE, 0, 0	; $db
	col_condition COL_EXCLUSIVE, 0, 0	; $dc
	col_condition COL_EXCLUSIVE, 0, 0	; $dd
	col_condition COL_INCLUSIVE, 0, 0	; $de
	col_condition COL_INCLUSIVE, 0, 0	; $df
	col_condition COL_JUMP_INC,  0, 6	; $e0
	col_condition COL_JUMP_INC,  0, 6	; $e1
	col_condition COL_JUMP_INC,  0, 6	; $e2
	col_condition COL_INCLUSIVE, 0, 0	; $e3
	col_condition COL_INCLUSIVE, 0, 0	; $e4
	col_condition COL_EXCLUSIVE, 0, 0	; $e5
	col_condition COL_EXCLUSIVE, 0, 0	; $e6
	col_condition COL_EXCLUSIVE, 0, 0	; $e7
	col_condition COL_EXCLUSIVE, 0, 0	; $e8
	col_condition COL_EXCLUSIVE, 0, 0	; $e9
	col_condition COL_EXCLUSIVE, 0, 0	; $ea
	col_condition COL_EXCLUSIVE, 0, 0	; $eb
	col_condition COL_EXCLUSIVE, 0, 0	; $ec
	col_condition COL_EXCLUSIVE, 0, 0	; $ed
	col_condition COL_EXCLUSIVE, 0, 0	; $ee
	col_condition COL_EXCLUSIVE, 0, 0	; $ef
	col_condition COL_EXCLUSIVE, 0, 0	; $f0
	col_condition COL_EXCLUSIVE, 0, 0	; $f1
	col_condition COL_EXCLUSIVE, 0, 0	; $f2
	col_condition COL_EXCLUSIVE, 0, 0	; $f3
	col_condition COL_EXCLUSIVE, 0, 0	; $f4
	col_condition COL_EXCLUSIVE, 0, 0	; $f5
	col_condition COL_EXCLUSIVE, 0, 0	; $f6
	col_condition COL_EXCLUSIVE, 0, 0	; $f7
	col_condition COL_EXCLUSIVE, 0, 0	; $f8
	col_condition COL_EXCLUSIVE, 0, 0	; $f9
	col_condition COL_EXCLUSIVE, 0, 0	; $fa
	col_condition COL_EXCLUSIVE, 0, 0	; $fb
	col_condition COL_EXCLUSIVE, 0, 0	; $fc
	col_condition COL_EXCLUSIVE, 0, 0	; $fd
	col_condition COL_EXCLUSIVE, 0, 0	; $fe
	col_condition COL_EXCLUSIVE, 0, 0	; $ff
	col_condition COL_EXCLUSIVE, 0, 0	; $00
	col_condition COL_EXCLUSIVE, 0, 0	; $01
	col_condition COL_EXCLUSIVE, 0, 0	; $02
	col_condition COL_EXCLUSIVE, 0, 0	; $03
	col_condition COL_EXCLUSIVE, 0, 0	; $04
	col_condition COL_EXCLUSIVE, 0, 0	; $05
	col_condition COL_EXCLUSIVE, 0, 0	; $06
	col_condition COL_EXCLUSIVE, 0, 0	; $07
	col_condition COL_EXCLUSIVE, 0, 0	; $08
	col_condition COL_EXCLUSIVE, 0, 0	; $09
	col_condition COL_EXCLUSIVE, 0, 0	; $0a
	col_condition COL_EXCLUSIVE, 0, 0	; $0b
	col_condition COL_EXCLUSIVE, 0, 0	; $0c
	col_condition COL_EXCLUSIVE, 0, 0	; $0d
	col_condition COL_EXCLUSIVE, 0, 0	; $0e
	col_condition COL_EXCLUSIVE, 0, 0	; $0f
	col_condition COL_EXCLUSIVE, 0, 0	; $10
	col_condition COL_EXCLUSIVE, 0, 0	; $11
	col_condition COL_EXCLUSIVE, 0, 0	; $12
	col_condition COL_EXCLUSIVE, 0, 0	; $13
	col_condition COL_EXCLUSIVE, 0, 0	; $14
	col_condition COL_EXCLUSIVE, 0, 0	; $15
	col_condition COL_EXCLUSIVE, 0, 0	; $16
	col_condition COL_EXCLUSIVE, 0, 0	; $17
	col_condition COL_EXCLUSIVE, 0, 0	; $18
	col_condition COL_EXCLUSIVE, 0, 0	; $19
	col_condition COL_EXCLUSIVE, 0, 0	; $1a
	col_condition COL_EXCLUSIVE, 0, 0	; $1b
	col_condition COL_EXCLUSIVE, 0, 0	; $1c
	col_condition COL_EXCLUSIVE, 0, 0	; $1d
	col_condition COL_EXCLUSIVE, 0, 0	; $1e
	col_condition COL_EXCLUSIVE, 0, 0	; $1f
