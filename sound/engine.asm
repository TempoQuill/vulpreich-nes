_InitSound:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	JSR MusicOff
	LDA #0
	STA SND_CHN
	LDX #(DPCM_SIZE - SQ1_ENV) + 1
@ClearAPU:
	DEX
	STA SQ1_ENV, X
	BNE @ClearAPU
	LDX #ZPAudioEnd - AudioZPRAM
@ClearZP:
	DEX
	STA AudioZPRAM, X
	BNE @ClearZP
	LDX #<ChannelRAMEnd - <ChannelRAM
@ClearCRAMPart1:
	DEX
	STA ChannelRAM + $300, X
	BNE @ClearCRAMPart1
@ClearCRAMPart2:
	DEX
	STA ChannelRAM, X
	STA ChannelRAM + $100, X
	STA ChannelRAM + $200, X
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
	LDA AudioCommandFlags
	AND #1 << MUSIC_PLAYING
	BNE @PlayerOn
	RTS

@PlayerOn:
	LDA #0
	STA CurrentChannel
	LDA #$f
	STA Mixer
	LDX #CHAN_0

@Loop:
	; check channel power
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_CHANNEL_ON
	BEQ @AndItsOn ; aaaaand it's on!
	JMP @NextChannel

@AndItsOn:
	LDA ChannelNoteDuration, X
	CMP #2
	BCC @NoteOver

	DEC ChannelNoteDuration, X
	JMP @ContinueSoundUpdate

@NoteOver:
	LDA ChannelVibratoPreamble, X
	STA ChannelVibratoCounter, X

	LDA ChannelFlagSection2, X
	AND #$ff ^ (1 << SOUND_VIBRATO)
	STA ChannelFlagSection2, X

	JSR ParseMusic

@ContinueSoundUpdate:
	JSR ApplyPitchSlide

	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2
	BEQ @Hill
	CMP #CHAN_4 ; dpcm has no volume/length control beyond sample size
	BEQ @Continue

	LDA ChannelCycle, X
	ORA ChannelEnvelope, X
	STA CurrentTrackEnvelope
	JMP @Continue

@Hill:
	LDA ChannelEnvelope, X
	STA HillLinearLength

@Continue:
	LDY ChannelRawPitch + 16, X
	LDA ChannelRawPitch, X
	STY CurrentTrackRawPitch + 1
	STA CurrentTrackRawPitch

	JSR GeneralHandler
	JSR HandleNoise
	JSR HandleDPCM

	LDA AudioCommandFlags
	AND #1 << SFX_PRIORITY
	BEQ @Next

	TXA ; X = current channel
	AND #1 << SFX_CHANNEL
	BNE @Next

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
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X

@Next:
	TXA
	AND #1 << SFX_CHANNEL
	BNE @SFXChannel

	LDA ChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @SoundChannelOn

@SFXChannel:
	JSR UpdateChannels

@SoundChannelOn:
	LDA #0
	STA ChannelNoteFlags, X

@NextChannel:
	INX
	INC CurrentChannel
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_4
	BCC @Valid
	BNE @NextChannel ; > DPCM means go straight to the next channel

@Valid:
	RTS

; X = current channel, Y = pointer offset, A = pointer data
UpdateChannels:
	TXA
	ASL A
	TAY
	LDA @FunctionPointers, Y
	STA ChannelFunctionPointer
	LDA @FunctionPointers + 1, Y
	STA ChannelFunctionPointer + 1
	JMP (ChannelFunctionPointer)

@FunctionPointers:
	.dw @Pulse1
	.dw @Pulse2
	.dw @Hill
	.dw @Noise
	.dw @DPCM
	.dw @None
	.dw @None
	.dw @None
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
	JMP ClearChannel

@Noise_NoiseSampling:
	PLA
	LDA CurrentTrackEnvelope
	LDY CurrentTrackRawPitch
	STA NOISE_ENV
	STY NOISE_LO
	LDA #0
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
	LDY #CHAN_4 << 2
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
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_PITCH_SLIDE
	BNE @PitchSlide
	JMP @CheckRelativePitch
@PitchSlide:
	LDA ChannelNoteDuration, X
	SBC CurrentNoteDuration
	BPL @PitchSlide_OK
	LDA #1
@PitchSlide_OK:
	STA CurrentNoteDuration
	LDA ChannelRawPitch, X
	LDY ChannelRawPitch + 16, X
	STA RawPitchBackup
	STY RawPitchBackup + 1
	LDA ChannelSlideTarget
	LDY ChannelSlideTarget + 16, X
	STA RawPitchTargetBackup
	STY RawPitchTargetBackup + 1
	SBC ChannelRawPitch, X
	STA PitchSlideDifference
	TAY
	SBC ChannelRawPitch + 16, X
	BPL @PitchSlide_Greater

	LDA ChannelFlagSection3, X
	ORA #1 << SOUND_PITCH_SLIDE_DIR
	STA ChannelFlagSection3, X
	LDA PitchSlideDifference + 1
	EOR #$ff
	STA PitchSlideDifference + 1
	LDA PitchSlideDifference
	EOR #$ff
	ADC #1
	STA PitchSlideDifference
	JMP @PitchSlide_Resume

@PitchSlide_Greater:
	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_PITCH_SLIDE_DIR)
	STA ChannelFlagSection3, X

@PitchSlide_Resume:
	LDY #0

@PitchSlide_Loop:
	; PitchSlideDifference = x' * CurrentNoteDuration + y'
	; x' + 1 -> >PitchSlideDifference
	; y' -> a
	INY
	LDA RawPitchTargetBackup
	SBC CurrentNoteDuration
	STA PitchSlideIncremental
	; borrow is not needed, loop
	BCS @PitchSlide_Loop

	LDA RawPitchTargetBackup + 1
	STA PitchSlideIncremental + 1
	BEQ @PitchSlide_Quit

	DEC PitchSlideIncremental + 1
	JMP @PitchSlide_Loop

@PitchSlide_Quit:
	LDA PitchSlideIncremental
	ADC CurrentNoteDuration
	STY PitchSlideIncremental + 1

	STY ChannelSlideDepth, X
	STA ChannelSlideFraction, Y
	LDA #0
	STA ChannelSlideTempo, X

@CheckRelativePitch:
	PLA
	PHA
	AND #1 << SOUND_RELATIVE_PITCH
	BEQ @CheckEnvelopePattern

	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA ChannelFlagSection3

@CheckEnvelopePattern:
	PLA
	PHA
	AND #1 << SOUND_ENV_PTRN
	BEQ @CheckMuteTimer

	LDA ChannelNoteFlags, X
	AND #$ff ^ (1 << NOTE_ENV_OVERRIDE)
	STA ChannelNoteFlags, X
	LDA #0
	STA ChannelEnvelopeGroupOffset, X

@CheckMuteTimer:
	PLA
	PHA
	AND #1 << SOUND_MUTE
	BNE @MuteTimer
	PLA
	RTS

@MuteTimer:
	PLA
	LDA ChannelMuteMain, X
	STA ChannelMuteCounter, X
	RTS

GeneralHandler:
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_CYCLE_LOOP
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

	LDA ChannelFlagSection3, X
	PHA
	AND #1 << SOUND_REL_PITCH_FLAG

	BEQ @RelativePitch_SetFlag

	PLA
	AND #$ff ^ (1 << SOUND_REL_PITCH_FLAG)
	STA ChannelFlagSection3, X

	AND #1 << SOUND_REST
	BNE @RelativePitch_SetFlag

	LDA ChannelNoteID, X
	ADC ChannelRelativeNoteID, X
	STA ChannelNoteID, X

	LDY ChannelOctave, X
	JSR GetFrequency
	STA CurrentTrackRawPitch
	STY CurrentTrackRawPitch + 1

@RelativePitch_SetFlag:
	PLA
	ORA #1 << SOUND_REL_PITCH_FLAG
	STA ChannelFlagSection3, X

@CheckPitchModifier:
	PLA
	AND #1 << SOUND_PITCH_MODIFIER
	BEQ @CheckPitchInc

	LDA ChannelRawPitch, X
	SBC ChannelPitchModifier + 16, X
	STA ChannelRawPitch, X

	LDA ChannelRawPitch + 16, X
	SBC ChannelPitchModifier, X
	STA ChannelRawPitch + 16, X

@CheckPitchInc:
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_PITCH_INC_SWITCH
	BEQ @CheckVibrato

	LDA ChannelPitchIncrementation, X
	BEQ @CheckVibrato

	LDA ChannelRawPitch, X
	BEQ @CheckVibrato

	DEC ChannelRawPitch + 16, X

@CheckPitchInc_NoCarry:
	DEC ChannelRawPitch, X

@CheckVibrato:
	LDA ChannelFlagSection2, X
	PHA
	AND #1 << SOUND_VIBRATO
	BEQ @CheckEnvelopePattern

	LDA ChannelVibratoCounter, X
	BNE @Vibrato_Subexit2

	LDA ChannelVibratoDepth, X
	BEQ @CheckEnvelopePattern

	STA VibratoBackup

	LDA ChannelVibratoSpeed, X
	AND #$f
	BEQ @Vibrato_Toggle

	DEC ChannelVibratoSpeed, X
	JMP @CheckEnvelopePattern

@Vibrato_Subexit2:
	DEC ChannelVibratoCounter, X
	JMP @CheckEnvelopePattern

@Vibrato_Toggle:
	ASL A
	ASL A
	ASL A
	ASL A
	ORA ChannelVibratoCounter, X
	STA ChannelVibratoCounter, X

	LDA CurrentTrackRawPitch
	TAY

	LDA ChannelFlagSection3, X
	PHA
	AND #1 << SOUND_VIBRATO_DIR
	BEQ @Vibrato_Down

; up
	PLA
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
	STA ChannelFlagSection3, X
	LDA VibratoBackup
	AND #$f
	STA VibratoBackup
	TYA
	SBC VibratoBackup
	BCS @Vibrato_NoBorrow
	LDA #0
	BEQ @Vibrato_NoCarry

@Vibrato_Down:
	PLA
	ORA #1 << SOUND_VIBRATO_DIR
	STA ChannelFlagSection3, X

	LDA VibratoBackup
	AND #$f0
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

	LDA ChannelEnvelopeGroup, X
	ASL A
	TAY
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_2
	BNE @EnvelopePattern_NotHill
	RTS

@EnvelopePattern_NotHill:
	JSR GetByteInEnvelopeGroup
	BCC @EnvelopePattern_Set

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	JMP @CheckMuteTimer

@EnvelopePattern_Set:
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
	LDA ChannelMuteCounter, X
	BEQ @MuteTimer_Enable

	DEC ChannelMuteCounter
	RTS

@MuteTimer_Enable:
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	RTS

ApplyPitchSlide:
	LDA ChannelFlagSection2, X
	AND #1 << SOUND_PITCH_SLIDE
	BNE @Now
	RTS

@Now:
	LDA ChannelRawPitch, X
	LDY ChannelRawPitch + 16, X
	STA RawPitchBackup
	STY RawPitchBackup + 1

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

	LDA ChannelSlideTempo, X
	ADC ChannelSlideFraction, X
	STA ChannelSlideFraction, X

	LDA #0
	ADC ChannelRawPitch, X
	STA ChannelRawPitch, X
	LDA #0
	ADC ChannelRawPitch + 16, X
	STA ChannelRawPitch + 16, X

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
	SEC
	LDA RawPitchBackup
	SBC ChannelSlideDepth, X
	STA ChannelRawPitch, X
	BCS @SlidingUp_NoDec
	DEY
@SlidingUp_NoDec:
	STA ChannelRawPitch + 16, X

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
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_NOISE
	BNE @CheckIfSFX
	RTS

@CheckIfSFX:
	TXA
	AND #1 << SFX_CHANNEL
	BNE @Next

	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_NOISE | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS

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
	LDA DrumAddresses
	ORA DrumAddresses + 1
	BEQ @Quit

	LDA (DrumAddresses)
	INC DrumAddresses
	LDY DrumAddresses

	BNE @SkipCarry1
	INC DrumAddresses + 1

@SkipCarry1:
	CMP #sound_ret_cmd
	BEQ @Quit

	AND #$f
	STA DrumDelay
	INC DrumDelay

	LDA (DrumAddresses)
	INC DrumAddresses
	LDY DrumAddresses

	BEQ @SkipCarry2
	INC DrumAddresses + 1

@SkipCarry2:
	STA CurrentTrackEnvelope
	LDA (DrumAddresses)
	INC DrumAddresses
	LDY DrumAddresses

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
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_DPCM
	BNE @CheckIfSFX
	RTS

@CheckIfSFX:
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_DPCM | 1 << SOUND_CHANNEL_ON
	BEQ @Next
	RTS

@Next:
	LDA DrumChannel
	ORA #$10
	STA DrumChannel

	LDA DrumAddresses + 2
	ORA DrumAddresses + 3
	BEQ @Quit

	LDA (DrumAddresses + 2)
	INC DrumAddresses + 2
	BNE @SkipCarry1

	INC DrumAddresses + 3

@SkipCarry1:
	STA DPCMSampleBank
	ORA #$80    ; ensures bank # points to ROM
	STA Window3 ; c000-dfff address range
	JSR UpdatePRG

	LDA (DrumAddresses + 2)
	INC DrumAddresses + 2
	BNE @SkipCarry2

	INC DrumAddresses + 3

@SkipCarry2:
	AND #$1f
	STA DPCMSamplePitch

	LDA (DrumAddresses + 2)
	INC DrumAddresses + 2
	BEQ @SkipCarry3

	INC DrumAddresses + 3

@SkipCarry3:
	STA DPCMSampleOffset

	LDA (DrumAddresses + 2)
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
	JSR GetMusicByte
	CMP #sound_ret_cmd
	BEQ @SoundRet

	CMP #FIRST_SOUND_COMMAND
	BCC @ReadNote

@ReadCommand:
	JSR ParseMusicCommand
	JMP ParseMusic

@ReadNote:
	LDA ChannelFlagSection1, X
	PHA
	AND #1 << SOUND_SFX | 1 << SOUND_REST
	BEQ @NextCheck
	PLA
	JMP ParseSFXOrRest

@NextCheck:
	PLA
	AND #1 << SOUND_DPCM | 1 << SOUND_NOISE
	BEQ @NormalNote
	JMP GetDrumSample

@NormalNote:
	LDA CurrentMusicByte
	AND #$f
	JSR SetNoteDuration

	LDA CurrentMusicByte
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	BEQ @Rest

	STA ChannelNoteID, X
	LDY ChannelOctave, X
	JSR GetFrequency
	STA CurrentTrackRawPitch
	STY CurrentTrackRawPitch + 1

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X
	JMP LoadNote

@Rest:
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X
	RTS

@SoundRet:
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_SUBROUTINE
	BNE @ReadCommand

	TXA
	CMP #CHAN_8
	BCS @Channel8toC

	LDA ChannelFlagSection1 + (1 << SFX_CHANNEL), X
	AND #1 << SOUND_CHANNEL_ON
	BNE @OK

@Channel8toC:
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_REST
	BEQ @SkipSub
	JSR RestoreVolume

@SkipSub:
	TXA
	CMP #CHAN_8
	BNE @OK

	LDA #0
	STA SQ1_SWEEP

@OK:
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_CHANNEL_ON)
	STA ChannelFlagSection1, X

	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_REST
	STA ChannelNoteFlags, X

	LDA #0
	STA ChannelID, X
	STA ChannelID + 16, X
	STA ChannelBank, X
	RTS

RestoreVolume:
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
	LDA ChannelNoteFlags, X
	ORA #1 << NOTE_NOISE_SAMPLING
	STA ChannelNoteFlags, X

	LDA CurrentMusicByte
	JSR SetNoteDuration ; SFX notes can be longer than 16

	JSR GetMusicByte
	AND #$3f
	STA ChannelEnvelope, X

	JSR GetMusicByte
	STA ChannelRawPitch, X

	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BNE @NotNoise
	RTS

@NotNoise:
	JSR GetMusicByte
	STA ChannelRawPitch + 16, X
	RTS

GetByteInEnvelopeGroup:
	LDA EnvelopeGroups, Y
	STA CurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA CurrentEnvelopeGroupAddress + 1

	LDA ChannelEnvelopeGroupOffset, X
	STA CurrentEnvelopeGroupOffset
	ADC CurrentEnvelopeGroupAddress
	STA CurrentEnvelopeGroupAddress

	LDA #0
	ADC CurrentEnvelopeGroupAddress + 1
	STA CurrentEnvelopeGroupAddress + 1

	LDA (CurrentEnvelopeGroupAddress)
	CMP #$ff
	BEQ @Quit

	CMP #$fe
	BNE @Next

	LDA #0
	STA ChannelEnvelopeGroupOffset, X
	STA CurrentEnvelopeGroupOffset

	LDA EnvelopeGroups, Y
	STA CurrentEnvelopeGroupAddress
	LDA EnvelopeGroups + 1, Y
	STA CurrentEnvelopeGroupAddress + 1
	LDA (CurrentEnvelopeGroupAddress)

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
	LDA MusicDrumSet
	JMP @NextDPCM

@SFXDPCM:
	LDA SFXDrumSet

@NextDPCM:
	ASL A
	TAY
	LDA SampleKits, Y
	STA DrumAddresses + 2
	LDA SampleKits + 1, Y
	STA DrumAddresses + 3
	LDA (DrumAddresses + 2)
	AND #$10
	BNE @DPCMOn
	RTS

@DPCMOn:
	LDA CurrentMusicByte
	AND #$f0
	BNE @NonRestDPCM
	RTS

@NonRestDPCM:
	LSR A
	LSR A
	LSR A
	ADC DrumAddresses + 2
	STA DrumAddresses + 2
	LDA #0
	STA BackupA
	ADC DrumAddresses + 3
	STA DrumAddresses + 3
	RTS

@ContinueNoise:
	LDA MusicDrumSet
	JMP @NextNoise

@SFXNoise:
	LDA SFXDrumSet

@NextNoise:
	ASL A
	TAY
	LDA DrumKits, Y
	STA DrumAddresses
	LDA DrumKits + 1, Y
	STA DrumAddresses + 1

	LDA (DrumAddresses)
	AND #$8
	BNE @NoiseOn
	RTS

@NoiseOn:
	INC DrumAddresses
	LDA CurrentMusicByte
	AND #$f0
	BNE @NonRestNoise
	RTS

@NonRestNoise:
	LSR A
	LSR A
	LSR A
	ADC DrumAddresses
	STA DrumAddresses
	LDA #0
	ADC DrumAddresses + 1
	STA DrumAddresses + 1

	LDA #0
	STA DrumDelay
	RTS

ParseMusicCommand:
	LDA CurrentMusicByte
	SBC #FIRST_SOUND_COMMAND
	ASL A
	TAY
	LDA MusicCommands, Y
	STA CommandPointer
	LDA MusicCommands + 1, Y
	STA CommandPointer + 1
	JMP (CommandPointer)

MusicCommands:
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
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	CMP #CHAN_3
	BNE @Percussion
	RTS

@Percussion:
	LDA AudioCommandFlags
	EOR #1 << FRAME_SWAP
	STA AudioCommandFlags
	RTS

Music_PitchIncSwitch: ; command f1
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_PITCH_INC_SWITCH
	STA ChannelFlagSection1, X
	LDA ChannelPitchIncrementation, X
	EOR #$1
	STA ChannelPitchIncrementation, X
	RTS

Music_SetMusic: ; command f3
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_SFX
	STA ChannelFlagSection1, X
	RTS

Music_Ret: ; command ff
	LDA ChannelBackupAddress1, X
	LDY ChannelBackupAddress1 + 16, X
	STA ChannelAddress, X
	STY ChannelAddress + 16, X
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
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_SUBROUTINE)
	STA ChannelFlagSection1, X
	RTS

Music_Call: ; command fe
	LDA ChannelBackupAddress1, X
	LDY ChannelBackupAddress1 + 16, X
	STA ChannelBackupAddress2, X
	STA ChannelBackupAddress2 + 16, X
	LDA ChannelAddress, X
	LDY ChannelAddress + 16, X
	STA ChannelBackupAddress1, X
	STY ChannelBackupAddress1 + 16, X

	JSR GetMusicByte
	STA ChannelAddress, X
	JSR GetMusicByte
	STA ChannelAddress + 16, X

	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_SUBROUTINE
	STA ChannelFlagSection1, X
	RTS

Music_Jump: ; command fc
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STY ChannelAddress, X
	STA ChannelAddress + 16, X
	RTS

Music_Loop: ; command fd
	JSR GetMusicByte
	LDA ChannelFlagSection1, X
	AND #1 << SOUND_LOOPING
	BNE @CheckLoop

	LDY CurrentMusicByte
	BEQ @Loop

	DEY
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_LOOPING
	STA ChannelFlagSection1, X
	STY ChannelLoopCounter, X

@CheckLoop:
	LDA ChannelLoopCounter, X
	BEQ @EndLoop

	DEC ChannelLoopCounter, X

@Loop:
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STY ChannelAddress, X
	STA ChannelAddress + 16, X
	RTS

@EndLoop:
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_SUBROUTINE)
	STA ChannelFlagSection1, X

	LDA ChannelAddress, X
	ADC #2
	STA ChannelAddress, X
	LDA ChannelAddress + 16, X
	ADC #0
	STA ChannelAddress + 16, X
	RTS

Music_SetCondition: ; command fa
	JSR GetMusicByte
	STA ChannelCondition, X
	RTS

Music_JumpIf: ; command fb
	JSR GetMusicByte
	CMP ChannelCondition, X
	BEQ @Jump

	LDA ChannelAddress, X
	ADC #2
	STA ChannelAddress, X
	LDA ChannelAddress + 16, X
	ADC #0
	STA ChannelAddress + 16, X
	RTS

@Jump:
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STY ChannelAddress, X
	STA ChannelAddress + 16, X
	RTS

Music_JumpRAM: ; command ee
	TXA
	AND #$ff ^ (1 << SFX_CHANNEL)
	TAY
	LDA AudioCommandFlags
	AND @Masks, Y
	BNE @Jump

	INC ChannelAddress, X
	BEQ @Carry
	INC ChannelAddress, X
	BNE @Exit
@Done:
	INC ChannelAddress + 16, X
@Exit:
	RTS

@Carry:
	INC ChannelAddress, X
	BNE @Done

@Jump:
	LDA AudioCommandFlags
	EOR @Masks, Y

	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	STY ChannelAddress, X
	STA ChannelAddress + 16, X
	RTS

@Masks:
	.db 1 << RCOND_PULSE_1    ; $10
	.db 1 << RCOND_PULSE_2    ; $20
	.db 1 << RCOND_HILL       ; $40
	.db 1 << RCOND_NOISE_DPCM ; $80
	.db 1 << RCOND_NOISE_DPCM ; $80 ; Noise and DPCM share a mask

Music_SetSoundEvent:
	LDA AudioCommandFlags
	ORA #1 << SOUND_EVENT
	STA AudioCommandFlags
	RTS

Music_TimeMute:
	JSR GetMusicByte
	STA ChannelMuteMain, X

	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_MUTE
	STA ChannelFlagSection2, X
	RTS

Music_Vibrato:
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_VIBRATO
	STA ChannelFlagSection2, X

	LDA ChannelFlagSection3, X
	AND #$ff ^ (1 << SOUND_VIBRATO_DIR)
	STA ChannelFlagSection3, X

	JSR GetMusicByte
	STA ChannelVibratoPreamble, X
	STA ChannelVibratoCounter, X

	JSR GetMusicByte
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	STA VibratoBackup
	ADC #0
	ASL A
	ASL A
	ASL A
	ASL A
	ORA VibratoBackup
	STA ChannelVibratoDepth, X

	LDA CurrentMusicByte
	AND #$f
	STA VibratoBackup
	ASL A
	ASL A
	ASL A
	ASL A
	ORA VibratoBackup
	STA ChannelVibratoSpeed, X

Music_PitchSlide:
	JSR GetMusicByte
	STA CurrentNoteDuration
	JSR GetMusicByte

	STA BackupA
	AND #$f
	TAY

	LDA BackupA
	AND #$f0
	LSR A
	LSR A
	LSR A
	LSR A
	JSR GetFrequency

	STA ChannelSlideTarget, X
	STY ChannelSlideTarget + 16, X

	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_SLIDE
	STA ChannelFlagSection2, X
	RTS

Music_PitchOffset:
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_PITCH_MODIFIER
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelPitchModifier + 16, X
	JSR GetMusicByte
	STA ChannelPitchModifier, X
	RTS

Music_RelativePitch:
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_RELATIVE_PITCH
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelRelativeNoteID, X
	RTS

Music_CyclePattern:
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_CYCLE_LOOP
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	ROR A
	ROR A
	STA ChannelCyclePattern, X
	AND #$c0
	STA ChannelCycle, X
	RTS

Music_EnvelopePattern:
	LDA ChannelFlagSection2, X
	ORA #1 << SOUND_ENV_PTRN
	STA ChannelFlagSection2, X

	JSR GetMusicByte
	STA ChannelEnvelopeGroup, X
	RTS

Music_ToggleMusic:
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_SFX
	STA ChannelFlagSection1, X
	RTS

Music_ToggleDrum:
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA ChannelFlagSection1, X
	BNE @GetParam
	RTS

@GetParam:
	JSR GetMusicByte
	STA MusicDrumSet, X
	RTS

Music_SFXToggleDrum:
	LDA ChannelFlagSection1, X
	EOR #1 << SOUND_NOISE
	STA ChannelFlagSection1, X
	BNE @GetParam
	RTS

@GetParam:
	JSR GetMusicByte
	STA SFXDrumSet, X
	RTS

Music_PitchSweep:
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

Music_Cycle:
	JSR GetMusicByte
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
	ASL A
	STA ChannelCycle, X
	RTS

Music_NoteType:
	JSR GetMusicByte
	STA ChannelNoteLength, X
	TXA
	AND #4 ; noise / DPCM
	BEQ Music_Envelope
	RTS

Music_Envelope:
	JSR GetMusicByte
	STA ChannelEnvelope, X
	RTS

Music_Tempo:
	JSR GetMusicByte
	TAY
	JSR GetMusicByte
	JMP SetGlobalTempo

Music_Octave:
	LDA CurrentMusicByte
	AND #7
	STA ChannelOctave, X
	RTS

Music_Transpose:
	JSR GetMusicByte
	STA ChannelTransposition, X
	RTS

Music_TempoRelative:
	JSR GetMusicByte
	LDA CurrentMusicByte
	BMI @Minus

	LDY #0
	JMP @OK

@Minus:
	LDY #$ff

@OK:
	ADC ChannelTempo + 16, x
	PHA
	TYA
	ADC ChannelTempo, x
	TAY
	PLA
	JMP SetGlobalTempo

Music_SFXPriorityOn:
	LDA AudioCommandFlags
	ORA #1 << SFX_PRIORITY
	STA AudioCommandFlags
	RTS

Music_SFXPriorityOff:
	LDA AudioCommandFlags
	AND #$ff ^ (1 << SFX_PRIORITY)
	STA AudioCommandFlags
	RTS

Music_RestartChannel:
	LDA ChannelID, X
	LDY ChannelBank, X
	STA MusicID
	STY MusicBank

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

Music_NewSong:
	JSR GetMusicByte
	TAY
	STX BackupX
	JSR _PlayMusic
	LDX BackupX
	RTS

GetMusicByte:
	JSR _LoadMusicByte
	INC ChannelAddress, X
	INC AuxAddresses
	BNE @Quit
	INC ChannelAddress + 16, X
	INC AuxAddresses + 1
@Quit:
	LDY BackupY
	LDA CurrentMusicByte
	RTS

GetFrequency:
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

@Loop
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
	ORA #$8
	TAY
	TXA
	LDX BackupX
	RTS

SetNoteDuration:
	ADC #1 ; a
	STA FactorBuffer ; e
	LDY #0
	STY FactorBuffer + 1 ; d
	LDA ChannelNoteLength, X
	STY FactorBuffer + 2 ; l
	JSR @Multiply
	LDA ChannelTempo, X
	STA FactorBuffer
	LDA ChannelTempo + 16, X
	STA FactorBuffer + 1
	LDA ChannelNoteFlow, X
	STY FactorBuffer + 2
	JSR @Multiply
	LDA FactorBuffer + 2
	LDY FactorBuffer + 3
	STA ChannelNoteFlow, X
	STY ChannelNoteDuration, X
	RTS

@Multiply:
	LDY #0
	STY FactorBuffer + 3 ; h

@Loop:
	ROR A
	BCC @Skip

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

	LDA BackupA
	BNE @Loop

	RTS

SetGlobalTempo:
	STX BackupX
	STA BackupA
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
	LDX BackupX
	LDA BackupA
	RTS

Tempo:
	LDA BackupA
	STY ChannelTempo, X
	STA ChannelTempo + 16, X
	LDA #0
	STA ChannelNoteFlow, X
	RTS

StartChannel:
	LDX BackupX
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_CHANNEL_ON
	STA ChannelFlagSection1, X
	RTS

_PlayMusic:
	JSR MusicOff
	STY MusicID
	LDA MusicBanks, Y
	STA MusicBank
	LDA MusicLo, Y
	LDX MusicHi, Y
	STA AuxAddresses
	STX AuxAddresses + 1
	JSR LoadMusicByte
	AND #$e0
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	ADC #1

@Loop:
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
	STY BackupY
	JSR MusicOff
	LDA ChannelFlagSection1 + CHAN_8
	AND #1 << SOUND_CHANNEL_ON
	BEQ @Ch9

	LDY #CHAN_0 << 2
	JSR ClearChannel
	STA Sweep1

@Ch9:
	LDA ChannelFlagSection1 + CHAN_9
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChA

	LDY #CHAN_1 << 2
	JSR ClearChannel
	STA Sweep2

@ChA:
	LDA ChannelFlagSection1 + CHAN_A
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChB

	LDY #CHAN_2 << 2
	JSR ClearChannel

@ChB:
	LDA ChannelFlagSection1 + CHAN_B
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChC

	LDY #CHAN_3 << 2
	JSR ClearChannel

@ChC:
	LDA ChannelFlagSection1 + CHAN_C
	AND #1 << SOUND_CHANNEL_ON
	BEQ @ChannelsCleared

	LDY #CHAN_4 << 2
	JSR ClearChannel

@ChannelsCleared:
	STY MusicID
	LDA SFXBanks, Y
	STA MusicBank
	LDA SFXLo, Y
	LDX SFXHi, Y
	STA AuxAddresses
	STX AuxAddresses + 1
	JSR LoadMusicByte
	AND #$e0
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	ADC #1

@StartChannels:
	PHA
	JSR LoadChannel
	LDX BackupX
	LDA ChannelFlagSection1, X
	ORA #1 << SOUND_SFX
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
	JSR LoadMusicByte
	INC AuxAddresses
	BNE @NoCarry1
	INC AuxAddresses + 1
@NoCarry1:
	STA BackupA
	LDA CurrentChannel
	AND #$f
	STA CurrentChannel
	TAY
	LDX BackupX
	LDA ChannelFlagSection1, X
	AND #$ff ^ (1 << SOUND_CHANNEL_ON)
	STA ChannelFlagSection1, X

	STY BackupY
	LDA BackupX
@Loop1:
	TAY
	LDA #0
	STA ChannelRAM, Y
	STA ChannelRAM + $100, Y
	STA ChannelRAM + $200, Y
	TYA
	ADC #$10
	BCC @Loop1
	CLC

@Loop2:
	TAY
	LDA #0
	STA ChannelRAM + $300, Y
	TYA
	ADC #$10
	CMP #<ChannelRAMEnd
	BCC @Loop2
	LDA #0
	STA ChannelTempo, X
	ADC #1
	STA ChannelTempo + 1, X
	STA ChannelNoteDuration, X
	JSR LoadMusicByte
	STA ChannelAddress, X
	INC AuxAddresses
	BNE @NoCarry2

	INC AuxAddresses + 1

@NoCarry2:
	JSR LoadMusicByte
	STA ChannelAddress + 16, X
	INC AuxAddresses
	BNE @NoCarry3

	INC AuxAddresses + 1
@NoCarry3:
	LDA MusicID
	STA ChannelID, X
	LDA MusicBank
	STA ChannelBank, X
	RTS

LoadMusicByte:
	JSR _LoadMusicByte
	LDA CurrentMusicByte
	RTS

ClearChannels:
	LDA #0
	STA SND_CHN
	LDY #CHAN_0 << 2
	JSR ClearChannel
	LDY #CHAN_1 << 2
	JSR ClearChannel
	LDY #CHAN_2 << 2
	JSR ClearChannel
	LDY #CHAN_3 << 2
	JSR ClearChannel
	LDY #CHAN_4 << 2

ClearChannel:
	LDA #0
	STA SQ1_ENV, Y
	STA SQ1_SWEEP, Y
	STA SQ1_LO, Y
	STA SQ1_HI, Y
	RTS

.include "sound/notes.asm"
.include "sound/envelope-groups.asm"
.include "sound/noise-kits.asm"
.include "sound/sample-kits.asm"
.include "sound/music-pointers.asm"
.include "sound/sfx-pointers.asm"
.include "music/none.asm"
