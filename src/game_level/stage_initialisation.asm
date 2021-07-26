INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Stage Initialisation WRAM", WRAM0
wSelectedStage::
    ds 1

SECTION "Stage Initialisation", ROM0
StageParam::
    ; Stage 0
    db "01"     ; 2-Byte stage name.
    dw_BE $0120 ; Stage Time in BCD format. (Yes this is in Big Endian.)
    dw_BE $0070 ; Time (in BCD) to get 2 Stars. (Player gets 1 star as long as they complete the stage.)
    dw_BE $0090 ; Time (in BCD) to get 3 Stars.

    ; Stage 1
    db "02"
    dw_BE $0120
    dw_BE $0070
    dw_BE $0090
    
    ; Stage 2
    db "03"
    dw_BE $0120
    dw_BE $0070
    dw_BE $0085
    
    ; Stage 3
    db "04"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0065
    
    ; Stage 4
    db "05"
    dw_BE $0120
    dw_BE $0040
    dw_BE $0060
    
    ; Stage 5
    db "XX"
    dw_BE $0120
    dw_BE $0060
    dw_BE $0075

Story0::
    db "Yuzu forcefully pushed Mei against the back of the door, her lips not wasting any time as they smashed against her lover."
    db "Her hands running up her outer thighs and hips coming to a stop on the small of her back, as she continued to push herself closer into the darker haired girl."
    db "Their heated, messy kiss not stopping for a moment. She could hear Mei trying to stifle light moans through their kiss as she hastily returned it."
.end::

Story1::
    db "Mei now tightly pressed between the door and Yuzu who continued to let her hands wander, as she began to play with the bottom of Mei's shirt."
    db "Mei let a loud groan as Yuzu grabbed her firmly, lifting her to straddle her waist to which she responded eagerly, wrapping her legs tightly around the assertive blond."
.end::

Story2::
    db "Story Part 3"
.end::

Story3::
    db "Story Part 4"
.end::

Story4::
    db "Story Part 5"
.end::

Story5::
    db "Story Part 6"
.end::

; Get the starting address of the selected stage's parameters.
; @param [wSelectedStage]
; @return hl The starting address of the selected stage's parameters.
; @destroy af, bc
GetSelectedStageParamAddr::
    ld bc, StageParam
    ld h, $00
    ld a, [wSelectedStage]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, bc
    ret

InitStage0::
    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage0TileMap)
    mem_copy Stage0TileMap, wGameLevelTileMap, Stage0TileMap.end-Stage0TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap
    
    ; Set Map Size
    ld a, HIGH(LEVEL0_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVEL0_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVEL0_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVEL0_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    set_romx_bank BANK(Stage0PlayerData)
    ld bc, Stage0EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level0PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ; Initialise Player
    ld hl, Stage0PlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM

    ret

InitStage1::
    ; Set Map Size
    ld a, HIGH(LEVEL1_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVEL1_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVEL1_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVEL1_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage1TileMap)
    mem_copy Stage1TileMap, wGameLevelTileMap, Stage1TileMap.end-Stage1TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    ; Initialise Player
    set_romx_bank BANK(Stage1PlayerData)
    ld bc, Stage1EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level1PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ld hl, Stage1PlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM

    ret

InitStage2::
    ; Set Map Size
    ld a, HIGH(LEVEL2_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVEL2_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVEL2_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVEL2_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage2TileMap)
    mem_copy Stage2TileMap, wGameLevelTileMap, Stage2TileMap.end-Stage2TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    ; Initialise Player
    set_romx_bank BANK(Stage1PlayerData)
    ld bc, Stage2EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level2PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ld hl, Stage2PlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM

    ret

InitStage3::
    ; Set Map Size
    ld a, HIGH(LEVEL3_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVEL3_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVEL3_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVEL3_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage3TileMap)
    mem_copy Stage3TileMap, wGameLevelTileMap, Stage3TileMap.end-Stage3TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    set_romx_bank BANK(Stage1PlayerData)
    ld bc, Stage3EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level3PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ; Initialise Player
    ld hl, Stage3PlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM
    ret

InitStage4::
    ; Set Map Size
    ld a, HIGH(LEVEL4_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVEL4_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVEL4_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVEL4_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage4TileMap)
    mem_copy Stage4TileMap, wGameLevelTileMap, Stage4TileMap.end-Stage4TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    set_romx_bank BANK(Stage1PlayerData)
    ld bc, Stage4EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level4PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ; Initialise Player
    ld hl, Stage4PlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM
    ret

InitStage5::
    xor a
    ld [wBossStateTracker], a

    ; Set Map Size
    ld a, HIGH(LEVELXX_MAP_SIZE_Y)
    ld [wMapSizeY], a
    ld a, LOW(LEVELXX_MAP_SIZE_Y)
    ld [wMapSizeY+1], a

    ld a, HIGH(LEVELXX_MAP_SIZE_X)
    ld [wMapSizeX], a
    ld a, LOW(LEVELXX_MAP_SIZE_X)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(StageXXTileMap)
    mem_copy StageXXTileMap, wGameLevelTileMap, StageXXTileMap.end-StageXXTileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    set_romx_bank BANK(Stage1PlayerData)
    ld bc, StageXXEnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, LevelXXPowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ; Initialise Player
    ld hl, StageXXPlayerData
    call InitialisePlayer
    set_romx_bank BANK(Sprites)
    call UpdatePlayerShadowOAM
    
    ret
