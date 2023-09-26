;
; Music Part Pointers
; ===================
;
; These are the pointers to various music segments used to cue those themes in
; the game as well as handle relative offsets for looping segments
;
MusicPartPointers:
Audio1_MusicPartPointers:

MusicPartPointers_Title:
	musicHeaderPointer MusicHeaderTitle1
MusicPartPointers_TitleLoop:
	musicHeaderPointer MusicHeaderTitle2
	musicHeaderPointer MusicHeaderTitle3
	musicHeaderPointer MusicHeaderTitle4
	musicHeaderPointer MusicHeaderTitle5
	musicHeaderPointer MusicHeaderTitle6
	musicHeaderPointer MusicHeaderTitle7
	musicHeaderPointer MusicHeaderTitle8
	musicHeaderPointer MusicHeaderTitle9
MusicPartPointers_TitleEnd:
	musicHeaderPointer MusicHeaderTitle10

.pad MusicPartPointers + $100, $ff