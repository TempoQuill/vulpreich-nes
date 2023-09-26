MusicPointersFirstPart:
	musicPart MusicPartPointers_Title
	musicPart MusicPartPointers_Title

.pad MusicPointersFirstPart + $20, $FF

MusicPointersLoopPart:
	musicPart MusicPartPointers_TitleLoop
	musicPart MusicPartPointers_TitleLoop

.pad MusicPointersLoopPart + $20, $FF

MusicPointersEndPart:
	musicPart MusicPartPointers_TitleEnd
	musicPart MusicPartPointers_TitleEnd

.pad MusicPointersEndPart + $20, $FF