.base $6000
; this game has 128K of PRG-RAM, the maximum the MMC5 can hold.
; RAM_Scratch
	.dsb $1800
sWindowStackBottom:
sWindowStack:
	.dsb $7ff
sWindowStackTop:
	.dsb 1
; RAM_PrimaryPlayFile
.base $6000
sCheckValue1: ; 6000
	.dsb 1
sCheckValue2: ; 6001
	.dsb 1
; this label relative to save data is used to write data to the save menu
wPlayerData: ; 6002
	; address + byte (2)
	.dsb 3
wEpisodeCount: ; 6005
	.dsb 2
	; address + byte (3)
	.dsb 3
wLocationsCount: ; 600a
	.dsb 3
	; address + byte (2)
	.dsb 3
wEpisodesCount: ; 6010
	.dsb 2
	; address + byte (7)
	.dsb 3
wName: ; 6015
	.dsb CHR_NAME_LENGTH
wPlayerMenuDataEnd:
	; end
	.dsb 1
wEpisodeEvents: ; 601d
	.dsb 27
wLocationsVisited: ; 6038
	.dsb 11
wEpisodesFinished: ; 6043
	.dsb 27 >> 1
wPlayerDataEnd: ; 6050
sSaveArea1: ; 6050
	.dsb wPlayerDataEnd - wPlayerData
sSaveArea2: ; 609e
	.dsb wPlayerDataEnd - wPlayerData
sSaveAreaEnd: ; 60ec
wSaveMenuOffsetHI:
	.dsb 1
wSaveMenuArea: ; 60ed
	.dsb 434
wSaveMenuData1:
	.dsb wPlayerMenuDataEnd - wPlayerData
wSaveMenuData2:
	.dsb wPlayerMenuDataEnd - wPlayerData
wSaveMenuEnd:
	.dsb 1
wOptionsData:
wOptionsText:
	.dsb 3 + $08
	.dsb 3 + $19
	.dsb 3 + $12
	.dsb 3 + $11
	.dsb 3 + $11
	.dsb 3 + $06
	.dsb 3 + $09
	.dsb 3 + $06
	.dsb 3
wOptionsMusicBCD:
	.dsb 3
	.dsb 3 + $12 - 3
wOptionsSFXBCD:
	.dsb 3
	.dsb 3 + $14
wOptionsAttributes:
	.dsb 3
wOptionsAttrRow1:
	.dsb 3
	.dsb 3
wOptionsAttrRow2:
	.dsb 7
wOptionsAttrRow3:
	.dsb 6
	.dsb 3
wOptionsAttrRow4:
	.dsb 5
wOptionsAttrRow5:
	.dsb 8
wOptionsAttrRow6:
	.dsb 7
wOptionsCheckMarkArea:
	.dsb 3
wOptionsCheckTile1:
	.dsb 1
	.dsb 3
wOptionsCheckTile2:
	.dsb 1
	.dsb 3
wOptionsCheckTile3:
	.dsb 1
	.dsb 1
wOptionsDynamicAttributes:
wODARow2Start:
	.dsb 3
wODARow2:
	.dsb 5
wODARow2_END:
	.dsb 1
wODARow4Start:
	.dsb 3
wODARow4:
	.dsb 3
wODARow3Start:
	.dsb 3
wODARow3:
	.dsb 3
	.dsb 1
wODARow5Start:
	.dsb 3
wODARow5:
	.dsb 1
wOptionsDynamicAttributesEnd:
wOptionsRealTimeBCD:
	.dsb 3
wOptionsRealTimeMusic:
	.dsb 3
	.dsb 3
wOptionsRealTimeSFX:
	.dsb 3
wOptionsRealTimeBCDEnd:
	.dsb 1
wOptionsDataEnd:
; RAM_BackupPlayFile
; a copy of RAM_PrimaryPlayFile
; only used when primary is corrupt, but written to when saved
