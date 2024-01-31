; decorative sprites (used to fill out the background)
SaveMenuBGSprites:
	;   y    tile attr x
	.db $0b, $9f, $41, $68 ; cursor
	.db $0b, $9d, $41, $70
	.db $8f, $a7, $02, $b0 ; mailbox flag
	.db $8f, $a9, $02, $b8
	.db $9f, $ab, $02, $b0
	.db $c7, $a5, $03, $b0 ; grass at mailbox base
SaveMenuBGSprites_END:

CursorMetaspriteData_SaveMenu:
	nesst_meta   0,  0, $9d, 1
	nesst_meta   8,  0, $9f, 1
	nesst_meta   0,  0, $a1, 1
	nesst_meta   8,  0, $a3, 1
	nesst_meta   0,  0, $9d, 1 | OAM_REV_Y
	nesst_meta   8,  0, $9f, 1 | OAM_REV_Y

	nesst_meta   0,  0, $9f, 1 | OAM_REV_X
	nesst_meta   8,  0, $9d, 1 | OAM_REV_X
	nesst_meta   0,  0, $a3, 1 | OAM_REV_X
	nesst_meta   8,  0, $a1, 1 | OAM_REV_X
	nesst_meta   0,  0, $9f, 1 | OAM_REV_Y | OAM_REV_X
	nesst_meta   8,  0, $9d, 1 | OAM_REV_Y | OAM_REV_X

CursorMetspriteOffsets_SaveMenu:
	.db OAM_16_16_WIDTH * 1
	.db OAM_16_16_WIDTH * 2
	.db OAM_16_16_WIDTH * 3
	.db OAM_16_16_WIDTH * 2

	.db OAM_16_16_WIDTH * 4
	.db OAM_16_16_WIDTH * 5
	.db OAM_16_16_WIDTH * 6
	.db OAM_16_16_WIDTH * 5

SaveMenuHighlight1:
	.db $23, $cb, $05
	.db $4a, $5a, $9a, $aa, $20
	.db $23, $d4, $04
	.db $55, $01, $aa, $02
	.db $23, $dc, $03
	.db $05, $00, $8a

	.db $00

SaveMenuHighlight2:
	.db $23, $cb, $05
	.db $8a, $aa, $6a, $5a, $10
	.db $23, $d4, $04
	.db $aa, $02, $55, $01
	.db $23, $dc, $03
	.db $0a, $00, $85

	.db $00
