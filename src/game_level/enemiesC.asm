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
    inc e
    inc hl

    ld a, [hl] ; take max frames
    cp a, e ; check if reach max frame
    jr nz, .updateCurrFrame
    ld e, 0 ; reset current frames

.updateCurrFrame
    ; e = curr frame, hl = max frame address
    dec hl
    ld a, e
    ld [hl], a ; update curr frame

.endUpdateEnemyC
    pop hl ; POP HL = enemy starting address
    call InitEnemyCSprite
    ret


/*  Init enemy C sprite
    hl - enemy address 
*/
InitEnemyCSprite:
    push hl
    call UpdateEnemyEffects
    pop hl
    
    call CheckEnemyInScreen
    and a
    jr z, .end

    inc hl ; offset to get direction
    inc hl
    ld a, [hli] ; check direction of enemy and init sprite data
    push af ; PUSH AF = direction 

    inc hl
    inc hl
    inc hl
    inc hl ; offset to get updateFrameCounter

    ld a, [hl] ; get int part of updateFrameCounter
    ld d, a ; reg d = updateFrameCounter

    pop af ; POP af = direction
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
    ld bc, EnemyCAnimation.rightAnimation
    jr .endDir

.upDir
    ld bc, EnemyCAnimation.upAnimation
    jr .endDir

.downDir
    ld bc, EnemyCAnimation.downAnimation
    jr .endDir

.leftDir
    ld bc, EnemyCAnimation.leftAnimation

.endDir
    ld a, l
    sub a, Character_UpdateFrameCounter + 1
    ld l, a
    ld a, h
    sbc a, 0
    ld h, a 
    call UpdateEnemySpriteOAM
.end
    ret