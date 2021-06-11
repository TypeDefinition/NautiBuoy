INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/hardware.inc"

SECTION "Enemy D", ROM0

/*  Update for enemy type D
    Behavior:
        - When player is in same view as enemy chase after player
        - Will keep chasing player until player or the ghost dies
        - Can go through walls
        - When player died, go back to original spawn location
        - sleep -> chase -> sleep
    Parameters:
    - hl: the starting address of the enemy
*/
UpdateEnemyD::
    push hl ; PUSH HL = enemy address

    ;TODO:: check current state whether
    ; depdending on state go to the correct one


.restState ; check if player can see enemy on screen
    ld a, [wShadowSCData] ; get screen pos y
    ld d, a

    inc hl
    inc hl ; offset address to get posY

    ld a, [hli] ; get enemy pos Y
    sub a, d ; enemy y pos - camera pos y
    jr c, .endUpdateEnemyD

.checkWithinYAxis
    cp a, SCRN_Y ; check if enemy pos is within y screen pos
    jr nc, .endUpdateEnemyD

.checkXOffset
    ld a, [wShadowSCData + 1] ; get screen pos x
    ld d, a

    inc hl
    inc hl ; offset address to get posX

    ld a, [hl]
    sub a, d ; enemy x pos - camera pos x
    jr c, .endUpdateEnemyD

.checkWithinXAxis
    cp a, SCRN_X
    jr nc, .endUpdateEnemyD 

.chaseState ; chase after player
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    inc hl
    inc hl ; offset address to get posY

    ld a, [wPlayer_PosYInterpolateTarget]
    ld b, a
    ld a, [hli]
    cp a, b
    jr z, .checkHorizontal
    ld c, DIR_DOWN
    jr c, .finishFindingPlayer ; player is below enemy
    ld c, DIR_UP
    jr .finishFindingPlayer

.checkHorizontal 
    inc hl
    inc hl ; get x pos

    ld a,  [wPlayer_PosXInterpolateTarget]
    ld b, a
    ld a, [hl]
    cp a, b
    ld c, DIR_RIGHT
    jr c, .finishFindingPlayer ; player on right of enemy
    ld c, DIR_LEFT

.finishFindingPlayer
    ; c = direction

    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    ld de, Character_Direction
    add hl, de
    ld a, c
    ld [hl], a

    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    call EnemyMoveBasedOnDir

.endUpdateEnemyD
    pop hl ; POP HL = enemy address
    call InitEnemyDSprite
    ret


/*  Init enemy Ghost sprite
    hl - enemy address 
*/
InitEnemyDSprite:
    push hl ; PUSH hl = enemy address

    ld de, Character_UpdateFrameCounter + 1
    add hl, de ; offset hl = updateFrameCounter

    ld a, [hl] ; get int part of updateFrameCounter
    ld d, a ; reg d = updateFrameCounter

    pop hl ; POP hl = enemy address
    push hl ; PUSH hl = enemy address
    ld bc, Character_Direction
    add hl, bc 
    ld a, [hl] ; check direction of enemy and init sprite data
    and a, DIR_BIT_MASK

.upDir
    cp a, DIR_UP
    jr nz, .downDir
    ld bc, EnemyAAnimation.upAnimation
    jr .endDir

.downDir
    cp a, DIR_DOWN
    jr nz, .rightDir
    ld bc, EnemyAAnimation.downAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir
    ld bc, EnemyAAnimation.rightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    ld bc, EnemyAAnimation.leftAnimation
    jr .endDir

.endDir
    ld de, EnemySpriteData.enemyCSpriteData

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret