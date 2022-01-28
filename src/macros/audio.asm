; header is split into 3 macros due to assembler limitations
; sound effects have equivalent macros
MACRO music_header total, channel, label
	.db ((total - 1) << 5 | channel - 1), <label, >label
ENDM

MACRO music_subheader channel, label
	.db channel - 1, <label, >label
ENDM

MACRO music_leftover channel
	.db channel - 1
ENDM

MACRO sfx_header total, channel, label
	.db ((total - 1) << 5 | channel + 7), <label, >label
ENDM

MACRO sfx_subheader channel, label
	.db channel + 7, <label, >label
ENDM

MACRO sfx_leftover channel
	.db channel + 7
ENDM

; sound effect note, 1/2 share the same macro
; other channels have their own
MACRO pulse_note note_length, rampflag, volumeramp, length, pitch
	.db note_length, rampflag << 4 | volumeramp, <pitch, length << 3 | >pitch
ENDM

MACRO hill_note note_length, flag, linear, length, pitch
	.db note_length, flag << 7 | linear, <pitch, length << 3 | >pitch
ENDM

MACRO noise_note length, rampflag, volumeramp, mode, pitch
	.db length, rampflag << 4 | volumeramp, mode << 7 | pitch
ENDM

MACRO dpcm_note length, bank, addr, size
	.db length, bank, (addr & %0011111111000000) >> 6, size
ENDM

; used for drum kits
MACRO dpcm_entry bank, pitch, addr, size
	.db bank, pitch, (addr & %0011111111000000) >> 6, size
ENDM

MACRO rest length
	.db 0 << 4 | length - 1
ENDM

MACRO note pitch, length
	.db pitch << 4 | length - 1
ENDM

; noise / DPCM
MACRO drum_note id, length
	.db id << 4 | length - 1
ENDM

MACRO octave value
	.db octave_cmd | 8 - value ; d0
ENDM

; channel 1/2
MACRO note_type length, rampflag, volumeramp
	.db note_type_cmd, length, rampflag << 4 | volumeramp
ENDM

; channel 3
MACRO hill_type length, flag, linear
	.db note_type_cmd, length, flag << 7 | linear
ENDM

; noise / DPCM
MACRO drum_speed length
	.db note_type_cmd, length
ENDM

MACRO transpose octave, pitch
	.db transpose_cmd, octave << 4 | pitch
ENDM

; value / 256 = speed
; 256 = 1 frame
MACRO tempo value
	.db tempo_cmd, >value, <value ; da
ENDM

; only valid on channels 1/2
MACRO duty_cycle value
	.db duty_cycle_cmd, value ; db
ENDM

; only valid on channels 1/2
MACRO volume_envelope rampflag, volumeramp
	.db volume_envelope_cmd, (rampflag << 4) | volumeramp
ENDM

; only valid on channels 3
MACRO linear_envelope flag, linear
	.db volume_envelope_cmd, flag << 7 | linear
ENDM

; only valid on channels 1/2
MACRO pitch_sweep enable, period, direction, depth
	.db pitch_sweep_cmd, enable << 7 | period << 4 | direction << 3 | depth
ENDM

; only valid on channels 1/2
MACRO duty_cycle_pattern cycle1, cycle2, cycle3, cycle4
	.db duty_cycle_pattern_cmd, cycle1 << 6 | cycle2 << 4 | cycle3 << 2 | cycle4
ENDM

; switch between data reading modes
MACRO toggle_music
	.db toggle_music_cmd ; df
ENDM

; implemented for channels 1-3
MACRO pitch_slide tail, octave, pitch
	.db pitch_slide_cmd, tail, (8 - octave) << 4 | pitch
ENDM

MACRO vibrato preamble, depth, length
	.db vibrato_cmd, preamble, depth << 4 | length
ENDM

; only works in Ray and Vulpreich
MACRO set_mute_timer delay
	.db set_mute_timer_cmd, delay ; e2
ENDM

; noise / DPCM
; if both channels are active, macro is used on noise
MACRO toggle_drum id
	.db toggle_drum_cmd, id ; e3
ENDM

; force_stereo_panning / old_panning
; obviously axed when migrating the sound engine to NES
MACRO dummy_e4
	.db $e4
ENDM

; volume
; obviously axed when migrating the sound engine to NES
MACRO dummy_e5
	.db $e5
ENDM

; obsolete equivalent to pitch_dec_switch
MACRO pitch_offset modifier
	.db pitch_offset_cmd, >modifier, <modifier ; e6
ENDM

; set a note medium
MACRO relative_pitch modifier
	.db relative_pitch_cmd, modifier ; e7
ENDM

; unorthodox on GB/C, old hat on NES though
MACRO volume_envelope_group id
	.db volume_envelope_group_cmd, id ; e8
ENDM

; adjust tempo with a signed offset
MACRO tempo_relative offset
	.db tempo_relative_cmd, offset ; e9
ENDM

MACRO restart_channel address
	.db restart_channel_cmd, <address, >address
ENDM

; two bytes on GB, converted to one on NES due to index limitations
MACRO new_song id
	.db new_song_cmd, id ; eb
ENDM

MACRO sfx_priority_on
	.db sfx_priority_on_cmd ; ec
ENDM

MACRO sfx_priority_off
	.db sfx_priority_off_cmd ; ed
ENDM

; uses exclusive flags in zAudioCommandFlags
MACRO sound_jump_flag address
	.db sound_jump_flag_cmd, <address, >address
ENDM

; stereo
; obviously axed when migrating the sound engine to NES
MACRO dummy_ef
	.db $ef
ENDM

MACRO sfx_toggle_drum id
	.db sfx_toggle_drum_cmd, id ; f0
ENDM

; from Ray, renamed to retain technical accuracy
MACRO pitch_dec_switch
	.db pitch_dec_switch_cmd ; f1
ENDM

; uses FRAME_SWAP in zAudioCommandFlags
MACRO frame_swap
	.db frame_swap_cmd ; f2
ENDM

; force engine into music data reading mode
MACRO set_music
	.db set_music_cmd ; f3
ENDM

MACRO dummy_f4
	.db $f4
ENDM

MACRO dummy_f5
	.db $f5
ENDM

MACRO dummy_f6
	.db $f6
ENDM

MACRO dummy_f7
	.db $f7
ENDM

MACRO dummy_f8
	.db $f8
ENDM

; uses SOUND_EVENT in zAudioCommandFlags
MACRO set_sound_event
	,db set_sound_event_cmd ; f9
ENDM

MACRO set_condition condition
	.db set_condition_cmd, condition ; fa
ENDM

MACRO sound_jump_if condition, address
	.db sound_jump_if_cmd, condition, <address, >address
ENDM

; renders "sound_loop 0" obsolete
MACRO sound_jump address
	.db sound_jump_cmd, <address, >address
ENDM

MACRO sound_loop counter, address
	.db sound_loop_cmd, counter, <address, >address
ENDM

MACRO sound_call address
	.db sound_call_cmd, <address, >address
ENDM

MACRO sound_ret
	.db sound_ret_cmd ; ff
ENDM
