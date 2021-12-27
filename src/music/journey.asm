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
Music_Journey_Pulse1_Mainloop:
	rest 16
	sound_loop 8, Music_Journey_Pulse1_Mainloop
Music_Journey_Pulse1_loop1:
	sound_call Music_Journey_Pulse1_Sub1
	rest 13
	sound_loop 7, Music_Journey_Pulse1_loop1
	rest 16
	rest 16
Music_Journey_Pulse1_loop2:
	sound_call Music_Journey_Pulse1_Sub1
	sound_call Music_Journey_Pulse1_Sub2
	sound_loop 3, Music_Journey_Pulse1_loop2
	sound_call Music_Journey_Pulse1_Sub1
	rest 13
	sound_jump Music_Journey_Pulse1_Mainloop

Music_Journey_Pulse1_Sub1:
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

Music_Journey_Pulse1_Sub2:
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
Music_Journey_Pulse2_Mainloop:
	rest 16
	rest 16
	rest 16
	rest 16
Music_Journey_Pulse2_loop1:
	sound_call Music_Journey_Pulse1_Sub1
	sound_call Music_Journey_Pulse1_Sub2
	sound_loop 2, Music_Journey_Pulse2_loop1
Music_Journey_Pulse2_loop2:
	sound_call Music_Journey_Pulse2_Sub1
	sound_call Music_Journey_Pulse1_Sub2
	sound_loop 7, Music_Journey_Pulse2_loop2
	sound_call Music_Journey_Pulse1_Sub1
	sound_call Music_Journey_Pulse1_Sub2
Music_Journey_Pulse2_loop3:
	set_mute_timer 0
	vibrato 10, 5, 4
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
	sound_loop 3, Music_Journey_Pulse2_loop3
	sound_call Music_Journey_Pulse2_Sub1
	sound_call Music_Journey_Pulse1_Sub2
	sound_jump Music_Journey_Pulse2_Mainloop

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
	toggle_drum 0
	drum_speed 6
Music_Journey_Noise_Mainloop:
	sound_call Music_Journey_Noise_Sub1
	sound_loop 16, Music_Journey_Noise_Mainloop
Music_Journey_Noise_loop1:
	rest 16
	sound_loop 8, Music_Journey_Noise_loop1
Music_Journey_Noise_loop2:
	sound_call Music_Journey_Noise_Sub1
	sound_loop 8, Music_Journey_Pulse1_loop2
	sound_jump Music_Journey_Noise_Mainloop

Music_Journey_Noise_Sub1:
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
Music_Journey_DPCM_Mainloop:
	sound_call Music_Journey_DPCM_Sub1
	drum_note 9, 2
	sound_call Music_Journey_DPCM_Sub1
	drum_note 9, 1
	drum_note 9, 1
	sound_loop 4, Music_Journey_DPCM_Mainloop
Music_Journey_DPCM_loop1:
	rest 16
	sound_loop 8, Music_Journey_DPCM_loop1
Music_Journey_DPCM_loop2:
	sound_call Music_Journey_DPCM_Sub1
	drum_note 9, 2
	sound_call Music_Journey_DPCM_Sub1
	drum_note 9, 1
	drum_note 9, 1
	sound_loop 2, Music_Journey_DPCM_loop2
	sound_jump Music_Journey_DPCM_Mainloop

Music_Journey_DPCM_Sub1:
	drum_note 11, 6
	drum_note 11, 2
	drum_note 9, 4
	drum_note 11, 8
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 6
	drum_note 11, 2
	drum_note 9, 4
	drum_note 11, 2
	drum_note 9, 4
	drum_note 9, 2
	drum_note 11, 4
	drum_note 9, 2
	drum_note 11, 4
	sound_ret