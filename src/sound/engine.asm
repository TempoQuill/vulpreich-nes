; The entire sound engine. Uses 00-27 in ZP RAM and 0200-04bf in internal RAM.

; Interfaces are in bank 7f.

_InitSound:
; restart sound operation
; clear all relevant hardware registers & ram
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	JSR MusicOff
	JSR ClearChannels
	; clear 0000-0027
	LDX #zAudioRAMEnd - zAudioRAM
@ClearZP:
	DEX
	STA zAudioRAM, X
	BNE @ClearZP
	; clear 0200-04bf
	LDX #<iChannelRAMEnd - <iChannelRAM
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
	PLA
	TAY
	PLA
	TAX
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
	ORA #1 << MUSIC_PLAYING
	STA zAudioCommandFlags
	RTS

MusicOff:
	LDA zAudioCommandFlags
	AND #$ff ^ (1 << MUSIC_PLAYING)
	STA zAudioCommandFlags
	RTS

_UpdateSound:
; called once per frame
	; no use updating audio if it's not playing
	LDA zAudioCommandFlags
	AND #1 << MUSIC_PLAYING
	BNE @PlayerOn
	RTS

@PlayerOn:
	; start at ch1
	LDA #1 << CHAN_3 | 1 << CHAN_2 | 1 << CHAN_1 | 1 << CHAN_0
	STA zMixer
	LDX #CHAN_0
	STX zCurrentChannel

@Loop:
	; check channel power
	LDA iChannelFlagSection1, X
	AND #1 << SOUND_CHANNEL_ON
	BNE @AndItsOn ; aaaaand it's on!
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
	AND #$ff ^ (1 << SOUND_VIBRATO)
	STA iChannelFlagSection2, X
	; get next note
	JSR ParseMusic
@ContinueSoundUpdate:
	JSR ApplyPitchSlide

	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2
	BEQ @Hill
	CMP #CHAN_4 ; dpcm has no volume/length control beyond sample size
	BEQ @Continue

	; duty cycle
	LDA iChannelCycle, X
	; volume envelope
	ORA iChannelEnvelope, X
	STA zCurrentTrackEnvelope
	JMP @Continue

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
	; effects, noise, DPCM
	JSR GeneralHandler
	JSR HandleNoise
	JSR HandleDPCM
	; turn off music when playing sfx?
	LDA zAudioCommandFlags
	AND #1 << SFX_PRIORITY
	BEQ @Next
	; are we in a sfx channel right now?
	TXA ; X = current channel
	AND #1 << SFX_CHANNEL
	BNE @Next
	; are any sfx channels active?
	; if so, mute
	LDA iChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA iChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA iChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @Next

	LDA zMixer
	ORA #1 << CHAN_4 ; turn on DPCM
	STA zMixer
	STA SND_CHN

@RestNote:
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_REST ; rest
	STA iChannelNoteFlags, X

@Next:
	; are we in a sfx channel right now?
	TXA
	AND #1 << SFX_CHANNEL
	BNE @SFXChannel
	LDA iChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @SoundChannelOn
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
	AND #$ff ^ (1 << SFX_CHANNEL)
	CPX #CHAN_4 + 1
	BCS @NextChannel ; > DPCM means go straight to the next channel
	JMP @Loop
@Done:
	RTS

; X = current channel, Y = pointer offset, A = pointer data
UpdateChannels:
	TXA
	ASL A
	TAY
	LDA @FunctionPointers, Y
	STA zChannelFunctionPointer
	INY
	LDA @FunctionPointers, Y
	STA zChannelFunctionPointer + 1
	JMP (zChannelFunctionPointer)

@FunctionPointers:
; music channels
	.dw @Pulse1
	.dw @Pulse2
	.dw @Hill
	.dw @Noise
	.dw @DPCM
	.dw @None
	.dw @None
	.dw @None
; sfx channels
; identical to music channels
	.dw @Pulse1
	.dw @Pulse2
	.dw @Hill
	.dw @Noise
	.dw @DPCM
	; $b0bd - PRG ROM - in window 1
	; $4802 - Mapper area
	; $0829 - ZP RAM mirrored

@Pulse1:
	LDA iChannelNoteFlags, X
	PHA
	AND #1 << NOTE_PITCH_SWEEP
	BEQ @Pulse1_NoSweep

	LDA zSweep1
	STA SQ1_SWEEP

@Pulse1_NoSweep:
	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @Pulse1_Rest

	PLA
	PHA
	AND #1 << NOTE_NOISE_SAMPLING
	BNE @Pulse1_NoiseSampling

	PLA
	PHA
	AND #1 << NOTE_PITCH_OVERRIDE
	BNE @Pulse1_PitchOverride

	PLA
	PHA
	AND #1 << NOTE_ENV_OVERRIDE
	BNE @Pulse1_EnvOverride

	PLA
	PHA
	AND #1 << NOTE_VIBRATO_OVERRIDE
	BNE @Pulse1_VibratoOverride

	BEQ @Pulse1_CheckCycleOverride

@Pulse1_PitchOverride:
	LDA zCurrentTrackRawPitch
	STA SQ1_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ1_HI

@Pulse1_CheckCycleOverride:
	PLA
	PHA
	AND #1 << NOTE_CYCLE_OVERRIDE
	BNE @Pulse1_CycleOverride
	RTS

@Pulse1_CycleOverride:
@Pulse1_EnvOverride:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ1_ENV
	RTS

@Pulse1_VibratoOverride:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ1_ENV
	LDA zCurrentTrackRawPitch
	STA SQ1_LO
	RTS

@Pulse1_Rest:
	PLA
	LDY #CHAN_0 << 2
	LDA #$30
	JMP ClearChannel

@Pulse1_NoiseSampling:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ1_ENV
	LDA zCurrentTrackRawPitch
	STA SQ1_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ1_HI
	RTS

@Pulse2:
	LDA iChannelNoteFlags, X
	PHA
	AND #1 << NOTE_PITCH_SWEEP
	BEQ @Pulse2_NoSweep

	LDA zSweep2
	STA SQ2_SWEEP

@Pulse2_NoSweep:
	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @Pulse2_Rest

	PLA
	PHA
	AND #1 << NOTE_NOISE_SAMPLING
	BNE @Pulse2_NoiseSampling

	PLA
	PHA
	AND #1 << NOTE_PITCH_OVERRIDE
	BNE @Pulse2_PitchOverride

	PLA
	PHA
	AND #1 << NOTE_ENV_OVERRIDE | 1 << NOTE_CYCLE_OVERRIDE
	BNE @Pulse2_EnvCycleOverrides

	PLA
	PHA
	AND #1 << NOTE_VIBRATO_OVERRIDE
	BNE @Pulse2_VibratoOverride
	PLA
	RTS

@Pulse2_EnvCycleOverrides:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ2_ENV
	RTS

@Pulse2_PitchOverride:
	PLA
	LDA zCurrentTrackRawPitch
	STA SQ2_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ2_HI
	RTS

@Pulse2_VibratoOverride:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ2_ENV
	LDA zCurrentTrackRawPitch
	STA SQ2_LO
	RTS
	
@Pulse2_Rest:
	PLA
	LDY #CHAN_1 << 2
	LDA #$30
	JMP ClearChannel

@Pulse2_NoiseSampling:
	PLA
	LDA zCurrentTrackEnvelope
	STA SQ2_ENV
	LDA zCurrentTrackRawPitch
	STA SQ2_LO
	LDA zCurrentTrackRawPitch + 1
	STA SQ2_HI
	RTS

@Hill:
	LDA iChannelNoteFlags, X
	PHA
	AND #1 << NOTE_REST
	BNE @Hill_Rest

	PLA
	PHA
	AND #1 << NOTE_NOISE_SAMPLING
	BNE @Hill_NoiseSampling

	PLA
	PHA
	AND #1 << NOTE_ENV_OVERRIDE
	BNE @Hill_EnvOverride

	PLA
	PHA
	AND #1 << NOTE_VIBRATO_OVERRIDE
	BNE @Hill_VibratoOverride

	PLA
	PHA
	AND #1 << NOTE_PITCH_OVERRIDE
	BNE @Hill_PitchOverride
	PLA
	RTS

@Hill_PitchOverride:
	PLA
	LDA zCurrentTrackRawPitch
	STA TRI_LO
	LDA zCurrentTrackRawPitch + 1
	STA TRI_HI
	RTS

@Hill_VibratoOverride:
	PLA
	LDA zCurrentTrackRawPitch
	STA TRI_LO
	RTS

@Hill_Rest:
	PLA
	LDY #CHAN_2 << 2
	LDA #$0
	JMP ClearChannel

@Hill_NoiseSampling:
	PLA
	LDA zHillLinearLength
	STA TRI_LINEAR
	LDA zCurrentTrackRawPitch
	STA TRI_HO
	LDA zCurrentTrackRawPitch + 1
	STA TRI_HI
	RTS

@Noise:
	LDA iChannelNoteFlags, X
	PHA
	AND #1 << NOTE_NOISE_SAMPLING
	BNE @Noise_NoiseSampling

	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @Noise_Rest
	PLA
	RTS

@Noise_Rest:
	PLA
	LDY #CHAN_3 << 2
	LDA #$30
	JMP ClearChannel

@Noise_NoiseSampling:
	PLA
	LDA zCurrentTrackEnvelope
	STA NOISE_ENV
	LDA zCurrentTrackRawPitch
	STA NOISE_LO
	LDA #$8
	STA NOISE_HI
	RTS

@DPCM:
	LDA iChannelNoteFlags, X
	PHA
	AND #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	BNE @DPCM_DeltaNoiseSamplingOverrides

	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @DPCM_Rest
	PLA
	RTS

@DPCM_Rest:
	PLA
	LDA zMixer
	AND #$ff ^ (1 << CHAN_4) ; turn off DPCM
	STA zMixer
	STA SND_CHN
	LDY #CHAN_4 << 2
	LDA #$0
	JMP ClearChannel

@DPCM_DeltaNoiseSamplingOverrides:
	PLA
	LDA zDPCMSamplePitch
	STA DPCM_ENV
	LDA zDPCMSampleOffset
	STA DPCM_OFFSET
	LDA zDPCMSampleLength
	STA DPCM_SIZE
	RTS

@None:
	RTS

LoadNote:
	; wait for pitch slide to finish
	LDA iChannelFlagSection2, X
	PHA
	AND #1 << SOUND_PITCH_SLIDE
	BNE @PitchSlide
	JMP @CheckRelativePitch
	; get note duration
@PitchSlide:
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
	LDY iChannelSlideTarget + 16, X
	STA zRawPitchTargetBackup
	STY zRawPitchTargetBackup + 1
	SBC iChannelRawPitch, X
	STA zPitchSlideDifference
	TYA
	SBC iChannelRawPitch + 16, X
	STA zPitchSlideDifference + 1
	BCS @PitchSlide_Greater
	LDA iChannelFlagSection3, X
	ORA #1 << SOUND_PITCH_SLIDE_DIR
	STA iChannelFlagSection3, X
	; flip bits of differential
	LDA zPitchSlideDifference + 1
	EOR #$ff
	STA zPitchSlideDifference + 1
	LDA zPitchSlideDifference
	EOR #$ff
	ADC #1
	STA zPitchSlideDifference
	JMP @PitchSlide_Resume

@PitchSlide_Greater:
	; clear directional flag
	LDA iChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_PITCH_SLIDE_DIR)
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
	JMP @PitchSlide_Loop

@PitchSlide_Quit:
	LDA zPitchSlideDifference ; remainder
	ADC zCurrentNoteDuration
	STY zPitchSlideDifference + 1 ; quotient

	STY iChannelSlideDepth, X ; quotient
	STA iChannelSlideFraction, X ; remainder
	LDA #0
	STA iChannelSlideTempo, X

@CheckRelativePitch:
	PLA
	PHA
	AND #1 << SOUND_RELATIVE_PITCH
	BEQ @CheckEnvelopePattern

	LDA iChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA iChannelFlagSection3, X

@CheckEnvelopePattern:
	PLA
	PHA
	AND #1 << SOUND_ENV_PTRN
	BEQ @CheckMuteTimer

	LDA iChannelNoteFlags, X
	AND #$ff ^ (1 << NOTE_ENV_OVERRIDE)
	STA iChannelNoteFlags, X
	; reset offset
	LDA #0
	STA iChannelEnvelopeGroupOffset, X

@CheckMuteTimer:
	PLA
	AND #1 << SOUND_MUTE
	BNE @MuteTimer
	RTS

@MuteTimer:
	; read main byte
	LDA iChannelMuteMain, X
	; copy to counter
	STA iChannelMuteCounter, X
	RTS

GeneralHandler:
; handle cycle, pitch, env ptrn, mute, and vibrato
	LDA iChannelFlagSection2, X
	PHA
	AND #1 << SOUND_CYCLE_LOOP ; cycle looping
	BEQ @CheckRelativePitch

	LDA zCurrentTrackEnvelope
	AND #$3f
	STA zCurrentTrackEnvelope
	LDA iChannelCyclePattern, X
	ROL A
	ROL A
	STA iChannelCyclePattern, X
	AND #$c0
	ORA zCurrentTrackEnvelope
	STA zCurrentTrackEnvelope

	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_CYCLE_OVERRIDE
	STA iChannelNoteFlags, X

@CheckRelativePitch:
	PLA
	PHA
	AND #1 << SOUND_RELATIVE_PITCH
	BEQ @CheckPitchOffset

	; is relative pitch on?
	LDA iChannelFlagSection3, X
	PHA
	AND #1 << SOUND_REL_PITCH_FLAG

	BEQ @RelativePitch_SetFlag

	PLA
	PHA
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA iChannelFlagSection3, X

	AND #1 << SOUND_REST
	BNE @RelativePitch_SetFlag

	PLA
	; get pitch
	LDA iChannelNoteID, X
	; add to pitch value
	ADC iChannelRelativeNoteID, X
	STA iChannelNoteID, X

	; get octave
	LDY iChannelOctave, X
	; get final tone
	JSR GetPitch
	STA zCurrentTrackRawPitch
	STY zCurrentTrackRawPitch + 1

@RelativePitch_SetFlag:
	PLA
	ORA #1 << SOUND_REL_PITCH_FLAG
	STA iChannelFlagSection3, X

; interesting notes:
;	$d9 and $e7 can stack with each other
;		$d9 $01 and $e7 $01 together would be the same as $d9/e7 $02
;	$e7 $f4-ff can trigger the rest pitch due to a lack of carry

@CheckPitchModifier:
	PLA
	AND #1 << SOUND_PITCH_MODIFIER
	BEQ @CheckPitchInc

	; sub offset to iChannelRawPitch
	LDA zCurrentTrackRawPitch
	SBC iChannelPitchModifier + 16, X
	STA zCurrentTrackRawPitch

	LDA zCurrentTrackRawPitch + 1
	SBC iChannelPitchModifier, X
	STA zCurrentTrackRawPitch + 1

@CheckPitchInc:
	; is pitch inc on?
	LDA iChannelFlagSection1, X
	AND #1 << SOUND_PITCH_INC_SWITCH
	BEQ @CheckVibrato

	; is the byte active?
	LDA iChannelPitchIncrementation, X
	BEQ @CheckVibrato

	; if so, inc the pitch by 1
	LDA zCurrentTrackRawPitch
	BEQ @CheckPitchInc_NoCarry

	; inc high byte if low byte rolls over
	DEC zCurrentTrackRawPitch + 1

; incidentally, pitch_inc_switch can stack with pitch_offset
; for example, $f1 followed by $e6 $0001 would essentially mean $e6 $0002
@CheckPitchInc_NoCarry:
	DEC zCurrentTrackRawPitch

@CheckVibrato:
	; is vibrato on?
	LDA iChannelFlagSection2, X
	PHA
	AND #1 << SOUND_VIBRATO ; vibrato
	BEQ @CheckEnvelopePattern

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
	JMP @CheckEnvelopePattern

@Vibrato_Subexit2:
	DEC iChannelVibratoCounter, X
	JMP @CheckEnvelopePattern

@Vibrato_Bend:
	; refresh counter
	ASL A
	ASL A
	ASL A
	ASL A
	ORA iChannelVibratoTimer, X
	STA iChannelVibratoTimer, X

	; get raw pitch
	LDA zCurrentTrackRawPitch
	TAY

	; get direction
	LDA iChannelFlagSection3, X
	PHA
	AND #1 << SOUND_VIBRATO_DIR ; vibrato up/down
	BEQ @Vibrato_Down

; up

	; vibrato down
	PLA
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
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
	PLA
	ORA #1 << SOUND_VIBRATO_DIR
	STA iChannelFlagSection3, X

	; get the depth
	LDA zVibratoBackup
	AND #$f0 ; high
	; move it to lo
	LSR A
	LSR A
	LSR A
	LSR A
	STY zVibratoBackup
	ADC zVibratoBackup
	BCC @Vibrato_NoCarry
	LDA #$ff

@Vibrato_NoBorrow:
@Vibrato_NoCarry:
	STA zCurrentTrackRawPitch
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_VIBRATO_OVERRIDE
	STA iChannelNoteFlags, X

@CheckEnvelopePattern:
	PLA
	PHA
	AND #1 << SOUND_ENV_PTRN
	BEQ @CheckMuteTimer

	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_ENV_OVERRIDE
	STA iChannelNoteFlags, X

	; get group pointer
	LDA iChannelEnvelopeGroup, X
	ASL A
	TAY
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2
	BNE @EnvelopePattern_NotHill
	; hill has no volume control on its own
	RTS

@EnvelopePattern_NotHill:
	; envelope group
	JSR GetByteInEnvelopeGroup
	BCC @EnvelopePattern_Set

	; pause during rest
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA iChannelNoteFlags, X
	BNE @CheckMuteTimer

@EnvelopePattern_Set:
	; store envelope during note
	ORA iChannelCycle, X
	STA zCurrentTrackEnvelope
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X

@CheckMuteTimer:
	PLA
	AND #1 << SOUND_MUTE
	BNE @MuteTimer
	RTS

@MuteTimer:
	; check for active counter
	LDA iChannelMuteCounter, X
	BEQ @MuteTimer_Enable

	; disable
	DEC iChannelMuteCounter, X
	RTS

@MuteTimer_Enable:
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA iChannelNoteFlags, X
	RTS

ApplyPitchSlide:
	; quit if pitch slide inactive
	LDA iChannelFlagSection2, X
	AND #1 << SOUND_PITCH_SLIDE
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
	AND #1 << SOUND_PITCH_SLIDE_DIR
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
	AND #FF ^ (1 << SOUND_PITCH_SLIDE)
	STA iChannelFlagSection2, X
	LDA iChannelFlagSection3, X
	AND #FF ^ (1 << SOUND_PITCH_SLIDE_DIR)
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
	AND #1 << SOUND_NOISE ; noise
	BNE @CheckIfSFX
	RTS

@CheckIfSFX:
	; are we in a sfx channel?
	TXA
	AND #1 << SFX_CHANNEL
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
	ORA #$8
	STA zDrumChannel

	LDA zDrumDelay
	BEQ @Read

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
	STA zDrumDelay
	INC zDrumDelay ; adds one frame to depicted duration

	LDA (zDrumAddresses), Y
	INC zDrumAddresses

	BEQ @SkipCarry2, Y
	INC zDrumAddresses + 1

@SkipCarry2:
	STA zCurrentTrackEnvelope
	LDA (zDrumAddresses), Y
	INC zDrumAddresses

	BEQ @SkipCarry3
	INC zDrumAddresses + 1

@SkipCarry3:
	STA zCurrentTrackRawPitch
	LDA #8
	STA zCurrentTrackRawPitch + 1

	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
	RTS

@Quit:
	LDA zDrumChannel
	EOR #$8
	STA zDrumChannel
	RTS

HandleDPCM: ; NES only
	; is DPCM on?
	LDA iChannelFlagSection1, X
	AND #1 << SOUND_DPCM ; DPCM
	BNE @CheckIfSFX
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
	ORA #$10
	STA zDrumChannel

; sample struct:
;	[vv] [wx] [yy] [zz]
;	vv: bank #
;	w: loop / interrupt request
;	x: pitch
;	yy: sample offset
;       zz: sample size
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
	ORA #$80    ; ensures bank # points to ROM
	STA zWindow3 ; c000-dfff address range
	JSR UpdatePRG

	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BNE @SkipCarry2

	INC zDrumAddresses + 3

@SkipCarry2:
	AND #$1f
	STA zDPCMSamplePitch

	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BEQ @SkipCarry3

	INC zDrumAddresses + 3

@SkipCarry3:
	STA zDPCMSampleOffset

	LDA (zDrumAddresses + 2), Y
	INC zDrumAddresses + 2
	BEQ @SkipCarry4

	INC zDrumAddresses + 3

@SkipCarry4:
	STA zDPCMSampleLength
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X

	LDA zMixer
	ORA #1 << CHAN_4 ; turn on DPCM
	STA zMixer
	STA SND_CHN
	RTS

@Quit:
	LDA zDrumChannel
	EOR #$10
	STA zDrumChannel

	LDA zMixer
	AND #$ff ^ (1 << CHAN_4) ; turn off DPCM
	STA zMixer
	STA SND_CHN
	RTS

ParseMusic:
; parses until a note is read or the song is ended
	JSR GetMusicByte ; store next byte in a
	CMP #sound_ret_cmd
	BEQ @SoundRet

	CMP #FIRST_SOUND_COMMAND
	BCC @ReadNote

	; then it's a command
@ReadCommand:
	JSR ParseMusicCommand
	JMP ParseMusic ; start over

@ReadNote:
; zCurrentMusicByte contains current note
; special notes
	LDA iChannelFlagSection1, X
	PHA
	AND #1 << SOUND_READING_MODE | 1 << SOUND_REST  ; sfx / sfx
	BEQ @NextCheck
	PLA
	JMP ParseSFXOrRest

@NextCheck:
	PLA
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
	LSR A
	LSR A
	LSR A
	LSR A
	BEQ @Rest ; note 0 -> rest

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
	ORA #1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X
	JMP LoadNote

@Rest:
; note = rest
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA iChannelNoteFlags, X
	RTS

@SoundRet:
; $ff is reached in music data
	LDA iChannelFlagSection1, X
	AND #1 << SOUND_SUBROUTINE ; in a subroutine?
	BNE @ReadCommand ; execute

	TXA
	CMP #CHAN_8
	BCS @Channel8toC

	; check if Channel 9's on
	LDA iChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @OK

@Channel8toC:
	LDA iChannelFlagSection1, X
	AND #1 << SOUND_REST
	BEQ @SkipSub
	JSR RestoreVolume

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
	AND #$ff ^ (1 << SOUND_CHANNEL_ON)
	STA iChannelFlagSection1, X

	; note = rest
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA iChannelNoteFlags, X

	; clear music id & bank
	LDA #0
	STA iChannelID, X
	STA iChannelBank, X
	RTS

RestoreVolume:
	; ch9 only
	TXA
	CMP #CHAN_8
	BEQ @Channel9
	RTS

@Channel9:
	LDA #0
	STA iChannelPitchModifier + CHAN_9
	STA iChannelPitchModifier + CHAN_9 + 16
	STA iChannelPitchModifier + CHAN_B
	STA iChannelPitchModifier + CHAN_B + 16

	LDA zAudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
	STA zAudioCommandFlags
	RTS

ParseSFXOrRest:
	; turn noise on
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA iChannelNoteFlags, X

	; update note duration
	LDA zCurrentMusicByte
	JSR SetNoteDuration ; SFX notes can be longer than 16

	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2 ; ch3 has no duty cycle
	BEQ @Hill

	; update volume envelope from next param
	JSR GetMusicByte
	AND #$3f
	STA iChannelEnvelope, X
	JMP @GetRawPitch
@Hill:
	JSR GetMusicByte
	STA iChannelEnvelope, X
@GetRawPitch:
	; update low pitch from next param
	JSR GetMusicByte
	STA iChannelRawPitch, X

	; are we on the last PSG channel? (noise)
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BNE @NotNoise
	RTS

@NotNoise:
	; update high pitch from next param
	JSR GetMusicByte
	STA iChannelRawPitch + 16, X
	RTS

GetByteInEnvelopeGroup:
	; get pointer
	LDA EnvelopeGroups, Y
	STA zCurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA zCurrentEnvelopeGroupAddress + 1

	; store the offset in ZP RAM
	; each group can only be 256 bytes long
	LDA iChannelEnvelopeGroupOffset, X
	STA zCurrentEnvelopeGroupOffset
	ADC zCurrentEnvelopeGroupAddress
	STA zCurrentEnvelopeGroupAddress

	LDA #0
	STY zBackupY ; save param
	TAY
	ADC zCurrentEnvelopeGroupAddress + 1
	STA zCurrentEnvelopeGroupAddress + 1

	; check for ff/fe
	LDA (zCurrentEnvelopeGroupAddress), Y
	LDY zBackupY
	CMP #$ff
	BEQ @Quit

	CMP #$fe
	BNE @Next

	; reset offset when reading fe
	; effectively loops the envelope sequence
	LDA #0
	STA iChannelEnvelopeGroupOffset, X
	STA zCurrentEnvelopeGroupOffset

	LDA EnvelopeGroups, Y
	STA zCurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA zCurrentEnvelopeGroupAddress + 1
	TAY
	LDA (zCurrentEnvelopeGroupAddress), Y

@Next:
	INC iChannelEnvelopeGroupOffset, X
	INC zCurrentEnvelopeGroupOffset
	RTS

@Quit:
	SEC
	RTS

GetDrumSample:
; load ptr to sample headers in zDrumAddresses

	; are we on the last channels?
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
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
	TXA
	CMP #CHAN_B
	BEQ @SFXNoise
	BCS @SFXDPCM

	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON ; is ch12 on? (noise)
	BNE @CheckDPCM
	JSR @ContinueNoise

@CheckDPCM:
	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON ; is ch13 on? (dpcm)
	BEQ @ContinueDPCM
	RTS

@ContinueDPCM:
	; load set ID
	LDA zMusicDrumSet
	BPL @NextDPCM

@SFXDPCM:
	LDA zSFXDrumSet

@NextDPCM:
	; load pointer to sample in A
	; sets use bit 0-6, 7 is discarded
	ASL A
	TAY
	LDA SampleKits, Y
	STA zDrumAddresses + 2
	LDA SampleKits + 1, Y
	STA zDrumAddresses + 3
	; get note
	LDA zCurrentMusicByte
	; non-rest note?
	AND #$f0
	BNE @NonRestDPCM
	RTS

@NonRestDPCM:
	; use note to seek sample set
	LSR A
	LSR A
	LSR A
	; load pointer into part 2 of zDrumAddresses
	ADC zDrumAddresses + 2
	STA zDrumAddresses + 2
	LDA #0
	ADC zDrumAddresses + 3
	STA zDrumAddresses + 3
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
	STA zDrumAddresses
	LDA DrumKits + 1, Y
	STA zDrumAddresses + 1
	; get note
	LDA zCurrentMusicByte
	; non-rest note?
	AND #$f0
	BNE @NonRestNoise
	RTS

@NonRestNoise:
	; use note to seek noise set
	LSR A
	LSR A
	LSR A
	; load pointer into part 1 of zDrumAddresses
	ADC zDrumAddresses
	STA zDrumAddresses
	LDA #0
	ADC zDrumAddresses + 1
	STA zDrumAddresses + 1

	; clear delay
	LDA #0
	STA zDrumDelay
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
	STA zAudioCommandPointer
	LDA MusicCommands + 1, Y
	STA zAudioCommandPointer + 1
	; jump to the new pointer
	JMP (zAudioCommandPointer)

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
	.dw Music_TimeMute
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
	.dw Music_JumpRAM
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
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BEQ @Percussion
	RTS

@Percussion:
	LDA zAudioCommandFlags
	EOR #1 << FRAME_SWAP
	STA zAudioCommandFlags
	RTS

Music_PitchIncSwitch: ; command f1
; dec APU timer by 1, thus incrementing pitch
	LDA iChannelFlagSection1, X
	ORA #1 << SOUND_PITCH_INC_SWITCH
	STA iChannelFlagSection1, X
	LDA iChannelPitchIncrementation, X
	EOR #$1
	STA iChannelPitchIncrementation, X
	RTS

Music_SetMusic: ; command f3
	LDA iChannelFlagSection1, X
	ORA #1 << SOUND_READING_MODE
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
	AND #$ff ^ (1 << SOUND_SUBROUTINE)
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
	STA iChannelAddress, X
	JSR GetMusicByte
	STA iChannelAddress + 16, X

	; set subroutine flag
	LDA iChannelFlagSection1, X
	ORA #1 << SOUND_SUBROUTINE
	STA iChannelFlagSection1, X
	RTS

Music_Jump: ; command fc
; jump
; parameters: ll hh ; pointer

	; get pointer from next 2 bytes
	JSR GetMusicByte
	STA iChannelAddress, X
	JSR GetMusicByte
	STA iChannelAddress + 16, X
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
	AND #1 << SOUND_LOOPING ; has the loop been initiated?
	BNE @CheckLoop

	LDY zCurrentMusicByte ; loop counter 0 = infinite
	BEQ @Loop

	; initiate loop
	DEY
	LDA iChannelFlagSection1, X ; set loop flag
	ORA #1 << SOUND_LOOPING
	STA iChannelFlagSection1, X
	STY iChannelLoopCounter, X ; store loop counter

@CheckLoop:
	LDA iChannelLoopCounter, X ; are we done?
	BEQ @EndLoop

	DEC iChannelLoopCounter, X

@Loop:
	; get pointer
	JSR GetMusicByte
	; load new pointer into iChannelAddress
	STA iChannelAddress, X
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	RTS

@EndLoop:
	; reset loop flag
	LDA iChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_LOOPING)
	STA iChannelFlagSection1, X

	; skip to next command
	LDA iChannelAddress, X
	ADC #2 ; skip pointer
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
	STA iChannelAddress, X
	JSR GetMusicByte
	STA iChannelAddress + 16, X
	RTS

Music_JumpRAM: ; command ee
; conditional jump
; checks for active condition flags in ZP RAM
; in Pokemon each condition flag had their own byte
; in Vulpreich, to save space, these are stored as flags in zAudioCommandFlags
; params: 2
; ll hh ; pointer

	; get channel
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	TAY
	LDA zAudioCommandFlags
	; mask current channel (DPCM = noise for the sake of percussion)
	AND @Masks, Y
	BNE @Jump ; if active, jump
	; skip pointer
	LDA iChannelAddress, X
	ADC #2
	STA iChannelAddress, X
	LDA iChannelAddress + 16, X
	ADC #0
	STA iChannelAddress + 16, X
	RTS

@Jump:
	LDA zAudioCommandFlags
	EOR @Masks, Y

	JSR GetMusicByte
	STA iChannelAddress, X
	JSR GetMusicByte
	STA iChannelAddress + 16, X
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
	ORA #1 << SOUND_EVENT
	STA zAudioCommandFlags
	RTS

Music_TimeMute: ; command e2
; cuts a note off after a specified number of frames
; useful for optimization
; params: 1

	JSR GetMusicByte
	STA iChannelMuteMain, X

	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_MUTE
	STA iChannelFlagSection2, X
	RTS

Music_Vibrato: ; command e1
; vibrato
; params: 2
;	1: [xx]
	; delay in frames
;	2: [yz]
	; y: extent
	; z: rate (# frames per cycle)

	; set vibrato flag?
	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_VIBRATO
	STA iChannelFlagSection2, X

	; start at lower frequency (depth is positive)
	LDA iChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
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
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A ; halve
	STA zVibratoBackup
	ADC #0 ; round up
	ASL A
	ASL A
	ASL A
	ASL A
	ORA zVibratoBackup
	STA iChannelVibratoDepth, X
; update timer
	LDA zCurrentMusicByte
	; get bottom nybble
	AND #$f
	STA zVibratoBackup
	ASL A
	ASL A
	ASL A
	ASL A
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
	LSR A
	LSR A
	LSR A
	LSR A
	TAY

	; pitch in A
	LDA zCurrentMusicByte
	AND #$f
	JSR GetPitch

	STA iChannelSlideTarget, X
	STY iChannelSlideTarget + 16, X

	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_SLIDE
	STA iChannelFlagSection2, X
	RTS

Music_PitchOffset: ; command e6
; tone
; params: 1 (bigdw)
; offset to add to each note frequency
	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_MODIFIER
	STA iChannelFlagSection2, X

	JSR GetMusicByte
	STA iChannelPitchModifier + 16, X
	JSR GetMusicByte
	STA iChannelPitchModifier, X
	RTS

Music_RelativePitch: ; command e7
; set a note medium
; operates squarely on NoteTable
; params: 1
	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_RELATIVE_PITCH
	STA iChannelFlagSection2, X

	JSR GetMusicByte
	STA iChannelRelativeNoteID, X
	RTS

Music_CyclePattern: ; command de
; sequence of 4 cycles to be looped
; params: 1 (4 2-bit cycle arguments)
	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_CYCLE_LOOP ; cycle looping
	STA iChannelFlagSection2, X

	; cycle sequence
	JSR GetMusicByte
	ROR A
	ROR A
	STA iChannelCyclePattern, X
	; update duty cycle
	AND #$c0 ; only uses top 2 bits
	STA iChannelCycle, X
	RTS

Music_EnvelopePattern: ; command e8
; envelope group
; params: 1
	LDA iChannelFlagSection2, X
	ORA #1 << SOUND_ENV_PTRN
	STA iChannelFlagSection2, X

	JSR GetMusicByte
	STA iChannelEnvelopeGroup, X
	RTS

Music_ToggleMusic: ; command df
; switch to music mode
; params: none
	LDA iChannelFlagSection1, X
	EOR #1 << SOUND_READING_MODE
	STA iChannelFlagSection1, X
	RTS

Music_ToggleDrum: ; command e3
; toggle music sampling
; can't be used as a straight toggle since the param is not read from on->off
; on NES, the drumset byte is shared between noise and DPCM
; params:
; 	noise on: 1
; 	noise off: 0
	; toggle sampling
	LDA iChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA iChannelFlagSection1, X
	AND #1 << SOUND_NOISE ; isolate bit
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA zMusicDrumSet
	RTS

Music_SFXToggleDrum: ; command f0
; toggle sfx sampling
; params:
;	on: 1
; 	off: 0
	; toggle sampling
	LDA iChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA iChannelFlagSection1, X
	AND #1 << SOUND_NOISE ; isolate bit
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA zSFXDrumSet, X
	RTS

Music_PitchSweep: ; command dd
; update pitch sweep
; params: 1
	LDA iChannelNoteFlags, X
	ORA #1 << NOTE_PITCH_SWEEP
	STA iChannelNoteFlags, X
	TXA
	AND #1
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
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
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
	CMP #3
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
	ORA #1 << SFX_PRIORITY
	STA zAudioCommandFlags
	RTS

Music_SFXPriorityOff: ; command ed
; turn sfx priority off
; params: none
	LDA zAudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
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
	JSR _LoadMusicByte ; home ROM
	INC iChannelAddress, X
	INC zAuxAddresses
	BNE @Quit
	INC iChannelAddress + 16, X
	INC zAuxAddresses + 1
@Quit:
	LDY zBackupY
	LDA zCurrentMusicByte
	RTS

GetPitch:
;     in     out
; A = Pitch  lo
; Y = Octave hi
	STY zBackupY ; store input for use
	STA zBackupA
	; get octave
	LDA iChannelTransposition, X
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	ADC zBackupY
	PHA ; save octave
	; add pitch
	LDA iChannelTransposition, X
	AND #$f
	ADC zBackupA
	ASL A
	TAY
	; X = lo, Y = hi
	LDA NoteTable, Y
	STX zBackupX
	TAX
	LDA NoteTable + 1, Y
	TAY
	PLA ; retrieve octave

@Loop:
	CMP #7
	BCS @OK

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
	ORA #$8 ; make sure the note is on
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
	; store Tempo in zFactorBuffer
	LDA iChannelTempo, X
	STA zFactorBuffer
	LDA iChannelTempo + 16, X
	STA zFactorBuffer + 1
	; add workflow to the next result
	LDA iChannelNoteFlow, X
	STY zFactorBuffer + 2
	; multiply Tempo by last result (iChannelNoteLength * LOW(delay))
	JSR @Multiply
	; copy result to zFactorBuffer offset 2
	LDA zFactorBuffer + 2
	; store result in iChannelNoteFlow
	STA iChannelNoteFlow, X
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
	ROR A
	; is there a remainder?
	BCC @Skip

	; add it to the result
	STA zBackupA
	LDA zFactorBuffer
	ADC zFactorBuffer + 2
	STA zFactorBuffer + 2
	LDA zFactorBuffer + 1
	ADC zFactorBuffer + 3
	STA zFactorBuffer + 3

@Skip:
	ROL zFactorBuffer
	ROL zFactorBuffer + 1

	; are we done?
	LDA zBackupA
	BNE @Loop

	RTS

SetGlobalTempo:
	STX zBackupX ; save current channel
	STA zBackupA
	; are we dealing with music or sfx?
	TXA
	AND #1 << SFX_CHANNEL
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
	LDX zBackupX ; restore current channel
	LDA zBackupA
	RTS

Tempo:
; input:
; 	AY: note length

	; update Tempo
	LDA zBackupA
	STA iChannelTempo, X
	STY iChannelTempo + 16, X
	; clear workflow
	LDA #0
	STA iChannelNoteFlow, X
	RTS

StartChannel:
	LDX zBackupX
	LDA iChannelFlagSection1, X
	ORA #1 << SOUND_CHANNEL_ON ; turn channel on
	STA iChannelFlagSection1, X
	RTS

_PlayMusic:
; load music
	JSR MusicOff
	STY zMusicID ; song number
	; bank list
	LDA MusicBanks, Y
	STA zMusicBank
	LDA MusicLo, Y ; music header address
	LDX MusicHi, Y
	STA zAuxAddresses
	STX zAuxAddresses + 1
	JSR LoadMusicByte ; store first byte of music header in a
	AND #$e0 ; get channel total
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	ADC #1

@Loop:
; start playing channels
	PHA
	JSR LoadChannel
	JSR StartChannel
	PLA
	SBC #1
	BNE @Loop
	STA zDrumAddresses
	STA zDrumAddresses + 1
	STA zDrumAddresses + 2
	STA zDrumAddresses + 3
	STA zDrumDelay
	STA zMusicDrumSet
	LDA zAudioCommandFlags
	AND #1 << MUSIC_PLAYING | 1 << SFX_PRIORITY
	STA zAudioCommandFlags
	JMP MusicOn

_PlaySFX:
; clear channels if they aren't already
	STY zBackupY
	JSR MusicOff
	LDA iChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON ; ch9 on?
	BEQ @Ch9

	LDY #CHAN_0 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel
	STA zSweep1

@Ch9:
	LDA iChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChA

	LDY #CHAN_1 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel
	STA zSweep2

@ChA:
	LDA iChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChB

	LDY #CHAN_2 << 2 ; turn it off
	LDA #$0
	JSR ClearChannel

@ChB:
	LDA iChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChC

	LDY #CHAN_3 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel

@ChC:
	LDA iChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChannelsCleared

	LDY #CHAN_4 << 2 ; turn it off
	LDA #$0
	JSR ClearChannel

@ChannelsCleared:
; start reading sfx header for # chs
	LDY zBackupY
	STY zMusicID
	; bank list
	LDA SFXBanks, Y
	STA zMusicBank
	LDA SFXLo, Y ; sfx header address
	LDX SFXHi, Y
	STA zAuxAddresses
	STX zAuxAddresses + 1
	JSR LoadMusicByte ; store first byte of music header in a
	AND #$e0 ; get channel total
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	ADC #1

@StartChannels:
; start playing channels
	PHA
	JSR LoadChannel
	LDA iChannelFlagSection1, X
	ORA #1 << SOUND_READING_MODE
	STA iChannelFlagSection1, X
	JSR StartChannel
	PLA
	SBC #1
	BNE @StartChannels
	JSR MusicOn
	LDA zAudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
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
	AND #$f ; bit 0-3 (current channel)
	STA zCurrentChannel
	TAY
	LDX zCurrentChannel
	LDA iChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_CHANNEL_ON) ; channel off
	STA iChannelFlagSection1, X

; make sure channel is cleared
; set default tempo and note length in case nothing is loaded
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
	ADC #$10
	BCC @Loop1
	CLC

@Loop2:
	TAY
	LDA #0
	STA iChannelRAM + $200, Y
	TYA
	ADC #$10
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
; runs ClearChannel for all 5 channels
; functionally identical to InitSound
	LDA #0
	STA SND_CHN
	LDY #CHAN_0 << 2
	LDA #$30
	JSR ClearChannel
	LDY #CHAN_1 << 2
	LDA #$30
	JSR ClearChannel
	LDY #CHAN_2 << 2
	JSR ClearChannel
	LDY #CHAN_3 << 2
	LDA #$30
	JSR ClearChannel
	LDY #CHAN_4 << 2

ClearChannel:
; input: Y = APU offset
; output: 1/2/4 - 30 00 00 00 / 3/5 - 00 00 00 00
	STA SQ1_ENV, Y
	LDA #0
	STA SQ1_SWEEP, Y
	STA SQ1_LO, Y
	STA SQ1_HI, Y
	RTS
