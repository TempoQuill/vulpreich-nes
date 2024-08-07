; section: AUDIO RAM (zero page)
zCurrentMusicPointer:
	.dsb 2 ; 0000
zNextPitch:
	.dsb 2
zNoiseIndexPointer:
	.dsb 2 ; 0004
zNoiseSFXOffset:
	.dsb 1
zMusicPulse1FPNA:
	.dsb 1
zMusicPulse2FPNA:
	.dsb 1 ; 0008
zMusicHillFPNA:
	.dsb 1
zMusicNoiseFPNA:
	.dsb 1
zMusicDPCMFPNA:
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
zCurrentMusic:
	.dsb 1
zCurrentDrum:
	.dsb 1 ; 0014
zCurrentDPCMSFX:
	.dsb 1
zCurrentNoiseSFX:
	.dsb 1
zCurrentFanfare:
	.dsb 1
zCurrentPulse2SFX:
	.dsb 1 ; 0018
zMusicQueue:
	.dsb 1
zDPCMSFX:
	.dsb 1
zNoiseDrumSFX:
	.dsb 1
zFanfare:
	.dsb 1 ; 001c
zPulse2SFX:
	.dsb 1
zPulse1IndexPointer:
	.dsb 2
zMusicBank:
	.dsb 1 ; 0020
zSweep:
	.dsb 1
zTempo:
	.dsb 1
zFanfareArea:
zFanfareTempo:
	.dsb 1
zFanfarePointers:
zFanfarePointerSQ2:
	.dsb 2 ; 0024
zFanfarePointerSQ1:
	.dsb 2
zFanfarePointerHill:
	.dsb 2 ; 0028
zFanfarePointerNoise:
	.dsb 2
zFanfarePointerDPCM:
	.dsb 2 ; 002c
zFanfare_instrument:
	.dsb 1
	.dsb 1
zFanfare_length:
	.dsb 1 ; 0030
	.dsb 1
	.dsb 1
zFanfare_offset:
	.dsb 1
	.dsb 1 ; 0034
	.dsb 1
	.dsb 1
	.dsb 1
zFanfare_duration:
	.dsb 1 ; 0038
	.dsb 1
	.dsb 1
	.dsb 1
	.dsb 1 ; 003c
zFanfareAreaEnd:
; section: Hardware Assistive RAM
; backup registers, banks, addresses, and buffers
zNMITimer:
	.dsb 1
zBackupA:
	.dsb 1
zBackupX:
	.dsb 1
zBackupY:
	.dsb 1 ; 0040
zTableOffset:
	.dsb 2
zRAMBank: ; MMC5 backups, and b/c this is ZP, this is optimal speed
	.dsb 1
; despite 4 switchable banks, only two real windows are needed
; zWindow1 - 8000-9fff, zWindow2 - a000-bfff
; c000-dfff is the DPCM area, and e000-fff9 is home ROM
zWindow1:
	.dsb 1 ; 0044
zWindow2:
	.dsb 1
zCurrentWindow:
	.dsb 2
zBackupWindow:
	.dsb 2 ; 0048
zPPUDataBufferPointer:
	.dsb 2
	.dsb 1 ; 004c
zCHRWindow0:
	.dsb 1
zCHRWindow1:
	.dsb 1
zCHRWindow2:
	.dsb 1

zAuxAddresses: ; back up 4 at a time
; 0: audio
; 1: updates / text
; 2: vblank
; 3: everything else
	.dsb 2 ; 0050
	.dsb 2
	.dsb 2
	.dsb 2
zFactorBuffer:
	.dsb 4 ; 0058
zDividerBuffer:
	.dsb 4 ; 005c
zAddendBuffer:
	.dsb 4 ; 0060
zDifferentialBuffer:
	.dsb 4 ; 0064
zInputBottleNeck:
	.dsb 2 ; 0068
zInputCurrentState:
	.dsb 2
zPPUCtrlMirror:
	.dsb 1 ; 006c
zPPUMaskMirror:
	.dsb 1
zPPUStatusMirror:
	.dsb 1
zPPUScrollXMirror:
	.dsb 1
zPPUScrollYMirror:
	.dsb 1 ; 0070
zPalFade:
	.dsb 1
zPalFadeSpeed:
	.dsb 1
zPalFadePlacement:
	.dsb 1
; section: miscellaneous
zSaveMenuOption:
	.dsb 1 ; 0074
zSaveMenuSelectedOption:
	.dsb 1
zSaveMenuROMPointer:
	.dsb 2
zSaveMenuRAMPointer:
	.dsb 2 ; 0078
zTitleScreenSelectedOption:
	.dsb 1
zTitleScreenTimer:
	.dsb 2
; Standard film FPS timers
; Used to skip NMI 3/5 times for 24 FPS
zFilmStandardTimerOdd:
	.dsb 1 
zFilmStandardTimerEven:
	.dsb 1
zLyricsOffset:
	.dsb 1
zStringXOffset:
	.dsb 1 ; 0080
zStringXConst:
	.dsb 1
; section: title screen animation variables
; only allows 2 objects due to the 8-sprite per scanline limitation.
; ANIMATION QUEUE 1 - Iggy / Otis
; 0     - Frames left before looping
; 1     - Pointer index
; 2     - X Coordinate
; 3-4   - Starting point
; 5-6   - Frame pointer
; 7-8   - Index pointer
; 9-13  - Pointer addresses (LO and HI)
; 14     - Y Coordinate - only changes on per sprite basis
; 15    - Sprite flags - only changes when sprites enter/exit the screen
; 16	- Sprite resolution - only changes on per sprite basis
; 17-18 - OAM pointer - $07xx
; 19-20 - Movement pointer
zTitleObj1:
zTitleObj1Timer:
	.dsb 1
zTitleObj1PointerIndex:
	.dsb 1
zTitleObj1XCoord:
	.dsb 1 ; 0084
zTitleObj1StartingPoint:
	.dsb 2
zTitleObj1FramePointer:
	.dsb 2
zTitleObj1IndexPointer:
	.dsb 2
zTitleObj1PointerAddresses:
	.dsb 4
zTitleObj1YCoord:
	.dsb 1
zTitleObj1ScreenEdgeFlags:
	.dsb 1 ; 0090
zTitleObj1Resolution:
	.dsb 1
zTitleObj1OAMPointer:
	.dsb 2
zTitleObj1MovementPointer:
	.dsb 2 ; 0094
zTitleObj1End:
; ANIMATION QUEUE 2 - June / the crow
zTitleObj2:
zTitleObj2Timer:
	.dsb 1
zTitleObj2PointerIndex:
	.dsb 1
zTitleObj2XCoord:
	.dsb 1 ; 0098
zTitleObj2StartingPoint:
	.dsb 2
zTitleObj2FramePointer:
	.dsb 2
zTitleObj2PointerAddresses:
	.dsb 4
zTitleObj2IndexPointer:
	.dsb 2
zTitleObj2YCoord:
	.dsb 1
zTitleObj2ScreenEdgeFlags:
	.dsb 1 ; 00a4
zTitleObj2Resolution:
	.dsb 1
zTitleObj2OAMPointer:
	.dsb 2
zTitleObj2MovementPointer:
	.dsb 2 ; 00a8
zTitleObj2End:
zTitleObjFinished:
	.dsb 1
zTitle1ObjIndex:
	.dsb 1
zTitle2ObjIndex:
	.dsb 1 ; 00ac
zTitleObj1InitPointer:
	.dsb 2
zTitleObj2InitPointer:
	.dsb 2
zTitleObjLoopPoint1:
	.dsb 1
zTitleObjLoopPoint2:
	.dsb 1
zCursorXPos:
	.dsb 1
zCursorYPos:
	.dsb 1 ; 00b4
zCursorFrame:
	.dsb 1
zOptions:
; 0-1 - Price Modifier
; 2-3 - Text speed
; 4   - Cutscenes
; 5   - Voices
; 6   - Sound Effects
; 7   - Music
	.dsb 1
zOptionNumber:
; 0 - Audio toggle
; 1 - Cutscenes
; 2 - Text speed
; 3 - Price setting
; 4 - Music test
; 5 - Sound effects test
; 6 - Back to title screen
	.dsb 1
zOptionNumberSelectedCPL:
	.dsb 1 ; 00b8
zAudioFlagPointer:
	.dsb 1
zTempAudioFlagPointer:
	.dsb 1
zOWObject1:
	.dsb 5
zOWObject2:
	.dsb 5 ; 00c0
	.dsb 27
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
zCurrentMusicOffset:
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
iTitleInputIndex:
	.dsb 1 ; 0224
iPulse2SFXVolume:
	.dsb 2
iPulse2SFXOffset:
	.dsb 1
iPulse2SFXSweep:
	.dsb 1 ; 0228
iFanfare_DurationID:
	.dsb 5
iFanfare_Remainder:
	.dsb 5
iFanfare_Sub:
	.dsb 5
iFanfare_LengthPoints:
	.dsb 1 ; 0238
	.dsb 1
; section: input
iBackupInput:
	.dsb 1
	.dsb 1
	.dsb 1 ; 023c
	.dsb 1
; 0: Menus
; 1: Overworld
; 2: Cutscenes
iGameMilestone:
	.dsb 1
	.dsb 1
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
iCurrentPals:
	.dsb 32 ; 04c0
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
