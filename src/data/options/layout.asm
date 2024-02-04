OptionsLayout:
	text $2045, "Options:"
	text $2085, "Audio:  Music   SFX   VFX"
	text $20c5, "Cutscenes: On  Off"
	text $2105, "Text:  1&  2&  3&"
	text $2145, "Prices:Affordable"
	text $218c, "Normal"
	text $21cc, "Expensive"
	text $2205, "Music:"
	text $2212, "---"
	text $2245, "Sound/Vocals:---"
	text $2285, "Back to title screen"
	.db $23, $c1, $03
	.db      $f0, $f0, $30
	.db $23, $c9, $0d
	.db      $55, $55, $30, $0c, $af, $0a, $0f
	.db $00, $55, $51, $a2, $a0, $22
	.db $23, $db, $14
	.db                $a0, $a0, $20, $00, $00
	.db $00, $55, $55, $50, $50, $aa, $00, $00
	.db $00, $0f, $0f, $0f, $0f, $0f

OptionsCheckMarks:
	.db $20, $92, $01, $1e
	.db $20, $96, $01, $1e
	.db $20, $9e, $01, $1e
	.db $00

OptionsDynamicAttributeData:
	.db $23, $cb, $05
	.db                $10, $0c, $af, $0a, $0f

	.db $23, $db, $03
	.db                $a0, $a0, $20
	.db $23, $d3, $03
	.db                $a2, $a0, $22

	.db $23, $e5, $01
	.db                          $aa

OptionsBCDArea:
	text $2214, "000"
	text $2254, "000"
	text_end

ODAD_Row2Data:
	.db $30, $0c, $af, $0a, $0f ; Music / Cutscenes on
	.db $30, $2c, $0f, $0a, $0f ; Music / Cutscenes off
	.db $3a, $0e, $ac, $0a, $0f ; SFX / Cutscenes on
	.db $3a, $2e, $0c, $0a, $0f ; SFX / Cutscenes off
	.db $3a, $0e, $af, $0a, $00 ; VFX / Cutscenes on
	.db $3a, $2e, $0f, $0a, $00 ; VFX / Cutscenes off

ODAD_Row3Data:
	.db $00, $02, $02 ; Text on 1's / Prices == Affordable
	.db $a0, $a2, $22 ; Text on 1's / Prices =! Affordable
	.db $02, $00, $02 ; Text on 2's / Prices == Affordable
	.db $a2, $a0, $22 ; Text on 2's / Prices =! Affordable
	.db $02, $02, $00 ; Text on 3's / Prices == Affordable
	.db $a2, $a2, $20 ; Text on 3's / Prices =! Affordable

ODAD_Row4Data:
	.db $aa, $a2, $20 ; Prices: Affordable
	.db $a0, $a0, $20 ; Prices: Normal
	.db $0a, $02, $00 ; Prices: Expensive

ODAD_Row5Data:
	.db $aa ; Not Testing Audio
	.db $a0 ; Music Test
	.db $0a ; Sound/Vocal Effects Test
