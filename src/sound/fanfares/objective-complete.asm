ObjectiveComplete_SQ2:
	.db $e0
	note_type 1, 4
	rest
	note_type 5, 8
	note G_, 1
	note_type 5, 4
	rest
	note B_, 1
	note_type 5, 8
	note C_, 2
	note_type 5, 4
	rest
	note C#, 2
	note_type 1, 1
	note C_, 3
	note_type 5, 3
	note D_, 2
	note_type 5, 0
	rest
	note_type 1, 1
	note D_, 3
	note_type 5, 3
	note D_, 1
	note_type 5, 0
	rest
	note_type 1, 1
	note D_, 3
	note_type 5, 3
	note G_, 1
	note_type 5, 10
	rest
	sound_ret

ObjectiveComplete_SQ1:
	.db $e1
	note_type 1, 4
	rest
	.db $e3
	note_type 1, 5
	note D_, 3
	note_type 1, 1
	note B_, 2
	note D_, 3
	note_type 1, 4
	note G_, 3
	note_type 2, 4
	note B_, 3
	note G_, 3
	note_type 1, 4
	note E_, 3
	note C_, 3
	note B_, 2
	.db $ef
	note_type 3, 5
	note A_, 2
	note C_, 3
	.db $eb
	note B_, 2
	note_type 1, 0
	rest
	note_type 1, 9
	rest

ObjectiveComplete_Hill:
	.db $e4
	note_type 1, 13
	note D_, 5
	note G_, 5
	note B_, 5
	.db $eb
	note_type 1, 4
	note D_, 6
	note C_, 6
	note B_, 5
	note_type 1, 1
	note C#, 6
	note_type 1, 3
	note D_, 6
	note_type 1, 4
	note C_, 6
	note B_, 5
	note A_, 5
	note G_, 5
	note_type 1, 5
	note F#, 5
	note_type 1, 1
	note G#, 5
	note_type 1, 14
	note A_, 5
	note_type 1, 5
	note G_, 5
	note_type 1, 0
	rest
	note_type 1, 9
	rest

ObjectiveComplete_Noise:
	note_type 1, 4
	drum_rest
	drum_note P_Hat
	drum_note P_OHat
	drum_note P_Hat
	drum_note P_Hat
	drum_note P_Hat
	drum_note P_OHat
	drum_note P_Hat
	drum_note P_Hat
	note_type 1, 5
	drum_note P_OHat
	drum_note P_OHat
	drum_note P_OHat
	note_type 1, 0
	drum_rest
	note_type 1, 9
	drum_rest

ObjectiveComplete_DPCM:
	note_type 1, 13
	drum_note P_Click
	drum_note P_Click
	drum_note P_Click
	note_type 1, 4
	drum_note P_Conga
	drum_note P_Claves
	drum_note P_Click
	drum_note P_Conga
	drum_note P_Conga
	drum_note P_Claves
	drum_note P_Click
	drum_note P_Conga
	note_type 1, 5
	drum_note P_Click
	drum_note P_Click
	drum_note P_Click
	note_type 1, 0
	drum_rest
	note_type 1, 9
	drum_rest
