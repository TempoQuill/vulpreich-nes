;
; +-----------------+
; |Otis' object data|
; +-----------------+
;
OtisFrames_0_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $a0, 2
	nesst_meta   8,  0, $90, 2
	nesst_meta   8, 16, $a2, 2
	nesst_meta  16,  0, $92, 2
	nesst_meta  16, 16, $a4, 2
	nesst_meta  24,  0, $94, 2
	nesst_meta  24, 16, $a6, 2

OtisFrames_1_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $a8, 2
	nesst_meta   8,  0, $96, 2
	nesst_meta   8, 16, $aa, 2
	nesst_meta  16,  0, $92, 2
	nesst_meta  16, 16, $ac, 2
	nesst_meta  24,  0, $94, 2
	nesst_meta  24, 16, $ae, 2

OtisFrames_2_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $b0, 2
	nesst_meta   8,  0, $98, 2
	nesst_meta   8, 16, $b2, 2
	nesst_meta  16,  0, $92, 2
	nesst_meta  16, 16, $b4, 2
	nesst_meta  24,  0, $94, 2
	nesst_meta  24, 16, $b6, 2

OtisFrames_3_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $b8, 2
	nesst_meta   8,  0, $9a, 2
	nesst_meta   8, 16, $ba, 2
	nesst_meta  16,  0, $9c, 2
	nesst_meta  16, 16, $bc, 2
	nesst_meta  24,  0, $9e, 2
	nesst_meta  24, 16, $be, 2

OtisFrames_4_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $c4, 2
	nesst_meta   8,  0, $c0, 2
	nesst_meta   8, 16, $c6, 2
	nesst_meta  16,  0, $92, 2
	nesst_meta  16, 16, $c8, 2
	nesst_meta  24,  0, $94, 2
	nesst_meta  24, 16, $ca, 2

OtisFrames_5_data:

	nesst_meta   0,  0, $8e, 2
	nesst_meta   0, 16, $cc, 2
	nesst_meta   8,  0, $c2, 2
	nesst_meta   8, 16, $ce, 2
	nesst_meta  16,  0, $92, 2
	nesst_meta  16, 16, $d0, 2
	nesst_meta  24,  0, $94, 2
	nesst_meta  24, 16, $d2, 2

OtisFrames_pointersLO:

	.dl OtisFrames_0_data
	.dl OtisFrames_1_data
	.dl OtisFrames_2_data
	.dl OtisFrames_3_data
	.dl OtisFrames_4_data
	.dl OtisFrames_5_data

OtisFrames_pointersHI:

	.dh OtisFrames_0_data
	.dh OtisFrames_1_data
	.dh OtisFrames_2_data
	.dh OtisFrames_3_data
	.dh OtisFrames_4_data
	.dh OtisFrames_5_data

OtisFrames_IndexSequence:
	.db 5, 4, 3, 2, 1, 0
OtisFrames_IndexSequence_LOOP:
OtisFrames_IndexSequence_START:

OtisFrames_Movement:
	.db 4, 4, 4, 4, 4, 4
OtisFrames_Movement_LOOP:
OtisFrames_Movement_START:
