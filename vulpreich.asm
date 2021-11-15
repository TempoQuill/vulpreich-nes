
.include "constants.asm"
.include "header.asm"

; -----------------------------------------
; Add macros
.include "macros.asm"

; -----------------------------------------
; Add definitions
.enum $0000
.include "def.asm"
.ende

; Add RAM definitions
.enum $0000
.include "ram/internal.asm"
.ende

.enum MMC5_ExpansionRAMStart
.include "ram/chip.asm"
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
.dsb (3 * $2000), $00

; bank 03 - sound engine
.base $8000
.include "sound/engine.asm"
.pad $a000, $00

; bank 04 - music bank
.base $a000
.include "music/title.asm"
.pad $c000, $00

.dsb $2000, $00

; bank 06 - text engine
.base $8000
.include "engine/text.asm"
.pad $a000, $00

; bank 05-7d - unused (for now)
.dsb (($fd - PRG_TextEngine) * $2000), $00

.base $c000
.incbin "raw-data/dpcm-7e.bin"
.pad $e000, $00

.base $e000
.include "home.asm"
