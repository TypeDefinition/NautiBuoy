INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/definitions/definitions.inc"

; UI Tile Index
DEF UTI_PLAYER_HP EQU $07
DEF UTI_NUM_ENEMIES EQU $0A
DEF UTI_GAME_TIMER EQU $01
DEF UTI_SPEED_POWERUP EQU $0F
DEF UTI_TORPEDO_POWERUP EQU $10
DEF UTI_INVINCIBILITY_POWERUP EQU $11

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
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, [wCurrLevelEnemiesNo]
    add a, "0"
    ld bc, UTI_NUM_ENEMIES
    call QueueWindowTile

    pop bc
    pop af
    ret

EnableSpeedPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, SPEED_POWERUP_TILE_VALUE
    ld bc, UTI_SPEED_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret

DisableSpeedPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, EMPTY_TILE_VALUE
    ld bc, UTI_SPEED_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret

EnableTorpedoPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, TORPEDO_POWERUP_TILE_VALUE
    ld bc, UTI_TORPEDO_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret

DisableTorpedoPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, EMPTY_TILE_VALUE
    ld bc, UTI_TORPEDO_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret

EnableInvincibilityPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, INVINCIBILITY_POWERUP_TILE_VALUE
    ld bc, UTI_INVINCIBILITY_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret

DisableInvincibilityPowerUpUI::
    push af ; Do not remove this. Will break stuff.
    push bc ; Do not remove this. Will break stuff.

    ld a, EMPTY_TILE_VALUE
    ld bc, UTI_INVINCIBILITY_POWERUP
    call QueueWindowTile

    pop bc
    pop af
    ret