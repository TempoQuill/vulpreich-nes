.enum $0000
; y = x * 32 (horizontal tile count)
TEXT_COORD_1 = $342 ; (2, 26)
TEXT_COORD_2 = $382 ; (2, 28)
TEXT_BOX_WIDTH = $1c

; enum ScreenUpdateBuffer
ScreenUpdateBuffer_RAM_301 = $00
ScreenUpdateBuffer_EpisodeSelect = $01
ScreenUpdateBuffer_PublicDomainLayout = $02
ScreenUpdateBuffer_TitleScreen = $03
ScreenUpdateBuffer_Credits = $04

PAL_FADE_DIR_F = 6
PAL_FADE_F = 7

GFX_ATTRIBUTE_SIZE = $40
NAMETABLE_ATTRIBUTE_0 = $23c0
NAMETABLE_ATTRIBUTE_1 = $27c0
NAMETABLE_ATTRIBUTE_2 = $2bc0
NAMETABLE_ATTRIBUTE_3 = $2fc0

NAMETABLE_MAP_0 = $2000
NAMETABLE_MAP_1 = $2400
NAMETABLE_MAP_2 = $2800
NAMETABLE_MAP_3 = $2c00
NAMETABLE_AREA = $400
NUM_BG_PALETTES = $4
PALETTE_RAM = $3f00
PALETTE_RAM_SPAN = $20

COLOR_INDEX = $3f

PALETTE_FADE_SPEED_MASK = $f
PALETTE_FADE_PLACEMENT_MASK = %00000011

text_end_cmd  = $00
text_next_cmd = $81
text_para_cmd = $82
text_line_cmd = $83
text_cont_cmd = $84
text_done_cmd = $85

; 0: $2000 1: $2400 2: $2800 3: $2c00
NAMETABLE_BASE_MASK = $3

PPU_VRAM_INC          = $04 ; 2 ; 0: horizontal 1: vertical
PPU_OBJECT_TABLE      = $08 ; 3 ; 0: $0000      1: $1000
PPU_BACKGROUND_TABLE  = $10 ; 4 ; 0: $0000      1: $1000
PPU_OBJECT_RESOLUTION = $20 ; 5 ; 0: 8x8        1: 8x16
PPU_MS_SELECT         = $40 ; 6 ; 0: read       1: output
PPU_NMI               = $80 ; 7 ; 0: off        1: on

PPU_GREYSCALE    = $01
PPU_BG_MASKLIFT  = $02
PPU_OBJ_MASKLIFT = $04
PPU_BG           = $08
PPU_OBJ          = $10
PPU_RED          = $20
PPU_GREEN        = $40
PPU_BLUE         = $80

.ende