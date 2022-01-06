PRG_Start0 = $80
PRG_Start1 = $81
PRG_Start2 = $82

IFNDEF NSF_FILE
  PRG_Audio = $83
  PRG_Music0 = $84
  PRG_DPCM0 = $f9
  PRG_DPCM1 = $fa
  PRG_DPCM2 = $fb
  PRG_DPCM3 = $fc
  PRG_DPCM4 = $fd
  PRG_DPCM5 = $fe
  PRG_Home = $ff
ELSE
  PRG_Audio = $02
  PRG_Music0 = $04
  PRG_DPCM0 = $06
  PRG_DPCM1 = $08
  PRG_DPCM2 = $0a
  PRG_DPCM3 = $0b
  PRG_DPCM4 = $0c
  PRG_DPCM5 = $0d
  PRG_Home = $00
ENDIF

PRG_TextEngine = $86
PRG_Names0 = $87

RAM_Scratch = $00
RAM_PrimaryPlayFile = $01
RAM_BackupPlayFile = $02

SAVE_CHECK_VALUE_1 = 99
SAVE_CHECK_VALUE_2 = 127