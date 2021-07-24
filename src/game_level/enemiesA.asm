SECTION "Enemy A", ROM0

INCLUDE "./src/definitions/definitions.inc"
INCLUDE "./src/include/entities.inc"

/*  Update for enemy type A 
    Behavior:
        - Stays in 1 spot and shoot based on direction
        - mostly based on animation
    Parameters:
    - hl: the starting address of the enemy 
    - a : enemy type
*/
UpdateEnemyA::
    push hl ; PUSH hl = enemy address

    cp a, TYPE_ENEMYA_MOV
    jr nz, .checkShoot

    push hl ; PUSH hl = enemy address
    call EnemyBounceOnWallMovement
    pop hl ; POP hl = enemy address

.checkShoot
    ld de, Character_Direction
    add hl, de ; get direction
    ld a, [hli]
    xor a, %00000001 ; invert last bit, get opposite direction for shooting
    ld c, a ; c = direction

    inc hl
    inc hl
    inc hl

    ld a, [hl] ; first part of updateFrameCounter
    add a, ENEMY_TYPEA_ANIMATION_UPDATE_SPEED
    ld [hli], a ; store the new value
    jr nc, .endUpdateEnemyA

    ; update frames
    ld a, [hl] ; a = int part of updateFrameCounter
    inc a ; add the carry

    cp a, ENEMY_TYPEA_ATTACK_FRAME ; check if shoot
    jr nz, .attackFinish
    pop de ; POP de = enemy address
    push de ; PUSH de = enemy address
 
    push af ; PUSH af = int part of updateFrameCounter
    push hl ; PUSH hl = updateFrameCounter address
    call EnemyShoot
    pop hl ; POP hl = updateFrameCounter address
    pop af ; POP af = int part of updateFrameCounter

.attackFinish
    ; a = int part of updateFrameCounter, hl = updateFrameCounter address
    ld d, a ; reg d = int part of updateFrameCounter
    
    inc hl
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check if go attack state
    jr nz, .updateAnimationFrames

    ; reach attack state, reset variables
    ld a, -1
    ld [hli], a ; currFrame = -1
    ld a, ENEMY_TYPEA_ATTACK_ANIM_MAX_FRAMES
    ld [hl], a ; init max frame to be the attack frames

    dec hl 

.updateAnimationFrames
    ; hl = curr animation frame address, d = int part of updateFrameCounter
    ld a, [hli] ; get curr animation frame
    inc a ; go next frame
    ld b, a ; b stores curr frame

    ld a, [hl] ; get max frames 
    cp a, b
    jr nz, .continueAnimation ; check if reach max frame

    ld b, 0 ; reset curr frame if reach max frame
    
    ; check if in attack mode
    ld a, d ; reg a = updateFrameCounter
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME
    jr c, .continueAnimation

    ld a, ENEMY_TYPEA_WALK_FRAMES
    ld [hl], a ; reset back to idling
    ld d, 0 ; int part of updateFrameCounter = 0

.continueAnimation ; store the relevant animation info
    ; hl = max frames address, d = updateFrameCounter, b = currFrame
    dec hl
    ld a, b
    ld [hl], a ; store curr frame

    dec hl 
    ld a, d 
    ld [hl], a ; store updateFrameCounter

.endUpdateEnemyA
    pop hl ; POP hl = enemy address
    
    call InitEnemyASprite
    ret


/*  Init enemy A sprite
    hl - enemy address 
*/
InitEnemyASprite:
    push hl
    call UpdateEnemyEffects
    pop hl

    ld b, SCREEN_UPPER_OFFSET_Y
    ld c, SCREEN_LEFT_OFFSET_X
    call CheckEnemyInScreen
    and a
    ret z

    inc hl ; offset to get direction
    inc hl
    ld a, [hli] ; check direction of enemy and init sprite data
    push af ; PUSH AF = direction 

    inc hl
    inc hl
    inc hl
    inc hl ; offset to get updateFrameCounter

    ld a, [hl] ; get int part of updateFrameCounter

    ld bc, EnemyAAnimation.upAnimation
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .endDir

.attackAnim
    ld bc, EnemyAAnimation.attackUpAnimation

.endDir
    pop af ; POP af = direction
    and a, DIR_BIT_MASK

    sla a
    sla a ; x 4
    add a, a ; x8

    add a, c
    ld c, a
    ld a, b
    adc a, 0 ; add direction offset to animation address: bc + a
    ld b, a 

    ld a, l ; offset the address back to default
    sub a, Character_UpdateFrameCounter + 1
    ld l, a
    ld a, h
    sbc a, 0
    ld h, a 

    call UpdateEnemySpriteOAM
.end
    ret