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
; we're in mode 1, so we can switch tilesets in as needed
; 4K is the perfect balance between speed and flexibility
	LDA zCHRWindow0
	STA MMC5_CHRBankSwitch4 ; 0000-0fff

	LDA zCHRWindow1
	STA MMC5_CHRBankSwitch8  ; 1000-1fff
	STA MMC5_CHRBankSwitch12 ; 1000-1fff, 0000-0fff

	RTS

; this unreferenced subroutine was commonplace in 80's NES games
; it's a bit superfluous though
; just write the address to the PPU as you see here to the location you want
ResetPPUAddress:
	LDA PPUSTATUS
	LDA #>PALETTE_RAM ; hi then lo
	STA PPUADDR
	LDA #<PALETTE_RAM
	STA PPUADDR
	STA PPUADDR
	STA PPUADDR
	RTS
;
; Updates joypad press/held values
;
UpdateJoypads:
	JSR ReadJoypads
	LDY #0

@Loop1:
	; Work around DPCM sample bug,
	; where some inputs get forged
	LDA zInputBottleNeck
	STA iBackupInput, Y
	JSR ReadJoypads
	DEY
	BNE @Loop1

	LDX #$02
	LDA zInputBottleNeck

@CMPStash:
	DEX
	BMI @UseStash
	CMP iBackupInput, X
	BNE @CMPStash
	BEQ @Bottleneck

@UseStash:
	LDA iBackupInput
	AND iBackupInput + 1
	STA zInputBottleNeck

@Bottleneck:
	LDX #$01

@Loop2:
	LDA zInputBottleNeck, X ; Update the press/held values
	TAY
	EOR zInputCurrentState, X
	AND zInputBottleNeck, X
	STA zInputBottleNeck, X
	STY zInputCurrentState, X
	DEX
	BPL @Loop2
	RTS


;
; Reads joypad pressed input
;
ReadJoypads:
	; send a jolt to the controller
	LDA #1
	STA JOY1
	; send the same jolt to the bottleneck to set C at the end
	STA zInputBottleNeck + 1
	; 1 >> 1 = 0, C is not needed right now
	LSR A
	STA JOY1
@Loop:
	; Read standard controller data
	LDA JOY1
	LSR A
	; are we done?
	ROL zInputBottleNeck
	LDA JOY2
	LSR A
	ROL zInputBottleNeck + 1
	BCC @Loop
	; we're done
	RTS

Start:
	; our game's configuration is now initialized
	; make sure track 0 is playing
	LDA #0
	STA PPUMASK
	STA zPPUMaskMirror
	; music 0
	TAY ; MUSIC_NONE
	STY zMusicQueue
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite1000
; PPUCtrl_Background0000
; PPUCtrl_SpriteSize8x8
; PPUCtrl_NMIEnabled
	ORA #PPU_NMI | PPU_OBJECT_TABLE
	STA zPPUCtrlMirror
	STA PPUCTRL
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
; The NMI runs every frame during vertical blanking and is responsible for
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
	; palettes
	JSR @ApplyPalette
	; dma shortcut
	; Map
	; tiles
	JSR UpdatePPUFromBufferWithOptions
	; scroll
	LDX zPPUCtrlMirror
	STX PPUCTRL
	LDX #0
	STX PPUSCROLL
	STX PPUSCROLL
	LDX zPPUMaskMirror
	STX PPUMASK
	JSR FadePalettes
	JSR UpdateJoypads
	; advance sound by one frame
	JSR UpdateSound
	; check for an NMI timer (4.25 seconds maximum)
	LDA zNMITimer
	BEQ @DoNotAdjust
	DEC zNMITimer
@DoNotAdjust:
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
	LDX PPUSTATUS
	LDX #>PALETTE_RAM
	STX PPUADDR
	LDX #<PALETTE_RAM
	STX PPUADDR
	LDA zPals
	AND #COLOR_INDEX
	TAX
	STA PPUDATA
	LDA zPals + 1
	STA PPUDATA
	LDA zPals + 2
	STA PPUDATA
	LDA zPals + 3
	STA PPUDATA
	STX PPUDATA
	LDA zPals + 5
	STA PPUDATA
	LDA zPals + 6
	STA PPUDATA
	LDA zPals + 7
	STA PPUDATA
	STX PPUDATA
	LDA zPals + 9
	STA PPUDATA
	LDA zPals + 10
	STA PPUDATA
	LDA zPals + 11
	STA PPUDATA
	STX PPUDATA
	LDA zPals + 13
	STA PPUDATA
	LDA zPals + 14
	STA PPUDATA
	LDA zPals + 15
	STA PPUDATA
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
	LDA #%01010000
	STA MMC5_NametableMapping

	; setup RAM
	LDA #RAM_Scratch
	STA zRAMBank
	; upper CHR bits go unused
	STA MMC5_CHRBankSwitchUpper

	; MMC5 Pulse channels
	LDA #$0f
	STA MMC5_SND_CHN

	; select the first two CHR banks
	LDA #CHR_TitleBG
	STA MMC5_CHRBankSwitch4
	STA zCHRWindow0
	LDA #CHR_TitleOBJ
	STA MMC5_CHRBankSwitch8
	STA MMC5_CHRBankSwitch12
	STA zCHRWindow1

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
	STA PPUCTRL
	STA zPPUCtrlMirror
	LDX #<iStackTop ; Reset stack pointer
	TXS

@VBlankLoop:
	; Wait for first VBlank
	LDA PPUSTATUS
	AND #PPUStatus_VBlankHit
	BEQ @VBlankLoop

@VBlank2Loop:
	; Wait for second VBlank
	LDA PPUSTATUS
	BPL @VBlank2Loop

	LDA #MMC5_VMirror
	STA MMC5_NametableMapping
	INX
	TXA
@Loop:
	; clear RAM
	DEX
	STA $400, X
	STA $500, X
	STA $600, X
	STA $700, X
	STA $5c00, X ; mmc5 RAM
	STA $5d00, X
	STA $5e00, X
	STA $5f00, X
	STA $6000, X ; cart RAM
	STA $6100, X
	STA $6200, X
	STA $6300, X
	STA $6400, X
	STA $6500, X
	STA $6600, X
	STA $6700, X
	STA $6800, X
	STA $6900, X
	STA $6a00, X
	STA $6b00, X
	STA $6c00, X
	STA $6d00, X
	STA $6e00, X
	STA $6f00, X
	STA $7000, X
	STA $7100, X
	STA $7200, X
	STA $7300, X
	STA $7400, X
	STA $7500, X
	STA $7600, X
	STA $7700, X
	STA $7800, X
	STA $7900, X
	STA $7a00, X
	STA $7b00, X
	STA $7c00, X
	STA $7d00, X
	STA $7e00, X
	STA $7f00, X
	BNE @Loop
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
