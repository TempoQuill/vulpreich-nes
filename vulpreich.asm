; -----------------------------------------
; Add definitions
.enum $0000
.include "src/def.asm"
.ende

.include "header.asm"

; -----------------------------------------
; Add macros
.include "src/macros.asm"

; -----------------------------------------
; Add RAM definitions
.enum $0000
.include "src/ram/internal.asm"
.ende

.enum MMC5_ExpansionRAMStart
.include "src/ram/chip.asm"
.ende

; add each of the banks
; Vulpreich is built with the MMC5 in mind
; it maxes out all of the possible specs with this mapper.
; 8000-dfff - general purpose ROM
; 8000-9fff - almost always instruction data
; a000-bfff - sometimes read-ready data, sometimes instruction data
; c000-dfff - always read-ready data, sometimes DPCM data
; e000-fff9 - home base, here lies only the most essential
;             instruction data (mapper data, math, NMI, interfaces, etc.)

; bank 00-02 starter banks
.base $8000
.include "src/start-0.asm"
.dsb (2 * $2000), $00

; bank 03 - sound engine
.base $8000
.include "src/sound.asm"
.pad $a000, $00

; bank 04 - music bank
.base $a000
.include "src/music-0.asm"
.pad $c000, $00

.dsb $2000, $00

; bank 06 - text engine
.base $8000
.include "src/text.asm"
.pad $a000, $00

; bank 07 - names
.base $c000
.include "src/names-0.asm"
.pad $e000, $00

; bank 08-78 - unused (for now)
.dsb (($f8 - PRG_Names0) * $2000), $00

; dpcm data - 48K
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
.pad $e000, $00

.base $e000
.include "src/home.asm"
