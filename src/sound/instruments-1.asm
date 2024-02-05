Duty0 = -48
Duty1 = 16
Duty2 = 80

InstrumentDVE_80:
Audio1_InstrumentDVE_80:
	.db "@AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBCCCCCCCCCCCCDDDDDDDEE" + Duty1
	.db "B" + Duty0
	.db "C" + Duty2
	.db "B" + Duty1
	.db "A" + Duty0

InstrumentDVE_80_Short:
Audio1_InstrumentDVE_80_Short:
	.db "@AAAAAAAAABBBBCCCDD" + Duty1
	.db "B" + Duty0
	.db "C" + Duty2
	.db "B" + Duty1
	.db "A" + Duty0

InstrumentDVE_90_E0:
Audio1_InstrumentDVE_90_E0:
	.db "@AAAAAAAABBBBBBBBCCCCCCCCDDDDDDEEEEEFFFFFGGGGGGHHHHIIJJKKLMMNOKG" + Duty2

InstrumentDVE_90_E0_Short:
Audio1_InstrumentDVE_90_E0_Short:
	.db "@ABCCDEEFFGGHIIJJKLOMKG" + Duty2

InstrumentDVE_A0:
Audio1_InstrumentDVE_A0:
	.db "@AAAAAAAABBBBBBBBCCCCCCCCDDDDDDEEEEEFFFFFGGGGGGHHHHIIJJKKLMMNOKG" + Duty0

InstrumentDVE_A0_Short:
Audio1_InstrumentDVE_A0_Short:
	.db "@ABCCDEEFFGGHIIJJKLOMKG" + Duty0

InstrumentDVE_B0:
Audio1_InstrumentDVE_B0:
	.db "@AABBCCDDEEFFGHIJKLMNNMMMNNNNMMMNNNNMMMNNNNMMMNNNNMMMNNNNMMMNNLF" + Duty1

InstrumentDVE_B0_Short:
Audio1_InstrumentDVE_B0_Short:
	.db "@ABCDEFGHIJKLMNNMMMNNLF" + Duty1

InstrumentDVE_C0:
Audio1_InstrumentDVE_C0:
	.db "@AAABBBCCCDDDEEEFFFGGGFFFFEEEDDDEEEFFFFGGGFFFFEEEDDEEEFFFFGGGHIF" + Duty1

InstrumentDVE_C0_Short:
Audio1_InstrumentDVE_C0_Short:
	.db "@AAABBCCDDEEEFFFFGGGHIF" + Duty1

InstrumentDVE_D0:
Audio1_InstrumentDVE_D0:
	.db "@AAABBBCCDDEEFFGGEFGEFGEFGEFGEFGEFGEFGEFGEFGEFGEFGEFGEFGFGFGHGF" + Duty2
	.db "D" + Duty0

InstrumentDVE_D0_Short:
Audio1_InstrumentDVE_D0_Short:
	.db "@AAABBBCCDDEEFGFGFGHGF" + Duty2
	.db "D" + Duty0

InstrumentDVE_F0:
Audio1_InstrumentDVE_F0:
	.db "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ABI" + Duty2

InstrumentDVE_F0_Short:
Audio1_InstrumentDVE_F0_Short:
	.db "@@@@@@@@@@@@@@@@@@@@ABI" + Duty2
