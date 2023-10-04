; -----------------------------------------
.include "config.asm"

; Add macros
.include "src/macros.asm"

; -----------------------------------------
; Add definitions
.include "src/def.asm"

.include "header.asm"

; -----------------------------------------
; Add RAM definitions
.enum $0000
.include "src/ram/internal.asm"
.ende

.enum MMC5_ExpansionRAMStart
.include "src/ram/chip.asm"
.ende

.enum $6000
.include "src/ram/cart.asm"
.ende

; add each of the banks
; VulpReich is built with the MMC5 in mind
; it maxes out all of the possible specs with this mapper.
; 8000-dfff - general purpose ROM
; 8000-9fff - switchable window lower
; a000-bfff - switchable window upper
; c000-dfff - always DPCM data
; e000-fff9 - home base, here lies only the most essential
;             instruction data (mapper data, math, NMI, interfaces, etc.)

IFNDEF NSF_FILE
	; bank 00-02 starter banks
	.base $8000
	.include "src/start.asm"
	.pad $c000, $00
	.pad $e000, $00 ; needs to be blank
ENDIF

; bank 03 - sound engine
.base $8000
.include "src/sound.asm"
.pad $a000, $00

; bank 04 - music bank
.base $a000
.include "src/music-0.asm"
.pad $c000, $00

	.dsb $2000, $00

IFNDEF NSF_FILE
	; bank 06 - text engine
	.base $8000
	.include "src/gfx.asm"
	.pad $a000, $00

	; bank 07 - names
	.base $a000
	.include "src/names-0.asm"
	.pad $c000, $00

	; bank 08-6f - unused (for now)
	.dsb (($ef - PRG_Names0) * $2000), $00
ENDIF

; dpcm data - 48K
.base $c000
.incbin "src/raw-data/dpcm70.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm71.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm72.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm73.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm74.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm75.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm76.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm77.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm78.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm79.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm7a.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm7b.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm7c.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm7d.bin"
.pad $e000, $00

.base $c000
.incbin "src/raw-data/dpcm7e.bin"
.incbin "docs/dmc-set-meta.txt"
.pad $e000, $00

IFNDEF NSF_FILE
	.base $e000
	.include "src/home.asm"

	.include "src/chr.asm"
ELSE
	.base $e000
	.include "src/home/nsf.asm"
ENDIF

