CardBCDBalance:
	.dsb 4 ; 5c00
CurrentBCDPrice:
	.dsb 4 ; 5c04
NametableAddress:
	.dsb 2 ; 5c08
ObjectIndex:
	.dsb 1
ObjectType:
	.dsb 1
NamePointer:
; bank, lo, high
	.dsb 3 ; 5c0c
CurrentIndex:
	.dsb 1
CurrentRAMAddress:
	.dsb 2 ; 5c10
	.dsb $2ee
TextBuffer:
	.dsb $100 ; 5f00
