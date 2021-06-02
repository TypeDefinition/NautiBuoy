INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/hardware.inc"

SECTION "Update Loop", ROM0
UpdateLoop::
    call UpdateInput

    call ResetShawdowOAM

    ; insert game logic here
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera

    call UpdateBullets

    ; TODO:: update shadow OAM data here
    ; temp code, might move this somewhere else
    call UpdatePlayerShadowOAM

    ; Dirty tiles get updated during HBlank.
    call UpdateDirtyTiles

    halt ; Save power, wait for vblank interrupt

    jr UpdateLoop