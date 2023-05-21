; The entire sound engine. Uses 00-21 in ZP RAM and 0200-04bf in internal RAM.

; Interfaces are in bank 7f.

_InitSound:
; restart sound operation
; clear all relevant hardware registers & ram
	PHP
	PHA
	PHX
	PHY
	JSR MusicOff
	JSR ClearChannels
	; clear 0000-0022
	LDX #zAudioRAMEnd
@ClearZP:
	DEX
	STA zAudioRAM, X
	BNE @ClearZP
	; clear 0200-04bf
	LDX #<iChannelRAMEnd
@ClearCRAMPart1:
	DEX
	STA iChannelRAM + $200, X
	BNE @ClearCRAMPart1
@ClearCRAMPart2:
	DEX
	STA iChannelRAM, X
	STA iChannelRAM + $100, X
	BNE @ClearCRAMPart2

	JSR MusicOn
	PLY
	PLX
	PLA
	PLP
	RTS

PreserveIDRestart:
; restart but preserve music id
	LDA zMusicID
	PHA
	JSR _InitSound
	PLA
	STA zMusicID
	RTS

MusicOn:
	LDA zAudioCommandFlags
	SSB MUSIC_PLAYING
	STA zAudioCommandFlags
	RTS

MusicOff:
	LDA zAudioCommandFlags
	RSB MUSIC_PLAYING
	STA zAudioCommandFlags
	RTS

_UpdateSound:
; called once per frame
	; no use updating audio if it's not playing
	LDA zAudioCommandFlags
	TSB MUSIC_PLAYING
	BNE @PlayerOn
	RTS
@PlayerOn:
	LDA zMixer
	AND #CHANNEL_FLAGS_MASK
	; is DPCM on? We are working around a hardware bug!
	CMP #1 << CHAN_4
	PHA ; save output for later
	BCC @SkipWorkaround
	LDA zMixer
	CMP #CHANNEL_FLAGS_MASK
	BEQ @SkipWorkaround
	PLA
	LDA #CHANNEL_FLAGS_MASK
	STA zMixer
	PHA ; save output for later
@SkipWorkaround:
	; start at ch1
	LDX #CHAN_0
	STX zCurrentChannel
@Loop:
	; check channel power
	LDA iChannelFlagSection1, X
	LSR A ; SOUND_CHANNEL_ON
	BCS @AndItsOn ; aaaaand it's on!
	JMP @NextChannel
@AndItsOn:
	; check time left in the current note
	LDA iChannelNoteDuration, X
	CMP #2 ; 1 or 0?
	BCC @NoteOver
	DEC iChannelNoteDuration, X
	BCS @ContinueSoundUpdate

@NoteOver:
	; reset vibrato delay
	LDA iChannelVibratoPreamble, X
	STA iChannelVibratoCounter, X
	; turn vibrato off for now
	LDA iChannelFlagSection2, X
	RSB SOUND_VIBRATO
	STA iChannelFlagSection2, X
	; get next note
	JSR ParseNote
@ContinueSoundUpdate:
	JSR ApplyPitchSlide
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_2
	BEQ @Hill
	CMP #CHAN_4 ; dpcm has no volume/length control beyond sample size
	BEQ @Handlers
	; duty cycle
	LDA iChannelCycle, X
	; volume envelope
	ORA iChannelEnvelope, X
	STA zCurrentTrackEnvelope
	; this assumes we're on pulses or noise
	; 5-7 are skipped entirely later on
	BCC @Continue
@Hill:
	; linear envelope
	LDA iChannelEnvelope, X
	STA zHillLinearLength
@Continue:
	; raw pitch
	LDA iChannelRawPitch + 16, X
	STA zCurrentTrackRawPitch + 1
	LDA iChannelRawPitch, X
	STA zCurrentTrackRawPitch
@Handlers:
	; effects, noise, DPCM
	JSR GeneralHandler
	JSR HandleNoise
	JSR HandleDPCM
	; turn off music when playing sfx?
	LDA zAudioCommandFlags
	TSB SFX_PRIORITY
	BEQ @Next
	; are we in a sfx channel right now?
	TXA ; X = current channel
	TSB SFX_CHANNEL
	BNE @Next
	; are any sfx channels active?
	; if so, mute
	LDA iChannelFlagSection1 + CHAN_8
	LSR A ; SOUND_CHANNEL_ON
	BCS @RestNote
	LDA iChannelFlagSection1 + CHAN_9
	LSR A ; SOUND_CHANNEL_ON
	BCS @RestNote
	LDA iChannelFlagSection1 + CHAN_A
	LSR A ; SOUND_CHANNEL_ON
	BCS @RestNote
	LDA iChannelFlagSection1 + CHAN_B
	LSR A ; SOUND_CHANNEL_ON
	BCS @RestNote
	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON
	BCC @Next
	LDA zMixer
	SSB CHAN_4 ; turn on DPCM
	STA zMixer
@RestNote:
	LDA iChannelNoteFlags, X
	SSB NOTE_REST ; rest
	STA iChannelNoteFlags, X
@Next:
	; are we in a sfx channel right now?
	TXA
	TSB SFX_CHANNEL
	BNE @SFXChannel
	LDA iChannelFlagSection1 + (1 << SFX_CHANNEL), X
	LSR A ; SOUND_CHANNEL_ON
	BCS @SoundChannelOn
@SFXChannel:
	JSR UpdateChannels
@SoundChannelOn:
	; clear note flags
	LDA #0
	STA iChannelNoteFlags, X
@NextChannel:
	; next channel
	INX
	INC zCurrentChannel
	CPX #CHAN_C + 1
	BCS @Done
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_4 + 1
	BCS @NextChannel ; zCurrentChannel > DPCM means go straight to the next channel
	JMP @Loop

@Done:
	LDA zMixer
	AND #CHANNEL_FLAGS_MASK
	CMP #1 << CHAN_4
	PLA ; output from previous frame
	BCS @FinishedUpdate
	CMP zMixer
	BEQ @FinishedUpdate
	LDA zMixer
	STA SND_CHN
@FinishedUpdate:
	JMP TryMusic

; X = current channel, Y = pointer offset, A = pointer data
UpdateChannels:
	TXA
	ASL A
	TAY
	LDA @FunctionPointers, Y
	STA zAuxAddresses + 2
	INY
	LDA @FunctionPointers, Y
	STA zAuxAddresses + 3
	JMP (zAuxAddresses + 2)

@FunctionPointers:
; music channels
	.dw @Pulse1
	.dw @Pulse2
	.dw @Hill
	.dw @Noise
	.dw @DPCM
	.dw @None ; not sure how we'd get here without a debugger
	.dw @None ; these channels would be skipped by the update routine
	.dw @None
; sfx channels
; identical to music channels
	.dw @Pulse1
	.dw @Pulse2
	.dw @Hill
	.dw @Noise
	.dw @DPCM
	; $b0bd - PRG ROM - in upper switchable window
	; $2902 - PPU Area mirrored - PPUSTATUS
	; $f008 - PRG ROM - in home window

@Pulse1:
	LDA iChannelNoteFlags, X
	TSB NOTE_PITCH_SWEEP
	BEQ @Pulse1_NoSweep
	LDA zSweep1
	STA SQ1_SWEEP
@Pulse1_NoSweep:
	LDA iChannelNoteFlags, X
	TSB NOTE_REST ; check for rest
	BEQ @Pulse1_Sampling

	LDA zMixer
	RSB CHAN_0 ; turn off square 1
	STA zMixer
	LDY #CHAN_0 << 2
	JMP ClearPulse

@Pulse1_Sampling:
	LDA iChannelNoteFlags, X
	TSB NOTE_NOISE_SAMPLING
	BEQ @Pulse1_Pitch

	LDA zCurrentTrackEnvelope
	STA SQ1_ENV
	LDA zCurrentTrackRawPitch
	STA SQ1_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ1_HI
	RTS

@Pulse1_Pitch:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_PITCH_OVERRIDE | 1 << NOTE_VIBRATO_OVERRIDE
	BEQ @Pulse1_EnvCycle

	TSB NOTE_PITCH_OVERRIDE
	BNE @Pulse1_Slide

	LDA zCurrentTrackRawPitch
	STA SQ1_LO
	RTS

@Pulse1_Slide:
	LDA zCurrentTrackRawPitch + 1
	STA SQ1_HI
	LDA zCurrentTrackRawPitch
	STA SQ1_LO

@Pulse1_EnvCycle:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_CYCLE_OVERRIDE | 1 << NOTE_ENV_OVERRIDE
	BEQ @Pulse1_Quit

	LDA zCurrentTrackEnvelope
	STA SQ1_ENV
	LDA zCurrentTrackRawPitch + 1
	STA SQ1_HI

@Pulse1_Quit:
	RTS

@Pulse2:
	LDA iChannelNoteFlags, X
	TSB NOTE_PITCH_SWEEP
	BEQ @Pulse2_NoSweep
	LDA zSweep2
	STA SQ2_SWEEP
@Pulse2_NoSweep:
	LDA iChannelNoteFlags, X
	TSB NOTE_REST ; check for rest
	BEQ @Pulse2_Sampling

	LDA zMixer
	RSB CHAN_1 ; turn off square 2
	STA zMixer
	LDY #CHAN_1 << 2
	JMP ClearPulse

@Pulse2_Sampling:
	LDA iChannelNoteFlags, X
	TSB NOTE_NOISE_SAMPLING
	BEQ @Pulse2_Pitch

	LDA zCurrentTrackEnvelope
	STA SQ2_ENV
	LDA zCurrentTrackRawPitch
	STA SQ2_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ2_HI
	RTS

@Pulse2_Pitch:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_PITCH_OVERRIDE | 1 << NOTE_VIBRATO_OVERRIDE
	BEQ @Pulse2_EnvCycle

	TSB NOTE_PITCH_OVERRIDE
	BNE @Pulse2_Slide

	LDA zCurrentTrackRawPitch
	STA SQ2_LO
	RTS

@Pulse2_Slide:
	LDA zCurrentTrackRawPitch + 1
	STA SQ2_HI
	LDA zCurrentTrackRawPitch
	STA SQ2_LO

@Pulse2_EnvCycle:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_CYCLE_OVERRIDE | 1 << NOTE_ENV_OVERRIDE
	BEQ @Pulse2_Quit

	LDA zCurrentTrackEnvelope
	STA SQ2_ENV
	LDA zCurrentTrackRawPitch + 1
	STA SQ2_HI

@Pulse2_Quit:
	RTS

@Hill:
	LDA iChannelNoteFlags, X
	TSB NOTE_REST ; check for rest
	BEQ @Hill_Sampling

	LDA zMixer
	RSB CHAN_2 ; turn off hill
	STA zMixer
	LDY #CHAN_2 << 2
	JMP ClearHillDPCM

@Hill_Sampling:
	LDA iChannelNoteFlags, X
	TSB NOTE_NOISE_SAMPLING
	BEQ @Hill_Pitch

	LDA zHillLinearLength
	STA TRI_LINEAR
	LDA zCurrentTrackRawPitch
	STA TRI_LO
	LDA zCurrentTrackRawPitch + 1
	STA TRI_HI
	RTS

@Hill_Pitch:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_PITCH_OVERRIDE | 1 << NOTE_VIBRATO_OVERRIDE
	BEQ @Hill_Quit

	LDA zCurrentTrackRawPitch
	STA TRI_LO
	LDA zCurrentTrackRawPitch + 1
	STA TRI_HI

@Hill_Quit:
	RTS

@Noise:
	LDA iChannelNoteFlags, X
	TSB NOTE_REST
	BEQ @Noise_Sampling

	LDA zMixer
	RSB CHAN_3 ; turn off noise
	STA zMixer
	LDY #CHAN_3 << 2
	JMP ClearNoise

@Noise_Sampling:
	LDA iChannelNoteFlags, X
	TSB NOTE_NOISE_SAMPLING
	BEQ @Noise_Quit

	LDA zCurrentTrackEnvelope
	STA NOISE_ENV
	LDA zCurrentTrackRawPitch
	STA NOISE_LO
	LDA #1 << SOUND_LENGTH_F
	STA NOISE_HI
	RTS

@Noise_Quit:
	RTS

@DPCM:
	LDA iChannelNoteFlags, X
	TSB NOTE_REST
	BEQ @DPCM_DeltaSampling

	LDA zMixer
	RSB CHAN_4 ; turn off DPCM
	STA zMixer
	LDY #CHAN_4 << 2
	JMP ClearHillDPCM

@DPCM_DeltaSampling:
	LDA iChannelNoteFlags, X
	AND #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	BEQ @DPCM_QUit

	LDA zDPCMSamplePitch
	STA DPCM_ENV
	LDA zDPCMSampleOffset
	STA DPCM_OFFSET
	LDA zDPCMSampleLength
	STA DPCM_SIZE
	RTS

@DPCM_QUit
	RTS

@None:
	RTS

TryMusic:
; severely truncated version of FadeMusic
	; don't overwrite channel ID
	PHX
	; get new song ID
	LDA zMusicID
	BEQ @Quit
	CMP iChannelID
	BEQ @Quit
	; restart sound
	JSR PreserveIDRestart
	; load new song
	TAY
	JSR _PlayMusic
@Quit:
	; cleanup
	PLX
	RTS

LoadNote:
	; wait for pitch slide to finish
	LDY iChannelFlagSection2, X
	STY zBackupY
	TYA
	TSB SOUND_PITCH_SLIDE
	BEQ @CheckRelativePitch
	; get note duration
	LDA iChannelNoteDuration, X
	SBC zCurrentNoteDuration
	BPL @PitchSlide_OK
	LDA #1
@PitchSlide_OK:
	STA zCurrentNoteDuration
	; get raw pitch
	LDA iChannelRawPitch, X
	STA zRawPitchBackup
	LDA iChannelRawPitch + 16, X
	STA zRawPitchBackup + 1
	; get direction of pitch slide
	LDA iChannelSlideTarget, X
	SBC iChannelRawPitch, X
	STA zPitchSlideDifference
	LDA iChannelSlideTarget + 16, X
	SBC iChannelRawPitch + 16, X
	STA zPitchSlideDifference + 1
	BCS @PitchSlide_Greater
	LDA iChannelFlagSection3, X
	SSB SOUND_PITCH_SLIDE_DIR
	STA iChannelFlagSection3, X
	; flip bits of differential
	SIW zPitchSlideDifference
	JMP @PitchSlide_Resume

@PitchSlide_Greater:
	; clear directional flag
	LDA iChannelFlagSection3, X
	RSB SOUND_PITCH_SLIDE_DIR
	STA iChannelFlagSection3, X
@PitchSlide_Resume:
	LDY #0 ; quotient
@PitchSlide_Loop:
	; zPitchSlideDifference = x' * zCurrentNoteDuration + y'
	; x' + 1 -> >zPitchSlideDifference
	; y' -> a
	INY
	LDA zPitchSlideDifference
	SBC zCurrentNoteDuration
	STA zPitchSlideDifference
	; borrow is not needed, loop
	BCS @PitchSlide_Loop
	LDA zPitchSlideDifference + 1
	BEQ @PitchSlide_Quit
	DEC zPitchSlideDifference + 1
	BCC @PitchSlide_Loop

@PitchSlide_Quit:
	LDA zPitchSlideDifference ; remainder
	ADC zCurrentNoteDuration
	STY zPitchSlideDifference + 1 ; quotient
	STA iChannelSlideFraction, X ; remainder
	TYA
	STA iChannelSlideDepth, X ; quotient
	LDA #0
	STA iChannelSlideTempo, X

@CheckRelativePitch:
	LDA zBackupY
	ASL A ; SOUND_RELATIVE_PITCH
	BPL @CheckEnvelopePattern
	LDA iChannelRelativeNoteID, X
	BEQ @rp_off
	LDA iChannelFlagSection3, X
	SSB SOUND_REL_PITCH_FLAG
	STA iChannelFlagSection3, X
	BNE @CheckEnvelopePattern
@rp_off:
	LDA iChannelFlagSection3, X
	RSB SOUND_REL_PITCH_FLAG
	STA iChannelFlagSection3, X

@CheckEnvelopePattern:
	LDA zBackupY
	TSB SOUND_ENV_PTRN
	BEQ @CheckStaccato
	LDA iChannelNoteFlags, X
	RSB NOTE_ENV_OVERRIDE
	STA iChannelNoteFlags, X
	; reset offset
	LDA #0
	STA iChannelEnvelopeGroupOffset, X

@CheckStaccato:
	LDA zBackupY
	TSB SOUND_STACCATO
	BNE @Staccato
	RTS
@Staccato:
	; read main byte
	LDA iChannelStaccatoMain, X
	; copy to counter
	STA iChannelStaccatoCounter, X
	RTS

GeneralHandler:
; handle cycle, pitch, env ptrn, staccato, and vibrato
	LDY iChannelFlagSection2, X
	STY zBackupY
	TYA
	TSB SOUND_CYCLE_LOOP ; cycle looping
	BEQ @CheckRelativePitch
	LDA zCurrentTrackEnvelope
	AND #ENVELOPE_MASK
	STA zCurrentTrackEnvelope
	LDA iChannelCyclePattern, X
	ASL iChannelCyclePattern, X
	ROL A
	ASL iChannelCyclePattern, X
	ROL A
	STA iChannelCyclePattern, X
	AND #CYCLE_MASK
	ORA zCurrentTrackEnvelope
	STA zCurrentTrackEnvelope
	LDA iChannelNoteFlags, X
	SSB NOTE_CYCLE_OVERRIDE
	STA iChannelNoteFlags, X
@CheckRelativePitch:
; interesting notes:
;	$d9 and $e7 can stack with each other
;		$d9 $01 and $e7 $01 together would be the same as $d9/e7 $02
;	$e7 $f4-ff can trigger the rest pitch due to a lack of carry
	LDA zBackupY
	ASL A ; SOUND_RELATIVE_PITCH
	BPL @CheckPitchModifier
	; is relative pitch on?
	LDA iChannelFlagSection3, X
	TSB SOUND_REL_PITCH_FLAG
	BEQ @CheckPitchModifier
	; get pitch
	LDA iChannelNoteID, X
	BEQ @CheckPitchModifier
	; add to pitch value
	ADC iChannelRelativeNoteID, X
	STA iChannelNoteID, X
	; get octave
	LDY iChannelOctave, X
	; get final tone
	JSR GetPitch
	STA zCurrentTrackRawPitch
	STY zCurrentTrackRawPitch + 1
@CheckPitchModifier:
	LDA zBackupY
	TSB SOUND_PITCH_MODIFIER
	BEQ @CheckPitchInc
	; sub offset to iChannelRawPitch
	LDA zCurrentTrackRawPitch
	SBC iChannelPitchModifier + 16, X
	STA zCurrentTrackRawPitch
	LDA zCurrentTrackRawPitch + 1
	SBC iChannelPitchModifier, X
	STA zCurrentTrackRawPitch + 1
@CheckPitchInc:
; incidentally, pitch_dec_switch can stack with pitch_offset
; for example, $f1 followed by $e6 $0001 would essentially mean $e6 $0002
	; is pitch inc on?
	LDA iChannelFlagSection1, X
	ASL A ; SOUND_PITCH_INC_SWITCH
	BPL @CheckVibrato
	; is the byte active?
	LDA iChannelPitchIncrementation, X
	BEQ @CheckVibrato
	; if so, inc the pitch by 1
	LDA zCurrentTrackRawPitch
	BEQ @CheckPitchInc_NoCarry
	; inc high byte if low byte rolls over
	DEC zCurrentTrackRawPitch + 1
@CheckPitchInc_NoCarry:
	DEC zCurrentTrackRawPitch
@CheckVibrato:
	; is vibrato on?
	LDA zBackupY
	LSR A ; SOUND_VIBRATO
	BCC @CheckEnvelopePattern
	; is vibrato active for this note yet?
	; is the preamble over?
	LDA iChannelVibratoCounter, X
	BNE @Vibrato_Subexit2
	; is the depth nonzero?
	LDA iChannelVibratoDepth, X
	BEQ @CheckEnvelopePattern
	; save it for later
	STA zVibratoBackup
	; is it time to bend up/down?
	LDA iChannelVibratoTimer, X
	AND #$f ; timer
	BEQ @Vibrato_Bend
	DEC iChannelVibratoTimer, X
	BCS @CheckEnvelopePattern
@Vibrato_Subexit2:
	DEC iChannelVibratoCounter, X
	BCS @CheckEnvelopePattern

@Vibrato_Bend:
	; refresh counter
	LTH A
	ORA iChannelVibratoTimer, X
	STA iChannelVibratoTimer, X
	; get raw pitch
	LDA zCurrentTrackRawPitch
	TAY
	; get direction
	LDA iChannelFlagSection3, X
	PHA
	LSR A ; SOUND_VIBRATO_DIR
	PLA
	BCC @Vibrato_Down
; up
	; vibrato down
	RSB SOUND_VIBRATO_DIR
	STA iChannelFlagSection3, X
	; get the depth
	LDA zVibratoBackup
	AND #$f ; low
	STA zVibratoBackup
	TYA
	SBC zVibratoBackup
	BCS @Vibrato_NoBorrow
	LDA #0
	BEQ @Vibrato_NoCarry
@Vibrato_Down:
	; vibrato up
	SSB SOUND_VIBRATO_DIR
	STA iChannelFlagSection3, X
	STY zVibratoBackup
	; get the depth
	LDA zVibratoBackup
	AND #$f0 ; high
	; move it to lo
	HTL A
	ADC zVibratoBackup
	BCC @Vibrato_NoCarry
	LDA #$ff
@Vibrato_NoBorrow:
@Vibrato_NoCarry:
	STA zCurrentTrackRawPitch
	LDA iChannelNoteFlags, X
	SSB NOTE_VIBRATO_OVERRIDE
	STA iChannelNoteFlags, X
@CheckEnvelopePattern:
	LDA zBackupY
	TSB SOUND_ENV_PTRN
	BEQ @CheckStaccato
	LDA iChannelNoteFlags, X
	SSB NOTE_ENV_OVERRIDE
	STA iChannelNoteFlags, X
	; get group pointer
	LDA iChannelEnvelopeGroup, X
	ASL A
	TAY
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_2
	BEQ @CheckStaccato ; hill has no volume control on its own
	; envelope group
	JSR GetByteInEnvelopeGroup
	BCC @EnvelopePattern_Set
	; if $ff was encountered, the envelope, therefore the note, has ended
	LDA iChannelNoteFlags, X
	SSB NOTE_REST
	STA iChannelNoteFlags, X
	BNE @CheckStaccato

@EnvelopePattern_Set:
	; store envelope during note
	; this was unorthodox in Gameboy titles, but old hat on NES
	; NES doesn't reset phase on envelope update
	ORA iChannelCycle, X
	STA zCurrentTrackEnvelope
	LDA iChannelNoteFlags, X
	SSB NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
@CheckStaccato:
	LDA zBackupY
	TSB SOUND_STACCATO
	BNE @Staccato
	RTS

@Staccato:
	; check for active counter
	LDA iChannelStaccatoCounter, X
	BEQ @Staccato_Enable
	; disable
	DEC iChannelStaccatoCounter, X
	RTS
@Staccato_Enable:
	LDA iChannelNoteFlags, X
	SSB NOTE_REST
	STA iChannelNoteFlags, X
	RTS

ApplyPitchSlide:
	; quit if pitch slide inactive
	LDA iChannelFlagSection2, X
	TSB SOUND_PITCH_SLIDE
	BNE @Now
	RTS
@Now:
	; back up raw pitch
	LDA iChannelRawPitch, X
	STA zRawPitchBackup
	LDA iChannelRawPitch + 16, X
	STA zRawPitchBackup + 1
	; check whether pitch slide is going up or down
	LDA iChannelFlagSection3, X
	TSB SOUND_PITCH_SLIDE_DIR
	BNE @SlidingUp
	; sliding down
	CLC
	LDA zRawPitchBackup
	ADC iChannelSlideDepth, X
	STA iChannelRawPitch, X
	TYA
	ADC #0
	STA iChannelRawPitch + 16, X
	; iChannelSlideTempo += iChannelSlideFraction
	; if rollover: pitch += 1
	LDA iChannelSlideTempo, X
	ADC iChannelSlideFraction, X
	STA iChannelSlideFraction, X
	LDA #0
	ADC iChannelRawPitch, X
	STA iChannelRawPitch, X
	LDA #0
	ADC iChannelRawPitch + 16, X
	STA iChannelRawPitch + 16, X
	; Compare the dw at iChannelSlideTarget to iChannelRawPitch.
	; If pitch is greater, we're finished.
	; Otherwise, load the pitch and set two flags.
	LDA iChannelSlideTarget + 16, X
	CMP iChannelRawPitch + 16, X
	BCC @Finished
	BNE @Continue
	LDA iChannelSlideTarget, X
	CMP iChannelRawPitch, X
	BCC @Finished
	BCS @Continue

@SlidingUp:
	; pitch -= iChannelSlideDepth
	SEC
	LDA zRawPitchBackup
	SBC iChannelSlideDepth, X
	STA iChannelRawPitch, X
	BCS @SlidingUp_NoDec
	DEY
@SlidingUp_NoDec:
	STA iChannelRawPitch + 16, X
	; iChannelSlideTempo *= 2
	; if rollover: pitch -= 1
	LDA iChannelSlideFraction, X
	ASL A
	STA iChannelSlideFraction, X
	LDA iChannelRawPitch, X
	SBC #0
	STA iChannelRawPitch, X
	TYA
	SBC #0
	TAY
	STA iChannelRawPitch + 16, X
	; Compare the dw at iChannelSlideTarget to iChannelRawPitch.
	; If pitch is lower, we're finished.
	; Otherwise, load the pitch and set two flags.
	LDA iChannelRawPitch + 16, X
	CMP iChannelSlideTarget + 16, X
	BCC @Finished
	BNE @Continue
	LDA iChannelRawPitch, X
	CMP iChannelSlideTarget, X
	BCS @Continue
@Finished:
	LDA iChannelFlagSection2, X
	RSB SOUND_PITCH_SLIDE
	STA iChannelFlagSection2, X
	LDA iChannelFlagSection3, X
	RSB SOUND_PITCH_SLIDE_DIR
	STA iChannelFlagSection3, X
	RTS

@Continue:
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_PITCH_OVERRIDE | 1 << NOTE_CYCLE_OVERRIDE
	STA iChannelNoteFlags, X
	RTS

HandleNoise:
	; is noise on?
	LDA iChannelFlagSection1, X
	TSB SOUND_NOISE ; noise
	BNE @CheckIfSFX
	RTS

@CheckIfSFX:
	; are we in a sfx channel?
	TXA
	TSB SFX_CHANNEL
	BNE @Next
	; is ch12 on? (noise)
	; is ch12 playing noise?
	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_NOISE | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS ; quit if so
@Next:
	; exclusive to NES - percussion uses two channels: Noise and DPCM
	LDA zDrumChannel
	SSB CHAN_3
	STA zDrumChannel
	LDA zDrumDelay
	BNE @Read
	DEC zDrumDelay
	RTS

@Read:
; noise struct:
;	[wx] [yy] [zz]
;	w: does nothing
;	x: actual duration - 1
;		1 = 2 2 = 3 etc
;	yy: volume envelope
;       zz: pitch

	; is it empty?
	LDY #0
	LDA zDrumAddresses
	ORA zDrumAddresses + 1
	BEQ @Quit

	LDA (zDrumAddresses), Y
	INC zDrumAddresses

	BNE @SkipCarry1
	INC zDrumAddresses + 1

@SkipCarry1:
	CMP #sound_ret_cmd
	BEQ @Quit

	AND #$f
	STI zDrumDelay ; adds one frame to depicted duration
	LDA (zDrumAddresses), Y
	INC zDrumAddresses
	BNE @SkipCarry2
	INC zDrumAddresses + 1
@SkipCarry2:
	STA zCurrentTrackEnvelope
	LDA (zDrumAddresses), Y
	INC zDrumAddresses
	BNE @SkipCarry3
	INC zDrumAddresses + 1
@SkipCarry3:
	STA zCurrentTrackRawPitch
	LDA #8
	STA zCurrentTrackRawPitch + 1

	LDA iChannelNoteFlags, X
	SSB NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
	RTS

@Quit:
	LDA zDrumChannel
	FSB CHAN_3
	STA zDrumChannel
	RTS

HandleDPCM: ; NES only
	; is SOUND_DPCM on? if so, sign flag is also on
	LDA iChannelFlagSection1, X
	BMI @CheckIfSFX
	RTS

@CheckIfSFX:
	; is ch13 on? (DPCM)
	; is ch13 playing samples?
	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_DPCM | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS ; quit if so

@Next:
	LDA zDrumChannel
	SSB CHAN_4
	STA zDrumChannel

	LDA iChannelNoteDuration, X
	AND #%11111110
	BNE @Read
	RTS

@Read:
; sample struct:
;	[vv] [wx] [yy] [zz]
;	vv: bank # to go into $c000-$dfff
;	w: loop / interrupt request
;	x: pitch
;	yy: sample offset
;       zz: sample size

	; is it empty?
	LDY #0
	LDA zDrumAddresses + 2
	ORA zDrumAddresses + 3
	BEQ @Quit

	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2

	BNE @SkipCarry1
	INC zDrumAddresses + 3

@SkipCarry1:
	STA zDPCMSampleBank
IFNDEF NSF_FILE
	SSB PROGRAM_ROM_F ; ROM Bank insurance
	STA MMC5_PRGBankSwitch4 ; c000-dfff address range
ELSE ; nsf file is 3 byte larger
	STA NSF_PRGBank4 ; c000-cfff
	ADC #0
	STA NSF_PRGBank5 ; d000-dfff
ENDIF
	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BNE @SkipCarry2
	INC zDrumAddresses + 3
@SkipCarry2:
	AND #1 << SOUND_DPCM_LOOP_F | DPCM_PITCH_MASK
	STA zDPCMSamplePitch
	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BNE @SkipCarry3
	INC zDrumAddresses + 3
@SkipCarry3:
	STA zDPCMSampleOffset
	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BNE @SkipCarry4
	INC zDrumAddresses + 3
@SkipCarry4:
	STA zDPCMSampleLength

	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X

	LDA zMixer
	SSB CHAN_4 ; turn on DPCM
	STA zMixer
	RTS

@Quit:
	LDA zDrumChannel
	FSB CHAN_4
	STA zDrumChannel
	LDA zMixer
	RSB CHAN_4 ; turn off DPCM
	STA zMixer
	RTS

ParseNote:
; parses until a note is read or the song is ended
	JSR GetMusicByte ; store next byte in a
	CMP #sound_ret_cmd
	BEQ @SoundRet
	CMP #FIRST_SOUND_COMMAND
	BCC @ReadNote
	; then it's a command
@ReadCommand:
	JSR ParseMusicCommand
	JMP ParseNote ; start over

@ReadNote:
; zCurrentMusicByte contains current note
; special notes
	LDY iChannelFlagSection1, X
	TYA
	TSB SOUND_READING_MODE ; sfx
	BEQ @NextCheck
	TYA
	BMI @DPCM ; if SOUND_DPCM is on, sign flag is also on
	JMP ParseSoundEffect
@DPCM:
	JMP ParseDPCM
@NextCheck:
	TYA
	AND #1 << SOUND_DPCM | 1 << SOUND_NOISE ; noise / DPCM
	BEQ @NormalNote
	JMP GetDrumSample
@NormalNote:
; normal note
	; set note duration (bottom nybble)
	LDA zCurrentMusicByte
	AND #$f
	JSR SetNoteDuration
	; get note ID (top nybble)
	LDA zCurrentMusicByte
	AND #$f0
	BEQ @Rest ; note 0 -> rest
	HTL A
	; update note ID
	STA iChannelNoteID, X
	; store octave in Y
	LDY iChannelOctave, X
	; update raw pitch
	JSR GetPitch
	STA zCurrentTrackRawPitch
	STY zCurrentTrackRawPitch + 1
	; check if note or rest
	LDA iChannelNoteFlags, X
	SSB NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
	JMP LoadNote

@Rest:
; note = rest
	LDA iChannelNoteFlags, X
	SSB NOTE_REST
	STA iChannelNoteFlags, X
	RTS
@SoundRet:
; $ff is reached in music data
	LDA iChannelFlagSection1, X
	TSB SOUND_SUBROUTINE ; in a subroutine?
	BNE @ReadCommand ; execute
	TXA
	CMP #CHAN_8
	BCS @SkipSub
	; check if Channel 9's on
	LDA iChannelFlagSection1 + (1 << SFX_CHANNEL), X
	LSR A ; SOUND_CHANNEL_ON
	BCS @OK
@SkipSub:
	; end music
	TXA
	CMP #CHAN_8
	BNE @OK
	LDA #0
	; no sweep
	STA SQ1_SWEEP ; sweep = 0
	STA SQ2_SWEEP ; sweep = 0
@OK:
; stop playing
	; turn channel off
	LDA iChannelFlagSection1, X
	RSB SOUND_CHANNEL_ON
	STA iChannelFlagSection1, X
	; note = rest
	LDA iChannelNoteFlags, X
	SSB NOTE_REST
	STA iChannelNoteFlags, X
	; clear music id & bank
	LDA #0
	STA iChannelID, X
	STA iChannelBank, X
	RTS

ParseDPCM:
; NOTE: sfx DPCM notes are locked at pitch $f
; in order to have lower pitches, use the sample kits
; sfx dpcm struct:
;	[ww] [xx] [yy] [zz]
;		w - note length (in frames - 1)
;		x - sample bank ($80-$fe)
;		y - sample address
;		z - sample size
	; hack proof
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_4
	BNE ParseSoundEffect

	LDA iChannelNoteFlags, X
	SSB NOTE_DELTA_OVERRIDE
	STA iChannelNoteFlags, X
	; update note duration
	LDA zCurrentMusicByte
	JSR SetNoteDuration ; SFX DPCM notes can be longer than 16
	JSR GetMusicByte
	STA zDPCMSampleBank
	LDA #DPCM_PITCH_MASK ; always highest pitch
	STA zDPCMSamplePitch
	JSR GetMusicByte
	STA zDPCMSampleOffset
	JSR GetMusicByte
	STA zDPCMSampleLength

	LDA zDPCMSampleBank
IFNDEF NSF_FILE
	SSB PROGRAM_ROM_F ; ROM Bank insurance
	STA MMC5_PRGBankSwitch4 ; c000-dfff
ELSE
	STA NSF_PRGBank4 ; c000-cfff
	ADC #0
	STA NSF_PRGBank5 ; d000-dfff
ENDIF
	RTS

ParseSoundEffect:
	; turn noise on
	LDA iChannelNoteFlags, X
	SSB NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
	; update note duration
	LDA zCurrentMusicByte
	JSR SetNoteDuration ; SFX notes can be longer than 16
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_2 ; ch3 has no duty cycle
	BEQ @Hill
	; update volume envelope from next param
	JSR GetMusicByte
	AND #ENVELOPE_MASK
	STA iChannelEnvelope, X
	BPL @GetRawPitch
@Hill:
	JSR GetMusicByte
	STA iChannelEnvelope, X
@GetRawPitch:
	; update low pitch from next param
	JSR GetMusicByte
	STA iChannelRawPitch, X
	; are we on the last PSG channel? (noise)
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_3
	BNE @NotNoise
	RTS
@NotNoise:
	; update high pitch from next param
	JSR GetMusicByte
	STA iChannelRawPitch + 16, X
	RTS

GetByteInEnvelopeGroup:
; start reading envelope data
; the group id is 7-bit, bit seven is discarded upon CMP
	; get pointer
	LDA EnvelopeGroups, Y
	STA zCurrentEnvelopeGroupAddress
	INY
	LDA EnvelopeGroups, Y
	STA zCurrentEnvelopeGroupAddress + 1
	; store the offset in ZP RAM
	; each group can only be 256 bytes long
	LDY iChannelEnvelopeGroupOffset, X
	STY zCurrentEnvelopeGroupOffset
	; check for ff/fe
	LDA (zCurrentEnvelopeGroupAddress), Y
	CMP #env_loop_cmd
	BNE @Next
	; reset offset when reading fe
	; effectively loops the envelope sequence
	LDA #0
	STA iChannelEnvelopeGroupOffset, X
	TAY
	STY zCurrentEnvelopeGroupOffset
	LDA (zCurrentEnvelopeGroupAddress), Y
	CLC
@Next:
	BCS @Quit ; C = 1 only if (zCurrentEnvelopeGroupAddress) = $ff
	INC iChannelEnvelopeGroupOffset, X
	INC zCurrentEnvelopeGroupOffset
@Quit:
	RTS

GetDrumSample:
; load ptr to sample headers in zDrumAddresses
	; are we on the last channels?
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_3
	; ret if not
	BCS @Valid
	RTS
@Valid:
	; update note duration
	LDA zCurrentMusicByte
	AND #$f
	JSR SetNoteDuration
	; check current channel
	CPX #CHAN_B
	BEQ @SFXNoise
	BCS @SFXDPCM
	TXA
	SEC
	SBC #CHAN_3
	BNE @CheckDPCM
@CheckNoise:
	LDA iChannelFlagSection1 + CHAN_B
	LSR A ; SOUND_CHANNEL_ON (noise)
	BCC @ContinueNoise
	RTS
@CheckDPCM:
	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON (dpcm)
	BCC @ContinueDPCM
	RTS
@ContinueDPCM:
	; load set ID
	LDA zMusicDrumSet
	; $80-$ff is treated as $00
	; falling through sign check, A gets overwritten by zSFXDrumSet
	; at this point, zSFXDrumSet was previously cleared by _PlayMusic
	BPL @NextDPCM

@SFXDPCM:
	LDA zSFXDrumSet
@NextDPCM:
	; load pointer to sample in A
	; sets use bit 0-6, 7 is discarded
	ASL A
	TAY
	LDA SampleKits, Y
	STA zAuxAddresses + 2
	INY
	LDA SampleKits, Y
	STA zAuxAddresses + 3
	; get pitch
	LDA zCurrentMusicByte
	; non-rest note?
	AND #$F0
	BEQ @QuitDPCM
	; use 'pitch' to seek sample set
	LSR A
	LSR A
	LSR A
	ADC zAuxAddresses + 2
	STA zAuxAddresses + 2
	LDA #0
	TAY
	ADC zAuxAddresses + 3
	STA zAuxAddresses + 3
	; load sample pointer into part 2 of zDrumAddresses
	LDA (zAuxAddresses + 2), Y
	PHA
	INY
	LDA (zAuxAddresses + 2), Y
	STA zDrumAddresses + 2, Y
	PLA
	STA zDrumAddresses + 2
@QuitDPCM:
	RTS

@ContinueNoise:
	; load set ID
	LDA zMusicDrumSet
	BPL @NextNoise

@SFXNoise:
	LDA zSFXDrumSet
@NextNoise:
	; load pointer to noise in A
	ASL A
	TAY
	LDA DrumKits, Y
	STA zAuxAddresses + 2
	INY
	LDA DrumKits, Y
	STA zAuxAddresses + 3
	; non-rest note?
	LDA zCurrentMusicByte
	AND #$f0
	BEQ @QuitNoise
	; use 'pitch' to seek noise set
	LDA zCurrentMusicByte
	AND #$F0
	LSR A
	LSR A
	LSR A
	ADC zAuxAddresses + 2
	STA zAuxAddresses + 2
	LDA #0
	TAY
	ADC zAuxAddresses + 3
	STA zAuxAddresses + 3
	; load pointer into part 1 of zDrumAddresses
	LDA (zAuxAddresses + 2), Y
	PHA
	INY
	LDA (zAuxAddresses + 2), Y
	STA zDrumAddresses, Y
	DEY
	PLA
	STA zDrumAddresses
	; get note
	LDA zCurrentMusicByte
	; clear delay
	STY zDrumDelay
@QuitNoise:
	RTS

ParseMusicCommand:
	; reload command
	LDA zCurrentMusicByte
	; get command #
	SBC #FIRST_SOUND_COMMAND
	ASL A
	TAY
	; seek command pointer
	LDA MusicCommands, Y
	STA zAuxAddresses + 2
	INY
	LDA MusicCommands, Y
	STA zAuxAddresses + 3
	; jump to the new pointer
	JMP (zAuxAddresses + 2)

MusicCommands:
; entries correspond to audio constants (see src/def/sound.asm)
	; d0
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	.dw Music_Octave
	; d8
	.dw Music_NoteType
	.dw Music_Transpose
	.dw Music_Tempo
	.dw Music_Cycle
	.dw Music_Envelope
	.dw Music_PitchSweep
	.dw Music_CyclePattern
	.dw Music_ToggleMusic
	; e0
	.dw Music_PitchSlide
	.dw Music_Vibrato
	.dw Music_Staccato
	.dw Music_ToggleDrum
	.dw MusicDummy ; no stereo
	.dw MusicDummy ; no global volume
	.dw Music_PitchOffset
	.dw Music_RelativePitch
	; e8
	.dw Music_EnvelopePattern
	.dw Music_TempoRelative
	.dw Music_RestartChannel
	.dw Music_NewSong
	.dw Music_SFXPriorityOn
	.dw Music_SFXPriorityOff
	.dw Music_JumpFlag
	.dw MusicDummy ; no stereo
	; f0
	.dw Music_SFXToggleDrum
	.dw Music_PitchIncSwitch
	.dw Music_FrameSwap
	.dw Music_SetMusic
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	.dw MusicDummy
	; f8
	.dw MusicDummy
	.dw Music_SetSoundEvent
	.dw Music_SetCondition
	.dw Music_JumpIf
	.dw Music_Jump
	.dw Music_Loop
	.dw Music_Call
	.dw Music_Ret

MusicDummy: ; command e4 e5 ef f4 f5 f6 f7 f8
	RTS

Music_FrameSwap: ; command f2
; controlled by zAudioCommandFlags >> FRAME_SWAP
; only works on noise channels
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_3
	BEQ @Percussion
	RTS
@Percussion:
	LDA zAudioCommandFlags
	FSB FRAME_SWAP
	STA zAudioCommandFlags
	RTS

Music_PitchIncSwitch: ; command f1
; dec APU timer by 1, thus incrementing pitch
	LDA iChannelFlagSection1, X
	SSB SOUND_PITCH_INC_SWITCH
	STA iChannelFlagSection1, X
	LDA iChannelPitchIncrementation, X
	EOR #1
	STA iChannelPitchIncrementation, X
	RTS

Music_SetMusic: ; command f3
; clear sound effect reading mode
	LDA iChannelFlagSection1, X
	RSB SOUND_READING_MODE
	STA iChannelFlagSection1, X
	RTS

Music_Ret: ; command ff
; called when $ff is encountered w/(o) subroutine flag set
; end music stream
; return to source address (if possible)
	; halves of the old code are reversed to apply a stack check
	; copy iChannelBackupAddress1 to iChannelAddress
	LDA iChannelBackupAddress1, X
	STA iChannelAddress, X
	LDA iChannelBackupAddress1 + 16, X
	STA iChannelAddress + 16, X
	; copy iChannelBackupAddress2 to iChannelBackupAddress1
	LDA iChannelBackupAddress2, X
	STA iChannelBackupAddress1, X
	LDA iChannelBackupAddress2 + 16, X
	STA iChannelBackupAddress1 + 16, X
	BEQ @ClearFlag
	LDA #0
	STA iChannelBackupAddress2, X
	STA iChannelBackupAddress2 + 16, X
	RTS
@ClearFlag:
	; reset subroutine flag
	LDA iChannelFlagSection1, X
	RSB SOUND_SUBROUTINE
	STA iChannelFlagSection1, X
	RTS

Music_Call: ; command fe
; call music stream (subroutine)
; parameters: ll hh ; pointer to subroutine
	; copy iChannelBackupAddress1 to iChannelBackupAddress2
	LDA iChannelBackupAddress1, X
	STA iChannelBackupAddress2, X
	LDA iChannelBackupAddress1 + 16, X
	STA iChannelBackupAddress2 + 16, X
	; copy iChannelAddress to iChannelBackupAddress1
	LDA iChannelAddress, X
	STA iChannelBackupAddress1, X
	LDA iChannelAddress + 16, X
	STA iChannelBackupAddress1 + 16, X
	; get pointer from next 2 bytes
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	PLA
	STA iChannelAddress, X
	; set subroutine flag
	LDA iChannelFlagSection1, X
	SSB SOUND_SUBROUTINE
	STA iChannelFlagSection1, X
	RTS

Music_Jump: ; command fc
; jump
; parameters: ll hh ; pointer
	; get pointer from next 2 bytes
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	PLA
	STA iChannelAddress, X
	RTS

Music_Loop: ; command fd
; loops xx - 1 times
; 	00: infinite (obsolete)
; params: 3
;	xx ll hh
;		xx : loop count
;   	ll hh : pointer

	; get loop count
	JSR GetMusicByte
	LDA iChannelFlagSection1, X
	TSB SOUND_LOOPING ; has the loop been initiated?
	BNE @CheckLoop
	LDY zCurrentMusicByte ; loop counter 0 = infinite
	BEQ @Loop
	; initiate loop
	DEY
	LDA iChannelFlagSection1, X ; set loop flag
	SSB SOUND_LOOPING
	STA iChannelFlagSection1, X
	TYA
	STA iChannelLoopCounter, X ; store loop counter
@CheckLoop:
	LDA iChannelLoopCounter, X ; are we done?
	BEQ @EndLoop
	DEC iChannelLoopCounter, X
@Loop:
	; get pointer
	JSR GetMusicByte
	; load new pointer into iChannelAddress
	PHA
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	PLA
	STA iChannelAddress, X
	RTS

@EndLoop:
	; reset loop flag
	LDA iChannelFlagSection1, X
	RSB SOUND_LOOPING
	STA iChannelFlagSection1, X
	; skip to next command
	; use 1 instead of 2: c = 1 at this point
	LDA iChannelAddress, X
	ADC #1 ; skip pointer
	STA iChannelAddress, X
	LDA iChannelAddress + 16, X
	ADC #0 ; update high byte in case of carry
	STA iChannelAddress + 16, X
	RTS

Music_SetCondition: ; command fa
; set condition for a jump
; stores condition in channel RAM
; used with FB
; params: 1
;	xx ; condition

	; set condition
	JSR GetMusicByte
	STA iChannelCondition, X
	RTS

Music_JumpIf: ; command fb
; conditional jump
; used with FA
; checks conditions in channel RAM
; params: 3
; 	xx: condition
;	ll hh: pointer

; check condition
	; a = condition
	JSR GetMusicByte
	; if existing condition matches, jump to new address
	CMP iChannelCondition, X
	BEQ @Jump
; skip to next command
	; get address
	LDA iChannelAddress, X
	ADC #2 ; skip pointer
	STA iChannelAddress, X
	LDA iChannelAddress + 16, X
	ADC #0 ; update high byte in case of carry
	STA iChannelAddress + 16, X
	RTS

@Jump:
; jump to the new address
	; get pointer
	JSR GetMusicByte
	; update pointer in iChannelAddress
	PHA
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	PLA
	STA iChannelAddress, X
	RTS

Music_JumpFlag: ; command ee
; conditional jump
; checks for active condition flags in ZP RAM
; in Pokemon each condition flag had their own byte
; in Vulpreich, to save space, these are stored as flags in zAudioCommandFlags
; params: 2
; ll hh ; pointer

	; get channel
	TXA
	RSB SFX_CHANNEL
	TAY
	LDA zAudioCommandFlags
	; mask current channel (DPCM = noise for the sake of percussion)
	AND @Masks, Y
	BNE @Jump ; if active, jump
	; skip pointer
	; add only 1: c = 1 at this point
	LDA iChannelAddress, X
	ADC #1
	STA iChannelAddress, X
	LDA iChannelAddress + 16, X
	ADC #0
	STA iChannelAddress + 16, X
	RTS

@Jump:
	LDA zAudioCommandFlags
	EOR @Masks, Y
	STA zAudioCommandFlags
	JSR GetMusicByte
	PHA
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	PLA
	STA iChannelAddress, X
	RTS

@Masks:
	.db 1 << RCOND_PULSE_1    ; $10
	.db 1 << RCOND_PULSE_2    ; $20
	.db 1 << RCOND_HILL       ; $40
	.db 1 << RCOND_NOISE_DPCM ; $80
	.db 1 << RCOND_NOISE_DPCM ; $80 ; Noise and DPCM share a mask

Music_SetSoundEvent: ; command f9
; $F9
; sets an exclusive flag in zAudioCommandFlags
; params: 0
	LDA zAudioCommandFlags
	SSB SOUND_EVENT
	STA zAudioCommandFlags
	RTS

Music_Staccato: ; command e2
; cuts a note off after a specified number of frames
; useful for optimization
; params: 1
	JSR GetMusicByte
	STA iChannelStaccatoMain, X
	LDA iChannelFlagSection2, X
	SSB SOUND_STACCATO
	STA iChannelFlagSection2, X
	RTS

Music_Vibrato: ; command e1
; vibrato
; params: 2
;	1: [xx]
	; x: preamble
;	2: [yz]
	; y: depth
	; z: length

	; set vibrato flag?
	LDA iChannelFlagSection2, X
	SSB SOUND_VIBRATO
	STA iChannelFlagSection2, X
	; start at lower frequency (depth is positive)
	LDA iChannelFlagSection3, X
	RSB SOUND_VIBRATO_DIR
	STA iChannelFlagSection3, X
	; get preamble
	JSR GetMusicByte
; update preamble
	STA iChannelVibratoPreamble, X
; update counter
	STA iChannelVibratoCounter, X
; update depth
; this is split into halves only to get added back together at the last second
	; get depth/timer
	JSR GetMusicByte
	; get top nybble
	AND #$f0
	HTL A
	LSR A ; halve
	STA zVibratoBackup
	ADC #0 ; round up
	LTH A
	ORA zVibratoBackup
	STA iChannelVibratoDepth, X
; update timer
	LDA zCurrentMusicByte
	; get bottom nybble
	AND #$f
	STA zVibratoBackup
	LTH A
	ORA zVibratoBackup
	STA iChannelVibratoTimer, X
	RTS

Music_PitchSlide: ; command e0
; set the target for pitch slide
; params: 2
; note duration
; target note
	JSR GetMusicByte
	STA zCurrentNoteDuration
	JSR GetMusicByte
	; octave in Y
	AND #$f0
	HTL A
	TAY
	; pitch in A
	LDA zCurrentMusicByte
	AND #$f
	JSR GetPitch
	STA iChannelSlideTarget, X
	TYA
	STA iChannelSlideTarget + 16, X
	LDA iChannelFlagSection2, X
	SSB SOUND_PITCH_SLIDE
	STA iChannelFlagSection2, X
	RTS

Music_PitchOffset: ; command e6
; sub hhll from current APU timer
; params: 1 (bigdw)
	LDA iChannelFlagSection2, X
	SSB SOUND_PITCH_MODIFIER
	STA iChannelFlagSection2, X
	JSR GetMusicByte
	STA iChannelPitchModifier + 16, X
	JSR GetMusicByte
	STA iChannelPitchModifier, X
	RTS

Music_RelativePitch: ; command e7
; add x to final note id
; operates squarely on NoteTable
; params: 1
	LDA iChannelFlagSection2, X
	SSB SOUND_RELATIVE_PITCH
	STA iChannelFlagSection2, X
	JSR GetMusicByte
	STA iChannelRelativeNoteID, X
	RTS

Music_CyclePattern: ; command de
; sequence of 4 cycles to be looped
; NOTE: sequence plays in ascending bit order
; params: 1 (4 2-bit cycle arguments)
	LDA iChannelFlagSection2, X
	SSB SOUND_CYCLE_LOOP ; cycle looping
	STA iChannelFlagSection2, X
	; cycle sequence
	JSR GetMusicByte
	STA iChannelCyclePattern, X
	LSR iChannelCyclePattern, X
	ROR A
	LSR iChannelCyclePattern, X
	ROR A
	STA iChannelCyclePattern, X
	; update cycle
	AND #$c0 ; only uses top 2 bits
	STA iChannelCycle, X
	RTS

Music_EnvelopePattern: ; command e8
; envelope group
; params: 1 (7-bit)
	LDA iChannelFlagSection2, X
	SSB SOUND_ENV_PTRN
	STA iChannelFlagSection2, X
	JSR GetMusicByte
	STA iChannelEnvelopeGroup, X
	RTS

Music_ToggleMusic: ; command df
; switch between audio data reading modes
; params: none
	LDA iChannelFlagSection1, X
	FSB SOUND_READING_MODE
	STA iChannelFlagSection1, X
	RTS

Music_ToggleDrum: ; command e3
; toggle music sampling
; can't be used as a straight toggle since the param is not read from on->off
; on NES, the drumset byte is shared between noise and DPCM
; also on NES, A returns zSFXDrumSet $00 if param = $80 or higher
; params:
; 	noise on: 1 (7-bit)
; 	noise off: 0
	; toggle sampling
	TXA
	AND #CHAN_3
	BEQ @DPCM
	LDA iChannelFlagSection1 + CHAN_4
	LSR A ; SOUND_CHANNEL_ON
	BCC @Noise
	LDA iChannelFlagSection1 + CHAN_4
	FSB SOUND_DPCM
	STA iChannelFlagSection1 + CHAN_4
@Noise:
	LDA iChannelFlagSection1, X
	FSB SOUND_NOISE
	STA iChannelFlagSection1, X
	BPL @Check
@DPCM:
	LDA iChannelFlagSection1, X
	FSB SOUND_DPCM
	STA iChannelFlagSection1, X
@Check:
	AND #1 << SOUND_DPCM | 1 << SOUND_NOISE ; isolate bits
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA zMusicDrumSet
	RTS

Music_SFXToggleDrum: ; command f0
; toggle sfx sampling
; on NES, A only keeps bits 0-6: bit 7 is uselessly transferred to c
; params:
;	on: 1 (7-bit mirror)
; 	off: 0
	; toggle sampling
	TXA
	AND #CHAN_3
	BEQ @DPCM
	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON
	BCC @Noise
	LDA iChannelFlagSection1 + CHAN_C
	FSB SOUND_DPCM
	STA iChannelFlagSection1 + CHAN_C
@Noise:
	LDA iChannelFlagSection1, X
	FSB SOUND_NOISE
	STA iChannelFlagSection1, X
	BPL @Check
@DPCM:
	LDA iChannelFlagSection1, X
	FSB SOUND_DPCM
	STA iChannelFlagSection1, X
@Check:
	AND #1 << SOUND_DPCM | 1 << SOUND_NOISE ; isolate bits
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA zSFXDrumSet
	RTS

Music_PitchSweep: ; command dd
; update pitch sweep
; params: 1
	LDA iChannelNoteFlags, X
	SSB NOTE_PITCH_SWEEP
	STA iChannelNoteFlags, X
	TXA
	AND #%11111110
	BEQ @Valid
	RTS
@Valid:
	TXA
	BNE @Pulse2
	JSR GetMusicByte
	STA zSweep1
	RTS
@Pulse2:
	JSR GetMusicByte
	STA zSweep2
	RTS

Music_Cycle: ; command db
; cycle
; params: 1
	JSR GetMusicByte
	CLC
	ROR A
	ROR A
	ROR A
	STA iChannelCycle, X
	RTS

Music_NoteType: ; command d8
; note length
;	# frames per 16th note
; volume envelope: see Music_Envelope
; params: 2
	; note length
	JSR GetMusicByte
	STA iChannelNoteLength, X
	TXA
	RSB SFX_CHANNEL
	CMP #CHAN_3
	BCC Music_Envelope
	RTS

Music_Envelope: ; command dc
; volume envelope
; params: 1
;	ch1-2: volume settings (loop, ramp, volume)
;	ch3: linear length (toggle, length)
	JSR GetMusicByte
	STA iChannelEnvelope, X
	RTS

Music_Tempo: ; command da
; global tempo
; params: 2
;	YA: tempo
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	JMP SetGlobalTempo

Music_Octave: ; command d0-d7
; set octave based on lo nybble of the command
	LDA zCurrentMusicByte
	AND #7
	STA iChannelOctave, X
	RTS

Music_Transpose: ; command d9
; pitch / octave offset
; params: 1
	JSR GetMusicByte
	STA iChannelTransposition, X
	RTS

Music_TempoRelative: ; command e9
; set global tempo to current channel tempo +/- param
; params: 1 signed
	CLC
	JSR GetMusicByte
	BMI @Minus
	LDY #0
	BEQ @OK

@Minus:
	LDY #$ff
@OK:
	ADC iChannelTempo + 16, X
	PHA
	TYA
	ADC iChannelTempo, X
	TAY
	PLA
	JMP SetGlobalTempo

Music_SFXPriorityOn: ; command ec
; turn sfx priority on
; params: none
	LDA zAudioCommandFlags
	SSB SFX_PRIORITY
	STA zAudioCommandFlags
	RTS

Music_SFXPriorityOff: ; command ed
; turn sfx priority off
; params: none
	LDA zAudioCommandFlags
	RSB SFX_PRIORITY
	STA zAudioCommandFlags
	RTS

Music_RestartChannel: ; command ea
; restart current channel from channel header (same bank)
; params: 2 (5)
; ll hh: pointer to new channel header
;	header format: 0x yy zz
;		x: channel # (0-4)
;		zzyy: pointer to new music data

	; update music id
	LDA iChannelID, X
	STA zMusicID
	LDA iChannelBank, X
	STA zMusicBank
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STX zBackupX
	TAX
	TYA
	STA zAuxAddresses
	STX zAuxAddresses + 1
	JSR LoadChannel
	JSR StartChannel
	LDX zBackupX
	RTS

Music_NewSong: ; command eb
; new song
; variant of an old Gen 1 command
; params: 2
;	Y: song id
	JSR GetMusicByte
	TAY
	STX zBackupX
	JSR _PlayMusic
	LDX zBackupX
	RTS

GetMusicByte:
; returns byte from current address in A
; advances to next byte in music data
; input: X = current channel
; output: C = 1
	LDA iChannelAddress, X
	STA zAuxAddresses
	LDA iChannelAddress + 16, X
	STA zAuxAddresses + 1
	JSR _LoadMusicByte ; home ROM
	INC zAuxAddresses
	INC iChannelAddress, X
	BNE @Quit
	INC zAuxAddresses + 1
	INC iChannelAddress + 16, X
@Quit:
	LDY zBackupY
	LDA zCurrentMusicByte
	RTS

GetPitch:
; generate pitch
;     in     out
; A = Pitch  lo
; Y = Octave hi
	STY zBackupY ; store input for use
	STA zBackupA
	; get octave
	LDA iChannelTransposition, X
	AND #$f0
	HTL A ; high nybble
	ADC zBackupY
	PHA ; save octave
	; add pitch
	LDA iChannelTransposition, X
	AND #$f ; lo nybble
	ADC zBackupA
	ASL A
	TAY
	; X = lo, Y = hi
	LDA NoteTable, Y
	STX zBackupX
	TAX
	INY
	LDA NoteTable, Y
	TAY
	PLA ; retrieve octave
	; shift byte (7 - A) bits
@Loop:
	; (7 - A) loops
	CMP #7
	BCS @OK
	; ROR XY
	PHA
	TXA
	ROR A
	TAX
	TYA
	ROR A
	TAY
	PLA
	CLC
	ADC #1
	JMP @Loop

@OK:
	TYA
	SSB SOUND_LENGTH_F ; make sure the note is on
	TAY
	TXA
	LDX zBackupX
	RTS

SetNoteDuration:
; input: a = note duration in 16ths
	; store delay units in zFactorBuffer
	ADC #1
	STA zFactorBuffer
	LDY #0
	STY zFactorBuffer + 1
	; store NoteLength in a
	LDA iChannelNoteLength, X
	; multiply NoteLength by delay units
	STY zFactorBuffer + 2 ; just multiply
	JSR @Multiply
	LDA zFactorBuffer + 2
	; store Tempo in zFactorBuffer
	LDY iChannelTempo, X
	STY zFactorBuffer
	LDY iChannelTempo + 16, X
	STY zFactorBuffer + 1
	; add high byte to the next result
	LDY iChannelNoteDuration + 16, X
	STY zFactorBuffer + 2
	; multiply Tempo by last result (iChannelNoteLength * LOW(delay))
	JSR @Multiply
	; copy result to zFactorBuffer offset 2
	LDA zFactorBuffer + 2
	; store result in iChannelNoteDuration + 16
	STA iChannelNoteDuration + 16, X
	LDA zFactorBuffer + 3
	; store result in NoteDuration
	STA iChannelNoteDuration, X
	RTS

@Multiply:
; multiplies a and zFactorBuffer
; adds the result to l
; stores the result in zFactorBuffer offset 2
	LDY #0
	STY zFactorBuffer + 3
@Loop:
	; halve a
	LSR A
	TAY
	; is there a remainder?
	BCC @Skip
	CLC
	; add it to the result
	LDA zFactorBuffer
	ADC zFactorBuffer + 2
	STA zFactorBuffer + 2
	LDA zFactorBuffer + 1
	ADC zFactorBuffer + 3
	STA zFactorBuffer + 3
@Skip:
	ASL zFactorBuffer
	ROL zFactorBuffer + 1
	; are we done?
	TYA
	BNE @Loop
	RTS

SetGlobalTempo:
	STA zBackupA
	; are we dealing with music or sfx?
	TXA
	TSB SFX_CHANNEL
	BNE @SFXChannel
	LDX #0
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
	BEQ @End

@SFXChannel:
	STX zBackupX
	LDX #8
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
	INX
	JSR Tempo
@End:
	LDX zCurrentChannel ; restore current channel
	RTS

Tempo:
; input:
; 	AY: note length
	; update Tempo
	LDA zBackupA
	STA iChannelTempo, X
	TYA
	STA iChannelTempo + 16, X
	; clear workflow
	LDA #0
	STA iChannelNoteDuration + 16, X
	RTS

StartChannel:
	LDX zBackupX
	LDA iChannelFlagSection1, X
	SSB SOUND_CHANNEL_ON ; turn channel on
	STA iChannelFlagSection1, X
	TXA
	EOR #CHAN_8 - 1
	TAY
	INY
	LDA #0
	SEC
@Loop:
	ROR A
	DEY
	BNE @Loop
	ORA zMixer
	STA zMixer
	LDX zBackupX
	RTS

GenerateTrackOffset:
; multiply zMusicID by 3
; input  - Y
; output - zAuxAddresses
	LDA #0
	STA zAuxAddresses + 1
	TYA
	STA zMusicID ; song number
	STA zAuxAddresses
	ASL A
	ROL zAuxAddresses + 1
	ADC zAuxAddresses
	STA zAuxAddresses
	BCC @SkipInc
	CLC
	INC zAuxAddresses + 1
@SkipInc:
	RTS

ThreeByteAudioPointer:
; read the track pointer
	LDY #0
	LDA (zAuxAddresses), Y
	STA zMusicBank
	INY
	LDA (zAuxAddresses), Y
	INY
	PHA
	LDA (zAuxAddresses), Y
	STA zAuxAddresses + 1
	PLA
	STA zAuxAddresses
	RTS

_PlayMusic:
; load music
	JSR MusicOff
	JSR GenerateTrackOffset
	LDA #<Music
	ADC zAuxAddresses
	STA zAuxAddresses
	LDA #>Music
	ADC zAuxAddresses + 1
	STA zAuxAddresses + 1
	JSR ThreeByteAudioPointer
	LDA #0
	STA zMixer
	JSR LoadMusicByte ; store first byte of music header in a
	AND #CHANNEL_TOTAL_MASK ; get channel total
	ASL A
	ROL A
	ROL A
	ROL A
	ADC #1
@Loop:
; start playing channels
	PHA
	JSR LoadChannel
	JSR StartChannel
	PLA
	SBC #0
	BNE @Loop
	STA zDrumAddresses
	STA zDrumAddresses + 1
	STA zDrumAddresses + 2
	STA zDrumAddresses + 3
	STA zDrumDelay
	STA zMusicDrumSet
	STA zSFXDrumSet
	LDA zAudioCommandFlags
	AND #1 << MUSIC_PLAYING | 1 << SFX_PRIORITY
	STA zAudioCommandFlags
	JMP MusicOn

_PlaySFX:
; clear channels if they aren't already
	STY zBackupY
	JSR MusicOff
	LDA iChannelFlagSection1 + CHAN_8
	LSR A ; SOUND_CHANNEL_ON
	BCS @Ch9
	LDY #CHAN_0 << 2 ; turn it off
	JSR ClearPulse
	STA zSweep1
@Ch9:
	LDA iChannelFlagSection1 + CHAN_9
	LSR A ; SOUND_CHANNEL_ON
	BCS @ChA
	LDY #CHAN_1 << 2 ; turn it off
	JSR ClearPulse
	STA zSweep2
@ChA:
	LDA iChannelFlagSection1 + CHAN_A
	LSR A ; SOUND_CHANNEL_ON
	BCS @ChB
	LDY #CHAN_2 << 2 ; turn it off
	JSR ClearHillDPCM
@ChB:
	LDA iChannelFlagSection1 + CHAN_B
	LSR A ; SOUND_CHANNEL_ON
	BCS @ChC
	LDY #CHAN_3 << 2 ; turn it off
	JSR ClearNoise
@ChC:
	LDA iChannelFlagSection1 + CHAN_C
	LSR A ; SOUND_CHANNEL_ON
	BCS @ChannelsCleared
	LDY #CHAN_4 << 2 ; turn it off
	JSR ClearHillDPCM
@ChannelsCleared:
; start reading sfx header for # chs
	LDY zBackupY
	JSR GenerateTrackOffset
	LDA #<SFX
	ADC zAuxAddresses
	STA zAuxAddresses
	LDA #>SFX
	ADC zAuxAddresses + 1
	STA zAuxAddresses + 1
	JSR ThreeByteAudioPointer
	JSR LoadMusicByte ; store first byte of music header in a
	AND #CHANNEL_TOTAL_MASK ; get channel total
	HTL A
	LSR A
	ADC #1
@StartChannels:
; start playing channels
	PHA
	JSR LoadChannel
	LDA iChannelFlagSection1, X
	SSB SOUND_READING_MODE
	STA iChannelFlagSection1, X
	JSR StartChannel
	PLA
	SBC #1
	BNE @StartChannels
	JSR MusicOn
	LDA zAudioCommandFlags
	RSB SFX_PRIORITY
	STA zAudioCommandFlags
	RTS

LoadChannel:
; prep channel for use
; input:
; 	zAuxAddresses:

	; get pointer to current channel
	JSR LoadMusicByte
	INC zAuxAddresses
	BNE @NoCarry1
	INC zAuxAddresses + 1
@NoCarry1:
	STA zBackupA
	AND #CHANNEL_BIT_MASK ; bit 0-3 (current channel)
	STA zCurrentChannel
	TAY
	LDX zCurrentChannel
	LDA iChannelFlagSection1, X
	RSB SOUND_CHANNEL_ON ; channel off
	STA iChannelFlagSection1, X
; make sure channel is cleared
; set default tempo and note length in case nothing is loaded
; input:
;	x: channel ID
	STY zBackupY
	LDA zCurrentChannel
	CLC ; start
	; clear channel
@Loop1:
	TAY
	LDA #0
	STA iChannelRAM, Y
	STA iChannelRAM + $100, Y
	TYA
	ADC #CHANNEL_RAM_STEP_LENGTH
	BCC @Loop1
	CLC
@Loop2:
	TAY
	LDA #0
	STA iChannelRAM + $200, Y
	TYA
	ADC #CHANNEL_RAM_STEP_LENGTH
	CMP #<iChannelRAMEnd
	BCC @Loop2
	; set tempo to default ($100)
	LDA #0
	STA iChannelTempo, X
	ADC #0
	STA iChannelTempo + 16, X
	; set note length to default ($1) (fast)
	STA iChannelNoteDuration, X
	JSR LoadMusicByte
	STA iChannelAddress, X
	INC zAuxAddresses
	BNE @NoCarry2
	INC zAuxAddresses + 1
@NoCarry2:
	; load music pointer
	JSR LoadMusicByte
	STA iChannelAddress + 16, X
	INC zAuxAddresses
	BNE @NoCarry3
	INC zAuxAddresses + 1
@NoCarry3:
	; load music id
	LDA zMusicID
	STA iChannelID, X
	; load music bank
	LDA zMusicBank
	STA iChannelBank, X
	RTS

LoadMusicByte:
; input:
;   zAuxAddresses
; output:
;   A = zCurrentMusicByte
	JSR _LoadMusicByte ; home ROM
	LDA zCurrentMusicByte
	RTS

ClearChannels:
; runs clears for all 5 channels
	LDA #0
	STA SND_CHN
	TAY
	JSR ClearPulse ;	30 00 00 00
	LDY #CHAN_1 << 2
	JSR ClearPulse ;	30 00 00 00
	LDY #CHAN_2 << 2
	JSR ClearHillDPCM ;	00 xx 00 00
	LDY #CHAN_3 << 2
	JSR ClearNoise ;	30 xx 00 00
	LDY #CHAN_4 << 2
;				00 xx 00 00

ClearHillDPCM:
; input: Y = APU offset
; output: 00 xx 00 00
	LDA #0
	STA SQ1_ENV, Y
	STA SQ1_LO, Y
	STA SQ1_HI, Y
	RTS

ClearPulse:
; input: Y = APU offset
; output: 30 00 00 00
	LDA #1 << SOUND_VOLUME_LOOP_F | 1 << SOUND_RAMP_F
	STA SQ1_ENV, Y
	LDA #0
	STA SQ1_SWEEP, Y
	STA SQ1_LO, Y
	STA SQ1_HI, Y
	RTS

ClearNoise:
; input: Y = APU offset
; output: 30 xx 00 00
	LDA #1 << SOUND_VOLUME_LOOP_F | 1 << SOUND_RAMP_F
	STA SQ1_ENV, Y
	LDA #0
	STA SQ1_LO, Y
	STA SQ1_HI, Y
	RTS
