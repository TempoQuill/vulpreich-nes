
; section: AUDIO RAM (zero page)

; duty cycle, length flag, volume ramp flag, ramp length/volume
AudioZPRAM:
CurrentTrackEnvelope:
	.dsb 1 ; 0000
CurrentTrackSweep:
	.dsb 1
; also includes note length
CurrentTrackRawPitch:
	.dsb 2
CurrentTrackLength:
	.dsb 1 ; 0004
CurrentNoteDuration:
	.dsb 1
CurrentMusicByte:
	.dsb 1
CurrentChannel:
	.dsb 1

; linear length + flag
HillLinearLength:
	.dsb 1 ; 0008
; 0 = off
; 1 = on
; 0-1: Pulses 2: Hill 3: Noise 4: DPCM
Mixer:
	.dsb 1
Sweep1:
	.dsb 1
Sweep2:
	.dsb 1
MusicID:
	.dsb 2 ; 000c
MusicBank:
	.dsb 1
BCDNumber:
	.dsb 1

DrumAddresses:
	.dsb 4 ; 0010
DrumChannel:
	.dsb 1 ; 0014
DrumDelay:
	.dsb 1
MusicDrumSet:
	.dsb 1
SFXDrumSet:
	.dsb 1

DPCMSamplePitch:
	.dsb 1 ; 0018
DPCMSampleOffset:
	.dsb 1
DPCMSampleLength:
	.dsb 1
DPCMSampleBank:
	.dsb 1
; 0: Sound event 1: SFX Priority 2: MusicPlaying 3: frame swap 4-7: RAM Conditions
AudioCommandFlags:
	.dsb 1 ; 001c
SFXDuration:
	.dsb 1
CurrentSFX:
	.dsb 2

ChannelFunctionPointer:
	.dsb 2 ; 0020
CommandPointer:
	.dsb 2
RawPitchBackup:
	.dsb 2 ; 0024
RawPitchTargetBackup:
	.dsb 2

PitchSlideDifference:
	.dsb 2 ; 0028
PitchSlideIncremental:
	.dsb 2
VibratoBackup:
	.dsb 1 ; 002c
CurrentEnvelopeGroupOffset:
	.dsb 1
CurrentEnvelopeGroupAddress:
	.dsb 2
ZPAudioEnd:

; section: Hardware Assistive RAM
; backup registers, banks, addresses, and buffers

BackupA:
	.dsb 1 ; 0030
BackupX:
	.dsb 1
BackupY:
	.dsb 1
RAMBank: ; MMC5 backups, also it's the zero page equivalent!
	.dsb 1
Window1:
	.dsb 1 ; 0034
Window2:
	.dsb 1
Window3:
	.dsb 1
Window4:
	.dsb 1

AuxAddresses: ; back up 4 at a time
; 0: audio
; 1: updates
; 2: vblank
; 3: everything else
	.dsb 8 ; 0038

FactorBuffer:
	.dsb 4 ; 0040
DividerBuffer:
	.dsb 4 ; 0044
AddendBuffer:
	.dsb 4 ; 0048
DifferentialBuffer:
	.dsb 4 ; 004c

InputBottleNeck:
	.dsb 2 ; 0050
InputCurrentState:
	.dsb 2
ScreenUpdateIndex:
	.dsb 1 ; 0054
GlobalFrameCounter:
	.dsb 1
BackgroundXOffset:
	.dsb 1
BackgroundYOffset:
	.dsb 1
DrawBackgroundAttributesPPUBigAddr:
	.dsb 2 ; 0058
	.dsb 2
PPUScrollYMirror:
	.dsb 1 ; 005c
PPUScrollXMirror:
	.dsb 1
PPUMaskMirror:
	.dsb 1
PPUCtrlMirror:
	.dsb 1
CHRWindow0:
	.dsb 1 ; 0060
CHRWindow1:
	.dsb 1
CurrentCardBalance:
	.dsb 3
CurrentPrice:
	.dsb 3
CurrentCardBalanceBCD:
	.dsb 7 ; 0068
	.dsb 1
	.dsb 16
DecimalPlaceBuffer:
	.dsb $20 ; 0080
	.dsb $60 ; 00a0

; section: STACK
Stack:
StackBottom:
	.dsb $100
StackTop:

; section: AUDIO RAM (channels) 0200 - 050f
; each entry is spread across 16 bytes
; xx0 pulse 1 xx1 pulse 2 xx2 hill xx3 noise xx4 DPCM
; xx8 pulse 1 xx9 pulse 2 xxa hill xxb noise xxc DPCM
ChannelRAM:
ChannelID:
	.dsb 16 ; 0200
ChannelBank:
	.dsb 16
ChannelFlagSection1:
	.dsb 16
ChannelFlagSection2:
	.dsb 16
ChannelFlagSection3:
	.dsb 16 ; 0240
ChannelAddress:
	.dsb 32
ChannelBackupAddress1:
	.dsb 32
ChannelBackupAddress2:
	.dsb 32
ChannelNoteFlags:
	.dsb 16
ChannelCondition:
	.dsb 16 ; 02c0
ChannelCycle:
	.dsb 16
ChannelEnvelope:
	.dsb 16
ChannelRawPitch:
	.dsb 32
ChannelNoteID:
	.dsb 16
ChannelOctave:
	.dsb 16
ChannelTransposition:
	.dsb 16
ChannelNoteDuration:
	.dsb 16 ; 0340
ChannelNoteFlow:
	.dsb 16
ChannelPitchIncrementation:
	.dsb 16
ChannelLoopCounter:
	.dsb 16
ChannelTempo:
	.dsb 32 ; 0380
; bit arr. 0/1: Pulse 2: Hill 3: Noise 4: DPCM 5-7: never used
ChannelTrackID:
	.dsb 16
ChannelCyclePattern:
	.dsb 16
ChannelVibratoCounter:
	.dsb 16 ; 03c0
ChannelVibratoPreamble:
	.dsb 16
ChannelVibratoDepth:
	.dsb 16
ChannelVibratoTimer:
	.dsb 16
ChannelSlideTarget:
	.dsb 32 ; 0400
ChannelSlideDepth:
	.dsb 16
ChannelSlideFraction:
	.dsb 16
ChannelSlideTempo:
	.dsb 16 ; 0440
ChannelMuteCounter:
	.dsb 16
ChannelPitchModifier:
	.dsb 32
ChannelRelativeNoteID:
	.dsb 16 ; 0480
ChannelEnvelopeGroup:
	.dsb 16
ChannelEnvelopeGroupOffset:
	.dsb 16
ChannelMuteMain:
	.dsb 16
ChannelNoteLength:
	.dsb 16 ; 04c0
ChannelTempoOffset:
	.dsb 16
ChannelBCDPreamble:
	.dsb 16
ChannelBCDCounter:
	.dsb 32 ; 0500
ChannelRAMEnd:
HorizontalScrollingPPUAttributeUpdateBuffer:
	.dsb $42 ; 0510 - 0551
VerticalScrollingPPUAttributeUpdateBuffer:
	.dsb $42 ; 0552 - 0593
	.dsb $6c ; 0594 - 05ff
PPUBuffer:
	.dsb $80 ; 0600 - 067f
ScrollingPPUTileUpdateBuffer:
	.dsb $80 ; 0680 - 06ff
OAM:
	.dsb $100 ; 0700 - 07ff
