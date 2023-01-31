
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

zRawPitchBackup:
	.dsb 2
zPitchSlideDifference:
	.dsb 2 ; 001c
zVibratoBackup:
	.dsb 1

zCurrentEnvelopeGroupOffset:
	.dsb 1
zCurrentEnvelopeGroupAddress:
	.dsb 2 ; 0020
zAudioRAMEnd:

; section: Hardware Assistive RAM
; backup registers, banks, addresses, and buffers
zNMIState:
	.dsb 1
zNMITimer:
	.dsb 1
zCHRWindow0:
	.dsb 1 ; 0024
zCHRWindow1:
	.dsb 1
zBackupA:
	.dsb 1
zBackupX:
	.dsb 1
zBackupY:
	.dsb 1 ; 0028
zTableOffset:
	.dsb 2
zRAMBank: ; MMC5 backups, and b/c this is ZP, this is optimal speed
	.dsb 1
; despite 4 switchable banks, only two real windows are needed
; zWindow1 - 8000-9fff, zWindow2 - a000-bfff
; c000-dfff is the DPCM area, and e000-fff9 is home ROM
zWindow1:
	.dsb 1 ; 002c
zWindow2:
	.dsb 1
zCurrentWindow:
	.dsb 2
zBackupWindow:
	.dsb 2 ; 0030
	.dsb 2
	.dsb 2 ; 0034
	.dsb 2

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
zPPUScrollXMirror:
	.dsb 1
zPPUScrollYMirror:
	.dsb 1 ; 0058
zStringXOffset:
	.dsb 1
zPalPointer:
	.dsb 2
zPalFade:
	.dsb 1 ; 005c
zPalFadeOffset:
	.dsb 1
zPalFadeSpeed:
	.dsb 1
zPalFadePlacement:
	.dsb 1
; section: miscellaneous
zTitleScreenOption:
	.dsb 1 ; 0060
zTitleScreenSelectedOption:
	.dsb 1
zCurrentTextByte:
	.dsb 1
zTextBank:
	.dsb 1
zCurrentTextAddress:
	.dsb 2 ; 0064
	.dsb 2
	.dsb 2 ; 0068
zTextOffset:
	.dsb 2
	.dsb 2 ; 006c
	.dsb 2
zCurrentTileAddress:
	.dsb 2 ; 0070
zTileOffset:
	.dsb 2
zCurrentTileNametableAddress:
	.dsb 2 ; 0074
zJumpTableIndex:
	.dsb 1
	.dsb 1
zTitleScreenTimer:
	.dsb 2 ; 0078
zSaveFileExists:
	.dsb 1
zTextSpeed:
	.dsb 1
	.dsb 1 ; 007c
	.dsb 1
	.dsb 1
	.dsb 1
	.dsb 2 ; 0080
	.dsb 2
	.dsb 4 ; 0084
	.dsb 4 ; 0088
	.dsb 4 ; 008c
	.dsb 4 ; 0090
	.dsb 4 ; 0094
	.dsb 4 ; 0098
	.dsb 4 ; 009c
	.dsb 4 ; 00a0
	.dsb 4 ; 00a4
	.dsb 4 ; 00a8
	.dsb 4 ; 00ac
zPals:
	.dsb 16 ; 00b0
zPalAttributes:
	.dsb 64 ; 00c0

; section: STACK
iStack:
iStackBottom:
	.dsb $ff
iStackTop:
	.dsb 1

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
	.dsb 32 ; 0340
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
iChannelStaccatoCounter:
	.dsb 16 ; 0440
iChannelPitchModifier:
	.dsb 32
iChannelRelativeNoteID:
	.dsb 16
iChannelEnvelopeGroup:
	.dsb 16 ; 0480
iChannelEnvelopeGroupOffset:
	.dsb 16
iChannelStaccatoMain:
	.dsb 16
iChannelNoteLength:
	.dsb 16
iChannelRAMEnd:
; section: groups
	.dsb 16 ; 04c0
iCurrentPals:
	.dsb 16 ; 04d0
iNSFBanks:
	.dsb 8 ; 04e0
	.dsb $18 ; 04e8
	.dsb $40 ; 0500
	.dsb $40 ; 0540
	.dsb $40 ; 0580
	.dsb $40 ; 05c0
iStringBuffer:
	.dsb $100 ; 0600
iVirtualOAM:
	.dsb $100 ; 0700 - 07ff
