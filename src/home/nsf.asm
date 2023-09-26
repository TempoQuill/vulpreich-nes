.base $e080
LOAD:
INIT:
IFDEF NSF_SFX
	TAY
	TAX
	DEY
	LDA SoundEffectDestinations, Y
	STA zCurrentMusicPointer
	LDY #0
	STY zCurrentMusicPointer + 1
	TXA
	STA (zCurrentMusicPointer), Y
	RTS
ELSE
	STA zMusicQueue
	RTS
ENDIF

PLAY:
	JMP StartProcessingSoundQueue

SetMusicBank:
	ASL A
	STA NSF_PRGBank2
	ORA #1
	STA NSF_PRGBank3
	RTS

.pad $f000, 0

	.dsb $1000, 0