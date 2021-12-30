cCardBCDBalance:
	.dsb 4 ; 5c00
cCurrentBCDPrice:
	.dsb 4 ; 5c04
cNametableAddress:
	.dsb 2 ; 5c08
cObjectIndex:
	.dsb 1
cObjectType:
	.dsb 1
cNamePointer:
; bank, lo, high
	.dsb 3 ; 5c0c
cCurrentIndex:
	.dsb 1
cCurrentRAMAddress:
	.dsb 2 ; 5c10
cWindowStackPointer:
	.dsb 2
	.dsb 12 ; 5c14
cCurrentROMBank:
	.dsb 1 ; 5c20
	.dsb $2af
c2DMenuCursorInitY:
	.dsb 16
cMenuData:
cMenuDataFlags:
	.dsb 16 ; 5ed0
cMenuHeader:
	.dsb 16 ; 5ee0
cMenuHeaderEnd:
	.dsb 16 ; 5ef0
cTextBuffer:
	.dsb $100 ; 5f00
