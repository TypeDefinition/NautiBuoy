INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/definitions.inc"

DEF PLAYER_LIVES_UI_TILE_INDEX EQU 34
DEF NUM_ENEMIES_UI_TILE_INDEX EQU 38

SECTION "Game UI", ROM0
InitialiseGameplayUI::
    set_romx_bank 3
    mem_copy GameplayUI, _SCRN1, GameplayUI.end-GameplayUI
    ld a, 7
    ld [rWX], a
    ld a, SCREEN_SIZE_Y-GAMEPLAY_UI_SIZE_Y
    ld [rWY], a
    ret

InitialiseStageEndUI::
    set_romx_bank 3
    mem_copy StageEndUI, _SCRN1, StageEndUI.end-StageEndUI
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a
    ret

UpdatePlayerLivesUI::
    ld hl, rSTAT
    ld a, [wPlayer_HP]
    add a, "0"
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM
    ld [_SCRN1 + PLAYER_LIVES_UI_TILE_INDEX], a
    ret

UpdateEnemyCounterUI::
    ld hl, rSTAT
    ld a, [wCurrLevelEnemiesNo]
    add a, "0"
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM
    ld [_SCRN1 + NUM_ENEMIES_UI_TILE_INDEX], a
    ret