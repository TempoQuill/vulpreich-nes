DMCSamplePitchTable:
;           C    C#   D    D#   E    F    F#   G    G#   A    A#   B
	.db $00, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	.db $0f, $0f, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	.db $0e, $0e, $0e, $0e, $0e, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	.db $0e, $0f, $0a, $00

DMCSamplePointers:
;           C    C#   D    D#   E    F    F#   G    G#   A    A#   B
	.db $7f, $38, $34, $00, $46, $65, $5d, $3d, $50, $23, $34, $44
	.db $16, $00, $2d, $58, $00, $26, $4a, $00, $20, $00, $53, $00
	.db $4f, $18, $3e, $1d, $1a, $5b, $2f, $00, $6c, $2a, $6e, $12
	.db $3e, $1d, $1a, $5b, $2f, $3e, $1d, $1a, $5b, $2f, $00, $6c
	.db $2a, $6e, $12, $62, $71, $62, $72, $73, $7a, $71, $53, $00
	.db $7f, $7f, $7f, $7f

DMCSampleLengths:
;           C    C#   D    D#   E    F    F#   G    G#   A    A#   B
	.db $00, $6a, $64, $5e, $59, $54, $4f, $4b, $46, $42, $3f, $3b
	.db $4f, $b3, $a9, $9f, $96, $8e, $86, $7f, $77, $71, $6a, $65
	.db $5f, $5a, $72, $6b, $65, $60, $5a, $55, $50, $4c, $48, $44
	.db $72, $6b, $65, $60, $5a, $72, $6b, $65, $60, $5a, $55, $50
	.db $4c, $48, $44, $40, $3c, $39, $36, $33, $16, $16, $3a, $46
	.db $07, $09, $09, $00

DPCMSampleBanks:
;           C    C#   D    D#   E    F    F#   G    G#   A    A#   B
	.db $fe, $fa, $fb, $fc, $fc, $fb, $fc, $fd, $fd, $fe, $fe, $fe
	.db $fd, $f7, $f7, $f7, $f8, $f8, $f8, $f9, $f9, $fa, $fa, $fb
	.db $fb, $fc, $f9, $fa, $fb, $f9, $fc, $fd, $f8, $fd, $fa, $fe
	.db $f9, $fa, $fb, $f9, $fc, $f9, $fa, $fb, $f9, $fc, $fd, $f8
	.db $fd, $fa, $fe, $fd, $fc, $fe, $fd, $f9, $fb, $fe, $fe, $fe
	.db $f4, $f4, $f4, $fe
