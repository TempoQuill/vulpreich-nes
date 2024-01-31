DMCSamplePitchTable:
	.db 0
	.db 14
	.db 14
	.db 14
	.db 14
	.db 14
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 11
	.db 14
	.db 14
	.db 14
	.db 14
	.db 14
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 15
	.db 14
	.db 15
	.db 10
	.db 0

DMCSamplePointers:
	dmc_ptr $1ff
	dmc_ptr DO_Mute_Fs
	dmc_ptr DO_Mute_G
	dmc_ptr DO_Mute_Gs
	dmc_ptr DO_Mute_A
	dmc_ptr DO_Mute_As
	dmc_ptr DO_Mute_Fs
	dmc_ptr DO_Mute_G
	dmc_ptr DO_Mute_Gs
	dmc_ptr DO_Mute_A
	dmc_ptr DO_Mute_As
	dmc_ptr DO_Mute_B
	dmc_ptr DO_Slide
	dmc_ptr DO_CsMajor
	dmc_ptr DO_DMajor
	dmc_ptr DO_DsMajor
	dmc_ptr DO_EMajor
	dmc_ptr DO_FMajor
	dmc_ptr DO_FsMajor
	dmc_ptr DO_GMajor
	dmc_ptr DO_GsMajor
	dmc_ptr DO_AMajor
	dmc_ptr DO_AsMajor
	dmc_ptr DO_BMajor
	dmc_ptr DO_CMajor
	dmc_ptr DO_CsMajor2
	dmc_ptr DO_Bass_F2
	dmc_ptr DO_Bass_Fs2
	dmc_ptr DO_Bass_G2
	dmc_ptr DO_Bass_Gs2
	dmc_ptr DO_Bass_A2
	dmc_ptr DO_Bass_As2
	dmc_ptr DO_Bass_B2
	dmc_ptr DO_Bass_C3
	dmc_ptr DO_Bass_Cs3
	dmc_ptr DO_Bass_D3
	dmc_ptr DO_Bass_F2
	dmc_ptr DO_Bass_Fs2
	dmc_ptr DO_Bass_G2
	dmc_ptr DO_Bass_Gs2
	dmc_ptr DO_Bass_A2
	dmc_ptr DO_Bass_F2
	dmc_ptr DO_Bass_Fs2
	dmc_ptr DO_Bass_G2
	dmc_ptr DO_Bass_Gs2
	dmc_ptr DO_Bass_A2
	dmc_ptr DO_Bass_As2
	dmc_ptr DO_Bass_B2
	dmc_ptr DO_Bass_C3
	dmc_ptr DO_Bass_Cs3
	dmc_ptr DO_Bass_D3
	dmc_ptr DO_Bass_Ds3
	dmc_ptr DO_Bass_E3
	dmc_ptr DO_Bass_F3
	dmc_ptr DO_Bass_Fs3
	dmc_ptr DO_Bass_G3
	dmc_ptr DO_Kick
	dmc_ptr DO_SideSticks
	dmc_ptr DO_Snare
	dmc_ptr DO_CrossSticks
	dmc_ptr DO_Click
	dmc_ptr DO_Claves
	dmc_ptr DO_Conga
	dmc_ptr $1ff

DMCSampleLengths:
	.db 0
	.db DO_Mute_Cs_END - DO_Mute_Cs
	.db DO_Mute_D_END - DO_Mute_D
	.db DO_Mute_Ds_END - DO_Mute_Ds
	.db DO_Mute_E_END - DO_Mute_E
	.db DO_Mute_F_END - DO_Mute_F
	.db DO_Mute_Fs_END - DO_Mute_Fs
	.db DO_Mute_G_END - DO_Mute_G
	.db DO_Mute_Gs_END - DO_Mute_Gs
	.db DO_Mute_A_END - DO_Mute_A
	.db DO_Mute_As_END - DO_Mute_As
	.db DO_Mute_B_END - DO_Mute_B
	.db DO_Slide_END - DO_Slide
	.db DO_CsMajor_END - DO_CsMajor
	.db DO_DMajor_END - DO_DMajor
	.db DO_DsMajor_END - DO_DsMajor
	.db DO_EMajor_END - DO_EMajor
	.db DO_FMajor_END - DO_FMajor
	.db DO_FsMajor_END - DO_FsMajor
	.db DO_GMajor_END - DO_GMajor
	.db DO_GsMajor_END - DO_GsMajor
	.db DO_AMajor_END - DO_AMajor
	.db DO_AsMajor_END - DO_AsMajor
	.db DO_BMajor_END - DO_BMajor
	.db DO_CMajor_END - DO_CMajor
	.db DO_CsMajor2_END - DO_CsMajor2
	.db DO_Bass_F2_END - DO_Bass_F2
	.db DO_Bass_Fs2_END - DO_Bass_Fs2
	.db DO_Bass_G2_END - DO_Bass_G2
	.db DO_Bass_Gs2_END - DO_Bass_Gs2
	.db DO_Bass_A2_END - DO_Bass_A2
	.db DO_Bass_As2_END - DO_Bass_As2
	.db DO_Bass_B2_END - DO_Bass_B2
	.db DO_Bass_C3_END - DO_Bass_C3
	.db DO_Bass_Cs3_END - DO_Bass_Cs3
	.db DO_Bass_D3_END - DO_Bass_D3
	.db DO_Bass_F2_END - DO_Bass_F2
	.db DO_Bass_Fs2_END - DO_Bass_Fs2
	.db DO_Bass_G2_END - DO_Bass_G2
	.db DO_Bass_Gs2_END - DO_Bass_Gs2
	.db DO_Bass_A2_END - DO_Bass_A2
	.db DO_Bass_F2_END - DO_Bass_F2
	.db DO_Bass_Fs2_END - DO_Bass_Fs2
	.db DO_Bass_G2_END - DO_Bass_G2
	.db DO_Bass_Gs2_END - DO_Bass_Gs2
	.db DO_Bass_A2_END - DO_Bass_A2
	.db DO_Bass_As2_END - DO_Bass_As2
	.db DO_Bass_B2_END - DO_Bass_B2
	.db DO_Bass_C3_END - DO_Bass_C3
	.db DO_Bass_Cs3_END - DO_Bass_Cs3
	.db DO_Bass_D3_END - DO_Bass_D3
	.db DO_Bass_Ds3_END - DO_Bass_Ds3
	.db DO_Bass_E3_END - DO_Bass_E3
	.db DO_Bass_F3_END - DO_Bass_F3
	.db DO_Bass_Fs3_END - DO_Bass_Fs3
	.db DO_Bass_G3_END - DO_Bass_G3
	.db DO_Kick_END - DO_Kick
	.db DO_SideSticks_END - DO_SideSticks
	.db DO_Snare_END - DO_Snare
	.db DO_CrossSticks_END - DO_CrossSticks
	.db DO_Click_END - DO_Click
	.db DO_Claves_END - DO_Claves
	.db DO_Conga_END - DO_Conga
	.db 0

DPCMSampleBanks:
	audio_bank PRG_DPCM12 ;
	dmc_bank DO_Mute_Fs
	dmc_bank DO_Mute_G
	dmc_bank DO_Mute_Gs
	dmc_bank DO_Mute_A
	dmc_bank DO_Mute_As
	dmc_bank DO_Mute_Fs
	dmc_bank DO_Mute_G
	dmc_bank DO_Mute_Gs
	dmc_bank DO_Mute_A
	dmc_bank DO_Mute_As
	dmc_bank DO_Mute_B
	dmc_bank DO_Slide
	dmc_bank DO_CsMajor
	dmc_bank DO_DMajor
	dmc_bank DO_DsMajor
	dmc_bank DO_EMajor
	dmc_bank DO_FMajor
	dmc_bank DO_FsMajor
	dmc_bank DO_GMajor
	dmc_bank DO_GsMajor
	dmc_bank DO_AMajor
	dmc_bank DO_AsMajor
	dmc_bank DO_BMajor
	dmc_bank DO_CMajor
	dmc_bank DO_CsMajor2
	dmc_bank DO_Bass_F2
	dmc_bank DO_Bass_Fs2
	dmc_bank DO_Bass_G2
	dmc_bank DO_Bass_Gs2
	dmc_bank DO_Bass_A2
	dmc_bank DO_Bass_As2
	dmc_bank DO_Bass_B2
	dmc_bank DO_Bass_C3
	dmc_bank DO_Bass_Cs3
	dmc_bank DO_Bass_D3
	dmc_bank DO_Bass_F2
	dmc_bank DO_Bass_Fs2
	dmc_bank DO_Bass_G2
	dmc_bank DO_Bass_Gs2
	dmc_bank DO_Bass_A2
	dmc_bank DO_Bass_F2
	dmc_bank DO_Bass_Fs2
	dmc_bank DO_Bass_G2
	dmc_bank DO_Bass_Gs2
	dmc_bank DO_Bass_A2
	dmc_bank DO_Bass_As2
	dmc_bank DO_Bass_B2
	dmc_bank DO_Bass_C3
	dmc_bank DO_Bass_Cs3
	dmc_bank DO_Bass_D3
	dmc_bank DO_Bass_Ds3
	dmc_bank DO_Bass_E3
	dmc_bank DO_Bass_F3
	dmc_bank DO_Bass_Fs3
	dmc_bank DO_Bass_G3
	dmc_bank DO_Kick
	dmc_bank DO_SideSticks
	dmc_bank DO_Snare
	dmc_bank DO_CrossSticks
	audio_bank PRG_DPCM2  ; Click
	audio_bank PRG_DPCM2  ; Claves
	audio_bank PRG_DPCM2  ; Conga
	audio_bank PRG_DPCM12 ; 
