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
@Mainloop:
	rest 16
	sound_loop 8, @Mainloop
@Loop1:
	sound_call @Sub1
	rest 13
	sound_loop 7, @Loop1
	rest 16
	rest 16
@Loop2:
	sound_call @Sub1
	sound_call @Sub2
	sound_loop 3, @Loop2
	sound_call @Sub1
	rest 13
	sound_jump @Mainloop

@Sub1:
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

@Sub2:
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
@Mainloop:
	rest 16
	rest 16
	rest 16
	rest 16
@Loop1:
	sound_call Music_Journey_Pulse1@Sub1
	sound_call Music_Journey_Pulse1@Sub2
	sound_loop 2, @Loop1
@Loop2:
	sound_call @Sub1
	sound_call Music_Journey_Pulse1@Sub2
	sound_loop 7, @Loop2
	sound_call Music_Journey_Pulse1@Sub1
	sound_call Music_Journey_Pulse1@Sub2
@Loop3:
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
	sound_loop 3, @Loop3
	sound_call @Sub1
	sound_call Music_Journey_Pulse1@Sub2
	sound_jump @Mainloop

@Sub1:
	set_mute_timer 7
	vibrato 10, 5, 4
	volume_envelope 1, 10
	note C_, 2
	volume_envelope 1, 5
	note C_, 2
	volume_envelope 1, 10
	note D_, 2
	volume_envelope 1, 5
	note D_, 2
	volume_envelope 1, 10
	note F_, 2
	volume_envelope 1, 5
	note F_, 2
	volume_envelope 1, 10
	note E_, 2
	volume_envelope 1, 5
	note E_, 2
	volume_envelope 1, 10
	note D_, 2
	volume_envelope 1, 5
	note D_, 2
	volume_envelope 1, 10
	note C_, 2
	volume_envelope 1, 5
	note C_, 2
	volume_envelope 1, 3
	note C_, 2
	volume_envelope 1, 2
	note C_, 2
	volume_envelope 1, 10
	note D_, 2
	volume_envelope 1, 5
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
@Mainloop:
	sound_call @Sub1
	sound_loop 16, @Mainloop
@Loop1:
	rest 16
	sound_loop 8, @Loop1
@Loop2:
	sound_call @Sub1
	sound_loop 8, @Loop2
	sound_jump @Mainloop

@Sub1:
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
@Mainloop:
	sound_call @Sub1
	drum_note 9, 2
	sound_call @Sub1
	drum_note 9, 1
	drum_note 9, 1
	sound_loop 4, @Mainloop
@Loop1:
	rest 16
	sound_loop 8, @Loop1
@Loop2:
	sound_call @Sub1
	drum_note 9, 2
	sound_call @Sub1
	drum_note 9, 1
	drum_note 9, 1
	sound_loop 2, @Loop2
	sound_jump @Mainloop

@Sub1:
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