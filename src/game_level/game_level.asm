INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Game Level Tiles", WRAM0
GameLevelTiles::
    ds 1024
.end::

SECTION "Game Level", ROM0
LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

OverridehVBlankHandler:
    ld  hl, .override
    ld  c, LOW(hVBlankHandler)
REPT 3 ; The "jp VBlankHandler" instruction is 3 bytes.
    ld  a, [hli]
    ldh [c], a
    inc c
ENDR
    ret
.override
    jp VBlankHandler

LoadGameLevel::
    di ; Disable Interrupts

    call LCDOff
    call OverridehVBlankHandler

    ; Set STAT interrupt flags.
    ld a, VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a

    ; Reset hWaitVBlankFlag.
    xor a
    ld [hWaitVBlankFlag], a

    ; Reset OAM & Shadow OAM
    call ResetOAM
    mem_set_small wShadowOAM, 0, wShadowOAM.end - wShadowOAM
    xor a
    ld [wCurrentShadowOAMPtr], a

    ; Copy textures into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData
    set_romx_bank BANK(Sprites)
    mem_copy Sprites, _VRAM8000, Sprites.end-Sprites

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Level0TileMap)
    mem_copy Level0TileMap, GameLevelTiles, Level0TileMap.end-Level0TileMap
    mem_copy GameLevelTiles, _SCRN0, GameLevelTiles.end-GameLevelTiles

    call LoadGameplayUI

    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM

    call ResetPlayerCamera
    call ResetAllBullets
    call ResetDirtyTiles
    
    set_romx_bank BANK(LevelOneEnemyData)
    call InitEnemiesAndPlaceOnMap
    call InitPowerupsAndPlaceOnMap

    call hOAMDMA ; transfer sprite data to OAM

    ; Reset SCY & SCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call LCDOn

    ; Set BGM
    set_romx_bank BANK(CombatBGM)
    ld hl, CombatBGM
    call hUGE_init

    ; Set Interrupt Flags
    ld a, IEF_VBLANK | IEF_STAT
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    jp UpdateGameLevel

UpdateGameLevel::
    call UpdateInput

    set_romx_bank BANK(Sprites)
    call ResetShadowOAM

    ; insert game logic here and update shadow OAM data
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera
    call UpdatePlayerShadowOAM

    call UpdateAllEnemies    
    call UpdateBullets
    call UpdatePowerUpShadowOAM

    ; Dirty tiles get updated during HBlank.
    call UpdateDirtyTiles

    ; Update Sound
    set_romx_bank BANK(CombatBGM)
    call _hUGE_dosound

    rst $0010 ; Wait VBlank

    jr UpdateGameLevel

VBlankHandler:
    push af
    ; If VBlankHandler was called without waiting for VBlank, the frame lagged.
    ld a, [hWaitVBlankFlag]
    and a
    jr z, .lagFrame
    ; Reset hWaitVBlankFlag
    xor a
    ld [hWaitVBlankFlag], a
    push bc
    push de
    push hl

    ; Enable Sprite Rendering
    ldh a, [hLCDC]
    ldh [rLCDC], a
    
    call hOAMDMA ; Update OAM

    ; Update camera position.
    ld a, [wShadowSCData]
    ld [rSCY], a
    ld a, [wShadowSCData + 1]
    ld [rSCX], a 

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti

SECTION "VBlank Data", WRAM0
wShadowSCData::
    ds 2 ; y pos, then x pos