;
; Channel stacks
; This data is used to determine how many bytes to use in the headers.
; $03 -> 5 Bytes -> Pulses + Hill only
; $05 -> 7 Bytes -> All five channels
;
MusicChannelStack:
	.db $05 ; title
	.db $05 ; save menu
	.db $05 ; journey
