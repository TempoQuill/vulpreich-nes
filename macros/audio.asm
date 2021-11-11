
MACRO music_header total, channel, label
	.db (total - 1) << 5 | channel - 1
	.dw label
ENDM

MACRO music_subheader channel, label
	.db channel - 1
	.dw label
ENDM

MACRO music_leftover channel
	.db channel - 1
ENDM

MACRO pulse_note note_length, rampflag, volumeramp, length, pitch
	.db note_length
	.db rampflag << 4 | volumeramp
	.db <pitch, length << 3 | >pitch
ENDM

MACRO hill_note note_length, flag, linear, length, pitch
	.db note_length
	.db flag << 7 | linear
	.db <pitch, length << 3 | >pitch
ENDM

MACRO noise_note note_length, rampflag, volumeramp, length, mode, pitch
	.db note_length
	.db rampflag << 4 | volumeramp
	.db mode << 7     | pitch
	.db legnth
ENDM

MACRO rest length
	.db 0 << 4 | length - 1
ENDM

MACRO note pitch, length
	.db pitch << 4 | length - 1
ENDM

MACRO drum_note id, length
	note id, length
ENDM

MACRO octave value
	.db octave_cmd | 8 - value ; d0
ENDM

MACRO note_type length, rampflag, volumeramp
	.db note_type_cmd, length ; d8
	.db rampflag << 4 | volumeramp
ENDM

MACRO hill_type length, flag, linear
	note_type length
	.dg flag << 7 | linear
ENDM

MACRO drum_speed length
	note_type length
ENDM

MACRO transpose octave, pitch
	.db transpose_cmd, octave << 4, pitch ; d9
ENDM

MACRO tempo value
	.db tempo_cmd, >value, <value ; da
ENDM

MACRO duty_cycle value
	.db duty_cycle_cmd, value ; db
ENDM

MACRO volume_envelope rampflag, volumeramp
	.db volume_envelope_cmd ; dc
	.db rampflag << 4 | volumeramp
ENDM

MACRO linear_envelope flag, linear
	.db volume_envelope_cmd ; dc
	.db flag << 7 | linear
ENDM

MACRO pitch_sweep enable, period, direction, depth
	.db pitch_sweep_cmd ; dd
	.db enable << 7 | period << 4 | direction << 3 | depth
ENDM

MACRO duty_cycle_pattern cycle1, cycle2, cycle3, cycle4
	.db duty_cycle_pattern_cmd ; de
	.db cycle1 << 6 | cycle2 << 4 | cycle3 << 2 | cycle4
ENDM

MACRO toggle_music
	.db toggle_music_cmd ; df
ENDM

MACRO pitch_slide tail, octave, pitch
	.db pitch_slide_cmd, tail ; e0
	.db octave << 4 | pitch
ENDM

MACRO vibrato preamble, depth, length
	.db vibrato_cmd, preamble ; e1
	.db depth << 4 | length
ENDM

MACRO set_mute_timer delay
	.db set_mute_timer_cmd, delay ; e2
ENDM

MACRO toggle_drum id
	.db toggle_drum_cmd, id ; e3
ENDM

MACRO dummy_e4
	.db $e4
ENDM

MACRO dummy_e4
	.db $e5
ENDM

MACRO pitch_offset modifier
	.db pitch_offset_cmd, >modifier, <modifier ; e7
ENDM

MACRO relative_pitch modifier
	.db relative_pitch_cmd, modifier ; e7
ENDM

MACRO volume_envelope_group id
	.db volume_envelope_group_cmd, id ; e8
ENDM

MACRO tempo_relative offset
	.db tempo_relative_cmd, offset ; e9
ENDM

MACRO restart_channel address
	.db restart_channel_cmd ; ea
	.dw address
ENDM

MACRO new_song id
	.db new_song_cmd, id ; eb
ENDM

MACRO sfx_priority_on
	.db sfx_priority_on_cmd ; ec
ENDM

MACRO sfx_priority_off
	.db sfx_priority_off_cmd ; ed
ENDM

MACRO sound_jump_ram address
	.db sound_jump_ram_cmd ; ee
	.dw address
ENDM

MACRO dummy_ef
	.db $ef
ENDM

MACRO sfx_toggle_drum id
	.db sfx_toggle_drum_cmd, id ; f0
ENDM

MACRO pitch_dec_switch
	.db pitch_dec_switch_cmd ; f1
ENDM

MACRO frame_swap
	.db frame_swap_cmd ; f2
ENDM

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

MACRO set_sound_event
	,db set_sound_event_cmd ; f9
ENDM

MACRO set_condition condition
	.db set_condition_cmd, condition ; fa
ENDM

MACRO sound_jump_if condition, address
	.db sound_jump_if_cmd, condition ; fb
	.dw address
ENDM

MACRO sound_jump address
	.db sound_jump_cmd ; fc
	.dw address
ENDM

MACRO sound_loop counter, address
	.db sound_loop_cmd, counter ; fd
	.dw address
ENDM

MACRO sound_call address
	.db sound_call_cmd ; fe
	.dw address
ENDM

MACRO sound_ret
	.db sound_ret_cmd ; ff
ENDM