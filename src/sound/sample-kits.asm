SampleKits:
	.dw SampleKit0
	.dw SampleKit1
	.dw SampleKit2
	.dw SampleKit3
	.dw SampleKit4
	.dw SampleKit5
	.dw SampleKit6 ; voice sampulz

SampleKit0:
	.dw Sample0_0 ; silence
	.dw Sample0_1 ; medium snare
	.dw Sample0_2 ; heavy kick
	.dw Sample0_3 ; light kick
	.dw Sample0_4 ; tom 1
	.dw Sample0_5 ; tom 2
	.dw Sample0_6 ; tom 3
	.dw Sample0_7 ; tom 4
	.dw Sample0_8 ; heavy snare
	.dw Sample0_9 ; light snare
	.dw Sample0_A ; medium kick
	.dw Sample0_B ; lighter kick
	.dw Sample0_C ; double snare

Sample0_0:
	;           bank, pitch, offset, length
	dpcm_entry PRG_DPCM5, 15, $c000, $00

Sample0_1:
	dpcm_entry PRG_DPCM5, 13, $c000, $40

Sample0_2:
	dpcm_entry PRG_DPCM5, 14, $c400, $27

Sample0_3:
	dpcm_entry PRG_DPCM5, 15, $c680, $19

Sample0_4:
	dpcm_entry PRG_DPCM5, 10, $c840, $16

Sample0_5:
	dpcm_entry PRG_DPCM5, 8,  $c840, $16

Sample0_6:
	dpcm_entry PRG_DPCM5, 6,  $c840, $16

Sample0_7:
	dpcm_entry PRG_DPCM5, 5,  $c840, $16

Sample0_8:
	dpcm_entry PRG_DPCM5, 14, $c9c0, $24

Sample0_9:
	dpcm_entry PRG_DPCM5, 14, $cc00, $24

Sample0_A:
	dpcm_entry PRG_DPCM5, 14, $ce40, $23

Sample0_B:
	dpcm_entry PRG_DPCM5, 15, $d080, $27

Sample0_C:
	dpcm_entry PRG_DPCM5, 14, $d300, $25

SampleKit1:
	.dw Sample0_0 ; silence
	.dw Sample0_3 ; light kick
	.dw Sample1_2 ; march snare
	.dw Sample1_3 ; cowbell
	.dw Sample1_4 ; click
	.dw Sample1_5 ; analog snare
	.dw Sample1_6 ; claves
	.dw Sample1_7 ; conga 1
	.dw Sample1_8 ; conga 2
	.dw Sample1_9 ; conga 3
	.dw Sample1_A ; conga hi
	.dw Sample1_B ; wood block
	.dw Sample1_C ; stomp drum

Sample1_2:
	dpcm_entry PRG_DPCM5, 14, $d580, $1f

Sample1_3:
	dpcm_entry PRG_DPCM5, 14, $d780, $20

Sample1_4:
	dpcm_entry PRG_DPCM5, 14, $d980, $07

Sample1_5:
	dpcm_entry PRG_DPCM5, 15, $da00, $14

Sample1_6:
	dpcm_entry PRG_DPCM5, 15, $db40, $09

Sample1_7:
	dpcm_entry PRG_DPCM5, 12, $dc00, $09

Sample1_8:
	dpcm_entry PRG_DPCM5, 11, $dc00, $09

Sample1_9:
	dpcm_entry PRG_DPCM5, 10, $dc00, $09

Sample1_A:
	dpcm_entry PRG_DPCM5, 13, $dcc0, $08

Sample1_B:
	dpcm_entry PRG_DPCM5, 13, $dd40, $0f

Sample1_C:
	dpcm_entry PRG_DPCM5, 13, $de40, $0d

SampleKit2:
	.dw Sample0_0 ; silence
	.dw Sample0_2 ; heavy kick
	.dw Sample0_8 ; heavy snare
	.dw Sample1_3 ; cowbell
	.dw Sample0_4 ; tom 1
	.dw Sample0_5 ; tom 2
	.dw Sample0_6 ; tom 3
	.dw Sample0_7 ; tom 4
	.dw Sample1_4 ; click
	.dw Sample1_5 ; analog snare
	.dw Sample1_6 ; claves
	.dw Sample1_B ; wood block
	.dw Sample1_C ; stomp drum

SampleKit3:
SampleKit4:
SampleKit5:
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence

SampleKit6:
	.dw Sample0_0 ; silence
	.dw Sample6_1 ; otis - idle
	.dw Sample6_2 ; otis - angry
	.dw Sample6_3 ; otis - curious
	.dw Sample6_4 ; otis - talking
	.dw Sample6_5 ; otis - bummed
	.dw Sample6_6 ; june - idle
	.dw Sample6_7 ; june - angry
	.dw Sample6_8 ; june - curious
	.dw Sample6_9 ; june - talking
	.dw Sample6_A ; june - bummed
	.dw Sample0_0 ; silence
	.dw Sample0_0 ; silence

Sample6_1:
	dpcm_entry PRG_DPCM1, 14, $c100, $70

Sample6_2:
	dpcm_entry PRG_DPCM1, 13, $c800, $ff

Sample6_3:
	dpcm_entry PRG_DPCM2, 14, $c000, $af

Sample6_4:
	dpcm_entry PRG_DPCM1, 14, $d800, $2b

Sample6_5:
	dpcm_entry PRG_DPCM2, 14, $cb00, $8c

Sample6_6:
	dpcm_entry PRG_DPCM2, 15, $d400, $8c

Sample6_7:
	dpcm_entry PRG_DPCM4, 15, $c540, $78

Sample6_8:
	dpcm_entry PRG_DPCM4, 15, $ccc0, $75

Sample6_9:
	dpcm_entry PRG_DPCM1, 15, $dac0, $51

Sample6_A:
	dpcm_entry PRG_DPCM4, 15, $d440, $69
