.include "src/sound/engine.asm"

;
; -------------------------------------------------------------------------
; Various bits of the music engine have been extracted into separate files;
; see the individual files for details on the formats within
;

; Determine which spot in Zero-Page to write to
.include "src/sound/sfx-queues.asm"

; Frequency table for notes; standard between various Mario games
.include "src/sound/notes.asm"

; Base note lengths and TRI_LINEAR parameters
.include "src/sound/note-lengths.asm"

; Channels active in the music (usually all 5)
.include "src/sound/music-channel-count.asm"

; noise sound effect pointers, contains some percussion
.include "src/sound/noise-sfx-pointers.asm"

.include "src/sound/noise-sfx.asm"

; DPCM sound effect data
.include "src/sound/dpcm-sfx-data.asm"

; Pulse 2 sound effect data
.include "src/sound/pulse-2-sfx-pointers.asm"
.include "src/sound/pulse-2-sfx.asm"