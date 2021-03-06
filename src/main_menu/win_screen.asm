INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Win Screen WRAM", WRAM0
wBGMTimer:
    ds 2

SECTION "Win Screen", ROM0
; Global Jumps
JumpLoadWinScreen::
    jp LoadWinScreen

; Local Jumps
JumpUpdateWinScreen:
    jp UpdateWinScreen
JumpVBlankHandler:
    jp VBlankHandler

LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
    ld [rLCDC], a
    ret

LoadWinScreen:
    di
    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback

    ld hl, JumpUpdateWinScreen
    call SetProgramLoopCallback

    ; Copy tile data into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData

    IF DEF(LANGUAGE_EN)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataEN)
    mem_copy FontTileDataEN, _VRAM9200, FontTileDataEN.end-FontTileDataEN

    ; Copy tile map into VRAM.
    set_romx_bank BANK(WinScreenTileMapEN)
    mem_copy WinScreenTileMapEN, _SCRN0, WinScreenTileMapEN.end-WinScreenTileMapEN
    ENDC

    IF DEF(LANGUAGE_JP)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataJP)
    mem_copy FontTileDataJP, _VRAM9200, FontTileDataJP.end-FontTileDataJP

    ; Copy tile map into VRAM.
    set_romx_bank BANK(WinScreenTileMapJP)
    mem_copy WinScreenTileMapJP, _SCRN0, WinScreenTileMapJP.end-WinScreenTileMapJP
    ENDC

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
    set_romx_bank BANK(WinScreenBGM)
    ld hl, WinScreenBGM
    call hUGE_init

    ei

    ret

UpdateWinScreen:
    ; Update Sound (Stop BGM after ~3 seconds.)
    ld a, [wBGMTimer]
    cp a, $02
    call z, SoundOff
    jr z, .getInput
    ld a, [wBGMTimer+1]
    add a, $03
    ld [wBGMTimer+1], a
    ld a, [wBGMTimer]
    adc a, $00
    ld [wBGMTimer], a
    set_romx_bank BANK(WinScreenBGM)
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