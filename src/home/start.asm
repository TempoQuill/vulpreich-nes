UpdatePRG:
	LDA zWindow1
	STA MMC5_PRGBankSwitch2
	LDA zWindow2
	STA MMC5_PRGBankSwitch3
	LDA zWindow3
	STA MMC5_PRGBankSwitch4
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
	LDX #0
	JSR ReadJoypads

@DoubleCheckInput0:
	; Work around DPCM sample bug,
	; where some inputs get forged
	LDY zInputBottleNeck, X
	JSR ReadJoypads

	TYA
	CMP zInputBottleNeck, X
	BNE @DoubleCheckInput0

	INX
	JSR ReadJoypads

@DoubleCheckInput1:
	LDY zInputBottleNeck, X
	JSR ReadJoypads

	TYA
	CMP zInputBottleNeck, X
	BNE @DoubleCheckInput1

@Loop:
	LDA zInputBottleNeck, X ; Update the press/held values
	TAY
	EOR zInputCurrentState, X
	AND zInputBottleNeck, X
	STA zInputBottleNeck, X
	STY zInputCurrentState, X
	DEX
	BPL @Loop

	RTS


;
; Reads joypad pressed input
;
ReadJoypads:
	; send a jolt to the controller
	LDA #1
	STA JOY1, X
	; send the same jolt to the bottleneck to set C at the end
	STA zInputBottleNeck, X
	; 1 >> 1 = 0, C is not needed right now
	LSR A
	STA JOY1, X
@Loop:
	; Read standard controller data
	LDA JOY1, X
	LSR A
	; are we done?
	ROL zInputBottleNeck, X
	BCC @Loop
	; we're done
	; make inputs readable to the game
	LDA zInputBottleNeck, X
	FAB
	STA zInputBottleNeck, X
	RTS

Start:
	; our game's configuration is now initialized
	; make sure track 0 is playing
	LDA #0
	STA PPUMASK
	TAY ; MUSIC_NONE
	JSR PlayMusic
	; we won't be ready for graphical updates
	; if we update anything now, it has to be only sound
	LDA #NMI_SOUND
	STA zNMIState
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite1000
; PPUCtrl_Background0000
; PPUCtrl_SpriteSize8x8
; PPUCtrl_NMIEnabled
	ORA #1 << PPU_NMI | 1 << PPU_OBJECT_TABLE
	STA zPPUCtrlMirror
	STA PPUCTRL
	; wait one vblank to init main loop
	LDA #1
	JSR DelayFrame_s_
	JMP GameInit

SyncToCurrentWindow:
	LDX #NUM_FLEXIBLE_PRG
@Loop:
	DEX
	LDA zCurrentWindow, X
	STA zWindow1, X
	STA MMC5_PRGBankSwitch2, X
	TXA
	BNE @Loop
	RTS

BackupPRG:
	LDX #NUM_FLEXIBLE_PRG
@Loop:
	DEX
	LDA zWindow1, X
	STA zBackupWindow, X
	LDA zCurrentWindow, X
	STA zWindow1, X
	STA MMC5_PRGBankSwitch2, X
	TXA
	BNE @Loop
	RTS

RestorePRG:
	LDX #NUM_FLEXIBLE_PRG
@Loop:
	DEX
	LDA zWindow1, X
	STA zCurrentWindow, X
	LDA zBackupWindow, X
	STA zWindow1, X
	STA MMC5_PRGBankSwitch2, X
	TXA
	BNE @Loop
	RTS

;
; Public NMI: where dreams come true!
;
; The NMI runs every frame during vertical blanking and is responsible for
; tasks that should occur on each frame of gameplay, such as drawing tiles and
; sprites, scrolling, and reading input.
;
; It also runs the audio engine, allowing music to play continuously no matter
; how busy the rest of the game happens to be.
;
; in VulpReich, the NMI can take on 6 (technically 8) unique states.
; Functionality in these states range from disabling everything but sound and
; basic NMI operation to ignoring inputs, sprites or scrolling
NMI:
	; preserve all registers
	PHP
	PHA
	PHX
	PHY
	; save the PRG
	; heavy bank switching might take place
	JSR BackupPRG
	; look for NMI_SOUND, else generate a pointer offset
	LDA zNMIState
	CMP #NMI_SOUND
	BEQ @JustSound
	ASL A
	TAY
	JSR @GeneratePointers
@JustSound:
	; advance sound by one frame
	JSR UpdateSound
	; check for an NMI timer (4.25 seconds maximum)
	LDA zNMITimer
	BEQ @DoNotAdjust
	DEC zNMITimer
@DoNotAdjust:
	; cleanup
	JSR RestorePRG
	PLY
	PLX
	PLA
	PLP
	RTI

@GeneratePointers:
	LDA @Pointers, Y
	STA zAuxAddresses + 2
	INY
	LDA @Pointers, Y
	STA zAuxAddresses + 3
	JMP (zAuxAddresses + 2)

@Pointers:
	.dw @State0
	.dw @State1
	.dw @State0 ; unused
	.dw @State3
	.dw @State4
	.dw @State5
	.dw @State0 ; just in case
	.dw @State0 ; just in case

@State0:
; normal NMI
	JSR @Scroll
	JSR @MapBuffer
	JSR @Palettes
	JSR @DMA
	JSR @Map
	JSR @Tiles
	JSR @OAM
	JMP @JoyPad

@State1:
; solid
; disable DMA
	JSR @Scroll
	JSR @Palettes
	JSR @Map
	JSR @Tiles
	JSR @OAM
	JMP @JoyPad

@State3:
; liquid
; disable joypad
	JSR @Scroll
	JSR @Palettes
	JSR @Map
	JSR @Tiles
	JMP @OAM

@State4:
; gas
; disable scrolling
	JSR @Map
	JSR @Tiles
	JSR @OAM
	JMP @JoyPad

@State5:
; plasma
; disable sprites
	JSR @Scroll
	JSR @Palettes
	JSR @Map
	JSR @Tiles
	JMP @JoyPad

@Scroll:
	LDA zNMIState
	CMP #5
	BNE @ScrollNormal
	LDA zPPUScrollXMirror
	STA PPUSCROLL
	LDA #0
	STA PPUSCROLL
	BEQ @ScrollQuit
@ScrollNormal:
	LDA zPPUScrollXMirror
	STA PPUSCROLL
	LDA zPPUScrollYMirror
	STA PPUSCROLL
@ScrollQuit:
	RTS

@MapBuffer:
	RTS

@Palettes:
	JSR FadePalettes
	LDA #>PALETTE_RAM
	STA PPUADDR
	LDA #<PALETTE_RAM
	STA PPUADDR
	TAX
@PalettesLoop:
	LDA iPals, X
	AND #COLOR_INDEX
	STA PPUDATA
	INX
	CPX #PALETTE_RAM_SPAN
	BCC @PalettesLoop
	JMP UpdateGFXAttributes
@PalettesQuit:
	RTS

@DMA:
	LDA #>iVirtualOAM
	STA OAM_DMA
	RTS

@Map:
	RTS

@Tiles:
	JMP UpdateBackground

@OAM:
	RTS

@JoyPad:
	JMP UpdateJoypads

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

	; Enable PRG RAM writing
	; Enable writable MMC5 exclusive RAM
	LDA #2
	STA MMC5_PRGRAMProtect1
	STA MMC5_ExtendedRAMMode
	LDA #1
	STA MMC5_PRGRAMProtect2

	; Set nametable mapping
	LDA #%01010000
	STA MMC5_NametableMapping

	LDA #RAM_Scratch
	STA zRAMBank
	STA MMC5_CHRBankSwitchUpper

	; MMC5 Pulse channels
	LDA #1 << CHAN_3 | 1 << CHAN_2 | 1 << CHAN_1 | 1 << CHAN_0
	STA MMC5_SND_CHN

	LDA #0
	STA MMC5_CHRBankSwitch4
	STA zCHRWindow0
	LDA #1
	STA MMC5_CHRBankSwitch8
	STA MMC5_CHRBankSwitch12
	STA zCHRWindow1

	LDA #PRG_Start0
	STA MMC5_PRGBankSwitch2
	STA zWindow1
	STA zCurrentWindow
	LDA #PRG_Start1
	STA MMC5_PRGBankSwitch3
	STA zWindow2
	STA zCurrentWindow + 1
	LDA #PRG_Start2
	STA MMC5_PRGBankSwitch4
	STA zWindow3
	STA zCurrentWindow + 2
	LDA #PRG_Home
	STA MMC5_PRGBankSwitch5
	STA zWindow4
	STA zCurrentWindow + 3
	STA zBackupWindow + 3

	SEI
	CLD
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite0000
; PPUCtrl_Background0000
; PPUCtrl_SpriteSize8x8
; PPUCtrl_NMIDisabled
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
	JSR InitSound
	; audio interfaces preserve all registers
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
