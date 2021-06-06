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
    ld a, [hl] ; a = int part of updateFrameCounter
    adc a, 0 ; add the carry
    ld d, a

    cp a, ENEMY_TYPEC_SHOOT_FRAME
    jr nz, .continue

    ; check shoot direction and just shoot
    pop hl ; POP hl = enemy starting address
    push hl ; PUSH hl = enemy starting address
    ld d, h ; de = enemy address
    ld e, l
    ld bc, Character_Direction
    add hl, bc
    ld a, [hl] ; get direction
    and a, SHOOT_DIR_BIT_MASK 

.shootUp
    bit BIT_SHOOT_UP_CMP, a
    jr z, .shootDown
    ld c, DIR_UP
    ld de, wEnemy0_Flags
    call EnemyShoot
.shootDown
    bit BIT_SHOOT_DOWN_CMP, a
    jr z, .shootRight
    ld c, DIR_DOWN
    ld de, wEnemy0_Flags
    call EnemyShoot
.shootRight
    bit BIT_SHOOT_RIGHT_CMP, a
    jr z, .shootLeft
    ld c, DIR_RIGHT
    ld de, wEnemy0_Flags
    call EnemyShoot
.shootLeft
    bit BIT_SHOOT_LEFT_CMP, a
    jr z, .endShooting
    ld c, DIR_LEFT
    ld de, wEnemy0_Flags
    call EnemyShoot 

.endShooting
    ld d, 0 ; reset updateFrameCounter

.continue 
    ; d = updateFrameCounter
    pop hl 
    push hl

    ld bc, Character_UpdateFrameCounter + 1
    add hl, bc
    ld a, d
    ld [hl], a ; update new value to updateFrameCounter

    ; TODO:: update current animation frames

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

.endDir
    ld de, EnemySpriteData.enemyASpriteData

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret