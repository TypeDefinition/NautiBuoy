INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

; UI Tile Index
DEF UTI_LOSE_REASON_EN EQU $89
DEF UTI_LOSE_REASON_JP EQU $82

SECTION "Lose Screen WRAM", WRAM0
wLoseReason::
    ds 1

wBGMTimer:
    ds 2

SECTION "Lose Screen", ROM0
; Global Jumps
JumpLoadLoseScreen::
    jp LoadLoseScreen

; Local Jumps
JumpUpdateLoseScreen:
    jp UpdateLoseScreen
JumpVBlankHandler:
    jp VBlankHandler

LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
    ld [rLCDC], a
    ret

WriteLoseReason:
    ld a, [wLoseReason]
    dec a
    jr z, .hp
.time
    ASSERT LOSE_REASON_TIME == 0

    IF DEF(LANGUAGE_EN)
    ld a, "t"
    ld [_SCRN0 + UTI_LOSE_REASON_EN], a
    ld a, "i"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 1], a
    ld a, "m"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 2], a
    ld a, "e"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 3], a
    ld a, "!"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 4], a
    ENDC

    IF DEF(LANGUAGE_JP)
    ld a, 76
    ld [_SCRN0 + UTI_LOSE_REASON_JP], a
    ld a, 115
    ld [_SCRN0 + UTI_LOSE_REASON_JP + 1], a
    ld a, 70
    ld [_SCRN0 + UTI_LOSE_REASON_JP + 2], a
    ld a, 110
    ld [_SCRN0 + UTI_LOSE_REASON_JP + 3], a
    ENDC

    jr .end
    
.hp
    ASSERT LOSE_REASON_HP == 1

    IF DEF(LANGUAGE_EN)
    ld a, "l"
    ld [_SCRN0 + UTI_LOSE_REASON_EN], a
    ld a, "i"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 1], a
    ld a, "v"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 2], a
    ld a, "e"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 3], a
    ld a, "s"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 4], a
    ld a, "!"
    ld [_SCRN0 + UTI_LOSE_REASON_EN + 5], a
    ENDC

    IF DEF(LANGUAGE_JP)
    ld a, 66
    ld [_SCRN0 + UTI_LOSE_REASON_JP], a
    ld a, 89
    ld [_SCRN0 + UTI_LOSE_REASON_JP + 1], a
    ld a, 81
    ld [_SCRN0 + UTI_LOSE_REASON_JP + 2], a
    ENDC

.end
    ret

LoadLoseScreen:
    di
    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback

    ld hl, JumpUpdateLoseScreen
    call SetProgramLoopCallback

    ; Copy tile data into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData

    IF DEF(LANGUAGE_EN)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataEN)
    mem_copy FontTileDataEN, _VRAM9200, FontTileDataEN.end-FontTileDataEN

    ; Copy tile map into VRAM.
    set_romx_bank BANK(LoseScreenTileMapEN)
    mem_copy LoseScreenTileMapEN, _SCRN0, LoseScreenTileMapEN.end-LoseScreenTileMapEN
    ENDC

    IF DEF(LANGUAGE_JP)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataJP)
    mem_copy FontTileDataJP, _VRAM9200, FontTileDataJP.end-FontTileDataJP

    ; Copy tile map into VRAM.
    set_romx_bank BANK(LoseScreenTileMapJP)
    mem_copy LoseScreenTileMapJP, _SCRN0, LoseScreenTileMapJP.end-LoseScreenTileMapJP
    ENDC


    call WriteLoseReason

    ; Reset SCY & SCX.
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call ResetBGWindowUpdateQueue

    ; Reset BGM Timer
    xor a
    ld [wBGMTimer], a
    ld [wBGMTimer+1], a

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(LoseScreenBGM)
    ld hl, LoseScreenBGM
    call hUGE_init

    ei

    ret

UpdateLoseScreen:
    ; Update Sound (Stop BGM after ~4 seconds.)
    ld a, [wBGMTimer]
    cp a, $01
    call z, SoundOff
    jr z, .getInput
    ld a, [wBGMTimer+1]
    add a, $01
    ld [wBGMTimer+1], a
    ld a, [wBGMTimer]
    adc a, $00
    ld [wBGMTimer], a
    set_romx_bank BANK(LoseScreenBGM)
    call _hUGE_dosound

    ; Get Input
.getInput
    call UpdateInput
    ld a, [wNewlyInputKeys]
    ld b, a
.onB
    bit PADB_B, b
    jr z, .end
    ld a, HIGH(JumpLoadStageSelectScreen)
    ld [wMainMenuDefaultJump], a
    ld a, LOW(JumpLoadStageSelectScreen)
    ld [wMainMenuDefaultJump+1], a
    ld hl, JumpLoadMainMenu
    call SetProgramLoopCallback
    jr .end
.end
    call UpdateBGWindow

    ret

VBlankHandler:
    push af
    ; Check for lag frame.
    ldh a, [hWaitVBlankFlag]
	and a
	jr z, .lagFrame
    ; Reset hWaitVBlankFlag
	xor a
	ldh [hWaitVBlankFlag], a
    push bc
    push de
    push hl

    ; Code Goes Here

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti