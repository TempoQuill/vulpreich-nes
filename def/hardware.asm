MMC5 = $05

MMC5_VMirror = %01000100
MMC5_HMirror = %01010000

CHR_A12_INVERSION = $80

; enum PPUControl (bitfield) (width 1 byte)
PPUCtrl_BaseAddress = $03
PPUCtrl_Base2000 = $00
PPUCtrl_Base2400 = $01
PPUCtrl_Base2800 = $02
PPUCtrl_Base2C00 = $03
PPUCtrl_WriteHorizontal = $00
PPUCtrl_WriteVertical = $04
PPUCtrl_Sprite0000 = $00
PPUCtrl_Sprite1000 = $08
PPUCtrl_Background0000 = $00
PPUCtrl_Background1000 = $10
PPUCtrl_SpriteSize8x8 = $00
PPUCtrl_SpriteSize8x16 = $20
PPUCtrl_NMIDisabled = $00
PPUCtrl_NMIEnabled = $80

PPUStatus_VBlankHit = $80

BATTERY_RAM      = 2
IGNORE_MIRRORING = 8

NES_2_0 = 8

; reference: NTSC NES runs at 1,789,773 Hz
; each frame contains 29,780 cycles
; therefore NTSC NES runs at 60,099.832 mHz
;            PAL NES runs at 1,662,607 Hz
; each frame contains 33,248 cycles
; therefore PAL NES runs at 50,006.226 mHz

; you can do more with PAL NES due to the lower framerate having more cycles than NTSC
; in theory porting to NTSC would cause lag.

;
; PPU registers
; $2000-$2007
;

PPUCTRL = $2000   ; control
PPUMASK = $2001   ; mask
PPUSTATUS = $2002 ; status
OAMADDR = $2003   ; oam location
OAMDATA = $2004   ; current byte
PPUSCROLL = $2005 ; scroll position
PPUADDR = $2006   ; ppu location
PPUDATA = $2007   ; current byte

;
; APU registers and joypad registers
;  $4000-$4015         $4016-$4017
; APU Features
; volume (with barebones sweep functions) (pulses, noise)
; 11-bit pitch (pulses, triangle)
; some features run at 240 Hz rather than the standard 60, marked by *
;

SQ1_ENV = $4000   ; 0-3: volume/sweep speed* 4:   volume sweep Flag 5:   counter flag 6-7: cycle id
SQ1_SWEEP = $4001 ; 0-2: shift multiplier    3:   direction         4-6: period       7:   power flag
SQ1_LO = $4002    ; 0-7: pitch
SQ1_HI = $4003    ; 0-2: pitch               3-7: length

SQ2_ENV = $4004
SQ2_SWEEP = $4005
SQ2_LO = $4006
SQ2_HI = $4007

; $4009 isn't functional 55053
TRI_LINEAR = $4008 ; 0-6: linear load* 7:   linear flag
TRI_LO = $400a     ; 0-7: pitch
TRI_HI = $400b     ; 0-2: pitch        3-7: length load

; $400d isn't functional
NOISE_ENV = $400c ; 0-3: volume/sweep speed* 4: volume sweep Flag 5: counter flag
NOISE_LO = $400e  ; 0-3: pitch               7: period loop flag
NOISE_HI = $400f  ; 3-7: length load

DPCM_ENV = $4010    ; 0-3: pitch 6: loop flag 7: IRQ flag
DPCM_DELTA = $4011  ; 0-6: delta counter
DPCM_OFFSET = $4012 ; 0-7: (offset - $c000) / $40
DPCM_SIZE = $4013   ; 0-7: (size - 1) / $10

OAM_DMA = $4014   ; CPU memory page $XX00 - $XXFF

; BUG: DPCM samples retrigger when poked
SND_CHN = $4015   ; master APU register: each bit is the corresponding channel power flag, 5-7 are not used

JOY1 = $4016
JOY2 = $4017

;
; MMC5 registers
; $5000-$5015
;

MMC5_PULSE1_VOL = $5000
MMC5_PULSE1_LO = $5002
MMC5_PULSE1_HI = $5003

MMC5_PULSE2_VOL = $5004
MMC5_PULSE2_LO = $5006
MMC5_PULSE2_HI = $5007

MMC5_PCM_MODE_IRQ = $5010
MMC5_RAW_PCM = $5011

MMC5_SND_CHN = $5015 ; master expansion sound register: only uses bits 0, 1, and 5 if at all

;
; MMC5 bank switching
;
MMC5_PRGMode = $5100
MMC5_CHRMode = $5101
MMC5_PRGRAMProtect1 = $5102
MMC5_PRGRAMProtect2 = $5103
MMC5_ExtendedRAMMode = $5104
MMC5_NametableMapping = $5105
MMC5_FillModeTile = $5106
MMC5_FillModeColor = $5107
MMC5_PRGBankSwitch1 = $5113 ; 6000 - 7fff
MMC5_PRGBankSwitch2 = $5114 ; 8000 - 9fff
MMC5_PRGBankSwitch3 = $5115 ; a000 - bfff
MMC5_PRGBankSwitch4 = $5116 ; c000 - dfff
MMC5_PRGBankSwitch5 = $5117 ; e000 - ffff
MMC5_CHRBankSwitch1 = $5120  ; 0000 - 03ff
MMC5_CHRBankSwitch2 = $5121  ; 0400 - 07ff
MMC5_CHRBankSwitch3 = $5122  ; 0800 - 0bff
MMC5_CHRBankSwitch4 = $5123  ; 0c00 - 0fff
MMC5_CHRBankSwitch5 = $5124  ; 1000 - 13ff
MMC5_CHRBankSwitch6 = $5125  ; 1400 - 17ff
MMC5_CHRBankSwitch7 = $5126  ; 1800 - 1bff
MMC5_CHRBankSwitch8 = $5127  ; 1c00 - 1fff
MMC5_CHRBankSwitch9 = $5128  ; 0000 - 03ff, 1000 - 13ff
MMC5_CHRBankSwitch10 = $5129 ; 0400 - 07ff, 1400 - 17ff
MMC5_CHRBankSwitch11 = $512a ; 0800 - 0bff, 1800 - 1bff
MMC5_CHRBankSwitch12 = $512b ; 0c00 - 0fff, 1c00 - 1fff
MMC5_CHRBankSwitchUpper = $5130

MMC5_VSplitMode = $5200
MMC5_VSplitScroll = $5201
MMC5_VSplitBlank = $5202
MMC5_IRQScanlineCompare = $5203
MMC5_IRQStatus = $5204
MMC5_Multiplier1 = $5205
MMC5_Multiplier2 = $5206

MMC5_ExpansionRAMStart = $5c00
MMC5_ExpansionRAMEnd = $5fff
