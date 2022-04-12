SFX_FoxExclamation:
	sfx_header 1, 5, SFX_FoxExclamation_DPCM

SFX_FoxCursor:
	sfx_header 1, 5, SFX_FoxCursor_DPCM

SFX_FoxSelect:
	sfx_header 1, 5, SFX_FoxSelect_DPCM

SFX_CatExclamation:
	sfx_header 1, 5, SFX_CatExclamation_DPCM

SFX_CatCursor:
	sfx_header 1, 5, SFX_CatCursor_DPCM

SFX_CatSelect:
	sfx_header 1, 5, SFX_CatSelect_DPCM

SFX_DogExclamation:
	sfx_header 1, 5, SFX_DogExclamation_DPCM

SFX_DogCursor:
	sfx_header 1, 5, SFX_DogCursor_DPCM

SFX_DogSelect:
	sfx_header 1, 5, SFX_DogSelect_DPCM

SFX_IggyVoice0: ; idle
	sfx_header 1, 5, SFX_IggyVoice0_DPCM

SFX_IggyVoice1: ; angry
	sfx_header 1, 5, SFX_IggyVoice1_DPCM

SFX_IggyVoice2: ; curious
	sfx_header 1, 5, SFX_IggyVoice2_DPCM

SFX_IggyVoice3: ; talking
	sfx_header 1, 5, SFX_IggyVoice3_DPCM

SFX_IggyVoice4: ; bummed
	sfx_header 1, 5, SFX_IggyVoice4_DPCM

SFX_JuneVoice0: ; idle
	sfx_header 1, 5, SFX_JuneVoice0_DPCM

SFX_JuneVoice1: ; angry
	sfx_header 1, 5, SFX_JuneVoice1_DPCM

SFX_JuneVoice2: ; curious
	sfx_header 1, 5, SFX_JuneVoice2_DPCM

SFX_JuneVoice3: ; talking
	sfx_header 1, 5, SFX_JuneVoice3_DPCM

SFX_JuneVoice4: ; bummed
	sfx_header 1, 5, SFX_JuneVoice4_DPCM

SFX_OtisVoice0: ; idle
	sfx_header 1, 5, SFX_OtisVoice0_DPCM

SFX_OtisVoice1: ; angry
	sfx_header 1, 5, SFX_OtisVoice1_DPCM

SFX_OtisVoice2: ; curious
	sfx_header 1, 5, SFX_OtisVoice2_DPCM

SFX_OtisVoice3: ; talking
	sfx_header 1, 5, SFX_OtisVoice3_DPCM

SFX_OtisVoice4: ; bummed
	sfx_header 1, 5, SFX_OtisVoice4_DPCM

SFX_DoorClick:
	sfx_header 1, 4, SFX_DoorClick_Noise

SFX_DoorShut:
	sfx_header 1, 4, SFX_DoorShut_Noise

SFX_DoorSlam:
	sfx_header 1, 4, SFX_DoorSlam_Noise

SFX_Sink:
	sfx_header 1, 4, SFX_Sink_Noise

SFX_ObjectiveComplete:
	sfx_header 5, 1, SFX_ObjectiveComplete_Pulse1
	sfx_subheader 2, SFX_ObjectiveComplete_Pulse2
	sfx_subheader 3, SFX_ObjectiveComplete_Hill
	sfx_subheader 4, SFX_ObjectiveComplete_Noise
	sfx_subheader 5, SFX_ObjectiveComplete_DPCM

SFX_ObjectiveComplete_Pulse1:
	set_music
	tempo 142
	vibrato 10, 5, 4
	set_mute_timer 3
	note_type 6, 1, 10
	rest 4
	octave 3
	note D_, 6
	octave 2
	note B_, 1
	octave 3
	note D_, 1
	note G_, 4
	duty_cycle 2
	volume_envelope 1, 15
	note B_, 4
	note G_, 4
	duty_cycle 0
	volume_envelope 1, 10
	note E_, 4
	note C_, 4
	octave 2
	note B_, 4
	duty_cycle 2
	vibrato 4, 7, 5
	set_mute_timer 15
	volume_envelope 0, 9
	note A_, 6
	octave 3
	note C_, 6
	set_mute_timer 11
	octave 2
	note B_, 8
	sound_ret

SFX_ObjectiveComplete_Pulse2:
	set_music
	duty_cycle 1
	vibrato 4, 7, 5
	note_type 6, 0, 9
	rest 4
	octave 1
	note G_, 8
	rest 4
	note B_, 4
	octave 2
	note C_, 8
	rest 4
	note C#, 4
	duty_cycle 0
	octave 3
	note C_, 1
	duty_cycle 1
	octave 2
	note D_, 3
	rest 2
	duty_cycle 0
	octave 3
	note D_, 1
	duty_cycle 1
	octave 1
	note D_, 3
	rest 2
	duty_cycle 0
	octave 3
	note D_, 1
	duty_cycle 1
	octave 1
	note D_, 2
	rest 6
	sound_ret

SFX_ObjectiveComplete_Hill:
	set_music
	hill_type 8, 0, 19
	octave 5
	note D_, 1
	note G_, 1
	note B_, 1
	hill_type 6, 0, 47
	octave 6
	note D_, 4
	note C_, 4
	octave 5
	note B_, 4
	linear_envelope 0, 15
	octave 6
	note C#, 1
	linear_envelope 0, 39
	note D_, 3
	linear_envelope 0, 47
	note C_, 4
	octave 5
	note B_, 4
	note A_, 4
	note G_, 4
	note F#, 6
	linear_envelope 0, 15
	note G#, 1
	linear_envelope 0, 47
	note A_, 5
	note G_, 8
	sound_ret

SFX_ObjectiveComplete_Noise:
	set_music
	sfx_drum_on 1
	drum_speed 12
	rest 2
	drum_note 1, 2
	drum_note 4, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 4, 2
	drum_note 1, 2
	drum_note 1, 2
	drum_note 4, 3
	drum_note 4, 3
	drum_note 4, 4
	sound_ret

SFX_ObjectiveComplete_DPCM:
	set_music
	drum_speed 8
	drum_note 4, 1
	drum_note 4, 1
	drum_note 4, 1
	drum_speed 12
	drum_note 9, 2
	drum_note 6, 2
	drum_note 4, 2
	drum_note 9, 2
	drum_note 9, 2
	drum_note 6, 2
	drum_note 4, 2
	drum_note 9, 2
	drum_note 4, 3
	drum_note 4, 3
	drum_note 4, 4
	sound_ret

SFX_DoorClick_Noise:
	noise_note 7, 0, 0, 0, 12
	noise_note 7, 0, 0, 0, 11
	sound_ret

SFX_DoorShut_Noise:
	noise_note 0, 0, 0, 0, 12
	noise_note 12, 0, 2, 0, 10
	sound_ret

SFX_DoorSlam_Noise:
	noise_note 1, 0, 15, 0, 13
	noise_note 1, 0, 15, 1, 13
	noise_note 59, 0, 15, 0, 12
	sound_ret

SFX_Sink_Noise:
	noise_note 2, 1, 7, 0, 1
	noise_note 2, 1, 6, 0, 2
	sound_jump_flag SFX_Sink_Noise_ret
	sound_jump SFX_Sink_Noise
SFX_Sink_Noise_ret:
	sound_ret

SFX_IggyVoice0_DPCM:
	dpcm_note 31, PRG_DPCM3, $c000, $74
	sound_ret

SFX_IggyVoice1_DPCM:
	dpcm_note 31, PRG_DPCM4, $c000, $54
	sound_ret

SFX_IggyVoice2_DPCM:
	dpcm_note 31, PRG_DPCM3, $c740, $76
	sound_ret

SFX_IggyVoice3_DPCM:
	dpcm_note 31, PRG_DPCM3, $cec0, $87
	sound_ret

SFX_IggyVoice4_DPCM:
	dpcm_note 31, PRG_DPCM3, $d740, $7a
	sound_ret

SFX_JuneVoice0_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 11
	drum_note 6, 3
	sound_ret

SFX_JuneVoice1_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 7
	drum_note 7, 4
	sound_ret

SFX_JuneVoice2_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 27
	drum_note 8, 1
	sound_ret

SFX_JuneVoice3_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 19
	drum_note 9, 1
	sound_ret

SFX_JuneVoice4_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 5
	drum_note 10, 5
	sound_ret

SFX_OtisVoice0_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 7
	drum_note 1, 5
	sound_ret

SFX_OtisVoice1_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 23
	drum_note 2, 4
	sound_ret

SFX_OtisVoice2_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 11
	drum_note 3, 5
	sound_ret

SFX_OtisVoice3_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 7
	drum_note 4, 2
	sound_ret

SFX_OtisVoice4_DPCM:
	toggle_music
	sfx_drum_on 6
	drum_speed 11
	drum_note 5, 4
	sound_ret

SFX_FoxExclamation_DPCM:
	dpcm_note 20, PRG_DPCM0, $c000, $46
	sound_ret

SFX_FoxCursor_DPCM:
	dpcm_note 20, PRG_DPCM0, $c480, $0d
	sound_ret

SFX_FoxSelect_DPCM:
	dpcm_note 20, PRG_DPCM0, $c580, $57
	sound_ret

SFX_CatExclamation_DPCM:
	dpcm_note 20, PRG_DPCM0, $cb00, $45
	sound_ret

SFX_CatCursor_DPCM:
	dpcm_note 20, PRG_DPCM0, $cf80, $0d
	sound_ret

SFX_CatSelect_DPCM:
	dpcm_note 20, PRG_DPCM0, $d080, $57
	sound_ret

SFX_DogExclamation_DPCM:	
	dpcm_note 20, PRG_DPCM0, $d600, $45
	sound_ret

SFX_DogCursor_DPCM:
	dpcm_note 20, PRG_DPCM1, $c000, $0d
	sound_ret

SFX_DogSelect_DPCM:
	dpcm_note 20, PRG_DPCM0, $da80, $57
	sound_ret
