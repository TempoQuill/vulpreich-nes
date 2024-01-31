.enum $01cc	; $f4
DO_Click:	.dsb $7
DO_Click_END:	.dsb 1
DO_Claves:	.dsb $9
DO_Claves_END:	.dsb 3
DO_Conga:	.dsb $9
DO_Conga_END:	.dsb 3
.ende

.enum $0000	; $f7
DO_CsMajor:	.dsb $b3
DO_CsMajor_END:	.dsb 1
DO_DMajor:	.dsb $a9
DO_DMajor_END:	.dsb 3
DO_DsMajor:	.dsb $9f
DO_DsMajor_END:	.dsb 1
.ende

.enum $0200	; $f8
DO_EMajor:	.dsb $96
DO_EMajor_END:	.dsb 2
DO_FMajor:	.dsb $8e
DO_FMajor_END:	.dsb 2
DO_FsMajor:	.dsb $86
DO_FsMajor_END:	.dsb 2
DO_Bass_B2:	.dsb $50
DO_Bass_B2_END:
.ende

.enum $0400	; $f9
DO_GMajor:	.dsb $7f
DO_GMajor_END:	.dsb 1
DO_GsMajor:	.dsb $77
DO_GsMajor_END:	.dsb 1
DO_Bass_F2:	.dsb $72
DO_Bass_F2_END: .dsb 2
DO_Bass_Gs2:	.dsb $60
DO_Bass_Gs2_END:
DO_Bass_G3:	.dsb $33
DO_Bass_G3_END:	.dsb 1
.ende

.enum $0600	; $fa
DO_AMajor:		.dsb $71
DO_AMajor_END:		.dsb 3
DO_Bass_Fs2:		.dsb $6b
DO_Bass_Fs2_END:	.dsb 1
DO_Mute_Cs:		.dsb $53
DO_Mute_Cs_END:		.dsb 1
DO_AsMajor:		.dsb $6a
DO_AsMajor_END:		.dsb 2
DO_Bass_Cs3:		.dsb $48
DO_Bass_Cs3_END:
DO_Kick:		.dsb $16
DO_Kick_END:		.dsb 2
.ende

.enum $0800	; $fb
DO_BMajor:		.dsb $65
DO_BMajor_END:		.dsb 3
DO_Bass_G2:		.dsb $65
DO_Bass_G2_END:		.dsb 3
DO_Mute_D:		.dsb $5f
DO_Mute_D_END:		.dsb 1
DO_CMajor:		.dsb $5f
DO_CMajor_END:		.dsb 1
DO_Mute_Fs:		.dsb $58
DO_Mute_Fs_END:
DO_SideSticks:		.dsb $16
DO_SideSticks_END:	.dsb 2
.ende

.enum $0a00	; $fc
DO_Bass_C3:		.dsb $4c
DO_Bass_C3_END:
DO_CsMajor2:		.dsb $5a
DO_CsMajor2_END:	.dsb 2
DO_Bass_A2:		.dsb $5a
DO_Bass_A2_END:		.dsb 2
DO_Mute_E:		.dsb $5d
DO_Mute_E_END:		.dsb 3
DO_Mute_F:		.dsb $5e
DO_Mute_F_END:		.dsb 2
DO_Bass_E3:		.dsb $3c
DO_Bass_E3_END:
.ende

.enum $0c00	; $fd
DO_Bass_As2:		.dsb $55
DO_Bass_As2_END:	.dsb 3
DO_Slide:		.dsb $4f
DO_Slide_END:		.dsb 1
DO_Snare:		.dsb $3a
DO_Snare_END:		.dsb 2
DO_Mute_G:		.dsb $52
DO_Mute_G_END:		.dsb 2
DO_Mute_Gs:		.dsb $4d
DO_Mute_Gs_END:		.dsb 3
DO_Bass_Ds3:		.dsb $40
DO_Bass_Ds3_END:
DO_Bass_Fs3:		.dsb $36
DO_Bass_Fs3_END:	.dsb 2
.ende

.enum $0e00	; $fe
DO_CrossSticks:		.dsb $46
DO_CrossSticks_END:	.dsb 2
DO_Bass_D3:		.dsb $44
DO_Bass_D3_END:
DO_Mute_A:		.dsb $49
DO_Mute_A_END:		.dsb 3
DO_Mute_As:		.dsb $49
DO_Mute_As_END:		.dsb 3
DO_Mute_B:		.dsb $3d
DO_Mute_B_END:		.dsb 3
DO_Mute_Ds:		.dsb $5b
DO_Mute_Ds_END:		.dsb 1
DO_Bass_F3:		.dsb $39
DO_Bass_F3_END:		.dsb 3
.ende
