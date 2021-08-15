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
    db 23, 23
    dw_BE $0120
    dw_BE $0060
    dw_BE $0075

    IF DEF(LANGUAGE_EN)
StoryEN0::
    db "Hello Captain! We are honoured to have you aboard the Nauti Buoy!                                                                             "
    db "This our research lab latest state of the art combat submarine.                                                                           "
    db "Your mission is to descend into the first level of the sea and investigate some underwater ruins.                                         "
    db "Beware, we heard reports of some giant squids living there. Be careful and steadfast captain! What is dead may never die."
.end::

StoryEN1::
    db "Congrats on your previous mission!                                                                                                              "
    db "We have reports of another underwater ruins deeper in the sea. You are to head there and check it out.                                      "
    db "We have provided a special torpedo that is able to penetrate through the toughest shell and have scattered them around the site. "
    db "                              Godspeed captain!"
.end::

StoryEN2::
    db "Hello captain! We got another mission for you at another underwater ruin site.                                                               "
    db "We have heard reports of much stronger enemies there.                                                                                              "
    db "Thus, we created an upgrade for the ship that will grant it temperary invincibility.                                                      "
    db "Like the torpedo, we have scattered them around the site.                                                                                     "
    db "Safe journey captain! We look forward to see you and your crew's safely back."
.end::

StoryEN3::
    db "Captain! So far, you have done exception work! Here's your next mission.                                                                           "
    db "Our scientists are having trouble navigating through the underwater ruins at the deeper depths of the sea.         "
    db "They report being attacked by an extremely fast entity that can travel through walls.                                                      "
    db "We have created a temperary power up that will allow you to at much faster speeds. All the best captain!"
.end::

StoryEN4::
    db "Captain, urgent news from the higher ups.                                                                                                       "
    db "After investigating the ruins you have previously cleared, we believe there might be a much more dangerous entity lurking around. "
    db "One that might even threaten the mainland if not dealt with sooner.                                                            "
    db "You are to eliminate all entities at the next site and do a full scale investigation. "
    db "We look forward to see you and your crew's safely back."
.end::

StoryEN5::
    db "Captain! We have reported sightings of the powerful entity. It is reported that it can control electricity.                     "
    db "We are dubbing this entity, codename Mjolnir. You are to report to the site and do your best to kill it. We cannot let it live.            "
    db "This mission is of the upmost importance. We wish you well captain.                                                                         "
    db "What is dead may never die. But rises again harder and stronger."
.end::
    ENDC

    IF DEF(LANGUAGE_JP)
StoryJP0::
    db 78,110,81,114,67,32,102,67,74,79,33,32,75,66,76,110,32,90,66,83,111,72,32,78,110,84,67,32,78,110,77,66
    db 70,110,32,89,32,60,89,45,83,45,94,115,66,62,32,86,32,66,111,103,111,76,112,66,95,78,46,32,74,110,70,66
    db 32,89,32,96,111,76,114,110,32,90,32,70,66,83,66,66,78,71,32,89,32,81,114,67,75,32,83,115,77,46,32,76
    db 70,76,44,32,94,67,74,32,86,102,111,83,32,71,114,80,115,66,85,32,66,70,32,70,115,32,66,105,89,102,67,83
    db 115,77,46,32,71,109,82,73,83,72,80,115,75,66,46
.end::

StoryJP1::
    db 78,110,81,114,67,32,78,115,110,70,66,32,89,32,96,111,76,114,110,32,78,66,74,67,32,69,98,83,115,84,67,74
    db 115,75,115,66,95,77,33,32,74,110,70,66,32,99,111,84,32,92,70,66,32,89,32,84,74,107,32,86,32,94,70,32
    db 89,32,70,66,83,66,66,78,71,32,70,115,32,90,111,73,110,75,106,95,76,80,46,32,95,80,32,81,114,67,75,32
    db 86,32,66,111,83,72,80,115,75,66,46,32,88,110,89,80,98,86,44,32,84,72,93,115,82,85,32,71,115,114,103,66
    db 32,109,32,102,67,66,76,83,44,32,78,110,84,67,32,81,80,66,32,86,32,81,103,90,115,104,95,76,80,46
.end::

StoryJP2::
    db 78,110,81,114,67,44,32,82,71,115,32,89,32,84,74,107,32,86,32,82,102,66,32,70,66,92,115,82,32,70,115,32
    db 66,95,77,46,32,79,89,80,98,44,32,60,89,45,83,45,94,115,66,62,32,70,115,32,76,90,115,103,72,32,92,98
    db 82,86,32,83,115,71,105,32,65,111,92,116,72,115,106,45,84,115,32,109,32,76,115,113,110,91,115,76,95,76,80,46
    db 78,115,110,70,66,32,96,80,66,86,32,78,110,84,67,32,81,80,66,32,86,32,81,103,90,115,104,95,76,80,46
.end::

StoryJP3::
    db 78,110,81,114,67,44,32,108,105,66,32,83,115,77,70,115,32,108,80,76,80,81,32,89,32,78,111,74,67,93,66,32
    db 70,115,32,96,111,76,114,110,32,83,115,32,101,72,68,92,98,66,32,83,115,76,80,46,32,78,111,74,67,93,66,32
    db 70,103,32,75,66,74,115,32,89,32,98,111,78,45,76,115,32,90,32,60,90,100,72,83,32,70,93,115,32,109,32,84
    db 104,87,73,105,62,32,83,115,76,80,46,32,65,79,74,32,89,32,70,66,92,115,82,32,109,32,78,115,110,98,82,76
    db 83,72,80,115,75,66,46,32,70,66,92,115,82,32,70,103,32,86,73,115,103,106,105,102,67,86,32,60,89,45,83,45
    db 94,115,66,62,32,70,115,32,76,90,115,103,72,32,79,72,84,115,32,109,32,90,100,72,77,105,32,65,111,92,116,72
    db 115,106,45,84,115,32,109,32,78,110,84,67,32,81,80,66,32,86,32,81,103,90,115,104,95,76,80,46
.end::

StoryJP4::
    db 78,110,81,114,67,44,32,60,96,114,105,86,105,62,32,84,32,102,90,115,106,83,66,105,32,84,83,99,32,82,102,66
    db 102,67,85,32,70,66,92,115,82,32,70,115,32,90,111,73,110,75,106,95,76,80,46,32,79,89,95,95,85,103,32,80
    db 66,104,72,32,86,99,32,71,73,110,32,70,115,32,65,105,70,99,76,106,95,78,110,46,32,70,66,83,66,66,78,71
    db 32,89,32,99,111,84,99,32,92,70,66,32,84,74,107,32,93,32,66,111,83,44,32,74,89,32,70,66,92,115,82,32
    db 109,32,75,70,115,76,83,72,80,115,75,66,46
.end::

StoryJP5::
    db 78,110,81,114,67,44,32,60,96,114,105,86,105,62,32,109,32,96,82,73,95,76,80,33,90,100,72,32,65,66,82,32
    db 109,32,78,66,92,72,76,83,44,32,76,115,110,105,66,32,109,32,77,72,69,67,33
.end::
    ENDC

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