INCLUDE "./src/definitions/definitions.inc"
INCLUDE "./src/include/entities.inc"

SECTION "Enemy C", ROM0
/*  Update for enemy type C
    Behavior:
        - Just moves in a certain direction really quickly and bounce off walls
        - Will occassionally shoot in certain directions
*/
UpdateEnemyC::
    push hl ; PUSH HL = enemy starting address 
    ;call EnemyBounceOnWallMovement

    ; update the frames
    pop hl  ; POP HL = enemy starting address 
    push hl ; PUSH HL = enemy starting address 
    ld de, Character_UpdateFrameCounter
    add hl, de

    ld a, [hl] ; first part of updateFrameCounter
    add a, ENEMY_TYPEC_ANIMATION_UPDATE_SPEED
    ld [hli], a ; store the new value
    jr nc, .endUpdateEnemyC

.updateFrames ; update frames normally
    ld a, [hl] ; a = int part of updateFrameCounter
    inc a
    
.checkGoBackIdleState ; if in last state, reset things properly
    cp a, ENEMY_TYPEC_GO_BACK_IDLE_FRAME
    jr nz, .checkAttackState

    xor a
    ld [hli], a ; update frame counter int
    ld [hli], a ; curr animation frame

    ld a, ENEMY_TYPEC_NORMAL_STATE_MAX_FRAME
    ld [hli], a ; max frame
    jr .endUpdateEnemyC

.checkAttackState
    ; a = int part of update frame counter
    ld [hli], a ; update it from .updateFrame

    cp a, ENEMY_TYPEC_ATTACK_STATE_FRAME ; check if ATTACK state
    jr nz, .checkShoot
    
    xor a
    ld [hli], a ; currFrame = 0
    ld a, ENEMY_TYPEC_ATTACK_STATE_MAX_FRAME
    ld [hli], a ; set max frame for ATTACK state
    jr .endUpdateEnemyC

.checkShoot
    cp a, ENEMY_TYPEC_SHOOT_FRAME
    jr nz, .updateAnimation

    pop de ; POP de = enemy starting address
    push de ; PUSH de = enemy starting address
    push hl ; PUSH HL = currframe address
    call EnemyShootDir
    pop hl ; pop HL = currframe address
 
.updateAnimation
    ; hl = currFrame address
    ld a, [hli] ; a = currFrame

    ; update animation frames and check if more
    inc a
    ld e, a ; e = currFrame

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
    ld a, d
    cp a, ENEMY_TYPEC_ATTACK_STATE_FRAME
    jr c, .normalRight
    ld bc, EnemyCAnimation.attackRightAnimation
    jr .endDir
.normalRight
    ld bc, EnemyCAnimation.rightAnimation
    jr .endDir

.upDir
    ld a, d
    cp a, ENEMY_TYPEC_ATTACK_STATE_FRAME
    jr c, .normalUp
    ld bc, EnemyCAnimation.attackUpAnimation
    jr .endDir
.normalUp
    ld bc, EnemyCAnimation.upAnimation
    jr .endDir

.downDir
    ld a, d
    cp a, ENEMY_TYPEC_ATTACK_STATE_FRAME ; check if use inflate animation
    jr c, .normalDown
    ld bc, EnemyCAnimation.attackDownAnimation
    jr .endDir
.normalDown
    ld bc, EnemyCAnimation.downAnimation
    jr .endDir

.leftDir
    ld a, d
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