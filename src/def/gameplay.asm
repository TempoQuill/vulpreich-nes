.enum $0000
TITLESCREENOPTION_MAIN_MENU:		.dsb 1
TITLESCREENOPTION_DELETE_SAVE_FILE:	.dsb 1
TITLESCREENOPTION_RESTART:		.dsb 1

NUM_TITLESCREENOPTION:

A_BUTTON = 7
B_BUTTON = 6
SELECT_BUTTON = 5
START_BUTTON = 4
UP_BUTTON = 3
DOWN_BUTTON = 2
LEFT_BUTTON = 1
RIGHT_BUTTON = 0
.ende

OAM_32_32_WIDTH = $20
OAM_24_32_WIDTH = $18

TITLE_SCREEN_DURATION = $902

.enum $0000
TITLE_JUNE_OFFSET:	.dsb OAM_24_32_WIDTH
TITLE_IGGY_OFFSET:	.dsb OAM_32_32_WIDTH
TITLE_OTIS_OFFSET:	.dsb OAM_32_32_WIDTH
TITLE_CROW_OFFSET:	.dsb OAM_24_32_WIDTH
TITLE_OAM_TOTAL_WIDTH:
.ende

TITLE_SCREEN_CROW_ENTRANCE_1 = $814
TITLE_SCREEN_IGGY_ENTRANCE_1 = $7dc
TITLE_SCREEN_OTIS_ENTRANCE_1 = $740
TITLE_SCREEN_CROW_ENTRANCE_2 = $1f6
TITLE_SCREEN_IGGY_ENTRANCE_2 = $1ec

; zTitleObj1ScreenEdgeFlags
; off = $00
; on = $01
; left = $00
; right = $40
; enter = $00
; exit = $80
ENTER_EXIT_ACT_F = 0
ENTER_EXIT_DIR_F = 6
ENTER_EXIT_F     = 7
