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
	LDX #ZPAudioEnd - AudioZPRAM
@ClearZP:
	DEX
	STA AudioZPRAM, X
	BNE @ClearZP
	; clear 0200-04bf
	LDX #<ChannelRAMEnd - <ChannelRAM
@ClearCRAMPart1:
	DEX
	STA ChannelRAM + $200, X
	BNE @ClearCRAMPart1
@ClearCRAMPart2:
	DEX
	STA ChannelRAM, X
	STA ChannelRAM + $100, X
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
	LDA MusicID
	PHA
	JSR _InitSound
	PLA
	STA MusicID
	RTS

MusicOn:
	LDA AudioCommandFlags
	ORA #1 << MUSIC_PLAYING
	STA AudioCommandFlags
	RTS

MusicOff:
	LDA AudioCommandFlags
	AND #$ff ^ (1 << MUSIC_PLAYING)
	STA AudioCommandFlags
	RTS

_UpdateSound:
; called once per frame
	; no use updating audio if it's not playing
	LDA AudioCommandFlags
	AND #1 << MUSIC_PLAYING
	BNE @PlayerOn
	RTS

@PlayerOn:
	; start at ch1
	LDA #$f
	STA Mixer
	LDX #CHAN_0
	STX CurrentChannel

@Loop:
	; check channel power
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_CHANNEL_ON
	BEQ @AndItsOn ; aaaaand it's on!
	JMP @NextChannel

@AndItsOn:
	; check time left in the current note
	LDA ChannelNoteDuration, X
	CMP #2 ; 1 or 0?
	BCC @NoteOver

	DEC ChannelNoteDuration, X
	JMP @ContinueSoundUpdate

@NoteOver:
	; reset vibrato delay
	LDA ChannelVibratoPreamble, X
	STA ChannelVibratoCounter, X
	; turn vibrato off for now
	LDA ChannelFlagSection2, X
	AND #$ff ^ (1 << SOUND_VIBRATO)
	STA ChannelFlagSection2, X
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
	LDA ChannelCycle, X
	; volume envelope
	ORA ChannelEnvelope, X
	STA CurrentTrackEnvelope
	JMP @Continue

@Hill:
	; linear envelope
	LDA ChannelEnvelope, X
	STA HillLinearLength

@Continue:
	; raw pitch
	LDY ChannelRawPitch + 16, X
	LDA ChannelRawPitch, X
	STY CurrentTrackRawPitch + 1
	STA CurrentTrackRawPitch
	; effects, noise, DPCM
	JSR GeneralHandler
	JSR HandleNoise
	JSR HandleDPCM
	; turn off music when playing sfx?
	LDA AudioCommandFlags
	AND #1 << SFX_PRIORITY
	BEQ @Next
	; are we in a sfx channel right now?
	TXA ; X = current channel
	AND #1 << SFX_CHANNEL
	BNE @Next
	; are any sfx channels active?
	; if so, mute
	LDA ChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA ChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA ChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BNE @RestNote
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @Next

	LDA Mixer
	EOR #$10 ; turn on DPCM
	STA Mixer
	STA SND_CHN

@RestNote:
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST ; rest
	STA ChannelNoteFlags, X

@Next:
	; are we in a sfx channel right now?
	TXA
	AND #1 << SFX_CHANNEL
	BNE @SFXChannel
	LDA ChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @SoundChannelOn
@SFXChannel:
	JSR UpdateChannels
@SoundChannelOn:
	; clear note flags
	LDA #0
	STA ChannelNoteFlags, X
@NextChannel:
	; next channel
	INX
	INC CurrentChannel
	TXA
	CMP #CHAN_C + 1
	BCS @Done
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_4
	BCC @Valid
	BNE @NextChannel ; > DPCM means go straight to the next channel

@Valid:
	JMP @Loop
@Done:
	RTS

; X = current channel, Y = pointer offset, A = pointer data
UpdateChannels:
	TXA
	ASL A
	TAY
	LDA @FunctionPointers, Y
	STA ChannelFunctionPointer
	INY
	LDA @FunctionPointers, Y
	STA ChannelFunctionPointer + 1
	JMP (ChannelFunctionPointer)

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

@Pulse1:
	LDA ChannelNoteFlags, X
	PHA
	AND #1 << NOTE_PITCH_SWEEP
	BEQ @Pulse1_NoSweep

	LDA Sweep1
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

	JMP @Pulse1_CheckCycleOverride

@Pulse1_PitchOverride:
	LDA CurrentTrackRawPitch
	LDY CurrentTrackRawPitch + 1
	STA SQ1_LO
	STY SQ1_HI

@Pulse1_CheckCycleOverride:
	PLA
	PHA
	AND #1 << NOTE_CYCLE_OVERRIDE
	BNE @Pulse1_CycleOverride
	RTS

@Pulse1_CycleOverride:
@Pulse1_EnvOverride:
	PLA
	LDA CurrentTrackEnvelope
	STA SQ1_ENV
	RTS

@Pulse1_VibratoOverride:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA SQ1_ENV
	STY SQ1_LO
	RTS

@Pulse1_Rest:
	PLA
	LDY #CHAN_0 << 2
	LDA #$30
	JMP ClearChannel

@Pulse1_NoiseSampling:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA SQ1_ENV
	LDA CurrentTrackRawPitch + 1
	STY SQ1_LO
	STA SQ1_HI
	RTS

@Pulse2:
	LDA ChannelNoteFlags, X
	PHA
	AND #1 << NOTE_PITCH_SWEEP
	BEQ @Pulse2_NoSweep

	LDA Sweep2
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
	RTS

@Pulse2_EnvCycleOverrides:
	PLA
	LDA CurrentTrackEnvelope
	STA SQ2_ENV
	RTS

@Pulse2_PitchOverride:
	PLA
	LDA CurrentTrackRawPitch
	LDY CurrentTrackRawPitch + 1
	STA SQ2_LO
	STY SQ2_HI
	RTS

@Pulse2_VibratoOverride:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA SQ2_ENV
	STY SQ2_LO
	RTS
	
@Pulse2_Rest:
	PLA
	LDY #CHAN_1 << 2
	LDA #$30
	JMP ClearChannel

@Pulse2_NoiseSampling:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA SQ2_ENV
	LDA CurrentTrackRawPitch + 1
	STY SQ2_LO
	STA SQ2_HI
	RTS

@Hill:
	LDA ChannelNoteFlags, X
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
	RTS

@Hill_PitchOverride:
	PLA
	LDA CurrentTrackRawPitch
	LDY CurrentTrackRawPitch + 1
	STA TRI_LO
	STY TRI_HI
	RTS

@Hill_VibratoOverride:
	PLA
	LDA CurrentTrackRawPitch
	STA TRI_LO
	RTS

@Hill_Rest:
	PLA
	LDY #CHAN_2 << 2
	LDA #$0
	JMP ClearChannel

@Hill_NoiseSampling:
	PLA
	LDA HillLinearLength
	LDY CurrentTrackRawPitch
	STA TRI_LINEAR
	LDA CurrentTrackRawPitch + 1
	STY TRI_HO
	STA TRI_HI
	RTS

@Noise:
	LDA ChannelNoteFlags, X
	PHA
	AND #1 << NOTE_NOISE_SAMPLING
	BNE @Noise_NoiseSampling

	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @Noise_Rest
	RTS

@Noise_Rest:
	PLA
	LDY #CHAN_3 << 2
	LDA #$30
	JMP ClearChannel

@Noise_NoiseSampling:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA NOISE_ENV
	STY NOISE_LO
	LDA #$8
	STA NOISE_HI
	RTS

@DPCM:
	LDA ChannelNoteFlags, X
	PHA
	AND #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	BNE @DPCM_DeltaNoiseSamplingOverrides

	PLA
	PHA
	AND #1 << NOTE_REST
	BNE @DPCM_Rest
	RTS

@DPCM_Rest:
	PLA
	LDA Mixer
	EOR #$10 ; turn off DPCM
	STA Mixer
	STA SND_CHN
	LDY #CHAN_4 << 2
	LDA #$0
	JMP ClearChannel

@DPCM_DeltaNoiseSamplingOverrides:
	PLA
	LDA DPCMSamplePitch
	STA DPCM_ENV
	LDA DPCMSampleOffset
	STA DPCM_OFFSET
	LDA DPCMSampleLength
	STA DPCM_SIZE
	RTS

@None:
	RTS

LoadNote:
	; wait for pitch slide to finish
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_PITCH_SLIDE
	BNE @PitchSlide
	JMP @CheckRelativePitch
	; get note duration
@PitchSlide:
	LDA ChannelNoteDuration, X
	SBC CurrentNoteDuration
	BPL @PitchSlide_OK
	LDA #1
@PitchSlide_OK:
	STA CurrentNoteDuration
	; get raw pitch
	LDA ChannelRawPitch, X
	LDY ChannelRawPitch + 16, X
	STA RawPitchBackup
	STY RawPitchBackup + 1
	; get direction of pitch slide
	LDA ChannelSlideTarget, X
	LDY ChannelSlideTarget + 16, X
	STA RawPitchTargetBackup
	STY RawPitchTargetBackup + 1
	SBC ChannelRawPitch, X
	STA PitchSlideDifference
	TYA
	SBC ChannelRawPitch + 16, X
	STA PitchSlideDifference + 1
	BCS @PitchSlide_Greater
	LDA ChannelFlagSection3, X
	ORA #1 << SOUND_PITCH_SLIDE_DIR
	STA ChannelFlagSection3, X
	; flip bits of differential
	LDA PitchSlideDifference + 1
	EOR #$ff
	STA PitchSlideDifference + 1
	LDA PitchSlideDifference
	EOR #$ff
	ADC #1
	STA PitchSlideDifference
	JMP @PitchSlide_Resume

@PitchSlide_Greater:
	; clear directional flag
	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_PITCH_SLIDE_DIR)
	STA ChannelFlagSection3, X

@PitchSlide_Resume:
	LDY #0 ; quotient

@PitchSlide_Loop:
	; PitchSlideDifference = x' * CurrentNoteDuration + y'
	; x' + 1 -> >PitchSlideDifference
	; y' -> a
	INY
	LDA PitchSlideDifference
	SBC CurrentNoteDuration
	STA PitchSlideDifference
	; borrow is not needed, loop
	BCS @PitchSlide_Loop

	LDA PitchSlideDifference + 1
	BEQ @PitchSlide_Quit

	DEC PitchSlideDifference + 1
	JMP @PitchSlide_Loop

@PitchSlide_Quit:
	LDA PitchSlideDifference ; remainder
	ADC CurrentNoteDuration
	STY PitchSlideDifference + 1 ; quotient

	STY ChannelSlideDepth, X ; quotient
	STA ChannelSlideFraction, X ; remainder
	LDA #0
	STA ChannelSlideTempo, X

@CheckRelativePitch:
	PLA
	PHA
	AND #1 << SOUND_RELATIVE_PITCH
	BEQ @CheckEnvelopePattern

	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA ChannelFlagSection3, X

@CheckEnvelopePattern:
	PLA
	PHA
	AND #1 << SOUND_ENV_PTRN
	BEQ @CheckMuteTimer

	LDA ChannelNoteFlags, X
	AND #$ff ^ (1 << NOTE_ENV_OVERRIDE)
	STA ChannelNoteFlags, X
	; reset offset
	LDA #0
	STA ChannelEnvelopeGroupOffset, X

@CheckMuteTimer:
	PLA
	AND #1 << SOUND_MUTE
	BNE @MuteTimer
	RTS

@MuteTimer:
	; read main byte
	LDA ChannelMuteMain, X
	; copy to counter
	STA ChannelMuteCounter, X
	RTS

GeneralHandler:
; handle cycle, pitch, env ptrn, mute, and vibrato
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_CYCLE_LOOP ; cycle looping
	BEQ @CheckRelativePitch

	LDA CurrentTrackEnvelope
	AND #$3f
	STA CurrentTrackEnvelope
	LDA ChannelCyclePattern, X
	ROL A
	ROL A
	STA ChannelCyclePattern, X
	AND #$c0
	ORA CurrentTrackEnvelope
	STA CurrentTrackEnvelope

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_CYCLE_OVERRIDE
	STA ChannelNoteFlags, X

@CheckRelativePitch:
	PLA
	PHA
	AND #1 << SOUND_RELATIVE_PITCH
	BEQ @CheckPitchOffset

	; is relative pitch on?
	LDA ChannelFlagSection3, X
	PHA
	AND #1 << SOUND_REL_PITCH_FLAG

	BEQ @RelativePitch_SetFlag

	PLA
	PHA
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA ChannelFlagSection3, X

	AND #1 << SOUND_REST
	BNE @RelativePitch_SetFlag

	PLA
	; get pitch
	LDA ChannelNoteID, X
	; add to pitch value
	ADC ChannelRelativeNoteID, X
	STA ChannelNoteID, X

	; get octave
	LDY ChannelOctave, X
	; get final tone
	JSR GetPitch
	STA CurrentTrackRawPitch
	STY CurrentTrackRawPitch + 1

@RelativePitch_SetFlag:
	PLA
	ORA #1 << SOUND_REL_PITCH_FLAG
	STA ChannelFlagSection3, X

; interesting notes:
;	$d9 and $e7 can stack with each other
;		$d9 $01 and $e7 $01 together would be the same as $d9/e7 $02
;	$e7 $f4-ff can trigger the rest pitch due to a lack of carry

@CheckPitchModifier:
	PLA
	AND #1 << SOUND_PITCH_MODIFIER
	BEQ @CheckPitchInc

	; sub offset to ChannelRawPitch
	LDA CurrentTrackRawPitch
	SBC ChannelPitchModifier + 16, X
	STA CurrentTrackRawPitch

	LDA CurrentTrackRawPitch + 1
	SBC ChannelPitchModifier, X
	STA CurrentTrackRawPitch + 1

@CheckPitchInc:
	; is pitch inc on?
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_PITCH_INC_SWITCH
	BEQ @CheckVibrato

	; is the byte active?
	LDA ChannelPitchIncrementation, X
	BEQ @CheckVibrato

	; if so, inc the pitch by 1
	LDA CurrentTrackRawPitch
	BEQ @CheckPitchInc_NoCarry

	; inc high byte if low byte rolls over
	DEC CurrentTrackRawPitch + 1

; incidentally, pitch_inc_switch can stack with pitch_offset
; for example, $f1 followed by $e6 $0001 would essentially mean $e6 $0002
@CheckPitchInc_NoCarry:
	DEC CurrentTrackRawPitch

@CheckVibrato:
	; is vibrato on?
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_VIBRATO ; vibrato
	BEQ @CheckEnvelopePattern

	; is vibrato active for this note yet?
	; is the preamble over?
	LDA ChannelVibratoCounter, X
	BNE @Vibrato_Subexit2

	; is the depth nonzero?
	LDA ChannelVibratoDepth, X
	BEQ @CheckEnvelopePattern

	; save it for later
	STA VibratoBackup

	; is it time to bend up/down?
	LDA ChannelVibratoTimer, X
	AND #$f ; timer
	BEQ @Vibrato_Bend

	DEC ChannelVibratoTimer, X
	JMP @CheckEnvelopePattern

@Vibrato_Subexit2:
	DEC ChannelVibratoCounter, X
	JMP @CheckEnvelopePattern

@Vibrato_Bend:
	; refresh counter
	ASL A
	ASL A
	ASL A
	ASL A
	ORA ChannelVibratoTimer, X
	STA ChannelVibratoTimer, X

	; get raw pitch
	LDA CurrentTrackRawPitch
	TAY

	; get direction
	LDA ChannelFlagSection3, X
	PHA
	AND #1 << SOUND_VIBRATO_DIR ; vibrato up/down
	BEQ @Vibrato_Down

; up

	; vibrato down
	PLA
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
	STA ChannelFlagSection3, X
	; get the depth
	LDA VibratoBackup
	AND #$f ; low
	STA VibratoBackup
	TYA
	SBC VibratoBackup
	BCS @Vibrato_NoBorrow
	LDA #0
	BEQ @Vibrato_NoCarry

@Vibrato_Down:
	; vibrato up
	PLA
	ORA #1 << SOUND_VIBRATO_DIR
	STA ChannelFlagSection3, X

	; get the depth
	LDA VibratoBackup
	AND #$f0 ; high
	; move it to lo
	LSR A
	LSR A
	LSR A
	LSR A
	STY VibratoBackup
	ADC VibratoBackup
	BCC @Vibrato_NoCarry
	LDA #$ff

@Vibrato_NoBorrow:
@Vibrato_NoCarry:
	STA CurrentTrackRawPitch
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_VIBRATO_OVERRIDE
	STA ChannelNoteFlags, X

@CheckEnvelopePattern:
	PLA
	PHA
	AND #1 << SOUND_ENV_PTRN
	BEQ @CheckMuteTimer

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_ENV_OVERRIDE
	STA ChannelNoteFlags, X

	; get group pointer
	LDA ChannelEnvelopeGroup, X
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
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	JMP @CheckMuteTimer

@EnvelopePattern_Set:
	; store envelope during note
	ORA ChannelCycle, X
	STA CurrentTrackEnvelope
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X

@CheckMuteTimer:
	PLA
	AND #1 << SOUND_MUTE
	BNE @MuteTimer
	RTS

@MuteTimer:
	; check for active counter
	LDA ChannelMuteCounter, X
	BEQ @MuteTimer_Enable

	; disable
	DEC ChannelMuteCounter, X
	RTS

@MuteTimer_Enable:
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	RTS

ApplyPitchSlide:
	; quit if pitch slide inactive
	LDA ChannelFlagSection2, X
	AND #1 << SOUND_PITCH_SLIDE
	BNE @Now
	RTS

@Now:
	; back up raw pitch
	LDA ChannelRawPitch, X
	LDY ChannelRawPitch + 16, X
	STA RawPitchBackup
	STY RawPitchBackup + 1

	; check whether pitch slide is going up or down
	LDA ChannelFlagSection3, X
	AND #1 << SOUND_PITCH_SLIDE_DIR
	BNE @SlidingUp

	; sliding down
	CLC
	LDA RawPitchBackup
	ADC ChannelSlideDepth, X
	STA ChannelRawPitch, X
	TYA
	ADC #0
	STA ChannelRawPitch + 16, X

	; ChannelSlideTempo += ChannelSlideFraction
	; if rollover: pitch += 1
	LDA ChannelSlideTempo, X
	ADC ChannelSlideFraction, X
	STA ChannelSlideFraction, X

	LDA #0
	ADC ChannelRawPitch, X
	STA ChannelRawPitch, X
	LDA #0
	ADC ChannelRawPitch + 16, X
	STA ChannelRawPitch + 16, X

	; Compare the dw at ChannelSlideTarget to ChannelRawPitch.
	; If pitch is greater, we're finished.
	; Otherwise, load the pitch and set two flags.
	LDA ChannelSlideTarget + 16, X
	CMP ChannelRawPitch + 16, X
	BCS @Finished
	BNE @Continue

	LDA ChannelSlideTarget, X
	CMP ChannelRawPitch, X
	BEQ @JumpToContinue
	BCS @Finished
@JumpToContinue:
	JMP @Continue

@SlidingUp:
	; pitch -= ChannelSlideDepth
	SEC
	LDA RawPitchBackup
	SBC ChannelSlideDepth, X
	STA ChannelRawPitch, X
	BCS @SlidingUp_NoDec
	DEY
@SlidingUp_NoDec:
	STA ChannelRawPitch + 16, X

	; ChannelSlideTempo *= 2
	; if rollover: pitch -= 1
	LDA ChannelSlideFraction, X
	ASL A
	STA ChannelSlideFraction, X
	LDA ChannelRawPitch, X
	SBC #0
	STA ChannelRawPitch, X
	TYA
	SBC #0
	TAY
	STA ChannelRawPitch + 16, X

	; Compare the dw at ChannelSlideTarget to ChannelRawPitch.
	; If pitch is lower, we're finished.
	; Otherwise, load the pitch and set two flags.
	LDA ChannelSlideTarget + 16, X
	CMP ChannelRawPitch + 16, X
	BCS @Finished
	BNE @Continue

	LDA ChannelSlideTarget, X
	CMP ChannelRawPitch, X
	BCC @Continue

@Finished:
	LDA ChannelFlagSection2, X
	AND #FF ^ (1 << SOUND_PITCH_SLIDE)
	STA ChannelFlagSection2, X
	LDA ChannelFlagSection3, X
	AND #FF ^ (1 << SOUND_PITCH_SLIDE_DIR)
	STA ChannelFlagSection3, X
	RTS

@Continue:
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_PITCH_OVERRIDE | 1 << NOTE_CYCLE_OVERRIDE
	STA ChannelNoteFlags, X
	RTS

HandleNoise:
	; is noise on?
	LDA ChannelFlagSection1, X
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
	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_NOISE | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS ; quit if so

@Next:
	; exclusive to NES - percussion uses two channels: Noise and DPCM
	LDA DrumChannel
	ORA #$8
	STA DrumChannel

	LDA DrumDelay
	BEQ @Read

	DEC DrumDelay
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
	LDA DrumAddresses
	ORA DrumAddresses + 1
	BEQ @Quit

	LDA (DrumAddresses), Y
	INC DrumAddresses

	BNE @SkipCarry1
	INC DrumAddresses + 1

@SkipCarry1:
	CMP #sound_ret_cmd
	BEQ @Quit

	AND #$f
	STA DrumDelay
	INC DrumDelay ; adds one frame to depicted duration

	LDA (DrumAddresses), Y
	INC DrumAddresses

	BEQ @SkipCarry2, Y
	INC DrumAddresses + 1

@SkipCarry2:
	STA CurrentTrackEnvelope
	LDA (DrumAddresses), Y
	INC DrumAddresses

	BEQ @SkipCarry3
	INC DrumAddresses + 1

@SkipCarry3:
	STA CurrentTrackRawPitch
	LDA #8
	STA CurrentTrackRawPitch + 1

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X
	RTS

@Quit:
	LDA DrumChannel
	EOR #$8
	STA DrumChannel
	RTS

HandleDPCM: ; NES only
	; is DPCM on?
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_DPCM ; DPCM
	BNE @CheckIfSFX
	RTS

@CheckIfSFX:
	; is ch13 on? (DPCM)
	; is ch13 playing samples?
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_DPCM | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS ; quit if so

@Next:
	LDA DrumChannel
	ORA #$10
	STA DrumChannel

; sample struct:
;	[vv] [wx] [yy] [zz]
;	vv: bank #
;	w: loop / interrupt request
;	x: pitch
;	yy: sample offset
;       zz: sample size
	LDY #0
	LDA DrumAddresses + 2
	ORA DrumAddresses + 3
	BEQ @Quit

	LDA (DrumAddresses + 2), Y
	INC DrumAddresses + 2
	BNE @SkipCarry1

	INC DrumAddresses + 3

@SkipCarry1:
	STA DPCMSampleBank
	ORA #$80    ; ensures bank # points to ROM
	STA Window3 ; c000-dfff address range
	JSR UpdatePRG

	LDA (DrumAddresses + 2), Y
	INC DrumAddresses + 2
	BNE @SkipCarry2

	INC DrumAddresses + 3

@SkipCarry2:
	AND #$1f
	STA DPCMSamplePitch

	LDA (DrumAddresses + 2), Y
	INC DrumAddresses + 2
	BEQ @SkipCarry3

	INC DrumAddresses + 3

@SkipCarry3:
	STA DPCMSampleOffset

	LDA (DrumAddresses + 2), Y
	INC DrumAddresses + 2
	BEQ @SkipCarry4

	INC DrumAddresses + 3

@SkipCarry4:
	STA DPCMSampleLength
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_DELTA_OVERRIDE | 1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X

	LDA Mixer
	EOR #$10 ; turn on DPCM
	STA Mixer
	STA SND_CHN
	RTS

@Quit:
	LDA DrumChannel
	EOR #$10
	STA DrumChannel

	LDA Mixer
	EOR #$10 ; turn off DPCM
	STA Mixer
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
; CurrentMusicByte contains current note
; special notes
	LDA ChannelFlagSection1, X
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
	LDA CurrentMusicByte
	AND #$f
	JSR SetNoteDuration

	; get note ID (top nybble)
	LDA CurrentMusicByte
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	BEQ @Rest ; note 0 -> rest

	; update note ID
	STA ChannelNoteID, X
	; store octave in Y
	LDY ChannelOctave, X
	; update raw pitch
	JSR GetPitch
	STA CurrentTrackRawPitch
	STY CurrentTrackRawPitch + 1

	; check if note or rest
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X
	JMP LoadNote

@Rest:
; note = rest
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	RTS

@SoundRet:
; $ff is reached in music data
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_SUBROUTINE ; in a subroutine?
	BNE @ReadCommand ; execute

	TXA
	CMP #CHAN_8
	BCS @Channel8toC

	; check if Channel 9's on
	LDA ChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @OK

@Channel8toC:
	LDA ChannelFlagSection1, X
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
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_CHANNEL_ON)
	STA ChannelFlagSection1, X

	; note = rest
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X

	; clear music id & bank
	LDA #0
	STA ChannelID, X
	STA ChannelBank, X
	RTS

RestoreVolume:
	; ch9 only
	TXA
	CMP #CHAN_8
	BEQ @Channel9
	RTS

@Channel9:
	LDA #0
	STA ChannelPitchModifier + CHAN_9
	STA ChannelPitchModifier + CHAN_9 + 16
	STA ChannelPitchModifier + CHAN_B
	STA ChannelPitchModifier + CHAN_B + 16

	LDA AudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
	STA AudioCommandFlags
	RTS

ParseSFXOrRest:
	; turn noise on
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X

	; update note duration
	LDA CurrentMusicByte
	JSR SetNoteDuration ; SFX notes can be longer than 16

	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2 ; ch3 has no duty cycle
	BEQ @Hill

	; update volume envelope from next param
	JSR GetMusicByte
	AND #$3f
	STA ChannelEnvelope, X
	JMP @GetRawPitch
@Hill:
	JSR GetMusicByte
	STA ChannelEnvelope, X
@GetRawPitch:
	; update low pitch from next param
	JSR GetMusicByte
	STA ChannelRawPitch, X

	; are we on the last PSG channel? (noise)
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BNE @NotNoise
	RTS

@NotNoise:
	; update high pitch from next param
	JSR GetMusicByte
	STA ChannelRawPitch + 16, X
	RTS

GetByteInEnvelopeGroup:
	; get pointer
	LDA EnvelopeGroups, Y
	STA CurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA CurrentEnvelopeGroupAddress + 1

	; store the offset in ZP RAM
	; each group can only be 256 bytes long
	LDA ChannelEnvelopeGroupOffset, X
	STA CurrentEnvelopeGroupOffset
	ADC CurrentEnvelopeGroupAddress
	STA CurrentEnvelopeGroupAddress

	LDA #0
	STY BackupY ; save param
	TAY
	ADC CurrentEnvelopeGroupAddress + 1
	STA CurrentEnvelopeGroupAddress + 1

	; check for ff/fe
	LDA (CurrentEnvelopeGroupAddress), Y
	LDY BackupY
	CMP #$ff
	BEQ @Quit

	CMP #$fe
	BNE @Next

	; reset offset when reading fe
	; effectively loops the envelope sequence
	LDA #0
	STA ChannelEnvelopeGroupOffset, X
	STA CurrentEnvelopeGroupOffset

	LDA EnvelopeGroups, Y
	STA CurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA CurrentEnvelopeGroupAddress + 1
	TAY
	LDA (CurrentEnvelopeGroupAddress), Y

@Next:
	INC ChannelEnvelopeGroupOffset, X
	INC CurrentEnvelopeGroupOffset
	RTS

@Quit:
	SEC
	RTS

GetDrumSample:
; load ptr to sample headers in DrumAddresses

	; are we on the last channels?
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3

	; ret if not
	BCS @Valid
	RTS

@Valid:
	; update note duration
	LDA CurrentMusicByte
	AND #$f
	JSR SetNoteDuration

	; check current channel
	TXA
	CMP #CHAN_B
	BEQ @SFXNoise
	BCS @SFXDPCM

	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON ; is ch12 on? (noise)
	BNE @CheckDPCM
	JSR @ContinueNoise

@CheckDPCM:
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON ; is ch13 on? (dpcm)
	BEQ @ContinueDPCM
	RTS

@ContinueDPCM:
	; load set ID
	LDA MusicDrumSet
	JMP @NextDPCM

@SFXDPCM:
	LDA SFXDrumSet

@NextDPCM:
	; load pointer to sample in A
	; sets use bit 0-6, 7 is discarded
	ASL A
	TAY
	LDA SampleKits, Y
	STA DrumAddresses + 2
	LDA SampleKits + 1, Y
	STA DrumAddresses + 3
	; get note
	LDA CurrentMusicByte
	; non-rest note?
	AND #$f0
	BNE @NonRestDPCM
	RTS

@NonRestDPCM:
	; use note to seek sample set
	LSR A
	LSR A
	LSR A
	; load pointer into part 2 of DrumAddresses
	ADC DrumAddresses + 2
	STA DrumAddresses + 2
	LDA #0
	ADC DrumAddresses + 3
	STA DrumAddresses + 3
	RTS

@ContinueNoise:
	; load set ID
	LDA MusicDrumSet
	JMP @NextNoise

@SFXNoise:
	LDA SFXDrumSet

@NextNoise:
	; load pointer to noise in A
	ASL A
	TAY
	LDA DrumKits, Y
	STA DrumAddresses
	LDA DrumKits + 1, Y
	STA DrumAddresses + 1
	; get note
	LDA CurrentMusicByte
	; non-rest note?
	AND #$f0
	BNE @NonRestNoise
	RTS

@NonRestNoise:
	; use note to seek noise set
	LSR A
	LSR A
	LSR A
	; load pointer into part 1 of DrumAddresses
	ADC DrumAddresses
	STA DrumAddresses
	LDA #0
	ADC DrumAddresses + 1
	STA DrumAddresses + 1

	; clear delay
	LDA #0
	STA DrumDelay
	RTS

ParseMusicCommand:
	; reload command
	LDA CurrentMusicByte
	; get command #
	SBC #FIRST_SOUND_COMMAND
	ASL A
	TAY
	; seek command pointer
	LDA MusicCommands, Y
	STA AudioCommandPointer
	LDA MusicCommands + 1, Y
	STA AudioCommandPointer + 1
	; jump to the new pointer
	JMP (AudioCommandPointer)

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
; controlled by AudioCommandFlags >> FRAME_SWAP
; only works on noise channels
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BEQ @Percussion
	RTS

@Percussion:
	LDA AudioCommandFlags
	EOR #1 << FRAME_SWAP
	STA AudioCommandFlags
	RTS

Music_PitchIncSwitch: ; command f1
; dec APU timer by 1, thus incrementing pitch
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_PITCH_INC_SWITCH
	STA ChannelFlagSection1, X
	LDA ChannelPitchIncrementation, X
	EOR #$1
	STA ChannelPitchIncrementation, X
	RTS

Music_SetMusic: ; command f3
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_READING_MODE
	STA ChannelFlagSection1, X
	RTS

Music_Ret: ; command ff
; called when $ff is encountered w/(o) subroutine flag set
; end music stream
; return to source address (if possible)

	; halves of the old code are reversed to apply a stack check
	; copy ChannelBackupAddress1 to ChannelAddress
	LDA ChannelBackupAddress1, X
	LDY ChannelBackupAddress1 + 16, X
	STA ChannelAddress, X
	STY ChannelAddress + 16, X
	; copy ChannelBackupAddress2 to ChannelBackupAddress1
	LDA ChannelBackupAddress2, X
	LDY ChannelBackupAddress2 + 16, X
	STA ChannelBackupAddress1, X
	STY ChannelBackupAddress1 + 16, X
	BEQ @ClearFlag

	LDA #0
	STA ChannelBackupAddress2, X
	STA ChannelBackupAddress2 + 16, X
	RTS

@ClearFlag:
	; reset subroutine flag
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_SUBROUTINE)
	STA ChannelFlagSection1, X
	RTS

Music_Call: ; command fe
; call music stream (subroutine)
; parameters: ll hh ; pointer to subroutine

	; copy ChannelBackupAddress1 to ChannelBackupAddress2
	LDA ChannelBackupAddress1, X
	LDY ChannelBackupAddress1 + 16, X
	STA ChannelBackupAddress2, X
	STA ChannelBackupAddress2 + 16, X
	; copy ChannelAddress to ChannelBackupAddress1
	LDA ChannelAddress, X
	LDY ChannelAddress + 16, X
	STA ChannelBackupAddress1, X
	STY ChannelBackupAddress1 + 16, X

	; get pointer from next 2 bytes
	JSR GetMusicByte
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X

	; set subroutine flag
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_SUBROUTINE
	STA ChannelFlagSection1, X
	RTS

Music_Jump: ; command fc
; jump
; parameters: ll hh ; pointer

	; get pointer from next 2 bytes
	JSR GetMusicByte
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X
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
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_LOOPING ; has the loop been initiated?
	BNE @CheckLoop

	LDY CurrentMusicByte ; loop counter 0 = infinite
	BEQ @Loop

	; initiate loop
	DEY
	LDA ChannelFlagSection1, X ; set loop flag
	ORA #1 << SOUND_LOOPING
	STA ChannelFlagSection1, X
	STY ChannelLoopCounter, X ; store loop counter

@CheckLoop:
	LDA ChannelLoopCounter, X ; are we done?
	BEQ @EndLoop

	DEC ChannelLoopCounter, X

@Loop:
	; get pointer
	JSR GetMusicByte
	; load new pointer into ChannelAddress
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X
	RTS

@EndLoop:
	; reset loop flag
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_LOOPING)
	STA ChannelFlagSection1, X

	; skip to next command
	LDA ChannelAddress, X
	ADC #2 ; skip pointer
	STA ChannelAddress, X
	LDA ChannelAddress + 16, X
	ADC #0 ; update high byte in case of carry
	STA ChannelAddress + 16, X
	RTS

Music_SetCondition: ; command fa
; set condition for a jump
; stores condition in channel RAM
; used with FB
; params: 1
;	xx ; condition

	; set condition
	JSR GetMusicByte
	STA ChannelCondition, X
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
	CMP ChannelCondition, X
	BEQ @Jump
; skip to next command
	; get address
	LDA ChannelAddress, X
	ADC #2 ; skip pointer
	STA ChannelAddress, X
	LDA ChannelAddress + 16, X
	ADC #0 ; update high byte in case of carry
	STA ChannelAddress + 16, X
	RTS

@Jump:
; jump to the new address
	; get pointer
	JSR GetMusicByte
	; update pointer in ChannelAddress
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X
	RTS

Music_JumpRAM: ; command ee
; conditional jump
; checks for active condition flags in ZP RAM
; in Pokemon each condition flag had their own byte
; in Vulpreich, to save space, these are stored as flags in AudioCommandFlags
; params: 2
; ll hh ; pointer

	; get channel
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	TAY
	LDA AudioCommandFlags
	; mask current channel (DPCM = noise for the sake of percussion)
	AND @Masks, Y
	BNE @Jump ; if active, jump
	; skip pointer
	LDA ChannelAddress, X
	ADC #2
	STA ChannelAddress, X
	LDA ChannelAddress + 16, X
	ADC #0
	STA ChannelAddress + 16, X
	RTS

@Jump:
	LDA AudioCommandFlags
	EOR @Masks, Y

	JSR GetMusicByte
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X
	RTS

@Masks:
	.db 1 << RCOND_PULSE_1    ; $10
	.db 1 << RCOND_PULSE_2    ; $20
	.db 1 << RCOND_HILL       ; $40
	.db 1 << RCOND_NOISE_DPCM ; $80
	.db 1 << RCOND_NOISE_DPCM ; $80 ; Noise and DPCM share a mask

Music_SetSoundEvent: ; command f9
; $F9
; sets an exclusive flag in AudioCommandFlags
; params: 0
	LDA AudioCommandFlags
	ORA #1 << SOUND_EVENT
	STA AudioCommandFlags
	RTS

Music_TimeMute: ; command e2
; cuts a note off after a specified number of frames
; useful for optimization
; params: 1

	JSR GetMusicByte
	STA ChannelMuteMain, X

	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_MUTE
	STA ChannelFlagSection2, X
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
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_VIBRATO
	STA ChannelFlagSection2, X

	; start at lower frequency (depth is positive)
	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
	STA ChannelFlagSection3, X
	; get preamble
	JSR GetMusicByte
; update preamble
	STA ChannelVibratoPreamble, X
; update counter
	STA ChannelVibratoCounter, X
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
	STA VibratoBackup
	ADC #0 ; round up
	ASL A
	ASL A
	ASL A
	ASL A
	ORA VibratoBackup
	STA ChannelVibratoDepth, X
; update timer
	LDA CurrentMusicByte
	; get bottom nybble
	AND #$f
	STA VibratoBackup
	ASL A
	ASL A
	ASL A
	ASL A
	ORA VibratoBackup
	STA ChannelVibratoTimer, X
	RTS

Music_PitchSlide: ; command e0
; set the target for pitch slide
; params: 2
; note duration
; target note
	JSR GetMusicByte
	STA CurrentNoteDuration
	JSR GetMusicByte

	; octave in Y
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	TAY

	; pitch in A
	LDA CurrentMusicByte
	AND #$f
	JSR GetPitch

	STA ChannelSlideTarget, X
	STY ChannelSlideTarget + 16, X

	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_SLIDE
	STA ChannelFlagSection2, X
	RTS

Music_PitchOffset: ; command e6
; tone
; params: 1 (bigdw)
; offset to add to each note frequency
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_MODIFIER
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelPitchModifier + 16, X
	JSR GetMusicByte
	STA ChannelPitchModifier, X
	RTS

Music_RelativePitch: ; command e7
; set a note medium
; operates squarely on NoteTable
; params: 1
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_RELATIVE_PITCH
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelRelativeNoteID, X
	RTS

Music_CyclePattern: ; command de
; sequence of 4 cycles to be looped
; params: 1 (4 2-bit cycle arguments)
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_CYCLE_LOOP ; cycle looping
	STA ChannelFlagSection2, X

	; cycle sequence
	JSR GetMusicByte
	ROR A
	ROR A
	STA ChannelCyclePattern, X
	; update duty cycle
	AND #$c0 ; only uses top 2 bits
	STA ChannelCycle, X
	RTS

Music_EnvelopePattern: ; command e8
; envelope group
; params: 1
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_ENV_PTRN
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelEnvelopeGroup, X
	RTS

Music_ToggleMusic: ; command df
; switch to music mode
; params: none
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_READING_MODE
	STA ChannelFlagSection1, X
	RTS

Music_ToggleDrum: ; command e3
; toggle music sampling
; can't be used as a straight toggle since the param is not read from on->off
; on NES, the drumset byte is shared between noise and DPCM
; params:
; 	noise on: 1
; 	noise off: 0
	; toggle sampling
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA ChannelFlagSection1, X
	AND #1 << SOUND_NOISE ; isolate bit
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA MusicDrumSet, X
	RTS

Music_SFXToggleDrum: ; command f0
; toggle sfx sampling
; params:
;	on: 1
; 	off: 0
	; toggle sampling
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA ChannelFlagSection1, X
	AND #1 << SOUND_NOISE ; isolate bit
	BNE @GetParam ; if routine turns on sampling, read param
	RTS

@GetParam:
	JSR GetMusicByte
	STA SFXDrumSet, X
	RTS

Music_PitchSweep: ; command dd
; update pitch sweep
; params: 1
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_PITCH_SWEEP
	STA ChannelNoteFlags, X
	TXA
	AND #1
	BNE @Pulse2

	JSR GetMusicByte
	STA Sweep1
	RTS

@Pulse2:
	JSR GetMusicByte
	STA Sweep2
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
	STA ChannelCycle, X
	RTS

Music_NoteType: ; command d8
; note length
;	# frames per 16th note
; volume envelope: see Music_Envelope
; params: 2

	; note length
	JSR GetMusicByte
	STA ChannelNoteLength, X
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
	STA ChannelEnvelope, X
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
	LDA CurrentMusicByte
	AND #7
	STA ChannelOctave, X
	RTS

Music_Transpose: ; command d9
; pitch / octave offset
; params: 1
	JSR GetMusicByte
	STA ChannelTransposition, X
	RTS

Music_TempoRelative: ; command e9
; set global tempo to current channel tempo +/- param
; params: 1 signed
	JSR GetMusicByte
	LDA CurrentMusicByte
	BMI @Minus

	LDY #0
	JMP @OK

@Minus:
	LDY #$ff

@OK:
	ADC ChannelTempo + 16, X
	PHA
	TYA
	ADC ChannelTempo, X
	TAY
	PLA
	JMP SetGlobalTempo

Music_SFXPriorityOn: ; command ec
; turn sfx priority on
; params: none
	LDA AudioCommandFlags
	ORA #1 << SFX_PRIORITY
	STA AudioCommandFlags
	RTS

Music_SFXPriorityOff: ; command ed
; turn sfx priority off
; params: none
	LDA AudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
	STA AudioCommandFlags
	RTS

Music_RestartChannel: ; command ea
; restart current channel from channel header (same bank)
; params: 2 (5)
; ll hh: pointer to new channel header
;	header format: 0x yy zz
;		x: channel # (0-4)
;		zzyy: pointer to new music data

	; update music id
	LDA ChannelID, X
	STA MusicID
	LDA ChannelBank, X
	STA MusicBank

	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STX BackupX
	TAX
	TYA
	STA AuxAddresses
	STX AuxAddresses + 1
	JSR LoadChannel
	JSR StartChannel
	LDX BackupX
	RTS

Music_NewSong: ; command eb
; new song
; params: 2
;	Y: song id
	JSR GetMusicByte
	TAY
	STX BackupX
	JSR _PlayMusic
	LDX BackupX
	RTS

GetMusicByte:
; returns byte from current address in A
; advances to next byte in music data
; input: X = current channel
	JSR _LoadMusicByte ; home ROM
	INC ChannelAddress, X
	INC AuxAddresses
	BNE @Quit
	INC ChannelAddress + 16, X
	INC AuxAddresses + 1
@Quit:
	LDY BackupY
	LDA CurrentMusicByte
	RTS

GetPitch:
;     in     out
; A = Pitch  lo
; Y = Octave hi
	STY BackupY ; store input for use
	STA BackupA
	; get octave
	LDA ChannelTransposition, X
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	ADC BackupY
	PHA ; save octave
	; add pitch
	LDA ChannelTransposition, X
	AND #$f
	ADC BackupA
	ASL A
	TAY
	; X = lo, Y = hi
	LDA NoteTable, Y
	STX BackupX
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
	LDX BackupX
	RTS

SetNoteDuration:
; input: a = note duration in 16ths

	; store delay units in FactorBuffer
	ADC #1
	STA FactorBuffer
	LDY #0
	STY FactorBuffer + 1
	; store NoteLength in a
	LDA ChannelNoteLength, X
	; multiply NoteLength by delay units
	STY FactorBuffer + 2 ; just multiply
	JSR @Multiply
	; store Tempo in FactorBuffer
	LDA ChannelTempo, X
	STA FactorBuffer
	LDA ChannelTempo + 16, X
	STA FactorBuffer + 1
	; add workflow to the next result
	LDA ChannelNoteFlow, X
	STY FactorBuffer + 2
	; multiply Tempo by last result (ChannelNoteLength * LOW(delay))
	JSR @Multiply
	; copy result to FactorBuffer offset 2
	LDA FactorBuffer + 2
	LDY FactorBuffer + 3
	; store result in ChannelNoteFlow
	STA ChannelNoteFlow, X
	; store result in NoteDuration
	STY ChannelNoteDuration, X
	RTS

@Multiply:
; multiplies a and FactorBuffer
; adds the result to l
; stores the result in FactorBuffer offset 2
	LDY #0
	STY FactorBuffer + 3

@Loop:
	; halve a
	ROR A
	; is there a remainder?
	BCC @Skip

	; add it to the result
	STA BackupA
	LDA FactorBuffer
	ADC FactorBuffer + 2
	STA FactorBuffer + 2
	LDA FactorBuffer + 1
	ADC FactorBuffer + 3
	STA FactorBuffer + 3

@Skip:
	ROL FactorBuffer
	ROL FactorBuffer + 1

	; are we done?
	LDA BackupA
	BNE @Loop

	RTS

SetGlobalTempo:
	STX BackupX ; save current channel
	STA BackupA
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
	JMP @End

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
	LDX BackupX ; restore current channel
	LDA BackupA
	RTS

Tempo:
; input:
; 	AY: note length

	; update Tempo
	LDA BackupA
	STA ChannelTempo, X
	STY ChannelTempo + 16, X
	; clear workflow
	LDA #0
	STA ChannelNoteFlow, X
	RTS

StartChannel:
	LDX BackupX
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_CHANNEL_ON ; turn channel on
	STA ChannelFlagSection1, X
	RTS

_PlayMusic:
; load music
	JSR MusicOff
	STY MusicID ; song number
	; bank list
	LDA MusicBanks, Y
	STA MusicBank
	LDA MusicLo, Y ; music header address
	LDX MusicHi, Y
	STA AuxAddresses
	STX AuxAddresses + 1
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
	STA DrumAddresses
	STA DrumAddresses + 1
	STA DrumAddresses + 2
	STA DrumAddresses + 3
	STA DrumDelay
	STA MusicDrumSet
	LDA AudioCommandFlags
	AND #1 << MUSIC_PLAYING | 1 << SFX_PRIORITY
	STA AudioCommandFlags
	JMP MusicOn

_PlaySFX:
; clear channels if they aren't already
	STY BackupY
	JSR MusicOff
	LDA ChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON ; ch9 on?
	BEQ @Ch9

	LDY #CHAN_0 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel
	STA Sweep1

@Ch9:
	LDA ChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChA

	LDY #CHAN_1 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel
	STA Sweep2

@ChA:
	LDA ChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChB

	LDY #CHAN_2 << 2 ; turn it off
	LDA #$0
	JSR ClearChannel

@ChB:
	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChC

	LDY #CHAN_3 << 2 ; turn it off
	LDA #$30
	JSR ClearChannel

@ChC:
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChannelsCleared

	LDY #CHAN_4 << 2 ; turn it off
	LDA #$0
	JSR ClearChannel

@ChannelsCleared:
; start reading sfx header for # chs
	LDY BackupY
	STY MusicID
	; bank list
	LDA SFXBanks, Y
	STA MusicBank
	LDA SFXLo, Y ; sfx header address
	LDX SFXHi, Y
	STA AuxAddresses
	STX AuxAddresses + 1
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
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_READING_MODE
	STA ChannelFlagSection1, X
	JSR StartChannel
	PLA
	SBC #1
	BNE @StartChannels
	JSR MusicOn
	LDA AudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
	STA AudioCommandFlags
	RTS

LoadChannel:
; prep channel for use
; input:
; 	AuxAddresses:
	; get pointer to current channel
	JSR LoadMusicByte
	INC AuxAddresses
	BNE @NoCarry1
	INC AuxAddresses + 1
@NoCarry1:
	STA BackupA
	AND #$f ; bit 0-3 (current channel)
	STA CurrentChannel
	TAY
	LDX CurrentChannel
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_CHANNEL_ON) ; channel off
	STA ChannelFlagSection1, X

; make sure channel is cleared
; set default tempo and note length in case nothing is loaded
	STY BackupY
	LDA CurrentChannel
	CLC ; start
	; clear channel
@Loop1:
	TAY
	LDA #0
	STA ChannelRAM, Y
	STA ChannelRAM + $100, Y
	TYA
	ADC #$10
	BCC @Loop1
	CLC

@Loop2:
	TAY
	LDA #0
	STA ChannelRAM + $200, Y
	TYA
	ADC #$10
	CMP #<ChannelRAMEnd
	BCC @Loop2
	; set tempo to default ($100)
	LDA #0
	STA ChannelTempo, X
	ADC #0
	STA ChannelTempo + 16, X
	; set note length to default ($1) (fast)
	STA ChannelNoteDuration, X
	JSR LoadMusicByte
	STA ChannelAddress, X
	INC AuxAddresses
	BNE @NoCarry2

	INC AuxAddresses + 1

@NoCarry2:
	; load music pointer
	JSR LoadMusicByte
	STA ChannelAddress + 16, X
	INC AuxAddresses
	BNE @NoCarry3

	INC AuxAddresses + 1
@NoCarry3:
	; load music id
	LDA MusicID
	STA ChannelID, X
	; load music bank
	LDA MusicBank
	STA ChannelBank, X
	RTS

LoadMusicByte:
; input:
;   AuxAddresses
; output:
;   A = CurrentMusicByte
	JSR _LoadMusicByte ; home ROM
	LDA CurrentMusicByte
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
