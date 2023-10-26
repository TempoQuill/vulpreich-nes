;
; The entire sound engine, entry is located in HomeROM
;
StartProcessingSoundQueue:
	LDA #$FF
	STA rFRC

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
	TAY
	DEY

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
	LDA rMIX
	ORA #$0F
	STA rMIX
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
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $9f, $9f, $00

Pulse2SFXEnvelopes:
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $80, $81, $00

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
	LDA rMIX
	ORA #$0F
	STA rMIX

ProcessNoiseQueue_Exit:
	RTS

;
; DPCM Channel SFX / Percussion Queue
;
ProcessDPCMQueue:
	LDA zDPCMSFX
	BNE ProcessDPCMQueue_Part2

	LDA zCurrentDPCMSFX
	BNE ProcessDPCMQueue_SoundCheck

	LDA iCurrentDPCMOffset
	BEQ ProcessDPCMQueue_None
	RTS

ProcessDPCMQueue_SoundCheck:
	LDA rMIX
	AND #$10
	BNE ProcessDPCMQueue_Exit

ProcessDPCMQueue_None:
	LDA #$00
	STA zCurrentDPCMSFX
	LDA #%00001111
	STA rMIX

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

ProcessMusicQueue_ThenReadNoteData:
	JMP ProcessMusicQueue_ReadNoteData

ProcessMusicQueue_StopMusic:
	JMP StopMusic

ProcessMusicQueue:
	LDY zOptions
	BPL ProcessMusicQueue_StopMusic

	; start by checking for no music
	LDY zMusicQueue
	TYA
	INY
	BEQ ProcessMusicQueue_StopMusic

	; if zMusicQueue != 0, branch
	LDA zMusicQueue
	BNE ProcessMusicQueue_MusicQueue1

	; if any music is playing, read note data
	; else return
	LDA iCurrentMusic
	BNE ProcessMusicQueue_ThenReadNoteData
	RTS

ProcessMusicQueue_MusicQueue1:
	; zMusicQueue != 0, initialize
	LDA iCurrentMusic
	STA zMusicStack
	JSR StopMusic
	LDY zMusicQueue
	STY iCurrentMusic
	LDA MusicStackPermission, Y
	BNE ProcessMusicQueue_ReadFirstPointer

	LDA #MUSIC_NONE
	STA zMusicStack

ProcessMusicQueue_ReadFirstPointer:
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
	STA iCurrentMusicOffset

ProcessMusicQueue_SetNextPart:
	; Y = music offset + 1, check if we reached the end
	INC iCurrentMusicOffset
	LDY iCurrentMusicOffset
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

	; initialize offsets / fractions
	LDA #$00
	STA zCurrentDrum
	STA iCurrentPulse2Offset
	STA iCurrentHillOffset
	STA iCurrentPulse1Offset
	STA iCurrentNoiseOffset
	STA iCurrentDPCMOffset
	STA zMusicPulse2NoteLengthFraction
	STA zMusicPulse1NoteLengthFraction
	STA zMusicHillNoteLengthFraction
	STA zMusicNoiseNoteLengthFraction
	STA zMusicDPCMNoteLengthFraction
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
	; iCurrentMusic always loops
	LDY iCurrentMusic
	LDA MusicStackPermission, Y
	BEQ ProcessMusicQueue_ThenSetNextPart

	; non-zero value, song meets permission, replay last song
	LDA zMusicStack
	BEQ StopMusic

	; zMusicStack != 0
	STA zMusicQueue
	JMP ProcessMusicQueue_MusicQueue1

StopMusic:
; ways to access this routine:
;	zMusicStack = 0, fallthrough
;	iCurrentMusic does not meet logic when fanfare ends
;	Reaching the end-offset without a loop
;	zMusicQueue is $80
;	initializing the sound engine for a new song
	LDA #$10
	STA rNR10
	LDA #$00
	STA iCurrentMusic
	STA rNR13
	STA rNR12
	STA rNR11

	LDX zCurrentPulse2SFX
	BNE ClearChannelTriangle

	LDA #$10
	STA rNR20
	LDA #$00
	STA rNR23
	STA rNR22
	STA rNR21

ClearChannelTriangle:
	STA rNR30
	STA rNR33
	STA rNR32

ClearChannelNoise:
	LDA zCurrentNoiseSFX
	BNE ClearChannelDPCM
	STA zCurrentDrum
	STA rNR43
	STA rNR42
	LDA #$10
	STA rNR40

ClearChannelDPCM:
	LDA zCurrentDPCMSFX
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
	ADC zMusicPulse2NoteLengthFraction
	STA zMusicPulse2NoteLengthFraction
	LDA iPulse2NoteLength
	ADC #0
	STA iMusicPulse2NoteLength

ProcessMusicQueue_Square2SustainNote:
	; note update
	; SFX playing?  If yes, skip to updating Pulse 1
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
	; set note length
	LDA iMusicPulse1NoteSubFrames
	CLC
	ADC zMusicPulse1NoteLengthFraction
	STA zMusicPulse1NoteLengthFraction
	LDA iPulse1NoteLength
	ADC #0
	STA iMusicPulse1NoteLength

ProcessMusicQueue_Square1SustainNote:
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

ProcessMusicQueue_Triangle:
	; if offset = 0, skip to next channel

	LDA iMusicHillBigPointer
	ORA iMusicHillBigPointer + 1
	BNE ProcessMusicQueue_TriangleStart
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_TriangleStart:
	LDA iMusicHillBigPointer
	STA zCurrentMusicPointer + 1
	LDA iMusicHillBigPointer + 1
	STA zCurrentMusicPointer

	; if note length doesn't reach 0, skip to next channel
	DEC iMusicHillNoteLength
	BEQ ProcessMusicQueue_TriangleByte
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_TriangleByte:
	; next byte
	; 0 = loop
	; + = note length
	; - = note
	LDY iCurrentHillOffset
	INC iCurrentHillOffset
	LDA (zCurrentMusicPointer), Y
	BEQ ProcessMusicQueue_TriangleLoopSegment

	BPL ProcessMusicQueue_TriangleNote

	; - = note length
	; instrument
	TAX
	AND #$F0
	STA zHillIns

ProcessMusicQueue_TriangleNoteLength:
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
	BEQ ProcessMusicQueue_TriangleSetLength

ProcessMusicQueue_TriangleNote:
	; - = note
	LDX #$08
	JSR PlayNote
	; iMusicHillNoteLength:
	LDA iMusicHillNoteSubFrames
	CLC
	ADC zMusicHillNoteLengthFraction
	STA zMusicHillNoteLengthFraction
	LDA iHillNoteLength
	ADC #0
	STA iMusicHillNoteLength
	BMI ProcessMusicQueue_TriangleMax

	TAY
	CPY #$38
	BCS ProcessMusicQueue_TriangleMax

	LDA zHillIns
	CMP #$F0
	BCS ProcessMusicQueue_TriangleMax
	CMP #$B0
	LDA Triangle15Outta16Lengths, Y
	BCC ProcessMusicQueue_TriangleSetLength
	LDA Triangle4Outta7Lengths, Y
	BCS ProcessMusicQueue_TriangleSetLength

ProcessMusicQueue_TriangleMax:
	LDA #$7F

ProcessMusicQueue_TriangleSetLength:
	STA rNR30
	JMP ProcessMusicQueue_Noise

ProcessMusicQueue_TriangleLoopSegment:
	STA iCurrentHillOffset
	JMP ProcessMusicQueue_TriangleByte

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
	LDY zCurrentNoiseSFX
	BNE ProcessMusicQueue_NoiseLengthCarry
	LSR A
	BEQ ProcessMusicQueue_NoiseLengthCarry

	STA zNoiseDrumSFX
	JSR ProcessNoiseQueue

ProcessMusicQueue_NoiseLengthCarry:
	LDA iMusicNoiseNoteSubFrames
	CLC
	ADC zMusicNoiseNoteLengthFraction
	STA zMusicNoiseNoteLengthFraction
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
	ADC zMusicDPCMNoteLengthFraction
	STA zMusicDPCMNoteLengthFraction
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
	LDX #zCurrentDPCMSFX
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
;       $08: triangle
;       $0C: noise
; Output
;   A = $00 for rest, hi frequency otherwise
PlayNote:
	CMP #$7E
	BNE PlayNote_NotRest

	CPX #$08
	LDA #$00
	BCS PlayNote_TriangleRest

	LDA #$10

PlayNote_TriangleRest:
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

	; tweak the frequency
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
