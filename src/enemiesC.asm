INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/entities.inc"

SECTION "Enemy C", ROM0
UpdateEnemyC::
    push hl
    call EnemyBounceOnWallMovement
    pop hl
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

    ld a, d ; a = updateFrameCounter

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .upDirAttack 
    ld bc, EnemyAAnimation.upAnimation
    jr .endDir
.upDirAttack
    ld bc, EnemyAAnimation.attackUpAnimation
    jr .endDir

.downDir
    cp a, DIR_DOWN
    jr nz, .rightDir

    ld a, d ; a = updateFrameCounter

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME  ; check state and init proper animation
    jr nc, .downDirAttack 
    ld bc, EnemyAAnimation.downAnimation
    jr .endDir
.downDirAttack
    ld bc, EnemyAAnimation.attackDownAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir

    ld a, d ; a = updateFrameCounter

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .rightDirAttack
    ld bc, EnemyAAnimation.rightAnimation
    jr .endDir
.rightDirAttack
    ld bc, EnemyAAnimation.attackRightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .leftDirAttack
    ld bc, EnemyAAnimation.leftAnimation
    jr .endDir
.leftDirAttack
    ld bc, EnemyAAnimation.attackLeftAnimation
    jr .endDir

.endDir
    ld de, EnemySpriteData.enemyASpriteData

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret