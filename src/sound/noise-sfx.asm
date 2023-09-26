NoiseSFX_Hihat:
	noise_envelope 1, 8
	noise_note 2, 0, 3
	noise_envelope 1, 3
	noise_note 2, 0, 2
	noise_envelope 1, 1
	noise_note 2, 0, 1
	noise_ret

NoiseSFX_Crash:
	noise_envelope 0, 0
	noise_note 2, 0, 7
	noise_adjust 2, 1, 8
	noise_adjust 2, 1, 9
	noise_adjust 2, 1, 7
	noise_adjust 2, 1, 6
	noise_adjust 2, 1, 5
	noise_adjust 2, 1, 4
	noise_adjust 2, 1, 3
	noise_adjust 2, 1, 2
	noise_adjust 6, 1, 1
	noise_ret

NoiseSFX_QuietHihat:
	noise_envelope 1, 2
	noise_note 2, 0, 1
	noise_adjust 2, 1, 1
	noise_ret

NoiseSFX_HihatOpen:
	noise_envelope 0, 0
	noise_note 2, 0, 1
	noise_adjust 2, 1, 8
	noise_adjust 2, 1, 9
	noise_adjust 2, 1, 7
	noise_adjust 2, 1, 6
	noise_adjust 2, 1, 5
	noise_adjust 2, 1, 4
	noise_adjust 2, 1, 3
	noise_adjust 2, 1, 2
	noise_adjust 6, 1, 1
	noise_ret

NoiseSFX_DryHihat:
	noise_envelope 1, 8
	noise_note 2, 0, 1
	noise_ret

NoiseSFX_DoubleClap:
	noise_envelope 1, 12
	noise_note 2, 0, 11
	noise_envelope 1, 10
	noise_note 2, 0, 10
	noise_adjust 2, 1, 8
	noise_adjust 4, 1, 6
	noise_envelope 1, 12
	noise_note 2, 0, 9
	noise_envelope 1, 10
	noise_note 2, 0, 10
	noise_adjust 2, 1, 8
	noise_adjust 4, 1, 6
	noise_adjust 2, 1, 4
	noise_adjust 2, 1, 2
	noise_ret

NoiseSFX_Snare:
	noise_envelope 1, 15
	noise_note 1, 1, 13
	noise_note 1, 0, 11
	noise_note 1, 0, 9
	noise_adjust 1, 1, 12
	noise_adjust 1, 1, 9
	noise_adjust 1, 1, 6
	noise_adjust 1, 1, 3
	noise_adjust 1, 1, 2
	noise_adjust 1, 1, 1
	noise_ret

NoiseSFX_Kick:
	noise_envelope 1, 15
	noise_note 1, 1, 13
	noise_note 1, 1, 14
	noise_envelope 0, 0
	noise_note 3, 0, 1
	noise_ret

NoiseSFX_DoorClick:
	noise_envelope 0, 0
	noise_note 8, 0, 12
	noise_note 3, 0, 11
	noise_ret

NoiseSFX_DoorClose:
	noise_envelope 0, 0
	noise_note 1, 0, 12
	noise_envelope 0, 2
	noise_note 11, 0, 12
	noise_ret

NoiseSFX_DoorSlam:
	noise_envelope 0, 15
	noise_note 2, 0, 13
	noise_note 2, 1, 13
	noise_note 60, 0, 12
	noise_ret

NoiseSFX_Sink:
	noise_envelope 1, 7
	noise_note 3, 0, 1
	noise_envelope 1, 6
	noise_note 3, 0, 2
	noise_ret

NoiseSFX_None:
	noise_ret
