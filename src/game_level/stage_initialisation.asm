INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

SECTION "Stage Initialisation", ROM0
InitStage0::
    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage0TileMap)
    mem_copy Stage0TileMap, GameLevelTileMap, Stage0TileMap.end-Stage0TileMap
    mem_copy GameLevelTileMap, _SCRN0, GameLevelTileMap.end-GameLevelTileMap
    
    ; Initialise Player
    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM
    
    set_romx_bank BANK(LevelOneEnemyData)
    call InitEnemiesAndPlaceOnMap
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ret

InitStage1::
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