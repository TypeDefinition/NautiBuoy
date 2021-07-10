INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/definitions/definitions.inc"

; UI Tile Index
DEF UTI_PLAYER_HP EQU 7
DEF UTI_NUM_ENEMIES EQU 10
DEF UTI_GAME_TIMER EQU 1

SECTION "Game Level UI", ROM0
LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

LoadGameLevelUI::
    set_romx_bank BANK(GameLevelUITileMap)
    mem_copy GameLevelUITileMap, _SCRN1, GameLevelUITileMap.end-GameLevelUITileMap
    ld a, 7
    ld [rWX], a
    ld a, SCRN_Y-GAMEPLAY_UI_SIZE_Y
    ld [rWY], a
    ret

UpdateGameTimerUI::
    push af
    push bc

    ; Thousands Place
    ld a, [wGameTimer]
    swap a
    and a, $0F
    add a, "0"
    ld bc, UTI_GAME_TIMER
    call QueueWindowTile

    ; Hundreds Place
    ld a, [wGameTimer]
    and a, $0F
    add a, "0"
    ld bc, UTI_GAME_TIMER + 1
    call QueueWindowTile

    ; Tens Place
    ld a, [wGameTimer+1]
    swap a
    and a, $0F
    add a, "0"
    ld bc, UTI_GAME_TIMER + 2
    call QueueWindowTile
    
    ; Ones Place
    ld a, [wGameTimer+1]
    and a, $0F
    add a, "0"
    ld bc, UTI_GAME_TIMER + 3
    call QueueWindowTile

    pop bc
    pop af
    ret

UpdatePlayerHPUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, [wPlayer_HP]
    add a, "0"
    ld bc, UTI_PLAYER_HP
    call QueueWindowTile

    pop bc
    pop af
    ret

UpdateEnemyCounterUI::
    push hl ; Do not remove this. Will break stuff.

    ld a, [wCurrLevelEnemiesNo]
    add a, "0"
    ld bc, UTI_NUM_ENEMIES
    call QueueWindowTile

    pop hl
    ret