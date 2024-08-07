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

;                 L    W   H  ; T
OAM_32_32_WIDTH = 4 * (4 * 2) ; 32
OAM_24_32_WIDTH = 4 * (3 * 2) ; 24
OAM_16_32_WIDTH = 4 * (2 * 2) ; 16
OAM_8_32_WIDTH  = 4 * (1 * 2) ; 8
OAM_32_16_WIDTH = 4 * (4 * 1) ; 16
OAM_24_16_WIDTH = 4 * (3 * 1) ; 12
OAM_16_16_WIDTH = 4 * (2 * 1) ; 8
OAM_8_16_WIDTH  = 4 * (1 * 1) ; 4

TITLE_SCREEN_DURATION = $902

.enum $0000
TITLE_JUNE_OFFSET:	.dsb OAM_24_32_WIDTH
TITLE_IGGY_OFFSET:	.dsb OAM_32_32_WIDTH
TITLE_OTIS_OFFSET:	.dsb OAM_32_32_WIDTH
TITLE_CROW_OFFSET:	.dsb OAM_24_32_WIDTH
TITLE_CURSOR_OFFSET:	.dsb OAM_16_16_WIDTH
TITLE_OAM_TOTAL_WIDTH:
.ende

.enum TITLE_CURSOR_OFFSET
SAVE_MENU_CURSOR_OFFS:	.dsb OAM_16_16_WIDTH
SAVE_MENU_DECO_OFFS:	.dsb OAM_16_16_WIDTH
			.dsb OAM_16_16_WIDTH
SAVE_MENU_TOTAL_WIDTH:
SAVE_MENU_SPRITE_AREA = SAVE_MENU_TOTAL_WIDTH - SAVE_MENU_CURSOR_OFFS
.ende

TITLE_SCREEN_CROW_ENTRANCE_1 = $814
TITLE_SCREEN_IGGY_ENTRANCE_1 = $7dc
TITLE_SCREEN_JUNE_ENTRANCE_1 = $794
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

; bits  flag(s)        Default
; 0-1 - Price Modifier Normal
; 2-3 - Text speed     2's
; 4   - Cutscenes      On
; 5   - Voices         On
; 6   - Sound Effects  On
; 7   - Music          On
DEFAULT_OPTION = %11111010

PRICE_MOD   = %00000011
TEXT_SPEED  = %00001100
CUTSCENES_F = %00010000
VFX_F       = %00100000
SFX_F       = %01000000
MUSIC_F     = %10000000
AUDIO_MASK  = %11100000

.enum $0000
OPTION_AUDIO_FLAGS:	.dsb 1
OPTION_CUTSCENES:	.dsb 1
OPTION_TEXT_SPEED:	.dsb 1
OPTION_PRICE_SETTING:	.dsb 1
OPTION_MUSIC_TEST:	.dsb 1
OPTION_SFX_VFX_TEST:	.dsb 1
OPTION_BACK_TO_TITLE:
.ende

; zOWObject?
.enum $0000
OW_OBJECT_X_COORD:	.dsb 1 ; left / right
OW_OBJECT_Y_COORD:	.dsb 1 ; scaling degree
OW_OBJECT_Z_COORD:	.dsb 1 ; master Y position offset
OW_OBJECT_ID:		.dsb 1
OW_OBJECT_DIRECTION:
.ende

; overworld collision constants
.enum 0
COL_NO_LIMITS:
COL_0_7:	.dsb 1 ; 0000
COL_0_1:	.dsb 1 ; 0001
COL_0_3:	.dsb 1 ; 0010
COL_0_5:	.dsb 1 ; 0011
COL_2_7:	.dsb 1 ; 0100
COL_BLOCK_5:	.dsb 1 ; 0101
COL_2_3:	.dsb 1 ; 0110
COL_2_5:	.dsb 1 ; 0111
COL_4_7:	.dsb 1 ; 1000
	.dsb 1
COL_BLOCK_A:	.dsb 1 ; 1010
COL_4_5:	.dsb 1 ; 1011
COL_6_7:	.dsb 1 ; 1100

COL_BLOCK_DEFAULT = %1111
COL_BLOCK_ALL = $ff

COL_EXCLUSIVE = %00000000
COL_INCLUSIVE = %10000000
COL_JUMP_EXC = %00001000
COL_JUMP_INC = %10001000
COL_JUMP_LO   = 0
COL_JUMP_HI   = 4
.ende
