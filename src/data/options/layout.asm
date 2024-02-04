OptionsLayout:
	text $2045, "Options:"
	text $2085, "Audio:  Music   SFX   VFX"
	text $20c5, "Cutscenes: On  Off"
	text $2105, "Text:  1&  2&  3&"
	text $2145, "Prices:Affordable"
	text $218c, "Normal"
	text $21cc, "Expensive"
	text $2205, "Music:"
	text $2214, "---"
	text $2245, "Sound/Vocals:  ---"
	text $2285, "Back to title screen"
OptionsCheckMarks:
	.db $20, $92, $01, $1e
	.db $20, $98, $01, $1e
	.db $20, $9e, $01, $1e
	attribute $2045, f0f030
	attribute $2085, 5555500caa0b0e005551a2a022
	attribute $218c, a0a02000000055555050aa0000000f0f0f0f0f03

	.db $00

OptionsDynamicAttributeData:
	attribute $208c, 100cae0a03
	.db $00

	attribute $218c, a0a020
	attribute $210c, a2a022
	.db $00

	attribute $2214, aa

OptionsBCDArea:
	text $2214, "000"
	text $2254, "000"
	text_end

ODAD_Row2Data:
	; 500caa0b0e
	hex 500caa0b0e ; Music / Cutscenes on
	hex 502c0a0b0e ; Music / Cutscenes off
	hex 5a0ea00b0e ; SFX / Cutscenes on
	hex 5a2e000b0e ; SFX / Cutscenes off
	hex 5a0eaa030c ; VFX / Cutscenes on
	hex 5a2e0a030c ; VFX / Cutscenes off

ODAD_Row3Data:
	; a2a022
	hex 000202 ; Text on 1's / Prices == Affordable
	hex a0a222 ; Text on 1's / Prices =! Affordable
	hex 020002 ; Text on 2's / Prices == Affordable
	hex a2a022 ; Text on 2's / Prices =! Affordable
	hex 020200 ; Text on 3's / Prices == Affordable
	hex a2a220 ; Text on 3's / Prices =! Affordable

ODAD_Row4Data:
	; a0a020
	hex aaa220 ; Prices: Affordable
	hex a0a020 ; Prices: Normal
	hex 0a0200 ; Prices: Expensive

ODAD_Row5Data:
	.db $aa ; Not Testing Audio
	.db $a0 ; Music Test
	.db $0a ; Sound/Vocal Effects Test
