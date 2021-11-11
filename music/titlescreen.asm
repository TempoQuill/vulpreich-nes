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
	rest 4
@Mainloop:
	sound_call @Sub1
	sound_loop 4, @Mainloop
	volume_envelope 0, 15
	octave 2
	note G#, 16
@Loop1:
	sound_call @Sub1
	sound_loop 4, @Loop1
@Loop2:
	note C#, 1
	note E_, 1
	note A_, 1
	note E_, 1
	note C#, 1
	note E_, 1
	note A_, 1
	note E_, 1
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
	sound_loop 3, @Loop2
	note C#, 1
	note F#, 1
	note A#, 1
	note F#, 1
	note C#, 1
	note F#, 1
	note A#, 1
	note F#, 1
	note E_, 1
	note F#, 1
	note B_, 1
	note F#, 1
	note E_, 1
	note F#, 1
	note B_, 1
	note F#, 1
	note D#, 8
	note_type 3, 1, 5
	note E_, 15
	rest 1
	note G#, 15
	rest 1
	note F#, 15
	rest 1
	note D#, 15
	rest 1
	note C#, 15
	rest 1
	octave 2
	note A_, 15
	rest 1
	note_type 12, 1, 5
	note B_, 6
	rest 2
	note_type 3, 1, 5
	octave 3
	note G#, 15
	rest 1
	note E_, 15
	rest 1
	note D#, 15
	rest 1
	octave 2
	note B_, 11
	rest 1
	note B_, 3
	rest 1
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
	note G#, 6
	rest 2
	sound_jump @Mainloop

@Sub1:
	volume_envelope 0, 1
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
	octave 2
	note A_, 1
	octave 3
	note D_, 1
	note F#, 1
	octave 2
	note A_, 1
	octave 3
	note D_, 1
	note F#, 1
	octave 2
	note A_, 1
	octave 3
	note D_, 1
	note C#, 1
	note E_, 1
	note A_, 1
	note C#, 1
	note E_, 1
	note A_, 1
	note C#, 1
	note E_, 1
	note D#, 1
	note F#, 1
	note B_, 1
	note D#, 1
	note F#, 1
	note B_, 1
	note D#, 1
	note F#, 1
	sound_ret

Music_TitleScreen_Pulse2:
	duty_cycle 3
	note_type 12, 0, 9
	rest 4
@Mainloop:
	note_type 12, 0, 9
	rest 16
	rest 16
	rest 16
	rest 16
@Loop1:
	vibrato 4, 7, 5
	octave 2
	note B_, 2
	octave 3
	note E_, 2
	note G#, 2
	note E_, 2
	octave 2
	note B_, 2
	octave 3
	note E_, 2
	note F#, 2
	note E_, 2
	note C#, 2
	note E_, 2
	note A_, 2
	note E_, 2
	octave 2
	note B_, 2
	octave 3
	note D#, 2
	note F#, 2
	note D#, 2
	sound_loop 2, @Loop1
	note_type 3, 0, 15
	rest 1
	octave 2
	note B_, 1
	note_type 12, 0, 15
	octave 3
	note E_, 15
	note_type 6, 0, 15
	rest 1
	duty_cycle 2
	vibrato 10, 5, 4
	note_type 3, 1, 10
	rest 4
	octave 2
	note B_, 3
	rest 1
	sound_call @Sub1
	note F#, 7
	rest 1
	note E_, 7
	rest 1
	note_type 6, 1, 10
	note D#, 14
	rest 8
	sound_call @Sub1
	note A_, 7
	rest 1
	note G#, 7
	rest 1
	note A_, 4
	note_type 6, 1, 10
	note B_, 12
	rest 8
	note_type 3, 1, 10
	octave 4
	note C#, 7
	rest 1
	note C#, 7
	rest 1
	octave 3
	note A_, 7
	rest 1
	note B_, 7
	rest 1
	note A_, 3
	rest 1
	note G#, 12
	rest 4
	note E_, 3
	rest 1
	note A_, 7
	rest 1
	note G#, 3
	rest 1
	note F#, 7
	rest 1
	note G#, 7
	rest 1
	note G#, 7
	rest 1
	note E_, 12
	rest 16
	rest 8
	octave 4
	note C#, 7
	rest 1
	note C#, 7
	rest 1
	note D#, 3
	rest 1
	note E_, 7
	rest 1
	octave 3
	note B_, 7
	rest 1
	note B_, 12
	rest 4
	note B_, 3
	rest 1
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
	rest 9
	note_type 3, 1, 10
	octave 4
	note C#, 15
	rest 1
	note E_, 15
	rest 1
	note D#, 15
	rest 1
	octave 3
	note B_, 15
	rest 1
	note A_, 15
	rest 1
	note F#, 15
	rest 1
	note_type 6, 1, 10
	note G#, 12
	rest 4
	note_type 3, 1, 10
	octave 4
	note E_, 15
	rest 1
	note C#, 15
	rest 1
	octave 3
	note B_, 15
	rest 1
	note G#, 11
	rest 1
	note G#, 3
	rest 1
	note F#, 7
	rest 1
	note A_, 7
	rest 1
	note G#, 7
	rest 1
	note F#, 7
	rest 1
	note_type 6, 1, 10
	note E_, 12
	rest 4
	sound_jump @Mainloop

@Sub1:
	note_type 3, 1, 10
	octave 2
	note B_, 7
	rest 1
	octave 3
	note E_, 7
	rest 1
	note E_, 7
	rest 1
	note F#, 5
	rest 1
	note G#, 4
	rest 1
	note G#, 2
	note A_, 11
	rest 16
	note E_, 7
	rest 1
	note G#, 7
	rest 1
	note B_, 7
	rest 1
	note A_, 5
	rest 1
	note G#, 5
	rest 1
	note F#, 7
	rest 1
	note E_, 8
	rest 8
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
	note A_, 5
	rest 1
	note G#, 5
	rest 1
	note F#, 12
	rest 4
	note E_, 3
	rest 1
	note F#, 7
	rest 1
	note G#, 3
	rest 1
	sound_ret

Music_TitleScreen_Hill:
	hill_type 6, 0, 35
	rest 8
@Mainloop:
	sound_call @Sub1
	sound_loop 4, @Mainloop
	linear_envelope 1, 1
	octave 3
	note E_, 13
	rest 1
	octave 3
	note E_, 1
	rest 1
	note E_, 15
	rest 1
@Loop1:
	sound_call @Sub1
	sound_loop 4, @Loop1
	linear_envelope 0, 67
	octave 2
	note A_, 4
	note A_, 4
	octave 3
	note A_, 4
	sound_call @Sub2
	note E_, 4
	note E_, 4
	octave 2
	note B_, 4
	note B_, 4
	note A_, 4
	note A_, 4
	note A_, 4
	sound_call @Sub2
	note B_, 4
	note B_, 4
	note B_, 4
	note B_, 4
	octave 3
	note B_, 4
	rest 12
	sound_call @Sub3
	note A_, 4
	note A_, 4
	note E_, 4
	note E_, 4
	note E_, 4
	note B_, 4
	sound_call @Sub3
	note B_, 4
	note B_, 4
	linear_envelope 1, 1
	octave 3
	note E_, 15
	rest 1
	sound_jump @Mainloop

@Sub1:
	linear_envelope 0, 35
	octave 3
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note E_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	note D_, 2
	octave 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note A_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	note B_, 2
	sound_ret

@Sub2:
	note A_, 4
	note G#, 4
	note G#, 4
	note G#, 4
	note G#, 4
	note F#, 4
	note F#, 4
	note F#, 4
	note F#, 4
	sound_ret

@Sub3:
	octave 3
	note C#, 4
	note C#, 4
	note C#, 4
	note C#, 4
	octave 2
	note B_, 4
	note B_, 4
	note B_, 4
	note B_, 4
	note A_, 4
	note A_, 4
	sound_ret

Music_TitleScreen_Noise:
	toggle_drum 0
	drum_speed 12
	rest 4
@Mainloop:
	drum_note 2, 2
@Loop1:
	drum_note 1, 2
	sound_loop 71, @Loop1
	drum_note 2, 2
@Loop2:
	drum_note 1, 2
	sound_loop 31, @Loop2
	drum_note 2, 2
	sound_call @Sub1
	sound_call @Sub1
	drum_note 2, 8
	sound_call @Sub1
	sound_jump @Mainloop

@Sub1:
	drum_note 2, 2
@Sub1_Loop1:
	drum_note 1, 2
	sound_loop 15, @Sub1_Loop1
	drum_note 2, 2
@Sub1_Loop2:
	drum_note 1, 2
	sound_loop 11, @Sub1_Loop2
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	drum_note 2, 2
	sound_ret

Music_TitleScreen_DPCM:
	drum_speed 6
	drum_note 1, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
@Mainloop:
	sound_call @Sub1
	sound_call @Sub1
	drum_note 10, 14
	drum_note 10, 2
	drum_note 10, 10
	drum_note 10, 2
	drum_note 1, 4
	sound_call @Sub1
	sound_call @Sub2
	sound_call @Sub2
	drum_note 10, 4
	drum_note 10, 4
	drum_note 10, 2
	drum_note 1, 1
	drum_note 1, 1
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	sound_call @Sub2
	sound_jump @Mainloop

@Sub1:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	sound_loop 3, @Sub1
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 10, 2
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	sound_ret

@Sub2:
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	sound_loop 3, @Sub2
	drum_note 10, 4
	drum_note 1, 4
	drum_note 1, 2
	drum_note 1, 1
	drum_note 1, 1
	drum_note 1, 2
	drum_note 1, 2
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 2
	drum_note 10, 2
	drum_note 10, 4
	drum_note 1, 4
	drum_note 10, 2
	drum_note 10, 2
	drum_note 1, 4
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
