MusicPointersFirstPart:
	musicPart MusicPartPointers_Title
	musicPart MusicPartPointers_SaveMenu

.pad MusicPointersFirstPart + $20, $FF

MusicPointersLoopPart:
	musicPart MusicPartPointers_TitleLoop
	musicPart MusicPartPointers_SaveMenuLoop

.pad MusicPointersLoopPart + $20, $FF

MusicPointersEndPart:
	musicPart MusicPartPointers_TitleEnd
	musicPart MusicPartPointers_SaveMenuEnd

.pad MusicPointersEndPart + $20, $FF