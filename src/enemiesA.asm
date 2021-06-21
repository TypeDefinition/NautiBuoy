SECTION "Enemy A", ROM0

INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/entities.inc"

/*  Update for enemy type A 
    Behavior:
        - Stays in 1 spot and shoot based on direction
        - mostly based on animation
    Parameters:
    - hl: the starting address of the enemy 
*/
UpdateEnemyA::
    push hl ; PUSH hl = enemy address

    ld de, Character_Direction
    add hl, de ; get direction
    ld a, [hli]
    ld c, a ; c = direction

    inc hl
    inc hl
    inc hl

    ld a, [hl] ; first part of updateFrameCounter
    add a, ENEMY_TYPEA_ANIMATION_UPDATE_SPEED
    ld [hli], a ; store the new value
    ld a, [hl] ; a = int part of updateFrameCounter
    ld d, a ; d = int part of updateFrameCounter
    jr nc, .endUpdateEnemyA

    ; update frames
    adc a, 0 ; add the carry

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
    push hl ; PUSH HL = updateFrameCounter address
    inc hl
    push hl ; PUSH HL = curr animation frame address

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check if go attack state
    jr nz, .updateAnimationFrames

    ; reach attack state, update variables
    ld a, -1
    ld [hli], a ; currFrame = -1
    ld a, ENEMY_TYPEA_ATTACK_ANIM_MAX_FRAMES
    ld [hl], a ; init max frame to be the attack frames

.updateAnimationFrames
    pop hl ; POP hl = curr animation frame address
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
    ; d = updateFrameCounter, b = currFrame
    pop hl ; POP hl = updateFrameCounter address
    ld a, d 
    ld [hli], a ; store updateFrameCounter

    ld a, b
    ld [hl], a ; store curr frame

.endUpdateEnemyA
    pop hl ; POP hl = enemy address
    call InitEnemyASprite

    ret


/*  Init enemy A sprite
    hl - enemy address 
*/
InitEnemyASprite:
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
    ld a, d ; a = updateFrameCounter
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .rightDirAttack
    ld bc, EnemyAAnimation.rightAnimation
    jr .endDir
.rightDirAttack
    ld bc, EnemyAAnimation.attackRightAnimation
    jr .endDir

.upDir
    ld a, d ; a = updateFrameCounter
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .upDirAttack 
    ld bc, EnemyAAnimation.upAnimation
    jr .endDir
.upDirAttack
    ld bc, EnemyAAnimation.attackUpAnimation
    jr .endDir

.downDir
    ld a, d ; a = updateFrameCounter
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME  ; check state and init proper animation
    jr nc, .downDirAttack 
    ld bc, EnemyAAnimation.downAnimation
    jr .endDir
.downDirAttack
    ld bc, EnemyAAnimation.attackDownAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .leftDirAttack
    ld bc, EnemyAAnimation.leftAnimation
    jr .endDir
.leftDirAttack
    ld bc, EnemyAAnimation.attackLeftAnimation

.endDir
    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret