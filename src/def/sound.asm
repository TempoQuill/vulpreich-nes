
C_ = 1
C# = 2
D_ = 3
D# = 4
E_ = 5
F_ = 6
F# = 7
G_ = 8
G# = 9
A_ = 10
A# = 11
B_ = 12

CHAN_0 = 0
CHAN_1 = 1
CHAN_2 = 2
CHAN_3 = 3
CHAN_4 = 4
CHAN_8 = 8
CHAN_9 = 9
CHAN_A = 10
CHAN_B = 11
CHAN_C = 12
SFX_CHANNEL = 3
CHANNEL_BIT_MASK = $f
CHANNEL_TOTAL_MASK = $e0
CHANNEL_RAM_STEP_LENGTH = $10
CHANNEL_FLAGS_MASK = $1f

SOUND_CHANNEL_ON       = 0
SOUND_SUBROUTINE       = 1
SOUND_LOOPING          = 2
SOUND_READING_MODE     = 3
SOUND_NOISE            = 4
SOUND_PITCH_INC_SWITCH = 6
SOUND_DPCM             = 7

SOUND_VIBRATO        = 0
SOUND_PITCH_SLIDE    = 1
SOUND_CYCLE_LOOP     = 2
SOUND_MUTE           = 3
SOUND_PITCH_MODIFIER = 4
SOUND_ENV_PTRN       = 5
SOUND_RELATIVE_PITCH = 6
SOUND_BCD            = 7

SOUND_VIBRATO_DIR     = 0
SOUND_PITCH_SLIDE_DIR = 1
SOUND_REL_PITCH_FLAG  = 2

NOTE_CYCLE_OVERRIDE   = 0
NOTE_PITCH_OVERRIDE   = 1
NOTE_ENV_OVERRIDE     = 2
NOTE_PITCH_SWEEP      = 3
NOTE_NOISE_SAMPLING   = 4
NOTE_REST             = 5
NOTE_VIBRATO_OVERRIDE = 6
NOTE_DELTA_OVERRIDE   = 7

; zAudioCommandFlags
SOUND_EVENT      = 0
SFX_PRIORITY     = 1
MUSIC_PLAYING    = 2
FRAME_SWAP       = 3
RCOND_PULSE_1    = 4
RCOND_PULSE_2    = 5
RCOND_HILL       = 6
RCOND_NOISE_DPCM = 7

ENVELOPE_MASK = $3f
CYCLE_MASK = $c0
SOUND_LENGTH_F = 3
SOUND_RAMP_F = 4
SOUND_VOLUME_LOOP_F = 5

SOUND_DPCM_LOOP_F = 4
DPCM_PITCH_MASK = $f

FIRST_SOUND_COMMAND = $d0

; all commands from Pokemon Ray
; only absent commands are those that use features not present on NES (ex. master volume, stereo)
octave_cmd                = $d0
note_type_cmd             = $d8
transpose_cmd             = $d9
tempo_cmd                 = $da
duty_cycle_cmd            = $db
volume_envelope_cmd       = $dc
pitch_sweep_cmd           = $dd
duty_cycle_pattern_cmd    = $de
toggle_music_cmd          = $df
pitch_slide_cmd           = $e0
vibrato_cmd               = $e1
set_mute_timer_cmd        = $e2
toggle_drum_cmd           = $e3
pitch_offset_cmd          = $e6
relative_pitch_cmd        = $e7
volume_envelope_group_cmd = $e8
tempo_relative_cmd        = $e9
restart_channel_cmd       = $ea
new_song_cmd              = $eb
sfx_priority_on_cmd       = $ec
sfx_priority_off_cmd      = $ed
sound_jump_flag_cmd       = $ee
sfx_toggle_drum_cmd       = $f0
pitch_dec_switch_cmd      = $f1
frame_swap_cmd            = $f2
set_music_cmd             = $f3
set_sound_event_cmd       = $f9
set_condition_cmd         = $fa
sound_jump_if_cmd         = $fb
sound_jump_cmd            = $fc
sound_loop_cmd            = $fd
sound_call_cmd            = $fe
sound_ret_cmd             = $ff

env_loop_cmd = $fe
env_ret_cmd  = $ff
