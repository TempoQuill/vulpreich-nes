UpdatePRG:
	LDA zWindow1
	STA MMC5_PRGBankSwitch2
	LDA zWindow2
	STA MMC5_PRGBankSwitch3
	LDA zWindow3
	STA MMC5_PRGBankSwitch4
	LDA zWindow4
	STA MMC5_PRGBankSwitch5
	RTS

UpdateCHR:
; This updates all the needed registers.
; 1024K only modes 0 and 1 can access the entire ROM with base registers
; 512K modes 0, 1 and 2 can access the entire ROM with base registers
; 256K all 4 modes 0-3 can access the entire ROM with base registers
	LDA zCHRWindow0
	STA MMC5_CHRBankSwitch4 ; 0000-0fff

	LDA zCHRWindow1
	STA MMC5_CHRBankSwitch8  ; 1000-1fff
	STA MMC5_CHRBankSwitch12 ; 1000-1fff, 0000-0fff

	RTS

ResetPPUAddress:
	LDA PPUSTATUS
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	STA PPUADDR
	STA PPUADDR
	RTS
;
; Updates joypad press/held values
;
UpdateJoypads:
	JSR ReadJoypads

@DoubleCheck:
	; Work around DPCM sample bug,
	; where some spurious inputs are read
	LDY zInputBottleNeck
	JSR ReadJoypads

	CPY zInputBottleNeck
	BNE @DoubleCheck

	LDX #$01

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
	LDX #$01
	STX JOY1
	DEX
	STX JOY1

	LDX #$08
@Loop:
	LDA JOY1
	LSR A
	; Read standard controller data
	ROL zInputBottleNeck

	LDA JOY2
	LSR A
	ROL zInputBottleNeck + 1 ; player 2
	DEX
	BNE @Loop

	RTS

Start:
	LDA #$00
	STA PPUMASK
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite0000
; PPUCtrl_Background1000
; PPUCtrl_SpriteSize8x16
; PPUCtrl_NMIDisabled
	LDA #$30
	STA PPUCTRL
	STA zPPUCtrlMirror
	LDY #MUSIC_NONE
	JSR PlayMusic
	JMP GameInit
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
; 0: scroll
; 1: map buffer
; 2: palettes
; 3: dma
; 4: map
; 5: tiles
; 6: oam
; 7: joypad
; 8: sound
; 9: additional stuff
NMI:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

	JSR @Scroll
	JSR @MapBuffer
	JSR @Palettes
	JSR @DMA
	JSR @Map
	JSR @Tiles
	JSR @OAM
	JSR @JoyPad
	JSR UpdateSound

	; special functions
	LDA zNMIState

	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTI

@Scroll:
	LDA zNMIState
	CMP #2
	BEQ @ScrollQuit
	CMP #4
	BEQ @ScrollQuit
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
	BNE @ScrollQuit
@ScrollQuit:
	RTS

@MapBuffer:
	LDA zNMIState
	BNE @MapBufferQuit
	RTS
@MapBufferQuit:
	RTS

@Palettes:
	LDA zNMIState
	CMP #2
	BEQ @PalettesQuit
	CMP #4
	BEQ @PalettesQuit
	LDA #$3f ; palette RAM hi
	STA PPUADDR
	LDA #$0 ; palette RAM lo
	STA PPUADDR
	TAX
@PalettesLoop:
	LDA iPals, x
	STA PPUDATA
	INX
	CPX #$20
	BCC @PalettesLoop
@PalettesQuit:
	RTS

@DMA:
	LDA zNMIState
	BNE @DMAQuit
	LDA #>iVirtualOAM
	STA OAM_DMA
@DMAQuit:
	RTS

@Map:
	LDA zNMIState
	CMP #2
	BEQ @MapQuit
	RTS
@MapQuit:
	RTS

@Tiles:
	LDA zNMIState
	CMP #2
	BEQ @TilesQuit
	RTS
@TilesQuit:
	RTS

@OAM:
	LDA zNMIState
	CMP #2
	BEQ @OAMQuit
	CMP #5
	BEQ @OAMQuit
	RTS
@OAMQuit:
	RTS

@JoyPad:
	LDA zNMIState
	CMP #2
	BEQ @JoyPadQuit
	CMP #3
	BEQ @JoyPadQuit
	JSR UpdateJoypads
@JoyPadQuit:
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

	LDA #$0
	STA zRAMBank
	STA MMC5_CHRBankSwitchUpper

	; MMC5 Pulse channels
	LDA #$0f
	STA MMC5_SND_CHN

	LDA #PRG_Start0
	STA zWindow1
	LDA #PRG_Start1
	STA zWindow2
	LDA #PRG_Start2
	STA zWindow3
	LDA #PRG_Home
	STA zWindow4
	JSR UpdatePRG

	SEI
	CLD
; PPUCtrl_Base2000
; PPUCtrl_WriteHorizontal
; PPUCtrl_Sprite0000
; PPUCtrl_Background0000
; PPUCtrl_SpriteSize8x8
; PPUCtrl_Background0000
; PPUCtrl_NMIDisabled
	LDA #$00
	STA PPUCTRL
	LDX #$FF ; Reset stack pointer
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
@Loop:
	; clear RAM
	DEX
	STA $0, X ; internal RAM
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
@Next:
	JMP Start

IRQ:
	RTI

.pad $fff1, $00
UnreferencedTitle:
; title of the game, fff1
	ascii "VULPREICH"

NESVectorTables:
	.dw NMI   ; runs every frame
	.dw RESET ; boots up the game
	.dw IRQ   ; dummied out
