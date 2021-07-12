INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

SECTION "Stage Initialisation WRAM", WRAM0
wSelectedStage::
    ds 1

SECTION "Stage Initialisation", ROM0
StageParam::
    ; Stage 0
    db "00"     ; 2-Byte stage name.
    db $01, $20 ; Stage Time in BCD format. (Yes this is in Big Endian.)
    db $00, $50 ; Time (in BCD) to get 2 Stars. (Player gets 1 star as long as they complete the stage.)
    db $00, $90 ; Time (in BCD) to get 3 Stars.

    ; Stage 1
    db "01"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 2
    db "02"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 3
    db "03"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 4
    db "04"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 5
    db "05"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 6
    db "06"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 7
    db "XX"
    db $01, $20
    db $00, $50
    db $00, $90

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
    
    ; Initialise Player
    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM
    
    set_romx_bank BANK(Stage0EnemyData)
    ld bc, Stage0EnemyData
    call InitEnemiesAndPlaceOnMap
    ld bc, Level0PowerUpData
    call InitPowerupsAndPlaceOnMap
    call InitParticleEffects

    ret

InitStage1::
    ; Copy tile map into VRAM.
    set_romx_bank BANK(Stage1TileMap)
    mem_copy Stage1TileMap, wGameLevelTileMap, Stage1TileMap.end-Stage1TileMap
    mem_copy wGameLevelTileMap, _SCRN0, wGameLevelTileMap.end-wGameLevelTileMap

    ; Initialise Player
    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM

    set_romx_bank BANK(Stage0EnemyData)
    ;call InitEnemiesAndPlaceOnMap
    ;call InitPowerupsAndPlaceOnMap
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