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
cCurrentROMBank:
	.dsb 1
	.dsb $2ed
cTextBuffer:
	.dsb $100 ; 5f00
