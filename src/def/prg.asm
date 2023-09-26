IFNDEF NSF_FILE
	.enum $0080
PRG_Start0:
	.dsb 1
PRG_Start1:
	.dsb 1
PRG_Start2:
	.dsb 1
ELSE
	.enum $0000
ENDIF
PRG_Audio:
	.dsb 1
PRG_Music0:
	.dsb 1
	.dsb 1
IFNDEF NSF_FILE
PRG_GFXEngine:
	.dsb 1
PRG_Names0:
	.dsb 1
	.dsb $68
ENDIF
PRG_DPCM0:
	.dsb 1
PRG_DPCM1:
	.dsb 1
PRG_DPCM2:
	.dsb 1
PRG_DPCM3:
	.dsb 1
PRG_DPCM4:
	.dsb 1
PRG_DPCM5:
	.dsb 1
PRG_DPCM6:
	.dsb 1
PRG_DPCM7:
	.dsb 1
PRG_DPCM8:
	.dsb 1
PRG_DPCM9:
	.dsb 1
PRG_DPCM10:
	.dsb 1
PRG_DPCM11:
	.dsb 1
PRG_DPCM12:
	.dsb 1
PRG_DPCM13:
	.dsb 1
PRG_DPCM14:
	.dsb 1
PRG_Home:


PROGRAM_ROM_F = 7
.ende

.enum $0000
RAM_Scratch = $00
RAM_PrimaryPlayFile = $01
RAM_BackupPlayFile = $02

SAVE_CHECK_VALUE_1 = 99
SAVE_CHECK_VALUE_2 = 127

WINDOW_MASK = $6000
WINDOW_SIZE = $2000
NUM_FLEXIBLE_PRG = 2

.ende