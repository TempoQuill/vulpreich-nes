; section: AUDIO RAM (zero page)
zCurrentMusicPointer:
	.dsb 2 ; 0000
zNextPitch:
	.dsb 2
zNoiseIndexPointer:
	.dsb 2 ; 0004
zNoiseSFXOffset:
	.dsb 1
zMusicPulse1NoteLengthFraction:
	.dsb 1
zMusicPulse2NoteLengthFraction:
	.dsb 1 ; 0008
zMusicHillNoteLengthFraction:
	.dsb 1
zMusicNoiseNoteLengthFraction:
	.dsb 1
zMusicDPCMNoteLengthFraction:
	.dsb 1
zHillIns:
	.dsb 1 ; 000c
zPulse2Ins:
	.dsb 1
zPulse1Ins:
	.dsb 1
zMusicStack:
	.dsb 1
zOctave:
	.dsb 1 ; 0010
zMusicChannelCount:
	.dsb 1
zDPCMNoteRatioLength:
	.dsb 1
iCurrentMusic:
	.dsb 1
zCurrentDrum:
	.dsb 1 ; 0014
zCurrentDPCMSFX:
	.dsb 1
zCurrentNoiseSFX:
	.dsb 1
	.dsb 1
zMusicQueue:
	.dsb 1 ; 0018
zDPCMSFX:
	.dsb 1
zNoiseDrumSFX:
	.dsb 1
	.dsb 1
	.dsb 1 ; 001c
	.dsb 1
	.dsb 1
	.dsb 1
zMusicBank:
	.dsb 1 ; 0020
zSweep:
	.dsb 1
zTempo:
	.dsb 1
; section: Hardware Assistive RAM
; backup registers, banks, addresses, and buffers
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
zPPUDataBufferPointer:
	.dsb 2
	.dsb 2 ; 0034
	.dsb 2

zAuxAddresses: ; back up 4 at a time
; 0: audio
; 1: updates / text
; 2: vblank
; 3: everything else
	.dsb 2 ; 0038
	.dsb 2
	.dsb 2
	.dsb 2
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
	.dsb 2
	.dsb 2 ; 006c
	.dsb 2
	.dsb 2 ; 0070
	.dsb 2
	.dsb 2 ; 0074
zJumpTableIndex:
	.dsb 1
	.dsb 1
zTitleScreenTimer:
	.dsb 2 ; 0078
zSaveFileExists:
	.dsb 1
	.dsb 1
; Standard film FPS timers
; Used to skip NMI 3/5 times for 24 FPS
zFilmStandardTimerOdd:
	.dsb 1 ; 007c
zFilmStandardTimerEven:
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
	.dsb 48 ; 00b0
zPals:
	.dsb 32 ; 00e0

; section: STACK
iStack:
iStackBottom:
	.dsb $ff
iStackTop:
	.dsb 1

; section: AUDIO RAM (channels) 0200 - 04bf
iMusicPulse2BigPointer:
	.dsb 2 ; 0200
iMusicPulse1BigPointer:
	.dsb 2
iMusicHillBigPointer:
	.dsb 2 ; 0204
iMusicNoiseBigPointer:
	.dsb 2
iMusicDPCMBigPointer:
	.dsb 2 ; 0208
iMusicPulse2NoteSubFrames:
	.dsb 1
iMusicPulse1NoteSubFrames:
	.dsb 1
iMusicHillNoteSubFrames:
	.dsb 1 ; 020c
iMusicNoiseNoteSubFrames:
	.dsb 1
iMusicDPCMNoteSubFrames:
	.dsb 1
iCurrentMusicOffset:
	.dsb 1
iPulse2NoteLength:
	.dsb 1 ; 0210
iPulse1NoteLength:
	.dsb 1
iHillNoteLength:
	.dsb 1
iNoiseNoteLength:
	.dsb 1
iDPCMNoteLength:
	.dsb 1 ; 0214
iMusicStartPoint:
	.dsb 1
iMusicEndPoint:
	.dsb 1
iMusicLoopPoint:
	.dsb 1
iCurrentPulse2Offset:
	.dsb 1 ; 0218
iCurrentPulse1Offset:
	.dsb 1
iCurrentHillOffset:
	.dsb 1
iCurrentNoiseOffset:
	.dsb 1
iCurrentDPCMOffset:
	.dsb 1 ; 021c
iMusicPulse2NoteLength:
	.dsb 1
iMusicPulse1NoteLength:
	.dsb 1
iMusicHillNoteLength:
	.dsb 1
iMusicNoiseNoteLength:
	.dsb 1 ; 0220
iMusicDPCMNoteLength:
	.dsb 1
iMusicPulse2InstrumentOffset:
	.dsb 1
iMusicPulse1InstrumentOffset:
	.dsb 1
; section: input
iBackupInput:
	.dsb 1 ; 0224
iTitleInputIndex:
	.dsb 1
	.dsb 1
	.dsb 1
	.dsb 1 ; 0228
	.dsb 1
	.dsb 1
	.dsb 1
	.dsb 1 ; 022c
	.dsb 1
	.dsb 1
	.dsb 1
	.dsb 16
	.dsb 16 ; 0240
	.dsb 32
	.dsb 32
	.dsb 32
	.dsb 16
	.dsb 16 ; 02c0
	.dsb 16
	.dsb 16
	.dsb 32
	.dsb 16
	.dsb 16
	.dsb 16
	.dsb 32 ; 0340
	.dsb 16
	.dsb 16
	.dsb 32 ; 0380
	.dsb 16
	.dsb 16
	.dsb 16 ; 03c0
	.dsb 16
	.dsb 16
	.dsb 32
	.dsb 16
	.dsb 16
	.dsb 16
	.dsb 16 ; 0440
	.dsb 32
	.dsb 16
	.dsb 16 ; 0480
	.dsb 16
	.dsb 16
	.dsb 16
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
