DrumKits:
	.dw Drumkit0
	.dw Drumkit0
	.dw Drumkit0
	.dw Drumkit0
	.dw Drumkit0 ; Iggy
	.dw Drumkit0 ; June
	.dw Drumkit0 ; Otis

Drumkit0:
	.dw Drum0_0
	.dw Drum0_1 ; hi hat
	.dw Drum0_2 ; crash
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0
	.dw Drum0_0

Drum0_0:
	sound_ret

Drum0_1:
	noise_note 0, 1, 8, 0, 3
	noise_note 0, 1, 3, 0, 2
	noise_note 0, 1, 1, 0, 1
	noise_note 0, 1, 0, 0, 0
	sound_ret

Drum0_2:
	noise_note 0, 0, 0, 0, 7
	noise_note 0, 1, 8, 0, 7
	noise_note 0, 1, 9, 0, 7
	noise_note 0, 1, 7, 0, 7
	noise_note 0, 1, 6, 0, 7
	noise_note 0, 1, 5, 0, 7
	noise_note 0, 1, 4, 0, 7
	noise_note 0, 1, 3, 0, 7
	noise_note 0, 1, 2, 0, 7
	noise_note 0, 1, 1, 0, 7
	noise_note 0, 1, 1, 0, 7
	noise_note 0, 1, 1, 0, 7
	noise_note 0, 1, 0, 0, 7
	sound_ret
