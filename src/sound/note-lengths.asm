;
; Note Lengths
; ============
;
; These are lookup tables used to determine note lengths (in ticks).
;
; There are a few weird values floating around, but it's generally broken into
; groups of 13 note lengths that correspond to a tempo as follows:
;
; $x0: 1/16 note
; $x1: 1/32 note
; $x2: 1/4 note triplet
; $x3: dotted 1/16 note
; $x4: 1/8 note
; $x5: dotted 1/8 note
; $x6: 1/2 note triplet
; $x7: 1/4 note <> 1/2 note triplet
; $x8: 1/4 note
; $x9: dotted 1/4 note
; $xA: 1/2 note
; $xB: dotted 1/2 note
; $xC: whole note
;

NLT_Title = $64
NLT_Save = $a4

NoteLengthMultipliers:
	.db $0C ; 1/16
	.db $06 ; 1/32
	.db $10 ; 1/4/3
	.db $12 ; 1/16.
	.db $18 ; 1/8
	.db $24 ; 1/8.
	.db $20 ; 1/2/3
	.db $50 ; 1/4 <> 1/2/3
	.db $30 ; 1/4
	.db $48 ; 1/4.
	.db $60 ; 1/2
	.db $90 ; 1/2.
	.db $C0 ; 1
	.db $08 ; 1/8/3
	.db $1E ; 1/8 <> 1/32

;
; Hill Linearity Indeces
; ==========================
;
; The hill channel goes by four linearity ratios that all max out at $7F
;
; $80-$90 - 15/16 RATIO
; The more common of the four, particularly useful for prevalant bass and leads
;
; $A0 - 5/7 RATIO
; Used in the title screen to separate very low notes more obviously
;
; $B0-$E0 - 4/7 RATIO
; Used for staccato
;
; $F0 - HELD NOTES
; Used in tandom with $80-$90
;

Hill15Outta16Lengths:
	.db $00
	.db $03, $07, $0B, $0F, $12, $16, $1A, $1E
	.db $21, $25, $29, $2D, $30, $34, $38, $3C
	.db $3F, $43, $47, $4B, $4E, $52, $56, $5A
	.db $5D, $61, $65, $69, $6C, $70, $74, $78
	.db $7B, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	.db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
	.db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F

Hill5Outta7Lengths:
	.db   0
	.db   2,   5,   8,  11,  14,  17,  20,  22
	.db  25,  28,  31,  34,  37,  50,  42,  45
	.db  48,  51,  54,  57,  60,  62,  65,  68
	.db  71,  74,  77,  80,  82,  85,  88,  91
	.db  94,  97, 100, 102, 105, 108, 111, 114
	.db 117, 120, 122, 125, 127, 127, 127, 127
	.db 127, 127, 127, 127, 127, 127, 127, 127

Hill4Outta7Lengths:
	.db $00
	.db $02, $04, $06, $09, $0B, $0D, $10, $12
	.db $14, $16, $19, $1B, $1D, $20, $22, $24
	.db $26, $29, $2B, $2D, $30, $32, $34, $36
	.db $39, $3B, $3D, $40, $42, $44, $46, $49
	.db $4B, $4D, $50, $52, $54, $56, $59, $5B
	.db $5D, $60, $62, $64, $66, $69, $6B, $6D
	.db $70, $72, $74, $76, $79, $7B, $7D, $7F
