INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

; UI Tile Index
DEF UTI_LOSE_REASON EQU $89

SECTION "Lose Screen WRAM", WRAM0
wLoseReason::
    ds 1

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
    ld a, "t"
    ld [_SCRN0 + UTI_LOSE_REASON], a
    ld a, "i"
    ld [_SCRN0 + UTI_LOSE_REASON + 1], a
    ld a, "m"
    ld [_SCRN0 + UTI_LOSE_REASON + 2], a
    ld a, "e"
    ld [_SCRN0 + UTI_LOSE_REASON + 3], a
    ld a, "!"
    ld [_SCRN0 + UTI_LOSE_REASON + 4], a
    jr .end
.hp
    ASSERT LOSE_REASON_HP == 1
    ld a, "l"
    ld [_SCRN0 + UTI_LOSE_REASON], a
    ld a, "i"
    ld [_SCRN0 + UTI_LOSE_REASON + 1], a
    ld a, "v"
    ld [_SCRN0 + UTI_LOSE_REASON + 2], a
    ld a, "e"
    ld [_SCRN0 + UTI_LOSE_REASON + 3], a
    ld a, "s"
    ld [_SCRN0 + UTI_LOSE_REASON + 4], a
    ld a, "!"
    ld [_SCRN0 + UTI_LOSE_REASON + 5], a
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

    ; Copy tile map into VRAM.
    set_romx_bank BANK(LoseScreenTileMap)
    mem_copy LoseScreenTileMap, _SCRN0, LoseScreenTileMap.end-LoseScreenTileMap

    call WriteLoseReason

    ; Reset SCY & SCX.
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call ResetBGWindowUpdateQueue

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(LoseScreenBGM)
    ld hl, LoseScreenBGM
    call hUGE_init

    ei

    ret

UpdateLoseScreen:
    call UpdateInput

    ; Update Sound
    set_romx_bank BANK(LoseScreenBGM)
    call _hUGE_dosound

    ; Get Input
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