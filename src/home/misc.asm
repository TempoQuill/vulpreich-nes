GetWindowIndex:
; input -  A - $80-$df
; output - X - PRG window X
	LDX #0
	AND #$60
	SEC
	BEQ @Quit
@Loop:
	INX
	SBC #$20
	BNE @Loop
@Quit
	RTS

CopyBytes:
; copy Y bytes from (AuxAddresses) + 6 to (AuxAddresses) + 2
	DEY
	STY BackupY
	LDA (AuxAddresses + 6), Y
	STA (AuxAddresses + 2), Y
	LDY BackupY
	BNE CopyBytes
	RTS
