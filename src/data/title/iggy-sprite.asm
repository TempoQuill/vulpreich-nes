;
; +------------------+
; |Iggy's object data|
; +------------------+
;
; Iggy's animation data, and by extension, everyone else's, were exported from
; NES screen tool.  That program gets the byte order wrong, so a macro was
; made to make implementing OAM logic easier by correcting the byte order.
;
; in addition, the title screen OAM logic counts down from a starting point and
; loops in blocks of four.
;

IggyFrames_0_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $00, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $02, 0
	nesst_meta  16,  0, $ff, 0
	nesst_meta  16, 16, $04, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $06, 0

IggyFrames_1_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $08, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $0a, 0
	nesst_meta  16,  0, $ff, 0
	nesst_meta  16, 16, $0c, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $0e, 0

IggyFrames_2_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $1a, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $1c, 0
	nesst_meta  16,  0, $ff, 0
	nesst_meta  16, 16, $1e, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $20, 0

IggyFrames_3_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $22, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $24, 0
	nesst_meta  16,  0, $ff, 0
	nesst_meta  16, 16, $26, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $28, 0

IggyFrames_4_data:

	nesst_meta   0,  0, $10, 0
	nesst_meta   0, 16, $2a, 0
	nesst_meta   8,  0, $12, 0
	nesst_meta   8, 16, $2c, 0
	nesst_meta  16,  0, $14, 0
	nesst_meta  16, 16, $2e, 0
	nesst_meta  24,  0, $16, 0
	nesst_meta  24, 16, $30, 0

IggyFrames_5_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $32, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $34, 0
	nesst_meta  16,  0, $18, 0
	nesst_meta  16, 16, $36, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $38, 0

IggyFrames_6_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $46, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $34, 0
	nesst_meta  16,  0, $18, 0
	nesst_meta  16, 16, $36, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $48, 0

IggyFrames_7_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $4a, 0
	nesst_meta   8,  0, $ff, 0
	nesst_meta   8, 16, $34, 0
	nesst_meta  16,  0, $18, 0
	nesst_meta  16, 16, $4c, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $4e, 0

IggyFrames_8_data:

	nesst_meta   0,  0, $ff, 0
	nesst_meta   0, 16, $50, 0
	nesst_meta   8,  0, $3a, 0
	nesst_meta   8, 16, $52, 0
	nesst_meta  16,  0, $3c, 0
	nesst_meta  16, 16, $54, 0
	nesst_meta  24,  0, $3e, 0
	nesst_meta  24, 16, $ff, 0

IggyFrames_9_data:

	nesst_meta   0,  0, $ff, OAM_REV_X
	nesst_meta   0, 16, $ff, OAM_REV_X
	nesst_meta   8,  0, $44, OAM_REV_X
	nesst_meta   8, 16, $58, OAM_REV_X
	nesst_meta  16,  0, $42, OAM_REV_X
	nesst_meta  16, 16, $56, OAM_REV_X
	nesst_meta  24,  0, $40, OAM_REV_X
	nesst_meta  24, 16, $ff, OAM_REV_X

IggyFrames_10_data:

	nesst_meta   0,  0, $60, OAM_REV_X
	nesst_meta   0, 16, $76, OAM_REV_X
	nesst_meta   8,  0, $5e, OAM_REV_X
	nesst_meta   8, 16, $74, OAM_REV_X
	nesst_meta  16,  0, $5c, OAM_REV_X
	nesst_meta  16, 16, $72, OAM_REV_X
	nesst_meta  24,  0, $5a, OAM_REV_X
	nesst_meta  24, 16, $70, OAM_REV_X

IggyFrames_11_data:

	nesst_meta   0,  0, $66, OAM_REV_X
	nesst_meta   0, 16, $7c, OAM_REV_X
	nesst_meta   8,  0, $5e, OAM_REV_X
	nesst_meta   8, 16, $7a, OAM_REV_X
	nesst_meta  16,  0, $64, OAM_REV_X
	nesst_meta  16, 16, $78, OAM_REV_X
	nesst_meta  24,  0, $62, OAM_REV_X
	nesst_meta  24, 16, $70, OAM_REV_X

IggyFrames_12_data:

	nesst_meta   0,  0, $60, OAM_REV_X
	nesst_meta   0, 16, $76, OAM_REV_X
	nesst_meta   8,  0, $5e, OAM_REV_X
	nesst_meta   8, 16, $74, OAM_REV_X
	nesst_meta  16,  0, $6a, OAM_REV_X
	nesst_meta  16, 16, $72, OAM_REV_X
	nesst_meta  24,  0, $68, OAM_REV_X
	nesst_meta  24, 16, $7e, OAM_REV_X

IggyFrames_13_data:

	nesst_meta   0,  0, $60, OAM_REV_X
	nesst_meta   0, 16, $76, OAM_REV_X
	nesst_meta   8,  0, $5e, OAM_REV_X
	nesst_meta   8, 16, $7a, OAM_REV_X
	nesst_meta  16,  0, $6e, OAM_REV_X
	nesst_meta  16, 16, $78, OAM_REV_X
	nesst_meta  24,  0, $6c, OAM_REV_X
	nesst_meta  24, 16, $80, OAM_REV_X

IggyFrames_14_data:

	nesst_meta   0,  0, $84, OAM_REV_X
	nesst_meta   0, 16, $8c, OAM_REV_X
	nesst_meta   8,  0, $82, OAM_REV_X
	nesst_meta   8, 16, $74, OAM_REV_X
	nesst_meta  16,  0, $5c, OAM_REV_X
	nesst_meta  16, 16, $72, OAM_REV_X
	nesst_meta  24,  0, $5a, OAM_REV_X
	nesst_meta  24, 16, $70, OAM_REV_X

IggyFrames_15_data:

	nesst_meta   0,  0, $66, OAM_REV_X
	nesst_meta   0, 16, $7c, OAM_REV_X
	nesst_meta   8,  0, $5e, OAM_REV_X
	nesst_meta   8, 16, $7a, OAM_REV_X
	nesst_meta  16,  0, $6a, OAM_REV_X
	nesst_meta  16, 16, $78, OAM_REV_X
	nesst_meta  24,  0, $68, OAM_REV_X
	nesst_meta  24, 16, $7e, OAM_REV_X

IggyFrames_16_data:

	nesst_meta   0,  0, $84, OAM_REV_X
	nesst_meta   0, 16, $8c, OAM_REV_X
	nesst_meta   8,  0, $82, OAM_REV_X
	nesst_meta   8, 16, $74, OAM_REV_X
	nesst_meta  16,  0, $6e, OAM_REV_X
	nesst_meta  16, 16, $72, OAM_REV_X
	nesst_meta  24,  0, $6c, OAM_REV_X
	nesst_meta  24, 16, $80, OAM_REV_X

IggyFrames_17_data:

	nesst_meta   0,  0, $66, OAM_REV_X
	nesst_meta   0, 16, $7c, OAM_REV_X
	nesst_meta   8,  0, $88, OAM_REV_X
	nesst_meta   8, 16, $7a, OAM_REV_X
	nesst_meta  16,  0, $64, OAM_REV_X
	nesst_meta  16, 16, $78, OAM_REV_X
	nesst_meta  24,  0, $62, OAM_REV_X
	nesst_meta  24, 16, $70, OAM_REV_X

IggyFrames_18_data:

	nesst_meta   0,  0, $3e, OAM_REV_X
	nesst_meta   0, 16, $ff, OAM_REV_X
	nesst_meta   8,  0, $3c, OAM_REV_X
	nesst_meta   8, 16, $54, OAM_REV_X
	nesst_meta  16,  0, $3a, OAM_REV_X
	nesst_meta  16, 16, $52, OAM_REV_X
	nesst_meta  24,  0, $ff, OAM_REV_X
	nesst_meta  24, 16, $50, OAM_REV_X

IggyFrames_19_data:

	nesst_meta   0,  0, $40, 0
	nesst_meta   0, 16, $ff, 0
	nesst_meta   8,  0, $42, 0
	nesst_meta   8, 16, $56, 0
	nesst_meta  16,  0, $44, 0
	nesst_meta  16, 16, $58, 0
	nesst_meta  24,  0, $ff, 0
	nesst_meta  24, 16, $ff, 0

IggyFrames_20_data:

	nesst_meta   0,  0, $ff, OAM_REV_X
	nesst_meta   0, 16, $06, OAM_REV_X
	nesst_meta   8,  0, $ff, OAM_REV_X
	nesst_meta   8, 16, $04, OAM_REV_X
	nesst_meta  16,  0, $ff, OAM_REV_X
	nesst_meta  16, 16, $02, OAM_REV_X
	nesst_meta  24,  0, $ff, OAM_REV_X
	nesst_meta  24, 16, $00, OAM_REV_X

IggyFrames_21_data:

	nesst_meta   0,  0, $ff, OAM_REV_X
	nesst_meta   0, 16, $0e, OAM_REV_X
	nesst_meta   8,  0, $ff, OAM_REV_X
	nesst_meta   8, 16, $0c, OAM_REV_X
	nesst_meta  16,  0, $ff, OAM_REV_X
	nesst_meta  16, 16, $0a, OAM_REV_X
	nesst_meta  24,  0, $ff, OAM_REV_X
	nesst_meta  24, 16, $08, OAM_REV_X

IggyFrames_22_data:

	nesst_meta   0,  0, $ff, OAM_REV_X
	nesst_meta   0, 16, $20, OAM_REV_X
	nesst_meta   8,  0, $ff, OAM_REV_X
	nesst_meta   8, 16, $1e, OAM_REV_X
	nesst_meta  16,  0, $ff, OAM_REV_X
	nesst_meta  16, 16, $1c, OAM_REV_X
	nesst_meta  24,  0, $ff, OAM_REV_X
	nesst_meta  24, 16, $1a, OAM_REV_X

IggyFrames_23_data:

	nesst_meta   0,  0, $ff, OAM_REV_X
	nesst_meta   0, 16, $28, OAM_REV_X
	nesst_meta   8,  0, $ff, OAM_REV_X
	nesst_meta   8, 16, $26, OAM_REV_X
	nesst_meta  16,  0, $ff, OAM_REV_X
	nesst_meta  16, 16, $24, OAM_REV_X
	nesst_meta  24,  0, $ff, OAM_REV_X
	nesst_meta  24, 16, $22, OAM_REV_X
IggyFrames_pointersLO:

	.dl IggyFrames_0_data
	.dl IggyFrames_1_data
	.dl IggyFrames_2_data
	.dl IggyFrames_3_data
	.dl IggyFrames_4_data
	.dl IggyFrames_5_data
	.dl IggyFrames_6_data
	.dl IggyFrames_7_data
	.dl IggyFrames_8_data
	.dl IggyFrames_9_data
	.dl IggyFrames_10_data
	.dl IggyFrames_11_data
	.dl IggyFrames_12_data
	.dl IggyFrames_13_data
	.dl IggyFrames_14_data
	.dl IggyFrames_15_data
	.dl IggyFrames_16_data
	.dl IggyFrames_17_data
	.dl IggyFrames_18_data
	.dl IggyFrames_19_data
	.dl IggyFrames_20_data
	.dl IggyFrames_21_data
	.dl IggyFrames_22_data
	.dl IggyFrames_23_data

IggyFrames_pointersHI:

	.dh IggyFrames_0_data
	.dh IggyFrames_1_data
	.dh IggyFrames_2_data
	.dh IggyFrames_3_data
	.dh IggyFrames_4_data
	.dh IggyFrames_5_data
	.dh IggyFrames_6_data
	.dh IggyFrames_7_data
	.dh IggyFrames_8_data
	.dh IggyFrames_9_data
	.dh IggyFrames_10_data
	.dh IggyFrames_11_data
	.dh IggyFrames_12_data
	.dh IggyFrames_13_data
	.dh IggyFrames_14_data
	.dh IggyFrames_15_data
	.dh IggyFrames_16_data
	.dh IggyFrames_17_data
	.dh IggyFrames_18_data
	.dh IggyFrames_19_data
	.dh IggyFrames_20_data
	.dh IggyFrames_21_data
	.dh IggyFrames_22_data
	.dh IggyFrames_23_data

IggyFrames_IndexSequence:
	.db 1,  0,  3,  2
IggyFrames_IndexSequence_LOOP:
	.db 1,  0,  3,  2
	.db 19, 18, 17, 14
	.db 16, 15, 11, 14
	.db 13, 12, 11, 10
	.db 13, 12, 11, 10
	.db 13, 12, 11, 10
	.db 9,  8,  7,  6
	.db 7,  6,  7,  6
	.db 7,  6,  5,  4
	.db 3,  2,  1,  0
	.db 3,  2,  1,  0
	.db 3,  2,  1,  0
	.db 3,  2,  1,  0
IggyFrames_IndexSequence_START:

IggyFrames_Movement:
	.db 6,  6,  6,  6
IggyFrames_Movement_LOOP:
	.db 6,  6,  6,  3
	.db 0,  0,  0,  0
	.db 0,  0,  0,  0
	.db 0,  0,  0,  0
	.db 0,  0,  0,  0
	.db 0,  0,  0,  0
	.db 0,  0,  1,  1
	.db 1,  1,  2,  3
	.db 4,  5,  5,  6
	.db 6,  6,  6,  6
	.db 6,  6,  6,  6
	.db 6,  6,  6,  6
	.db 6,  6,  6,  6
IggyFrames_Movement_START:

IggyFrames_LeftRunningCycle:
	.db 23, 22, 21, 20
IggyFrames_LeftRunningCycle_LOOP::
IggyFrames_LeftRunningCycle_START:

IggyFrames_LeftMovement:
	.db $fb, $fb, $fb, $fb
IggyFrames_LeftMovement_LOOP:
IggyFrames_LeftMovement_START:
