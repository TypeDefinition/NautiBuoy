INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/entities.inc"

SECTION "Enemy C", ROM0
/*  Update for enemy type C
    Behavior:
        - Just moves in a certain direction really quickly and bounce off walls
        - Will occassionally shoot in certain directions
*/
UpdateEnemyC::
    push hl ; PUSH HL = enemy starting address 
    call EnemyBounceOnWallMovement

    ; update the frames
    ; start shooting based on the direction available
    pop hl  ; POP HL = enemy starting address 
    push hl ; PUSH HL = enemy starting address 
    ld de, Character_UpdateFrameCounter
    add hl, de

    ld a, [hl] ; first part of updateFrameCounter
    add a, ENEMY_TYPEC_ANIMATION_UPDATE_SPEED
    ld [hli], a ; store the new value
    jr nc, .endUpdateEnemyC

    ; update frames
    ld a, [hli] ; a = int part of updateFrameCounter
    adc a, 0 ; add the carry
    ld d, a ; d = int part of updateFrameCounter

    cp a, ENEMY_TYPEC_SHOOT_FRAME
    ld a, [hl] ; a = currFrame
    ld e, a ; e = currFrame
    jr nz, .continue

    ; check shoot direction and just shoot
    pop hl ; POP hl = enemy starting address
    push hl ; PUSH hl = enemy starting address
    call EnemyShootDir

.endShooting
    ld d, 0 ; reset updateFrameCounter
    ld e, 0

.continue 
    ; d = updateFrameCounter, e = currFrame
    pop hl 
    push hl

    ld bc, Character_UpdateFrameCounter + 1
    add hl, bc
    ld a, d
    ld [hli], a ; update new value to updateFrameCounter

    ; update animation frames and check if more
    inc hl
    ld a, [hl] ; take max frames
    ld b, a ; b = max frames

    inc e
    ld a, e
    cp a, b ; check if reach max frame
    jr nz, .updateCurrFrame
    ld a, 0 ; reset current frames

.updateCurrFrame
    ; a = curr frame, hl = max frame address
    dec hl
    ld [hl], a ; update curr frame

.endUpdateEnemyC
    pop hl ; POP HL = enemy starting address
    call InitEnemyCSprite
    ret


/*  Init enemy C sprite
    hl - enemy address 
*/
InitEnemyCSprite:
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
    ld bc, EnemyCAnimation.upAnimation
    jr .endDir

.downDir
    cp a, DIR_DOWN
    jr nz, .rightDir
    ld bc, EnemyCAnimation.upAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir
    ld bc, EnemyCAnimation.rightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    ld bc, EnemyCAnimation.rightAnimation
    jr .endDir

.endDir
    ld de, EnemySpriteData.enemyCSpriteData

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret