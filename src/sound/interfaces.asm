; +------------+
; |Update Sound|
; +------------+
; This function runs every frame and jumps to the sound engine to get
; everything there done.
;
; The current song bank is loaded into the CPU alongside the sound engine
; because this is also responsible for playing all audio.
UpdateSound:
	PHP
	PHA
	PHX
	PHY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	STA zCurrentWindow
	LDA zMusicBank
	STA MMC5_PRGBankSwitch3
	STA zCurrentWindow + 1
	JSR StartProcessingSoundQueue
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

; +----------------------------+
; |Play designated sound effect|
; +----------------------------+
; This function automatically writes to a spot in Zero-Page RAM specified by a
; string of data in order to play a sound reliably.
;
; The function ejects early if it detects a given sound effect's class has been
; turned off.
;
; It also fakes bit priority by only writing values in the spot already written
; to if the new value is lower than or equal to the old value.
PlaySFX:
	PHP
	PHA
	PHX
	PHY
	TAX
	DEY
	LDA #PRG_Audio
	STA MMC5_PRGBankSwitch2
	LDA SoundEffectClasses, Y
	AND zOptions
	BEQ @Skip
	LDA SoundEffectDestinations, Y
	STA zCurrentMusicPointer
	LDY #0
	STY zCurrentMusicPointer + 1
	LDA (zCurrentMusicPointer), Y
	BEQ @Stash
	TXA
	CMP (zCurrentMusicPointer), Y
	BCS @Skip
@Stash:
	TXA
	STA (zCurrentMusicPointer), Y
@Skip:
	JSR UpdatePRG
	PLY
	PLX
	PLA
	PLP
	RTS

WaitPlaySFX:
	JSR WaitSFX
	JMP PlaySFX

WaitSFX:
	LDA zCurrentDPCMSFX
	ORA zCurrentNoiseSFX
	ORA zCurrentPulse2SFX
	BNE WaitSFX
	RTS

SkipMusic:
	TAB
	BNE @Update
	RTS
@Update:
	SBC #1
	JSR UpdateSound
	JMP SkipMusic

CheckSFX:
	LDA zCurrentDPCMSFX
	ORA zCurrentNoiseSFX
	ORA zCurrentPulse2SFX
	BNE @On
	CLC
	RTS

@On:
	SEC
	RTS
