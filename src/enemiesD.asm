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

.checkState

    ; check current state here
    ; if rest state, dont even bother updating the animation or render
    ; if 'waking up state' go to end, just render, make sure the animation stuff is updated: 2 - 4
    ; if chase state, to to chase state: after a certain number
    ; if player dies, teleport enemy D to somewhere
    ; rest state if player is nearby, set to 'wake up state'
    ; set all the proper variables like max frames

    ; TODO:: all the reset animation frame properly, able to teleport back to its original location when player died
    ; able to reset its state after player has died

    ; rest state is currently ran every frame, do we want to change this?
    ; run only certain frames?
    ; when it just reach wakeup state, it should start the animation
    ; if it reach chase state, should change the max animation frame and reset the animation counter
    ; rest state has no animation or even need update animation frame since player cant see the enemy

    ld de, Character_UpdateFrameCounter + 1
    add hl, de
    ld a, [hl]

    cp a, ENEMY_TYPED_CHASE_STATE_FRAME
    jr nc, .chaseState ; >=, it is in chase state 

    cp a, ENEMY_TYPED_WAKEUP_STATE_FRAME
    jr nc, .updateAnimation ; >=, it is waking up

.restState ; check if player can see enemy on screen
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

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

    jr .updateAnimation ; start waking up

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

.updateAnimation
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    ld de, Character_UpdateFrameCounter
    add hl, de
    ld a, [hl]
    add a, ENEMY_TYPED_ANIMATION_UPDATE_SPEED
    ld [hli], a ; update fraction part of updateFrameCounter
    jr nc, .endUpdateEnemyD

.updateFrames
    ; hl = enemy update frame counter + 1 address
    ld a, [hl]
    inc a
    ; TODO:: make sure to check for overflow when attack mode
    ld [hli], a ; int part of update frame counter
    
    ld a, [hli]
    inc a  ; update animation frames
    ld b, a ; b = curr animation frame

    ld a, [hl] ; get max frames 
    cp a, b
    jr nz, .continueUpdateFrames

    ld b, 0 ; reset frame

.continueUpdateFrames
    ; b = curr animation frame, hl = enemy max frame address
    dec hl
    ld a, b
    ld [hl], a ; store curr animation frame */

.endUpdateEnemyD
    pop hl ; POP HL = enemy address
    call InitEnemyDSprite ; DONT EVEN HAVE TO RENDER IF PLAYER NOT ON SAME SCREEN
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

    ASSERT DIR_UP == 0
    and a, a ; cp a, 0
    jr z, .upDir
    ASSERT DIR_DOWN == 1
    dec a
    jr z, .downDir
    ASSERT DIR_LEFT == 2
    dec a
    jr z, .leftDir
    ASSERT DIR_RIGHT > 2

.rightDir
    ld bc, EnemyDAnimation.rightAnimation
    jr .endDir
.upDir
    ld bc, EnemyDAnimation.upAnimation
    jr .endDir
.downDir
    ld bc, EnemyDAnimation.downAnimation
    jr .endDir
.leftDir
    ld bc, EnemyDAnimation.leftAnimation

.endDir

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret