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
	JSR TryOptionsInput
	LDA zOptionNumberSelectedCPL
	CMP #OPTION_BACK_TO_TITLE ^ $ff
	BEQ @Quit
	JSR UpdateOptions
	JSR RunCursor_Title
	LDA #1
	JSR DelayFrame_s_
	BEQ RunOptions
@Quit:
	LDA #2
	STA zPalFadeSpeed
	STA zPalFade
	LDA zPals
	ORA #1 << PAL_FADE_F | 1 << PAL_FADE_DIR_F
	STA zPals
@CheckPal:
	LDY zPals + 15
	CPY #$f
	BEQ @Terminal
	LDA #1
	JSR DelayFrame_s_
	BEQ @CheckPal
	; aaaand JUMP!
	JMP IntroSequence_TitleOnly

OptionsCursorYPositions:
	.db $1b ; audio
	.db $2b ; cutscenes
	.db $3b ; text
	.db $4b ; prices
	.db $7b ; music
	.db $8b ; sound effects / voice effects
	.db $9b ; back to title screen

UpdateOptions:
;object/pal.	RAM
;cursor		zOptionNumber v
;	zCursorYPos <- OptionsCursorYPositions
	LDX zOptionNumber
	LDA OptionsCursorYPositions, Y
	STA zCursorYPos
;audio pal.	zAudioFlagPointer v
;		wODARow2 <- ODAD_Row2Data
;cutscenes	zOptions.4 v
;	wODARow2 <- ODAD_Row2Data
	LDX #0
	LDY #wODARow2_END - wODARow2
	LDA zOptions
	AND #OPTION_CUTSCENES
	BEQ @CutscenesOn
	TYA
	TAX
	DEY
@CutscenesOn:
	LDA zAudioFlagPointer
	STA zTempAudioFlagPointer
	TXA
	LDX zTempAudioFlagPointer
	BMI @DoAudioPalette
	CLC
	ADC #(wODARow2_END - wODARow2) * 2
	LSR zTempAudioFlagPointer
	BMI @DoAudioPalette
	ADC #(wODARow2_END - wODARow2) * 2
@DoAudioPalette:
	TAX
	DEX
@AudioCutscenAttrLoop:
	LDA ODAD_Row2Data, X
	STA wODARow2, Y
	DEX
	DEY
	BPL @AudioCutscenAttrLoop
;audio tiles	zOptions.5-zOptions.7 v
;	wOptionsCheckTile1/2/3 <- tile_1e/tile_1f
	LDA zOptions
	AND #AUDIO_MASK
	STA zTempAudioFlagPointer
	JSR GenerateCheckTile
	STA wOptionsCheckTile1
	JSR GenerateCheckTile
	STA wOptionsCheckTile2
	JSR GenerateCheckTile
	STA wOptionsCheckTile3
;text speed	zOptions.2-zOptions.3 v
;		wODARow3 <- ODAD_Row3Data
;prices		zOptions.0-zOptions.1 v
;	wODARow3/4 <- ODAD_Row3Data/ODAD_Row4Data
	LDX #2
	LDA zOptions
	AND #TEXT_SPEED	; &$0c
	LSR A		; &$06
	LSR A		; &$03
	TAY
	LDA #0
	ADC TextSpeedPricesROMOffsets_Speed, Y
	PHA
	LDA zOptions
	AND #PRICE_MOD
	TAY
	PLA
	ADC TextSpeedPricesROMOffsets_Prices, Y
	TAY
@PriceSpeedLoop:
	LDA ODAD_Row3Data, Y
	STA wODARow3, X
	DEY
	DEX
	BPL @PriceSpeedLoop
	LDX #2
	LDA zOptions
	AND #PRICE_MOD
	TAY
	LDA PricesROMOffset, Y
	TAY
@PriceLoop:
	LDA ODAD_Row4Data, Y
	STA wODARow4, X
	DEY
	DEX
	BPL @PriceLoop
;music ID	zOptionNumber v
;	wODARow5 <- ODAD_Row5Data
;sfx/vfx ID	zOptionNumber v
;	wODARow5 <- ODAD_Row5Data
	LDY zOptionNumber
	LDA AudioTestROMOffset, Y
	TAY
	LDA ODAD_Row5Data, Y
	STA wODARow5
	; now it's time to update zPPUDataBufferPointer
	; first, is option 0 selected
	LDX zOptionNumberSelectedCPL
	INX
	BEQ @PPUOffset
	LDA zInputBottleNeck
	AND #1 << A_BUTTON | 1 << START_BUTTON
	BEQ @PPUOffset
	LDA #<wOptionsCheckMarkArea
	STA zPPUDataBufferPointer
	LDA #>wOptionsCheckMarkArea
	STA zPPUDataBufferPointer + 1
	RTS
@PPUOffset:
	LDA #<wODARow2
	STA zPPUDataBufferPointer
	LDA #>wODARow2
	STA zPPUDataBufferPointer + 1
	RTS

TextSpeedPricesROMOffsets_Speed:
	.db 2
	.db 8
	.db 14
TextSpeedPricesROMOffsets_Prices:
	.db 2
	.db 5
	.db 5

PricesROMOffset:
	.db 2
	.db 5
	.db 8

AudioTestROMOffset:
	.db 0
	.db 0
	.db 0
	.db 0
	.db 1
	.db 2
	.db 0

GenerateCheckTile:
	LDA #0
	ASL zTempAudioFlagPointer
	ROL A
	ORA #1e
	RTS

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
	LDA #0
	STA zOptionNumberSelectedCPL
	RTS

SOIP_A:
	LDA zOptionNumber
	CMP #OPTION_BACK_TO_TITLE
	BCS SOIP_None
	CMP #OPTION_TEXT_SPEED
	BCC SOIP_None
	BEQ SOIP_None
	JMP HandleSubOptionAPress

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

HandleSubOptionAPress:
; 0 - Music   - Play Music
; 1 - SFX/VFX - Play Sound/Voice Effects
	; what option index?
	LDX #0
	LDA zOptionNumber
	SEC
	SBC #OPTION_MUSIC_TEST ; first valid entry
	BEQ @Music
	; if not OPTION_MUSIC_TEST, then OPTION_SFX_VFX_TEST
	LDX #wOptionsSFXBCD - wOptionsMusicBCD
@Music:
	; the x-offset seems a good solution for now
	; just focus on converting the right spot to hex
	LDA wOptionsMusicBCD + 2, X
	SBC #"0"
	TAY
	JSR @MaybeMax
	BCS @Max
	; bcd <= 255
	; add special values equivalent to 100s, 10s, 1s according to Y
	LDA #0
	ADC @Hundreds, Y
	PHA
	LDA wOptionsMusicBCD + 1, X
	SBC #"0"
	TAY
	PLA
	ADC @Tens, Y
	PHA
	LDA wOptionsMusicBCD, X
	SBC #"0"
	TAY
	PLA
	ADC @Ones, Y
@Play:
	; store the result now in Y for audio initialization
	TAY
	TXA
	BNE @SFX
	; x == 0 == zMusicQueue
	STY zMusicQueue
	RTS
@SFX:
	; x != 0
	; non-zero = PlaySFX
	JMP PlaySFX
@Max:
	LDA #$ff
	BNE @Play

@MaybeMax:
	; if BCD is > 255, make the value 255 / $ff
	LDA wOptionsMusicBCD + 2, X
	CMP #"2"
	BCC @NotMax
	BNE @IsMax
	LDA wOptionsMusicBCD + 1, X
	CMP #"5"
	BCC @NotMax
	BNE @IsMax
	LDA wOptionsMusicBCD, X
	CMP #"5"
@IsMax:
@NotMax:
	RTS

@Hundreds:
	.db 0
	.db 100
	.db 200

@Tens:
	.db 0
	.db 10
	.db 20
	.db 30
	.db 40
	.db 50
	.db 60
	.db 70
	.db 80
	.db 90

@Ones:
	.db 0
	.db 1
	.db 2
	.db 3
	.db 4
	.db 5
	.db 6
	.db 7
	.db 8
	.db 9

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
	LDA wOptionsSFXBCD, X
	CMP #"0"
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
	LDA wOptionsMusicBCD, X
	CMP #"0"
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
	CMP #"0"
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
	CMP #"0"
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
	LDA wOptionsSFXBCD, X
	CMP #"0"
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
	LDA wOptionsMusicBCD, X
	CMP #"0"
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
	CMP #"0"
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
	CMP #"0"
	BMI @Quit
	STA wOptionsMusicBCD, X
	INX
	CPX #3
	BCC @Music_Loop
@Quit:
	RTS
