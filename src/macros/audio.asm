MACRO musicPointerOffset label, offset
	.db (label - MusicPointerOffset + offset)
ENDM

MACRO musicPart label
	.db (label - MusicPartPointers)
ENDM

MACRO musicHeaderPointer label
	.db (label - MusicHeaders)
ENDM

;
; MusicHeader macro, to replace this:
;	.db NoteLengthTable_Death
;	.dw MusicDataXXX
;	.db MusicDataXXX_Triangle - MusicDataXXX
;	.db MusicDataXXX_Square1 - MusicDataXXX
;	.db MusicDataXXX_Noise - MusicDataXXX
;	; no noise channel, using $00 from below
;
; Setting "noise" or "dpcm" to -1 will suppress output of $00 for music headers
; "reuse" the note length from the following header to save bytes.
;
MACRO musicHeader noteLengthLabel, square2, triangle, square1, noise, dpcm
	.db noteLengthLabel
	.dw square2
	.db (triangle - square1)
	.db (square1 - square2)

	IF noise > 0
		.db (noise - triangle)
	ENDIF
	IF dpcm > 0
		.db (dpcm - noise)
	ENDIF
ENDM

; define a ROM Bank
MACRO audio_bank num
	IFNDEF NSF_FILE
		.db $80 | num
	ELSE
		.db num
	ENDIF
ENDM

; zNoiseDrumSFX macros
MACRO noise_envelope rampflag, volumeramp
	IF rampflag < 1
		.db $40 + volumeramp
	ELSE
		.db (rampflag << 4) + volumeramp
	ENDIF
ENDM

MACRO noise_adjust length, rampflag, volumeramp
	IF rampflag < 1
		.db $40 + volumeramp
	ELSE
		.db (rampflag << 4) + volumeramp
	ENDIF
	REPT length
		.db $7e
	ENDR
ENDM

MACRO noise_note length, period, division
	.db (period << 7) + division
	IF length > 1
		REPT length - 1
			.db $7e
		ENDR
	ENDIF
ENDM

MACRO noise_ret
	.db 0
ENDM

MACRO note_type ins, length
i = (ins - 1) << 4
	.db $80 + i + length
ENDM

MACRO note pitch, oct
o = (oct - 1) * $18
	.db pitch + o
ENDM

MACRO rest
	.db $7E
ENDM

MACRO sound_ret
	.db $00
ENDM

MACRO toggle_sweep
	.db $00
ENDM

MACRO sound_loop
	.db $00
ENDM

MACRO drum_note id
	.db id * 2
ENDM

MACRO drum_rest
	.db $01
ENDM

MACRO smp_note id
	.db id * 2
ENDM

MACRO sfx_sweep period, dir, step
p = period << 4
d = dir << 3
	.db $80 + p + d + step
ENDM

MACRO sfx_note length, raw_pitch
	.db >($800 + raw_pitch)
	.db <($800 + raw_pitch)
IF length > 1
	REPT length - 1
		.db $40
	ENDR
ENDIF
ENDM