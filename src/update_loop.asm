INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/hardware.inc"

SECTION "Update Loop", ROM0
UpdateLoop::
    call UpdateInput

    call ResetShawdowOAM

    ; TODO:: insert game logic here
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera

    call UpdateBullets

    ; TODO:: update shadow OAM data here
    ld hl, wShadowOAM

    ; temp code, might move this somewhere else
    /*  WARNING: the hl address will cascade 
        End hl address for an entity is the starting for the next entity
    */
    call UpdatePlayerShadowOAM
    call UpdateBulletsShadowOAM

    halt ; Save power, wait for vblank interrupt

    jr UpdateLoop