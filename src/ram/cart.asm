.base $6000
; this game has 128K of PRG-RAM, the maximum the MMC5 can hold.
; RAM_Scratch
	.dsb $1800
sWindowStackBottom:
sWindowStack:
	.dsb $7ff
sWindowStackTop:
	.dsb 1
; RAM_PrimaryPlayFile
.base $6000
sPlayerData:
sCheckValue1:
	.dsb 1 ; 6000
sCheckValue2:
	.dsb 1
	.dsb $1ffe
; RAM_BackupPlayFile
.base $6000
sBackupPlayerData:
sBackupCheckValue1:
	.dsb 1 ; 6000
sBackupCheckValue2:
	.dsb 1
	.dsb $1ffe
	.dsb (13 * $2000)