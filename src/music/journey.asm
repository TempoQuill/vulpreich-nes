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
	rest 16
	sound_loop 8, Music_Journey_Loop1_01
Music_Journey_Loop1_09:
	sound_call Music_Journey_Measure1_09
	rest 13
	sound_loop 7, Music_Journey_Loop1_09
	rest 16
	rest 16
Music_Journey_Loop1_25:
	sound_call Music_Journey_Measure1_09
	sound_call Music_Journey_Measure1_26
	sound_loop 3, Music_Journey_Loop1_25
	sound_call Music_Journey_Measure1_09
	rest 13
	sound_jump Music_Journey_Loop1_01

Music_Journey_Measure1_09:
	set_mute_timer 5
	vibrato 4, 7, 5
	volume_envelope 1, 6
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
	octave 1
	note G_, 1
	octave 2
	note G_, 1
	octave 3
	note G_, 1
	sound_ret

Music_Journey_Measure1_26:
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

Music_Journey_Pulse2:
	duty_cycle 1
	note_type 12, 0, 0
Music_Journey_Loop2_01:
	rest 16
	rest 16
	rest 16
	rest 16
Music_Journey_Loop2_05:
	sound_call Music_Journey_Measure1_09
	sound_call Music_Journey_Measure1_26
	sound_loop 2, Music_Journey_Loop2_05
Music_Journey_Loop2_09:
	set_mute_timer 7
	vibrato 10, 5, 4
	sound_call Music_Journey_Measure2_09
	sound_call Music_Journey_Measure1_26
	sound_loop 7, Music_Journey_Loop2_09
	sound_call Music_Journey_Measure1_09
	sound_call Music_Journey_Measure1_26
	set_mute_timer 0
	vibrato 10, 5, 4
Music_Journey_Loop2_25:
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
	sound_loop 3, Music_Journey_Loop2_25
	set_mute_timer 7
	vibrato 10, 5, 4
	sound_call Music_Journey_Measure2_09
	sound_call Music_Journey_Measure1_26
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
	volume_envelope 1, 3
	note D_, 1
	volume_envelope 1, 2
	note D_, 1
	volume_envelope 1, 1
	note D_, 1
	sound_ret

Music_Journey_Hill:
	hill_type 12, 0, 40
	octave 3
	note D_, 6
	note D_, 4
	octave 2
	note A_, 3
	octave 3
	note C_, 3
	octave 2
	note G_, 6
	note G_, 4
	octave 3
	note C_, 3
	octave 2
	note G_, 3
	sound_jump Music_Journey_Hill

Music_Journey_Noise:
	drum_on 0
	drum_speed 6
Music_Journey_Loop4_01:
	sound_call Music_Journey_Measure4_01
	sound_call Music_Journey_Measure4_01
Music_Journey_Loop4_17:
	rest 16
	sound_loop 16, Music_Journey_Loop4_17
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
	sound_loop 8, Music_Journey_Measure4_01
	sound_ret

Music_Journey_DPCM:
	drum_speed 6
Music_Journey_Loop5_01:
	sound_call Music_Journey_Measure5_01
	sound_call Music_Journey_Measure5_02
	sound_call Music_Journey_Measure5_04
	sound_loop 4, Music_Journey_Loop5_01
Music_Journey_Loop5_17:
	rest 16
	sound_loop 16, Music_Journey_Loop5_17
Music_Journey_Loop5_25:
	sound_call Music_Journey_Measure5_01
	sound_call Music_Journey_Measure5_02
	sound_call Music_Journey_Measure5_04
	sound_loop 2, Music_Journey_Loop5_25
	sound_jump Music_Journey_Loop5_01

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
