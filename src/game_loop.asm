INCLUDE "./src/structs.inc"
INCLUDE "./src/hardware.inc"

SECTION "Main Game Loop", ROM0
MainGameLoop::
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

    jr MainGameLoop

SECTION "VBlank Handler", ROM0

VBlankHandler::
    call ResetOAM
    call hOAMDMA ; Update OAM

    ; TODO:: scrolling or any tile updates here
    ; TODO:: camera stuff here, just fix with player being in center of it
    ; TODO:: any UI stuff here too


    ; get back old state
    pop hl
    pop de
    pop bc
    pop af

    reti
