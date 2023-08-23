.enum $0001
C_:
	.dsb 1
C#:
	.dsb 1
D_:
	.dsb 1
D#:
	.dsb 1
E_:
	.dsb 1
F_:
	.dsb 1
F#:
	.dsb 1
G_:
	.dsb 1
G#:
	.dsb 1
A_:
	.dsb 1
A#:
	.dsb 1
B_:
	.dsb 1
.ende

.enum $0000
CHAN_0:
	.dsb 1
CHAN_1:
	.dsb 1
CHAN_2:
	.dsb 1
CHAN_3:
	.dsb 1
CHAN_4:
	.dsb 4
CHAN_8:
	.dsb 1
CHAN_9:
	.dsb 1
CHAN_A:
	.dsb 1
CHAN_B:
	.dsb 1
CHAN_C:
SFX_CHANNEL = 3
CHANNEL_BIT_MASK = $f
CHANNEL_TOTAL_MASK = $e0
CHANNEL_RAM_STEP_LENGTH = $10
CHANNEL_FLAGS_MASK = $1f
.ende

.enum $0000
; iChannelFlagSection1
SOUND_CHANNEL_ON:
	.dsb 1
SOUND_SUBROUTINE:
	.dsb 1
SOUND_LOOPING:
	.dsb 1
SOUND_READING_MODE:
	.dsb 1
SOUND_NOISE:
	.dsb 1
; SOUND_CRY:
	.dsb 1
SOUND_PITCH_INC_SWITCH:
	.dsb 1
SOUND_DPCM: ; nes only
.ende

.enum $0000
; iChannelFlagSection2
SOUND_VIBRATO:
	.dsb 1
SOUND_PITCH_SLIDE:
	.dsb 1
SOUND_CYCLE_LOOP:
	.dsb 1
SOUND_STACCATO:
	.dsb 1
SOUND_PITCH_MODIFIER:
	.dsb 1
SOUND_ENV_PTRN:
	.dsb 1
SOUND_RELATIVE_PITCH::
;	.dsb 1
; SOUND_STEREO:
.ende

.enum $0000
; iChannelFlagSection3
SOUND_VIBRATO_DIR:
	.dsb 1
SOUND_PITCH_SLIDE_DIR:
	.dsb 1
SOUND_REL_PITCH_FLAG:
	.dsb 1
.ende

.enum $0000
; iChannelNoteFlags
NOTE_CYCLE_OVERRIDE:
	.dsb 1
NOTE_PITCH_OVERRIDE:
	.dsb 1
NOTE_ENV_OVERRIDE:
	.dsb 1
NOTE_PITCH_SWEEP:
	.dsb 1
NOTE_NOISE_SAMPLING:
	.dsb 1
NOTE_REST:
	.dsb 1
NOTE_VIBRATO_OVERRIDE:
	.dsb 1
NOTE_DELTA_OVERRIDE: ; nes only
.ende

.enum $0000
; zAudioCommandFlags
SOUND_EVENT:
	.dsb 1
SFX_PRIORITY:
	.dsb 1
MUSIC_PLAYING:
	.dsb 1
FRAME_SWAP:
	.dsb 1
RCOND_PULSE_1:
	.dsb 1
RCOND_PULSE_2:
	.dsb 1
RCOND_HILL:
	.dsb 1
RCOND_NOISE_DPCM:

; register defs
ENVELOPE_MASK = $3f
CYCLE_MASK = $c0
SOUND_LENGTH_F = 3
SOUND_RAMP_F = 4
SOUND_VOLUME_LOOP_F = 5

; DPCM
SOUND_DPCM_LOOP_F = 6
DPCM_PITCH_MASK = $f

.ende

.enum $00d0
FIRST_SOUND_COMMAND:
; all commands from Pokemon Ray
; only absent commands are those that use features not present on NES (ex. master volume, stereo)
octave_cmd:
	.dsb 8
note_type_cmd:
	.dsb 1
transpose_cmd:
	.dsb 1
tempo_cmd:
	.dsb 1
duty_cycle_cmd:
	.dsb 1
volume_envelope_cmd:
	.dsb 1
pitch_sweep_cmd:
	.dsb 1
duty_cycle_pattern_cmd:
	.dsb 1
toggle_music_cmd:
	.dsb 1
pitch_slide_cmd:
	.dsb 1
vibrato_cmd:
	.dsb 1
staccato_cmd:
	.dsb 1
drum_switch_cmd:
	.dsb 3
pitch_offset_cmd:
	.dsb 1
relative_pitch_cmd:
	.dsb 1
volume_envelope_group_cmd:
	.dsb 1
tempo_relative_cmd:
	.dsb 1
restart_channel_cmd:
	.dsb 1
new_song_cmd:
	.dsb 1
sfx_priority_on_cmd:
	.dsb 1
sfx_priority_off_cmd:
	.dsb 1
sound_jump_flag_cmd:
	.dsb 2
sfx_drum_switch_cmd:
	.dsb 1
pitch_dec_switch_cmd:
	.dsb 1
frame_swap_cmd:
	.dsb 1
set_music_cmd:
	.dsb 6
set_sound_event_cmd:
	.dsb 1
set_condition_cmd:
	.dsb 1
sound_jump_if_cmd:
	.dsb 1
sound_jump_cmd:
	.dsb 1
sound_loop_cmd:
	.dsb 1
sound_call_cmd:
	.dsb 1
sound_ret_cmd:
env_ret_cmd:

env_loop_cmd = env_ret_cmd - 1

.ende