Music_HOFScene2:
	music_header 5, 1, Music_HOFScene2_Pulse1
	music_subheader 2, Music_HOFScene2_Pulse2
	music_subheader 3, Music_HOFScene2_Hill
	music_subheader 4, Music_HOFScene2_Noise
	music_subheader 5, Music_HOFScene2_DPCM

Music_HOFScene2_Pulse1:
	tempo 160
	duty_cycle 3
	note_type 12, 0, 2
	rest 16
	rest 16
	rest 16
	rest 16
Music_HOFScene2_Pulse1_Mainloop:
	sound_call Music_HOFScene2_Pulse1_sub1
	sound_call Music_HOFScene2_Pulse1_sub2
Music_HOFScene2_Pulse1_loop1:
	sound_call Music_HOFScene2_Pulse1_sub1
	octave 3
	note D#, 2
	note G#, 2
	octave 4
	note F_, 2
	octave 3
	note G#, 2
	octave 2
	note A#, 2
	octave 3
	note G_, 2
	octave 4
	note D#, 2
	octave 3
	note G_, 2
	octave 2
	note A#, 2
	octave 3
	note F_, 2
	octave 4
	note D_, 2
	octave 3
	note F_, 2
	sound_loop 2, Music_HOFScene2_Pulse1_loop1
	sound_call Music_HOFScene2_Pulse1_sub3
	note D_, 2
	note C_, 2
	octave 3
	note A#, 10
	sound_call Music_HOFScene2_Pulse1_sub4
	sound_call Music_HOFScene2_Pulse1_sub3
	octave 3
	note A#, 2
	octave 4
	note C_, 2
	note D_, 10
	sound_call Music_HOFScene2_Pulse1_sub4
	duty_cycle 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	note A#, 4
	duty_cycle 3
	vibrato 0, 0, 0
	volume_envelope 0, 2
	octave 4
	note G_, 2
	duty_cycle 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	octave 3
	note G_, 4
	note G#, 2
	note A#, 2
	octave 4
	note C_, 6
	octave 3
	note A#, 2
	note G#, 6
	duty_cycle 3
	vibrato 0, 0, 0
	volume_envelope 0, 2
	octave 4
	note D#, 2
	octave 3
	note G#, 2
	duty_cycle 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	note G_, 4
	note G#, 2
	note A#, 4
	note G#, 2
	note G_, 2
	note F_, 14
	sound_call Music_HOFScene2_Pulse1_sub5
	note D#, 2
	duty_cycle 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	note G_, 2
	note G#, 2
	note A#, 4
	octave 4
	note D_, 4
	note C_, 6
	octave 3
	note A#, 2
	note G#, 4
	note G_, 4
	note G_, 2
	note A#, 2
	note G#, 2
	note G_, 2
	octave 4
	note F_, 4
	note D#, 4
	note D_, 14
	sound_call Music_HOFScene2_Pulse1_sub5
	sound_jump Music_HOFScene2_Pulse1_Mainloop

Music_HOFScene2_Pulse1_sub1:
	octave 3
	note D#, 2
	note A#, 2
	octave 4
	note G_, 2
	octave 3
	note A#, 2
	sound_ret

Music_HOFScene2_Pulse1_sub2:
	note D#, 2
	octave 4
	note C_, 2
	note G#, 2
	note C_, 2
	octave 3
	note D#, 2
	octave 4
	note D_, 2
	note A#, 2
	note D_, 2
	octave 3
	note D#, 2
	octave 4
	note C_, 2
	note G#, 2
	note C_, 2
	sound_ret

Music_HOFScene2_Pulse1_sub3:
	note C_, 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	note D#, 2
	note F_, 2
	note G_, 4
	note F_, 2
	note D#, 2
	note D_, 2
	octave 2
	note A#, 8
	vibrato 0, 0, 0
	volume_envelope 0, 2
	octave 3
	note D_, 2
	note A#, 2
	octave 4
	note F_, 2
	note G_, 2
	octave 3
	note D#, 2
	vibrato 10, 5, 4
	volume_envelope 1, 9
	note D#, 2
	note G#, 2
	note C_, 4
	sound_ret

Music_HOFScene2_Pulse1_sub4:
	vibrato 0, 0, 0
	volume_envelope 0, 2
	octave 3
	note D_, 2
	note A#, 2
Music_HOFScene2_Pulse1_sub5:
	duty_cycle 3
	vibrato 0, 0, 0
	volume_envelope 0, 2
	octave 4
	note F_, 2
	octave 3
	note A#, 2
	sound_ret

Music_HOFScene2_Pulse2:
	duty_cycle 3
	note_type 12, 0, 2
	sound_call Music_HOFScene2_Pulse1_sub1
	sound_call Music_HOFScene2_Pulse1_sub2
	sound_loop 2, Music_HOFScene2_Pulse2
Music_HOFScene2_Pulse2_Mainloop:
	duty_cycle 0
	vibrato 15, 4, 4
	volume_envelope 1, 12
	sound_call Music_HOFScene2_Pulse2_sub1
	octave 3
	note A#, 4
	octave 4
	note D#, 2
	note F_, 10
	rest 8
	sound_call Music_HOFScene2_Pulse2_sub1
	note D_, 4
	note C_, 2
	octave 3
	note A#, 10
	duty_cycle 2
	vibrato 27, 3, 3
	sound_call Music_HOFScene2_Pulse2_sub2
	note A_, 1
	note A#, 3
	note G#, 4
	note_type 12, 1, 9
	note G_, 10
	sound_call Music_HOFScene2_Pulse2_sub2
	note G_, 4
	note G#, 4
	note A_, 1
	note A#, 1
	note_type 12, 1, 9
	note A#, 13
	rest 4
	duty_cycle 0
	vibrato 15, 4, 4
	volume_envelope 1, 12
	note G_, 4
	rest 2
	note D#, 4
	note F_, 2
	note G_, 2
	note G#, 6
	note G_, 2
	note F_, 6
	rest 4
	note D#, 4
	note F_, 2
	note G_, 4
	note F_, 2
	note D#, 2
	note D_, 14
	rest 6
	note D#, 2
	note F_, 2
	note G_, 4
	note A#, 4
	note G#, 6
	note G_, 2
	note F_, 4
	note D#, 4
	note D#, 2
	note G_, 2
	note F_, 2
	note D#, 2
	note D_, 4
	note C_, 4
	octave 3
	note A#, 14
	sound_jump Music_HOFScene2_Pulse2_Mainloop

Music_HOFScene2_Pulse2_sub1:
	octave 4
	note D#, 8
	rest 4
	note F_, 4
	note G_, 8
	rest 4
	note F_, 2
	note G_, 6
	note D#, 4
	sound_ret

Music_HOFScene2_Pulse2_sub2:
	rest 10
	note_type 6, 1, 9
	octave 3
	note B_, 1
	octave 4
	note C_, 3
	note D_, 4
	note D#, 8
	note D_, 4
	note C_, 4
	octave 3
	note A#, 4
	note G_, 16
	rest 16
	rest 4
	octave 3
	note B_, 1
	octave 4
	note C_, 3
	note D#, 4
	note G#, 8
	sound_ret

Music_HOFScene2_Hill:
	vibrato 4, 7, 5
	hill_type 12, 1, 1
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 14
Music_HOFScene2_Hill_Mainloop:
	octave 2
	note B_, 2
	octave 3
	note C_, 16
	octave 2
	note G_, 16
	note G#, 16
	octave 3
	note D#, 8
	note D_, 8
	note C_, 16
	octave 2
	note G_, 16
	note G#, 16
	note A#, 16
Music_HOFScene2_Hill_loop1:
	octave 3
	note D#, 16
	octave 2
	note G#, 16
	octave 3
	note C_, 16
	octave 2
	note A#, 16
	sound_loop 2, Music_HOFScene2_Hill_loop1
	octave 3
	note D#, 16
	note G#, 16
	note D#, 16
	octave 2
	note A#, 16
	octave 3
	note D#, 16
	note G#, 16
	note D#, 16
	octave 2
	note A#, 14
	sound_jump Music_HOFScene2_Hill_Mainloop

Music_HOFScene2_Noise:
	toggle_drum 0
	drum_speed 12
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 16
	rest 12
	drum_note 5, 1
	drum_note 5, 1
	drum_note 5, 1
	drum_note 5, 1
Music_HOFScene2_Noise_Mainloop:
	drum_note 5, 2
	sound_jump Music_HOFScene2_Noise_Mainloop

Music_HOFScene2_DPCM:
	drum_speed 12
	rest 16
	rest 16
	rest 16
	rest 10
	drum_note 10, 2
	drum_note 12, 4
Music_HOFScene2_DPCM_Mainloop:
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 2
	drum_note 10, 2
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 2
	drum_note 12, 2
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 2
	drum_note 10, 2
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	drum_note 10, 4
	drum_note 12, 6
	drum_note 10, 2
	drum_note 12, 4
	drum_note 12, 2
	drum_note 10, 2
	drum_note 12, 2
	drum_note 10, 2
	drum_note 12, 2
	drum_note 12, 2
	drum_note 12, 2
	drum_note 12, 2
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 2
	drum_note 10, 2
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 4
	sound_call Music_HOFScene2_DPCM_sub1
	drum_note 12, 2
	drum_note 12, 2
	sound_jump Music_HOFScene2_DPCM_Mainloop

Music_HOFScene2_DPCM_sub1:
	drum_note 10, 4
	drum_note 12, 6
	drum_note 10, 2
	drum_note 12, 4
	drum_note 10, 4
	drum_note 12, 4
	drum_note 10, 2
	drum_note 10, 2
	sound_ret
