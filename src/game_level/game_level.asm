INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Game Level Tiles", WRAM0
GameLevelTiles::
    ds 1024 ; Every game level is made of 1024 tiles.
.end::

SECTION "Game Level Data", WRAM0
wGameTimer::
    ds 2 ; Store the timer as Binary-Coded-Decimals (BCD)
wGameTimerFrac::
    ds 1
.end

SECTION "Game Level", ROM0
; Global Jumps
JumpLoadGameLevel::
    jp LoadGameLevel
; Local Jumps
JumpVBlankHandler:
    jp VBlankHandler
JumpOnUpdate:
    jp OnUpdate

LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

LoadGameLevel::
    di ; Disable Interrupts

    call LCDOff
    call SoundOff
    ld hl, JumpVBlankHandler
    call SetVBlankCallback
    ld hl, JumpOnUpdate
    call SetProgramLoopCallback

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

    call LoadGameLevelUI

    call ResetPlayerCamera
    call ResetAllBullets
    call ResetBGWindowUpdateQueue

    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM
    
    set_romx_bank BANK(LevelOneEnemyData)
    call InitEnemiesAndPlaceOnMap
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    call hOAMDMA ; transfer sprite data to OAM

    ; Reset SCY & SCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; reset timer values
    xor a
    ld [wGameTimerFrac], a
    ld a, $01
    ld [wGameTimer], a
    ld a, $20
    ld [wGameTimer + 1], a
    call UpdateGameTimerUI

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(GameLevelBGM)
    ld hl, GameLevelBGM
    call hUGE_init

    ; Set Interrupt Flags
    ld a, IEF_VBLANK | IEF_STAT
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    ret

OnUpdate:
    call UpdateInput

    set_romx_bank BANK(Sprites)
    call ResetShadowOAM

    ; insert game logic here and update shadow OAM data
    call UpdateLevelTimer ; update timer
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera
    call UpdatePlayerShadowOAM

    call UpdateAllEnemies    
    call UpdateBullets
    call UpdatePowerUpShadowOAM
    call UpdateParticleEffect

    ; Dirty tiles get updated during HBlank.
    call UpdateBGWindow

    ; Update Sound
    set_romx_bank BANK(GameLevelBGM)
    call _hUGE_dosound

    ret

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

; Get the value of the tile, given a tile index.
; @param bc TileIndex
; @return a Tile Value
GetTileValue::
    push hl

    ld hl, GameLevelTiles
    add hl, bc
    ld a, [hl]

    pop hl
    ret

; Set a tile to be updated.
; @param a New Tile Value
; @param bc Tile Index
SetGameLevelTile::
    push af
    push hl
    ld hl, GameLevelTiles
    add hl, bc
    ld [hl], a
    pop hl
    pop af
    call QueueBGTile
    ret

UpdateLevelTimer:
    ; Update timer
    ld a, [wGameTimerFrac]
    add a, TIMER_UPDATE_SPEED
    ld [wGameTimerFrac], a
    ret nc

    ; Load game timer value into hl.
    ld a, [wGameTimer]
    ld h, a
    ld a, [wGameTimer+1]
    ld l, a

    ; hl - 1
    sub a, $01
    daa
    ld l, a
    ld a, h
    sbc a, $00
    daa
    ld h, a

    ; Save new game timer value.
    ld a, h
    ld [wGameTimer], a
    ld a, l
    ld [wGameTimer+1], a

    call UpdateGameTimerUI

    ; If h == l == 0, HP == 0. If HP == 0, lose.
    xor a
    xor h
    xor l
    jr nz, .end

.end
    ret

SECTION "VBlank Data", WRAM0
wShadowSCData::
    ds 2 ; y pos, then x pos