JuneFrames_0_data:

	nesst_meta   0,  0, $61, 1
	nesst_meta   0, 16, $6d, 1
	nesst_meta   8,  0, $63, 1
	nesst_meta   8, 16, $6f, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $71, 1

JuneFrames_1_data:

	nesst_meta   0,  0, $67, 1
	nesst_meta   0, 16, $73, 1
	nesst_meta   8,  0, $63, 1
	nesst_meta   8, 16, $75, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $77, 1

JuneFrames_2_data:

	nesst_meta   0,  0, $61, 1
	nesst_meta   0, 16, $79, 1
	nesst_meta   8,  0, $69, 1
	nesst_meta   8, 16, $7b, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $7d, 1

JuneFrames_3_data:

	nesst_meta   0,  0, $6b, 1
	nesst_meta   0, 16, $7f, 1
	nesst_meta   8,  0, $69, 1
	nesst_meta   8, 16, $81, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $83, 1

JuneFrames_4_data:

	nesst_meta   0,  0, $61, 1
	nesst_meta   0, 16, $6d, 1
	nesst_meta   8,  0, $63, 1
	nesst_meta   8, 16, $85, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $87, 1

JuneFrames_5_data:

	nesst_meta   0,  0, $67, 1
	nesst_meta   0, 16, $95, 1
	nesst_meta   8,  0, $89, 1
	nesst_meta   8, 16, $97, 1
	nesst_meta  16,  0, $8b, 1
	nesst_meta  16, 16, $99, 1

JuneFrames_6_data:

	nesst_meta   0,  0, $67, 1
	nesst_meta   0, 16, $95, 1
	nesst_meta   8,  0, $8d, 1
	nesst_meta   8, 16, $9b, 1
	nesst_meta  16,  0, $8f, 1
	nesst_meta  16, 16, $99, 1

JuneFrames_7_data:

	nesst_meta   0,  0, $67, 1
	nesst_meta   0, 16, $95, 1
	nesst_meta   8,  0, $91, 1
	nesst_meta   8, 16, $9b, 1
	nesst_meta  16,  0, $8f, 1
	nesst_meta  16, 16, $99, 1

JuneFrames_8_data:

	nesst_meta   0,  0, $67, 1
	nesst_meta   0, 16, $95, 1
	nesst_meta   8,  0, $93, 1
	nesst_meta   8, 16, $9b, 1
	nesst_meta  16,  0, $8f, 1
	nesst_meta  16, 16, $99, 1

JuneFrames_9_data:

	nesst_meta   0,  0, $61, 1
	nesst_meta   0, 16, $6d, 1
	nesst_meta   8,  0, $63, 1
	nesst_meta   8, 16, $9b, 1
	nesst_meta  16,  0, $65, 1
	nesst_meta  16, 16, $99, 1

JuneFrames_pointersLO:
	.dl JuneFrames_0_data
	.dl JuneFrames_1_data
	.dl JuneFrames_2_data
	.dl JuneFrames_3_data
	.dl JuneFrames_4_data
	.dl JuneFrames_5_data
	.dl JuneFrames_6_data
	.dl JuneFrames_7_data
	.dl JuneFrames_8_data
	.dl JuneFrames_9_data

JuneFrames_pointersHI:
	.dh JuneFrames_0_data
	.dh JuneFrames_1_data
	.dh JuneFrames_2_data
	.dh JuneFrames_3_data
	.dh JuneFrames_4_data
	.dh JuneFrames_5_data
	.dh JuneFrames_6_data
	.dh JuneFrames_7_data
	.dh JuneFrames_8_data
	.dh JuneFrames_9_data

JuneFrames_IndexSequence:
	.db 2, 1, 0, 3
JuneFrames_IndexSequence_LOOP:
	.db 2, 9, 5, 6
	.db 7, 8, 8, 7
	.db 6, 7, 8, 7
	.db 6, 5, 1, 4
	.db 3, 2, 1, 0
	.db 3, 2, 1, 0
JuneFrames_IndexSequence_START:

JuneFrames_Movement
	.db 5, 5, 5, 5
JuneFrames_Movement_LOOP:
	.db 0, 0, 0, 0
	.db 0, 0, 0, 0
	.db 0, 0, 0, 0
	.db 0, 0, 1, 3
	.db 5, 5, 5, 5
	.db 5, 5, 5, 5
JuneFrames_Movement_START: