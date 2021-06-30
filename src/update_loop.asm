INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/hardware.inc"
include "./src/include/hUGE.inc"
include "./src/include/util.inc"

SECTION "Update Loop", ROM0
UpdateLoop::
    set_romx_bank 2 ; player, enemy and bullet sprite data is in rombank 2
    ;ld a, BANK(LevelOneEnemyData)
    ;ld [rROMB0], a
    call UpdateInput

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
    set_romx_bank 5
    call _hUGE_dosound

    rst $0010 ; Wait VBlank

    jr UpdateLoop