
MACRO music_header total, channel, label
	.db (total - 1) << 5 | channel - 1
	.dw label
ENDM

MACRO music_subheader channel, label
	.db channel - 1
	.dw label
ENDM

MACRO noise_note length, rampflag, volumeramp, mode, pitch
	.db length
	.db rampflag << 4 | volumeramp
	.db mode << 7     | pitch
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
	.dg flag << 7 | linear
ENDM

MACRO vibrato preamble, depth, length
	.db vibrato_cmd, preamble ; e1
	.db depth << 4 | length
ENDM

MACRO toggle_drum id
	.db toggle_drum_cmd, id ; e3
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