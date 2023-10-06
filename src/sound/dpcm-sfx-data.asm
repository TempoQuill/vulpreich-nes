; define a DPCM address
MACRO dmc_sfx address
	.db (address & %0011111111000000) >> 6
ENDM

DMCStartTable:
	dmc_sfx $c000 ; exclamation
	dmc_sfx $cb00
	dmc_sfx $d600
	dmc_sfx $c480 ; cursor
	dmc_sfx $cf80
	dmc_sfx $c000
	dmc_sfx $c580 ; select
	dmc_sfx $d080
	dmc_sfx $da80
	dmc_sfx $c000 ; emote 1
	dmc_sfx $d400
	dmc_sfx $c100
	dmc_sfx $c000 ; emote 2
	dmc_sfx $c540
	dmc_sfx $c800
	dmc_sfx $c740 ; emote 3
	dmc_sfx $ccc0
	dmc_sfx $c000
	dmc_sfx $cec0 ; emote 4
	dmc_sfx $dac0
	dmc_sfx $d800
	dmc_sfx $d740 ; emote 5
	dmc_sfx $d440
	dmc_sfx $cb00
	dmc_sfx $dcc0 ; percussion
	dmc_sfx $dd40
	dmc_sfx $de00
	dmc_sfx $dfff ; nothing
	dmc_sfx $dfff
	dmc_sfx $dfff

DMCLengthTable:
	.db $46, $45, $45 ; exclamation
	.db $0d, $0d, $0d ; cursor
	.db $57, $57, $57 ; select
	.db $74, $8c, $70 ; emote 1
	.db $54, $78, $ff ; emote 2
	.db $76, $75, $af ; emote 3
	.db $87, $51, $2b ; emote 4
	.db $7a, $69, $8c ; emote 5
	.db $07, $09, $09 ; percussion
	.db $03, $03, $03 ; nothing

DMCBankTable:
	audio_bank PRG_DPCM0 ; exclamation
	audio_bank PRG_DPCM0
	audio_bank PRG_DPCM0
	audio_bank PRG_DPCM0 ; cursor
	audio_bank PRG_DPCM0
	audio_bank PRG_DPCM1
	audio_bank PRG_DPCM0 ; select
	audio_bank PRG_DPCM0
	audio_bank PRG_DPCM0
	audio_bank PRG_DPCM3 ; emote 1
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM1
	audio_bank PRG_DPCM4 ; emote 2
	audio_bank PRG_DPCM4
	audio_bank PRG_DPCM1
	audio_bank PRG_DPCM3 ; emote 3
	audio_bank PRG_DPCM4
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM3 ; emote 4
	audio_bank PRG_DPCM1
	audio_bank PRG_DPCM1
	audio_bank PRG_DPCM3 ; emote 5
	audio_bank PRG_DPCM4
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM2 ; percussion
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM2 ; nothing
	audio_bank PRG_DPCM2
	audio_bank PRG_DPCM2

DMCPitchTable:
	.db $f, $f, $f ; exclamation
	.db $f, $f, $f ; cursor
	.db $f, $f, $f ; select
	.db $f, $f, $e ; emote 1
	.db $f, $f, $d ; emote 2
	.db $f, $f, $e ; emote 3
	.db $f, $f, $e ; emote 4
	.db $f, $f, $e ; emote 5
	.db $e, $f, $a ; percussion
	.db $0, $0, $0 ; nothing
