Music:
IFDEF NSF_FILE
	dba PRG_Audio + 1, Music_None
ELSE
	dba PRG_Audio,     Music_None
ENDIF
	dba PRG_Music0,    Music_TitleScreen
	dba PRG_Music0,    Music_Journey
