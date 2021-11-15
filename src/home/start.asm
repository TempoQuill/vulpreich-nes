
UpdatePRG:
	LDA RAMBank
	STA MMC5_PRGBankSwitch1
	LDA Window1
	STA MMC5_PRGBankSwitch2
	LDA Window2
	STA MMC5_PRGBankSwitch3
	LDA Window3
	STA MMC5_PRGBankSwitch4
	LDA Window4
	STA MMC5_PRGBankSwitch5
	RTS

UpdateCHR:
; This updates all the needed registers.
; 1024K only modes 0 and 1 can access the entire ROM with base registers
; 512K modes 0, 1 and 2 can access the entire ROM with base registers
; 256K all 4 modes 0-3 can access the entire ROM with base registers
	LDA CHRWindow0
	STA MMC5_CHRBankSwitch4 ; 0000-0fff

	LDA CHRWindow1
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

UpdateJoypads_DoubleCheck:
	; Work around DPCM sample bug,
	; where some spurious inputs are read
	LDY InputBottleNeck
	JSR ReadJoypads

	CPY InputBottleNeck
	BNE UpdateJoypads_DoubleCheck

	LDX #$01

UpdateJoypads_Loop:
	LDA InputBottleNeck, X ; Update the press/held values
	TAY
	EOR InputCurrentState, X
	AND InputBottleNeck, X
	STA InputBottleNeck, X
	STY InputCurrentState, X
	DEX
	BPL UpdateJoypads_Loop

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
ReadJoypadLoop:
	LDA JOY1
	LSR A
	; Read D0 standard controller data
	ROL InputBottleNeck

	LDA JOY2
	LSR A
	ROL InputBottleNeck + 1 ; player 2
	DEX
	BNE ReadJoypadLoop

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
	STA PPUCtrlMirror
	JSR InitSound
	LDY #0 ; MUSIC_NONE
	JSR PlayMusic
Start_Loop:
	JMP Start_Loop
;
; NMI logic for during a transition
;
NMI_Transition:
	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAM_DMA
	JSR UpdateCHR

	LDA PPUMaskMirror
	STA PPUMASK
	JSR NMI_DoSoundProcessing

	LDA PPUCtrlMirror
	STA PPUCTRL
	DEC NMIWaitFlag
	JMP NMI_Exit

;
; NMI logic for during the pause menu
;
NMI_PauseOrMenu:
	LDA #$00
	STA PPUMASK
	STA OAMADDR
	LDA #$02
	STA OAM_DMA
	JSR UpdateCHR

	JSR UpdatePPUFromBufferWithOptions

	JSR ResetPPUAddress

	LDA PPUScrollXMirror
	STA PPUSCROLL
	LDA #$00
	STA PPUSCROLL
	LDA PPUMaskMirror
	STA PPUMASK
	JMP NMI_CheckScreenUpdateIndex


; When waiting for an NMI, just run the audio engine
;
NMI_Waiting:
	LDA PPUMaskMirror
	STA PPUMASK
	JMP NMI_DoSoundProcessing
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
; The NMI is actually separated into several distinct behaviors depending on the
; game state, as dictated by flags in stack `$100`.
;
; For normal gameplay, here is the general flow of the NMI:
;
;  1. Push registers and processor flags so that we can restore them later.
;  2. Check to see whether we're in a menu or transitioning. If so, use those
;     divert to that code instead.
;  3. Hide the sprites/background and update the sprite OAM.
;  4. Load the current CHR banks.
;  5. Check the `NMIWaitFlag`. If it's nonzero, restore `PPUMASK` and skip to
;     handling the sound processing.
;  6. Handle any horizontal or vertical scrolling tile updates.
;  7. Update PPU using the current screen update buffer.
;  8. Write PPU control register, scroll position, and mask.
;  9. Increment the global frame counter.
; 10. Reset PPU buffer if we just used it for the screen update.
; 11. Read joypad input.
; 12. Decrement `NMIWaitFlag`, unblocking any code that was waiting for the NMI.
; 13. Run the audio engine.
; 14. Restore registers and processor flags, yield back to the game loop.
;
; The game loop is synchronized with rendering using `JSR WaitForNMI`, which
; sets `NMIWaitFlag` to `$00` until the NMI completes and decrements it.
;
NMI:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA

	BIT StackBottom
	BPL NMI_PauseOrMenu ; branch if bit 7 was 0

	BVC NMI_Transition ; branch if bit 6 was 0

	LDA #$00
	STA PPUMASK
	STA OAMADDR
	LDA #$02
	STA OAM_DMA

	JSR UpdateCHR

NMI_CheckWaitFlag:
	LDA NMIWaitFlag
	BNE NMI_Waiting
NMI_Gameplay:
UpdatePPUFromBufferNMI:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCTRL
	LDY #$00

UpdatePPUFromBufferNMI_CheckForBuffer:
	LDA (RAM_PPUDataBufferPointer), Y
	BEQ PPUBufferUpdatesComplete

	LDX PPUSTATUS
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	TAX

UpdatePPUFromBufferNMI_CopyLoop:
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	STA PPUDATA
	DEX
	BNE UpdatePPUFromBufferNMI_CopyLoop

	INY
	JMP UpdatePPUFromBufferNMI_CheckForBuffer

PPUBufferUpdatesComplete:

	JSR ResetPPUAddress

	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	ORA PPUScrollXHiMirror

	STA PPUCTRL
	STA PPUCtrlMirror
	LDA PPUScrollXMirror
	STA PPUSCROLL
	LDA PPUScrollYMirror
	CLC
	ADC BackgroundYOffset
	STA PPUSCROLL
	LDA PPUMaskMirror
	STA PPUMASK
	INC GlobalFrameCounter
NMI_CheckScreenUpdateIndex:
	LDA ScreenUpdateIndex
	BNE NMI_ResetScreenUpdateIndex

	STA PPUBuffer
	STA PPUBuffer + 1

NMI_ResetScreenUpdateIndex:
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
	JSR UpdateJoypads
	DEC NMIWaitFlag
NMI_DoSoundProcessing:
	JSR UpdateSound
NMI_Exit:
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTI

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
	STA RAMBank
	STA MMC5_CHRBankSwitchUpper

	; MMC5 Pulse channels
	LDA #$0f
	STA MMC5_SND_CHN

	LDA #PRG_Start0
	STA Window1
	LDA #PRG_Start1
	STA Window2
	LDA #PRG_Start2
	STA Window3
	LDA #PRG_Home
	STA Window4
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

@Loop:
	; clear RAM
	DEX
	STA $0, X ; internal RAM
	STA $200, X
	STA $300, X
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
	BEQ @Next
	JMP @Loop
@Next:
	JMP Start

IRQ:
	RTI

.pad $fff1, $00
; title of the game, fff1
	.db "VULPREICH"

NESVectorTables:
	.dw NMI   ; runs every frame
	.dw RESET ; boots up the game
	.dw IRQ   ; dummied out
