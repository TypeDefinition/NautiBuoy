INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Stage Initialisation WRAM", WRAM0
wSelectedStage::
    ds 1

SECTION "Stage Initialisation", ROM0
StageParam::
    ; Stage 0
    db "00"     ; 2-Byte stage name.
    dw_BE $0120 ; Stage Time in BCD format. (Yes this is in Big Endian.)
    dw_BE $0050 ; Time (in BCD) to get 2 Stars. (Player gets 1 star as long as they complete the stage.)
    dw_BE $0090 ; Time (in BCD) to get 3 Stars.

    ; Stage 1
    db "01"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 2
    db "02"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 3
    db "03"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 4
    db "04"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 5
    db "05"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 6
    db "06"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090
    
    ; Stage 7
    db "XX"
    dw_BE $0120
    dw_BE $0050
    dw_BE $0090

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
    ld a, HIGH($00A8)
    ld [wMapSizeY], a
    ld a, LOW($00A8)
    ld [wMapSizeY+1], a

    ld a, HIGH($00C8)
    ld [wMapSizeX], a
    ld a, LOW($00C8)
    ld [wMapSizeX+1], a

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage1TileMap)
    mem_copy Stage1TileMap, wGameLevelTileMap, Stage1TileMap.end-Stage1TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    ; Initialise Player
    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    call InitialisePlayer
    call UpdatePlayerShadowOAM

    xor a
    ld [wBossStateTracker], a
    set_romx_bank BANK(Stage0EnemyData)
    ld bc, StageXXEnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level0PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ret

InitStage2::
    ret

InitStage3::
    ret

InitStage4::
    ret

InitStage5::
    ret

InitStage6::
    ret

InitStage7::
    ret