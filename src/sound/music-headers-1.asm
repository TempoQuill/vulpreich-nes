;
; Music Headers
; =============
;
; These are broken down by song segment and point to the note length table and
; and individual channel data. Square 2 is the main pointer, and hill,
; square 1, and noise are stored as offets relative to the main pointer.
;
; Bytes:
;   00: Note length table (from $8F00)
;   01: Main address / Square 2 (lo)
;   02: Main address / Square 2 (hi)
;   03: Hill offset from Square 1
;   04: Square 1 offset from Square 2
;   05: Noise offset from Hill
;   06: DPCM offset from Noise
;
; For the musicHeader macro, specifying $00 is "none", -1 for noise/pcm is "omit".
;
; This turns out to be important because the music part pointers are stored as
; offsets from MusicPartPointers, which means they can't be larger than $FF!
;
MusicHeaders:
Audio1_MusicHeaders:

; ----------------------------------------
; Title Screen
MusicHeaderTitle1:
	musicHeader NLT_Title, MusDTitle1, MusDTitle1_Hill, MusDTitle1_SQ1, MusDTitle1_Noise, MusDTitle1_DPCM

MusicHeaderTitle2:
	musicHeader NLT_Title, MusDTitle2, MusDTitle2_Hill, MusDTitle2_SQ1, MusDTitle2_Noise, MusDTitle2_DPCM

MusicHeaderTitle3:
	musicHeader NLT_Title, MusDTitle3, MusDTitle3_Hill, MusDTitle3_SQ1, MusDTitle3_Noise, MusDTitle3_DPCM

MusicHeaderTitle4:
	musicHeader NLT_Title, MusDTitle4, MusDTitle4_Hill, MusDTitle4_SQ1, MusDTitle4_Noise, MusDTitle4_DPCM

MusicHeaderTitle5:
	musicHeader NLT_Title, MusDTitle5, MusDTitle5_Hill, MusDTitle5_SQ1, MusDTitle5_Noise, MusDTitle5_DPCM

MusicHeaderTitle6:
	musicHeader NLT_Title, MusDTitle6, MusDTitle6_Hill, MusDTitle6_SQ1, MusDTitle6_Noise, MusDTitle6_DPCM

MusicHeaderTitle7:
	musicHeader NLT_Title, MusDTitle7, MusDTitle7_Hill, MusDTitle7_SQ1, MusDTitle7_Noise, MusDTitle7_DPCM

MusicHeaderTitle8:
	musicHeader NLT_Title, MusDTitle8, MusDTitle8_Hill, MusDTitle8_SQ1, MusDTitle8_Noise, MusDTitle8_DPCM

MusicHeaderTitle9:
	musicHeader NLT_Title, MusDTitle9, MusDTitle9_Hill, MusDTitle9_SQ1, MusDTitle9_Noise, MusDTitle9_DPCM

MusicHeaderTitle10:
	musicHeader NLT_Title, MusDTitle10, MusDTitle10_Hill, MusDTitle10_SQ1, MusDTitle10_Noise, MusDTitle10_DPCM

; ----------------------------------------
; Save Menu
MusicHeaderSaveMenu1:
	musicHeader NLT_Save, MusDSave1, MusDSave1_Hill, MusDSave1_SQ1, MusDSave1_Noise, MusDSave1_DPCM

MusicHeaderSaveMenu2:
	musicHeader NLT_Save, MusDSave2, MusDSave2_Hill, MusDSave2_SQ1, MusDSave2_Noise, MusDSave2_DPCM

.pad MusicHeaders + $100, $ff