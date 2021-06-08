INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/hardware.inc"
include "./src/include/hUGE.inc"
include "./src/include/util.inc"

SECTION "Update Loop", ROM0
UpdateLoop::
    set_romx_bank 2 ; player, enemy and bullet sprite data is in rombank 2
    call UpdateInput

    call ResetShawdowOAM

    ; insert game logic here
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera
    call UpdatePlayerShadowOAM ; TODO:: update shadow OAM data here

    call UpdateAllEnemies    
    call UpdateBullets

    ; Dirty tiles get updated during HBlank.
    call UpdateDirtyTiles

    ; Update Sound
    set_romx_bank 5
    call _hUGE_dosound

    halt ; Save power, wait for vblank interrupt

    jr UpdateLoop