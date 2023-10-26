UpdatePRG:
; update the two available windows
; window 3 uses DPCM, and window 4 is Home ROM
	LDA zWindow1
	STA MMC5_PRGBankSwitch2
	LDA zWindow2
	STA MMC5_PRGBankSwitch3
	RTS

UpdateCHR:
; This updates all the needed registers.
; we're in mode 1, so we can switch tilesets / sprites in as needed
; 4K is the perfect balance between speed and flexibility
	LDA zCHRWindow2
	BEQ @Quit
	STA MMC5_CHRBankSwitch12 ; background

	LDA zCHRWindow1
	BEQ @Quit
	STA MMC5_CHRBankSwitch8 ; sprite table 1

	LDA zCHRWindow0
	BEQ @Quit
	STA MMC5_CHRBankSwitch4 ; sprite table 0

@Quit:
	LDA #0
	STA zCHRWindow0
	STA zCHRWindow1
	STA zCHRWindow2
	RTS

; this unreferenced subroutine was commonplace in 80's NES games
; it's a bit superfluous though
; just write the address to the PPU as you see here to the location you want
ResetPPUAddress:
	LDA rSTATE
	LDA #>PALETTE_RAM ; hi then lo
	STA rWORD
	LDA #<PALETTE_RAM
	STA rWORD
	STA rWORD
	STA rWORD
	RTS
;
; Updates joypad press/held values
;
UpdateJoypads:
	; Work around DPCM sample bug.
	; Some inputs are skipped, leading to polling corruption
	; most noticeable with forged right presses, but also mistaking
	; certain inputs for others

	; Delection can result in each column below:
	; Interpreted: A B      SELECT START UP   DOWN LEFT  RIGHT
	; Reality:     B SELECT START  UP    DOWN LEFT RIGHT NULL
; STEP 1: Read input twice, stash them one at a time.
	JSR ReadJoypad
	LDA zInputBottleNeck
	STA iBackupInput
	JSR ReadJoypad
	LDA zInputBottleNeck
	STA iBackupInput + 1
; STEP 2: EOR the backups together.  0 means the backups match
	EOR iBackupInput
	BEQ @Loop
; Corrupt stash!
; STEP 3: Stash result.
	TAX

; STEP 4: Look for the correct input.
; MEASURE 1: If one of the backups is 0, nothing was pressed.
	LDA iBackupInput + 1
	BEQ @CorrectInput
	LDA iBackupInput
	BEQ @CorrectInput

; MEASURE 2: Find the correct backup, as output by Y
	JSR @FindDeletion

	LDA iBackupInput, Y

@CorrectInput:
; At this point, A is assumed to hold the correct input, which should be used.
	STA zInputBottleNeck

@Loop:
	; determine which buttons were newly pressed
	LDA zInputBottleNeck
	TAY
	EOR zInputCurrentState
	AND zInputBottleNeck
	STA zInputBottleNeck
	STY zInputCurrentState
	RTS

@FindDeletion:
	; We need the EOR result!
	; Seperate each bit into where they belong.
	TXA
	AND iBackupInput
	STA iBackupInput + 2
	TXA
	AND iBackupInput + 1
	STA iBackupInput + 3
	; Y will now determine which backup is the correct input.
	; Looping may occur during right presses.
	LDY #0
@Looking:
	; iBackupInput(3) trips C --> Y = 0
	LSR iBackupInput + 3
	BCS @Found
	; iBackupInput(3) trips Z --> Y = 1
	INY
	LDA iBackupInput + 3
	BEQ @Found
	; iBackupInput(2) trips C --> Y = 1
	LSR iBackupInput + 2
	BCS @Found
	; iBackupInput(2) trips Z --> Y = 0
	DEY
	LDA iBackupInput + 2
	BNE @Looking ; loop if nothing was tripped
@Found:
	RTS

;
; Reads joypad pressed input
;
ReadJoypad:
	; send a jolt to the controller
	LDA #1
	STA rJOY
	; send the same jolt to the bottleneck to set C at the end
	STA zInputBottleNeck
	; 1 >> 1 = 0, C is not needed right now
	LSR A
	STA rJOY
@Loop:
	; Read standard controller data
	LDA rJOY
	LSR A
	; are we done?
	ROL zInputBottleNeck
	BCC @Loop
	; we're done
	RTS

Start:
	; our game's configuration is now initialized
	; make sure track 0 is playing
	LDA #0
	STA rMASK
	STA zPPUMaskMirror
	LDY #DEFAULT_OPTION
	STY zOptions
	TAY
	STY zMusicQueue
	LDY #PRG_Music0
	STY zMusicBank
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite0000
; PPUCtrl_Background1000
; PPUCtrl_SpriteSize8x8
; PPUCtrl_NMIEnabled
	ORA #PPU_NMI | PPU_BG_TABLE
	STA zPPUCtrlMirror
	STA rCTRL
	; wait one vblank to init main loop
	LDA #1
	JSR DelayFrame_s_
	JMP GameInit

SyncToCurrentWindow:
	LDA zCurrentWindow + 1
	STA zWindow2
	STA MMC5_PRGBankSwitch3
	LDA zCurrentWindow
	STA zWindow1
	STA MMC5_PRGBankSwitch2 
	RTS

;
; NMI - this is the first of three labels that need constant accessibility
;	RESET is the starting point of the ROM, and IRQ runs mid-frame
;
; The NMI runs every 2/5 frames during vertical blanking and is responsible for
; tasks that should occur on each frame of gameplay, such as drawing tiles and
; sprites, scrolling, and reading input.
;
; It also runs the audio engine, allowing music to play continuously no matter
; how busy the rest of the game happens to be.
;
NMI:
	PHP
	PHA
	PHX
	PHY
	; save the PRG
	; heavy bank switching might take place
	LDA zWindow2
	STA zBackupWindow + 1
	LDA zWindow1
	STA zBackupWindow
	LDA zCurrentWindow + 1
	STA zWindow2
	LDA zCurrentWindow
	STA zWindow1
	; if none of neither timer is 0, we're off-frame
	; starting timer values of 1 & 4 allow for 24 FPS
	;           (Standard Animation Framerate)-++
	JSR CheckFilmTimers
	BNE @OffFrame
	; CHR ROM
	JSR UpdateCHR
	; palettes
	JSR @ApplyPalette
	; Map
	; tiles
	JSR UpdatePPUFromBufferWithOptions
	; dma shortcut
	LDA #>iVirtualOAM
	STA rOAMDMA
	; scroll
	LDX zPPUCtrlMirror
	STX rCTRL
	JSR ResetPPUAddress
	LDX #0
	STX rSCROLL
	STX rSCROLL
	LDX zPPUMaskMirror
	STX rMASK
	JSR FadePalettes
	JSR UpdateJoypads
@OffFrame:
	; sound operates every NMI
	; advance sound by one frame
	JSR UpdateSound
	; check the film timers again
	; off-frames can't advance any NMI timer
	JSR CheckFilmTimers
	BNE @DoNotAdjust
	; check for an NMI timer (10.625 seconds maximum at 24 FPS)
	LDA zNMITimer
	BEQ @DoNotAdjust
	DEC zNMITimer
@DoNotAdjust:
	; advance the film timers
	JSR UpdateFilmTimers
	; cleanup
	LDA zWindow2
	STA zCurrentWindow + 1
	LDA zWindow1
	STA zCurrentWindow
	LDA zBackupWindow + 1
	STA zWindow2
	STA MMC5_PRGBankSwitch3
	LDA zBackupWindow
	STA zWindow1
	STA MMC5_PRGBankSwitch2
	PLY
	PLX
	PLA
	PLP
	RTI

@ApplyPalette:
	LDX rSTATE
	LDX #>PALETTE_RAM
	STX rWORD
	LDX #<PALETTE_RAM
	STX rWORD
	LDA zPals
	AND #COLOR_INDEX
	TAX
	STA rDATA
	LDA zPals + $01
	STA rDATA
	LDA zPals + $02
	STA rDATA
	LDA zPals + $03
	STA rDATA
	STX rDATA
	LDA zPals + $05
	STA rDATA
	LDA zPals + $06
	STA rDATA
	LDA zPals + $07
	STA rDATA
	STX rDATA
	LDA zPals + $09
	STA rDATA
	LDA zPals + $0a
	STA rDATA
	LDA zPals + $0b
	STA rDATA
	STX rDATA
	LDA zPals + $0d
	STA rDATA
	LDA zPals + $0e
	STA rDATA
	LDA zPals + $0f
	STA rDATA
	STX rDATA
	LDA zPals + $11
	STA rDATA
	LDA zPals + $12
	STA rDATA
	LDA zPals + $13
	STA rDATA
	STX rDATA
	LDA zPals + $15
	STA rDATA
	LDA zPals + $16
	STA rDATA
	LDA zPals + $17
	STA rDATA
	STX rDATA
	LDA zPals + $19
	STA rDATA
	LDA zPals + $1a
	STA rDATA
	LDA zPals + $1b
	STA rDATA
	STX rDATA
	LDA zPals + $1d
	STA rDATA
	LDA zPals + $1e
	STA rDATA
	LDA zPals + $1f
	STA rDATA
	RTS

;
; Public RESET
;
; This code is called when the NES is reset and handles some boilerplate
; initialization before starting the game loop.
;
; The NMI handles frame rendering.
;
RESET:
	LDA #3 ; all 8K switchable
	STA MMC5_PRGMode
	LDA #1 ; 4K mode (try not to use $5130)
	STA MMC5_CHRMode

	; PRG RAM handshake
	; Enable writable MMC5 exclusive RAM
	LDA #2
	STA MMC5_PRGRAMProtect1
	STA MMC5_ExtendedRAMMode
	LDA #1
	STA MMC5_PRGRAMProtect2

	; Set nametable mapping
	LDA #MMC5_HMirror
	STA MMC5_NametableMapping

	; setup RAM
	LDA #RAM_Scratch
	STA zRAMBank
	; upper CHR bits go unused
	STA MMC5_CHRBankSwitchUpper

	; MMC5 Pulse channels
	LDA #$0f
	STA MMC5_MIXER

	; select the first three CHR banks
	; bank 0 is a mirror of 3
	LDX #CHR_TitleBG
	STX MMC5_CHRBankSwitch12
	STX zCHRWindow2
	DEX ; CHR_TitleOBJ2
	STX MMC5_CHRBankSwitch8
	STX zCHRWindow1
	DEX ; CHR_TitleOBJ1
	STX MMC5_CHRBankSwitch4
	STX zCHRWindow0
	DEX
	TXA
	; init RAM
@Loop:
	; clear RAM
	DEX
	STA $0, X
	STA $100, X
	STA $200, X
	STA $300, X
	STA $400, X
	STA $500, X
	STA $600, X
	STA $700, X
	STA $5e00, X ; mmc5 RAM
	BNE @Loop

	; select the starter PRG banks
	LDA #PRG_Start0
	STA MMC5_PRGBankSwitch2
	STA zWindow1
	STA zCurrentWindow
	LDA #PRG_Start1
	STA MMC5_PRGBankSwitch3
	STA zWindow2
	STA zCurrentWindow + 1
	; PRG_Start2 needs to be empty due to DPCM
	LDA #PRG_Start2
	STA MMC5_PRGBankSwitch4
	; Home ROM
	LDA #PRG_Home
	STA MMC5_PRGBankSwitch5

	SEI
	CLD
; Nametable base 0, Horizontal writing, OBJ base 0, BG base 0, 8x8 OBJs, no NMI
	LDA #0
	STA rCTRL
	STA zPPUCtrlMirror
	LDX #<iStackTop ; Reset stack pointer
	TXS

@VBlankLoop:
	; Wait for first VBlank
	LDA rSTATE
	AND #PPUStatus_VBlankHit
	BEQ @VBlankLoop

@VBlank2Loop:
	; Wait for second VBlank
	LDA rSTATE
	BPL @VBlank2Loop

	LDA #MMC5_SFiller
	STA MMC5_NametableMapping
	LDA #0
	STA MMC5_FillModeTile
	STA MMC5_FillModeColor
	JMP Start

IRQ:
	RTI

.pad $fff1, $00
UnreferencedTitle:
; title of the game, fff1
; it was common practice in old games to write the name at the end of PRG ROM.
	.db "VULPREICH"

NESVectorTables:
	.dw NMI   ; runs every frame
	.dw RESET ; boots up the game
	.dw IRQ   ; dummied out
