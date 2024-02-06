FanfareHeaderPointers:
	.dw Header_ObjectiveComplete
	.dw Header_LandlineRing

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

Header_LandlineRing:
	.db 80			; tempo
	.db (+end - +start) / 2	; number of channels
+start
	.dw LandlineRing_SQ2
	.dw LandlineRing_SQ1
+end