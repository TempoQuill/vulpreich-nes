
; section: AUDIO RAM (zero page)

; duty cycle, length flag, volume ramp flag, ramp length/volume
zAudioRAM:
zCurrentTrackEnvelope:
	.dsb 1 ; 0000
; also includes note length
zCurrentTrackRawPitch:
	.dsb 2
zCurrentNoteDuration:
	.dsb 1
zCurrentMusicByte:
	.dsb 1 ; 0004
zCurrentChannel:
	.dsb 1

; linear length + flag
zHillLinearLength:
	.dsb 1
; 0 = off
; 1 = on
; 0-1: Pulses 2: Hill 3: Noise 4: DPCM
zMixer:
	.dsb 1
zSweep1:
	.dsb 1 ; 0008
zSweep2:
	.dsb 1
zMusicID:
	.dsb 1
zMusicBank:
	.dsb 1

zDrumAddresses:
	.dsb 4 ; 000c
zDrumChannel:
	.dsb 1 ; 0010
zDrumDelay:
	.dsb 1
zMusicDrumSet:
	.dsb 1
zSFXDrumSet:
	.dsb 1

zDPCMSamplePitch:
	.dsb 1 ; 0014
zDPCMSampleOffset:
	.dsb 1
zDPCMSampleLength:
	.dsb 1
zDPCMSampleBank:
	.dsb 1
; 0: Sound event 1: SFX Priority 2: MusicPlaying 3: frame swap 4-7: RAM Conditions
zAudioCommandFlags:
	.dsb 1 ; 0018
zCurrentSFX:
	.dsb 1

zChannelFunctionPointer:
	.dsb 2
zAudioCommandPointer:
	.dsb 2 ; 001c
zRawPitchBackup:
	.dsb 2
; unused, stored but never read
zRawPitchTargetBackup:
	.dsb 2 ; 0020

zPitchSlideDifference:
	.dsb 2
zVibratoBackup:
	.dsb 1 ; 0024
zCurrentEnvelopeGroupOffset:
	.dsb 1
zCurrentEnvelopeGroupAddress:
	.dsb 2
zAudioRAMEnd:
; section: miscellaneous
zSaveFileExists:
	.dsb 1 ; 0028
zTextBank:
	.dsb 1
zCurrentTextByte:
	.dsb 1
zNMIState:
	.dsb 1
zCHRWindow0:
	.dsb 1 ; 002c
zCHRWindow1:
	.dsb 1
zTableOffset:
	.dsb 2

; section: Hardware Assistive RAM
; backup registers, banks, addresses, and buffers

zBackupA:
	.dsb 1 ; 0030
zBackupX:
	.dsb 1
zBackupY:
	.dsb 1
zRAMBank: ; MMC5 backups, also it's the zero page equivalent!
	.dsb 1
zWindow1:
	.dsb 1 ; 0034
zWindow2:
	.dsb 1
zWindow3:
	.dsb 1
zWindow4:
	.dsb 1

zAuxAddresses: ; back up 4 at a time
; 0: audio
; 1: updates / text
; 2: vblank
; 3: everything else
	.dsb 8 ; 0038

zFactorBuffer:
	.dsb 4 ; 0040
zDividerBuffer:
	.dsb 4 ; 0044
zAddendBuffer:
	.dsb 4 ; 0048
zDifferentialBuffer:
	.dsb 4 ; 004c

zInputBottleNeck:
	.dsb 2 ; 0050
zInputCurrentState:
	.dsb 2
zPPUCtrlMirror:
	.dsb 1 ; 0054
zPPUMaskMirror:
	.dsb 1
zPPUStatusMirror:
	.dsb 1
	.dsb 1
zPaletteIndex:
	.dsb 8 ; 0058
zPPUScrollXMirror:
	.dsb 1 ; 0060
zPPUScrollYMirror:
	.dsb 1
zStringXOffset:
	.dsb 1
zCurrentCardBalance:
	.dsb 3
zCurrentPrice:
	.dsb 3
zCurrentCardBalanceBCD:
	.dsb 7
zDecimalPlaceBuffer:
	.dsb 16 ; 0070
zStringBuffer:
	.dsb $20 ; 0080
	.dsb $20 ; 00a0
	.dsb $20 ; 00c0
	.dsb $20 ; 00e0

; section: STACK
iStack:
iStackBottom:
	.dsb $100
iStackTop:

; section: AUDIO RAM (channels) 0200 - 04bf
; each entry is spread across 16 bytes
; xx0 pulse 1 xx1 pulse 2 xx2 hill xx3 noise xx4 DPCM
; xx8 pulse 1 xx9 pulse 2 xxa hill xxb noise xxc DPCM
iChannelRAM:
iChannelID:
	.dsb 16 ; 0200
iChannelBank:
	.dsb 16
iChannelFlagSection1:
	.dsb 16
iChannelFlagSection2:
	.dsb 16
iChannelFlagSection3:
	.dsb 16 ; 0240
iChannelAddress:
	.dsb 32
iChannelBackupAddress1:
	.dsb 32
iChannelBackupAddress2:
	.dsb 32
iChannelNoteFlags:
	.dsb 16
iChannelCondition:
	.dsb 16 ; 02c0
iChannelCycle:
	.dsb 16
iChannelEnvelope:
	.dsb 16
iChannelRawPitch:
	.dsb 32
iChannelNoteID:
	.dsb 16
iChannelOctave:
	.dsb 16
iChannelTransposition:
	.dsb 16
iChannelNoteDuration:
	.dsb 16 ; 0340
iChannelNoteFlow:
	.dsb 16
iChannelPitchIncrementation:
	.dsb 16
iChannelLoopCounter:
	.dsb 16
iChannelTempo:
	.dsb 32 ; 0380
iChannelCyclePattern:
	.dsb 16
iChannelVibratoCounter:
	.dsb 16
iChannelVibratoPreamble:
	.dsb 16 ; 03c0
iChannelVibratoDepth:
	.dsb 16
iChannelVibratoTimer:
	.dsb 16
iChannelSlideTarget:
	.dsb 32
iChannelSlideDepth:
	.dsb 16
iChannelSlideFraction:
	.dsb 16
iChannelSlideTempo:
	.dsb 16
iChannelMuteCounter:
	.dsb 16 ; 0440
iChannelPitchModifier:
	.dsb 32
iChannelRelativeNoteID:
	.dsb 16
iChannelEnvelopeGroup:
	.dsb 16 ; 0480
iChannelEnvelopeGroupOffset:
	.dsb 16
iChannelMuteMain:
	.dsb 16
iChannelNoteLength:
	.dsb 16
iChannelRAMEnd:
; section: groups
iPals:
	.dsb 16 ; 04c0
	.dsb $230 ; 04d0 - 06ff
iVirtualOAM:
	.dsb $100 ; 0700 - 07ff
