INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Enemy B", ROM0

/* Update for enemy type B
    Behavior:
        - Spin to win
        - moves and when player on same line (x/y axis), wait for a few frames then spin after player
        - when in shell/spinning mode, enemy is invulnerable to bullets 
    Parameters:
    - hl: the starting address of the enemy
*/
UpdateEnemyB::
    ; movement behaviour, goes in opposite direction when hit wall
    push hl ; PUSH HL = enemy starting address
    ld de, Character_Velocity
    add hl, de
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a ; bc = velocity, note the velocity in data is stored in little endian
    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address

    ld de, Character_Direction
    add hl, de
    ld a, [hl]

    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    ld de, Character_PosY
    add hl, de ; hl = pos Y address

    ld d, h
    ld e, l
    inc de
    inc de
    inc de ; de = posX address

    ; bc = velocity, hl = posY address, de = posX address
.upDirMove
    cp a, DIR_UP
    jr nz, .downDirMove
    tile_collision_check_up_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveUp
.moveUp
    interpolate_pos_dec_reg
    jp .endDirMove

.downDirMove
    cp a, DIR_DOWN
    jr nz, .rightDirMove
    tile_collision_check_down_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveDown
.moveDown
    interpolate_pos_inc_reg
    jp .endDirMove

.rightDirMove
    cp a, DIR_RIGHT
    jr nz, .leftDirMove
    tile_collision_check_right_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveRight
.moveRight
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_inc_reg
    jr .endDirMove

.leftDirMove
    tile_collision_check_left_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveLeft
.moveLeft
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_dec_reg
    jr .endDirMove

.collideOnWall ; move the opposite direction
    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    ld de, Character_Direction
    add hl, de

    ; invert last bit to get opposite direction
    ld d, %00000001
    ld a, [hl]
    xor a, d ; invert last bit
    
    ld [hl], a 
    jr .endDirMove

.endDirMove
    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address

    ; TODO:: might want to change animation speed when in attack mode?
    ; if more than ENEMY_TYPEB_ATTACK_STATE_FRAME its in attack mode, remember to offset
    ld de, Character_UpdateFrameCounter
    add hl, de
    ld a, [hl]
    add a, ENEMY_TYPEB_ANIMATION_UPDATE
    ld [hli], a
    jp nc, .endUpdateEnemyB

    ; update frames
    ld a, [hli] ; a = int part of UpdateFrameCounter
    adc a, 0
    ld d, a

    ld a, [hli]
    ld e, a ; e = curr frame
    ld a, d

.normalState ; check if player is same axis
    ; e = curr frame, d = int value of UpdateFrameCounter
    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address

    cp a, 1 
    jr nz, .checkEnterAttackState
    push de ; PUSH de = int value of UpdateFrameCounter & curr frame
    
    ld a, [wPlayer_PosYInterpolateTarget]
    ld d, a
    ld a, [wPlayer_PosXInterpolateTarget]
    ld e, a
    srl d ; convert to tile pos
    srl d
    srl d
    srl e
    srl e
    srl e

    inc hl
    inc hl
    ld a, [hli] ; get pos Y of enemy
    ld b, a
    inc hl
    inc hl
    ld a, [hl] ; get pos X of enemy
    ld c, a
    srl b ; convert to tile pos
    srl b
    srl b
    srl c
    srl c
    srl c

    ; bc = enemy tile pos, de = player tile pos, hl = pos X of enemy
    ld a, b
    cp a, d ; compare y axis
    jr z, .playerOnSameYAxis
    ld a, c
    cp a, e ; compare x axis
    jr z, .playerOnSameXAxis

    ; player not on same axis
    pop de ; POP de = int value of UpdateFrameCounter & curr frame
    ld d, 0 ; currFrame = 0 for normal state
    jr .updateAnimationFrames

.playerOnSameYAxis ; if they are on the same y axis, check x dir, left or right. change direction
    ld a, c
    cp a, e ; compare x axis
    jr nc, .playerLeftOfEnemy
    ld d, DIR_RIGHT
    jr .enemyFacePlayer
.playerLeftOfEnemy
    ld d, DIR_LEFT
    jr .enemyFacePlayer

.playerOnSameXAxis ; if they are on the same x axis, check y dir, up or down
    ld a, b
    cp a, d ; compare y axis
    jr nc, .playerUpOfEnemy
    ld d, DIR_DOWN
    jr .enemyFacePlayer
.playerUpOfEnemy
    ld d, DIR_UP
    jr .enemyFacePlayer

.enemyFacePlayer ; if on same line, properly reset the position to fix to tile, x8 shift left 3 times
    ; bc = enemy tile pos, d = direction, hl = address of pos X
    sla b
    sla b
    sla b

    sla c
    sla c
    sla c

    ld a, c
    ld [hli], a ; init x pos
    inc hl
    ld a, d
    ld [hl], d ; init new dir

    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    ld a, b
    ld [hl], a ; init y pos

    pop de ; POP de = int value of UpdateFrameCounter & curr frame
    jr .updateAnimationFrames 

.checkEnterAttackState ; check if should go attack mode
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME
    jr nz, .checkAttackStop

    ld bc, VELOCITY_SLOW ; set the new velocity
    ld e, ENEMY_TYPEB_ATTACK_ANIM_MAX_FRAMES
    jr .changeVelocityAndFrames

.checkAttackStop ; check if attack should stop -> go rest mode
    cp a, ENEMY_TYPEB_ATTACK_STATE_STOP_FRAME
    jr nz, .updateAnimationFrames

    ld d, -ENEMY_TYPEB_REST_STATE_FRAME
    ld e, ENEMY_TYPEB_WALK_MAX_FRAMES
    ld bc, VELOCITY_VSLOW 

.changeVelocityAndFrames
    ; bc = velocity, d = int value of UpdateFrameCounter, e = max frames

    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    push bc ; PUSH BC = temp, velocity

    ld bc, Character_Velocity
    add hl, bc
    pop bc ; POP BC = temp, velocity
    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a ; reset velocity, store in little endian

    inc hl
    inc hl
    inc hl
    ld [hl], e ; init new max frames 

    ld e, -1 ; reset curr frame

.updateAnimationFrames
    ; e = curr frame, d = int value of UpdateFrameCounter

    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    ld bc, Character_UpdateFrameCounter + 1
    add hl, bc
    ld a, d 
    ld [hli], a ; store updated value for UpdateFrameCounter

    inc e
    inc hl

    ld a, [hl] ; get max frames 
    cp a, e
    jr nz, .continueUpdateAnimation ; check if reach max frame
    ld e, 0 ; reset curr frame if reach max frame

.continueUpdateAnimation
    ; e = curr frame
    dec hl
    ld a, e
    ld [hl], a
    
.endUpdateEnemyB
    pop hl ; POP HL = enemy starting address
    call InitEnemyBSprite
    ret


/* Init enemy B sprite and render */
InitEnemyBSprite:
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
.upDir
    cp a, DIR_UP
    jr nz, .downDir

    ld a, d ; a = updateFrameCounter
    add a, ENEMY_TYPEB_REST_STATE_FRAME ; offset it
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME + ENEMY_TYPEB_REST_STATE_FRAME; check state and init proper animation
    jr nc, .upDownDirAttack
    ld bc, EnemyBAnimation.upAnimation
    jr .endDir

.downDir
    cp a, DIR_DOWN
    jr nz, .rightDir

    ld a, d ; a = updateFrameCounter
    add a, ENEMY_TYPEB_REST_STATE_FRAME ; offset it
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME + ENEMY_TYPEB_REST_STATE_FRAME ; check state and init proper animation
    jr nc, .upDownDirAttack 
    ld bc, EnemyBAnimation.downAnimation
    jr .endDir

.upDownDirAttack ; up and down have same attack animation
    ld bc, EnemyBAnimation.attackUpAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir

    ld a, d ; a = updateFrameCounter
    add a, ENEMY_TYPEB_REST_STATE_FRAME ; offset it
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME + ENEMY_TYPEB_REST_STATE_FRAME ; check state and init proper animation
    jr nc, .leftRightDirAttack
    ld bc, EnemyBAnimation.rightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    add a, ENEMY_TYPEB_REST_STATE_FRAME ; offset it
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME + ENEMY_TYPEB_REST_STATE_FRAME; check state and init proper animation
    jr nc, .leftRightDirAttack
    ld bc, EnemyBAnimation.leftAnimation
    jr .endDir

.leftRightDirAttack ; right and left have same attack animation
    ld bc, EnemyBAnimation.attackRightAnimation

.endDir
    ld de, EnemySpriteData.enemyBSpriteData

    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret