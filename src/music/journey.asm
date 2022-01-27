Music_Journey: ; JACK GETSCHMAN
	music_header 5, 1, Music_Journey_Pulse1
	music_subheader 2, Music_Journey_Pulse2
	music_subheader 3, Music_Journey_Hill
	music_subheader 4, Music_Journey_Noise
	music_subheader 5, Music_Journey_DPCM

Music_Journey_Pulse1:
	tempo 160
	duty_cycle 1
	note_type 12, 0, 0
Music_Journey_Loop1_01:
	; 1-01
	rest 16
	; 1-02
	rest 16
	; 1-03
	rest 16
	; 1-04
	rest 16
	; 1-05
	rest 16
	; 1-06
	rest 16
	; 1-07
	rest 16
	; 1-08
	rest 16
	set_mute_timer 5
	vibrato 4, 7, 5
	volume_envelope 1, 6
	; 1-09
	sound_call Music_Journey_Measure1_09
	; 1-10
	sound_call Music_Journey_Measure1_10
	; 1-11
	sound_call Music_Journey_Measure1_09
	; 1-12
	sound_call Music_Journey_Measure1_10
	; 1-13
	sound_call Music_Journey_Measure1_09
	; 1-14
	sound_call Music_Journey_Measure1_10
	; 1-15
	sound_call Music_Journey_Measure1_09
	; 1-16
	sound_call Music_Journey_Measure1_10
	; 1-17
	sound_call Music_Journey_Measure1_09
	; 1-18
	sound_call Music_Journey_Measure1_10
	; 1-19
	sound_call Music_Journey_Measure1_09
	; 1-20
	sound_call Music_Journey_Measure1_10
	; 1-21
	sound_call Music_Journey_Measure1_09
	; 1-22
	sound_call Music_Journey_Measure1_10
	; 1-23
	rest 16
	; 1-24
	rest 16
	; 1-25
	sound_call Music_Journey_Measure1_09
	; 1-26
	sound_call Music_Journey_Measure1_26
	; 1-27
	sound_call Music_Journey_Measure1_09
	; 1-28
	sound_call Music_Journey_Measure1_26
	; 1-29
	sound_call Music_Journey_Measure1_09
	; 1-30
	sound_call Music_Journey_Measure1_26
	; 1-31
	sound_call Music_Journey_Measure1_09
	; 1-32
	sound_call Music_Journey_Measure1_10
	sound_jump Music_Journey_Loop1_01

Music_Journey_Measure1_09:
	octave 2
	note D_, 1
	octave 3
	note D_, 1
	octave 4
	note D_, 1
	octave 3
	note D_, 3
	octave 2
	note D_, 1
	octave 3
	note D_, 1
	octave 4
	note D_, 1
	octave 3
	note D_, 1
	octave 1
	note A_, 1
	octave 2
	note A_, 1
	octave 3
	note A_, 1
	octave 2
	note C_, 1
	octave 3
	note C_, 1
	octave 4
	note C_, 1
	sound_ret

Music_Journey_Measure1_10:
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	rest 13
	sound_ret

Music_Journey_Measure1_26:
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	octave 2
	note G_, 3
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	octave 2
	note G_, 1
	octave 2
	note C_, 1
	octave 3
	note C_, 1
	octave 4
	note C_, 1
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	sound_ret

Music_Journey_Pulse2:
	duty_cycle 1
	note_type 12, 0, 0
Music_Journey_Loop2_01:
	; 2-01
	rest 16
	; 2-02
	rest 16
	; 2-03
	rest 16
	; 2-04
	rest 16
	set_mute_timer 5
	vibrato 4, 7, 5
	volume_envelope 1, 6
	; 2-05
	sound_call Music_Journey_Measure1_09
	; 2-06
	sound_call Music_Journey_Measure1_26
	; 2-07
	sound_call Music_Journey_Measure1_09
	; 2-08
	sound_call Music_Journey_Measure1_26
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-09
	sound_call Music_Journey_Measure2_09
	; 2-10
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-11
	sound_call Music_Journey_Measure2_09
	; 2-12
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-13
	sound_call Music_Journey_Measure2_09
	; 2-14
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-15
	sound_call Music_Journey_Measure2_09
	; 2-16
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-17
	sound_call Music_Journey_Measure2_09
	; 2-18
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-19
	sound_call Music_Journey_Measure2_09
	; 2-20
	sound_call Music_Journey_Measure2_10
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-21
	sound_call Music_Journey_Measure2_09
	; 2-22
	sound_call Music_Journey_Measure2_10
	; 2-23
	sound_call Music_Journey_Measure1_09
	; 2-24
	sound_call Music_Journey_Measure1_26
	set_mute_timer 0
	vibrato 10, 5, 4
	; 2-25
	sound_call Music_Journey_Measure2_25_26
	; 2-27
	sound_call Music_Journey_Measure2_25_26
	; 2-29
	sound_call Music_Journey_Measure2_25_26
	set_mute_timer 7
	vibrato 10, 5, 4
	; 2-31
	sound_call Music_Journey_Measure2_09
	; 2-32
	sound_call Music_Journey_Measure2_10
	sound_jump Music_Journey_Loop2_01

Music_Journey_Measure2_09:
	volume_envelope 1, 10
	note C_, 1
	volume_envelope 1, 5
	note C_, 1
	volume_envelope 1, 10
	note D_, 1
	volume_envelope 1, 5
	note D_, 1
	volume_envelope 1, 10
	note F_, 1
	volume_envelope 1, 5
	note F_, 1
	volume_envelope 1, 10
	note E_, 1
	volume_envelope 1, 5
	note E_, 1
	volume_envelope 1, 10
	note D_, 1
	volume_envelope 1, 5
	note D_, 1
	volume_envelope 1, 10
	note C_, 1
	volume_envelope 1, 5
	note C_, 1
	volume_envelope 1, 3
	note C_, 1
	volume_envelope 1, 2
	note C_, 1
	volume_envelope 1, 10
	note D_, 1
	volume_envelope 1, 5
	note D_, 1
	sound_ret

Music_Journey_Measure2_10:
	volume_envelope 1, 3
	note D_, 1
	volume_envelope 1, 2
	note D_, 1
	volume_envelope 1, 1
	note D_, 1
	set_mute_timer 5
	vibrato 4, 7, 5
	volume_envelope 1, 6
	octave 2
	note G_, 3
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	octave 2
	note G_, 1
	octave 2
	note C_, 1
	octave 3
	note C_, 1
	octave 4
	note C_, 1
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	sound_ret

Music_Journey_Measure2_25_26:
	; 2-25
	volume_envelope 1, 3
	note D_, 3
	volume_envelope 1, 5
	note D_, 3
	volume_envelope 1, 7
	note D_, 3
	volume_envelope 1, 9
	note D_, 3
	volume_envelope 1, 10
	note D_, 6
	; 2-26 - tie
	volume_envelope 1, 7
	note D_, 2
	volume_envelope 1, 6
	note D_, 2
	volume_envelope 1, 5
	note D_, 2
	volume_envelope 1, 4
	note D_, 2
	volume_envelope 1, 3
	note D_, 2
	volume_envelope 1, 2
	note D_, 2
	volume_envelope 1, 1
	note D_, 2
	sound_ret

Music_Journey_Hill:
	hill_type 12, 0, 40
	; 3-01
	octave 3
	note D_, 6
	note D_, 4
	octave 2
	note A_, 3
	octave 3
	note C_, 3
	; 3-02
	octave 2
	note G_, 6
	note G_, 4
	octave 3
	note C_, 3
	octave 2
	note G_, 3
	sound_jump Music_Journey_Hill

Music_Journey_Noise:
	toggle_drum 0
	drum_speed 6
Music_Journey_Loop4_01:
	; 4-01
	sound_call Music_Journey_Measure4_01
	; 4-02
	sound_call Music_Journey_Measure4_01
	; 4-03
	sound_call Music_Journey_Measure4_01
	; 4-04
	sound_call Music_Journey_Measure4_01
	; 4-05
	sound_call Music_Journey_Measure4_01
	; 4-06
	sound_call Music_Journey_Measure4_01
	; 4-07
	sound_call Music_Journey_Measure4_01
	; 4-08
	sound_call Music_Journey_Measure4_01
	; 4-09
	sound_call Music_Journey_Measure4_01
	; 4-10
	sound_call Music_Journey_Measure4_01
	; 4-11
	sound_call Music_Journey_Measure4_01
	; 4-12
	sound_call Music_Journey_Measure4_01
	; 4-13
	sound_call Music_Journey_Measure4_01
	; 4-14
	sound_call Music_Journey_Measure4_01
	; 4-15
	sound_call Music_Journey_Measure4_01
	; 4-16
	sound_call Music_Journey_Measure4_01
	; 4-17
	rest 16
	rest 16
	; 4-18
	rest 16
	rest 16
	; 4-19
	rest 16
	rest 16
	; 4-20
	rest 16
	rest 16
	; 4-21
	rest 16
	rest 16
	; 4-22
	rest 16
	rest 16
	; 4-23
	rest 16
	rest 16
	; 4-24
	rest 16
	rest 16
	; 4-25
	sound_call Music_Journey_Measure4_01
	; 4-26
	sound_call Music_Journey_Measure4_01
	; 4-27
	sound_call Music_Journey_Measure4_01
	; 4-28
	sound_call Music_Journey_Measure4_01
	; 4-29
	sound_call Music_Journey_Measure4_01
	; 4-30
	sound_call Music_Journey_Measure4_01
	; 4-31
	sound_call Music_Journey_Measure4_01
	; 4-32
	sound_call Music_Journey_Measure4_01
	sound_jump Music_Journey_Loop4_01

Music_Journey_Measure4_01:
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 1
	drum_note 3, 1
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	drum_note 3, 2
	sound_ret

Music_Journey_DPCM:
	drum_speed 6
Music_Journey_Loop5_01:
	; 5-01
	sound_call Music_Journey_Measure5_01
	; 5-02
	sound_call Music_Journey_Measure5_02
	; 5-03
	sound_call Music_Journey_Measure5_01
	; 5-04
	sound_call Music_Journey_Measure5_04
	; 5-05
	sound_call Music_Journey_Measure5_01
	; 5-06
	sound_call Music_Journey_Measure5_02
	; 5-07
	sound_call Music_Journey_Measure5_01
	; 5-08
	sound_call Music_Journey_Measure5_04
	; 5-09
	sound_call Music_Journey_Measure5_01
	; 5-10
	sound_call Music_Journey_Measure5_02
	; 5-11
	sound_call Music_Journey_Measure5_01
	; 5-12
	sound_call Music_Journey_Measure5_04
	; 5-13
	sound_call Music_Journey_Measure5_01
	; 5-14
	sound_call Music_Journey_Measure5_02
	; 5-15
	sound_call Music_Journey_Measure5_01
	; 5-16
	sound_call Music_Journey_Measure5_04
	; 5-17
	rest 16
	rest 16
	; 5-18
	rest 16
	rest 16
	; 5-19
	rest 16
	rest 16
	; 5-20
	rest 16
	rest 16
	; 5-21
	rest 16
	rest 16
	; 5-22
	rest 16
	rest 16
	; 5-23
	rest 16
	rest 16
	; 5-24
	rest 16
	rest 16
	; 5-25
	sound_call Music_Journey_Measure5_01
	; 5-26
	sound_call Music_Journey_Measure5_02
	; 5-27
	sound_call Music_Journey_Measure5_01
	; 5-28
	sound_call Music_Journey_Measure5_04
	; 5-29
	sound_call Music_Journey_Measure5_01
	; 5-30
	sound_call Music_Journey_Measure5_02
	; 5-31
	sound_call Music_Journey_Measure5_01
	; 5-32
	sound_call Music_Journey_Measure5_04
	sound_jump Music_Journey_Loop5_01

Music_Journey_Measure5_01:
	drum_note 11, 6
	drum_note 11, 2
	drum_note 9, 4
	drum_note 11, 8
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	sound_ret

Music_Journey_Measure5_02:
	drum_note 11, 6
	drum_note 11, 2
	drum_note 9, 4
	drum_note 11, 2
	drum_note 9, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	sound_ret

Music_Journey_Measure5_04:
	drum_note 11, 6
	drum_note 11, 2
	drum_note 9, 4
	drum_note 11, 2
	drum_note 9, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 1
	drum_note 9, 1
	sound_ret
