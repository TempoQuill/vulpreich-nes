FanfareHeaderPointers:
	.dw Header_ObjectiveComplete

Header_ObjectiveComplete:
	.db 144			; tempo
	.db (+end - +start) / 2	; number of channels
+start
	.dw ObjectiveComplete_SQ2
	.dw ObjectiveComplete_SQ1
	.dw ObjectiveComplete_Hill
	.dw ObjectiveComplete_Noise
	.dw ObjectiveComplete_DPCM
+end