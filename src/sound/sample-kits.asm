SampleKits:
	.dw SampleKit0
	.dw SampleKit1
	.dw SampleKit2
	.dw SampleKit3
	.dw SampleKit4
	.dw SampleKit5
	.dw SampleKit6

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
	;   bnk, pch, ofs, len
	.db PRG_DPCM0, $0f, $00, $00 ; bank $7e, pitch $f, $c000, $001 bytes

Sample0_1:
	.db PRG_DPCM0, $0d, $00, $40 ; bank $7e, pitch $d, $c000, $401 bytes

Sample0_2:
	.db PRG_DPCM0, $0e, $10, $27 ; bank $7e, pitch $e, $c400, $271 bytes

Sample0_3:
	.db PRG_DPCM0, $0f, $1a, $19 ; bank $7e, pitch $f, $c680, $191 bytes

Sample0_4:
	.db PRG_DPCM0, $0a, $21, $16 ; bank $7e, pitch $a, $c840, $161 bytes

Sample0_5:
	.db PRG_DPCM0, $08, $21, $16 ; bank $7e, pitch $8, $c840, $161 bytes

Sample0_6:
	.db PRG_DPCM0, $06, $21, $16 ; bank $7e, pitch $6, $c840, $161 bytes

Sample0_7:
	.db PRG_DPCM0, $05, $21, $16 ; bank $7e, pitch $5, $c840, $161 bytes

Sample0_8:
	.db PRG_DPCM0, $0e, $27, $24 ; bank $7e, pitch $e, $c9c0, $241 bytes

Sample0_9:
	.db PRG_DPCM0, $0e, $30, $24 ; bank $7e, pitch $e, $cc00, $241 bytes

Sample0_A:
	.db PRG_DPCM0, $0e, $39, $23 ; bank $7e, pitch $e, $ce40, $231 bytes

Sample0_B:
	.db PRG_DPCM0, $0f, $42, $27 ; bank $7e, pitch $f, $d080, $271 bytes

Sample0_C:
	.db PRG_DPCM0, $0e, $4c, $25 ; bank $7e, pitch $e, $d300, $251 bytes

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
	.db PRG_DPCM0, $0e, $56, $1f ; bank $7e, pitch $e, $d580, $1f1 bytes

Sample1_3:
	.db PRG_DPCM0, $0e, $5e, $20 ; bank $7e, pitch $e, $d780, $201 bytes

Sample1_4:
	.db PRG_DPCM0, $0e, $66, $07 ; bank $7e, pitch $e, $d980, $071 bytes

Sample1_5:
	.db PRG_DPCM0, $0f, $68, $14 ; bank $7e, pitch $e, $da00, $141 bytes

Sample1_6:
	.db PRG_DPCM0, $0f, $6D, $09 ; bank $7e, pitch $f, $db40, $091 bytes

Sample1_7:
	.db PRG_DPCM0, $0c, $70, $09 ; bank $7e, pitch $c, $dc00, $091 bytes

Sample1_8:
	.db PRG_DPCM0, $0b, $70, $09 ; bank $7e, pitch $b, $dc00, $091 bytes

Sample1_9:
	.db PRG_DPCM0, $0a, $70, $09 ; bank $7e, pitch $a, $dc00, $091 bytes

Sample1_A:
	.db PRG_DPCM0, $0d, $73, $08 ; bank $7e, pitch $d, $dcc0, $081 bytes

Sample1_B:
	.db PRG_DPCM0, $0d, $75, $0f ; bank $7e, pitch $d, $dd40, $0f1 bytes

Sample1_C:
	.db PRG_DPCM0, $0d, $79, $0d ; bank $7e, pitch $d, $de40, $0d1 bytes

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
SampleKit6:
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
