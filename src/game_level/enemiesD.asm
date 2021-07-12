INCLUDE "./src/include/entities.inc"
INCLUDE "./src/definitions/definitions.inc"
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

    push hl ; PUSH hl = enemy address
    call UpdateEnemyEffects
    pop hl

.checkState
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

    call CheckEnemyInScreen
    and a
    pop hl ; POP HL = enemy address
    jr z, .end

    push hl ; PUSH HL = enemy address

    jr .updateAnimation ; start waking up

.chaseState ; chase after player
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    inc hl
    inc hl ; offset address to get posY

    ; bc = player pos y and x, de = enemy pos y and z
    ld a, [wPlayer_PosYInterpolateTarget]
    ld b, a
    ld a, [wPlayer_PosXInterpolateTarget]
    ld c, a

    ld a, [hli]
    and a, %11111000
    ld d, a
    inc hl
    inc hl ; get x pos
    ld a, [hli]
    and a, %11111000
    ld e, a

    ; d - b, e - c, then compare which one is larger
    sub a, c ; get x offset
    jr nc, .compareY

    cpl ; invert the value as it underflowed
    inc a
    
.compareY
    ld h, a ; h = x offset

    ld a, d ; a = enemy pos y
    sub a, b ; get y offset
    jr nc, .compareOffset

    cpl ; invert the value as it underflowed
    inc a

.compareOffset
    ld l, a ; l = y offset

    sub a, h ; y offset - x offset 
    jr nc, .checkOffset

    cpl ; invert the value as it underflowed
    inc a

.checkOffset
    ld a, l
    cp a, h ; y offset - x offset: 
    jr c, .checkHorizontal ; move in the direction with the biggest offset dist 
   
.checkVertical
    ld a, d ; a = enemy pos y
    cp a, b
    jr z, .checkHorizontal
    ld c, DIR_DOWN
    jr c, .finishFindingPlayer ; player is below enemy
    ld c, DIR_UP
    jr .finishFindingPlayer

.checkHorizontal 
    ; c = player pos x, e = enemy pos x
    ld a, e
    cp a, c
    ld c, DIR_RIGHT
    jr c, .finishFindingPlayer ; player on right of enemy
    ld c, DIR_LEFT
    jr z, .move

.finishFindingPlayer
    ; c = direction
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    ld de, Character_Direction
    add hl, de
    ld a, c
    ld [hl], a

.move
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
    add a, 1 ; inc doesnt set the carry flag
    sbc a, 0 ; prevents overflow
    
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
    call InitEnemyGhostSprite ; DONT EVEN HAVE TO RENDER IF PLAYER NOT ON SAME SCREEN
.end
    ret

/*  Reset enemy D state when player dies
    hl - enemy address

    registers changed:
        - hl
        - de
        - af
        - bc
*/
ResetEnemyD::
    push hl ; PUSH HL = enemy address

    ; get spawn position
    ld de, Character_SpawnPosition
    add hl, de
    ld a, [hli] 
    ld d, a
    ld a, [hl]
    ld e, a

    ; d = spawn pos y, e = spawn pos x
    pop hl ; POP HL = enemy address

    inc hl
    inc hl

    ld a, d
    ld [hli], a ; update pos Y
    inc hl 
    inc hl

    ld a, e
    ld [hl], a ; update pos x

    ; 8 cycles, offset to get updateFrameCounter
    ld a, (Character_UpdateFrameCounter) - Character_PosX 
    add a, l
    ld l, a
    ld a, h
    adc a, 0
    ld h, a

    xor a
    ld [hli], a ; update fraction part of UpdateFrameCounter
    ld [hli], a ; update int part of UpdateFrameCounter
    ld [hl], a ; update curr anaimation frame

    ret


/*  Init enemy Ghost sprite
    hl - enemy address 
*/
InitEnemyGhostSprite:
    push hl
    ld de, Character_UpdateFrameCounter + 1
    add hl, de ; offset hl = updateFrameCounter

    ld a, [hl] ; get int part of updateFrameCounter
    cp a, ENEMY_TYPED_CHASE_STATE_FRAME
    jr nc, .chaseStateSprite ; >=, it is in chase state 

    ld bc, EnemyDAnimation.sleepAnimation
    jr .endDir

.chaseStateSprite
    ; a = updateFrameCounter

    ld d, a ; reg d = updateFrameCounter

    ld a, l ; 8 cycles
    sub a, 5
    ld l, a
    ld a, h
    sbc a, 0
    ld h, a ; offset to get direction

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

