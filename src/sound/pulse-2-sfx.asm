Pulse2SFX_Stop:
	sfx_sweep 0, 1, 7
	sfx_note 1, $7e
	sfx_note 1, $86
	sfx_note 1, $8e
	sfx_note 1, $86
	sfx_note 1, $7e

	sfx_note 1, $86
	sfx_note 1, $8e
	sfx_note 1, $96
	sfx_note 1, $8e
	sfx_note 1, $86

	sfx_note 1, $8e
	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $96
	sfx_note 1, $8e

	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $a9
	sfx_note 1, $9f
	sfx_note 1, $96

	sfx_note 1, $8e
	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $96
	sfx_note 1, $8e

	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $a9
	sfx_note 1, $9f
	sfx_note 1, $96

	sfx_note 1, $8e
	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $96
	sfx_note 1, $8e

	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $a9
	sfx_note 1, $9f
	sfx_note 1, $96

	sfx_note 1, $8e
	sfx_note 1, $96
	sfx_note 1, $9f
	sfx_note 1, $96
	sfx_note 1, $8e
	sound_ret

Pulse2SFX_Jump:
	sfx_sweep 0, 1, 3
	sfx_note 7, $11c
	sound_ret

Pulse2SFX_None:
	sound_ret