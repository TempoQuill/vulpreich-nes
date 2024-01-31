InitOptionsMenu:
	JSR InitPPU_FullScreenUpdate
	LDX #MUSIC_NONE
	STX zMusicQueue
	LDX #1
	STX zPalFade
	STX zPalFadeSpeed
	JSR TitleScreenPaletteAndNameTableSetup
	JSR InitOptionsMenuData

	LDY #TitldNTInitData_END - TitldNTInitData

@StringLoop:
	LDA TitldNTInitData, Y
	STA iStringBuffer, Y
	DEY
	BPL @StringLoop
	; we can enable graphical updates now
	LDA zPPUCtrlMirror
	ORA #PPU_NMI
	STA zPPUCtrlMirror
	STA rCTRL
	JSR SetUpStringBuffer

	LDY #>wOptionsData
	STY zPPUDataBufferPointer + 1
	LDY #<wOptionsData
	STY zPPUDataBufferPointer

	LDA #1
	JSR DelayFrame_s_

	JSR ShowNewScreen
	JMP AutomaticFadeIn

OptionsRoutine:
	JSR InitOptionsMenu
	JMP RunOptions

InitOptionsMenuData:
	LDA #MUSIC_F
	STA zAudioFlagPointer
	LDX #wOptionsDataEnd - wOptionsData - 1
@LayoutLoop:
	LDA OptionsLayout, X
	STA wOptionsData, X
	DEX
	BPL @LayoutLoop
	LDA #"0"
	LDX #3
@AudioBCDLoop:
	DEX
	STA wOptionsMusicBCD, X
	STA wOptionsSFXBCD, X
	BNE @AudioBCDLoop
	LDX #wOptionsRealTimeBCDEnd - wOptionsRealTimeBCD - 1
@RealTimeLoop:
	LDA OptionsBCDArea, X
	STA wOptionsRealTimeBCD, X
	DEX
	BPL @RealTimeLoop
	LDX #wOptionsDynamicAttributesEnd - wOptionsDynamicAttributes - 1
@ODALoop:
	LDA OptionsDynamicAttributeData, X
	STA wOptionsDynamicAttributes, X
	DEX
	BPL @ODALoop
	LDA #0
	STA zOptionNumber
	STA zOptionNumberSelectedCPL
	LDA #3
	STA zNumBCDDigits
	LDA #$1b
	STA zCursorYPos
	LDA #$18
	STA zCursorXPos
	RTS

RunOptions:
	JSR RunCursor_Title
	JSR TryOptionsInput
	LDA zOptionNumberSelectedCPL
	CMP #OPTION_BACK_TO_TITLE ^ $ff
	LDA #1
	JSR DelayFrame_s_
	JMP RunOptions

OptionsCursorYPositions:
	.db $1b ; audio
	.db $2b ; cutscenes
	.db $3b ; text
	.db $4b ; prices
	.db $7b ; music
	.db $8b ; sound effects
	.db $9b ; back to title screen

BasicOptionsInput:
	LDA zOptionNumberSelectedCPL
	BPL @NoSuboption
	SEC
@NoInput:
	RTS

@NoSuboption:
; x:
; 0 - no valid input
; 1 - up
; 2 - down
; 3 - b
; 4 - a / start
	LDX #0
	LDY zInputBottleNeck
	BEQ @NoInput
	INX
	TYA
	TSB UP_BUTTON
	BNE @Ready
	INX
	TYA
	TSB DOWN_BUTTON
	BNE @Ready
	INX
	TYA
	TSB B_BUTTON
	BNE @Ready
	INX
	TYA
	AND #1 << A_BUTTON | 1 << START_BUTTON
	BNE @Ready
	LDX #0
@Ready:
	CLC
	RTS

TryOptionsInput:
	JSR BasicOptionsInput
	BCC @NoSuboption
	JSR SubOptionInput
	JMP InterpretSubOptionInput
@NoSuboption:
	TXA
	BEQ @Nothing
	DEX
	BEQ @Up
	DEX
	BEQ @Down
	DEX
	BEQ @B
	DEX
	BEQ @AStart
@Nothing:
	RTS

@Up:
	LDY #SFX_CURSOR_1
	JSR PlaySFX
	LDA zOptionNumber
	BEQ @NoDec
	DEC zOptionNumber
@NoDec:
	RTS

@Down:
	LDY #SFX_CURSOR_1
	JSR PlaySFX
	LDA #5
	CMP zOptionNumber
	BCC @NoInc
	INC zOptionNumber
@NoInc:
	RTS

@B:
	LDY #SFX_SELECT_1
	JSR PlaySFX
	LDA #OPTION_BACK_TO_TITLE
	FAB
	STA zOptionNumberSelectedCPL
	RTS

@AStart:
	LDY #SFX_SELECT_1
	JSR PlaySFX
	LDA zOptionNumber
	FAB
	STA zOptionNumberSelectedCPL
	RTS

SubOptionInput:
; x:
; 0 - no valid input
; 1 - up (0, 3-5)
; 2 - down (0, 3-5)
; 3 - left (0-2, 4, 5)
; 4 - right (0-2, 4, 5)
; 5 - b (0-5)
; 6 - a (4, 5)
	LDX #0
	LDY zInputBottleNeck
	BEQ @Ready
	INX
	TYA
	TSB UP_BUTTON
	BNE @Ready
	INX
	TYA
	TSB DOWN_BUTTON
	BNE @Ready
	INX
	TYA
	TSB LEFT_BUTTON
	BNE @Ready
	INX
	TYA
	TSB RIGHT_BUTTON
	BNE @Ready
	INX
	TYA
	TSB B_BUTTON
	BNE @Ready
	INX
	TYA
	TSB A_BUTTON
	BNE @Ready
	LDX #0
@Ready:
	RTS

InterpretSubOptionInput:
	LDA SubOptionsInputPointersHI, X
	PHA
	LDA SubOptionsInputPointersLO, X
	PHA
	RTS

SubOptionsInputPointersLO:
	dl (SOIP_None - 1)
	dl (SOIP_Up - 1)
	dl (SOIP_Down - 1)
	dl (SOIP_Left - 1)
	dl (SOIP_Right - 1)
	dl (SOIP_A - 1)
	dl (SOIP_B - 1)

SubOptionsInputPointersHI:
	dh (SOIP_None - 1)
	dh (SOIP_Up - 1)
	dh (SOIP_Down - 1)
	dh (SOIP_Left - 1)
	dh (SOIP_Right - 1)
	dh (SOIP_A - 1)
	dh (SOIP_B - 1)

SOIP_B:
SOIP_A:
SOIP_Up:
	LDA zOptionNumber
	CMP #OPTION_CUTSCENES
	BEQ SOIP_None
	CMP #OPTION_TEXT_SPEED
	BEQ SOIP_None
	CMP #OPTION_BACK_TO_TITLE
	BCS SOIP_None
	JMP HandleSubOptionUpPress

SOIP_Down:
	LDA zOptionNumber
	CMP #OPTION_CUTSCENES
	BEQ SOIP_None
	CMP #OPTION_TEXT_SPEED
	BEQ SOIP_None
	CMP #OPTION_BACK_TO_TITLE
	BCS SOIP_None
	JMP HandleSubOptionDownPress

SOIP_Left:
	LDA zOptionNumber
	CMP #OPTION_PRICE_SETTING
	BEQ SOIP_None
	CMP #OPTION_BACK_TO_TITLE
	BCS SOIP_None
	JMP HandleSubOptionLeftPress

SOIP_Right:
	LDA zOptionNumber
	CMP #OPTION_PRICE_SETTING
	BEQ SOIP_None
	CMP #OPTION_BACK_TO_TITLE
	BCS SOIP_None
	JMP HandleSubOptionRightPress

SOIP_None:
	RTS

HandleSubOptionUpPress:
; 0 - Audio Flags - Turn on flag according to pointer
; 1 - Prices      - Deflate
; 2 - Music       - Subtract ten from music ID pointer
; 3 - SFX / VFX   - Subtract ten from SFX/VFX ID pointer
	LDA zOptionNumber
	BEQ @AudioFlags
	CMP #OPTION_MUSIC_TEST
	BCC @Prices
	BEQ @Music
@SFXVFX:
	LDX #1
@SFXVFX_Loop:
	DEC wOptionsSFXBCD, X
	BPL @Quit
	LDA wOptionsSFXBCD, X
	CLC
	ADC #10
	STA wOptionsSFXBCD, X
	INX
	CPX #3
	BCC @SFXVFX_Loop
	RTS
@AudioFlags:
	LDA zAudioFlagPointer
	ORA zOptions
	STA zOptions
	RTS
@Prices:
	LDX zOptions
	DEX
	TXA
	AND #PRICE_MOD
	BEQ @Quit
	DEC zOptions
	RTS
@Music:
	LDX #1
@Music_Loop:
	DEC wOptionsMusicBCD, X
	BPL @Quit
	LDA wOptionsMusicBCD, X
	CLC
	ADC #10
	STA wOptionsMusicBCD, X
	INX
	CPX #3
	BCC @Music_Loop
@Quit:
	RTS

HandleSubOptionDownPress:
; 0 - Audio Flags - Turn off flag according to pointer
; 1 - Prices      - Inflate
; 2 - Music       - Add ten from music ID pointer
; 3 - SFX / VFX   - Add ten from SFX/VFX ID pointer
	LDA zOptionNumber
	BEQ @AudioFlags
	CMP #OPTION_MUSIC_TEST
	BCC @Prices
	BEQ @Music
@SFXVFX:
	LDX #1
@SFXVFX_Loop:
	INC wOptionsSFXBCD, X
	LDA wOptionsSFXBCD, X
	SEC
	SBC #10
	BMI @Quit
	STA wOptionsSFXBCD, X
	INX
	CPX #3
	BCC @SFXVFX_Loop
	RTS
@AudioFlags:
	LDA zAudioFlagPointer
	FAB
	AND zOptions
	STA zOptions
	RTS
@Prices:
	LDX zOptions
	INX
	TXA
	AND #PRICE_MOD
	BEQ @Quit
	INC zOptions
	RTS
@Music:
	LDX #1
@Music_Loop:
	INC wOptionsMusicBCD, X
	LDA wOptionsMusicBCD, X
	SEC
	SBC #10
	BMI @Quit
	STA wOptionsMusicBCD, X
	INX
	CPX #3
	BCC @Music_Loop
@Quit:
	RTS

HandleSubOptionLeftPress:
; 0 - Audio Flags - Rotate bit pointer left
; 1 - Cutscenes   - Turn on
; 2 - Text Speed  - Decrease text frame counter
; 3 - Music       - Subtract one from music ID pointer
; 4 - SFX / VFX   - Subtract one from SFX/VFX ID pointer
	CMP #OPTION_CUTSCENES
	BCC @AudioFlags
	BEQ @Cutscene
	CMP #OPTION_MUSIC_TEST
	BCC @TextSpeed
	BEQ @Music
@SFXVFX:
	LDX #0
@SFXVFX_Loop:
	DEC wOptionsSFXBCD, X
	BPL @Quit
	LDA wOptionsSFXBCD, X
	CLC
	ADC #10
	STA wOptionsSFXBCD, X
	INX
	CPX #3
	BCC @SFXVFX_Loop
	RTS
@AudioFlags:
	LDA zAudioFlagPointer
	ROL A
	CMP #VFX_F
	BCC @Quit
	ROR zAudioFlagPointer
	RTS
@Cutscene:
	LDA zOptions
	ORA #CUTSCENES_F
	STA zOptions
	RTS
@TextSpeed:
	LDA zOptions
	AND #TEXT_SPEED
	BNE @Quit
	LDA zOptions
	SEC
	SBC #4
	STA zOptions
	RTS
@Music:
	LDX #0
@Music_Loop:
	DEC wOptionsMusicBCD, X
	BPL @Quit
	LDA wOptionsMusicBCD, X
	CLC
	ADC #10
	STA wOptionsMusicBCD, X
	INX
	CPX #3
	BCC @Music_Loop
@Quit:
	RTS

HandleSubOptionRightPress:
; 0 - Audio Flags - Rotate bit pointer right
; 1 - Cutscenes   - Turn off
; 2 - Text Speed  - Increase text frame counter
; 3 - Music       - Add one to music ID pointer
; 4 - SFX / VFX   - Add one to SFX/VFX ID pointer
	CMP #OPTION_CUTSCENES
	BCC @AudioFlags
	BEQ @Cutscene
	CMP #OPTION_MUSIC_TEST
	BCC @TextSpeed
	BEQ @Music
@SFXVFX:
	LDX #0
@SFXVFX_Loop:
	INC wOptionsSFXBCD, X
	LDA wOptionsSFXBCD, X
	SEC
	SBC #10
	BMI @Quit
	STA wOptionsSFXBCD, X
	INX
	CPX #3
	BCC @SFXVFX_Loop
	RTS
@AudioFlags:
	LDA zAudioFlagPointer
	ROR A
	CMP #VFX_F
	BCC @Quit
	ROR zAudioFlagPointer
	RTS
@Cutscene:
	LDA zOptions
	AND #$ff ^ CUTSCENES_F
	STA zOptions
	RTS
@TextSpeed:
	LDA zOptions
	CLC
	ADC #4
	AND #TEXT_SPEED
	BNE @Quit
	LDA zOptions
	CLC
	ADC #4
	STA zOptions
	RTS
@Music:
	LDX #0
@Music_Loop:
	INC wOptionsMusicBCD, X
	LDA wOptionsMusicBCD, X
	SEC
	SBC #10
	BMI @Quit
	STA wOptionsMusicBCD, X
	INX
	CPX #3
	BCC @Music_Loop
@Quit:
	RTS
