UploadTitleGFX:
	LDY #0 ; happens to be the param we need
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	STY PPUADDR
@write:
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY

	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY

	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY

	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	LDA LogoData, Y
	STA PPUDATA
	INY
	BEQ @write
	INC zCurrentTileAddress + 1
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY

	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY

	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA
	INY
	LDA (zCurrentTileAddress), Y
	STA PPUDATA

	LDY #0
	LDA #>NAMETABLE_MAP_0
	STA PPUADDR
	STY PPUADDR
	RTS
