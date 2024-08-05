;
; The entire sound engine, entry is located in HomeROM
;
StartProcessingSoundQueue:
	LDA #$FF
	STA rFRC

	JSR ProcessFanfare ; fanfares / multichannel sfx
	JSR ProcessPulse2SFX
	JSR ProcessNoiseQueue
	JSR ProcessDPCMQueue
	JSR ProcessMusicQueue

	; Reset queues- aaaand it's done!
	LDA #$00
	STA zPulse2SFX
	STA zNoiseDrumSFX
	STA zDPCMSFX
	STA zMusicQueue
	STA zFanfare
	RTS

ProcessFanfare:
	LDA zFanfare
	BNE ProcessFanfare_Part2
	LDA zCurrentFanfare
	BNE ProcessFanfare_Part3
ProcessFanfare_Exit:
	RTS

ProcessFanfare_Part2:
	STA zCurrentFanfare
	LDA #0
	LDY #zFanfareAreaEnd - zFanfareArea
ProcessFanfare_Part2Loop1:
	DEY
	STA zFanfareArea, Y
	BNE ProcessFanfare_Part2Loop1
	STA iFanfare_Sub
	STA iFanfare_Sub + 1
	STA iFanfare_Sub + 2
	STA iFanfare_Sub + 3
	STA iFanfare_Sub + 4
	LDA zFanfare
	SEC
	SBC #SFX_FANFARES_START
	ASL A
	TAY
	; header pointer
	LDA FanfareHeaderPointers, Y
	STA zAuxAddresses + 4
	LDA FanfareHeaderPointers + 1, Y
	STA zAuxAddresses + 5
	; tempo
	LDY #0
	LDA (zAuxAddresses + 4), Y
	STA zFanfareTempo
	; channel count
	INY
	LDA (zAuxAddresses + 4), Y
	TAX
	DEX
ProcessFanfare_Part2Loop2:
	INC zFanfare_duration, X
	DEX
	BPL ProcessFanfare_Part2Loop2
	LDA (zAuxAddresses + 4), Y
	ASL A
	TAX
	TYA
	SEC
	ADC zAuxAddresses + 4
	STA zAuxAddresses + 4
	LDA #0
	ADC zAuxAddresses + 5
	STA zAuxAddresses + 5
	TXA
	TAY
	DEY
ProcessFanfare_Part2Loop3:
	LDA (zAuxAddresses + 4), Y
	STA zFanfarePointers, Y
	DEY
	BPL ProcessFanfare_Part2Loop3

ProcessFanfare_Part3:
ProcessFanfare_Square2:
	CLC
	DEC zFanfare_length
	BNE +
	LDA #10
	STA rNR20
	LDA #0
	STA rNR21
	STA rNR22
	STA rNR23
+
	DEC zFanfare_duration
	BNE ProcessFanfare_Square2End

	LDY zFanfare_offset
	JSR ProcessFanfare_Square2Bytes
	STY zFanfare_offset

ProcessFanfare_Square2End:
	BCS ProcessFanfare_End
	LDA zFanfarePointerSQ1
	ORA zFanfarePointerSQ1 + 1
	BNE ProcessFanfare_Square1
	RTS

ProcessFanfare_End:
	LDA #10
	STA rNR10
	STA rNR20
	LDA #0
	STA rNR11
	STA rNR12
	STA rNR13
	STA rNR21
	STA rNR22
	STA rNR23
	LDX zFanfarePointerHill + 1
	BEQ ProcessFanfare_EndNoHill
	STA rNR30
	STA rNR32
	STA rNR33
ProcessFanfare_EndNoHill:
	STA zCurrentFanfare
	STA zFanfare
	LDY #zFanfareAreaEnd - zFanfareArea
ProcessFanfare_EndLoop:
	DEY
	STA zFanfareArea, Y
	BNE ProcessFanfare_EndLoop
	STA iFanfare_Sub
	STA iFanfare_Sub + 1
	STA iFanfare_Sub + 2
	STA iFanfare_Sub + 3
	STA iFanfare_Sub + 4
	RTS

ProcessFanfare_Square1:
	DEC zFanfare_length + 1
	BNE +
	LDA #10
	STA rNR10
	LDA #0
	STA rNR11
	STA rNR12
	STA rNR13
+
	DEC zFanfare_duration + 1
	BNE ProcessFanfare_Square1End

	LDY zFanfare_offset + 1
	JSR ProcessFanfare_Square1Bytes
	STY zFanfare_offset + 1

ProcessFanfare_Square1End:
	LDA zFanfarePointerHill
	ORA zFanfarePointerHill + 1
	BNE ProcessFanfare_Hill
	RTS

ProcessFanfare_Hill:
	DEC zFanfare_duration + 2
	BNE ProcessFanfare_HillEnd

	LDY zFanfare_offset + 2
	JSR ProcessFanfare_HillBytes
	STY zFanfare_offset + 2

ProcessFanfare_HillEnd:
	LDA zFanfarePointerNoise
	ORA zFanfarePointerNoise + 1
	BNE ProcessFanfare_Noise
	RTS

ProcessFanfare_Noise:
	DEC zFanfare_duration + 3
	BNE ProcessFanfare_NoiseEnd

	LDY zFanfare_offset + 3
	JSR ProcessFanfare_NoiseBytes
	STY zFanfare_offset + 3

ProcessFanfare_NoiseEnd:
	LDA zFanfarePointerDPCM
	ORA zFanfarePointerDPCM + 1
	BNE ProcessFanfare_DPCM
	RTS

ProcessFanfare_DPCM:
	DEC zFanfare_duration + 4
	BNE ProcessFanfare_DPCMEnd

	LDY zFanfare_offset + 4
	JSR ProcessFanfare_DPCMBytes
	STY zFanfare_offset + 4

ProcessFanfare_DPCMEnd:
	RTS

ProcessFanfare_Square2Bytes:
; 80-df, f0-ff	instrument, duration
; e0-ef		length
; 7e		rest
; 02-7c		note
; 00		stop
	LDA (zFanfarePointerSQ2), Y
	BMI @InstrumentOrLength
	BEQ @Quit
	INY
	STY zFanfare_offset
	LDY zFanfare_instrument
	STY rNR20
	LDX #4
	JSR PlayNote
	BNE @Note
	LDY #$10
	STY rNR20
@Note:
	LDX #$7F
	STX rNR21
	LDX iFanfare_DurationID
	JSR CalculateFanfareTempo
	STA iFanfare_Remainder
	STX zFanfare_duration
	LDY zFanfare_offset
	LDA iFanfare_Remainder
	CLC
	ADC iFanfare_Sub
	STA iFanfare_Sub
	LDA zFanfare_duration
	ADC #0
	STA zFanfare_duration
	LDA iFanfare_LengthPoints
	STA zFanfare_length
	CLC
	RTS
@Quit:
	INY
	SEC
	RTS

@InstrumentOrLength:
	INY
	TAX
	AND #$f0
	CMP #$e0
	BEQ @Length
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$7
	STY zFanfare_offset
	TAY
	LDA FanfareInstruments, Y
	STA zFanfare_instrument
	TXA
	AND #$0f
	STA iFanfare_DurationID
	LDY zFanfare_offset
	JMP ProcessFanfare_Square2Bytes
@Length:
	TXA
	AND #$0f
	STA iFanfare_LengthPoints
	BNE @NonZero
	DEC iFanfare_LengthPoints
@NonZero:
	JMP ProcessFanfare_Square2Bytes

ProcessFanfare_Square1Bytes:
; 80-df, f0-ff	instrument, duration
; e0-ef		length
; 7e		rest
; 02-7c		note
	LDA (zFanfarePointerSQ1), Y
	BMI @InstrumentOrLength
	BEQ @Quit
	STY zFanfare_offset + 1
	LDY zFanfare_instrument + 1
	STY rNR10
	LDX #0
	JSR PlayNote
	BNE @Note
	LDY #$10
	STY rNR10
@Note:
	LDX iFanfare_DurationID + 1
	JSR CalculateFanfareTempo
	STA iFanfare_Remainder + 1
	STX zFanfare_duration + 1
	LDY zFanfare_offset + 1
	LDA iFanfare_Remainder + 1
	CLC
	ADC iFanfare_Sub + 1
	STA iFanfare_Sub + 1
	LDA zFanfare_duration + 1
	ADC #0
	STA zFanfare_duration + 1
	LDA iFanfare_LengthPoints + 1
	STA zFanfare_length + 1
@Quit:
	INY
	RTS

@InstrumentOrLength:
	INY
	TAX
	AND #$f0
	CMP #$e0
	BEQ @Length
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$7
	STY zFanfare_offset + 1
	TAY
	LDA FanfareInstruments, Y
	STA zFanfare_instrument + 1
	TXA
	AND #$0f
	STA iFanfare_DurationID + 1
	LDY zFanfare_offset + 1
	JMP ProcessFanfare_Square1Bytes
@Length:
	TXA
	AND #$0f
	STA iFanfare_LengthPoints + 1
	BNE @NonZero
	DEC iFanfare_LengthPoints + 1
@NonZero:
	JMP ProcessFanfare_Square1Bytes

FanfareInstruments:
	.db $08
	.db $8f
	.db $8a
	.db $4f
	.db $4a
	.db $75
	.db $75
	.db $b5

ProcessFanfare_HillBytes:
; 80-df, f0-ff	duration
; e0-ef		length
; 7e		rest
; 02-7c		note
	LDA (zFanfarePointerHill), Y
	BMI @InstrumentOrLength
	BEQ @Quit
	STY zFanfare_offset + 2
	LDY zFanfare_length + 2
	STY rNR30
	LDX #8
	JSR PlayNote
	BNE @Note
	LDY #0
	STY rNR30
@Note:
	LDX iFanfare_DurationID + 2
	JSR CalculateFanfareTempo
	STA iFanfare_Remainder + 2
	STX zFanfare_duration + 2
	LDY zFanfare_offset + 2
	LDA iFanfare_Remainder + 2
	CLC
	ADC iFanfare_Sub + 2
	STA iFanfare_Sub + 2
	LDA zFanfare_duration + 2
	ADC #0
	STA zFanfare_duration + 2
@Quit:
	INY
	RTS

@InstrumentOrLength:
	INY
	TAX
	AND #$f0
	CMP #$e0
	BEQ @Length
	TXA
	AND #$0f
	STA iFanfare_DurationID + 2
	JMP ProcessFanfare_HillBytes
@Length:
	TXA
	AND #$0f
	ASL A
	ASL A
	BNE @NonZero
	LDA #$81
@NonZero:
	STA zFanfare_length + 2
	JMP ProcessFanfare_HillBytes

ProcessFanfare_NoiseBytes:
; 80-ff	duration
; 01	rest
; 02-7e	note
	LDA (zFanfarePointerNoise), Y
	BMI @InstrumentOrLength
	BEQ @Quit
	TAX
	DEX
	BEQ @Rest
	LSR A
	STA zNoiseDrumSFX
@Rest:
	LDX iFanfare_DurationID + 3
	JSR CalculateFanfareTempo
	STA iFanfare_Remainder + 3
	STX zFanfare_duration + 3
	LDA iFanfare_Remainder + 3
	CLC
	ADC iFanfare_Sub + 3
	STA iFanfare_Sub + 3
	LDA zFanfare_duration + 3
	ADC #0
	STA zFanfare_duration + 3
@Quit:
	INY
	RTS

@InstrumentOrLength:
	INY
	AND #$0f
	STA iFanfare_DurationID + 3
	JMP ProcessFanfare_NoiseBytes

ProcessFanfare_DPCMBytes:
; 80-ff	duration
; 01	rest
; 02-7e	note
	LDA (zFanfarePointerDPCM), Y
	BMI @InstrumentOrLength
	BEQ @Quit
	TAX
	DEX
	BEQ @Rest
	LSR A
	STA zDPCMSFX
@Rest:
	LDX iFanfare_DurationID + 4
	JSR CalculateFanfareTempo
	STA iFanfare_Remainder + 4
	STX zFanfare_duration + 4
	LDA iFanfare_Remainder + 4
	CLC
	ADC iFanfare_Sub + 4
	STA iFanfare_Sub + 4
	LDA zFanfare_duration + 4
	ADC #0
	STA zFanfare_duration + 4
@Quit:
	INY
	RTS

@InstrumentOrLength:
	INY
	AND #$0f
	STA iFanfare_DurationID + 4
	JMP ProcessFanfare_DPCMBytes

CalculateFanfareTempo:
	LDA NoteLengthMultipliers, X
	STA MMC5_Multiplier1
	LDA zFanfareTempo
	STA MMC5_Multiplier2
	LDA MMC5_Multiplier1
	LDX MMC5_Multiplier2
	RTS

ProcessPulse2SFX:
	LDA zPulse2SFX
	BNE ProcessPulse2SFX_Part2
	LDA zCurrentPulse2SFX
	BNE ProcessPulse2SFX_Part3
ProcessPulse2SFX_Exit:
	RTS

ProcessPulse2SFX_Part2:
	STA zCurrentPulse2SFX
	LDY #0
	STY iPulse2SFXOffset
	STY iPulse2SFXSweep
	SEC
	SBC #SFX_PULSE_2_SOUNDS_START
	TAY

ProcessPulse2SFX_DesignatePointer:
	LDA Pulse2SFXVolumes, Y
	STA iPulse2SFXVolume
	LDA Pulse2SFXEnvelopes, Y
	STA iPulse2SFXVolume + 1
	LDA Pulse2SFXPointersLO, Y
	STA zPulse1IndexPointer
	LDA Pulse2SFXPointersHI, Y
	STA zPulse1IndexPointer + 1

ProcessPulse2SFX_Part3:
	LDY iPulse2SFXOffset
	LDA (zPulse1IndexPointer), Y
	BEQ ProcessPulse2SFX_End
	BPL ProcessPulse2SFX_Note

	INY
	STA iPulse2SFXSweep
	LDA (zPulse1IndexPointer), Y

ProcessPulse2SFX_Note:
	INY
	CMP #$40
	BCS ProcessPulse2SFX_Tie
	CMP #$08
	LDX #$10
	BCC ProcessPulse2SFX_Volume
	LDX iPulse2SFXVolume
ProcessPulse2SFX_Volume:
	STX rNR20
	TAX
	LDA (zPulse1IndexPointer), Y
	INY
	STA rNR22
	STX rNR23
	CPX #$08
	BCC ProcessPulse2SFX_Tie
	LDA iPulse2SFXSweep
	STA rNR21
	LDA iPulse2SFXVolume + 1
	STA rNR20
ProcessPulse2SFX_Tie:
	STY iPulse2SFXOffset
	RTS

ProcessPulse2SFX_End:
	STA zCurrentPulse2SFX
	STA iPulse2SFXSweep
	STA zPulse1IndexPointer
	STA zPulse1IndexPointer + 1
	STA iPulse2SFXOffset
	LDA #$10
	STX rNR20
	LDA #0
	STA rNR22
	STA rNR23
	STA rNR21
	RTS

Pulse2SFXVolumes:
	.db $9f, $9f, $10, $10, $10

Pulse2SFXEnvelopes:
	.db $80, $81, $10, $10, $10

;
; Noise Channel SFX / Percussion Queue
;
ProcessNoiseQueue:
	LDA zNoiseDrumSFX
	BEQ ProcessNoiseQueue_None

	LDX #0
	STX zNoiseSFXOffset
	BEQ ProcessNoiseQueue_Part2

ProcessNoiseQueue_None:
	LDX zCurrentNoiseSFX
	BNE ProcessNoiseQueue_Part3
	LDX zCurrentDrum
	BNE ProcessNoiseQueue_Part3
	RTS

ProcessNoiseQueue_Part2:
	; start a new sound effect
	CMP #NOISE_SFX
	BCS ProcessNoiseQueue_NotPercussion

	STA zCurrentDrum
	LDY #0
	STY zCurrentNoiseSFX
	BCC ProcessNoiseQueue_PointerOffset

ProcessNoiseQueue_NotPercussion:
	STA zCurrentNoiseSFX
	LDY #0
	STY zCurrentDrum

ProcessNoiseQueue_PointerOffset:
	TAY
	DEY
	; load pointer for us to access
	LDA NoiseSFXPointersLo, Y
	STA zNoiseIndexPointer
	LDA NoiseSFXPointersHi, Y
	STA zNoiseIndexPointer + 1

ProcessNoiseQueue_Part3:
	; load offset and increment it
	LDY zNoiseSFXOffset
	INC zNoiseSFXOffset
	; examine data
	LDA (zNoiseIndexPointer), Y
	; 00 = ret
	BEQ ProcessNoiseQueue_Done
	; 7e = rest
	CMP #$7e
	BEQ ProcessNoiseQueue_Exit
	; 10-7f = patch
	AND #$70
	BNE ProcessNoiseQueue_Patch
	; 00-0f / 80-8f = note
	BEQ ProcessNoiseQueue_Note

ProcessNoiseQueue_Done:
	; if it was $00, we're at the end of the data for this sound effect
	LDX #$90
	STX rNR40
	LDX #$18
	STX rNR43
	LDX #$00
	STX rNR42
	STX zCurrentNoiseSFX
	STX zCurrentDrum
	RTS

ProcessNoiseQueue_Patch:
	; apply patch
	LDA (zNoiseIndexPointer), Y
	STA rNR40
	LDY zNoiseSFXOffset
	INC zNoiseSFXOffset

ProcessNoiseQueue_Note:
	; apply note
	LDA (zNoiseIndexPointer), Y
	CMP #$7E
	BEQ ProcessNoiseQueue_Exit
	STA rNR42
	LDA #$08
	STA rNR43

ProcessNoiseQueue_Exit:
	RTS

;
; DPCM Channel SFX / Percussion Queue
;
ProcessDPCMQueue:
	LDA zDPCMSFX
	BNE ProcessDPCMQueue_Part2

	LDA zCurrentDPCMSFX
	BEQ ProcessDPCMQueue_None

	LDA rMIX
	AND #$10
	BNE ProcessDPCMQueue_Exit

	LDA #$00
	STA zCurrentDPCMSFX
	LDA #%00001111
	STA rMIX

ProcessDPCMQueue_None:
ProcessDPCMQueue_Exit:
	RTS

ProcessDPCMQueue_Part2:
	STA zCurrentDPCMSFX
	TAY
	DEY

	LDA DMCBankTable, Y
IFNDEF NSF_FILE
	STA MMC5_PRGBankSwitch4
ELSE
	ASL A
	STA NSF_PRGBank4
	ORA #1
	STA NSF_PRGBank5
ENDIF

	LDA DMCPitchTable, Y
	STA rNR50

	LDA DMCStartTable, Y
	STA rNR52
	LDA DMCLengthTable, Y
	STA rNR53
	LDA #%00001111
	STA rMIX
	LDA #%00011111
	STA rMIX
	RTS

; Music handling:
; This routine runs last during the sound update before clearing the sound
; queue.  Responsible for most BGM.
ProcessMusicQueue_ThenReadNoteData:
	JMP ProcessMusicQueue_ReadNoteData

ProcessMusicQueue_StopMusic:
	JMP StopMusic

ProcessMusicQueue:
	; is the music flag even on?
	LDY zOptions
	BPL ProcessMusicQueue_StopMusic
	; yes
	; start by checking for no music
	LDY zMusicQueue
	TYA
	INY
	BEQ ProcessMusicQueue_StopMusic

	; if zMusicQueue != 0, branch
	LDA zMusicQueue
	BNE ProcessMusicQueue_MusicQueue1

	; if any music is playing, advance by one frame
	; else return
	LDA zCurrentMusic
	BNE ProcessMusicQueue_ThenReadNoteData
	RTS

ProcessMusicQueue_MusicQueue1:
	; zMusicQueue != 0, initialize
	; save previous song in case of permission
	LDA zCurrentMusic
	STA zMusicStack
	JSR StopMusic
	LDY zMusicQueue
	STY zCurrentMusic
	; does current song permit the previous one to play afterward?
	LDA MusicStackPermission, Y
	BNE ProcessMusicQueue_ReadFirstPointer

	; MusicStackPermission+Y = 0, clear the queue stack
	LDA #MUSIC_NONE
	STA zMusicStack

ProcessMusicQueue_ReadFirstPointer:
	; set music bank
	DEY
	LDA SongBanks, Y
IFNDEF NSF_FILE
	STA zMusicBank
	STA MMC5_PRGBankSwitch3
ELSE
	JSR SetMusicBank
ENDIF
	; store the amount of channels
	LDA MusicChannelStack, Y
	STA zMusicChannelCount
	; starting point
	LDA MusicPointersFirstPart, Y
	STA iMusicStartPoint
	; ending point
	LDA MusicPointersEndPart, Y
	CLC
	ADC #$02
	STA iMusicEndPoint
	; loop point
	LDA MusicPointersLoopPart, Y
	STA iMusicLoopPoint
	; store the beginning offset
	LDA iMusicStartPoint

ProcessMusicQueue_SetCurrentPart:
	STA zCurrentMusicOffset

ProcessMusicQueue_SetNextPart:
	; Y = music offset + 1, check if we reached the end
	INC zCurrentMusicOffset
	LDY zCurrentMusicOffset
	CPY iMusicEndPoint
	BNE ProcessMusicQueue_ReadHeader

	; reset offset to loop point if we reached the end
	LDA iMusicLoopPoint
	BNE ProcessMusicQueue_SetCurrentPart

	; we're here if there's no loop, stop the music
	JMP StopMusic

ProcessMusicQueue_ReadHeader:
	; nab offset, X = channel amount 3-5
	LDX zMusicChannelCount
	LDA MusicPartPointers - 1, Y
	TAY
	; header data
	; byte 1 - base note length
	LDA MusicHeaders, Y
	STA zTempo
	; byte 2-3 - music pointer, pulse 2
	LDA MusicHeaders + 1, Y
	STA zCurrentMusicPointer
	STA iMusicPulse2BigPointer + 1
	LDA MusicHeaders + 2, Y
	STA zCurrentMusicPointer + 1
	STA iMusicPulse2BigPointer
	DEX
	; byte 5 - pulse 1 offset
	LDA MusicHeaders + 4, Y
	CLC
	ADC iMusicPulse2BigPointer + 1
	STA iMusicPulse1BigPointer + 1
	LDA #0
	ADC iMusicPulse2BigPointer
	STA iMusicPulse1BigPointer
	DEX
	; byte 4 - hill offset
	LDA MusicHeaders + 3, Y
	CLC
	ADC iMusicPulse1BigPointer + 1
	STA iMusicHillBigPointer + 1
	LDA #0
	ADC iMusicPulse1BigPointer
	STA iMusicHillBigPointer
	DEX
	BNE ProcessMusicQueue_ReadHeaderNoise

	LDA #0
	STA iMusicNoiseBigPointer + 1
	STA iMusicNoiseBigPointer
	STA iMusicDPCMBigPointer + 1
	STA iMusicDPCMBigPointer
	BEQ ProcessMusicQueue_DefaultNotelength

ProcessMusicQueue_ReadHeaderNoise:
	; byte 6 - noise offset
	LDA MusicHeaders + 5, Y
	CLC
	ADC iMusicHillBigPointer + 1
	STA iMusicNoiseBigPointer + 1
	LDA #0
	ADC iMusicHillBigPointer
	STA iMusicNoiseBigPointer
	DEX
	BNE ProcessMusicQueue_ReadHeaderDPCM

	LDA #0
	STA iMusicDPCMBigPointer + 1
	STA iMusicDPCMBigPointer
	BEQ ProcessMusicQueue_DefaultNotelength

ProcessMusicQueue_ReadHeaderDPCM:
	; byte 7 - DPCM
	LDA MusicHeaders + 6, Y
	CLC
	ADC iMusicNoiseBigPointer + 1
	STA iMusicDPCMBigPointer + 1
	LDA #0
	ADC iMusicNoiseBigPointer
	STA iMusicDPCMBigPointer

ProcessMusicQueue_DefaultNotelength:
	LDA #$01
	STA iMusicPulse2NoteLength
	STA iMusicPulse1NoteLength
	STA iMusicHillNoteLength
	STA iMusicNoiseNoteLength
	STA iMusicDPCMNoteLength
	STA zDPCMNoteRatioLength

	; initialize offsets / accumulators
	LDA #$00
	STA zCurrentDrum
	STA iCurrentPulse2Offset
	STA iCurrentHillOffset
	STA iCurrentPulse1Offset
	STA iCurrentNoiseOffset
	STA iCurrentDPCMOffset
; Fixed-point note accumulators only needed initialization in SMB2:ASSA
; VulpReich's bankswitching structure allows it to opt out of initialization
;	STA zMusicPulse2FPNA
;	STA zMusicPulse1FPNA
;	STA zMusicHillFPNA
;	STA zMusicNoiseFPNA
;	STA zMusicDPCMFPNA
	STA zSweep

ProcessMusicQueue_ReadNoteData:
	; check note length
	; if 0, start a new note
	; else, skip to updating
	DEC iMusicPulse2NoteLength
	BEQ ProcessMusicQueue_Square2EndOfNote
	JMP ProcessMusicQueue_Square2SustainNote

ProcessMusicQueue_Square2EndOfNote:
	LDA iMusicPulse2BigPointer
	STA zCurrentMusicPointer + 1
	LDA iMusicPulse2BigPointer + 1
	STA zCurrentMusicPointer
	; new note, read next byte
	LDY iCurrentPulse2Offset
	INC iCurrentPulse2Offset
	LDA (zCurrentMusicPointer), Y
	; 0 = ret
	; + = note
	; - = instrument / note length
	BEQ ProcessMusicQueue_EndOfSegment

	BMI ProcessMusicQueue_Square2Patch
	JMP ProcessMusicQueue_Square2Note

ProcessMusicQueue_EndOfSegment:
; 0 = ret
	; check which song's playing
	; zCurrentMusic always loops
	LDY zCurrentMusic
	LDA MusicStackPermission, Y
	BEQ ProcessMusicQueue_ThenSetNextPart

	; non-zero value, song meets permission, replay last song
	LDA zMusicStack
	BEQ StopMusic

	; zMusicStack != 0
	STA zMusicQueue
	JMP ProcessMusicQueue_MusicQueue1

StopMusic:
; This routine runs when:
;	zOptions is positive
;	zMusicQueue = $ff
;	Song is initializing
;	Song ends without a loop
;	zMusicStack = 0
	LDA #$00
	STA zCurrentMusic
	LDA zFanfarePointerSQ1 + 1
	BNE ClearChannelPulse2

	STA rNR13
	STA rNR12
	STA rNR11
	LDA #$10
	STA rNR10

ClearChannelPulse2:
	LDA zCurrentPulse2SFX
	ORA zFanfarePointerSQ2 + 1
	BNE ClearChannelHill

	STA rNR23
	STA rNR22
	STA rNR21
	LDA #$10
	STA rNR20

ClearChannelHill:
	LDA zFanfarePointerHill + 1
	BNE ClearChannelNoise

	STA rNR30
	STA rNR33
	STA rNR32

ClearChannelNoise:
	LDA zCurrentNoiseSFX
	ORA zFanfarePointerNoise + 1
	BNE ClearChannelDPCM
	STA zCurrentDrum
	STA rNR43
	STA rNR42
	LDA #$10
	STA rNR40

ClearChannelDPCM:
	LDA zCurrentDPCMSFX
	ORA zFanfarePointerDPCM + 1
	BNE ClearChannelDone
	JMP ProcessMusicQueue_DPCMDisable

ClearChannelDone:
	RTS

ProcessMusicQueue_ThenSetNextPart:
; any song able to move their pointer offset
	JMP ProcessMusicQueue_SetNextPart

ProcessMusicQueue_Square2Patch:
; - = instrument / note length
	; instrument
	TAX
	AND #$F0
	STA zPulse2Ins
	; note length
	TXA
	JSR ProcessMusicQueue_PatchNoteLength

	STA iPulse2NoteLength
	STY iMusicPulse2NoteSubFrames

	; next byte, allows higher notes
	LDY iCurrentPulse2Offset
	INC iCurrentPulse2Offset
	LDA (zCurrentMusicPointer), Y

ProcessMusicQueue_Square2Note:
; + = note
	LDX zCurrentFanfare
	BNE ProcessMusicQueue_Square2ContinueNote
	LDX zCurrentPulse2SFX
	BNE ProcessMusicQueue_Square2ContinueNote

	; We're clear! Play the note!
	LDX #$04
	JSR PlayNote
	TAY
	BEQ ProcessMusicQueue_Square2UpdateNoteOffset

	LDA iPulse2NoteLength
	JSR SetInstrumentStartOffset

ProcessMusicQueue_Square2UpdateNoteOffset:
	; set instruemnt offset, init sweep/gain
	STA iMusicPulse2InstrumentOffset

; Sets volume/sweep on Square 2 channel
;
; Input
;   X = duty/volume/envelope
;   Y = sweep
	STX rNR20
	STY rNR21

ProcessMusicQueue_Square2ContinueNote:
	; set note length
	LDA iMusicPulse2NoteSubFrames
	CLC
	ADC zMusicPulse2FPNA
	STA zMusicPulse2FPNA
	LDA iPulse2NoteLength
	ADC #0
	STA iMusicPulse2NoteLength

ProcessMusicQueue_Square2SustainNote:
	; note update
	; SFX playing?  If yes, skip to updating Pulse 1
	LDX zCurrentFanfare
	BNE ProcessMusicQueue_Square1
	LDX zCurrentPulse2SFX
	BNE ProcessMusicQueue_Square1

ProcessMusicQueue_LoadSquare2InstrumentOffset:
	; load isntrument offset
	LDY iMusicPulse2InstrumentOffset
	BEQ ProcessMusicQueue_LoadSquare2Instrument

	DEC iMusicPulse2InstrumentOffset

ProcessMusicQueue_LoadSquare2Instrument:
	; load instrument no.
	LDA iPulse2NoteLength
	LDX zPulse2Ins
	JSR LoadSquareInstrumentDVE

	; update
	STA rNR20
	LDX #$7F
	STX rNR21

ProcessMusicQueue_Square1:
; if note length != 0, sustain note
	DEC iMusicPulse1NoteLength
	BNE ProcessMusicQueue_Square1SustainNote

; else we start here instead
; load byte offset / data
	LDA iMusicPulse1BigPointer
	STA zCurrentMusicPointer + 1
	LDA iMusicPulse1BigPointer + 1
	STA zCurrentMusicPointer
ProcessMusicQueue_Square1Patch:
	; 0 - set sweep to $94
	; - - instrument / note length
	; + - note
	LDY iCurrentPulse1Offset
	INC iCurrentPulse1Offset
	LDA (zCurrentMusicPointer), Y
	BPL ProcessMusicQueue_Square1AfterPatch

	; - - instrument / note length
	; instrument
	TAX
	AND #$F0
	STA zPulse1Ins
	; note length
	TXA
	JSR ProcessMusicQueue_PatchNoteLength

	STA iPulse1NoteLength
	STY iMusicPulse1NoteSubFrames

	; next byte, allows higher notes
	LDY iCurrentPulse1Offset
	INC iCurrentPulse1Offset
	LDA (zCurrentMusicPointer), Y

ProcessMusicQueue_Square1AfterPatch:
; + = note
	TAY
	BNE ProcessMusicQueue_Square1Note

	LDA zSweep
	BEQ ProcessMusicQueue_HandleSweep

	LDA #0
	STA zSweep
	BEQ ProcessMusicQueue_Square1Patch

ProcessMusicQueue_HandleSweep:
	; 0 - set sweep to $8C
	LDA #$89
	STA zSweep
	BNE ProcessMusicQueue_Square1Patch

ProcessMusicQueue_Square1Note:
	LDX zCurrentFanfare
	BNE ProcessMusicQueue_Square1ContinueNote
	; We're clear! Play the note!
	JSR PlaySquare1Note

	BEQ ProcessMusicQueue_Square1UpdateNoteOffset
	LDA iPulse1NoteLength
	JSR SetInstrumentStartOffset

ProcessMusicQueue_Square1UpdateNoteOffset:
	; set instruemnt offset, init sweep/gain
	STA iMusicPulse1InstrumentOffset
; Sets volume/sweep on Square 1 channel
; Input
;   X = duty/volume/envelope
;   Y = sweep
	STY rNR11
	STX rNR10
ProcessMusicQueue_Square1ContinueNote:
	; set note length
	LDA iMusicPulse1NoteSubFrames
	CLC
	ADC zMusicPulse1FPNA
	STA zMusicPulse1FPNA
	LDA iPulse1NoteLength
	ADC #0
	STA iMusicPulse1NoteLength

ProcessMusicQueue_Square1SustainNote:
	LDX zCurrentFanfare
	BNE ProcessMusicQueue_Hill
	; note update
	; load isntrument offset
	LDY iMusicPulse1InstrumentOffset
	BEQ ProcessMusicQueue_Square1AfterDecrementInstrumentOffset

	DEC iMusicPulse1InstrumentOffset

ProcessMusicQueue_Square1AfterDecrementInstrumentOffset:
	; load instrument no.
	LDA iPulse1NoteLength
	LDX zPulse1Ins
	JSR LoadSquareInstrumentDVE

	; update
	STA rNR10
	LDA zSweep
	BNE ProcessMusicQueue_Square1Sweep

	LDA #$7F

ProcessMusicQueue_Square1Sweep:
	STA rNR11

ProcessMusicQueue_Hill:
	; if offset = 0, skip to next channel

	LDA iMusicHillBigPointer
	ORA iMusicHillBigPointer + 1
	BNE ProcessMusicQueue_HillStart
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_HillStart:
	LDA iMusicHillBigPointer
	STA zCurrentMusicPointer + 1
	LDA iMusicHillBigPointer + 1
	STA zCurrentMusicPointer

	; if note length doesn't reach 0, skip to next channel
	DEC iMusicHillNoteLength
	BEQ ProcessMusicQueue_HillByte
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_HillByte:
	; next byte
	; 0 = loop
	; + = note length
	; - = note
	LDY iCurrentHillOffset
	INC iCurrentHillOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_HillLoopSegment

	BPL ProcessMusicQueue_HillNote

	; - = note length
	; instrument
	TAX
	AND #$F0
	STA zHillIns

ProcessMusicQueue_HillNoteLength:
	; note length
	TXA
	JSR ProcessMusicQueue_PatchNoteLength

	STA iHillNoteLength
	STY iMusicHillNoteSubFrames
	LDA #$1F
	STA rNR30

	; next byte is treated like a note, or mute
	LDY iCurrentHillOffset
	INC iCurrentHillOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_HillSetLength

ProcessMusicQueue_HillNote:
	LDX zFanfarePointerHill + 1
	BNE ProcessMusicQueue_HillCnotinueNote
	; - = note
	LDX #$08
	JSR PlayNote
ProcessMusicQueue_HillCnotinueNote:
	; iMusicHillNoteLength:
	LDA iMusicHillNoteSubFrames
	CLC
	ADC zMusicHillFPNA
	STA zMusicHillFPNA
	LDA iHillNoteLength
	ADC #0
	STA iMusicHillNoteLength
	BMI ProcessMusicQueue_HillMax

	TAY
	CPY #$38
	BCS ProcessMusicQueue_HillMax

	LDX zHillIns
	CPX #$F0
	BCS ProcessMusicQueue_HillMax
	CPX #$A0
	LDA Hill15Outta16Lengths, Y
	BCC ProcessMusicQueue_HillSetLength
	CPX #$B0
	LDA Hill5Outta7Lengths, Y
	BCC ProcessMusicQueue_HillSetLength
	LDA Hill4Outta7Lengths, Y
	BCS ProcessMusicQueue_HillSetLength

ProcessMusicQueue_HillMax:
	LDA #$7F

ProcessMusicQueue_HillSetLength:
	LDX zFanfarePointerHill + 1
	BNE ProcessMusicQueue_Noise

	STA rNR30
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_HillLoopSegment:
	STA iCurrentHillOffset
	JMP ProcessMusicQueue_HillByte

ProcessMusicQueue_Noise:
	; if offset = 0, skip to next channel
	LDA iMusicNoiseBigPointer
	BEQ ProcessMusicQueue_ThenNoiseEnd
	STA zCurrentMusicPointer + 1
	LDA iMusicNoiseBigPointer + 1
	STA zCurrentMusicPointer

	; if note length doesn't reach 0, skip to next channel
	DEC iMusicNoiseNoteLength
	BNE ProcessMusicQueue_ThenNoiseEnd

ProcessMusicQueue_NoiseByte:
; next byte
	; 0 = loop
	; - = note length
	; + = note
	LDY iCurrentNoiseOffset
	INC iCurrentNoiseOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_NoiseLoopSegment

	BPL ProcessMusicQueue_NoiseNote

	; - = note length
	JSR ProcessMusicQueue_PatchNoteLength

	STA iNoiseNoteLength
	STY iMusicNoiseNoteSubFrames
	; next byte - later entries allowed
	LDY iCurrentNoiseOffset
	INC iCurrentNoiseOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_NoiseLoopSegment

ProcessMusicQueue_NoiseNote:
; + = note
; NOTE - only $02-$10 are valid
; $32 - $38 are treated as sound effects
; $01 is a rest note
	LDY zFanfarePointerNoise + 1
	BNE ProcessMusicQueue_NoiseLengthCarry
	LDY zCurrentNoiseSFX
	BNE ProcessMusicQueue_NoiseLengthCarry
	LSR A
	BEQ ProcessMusicQueue_NoiseLengthCarry

	STA zNoiseDrumSFX
	JSR ProcessNoiseQueue

ProcessMusicQueue_NoiseLengthCarry:
	LDA iMusicNoiseNoteSubFrames
	CLC
	ADC zMusicNoiseFPNA
	STA zMusicNoiseFPNA
	LDA iNoiseNoteLength
	ADC #0
	STA iMusicNoiseNoteLength

ProcessMusicQueue_ThenNoiseEnd:
	JMP ProcessMusicQueue_DPCM

ProcessMusicQueue_NoiseLoopSegment:
; 0 = loop
	STA iCurrentNoiseOffset
	JMP ProcessMusicQueue_NoiseByte

ProcessMusicQueue_DPCM:
	; if offset = 0, end
	LDA iMusicDPCMBigPointer
	BNE ProcessMusicQueue_DPCMlength
	JMP ProcessMusicQueue_DPCMEnd

ProcessMusicQueue_DPCMlength:
	STA zCurrentMusicPointer + 1
	LDA iMusicDPCMBigPointer + 1
	STA zCurrentMusicPointer
	; if note length reaches 0, read sample music data
	DEC iMusicDPCMNoteLength
	BEQ ProcessMusicQueue_DPCMByte
	; note cuts off in advance
	LDA zDPCMNoteRatioLength
	BEQ ProcessMusicQueue_DPCMExit11
	DEC zDPCMNoteRatioLength
	BNE ProcessMusicQueue_DPCMExit11

	; if note length ratio remains non-zero, check for sound effects
	LDA zFanfarePointerDPCM + 1
	BNE ProcessMusicQueue_DPCMExit11
	LDA zCurrentDPCMSFX
	BNE ProcessMusicQueue_DPCMExit11
	; Disable - no sound effects playing
	LDX #%00001111
	STX rMIX
	LDX #0
	STX rNR50
	STX rNR52
	STX rNR53
ProcessMusicQueue_DPCMExit11:
	RTS

ProcessMusicQueue_DPCMByte:
; next byte
	; 0 = loop
	; - = note length
	; + = note
	LDY iCurrentDPCMOffset
	INC iCurrentDPCMOffset
	LDA (zCurrentMusicPointer), Y
	BNE ProcessMusicQueue_DPCMNotLoop
	JMP ProcessMusicQueue_DPCMLoopSegment

ProcessMusicQueue_DPCMNotLoop:
	BPL ProcessMusicQueue_DPCMNote

	; - = note length
	JSR ProcessMusicQueue_PatchNoteLength

	; next byte - later entries allowed
	STA iDPCMNoteLength
	STY iMusicDPCMNoteSubFrames

	LDY iCurrentDPCMOffset
	INC iCurrentDPCMOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_DPCMLoopSegment

ProcessMusicQueue_DPCMNote:
; check for sound effects before playing a note
	LDX zFanfarePointerDPCM + 1
	BNE ProcessMusicQueue_DPCMSFXExit
	LDX zCurrentDPCMSFX
	BNE ProcessMusicQueue_DPCMSFXExit

	LSR A
	TAY
	; get octave bank
	LDA DPCMSampleBanks, Y
IFNDEF NSF_FILE
	STA MMC5_PRGBankSwitch4
ELSE
	SEC
	SBC #$f2 - PRG_DPCM0
	ASL A
	STA NSF_PRGBank4
	ORA #1
	STA NSF_PRGBank5
ENDIF
	; pitch
	LDA DMCSamplePitchTable, Y
	STA rNR50
	; address
	LDA DMCSamplePointers, Y
	STA rNR52
	; length
	LDA DMCSampleLengths, Y
	STA rNR53

	; mixer
	LDX #%00001111
	STX rMIX
	LDA #%00011111
	STA rMIX

ProcessMusicQueue_DPCMSFXExit:
	LDA iMusicDPCMNoteSubFrames
	CLC
	ADC zMusicDPCMFPNA
	STA zMusicDPCMFPNA
	LDA iDPCMNoteLength
	ADC #0
	STA iMusicDPCMNoteLength
	LDX #$F0 ; pitch lasts 15 / 16 frames rounded down
	STA MMC5_Multiplier1
	STX MMC5_Multiplier2
	LDA MMC5_Multiplier2
	STA zDPCMNoteRatioLength
	RTS

ProcessMusicQueue_DPCMEnd:
	; check for sound effects before disabling
	LDX zCurrentDPCMSFX
	BNE ProcessMusicQueue_DPCMExit2

ProcessMusicQueue_DPCMDisable:
	; Disable
	LDX #%00001111
	STX rMIX
	LDX #0
	STX rNR50
	STX rNR52
	STX rNR53
ProcessMusicQueue_DPCMExit2:
	RTS

ProcessMusicQueue_DPCMLoopSegment:
	; 0 = Loop
	STA iCurrentDPCMOffset
	JMP ProcessMusicQueue_DPCMByte


; DPCM sawtooth configuration data
.include "src/sound/dpcm-table-data.asm"

; Input
;   A = full patch byte
; Output
;   A = new note length
ProcessMusicQueue_PatchNoteLength:
	AND #$0F
	TAY
	LDA NoteLengthMultipliers, Y
	LDY zTempo
	STY MMC5_Multiplier1
	STA MMC5_Multiplier2
	LDA MMC5_Multiplier1
	TAY
	LDA MMC5_Multiplier2
	RTS

; Input
;   A = note start length, >= $13 for table A, < $13 for instrument table B
; Ouput
;   A = starting instrument offset ($16 for short, $3F for long)
;   X = duty/volume/envelope ($82)
;   Y = sweep ($7F)
;
SetInstrumentStartOffset:
	CMP #$13
	BCC SetInstrumentStartOffset_Short
	LDA #$3F
	BNE SetInstrumentStartOffset_Exit
SetInstrumentStartOffset_Short:
	LDA #$16
SetInstrumentStartOffset_Exit:
	LDX #$82
	LDY #$7F
	RTS

;
; Loads instrument data for a square channel
;
; Each instrument has two lookup tables based on the note length.
;
; Input
;   A = note length, >= $13 for table A, < $13 for instrument table B
;   X = instrument patch
;   Y = instrument offset
; Output
;   A = duty/volume/envelope
;
LoadSquareInstrumentDVE:
	CPX #$90
	BEQ LoadSquareInstrumentDVE_90_E0

	CPX #$E0
	BEQ LoadSquareInstrumentDVE_90_E0

	CPX #$A0
	BEQ LoadSquareInstrumentDVE_A0

	CPX #$B0
	BEQ LoadSquareInstrumentDVE_B0

	CPX #$C0
	BEQ LoadSquareInstrumentDVE_C0

	CPX #$D0
	BEQ LoadSquareInstrumentDVE_D0

	CPX #$F0
	BEQ LoadSquareInstrumentDVE_F0

LoadSquareInstrumentDVE_80:
	CMP #$13
	BCC LoadSquareInstrumentDVE_80_Short
	LDA InstrumentDVE_80, Y
	BNE LoadSquareInstrumentDVE_80_Exit
LoadSquareInstrumentDVE_80_Short:
	LDA InstrumentDVE_80_Short, Y
LoadSquareInstrumentDVE_80_Exit:
	RTS

LoadSquareInstrumentDVE_90_E0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_90_E0_Short
	LDA InstrumentDVE_90_E0, Y
	BNE LoadSquareInstrumentDVE_90_E0_Exit
LoadSquareInstrumentDVE_90_E0_Short:
	LDA InstrumentDVE_90_E0_Short, Y
LoadSquareInstrumentDVE_90_E0_Exit:
	RTS

LoadSquareInstrumentDVE_A0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_A0_Short
	LDA InstrumentDVE_A0, Y
	BNE LoadSquareInstrumentDVE_A0_Exit
LoadSquareInstrumentDVE_A0_Short:
	LDA InstrumentDVE_A0_Short, Y
LoadSquareInstrumentDVE_A0_Exit:
	RTS

LoadSquareInstrumentDVE_B0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_B0_Short
	LDA InstrumentDVE_B0, Y
	BNE LoadSquareInstrumentDVE_B0_Exit
LoadSquareInstrumentDVE_B0_Short:
	LDA InstrumentDVE_B0_Short, Y
LoadSquareInstrumentDVE_B0_Exit:
	RTS

LoadSquareInstrumentDVE_C0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_C0_Short
	LDA InstrumentDVE_C0, Y
	BNE LoadSquareInstrumentDVE_C0_Exit
LoadSquareInstrumentDVE_C0_Short:
	LDA InstrumentDVE_C0_Short, Y
LoadSquareInstrumentDVE_C0_Exit:
	RTS

LoadSquareInstrumentDVE_F0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_F0_Short
	LDA InstrumentDVE_F0, Y
	BNE LoadSquareInstrumentDVE_F0_Exit
LoadSquareInstrumentDVE_F0_Short:
	LDA InstrumentDVE_F0_Short, Y
LoadSquareInstrumentDVE_F0_Exit:
	RTS

LoadSquareInstrumentDVE_D0:
	CMP #$13
	BCC LoadSquareInstrumentDVE_D0_Short
	LDA InstrumentDVE_D0, Y
	BNE LoadSquareInstrumentDVE_D0_Exit
LoadSquareInstrumentDVE_D0_Short:
	LDA InstrumentDVE_D0_Short, Y
LoadSquareInstrumentDVE_D0_Exit:
	RTS

; Play a note on the Square 1 channel
;
; Input
;   A = note
PlaySquare1Note:
	LDX #0

; Plays a note
;
; Input
;   A = note
;   X = channel
;       $00: square 1
;       $04: square 2
;       $08: hill
;       $0C: noise
; Output
;   A = $00 for rest, hi frequency otherwise
PlayNote:
	CMP #$7E
	BNE PlayNote_NotRest

	CPX #$08
	LDA #$00
	BCS PlayNote_HillRest

	LDA #$10

PlayNote_HillRest:
	STA rNR10, X
	LDA #$00
	RTS

PlayNote_NotRest:
	LDY #$01
	STY zOctave
	TAY
	BMI PlayNote_LoadFrequencyData

	SEC

PlayNote_IncrementOctave:
	INC zOctave
	SBC #$18
	BCS PlayNote_IncrementOctave

PlayNote_LoadFrequencyData:
	CLC
	ADC #$18
	TAY
	LDA NoteFrequencyData, Y
	STA zNextPitch
	LDA NoteFrequencyData + 1, Y
	STA zNextPitch + 1

PlayNote_FrequencyOctaveLoop:
	LSR zNextPitch + 1
	ROR zNextPitch
	DEC zOctave
	BNE PlayNote_FrequencyOctaveLoop

	LDA zNextPitch
	BEQ PlayNote_SetFrequency

	; tweak the frequency
	; leave channel 1 if both 1 & 2 ins are $80
	LDA zPulse1Ins
	ORA zPulse2Ins
	AND #$70
	BNE PlayNote_NotSameFirstIns

	TXA
	BEQ PlayNote_SetFrequency

PlayNote_NotSameFirstIns:
	DEC zNextPitch

PlayNote_SetFrequency:
	LDA zNextPitch
	STA rNR12, X
	LDA zNextPitch + 1
	ORA #$08
	STA rNR13, X
	RTS

SongBanks:
	audio_bank PRG_Music0
	audio_bank PRG_Music0

MusicStackPermission:
	.db $FF
	.db $00
	.db $00
