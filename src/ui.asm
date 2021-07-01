INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/definitions.inc"

DEF PLAYER_LIVES_UI_TILE_INDEX EQU 34
DEF NUM_ENEMIES_UI_TILE_INDEX EQU 38
DEF STAGE_RESULT_UI_TILE_INDEX EQU 74

SECTION "Game UI", ROM0
LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

LoadGameplayUI::
    set_romx_bank BANK(GameplayUI)
    mem_copy GameplayUI, _SCRN1, GameplayUI.end-GameplayUI
    ld a, 7
    ld [rWX], a
    ld a, SCRN_Y-GAMEPLAY_UI_SIZE_Y
    ld [rWY], a
    ret

LoadStageClearedUI::
    push af
    push hl

    call LCDOff

    set_romx_bank BANK(StageEndUI)
    mem_copy StageEndUI, _SCRN1, StageEndUI.end-StageEndUI
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a

    ld hl, _SCRN1+STAGE_RESULT_UI_TILE_INDEX

    ld a, "C"
    ld [hli], a
    ld a, "L"
    ld [hli], a
    ld a, "E"
    ld [hli], a
    ld a, "A"
    ld [hli], a
    ld a, "R"
    ld [hli], a
    ld a, "E"
    ld [hli], a
    ld a, "D"
    ld [hl], a

    call LCDOn

    pop hl
    pop af
    ret

LoadStageFailedUI::
    push af
    push hl

    call LCDOff

    set_romx_bank BANK(StageEndUI)
    mem_copy StageEndUI, _SCRN1, StageEndUI.end-StageEndUI
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a

    ld hl, _SCRN1+STAGE_RESULT_UI_TILE_INDEX

    ld a, "F"
    ld [hli], a
    ld a, "A"
    ld [hli], a
    ld a, "I"
    ld [hli], a
    ld a, "L"
    ld [hli], a
    ld a, "E"
    ld [hli], a
    ld a, "D"
    ld [hl], a

    call LCDOn

    pop hl
    pop af
    ret

UpdatePlayerLivesUI::
    push af ; Do not remove this. Will break stuff.
    push hl ; Do not remove this. Will break stuff.

    ld hl, rSTAT
    ld a, [wPlayer_HP]
    add a, "0"
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM
    ld [_SCRN1 + PLAYER_LIVES_UI_TILE_INDEX], a

    pop hl
    pop af
    ret

UpdateEnemyCounterUI::
    push af ; Do not remove this. Will break stuff.
    push hl ; Do not remove this. Will break stuff.

    ld hl, rSTAT
    ld a, [wCurrLevelEnemiesNo]
    add a, "0"
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM
    ld [_SCRN1 + NUM_ENEMIES_UI_TILE_INDEX], a

    pop hl
    pop af
    ret