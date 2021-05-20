INCLUDE "./src/structs.inc"
INCLUDE "./src/hardware.inc"

SECTION "Main Game Loop", ROM0
MainGameLoop::
    call UpdateInput

    call ResetShawdowOAM

    ; TODO:: insert game logic here
    call HandlePlayerInput

    ; TODO:: update shadow OAM data here
    ld hl, wShadowOAM

    ; temp code, might move this somewhere else
    call UpdatePlayerShadowOAM

    ; Collision Test
    ; Src
    /*
    ld a, 22
    ld [wCollisionArgs.srcPosX], a
    ld a, 5
    ld [wCollisionArgs.srcPosY], a
    ld a, 8
    ld [wCollisionArgs.srcColSize], a

    ; Tgt
    ld a, 5
    ld [wCollisionArgs.tgtPosX], a
    ld a, 5
    ld [wCollisionArgs.tgtPosY], a
    ld a, 8
    ld [wCollisionArgs.tgtColSize], a

    call CollisionCheck
    ld a, [wCollisionArgs.result]
    add a, 48
    */

    halt ; Save power, wait for vblank interrupt
    
    ; Print Collision Result Onto Screen
    ; ld [_SCRN0], a

    jr MainGameLoop

SECTION "VBlank handler", ROM0

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
