Music_TitleScreen:
	music_header 5, 1, Music_TitleScreen_Pulse1
	music_subheader 2, Music_TitleScreen_Pulse2
	music_subheader 3, Music_TitleScreen_Hill
	music_subheader 4, Music_TitleScreen_Noise
	music_subheader 5, Music_TitleScreen_DPCM

Music_TitleScreen_Pulse1:
	tempo 201
	duty_cycle 1
	note_type 12, 0, 1
	; 1-00
	rest 4
Music_TitleScreen_Pulse1_Mainloop:
	volume_envelope 0, 1
	; 1-01
	sound_call Music_TitleScreen_Measure1_01
	; 1-02
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-03
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-04
	sound_call Music_TitleScreen_Measure1_04
	; 1-05
	sound_call Music_TitleScreen_Measure1_01
	; 1-06
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-07
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-08
	sound_call Music_TitleScreen_Measure1_04
	; 1-09
	sound_call Music_TitleScreen_Measure1_01
	; 1-10
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-11
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-12
	sound_call Music_TitleScreen_Measure1_04
	; 1-13
	sound_call Music_TitleScreen_Measure1_01
	; 1-14
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-15
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-16
	sound_call Music_TitleScreen_Measure1_04
	volume_envelope 0, 15
	; 1-17
	octave 2
	note G#, 16
	; 1-18 - tie
	volume_envelope 0, 1
	; 1-19
	sound_call Music_TitleScreen_Measure1_01
	; 1-20
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-21
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-22
	sound_call Music_TitleScreen_Measure1_04
	; 1-23
	sound_call Music_TitleScreen_Measure1_01
	; 1-24
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-25
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-26
	sound_call Music_TitleScreen_Measure1_04
	; 1-27
	sound_call Music_TitleScreen_Measure1_01
	; 1-28
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-29
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-30
	sound_call Music_TitleScreen_Measure1_04
	; 1-31
	sound_call Music_TitleScreen_Measure1_01
	; 1-32
	transpose 1, 10
	sound_call Music_TitleScreen_Measure1_01
	; 1-33
	sound_call Music_TitleScreen_Measure1_04
	transpose 0, 0
	; 1-34
	sound_call Music_TitleScreen_Measure1_04
	; 1-35
	sound_call Music_TitleScreen_Measure1_35
	; 1-36
	sound_call Music_TitleScreen_Measure1_36
	; 1-37
	sound_call Music_TitleScreen_Measure1_35
	; 1-38
	sound_call Music_TitleScreen_Measure1_36
	; 1-39
	sound_call Music_TitleScreen_Measure1_35
	; 1-40
	sound_call Music_TitleScreen_Measure1_36
	; 1-41
	note C#, 1
	note F#, 1
	note A#, 1
	note F#, 1
	note C#, 1
	note F#, 1
	note A#, 1
	note F#, 1
	; 1-42
	note E_, 1
	note F#, 1
	note B_, 1
	note F#, 1
	note E_, 1
	note F#, 1
	note B_, 1
	note F#, 1
	; 1-43
	note D#, 8
	note_type 3, 1, 5
	; 1-44
	note E_, 15
	rest 1
	note G#, 15
	rest 1
	; 1-45
	note F#, 15
	rest 1
	note D#, 15
	rest 1
	; 1-46
	note C#, 15
	rest 1
	octave 2
	note A_, 15
	rest 1
	note_type 12, 1, 5
	; 1-47
	note B_, 6
	rest 2
	note_type 3, 1, 5
	; 1-48
	octave 3
	note G#, 15
	rest 1
	note E_, 15
	rest 1
	; 1-49
	note D#, 15
	rest 1
	octave 2
	note B_, 11
	rest 1
	note B_, 3
	rest 1
	; 1-50
	note A_, 7
	rest 1
	octave 3
	note C#, 7
	rest 1
	octave 2
	note B_, 7
	rest 1
	note A_, 7
	rest 1
	note_type 12, 1, 5
	; 1-51
	note G#, 6
	rest 2
	sound_jump Music_TitleScreen_Pulse1_Mainloop

Music_TitleScreen_Measure1_01:
	octave 2
	note B_, 1
	octave 3
	note E_, 1
	note G#, 1
	octave 2
	note B_, 1
	octave 3
	note E_, 1
	note G#, 1
	octave 2
	note B_, 1
	octave 3
	note E_, 1
	sound_ret

Music_TitleScreen_Measure1_04:
	note D#, 1
	note F#, 1
	note B_, 1
	note D#, 1
	note F#, 1
	note B_, 1
	note D#, 1
	note F#, 1
	sound_ret

Music_TitleScreen_Measure1_35:
	note C#, 1
	note E_, 1
	note A_, 1
	note E_, 1
	note C#, 1
	note E_, 1
	note A_, 1
	note E_, 1
	sound_ret

Music_TitleScreen_Measure1_36:
	octave 2
	note B_, 1
	octave 3
	note E_, 1
	note G#, 1
	note E_, 1
	octave 2
	note B_, 1
	octave 3
	note E_, 1
	note G#, 1
	note E_, 1
	sound_ret

Music_TitleScreen_Pulse2:
	duty_cycle 3
	note_type 12, 0, 9
	; 2-00
	rest 4
Music_TitleScreen_Loop2_01:
	note_type 12, 0, 9
	; 2-01
	rest 16
	; 2-02 - tie
	; 2-03
	rest 16
	; 2-04 - tie
	; 2-05
	rest 16
	; 2-06 - tie
	; 2-07
	rest 16
	; 2-08 - tie
	vibrato 4, 7, 5
	; 2-09
	sound_call Music_TitleScreen_Measure2_09_12
	; 2-13
	sound_call Music_TitleScreen_Measure2_09_12
	note_type 3, 0, 15
	; 2-17
	rest 1
	octave 2
	note B_, 1
	note_type 12, 0, 15
	octave 3
	note E_, 15
	; 2-18 - tie
	note_type 6, 0, 15
	rest 1
	duty_cycle 2
	vibrato 10, 5, 4
	note_type 3, 1, 10
	; 2-19
	rest 4
	octave 2
	note B_, 3
	rest 1
	note_type 3, 1, 10
	octave 2
	note B_, 7
	rest 1
	octave 3
	note E_, 7
	rest 1
	note E_, 7
	rest 1
	; 2-20
	sound_call Music_TitleScreen_Measure2_20_24
	; 2-25
	note F#, 7
	rest 1
	note G#, 3
	rest 1
	note F#, 7
	rest 1
	note E_, 7
	rest 1
	note_type 6, 1, 10
	note D#, 14
	; 2-26 - tie
	rest 8
	; 2-27 - tie
	note_type 3, 1, 10
	octave 2
	note B_, 7
	rest 1
	octave 3
	note E_, 7
	rest 1
	note E_, 7
	rest 1
	; 2-28
	sound_call Music_TitleScreen_Measure2_20_24
	; 2-33
	note F#, 7
	rest 1
	note G#, 3
	rest 1
	note A_, 7
	rest 1
	note G#, 7
	rest 1
	note A_, 4
	note_type 6, 1, 10
	; 2-34
	note B_, 12
	rest 8
	; 2-35 - tie
	note_type 3, 1, 10
	octave 4
	note C#, 7
	rest 1
	note C#, 7
	rest 1
	octave 3
	note A_, 7
	rest 1
	; 2-36
	note B_, 7
	rest 1
	note A_, 3
	rest 1
	note G#, 12
	rest 4
	note E_, 3
	rest 1
	; 2-37
	note A_, 7
	rest 1
	note G#, 3
	rest 1
	note F#, 7
	rest 1
	note G#, 7
	rest 1
	note G#, 7
	; 2-38 - tie
	rest 1
	note E_, 12
	rest 16
	rest 8
	; 2-39 - tie
	octave 4
	note C#, 7
	rest 1
	note C#, 7
	rest 1
	note D#, 3
	rest 1
	note E_, 7
	; 2-40 - tie
	rest 1
	octave 3
	note B_, 7
	rest 1
	note B_, 12
	rest 4
	note B_, 3
	rest 1
	; 2-41
	note A#, 7
	rest 1
	note A#, 3
	rest 1
	note B_, 7
	rest 1
	octave 4
	note C#, 7
	rest 1
	note_type 12, 1, 10
	octave 3
	note B_, 8
	; 2-42 - tie
	rest 9
	; 2-43 - tie
	note_type 3, 1, 10
	; 2-44
	octave 4
	note C#, 15
	rest 1
	note E_, 15
	rest 1
	; 2-45
	note D#, 15
	rest 1
	octave 3
	note B_, 15
	rest 1
	; 2-46
	note A_, 15
	rest 1
	note F#, 15
	rest 1
	note_type 6, 1, 10
	; 2-47
	note G#, 12
	rest 4
	note_type 3, 1, 10
	; 2-48
	octave 4
	note E_, 15
	rest 1
	note C#, 15
	rest 1
	; 2-49
	octave 3
	note B_, 15
	rest 1
	note G#, 11
	rest 1
	note G#, 3
	rest 1
	; 2-50
	note F#, 7
	rest 1
	note A_, 7
	rest 1
	note G#, 7
	rest 1
	note F#, 7
	rest 1
	note_type 6, 1, 10
	; 2-51
	note E_, 12
	rest 4
	sound_jump Music_TitleScreen_Loop2_01


Music_TitleScreen_Measure2_09_12:
	; 2-09
	octave 2
	note B_, 2
	octave 3
	note E_, 2
	note G#, 2
	note E_, 2
	; 2-10
	octave 2
	note B_, 2
	octave 3
	note E_, 2
	note F#, 2
	note E_, 2
	; 2-11
	note C#, 2
	note E_, 2
	note A_, 2
	note E_, 2
	; 2-12
	octave 2
	note B_, 2
	octave 3
	note D#, 2
	note F#, 2
	note D#, 2
	sound_ret

Music_TitleScreen_Measure2_20_24:
	; 2-20
	note F#, 5
	rest 1
	note G#, 4
	rest 1
	note G#, 2
	note A_, 11
	rest 16
	; 2-21 - tie
	note E_, 7
	rest 1
	note G#, 7
	rest 1
	note B_, 7
	rest 1
	; 2-22
	note A_, 5
	rest 1
	note G#, 5
	rest 1
	note F#, 7
	rest 1
	note E_, 8
	rest 8
	; 2-23 - tie
	octave 2
	note B_, 3
	rest 1
	octave 3
	note E_, 7
	rest 1
	note G#, 7
	rest 1
	note B_, 7
	rest 1
	; 2-24
	note A_, 5
	rest 1
	note G#, 5
	rest 1
	note F#, 12
	rest 4
	note E_, 3
	rest 1
	sound_ret

Music_TitleScreen_Hill:
	hill_type 6, 0, 35
	; 3-00
	rest 8
Music_TitleScreen_Loop3_01:
	linear_envelope 0, 35
	; 3-01
	sound_call Music_TitleScreen_Measure3_01
	; 3-02
	sound_call Music_TitleScreen_Measure3_02
	; 3-03
	sound_call Music_TitleScreen_Measure3_03
	; 3-04
	sound_call Music_TitleScreen_Measure3_04
	; 3-05
	sound_call Music_TitleScreen_Measure3_01
	; 3-06
	sound_call Music_TitleScreen_Measure3_02
	; 3-07
	sound_call Music_TitleScreen_Measure3_03
	; 3-08
	sound_call Music_TitleScreen_Measure3_04
	; 3-09
	sound_call Music_TitleScreen_Measure3_01
	; 3-10
	sound_call Music_TitleScreen_Measure3_02
	; 3-11
	sound_call Music_TitleScreen_Measure3_03
	; 3-12
	sound_call Music_TitleScreen_Measure3_04
	; 3-13
	sound_call Music_TitleScreen_Measure3_01
	; 3-14
	sound_call Music_TitleScreen_Measure3_02
	; 3-15
	sound_call Music_TitleScreen_Measure3_03
	; 3-16
	sound_call Music_TitleScreen_Measure3_04
	linear_envelope 1, 1
	; 3-17
	octave 3
	note E_, 13
	rest 1
	octave 3
	note E_, 1
	rest 1
	; 3-18
	note E_, 15
	rest 1
	linear_envelope 0, 35
	; 3-19
	sound_call Music_TitleScreen_Measure3_01
	; 3-20
	sound_call Music_TitleScreen_Measure3_02
	; 3-21
	sound_call Music_TitleScreen_Measure3_03
	; 3-22
	sound_call Music_TitleScreen_Measure3_04
	; 3-23
	sound_call Music_TitleScreen_Measure3_01
	; 3-24
	sound_call Music_TitleScreen_Measure3_02
	; 3-25
	sound_call Music_TitleScreen_Measure3_03
	; 3-26
	sound_call Music_TitleScreen_Measure3_04
	; 3-27
	sound_call Music_TitleScreen_Measure3_01
	; 3-28
	sound_call Music_TitleScreen_Measure3_02
	; 3-29
	sound_call Music_TitleScreen_Measure3_03
	; 3-30
	sound_call Music_TitleScreen_Measure3_04
	; 3-31
	sound_call Music_TitleScreen_Measure3_01
	; 3-32
	sound_call Music_TitleScreen_Measure3_02
	; 3-33
	sound_call Music_TitleScreen_Measure3_03
	; 3-34
	sound_call Music_TitleScreen_Measure3_04
	; 3-35
	octave 2
	note A_, 4
	note A_, 4
	octave 3
	note A_, 4
	note A_, 4
	; 3-36
	note G#, 4
	note G#, 4
	note G#, 4
	note G#, 4
	; 3-37
	note F#, 4
	note F#, 4
	note F#, 4
	note F#, 4
	; 3-38
	note E_, 4
	note E_, 4
	octave 2
	note B_, 4
	note B_, 4
	; 3-39
	note A_, 4
	note A_, 4
	note A_, 4
	note A_, 4
	; 3-40
	note G#, 4
	note G#, 4
	note G#, 4
	note G#, 4
	; 3-41
	note F#, 4
	note F#, 4
	note F#, 4
	note F#, 4
	; 3-42
	note B_, 4
	note B_, 4
	note B_, 4
	note B_, 4
	; 3-43
	octave 3
	note B_, 4
	rest 12
	; 3-44
	octave 3
	note C#, 4
	note C#, 4
	note C#, 4
	note C#, 4
	; 3-45
	octave 2
	note B_, 4
	note B_, 4
	note B_, 4
	note B_, 4
	; 3-46
	note A_, 4
	note A_, 4
	note A_, 4
	note A_, 4
	; 3-47
	note E_, 4
	note E_, 4
	note E_, 4
	note B_, 4
	; 3-48
	octave 3
	note C#, 4
	note C#, 4
	note C#, 4
	note C#, 4
	; 3-49
	octave 2
	note B_, 4
	note B_, 4
	note B_, 4
	note B_, 4
	; 3-50
	note A_, 4
	note A_, 4
	note B_, 4
	note B_, 4
	linear_envelope 1, 1
	; 3-51
	octave 3
	note E_, 15
	rest 1
	sound_jump Music_TitleScreen_Loop3_01

Music_TitleScreen_Measure3_01:
	octave 3
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	sound_ret

Music_TitleScreen_Measure3_02:
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	sound_ret

Music_TitleScreen_Measure3_03:
	octave 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	sound_ret

Music_TitleScreen_Measure3_04:
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	sound_ret

Music_TitleScreen_Noise:
	toggle_drum 0
	drum_speed 12
	; 4-00
	rest 4
Music_TitleScreen_Loop4_01:
	; 4-01
	sound_call Music_TitleScreen_Measure4_01
	; 4-02
	sound_call Music_TitleScreen_Measure4_02
	; 4-03
	sound_call Music_TitleScreen_Measure4_02
	; 4-04
	sound_call Music_TitleScreen_Measure4_02
	; 4-05
	sound_call Music_TitleScreen_Measure4_02
	; 4-06
	sound_call Music_TitleScreen_Measure4_02
	; 4-07
	sound_call Music_TitleScreen_Measure4_02
	; 4-08
	sound_call Music_TitleScreen_Measure4_02
	; 4-09
	sound_call Music_TitleScreen_Measure4_02
	; 4-10
	sound_call Music_TitleScreen_Measure4_02
	; 4-11
	sound_call Music_TitleScreen_Measure4_02
	; 4-12
	sound_call Music_TitleScreen_Measure4_02
	; 4-13
	sound_call Music_TitleScreen_Measure4_02
	; 4-14
	sound_call Music_TitleScreen_Measure4_02
	; 4-15
	sound_call Music_TitleScreen_Measure4_02
	; 4-16
	sound_call Music_TitleScreen_Measure4_02
	; 4-17
	sound_call Music_TitleScreen_Measure4_02
	; 4-18
	sound_call Music_TitleScreen_Measure4_02
	; 4-19
	sound_call Music_TitleScreen_Measure4_01
	; 4-20
	sound_call Music_TitleScreen_Measure4_02
	; 4-21
	sound_call Music_TitleScreen_Measure4_02
	; 4-22
	sound_call Music_TitleScreen_Measure4_02
	; 4-23
	sound_call Music_TitleScreen_Measure4_02
	; 4-24
	sound_call Music_TitleScreen_Measure4_02
	; 4-25
	sound_call Music_TitleScreen_Measure4_02
	; 4-26
	sound_call Music_TitleScreen_Measure4_02
	; 4-27
	sound_call Music_TitleScreen_Measure4_01
	; 4-28
	sound_call Music_TitleScreen_Measure4_02
	; 4-29
	sound_call Music_TitleScreen_Measure4_02
	; 4-30
	sound_call Music_TitleScreen_Measure4_02
	; 4-31
	sound_call Music_TitleScreen_Measure4_01
	; 4-32
	sound_call Music_TitleScreen_Measure4_02
	; 4-33
	sound_call Music_TitleScreen_Measure4_02
	; 4-34
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	; 4-35
	sound_call Music_TitleScreen_Measure4_01
	; 4-36
	sound_call Music_TitleScreen_Measure4_02
	; 4-37
	sound_call Music_TitleScreen_Measure4_02
	; 4-38
	sound_call Music_TitleScreen_Measure4_02
	; 4-39
	sound_call Music_TitleScreen_Measure4_01
	; 4-40
	sound_call Music_TitleScreen_Measure4_02
	; 4-41
	sound_call Music_TitleScreen_Measure4_02
	; 4-42
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	; 4-43
	drum_note 2, 8
	; 4-44
	sound_call Music_TitleScreen_Measure4_01
	; 4-45
	sound_call Music_TitleScreen_Measure4_02
	; 4-46
	sound_call Music_TitleScreen_Measure4_02
	; 4-47
	sound_call Music_TitleScreen_Measure4_02
	; 4-48
	sound_call Music_TitleScreen_Measure4_01
	; 4-49
	sound_call Music_TitleScreen_Measure4_02
	; 4-50
	sound_call Music_TitleScreen_Measure4_02
	; 4-51
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	sound_jump Music_TitleScreen_Loop4_01

Music_TitleScreen_Measure4_01:
	drum_note 2, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 1, 2
	sound_ret

Music_TitleScreen_Measure4_02:
	drum_note 1, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 1, 2
	sound_ret

Music_TitleScreen_DPCM:
	drum_speed 6
	; 5-00
	drum_note 1, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
Music_TitleScreen_Loop5_01:
	; 5-01
	sound_call Music_TitleScreen_Measure5_01
	; 5-02
	sound_call Music_TitleScreen_Measure5_01
	; 5-03
	sound_call Music_TitleScreen_Measure5_01
	; 5-04
	sound_call Music_TitleScreen_Measure5_04
	; 5-05
	sound_call Music_TitleScreen_Measure5_01
	; 5-06
	sound_call Music_TitleScreen_Measure5_06
	; 5-07
	sound_call Music_TitleScreen_Measure5_01
	; 5-08
	sound_call Music_TitleScreen_Measure5_08
	; 5-09
	sound_call Music_TitleScreen_Measure5_01
	; 5-10
	sound_call Music_TitleScreen_Measure5_01
	; 5-11
	sound_call Music_TitleScreen_Measure5_01
	; 5-12
	sound_call Music_TitleScreen_Measure5_04
	; 5-13
	sound_call Music_TitleScreen_Measure5_01
	; 5-14
	sound_call Music_TitleScreen_Measure5_06
	; 5-15
	sound_call Music_TitleScreen_Measure5_01
	; 5-16
	sound_call Music_TitleScreen_Measure5_08
	; 5-17
	drum_note 10, 14
	drum_note 10, 2
	; 5-18
	drum_note 10, 10
	drum_note 10, 2
	drum_note 1, 4
	; 5-19
	sound_call Music_TitleScreen_Measure5_01
	; 5-20
	sound_call Music_TitleScreen_Measure5_01
	; 5-21
	sound_call Music_TitleScreen_Measure5_01
	; 5-22
	sound_call Music_TitleScreen_Measure5_04
	; 5-23
	sound_call Music_TitleScreen_Measure5_01
	; 5-24
	sound_call Music_TitleScreen_Measure5_06
	; 5-25
	sound_call Music_TitleScreen_Measure5_01
	; 5-26
	sound_call Music_TitleScreen_Measure5_08
	; 5-27
	sound_call Music_TitleScreen_Measure5_01
	; 5-28
	sound_call Music_TitleScreen_Measure5_01
	; 5-29
	sound_call Music_TitleScreen_Measure5_01
	; 5-30
	sound_call Music_TitleScreen_Measure5_30
	; 5-31
	sound_call Music_TitleScreen_Measure5_01
	; 5-32
	sound_call Music_TitleScreen_Measure5_06
	; 5-33
	sound_call Music_TitleScreen_Measure5_01
	; 5-34
	sound_call Music_TitleScreen_Measure5_34
	; 5-35
	sound_call Music_TitleScreen_Measure5_01
	; 5-36
	sound_call Music_TitleScreen_Measure5_01
	; 5-37
	sound_call Music_TitleScreen_Measure5_01
	; 5-38
	sound_call Music_TitleScreen_Measure5_30
	; 5-39
	sound_call Music_TitleScreen_Measure5_01
	; 5-40
	sound_call Music_TitleScreen_Measure5_06
	; 5-41
	sound_call Music_TitleScreen_Measure5_01
	; 5-42
	sound_call Music_TitleScreen_Measure5_34
	; 5-43
	drum_note 10, 4
	drum_note 10, 4
	drum_note 10, 2
	drum_note 1, 1
	drum_note 1, 1
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	; 5-44
	sound_call Music_TitleScreen_Measure5_01
	; 5-45
	sound_call Music_TitleScreen_Measure5_01
	; 5-46
	sound_call Music_TitleScreen_Measure5_01
	; 5-47
	sound_call Music_TitleScreen_Measure5_30
	; 5-48
	sound_call Music_TitleScreen_Measure5_01
	; 5-49
	sound_call Music_TitleScreen_Measure5_06
	; 5-50
	sound_call Music_TitleScreen_Measure5_01
	; 5-51
	sound_call Music_TitleScreen_Measure5_34
	sound_jump Music_TitleScreen_Loop5_01

Music_TitleScreen_Measure5_01:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	sound_ret

Music_TitleScreen_Measure5_04:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 2
	sound_ret

Music_TitleScreen_Measure5_06:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 10, 2
	sound_ret

Music_TitleScreen_Measure5_08:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	sound_ret

Music_TitleScreen_Measure5_30:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	drum_note 1, 2
	drum_note 1, 2
	sound_ret

Music_TitleScreen_Measure5_34:
	drum_note 1, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	sound_ret
