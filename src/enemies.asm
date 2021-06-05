INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"

SECTION "Enemies Data", WRAM0
wEnemiesData::
    dstruct Character, wEnemy0
    dstruct Character, wEnemy1
    dstruct Character, wEnemy2
    dstruct Character, wEnemy3
    dstruct Character, wEnemy4
    dstruct Character, wEnemy5
    dstruct Character, wEnemy6
    dstruct Character, wEnemy7
wEnemiesDataEnd::


; just make it shoot/attack first?
; and make it so if it got hit by bullet gets destroyed
; and can be rendered
; and aninmated
; make it be able to shoot first

; if got hit by bullet, bullet should check whether hit enemy
; if enemy has been hit, make it dead
; should no longer be rendered

; i need a way to set the enemy pos based on the map too

SECTION "Enemies", ROM0

/*  Read data on where enemy should be and its type
    Initialise the enemy
*/
InitEnemiesAndPlaceOnMap::
    mem_set_small wEnemiesData, 0, wEnemiesDataEnd - wEnemiesData ; reset all enemy data

    ld hl, wEnemiesData
    ld bc, LevelOneEnemyData
    ld a, [bc] ; get number of enemies in level
    ld d, a ; transfer the numbner of enemies to d
    
    inc bc
.loop
    ld a, [bc]
    ld [hli], a ; store flag
    inc bc

    inc hl ; skip PosYInterpolateTarget, since init to 0 abv

    ld a, [bc]
    ld [hli], a ; set first byte of pos y
    inc bc

    inc hl ; skip second byte of pos y = 0
    inc hl ; skip PosXInterpolateTarget = 0

    ld a, [bc]
    ld [hli], a ; set first byte of pos x
    inc hl ;  skip second byte of pos x = 0
    inc bc

    ld a, [bc]
    ld [hli], a ; set direction
    inc bc

    ld a, [bc]
    ld [hli], a ; set health
    inc bc

    ld a, [bc]
    ld [hli], a ; set first part of velocity
    inc bc

    ld a, [bc]
    ld [hli], a ; set second part of velocity
    inc bc

    inc hl ; skip updateFrameCounter
    inc hl ; skip updateFrameCounter
    inc hl ; skip CurrAnimationFrame = 0

    ld a, ENEMY_TYPEA_WALK_FRAMES ; TEMP CODES, initialised this properly
    ld [hli], a ; set CurrStateMaxAnimFrame

    dec d
    ld a, d
    cp a, 0 ; check if initialise all the required enemies yet
    jr nz, .loop
.endloop
    ret


UpdateAllEnemies::
    ld hl, wEnemiesData

    ; TODO:: make update loop
    ; check enemies type and then call the correct update

.startOfLoop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .endOfLoop ; TODO:: fix this, if not alive, for now end loop

.updateEnemy
    ;push hl
    and a, BIT_MASK_TYPE
    ;inc hl ; no need the flags

.enemyTypeA
    cp a, TYPE_ENEMYA ; TODO:: COMPARE BITS, NOT CP
    jr nz, .enemyTypeB
    call UpdateEnemyA ; call correct update for enemy
    jr .endOfLoop
.enemyTypeB
    ;cp a, TYPE_ENEMYB
    ;jr nz, .endOfLoop
    call UpdateEnemyB ; call correct update for enemy

.endOfLoop
    ret


/*  Update for enemy type A 
    Behavior:
        - Stays in 1 spot and shoot based on direction
        - mostly based on animation
    Parameters:
    - hl: the starting address of the enemy 
*/
UpdateEnemyA:
    push hl ; PUSH hl = enemy address

    ld de, Character_Direction
    add hl, de ; get direction
    ld a, [hl]
    ld c, a ; c = direction

    pop hl ; POP hl = enemy address
    push hl ; PUSH hl = enemy address
    ld de, Character_UpdateFrameCounter
    add hl, de

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

    call EnemyShoot

.attackFinish
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

    ld bc, Character_Direction
    add hl, bc 
    ld a, [hl] ; check direction of enemy and init sprite data
.upDir
    cp a, DIR_UP
    jr nz, .downDir

    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.upSprite

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
    ld de, EnemyASprites.downSprite

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME  ; check state and init proper animation
    jr nc, .upDirAttack ; down have the same animation as up
    ld bc, EnemyAAnimation.upAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir

    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.rightSprite

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .rightDirAttack
    ld bc, EnemyAAnimation.rightAnimation
    jr .endDir
.rightDirAttack
    ld bc, EnemyAAnimation.attackRightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.leftSprite

    cp a, ENEMY_TYPEA_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .leftDirAttack
    ld bc, EnemyAAnimation.leftAnimation
    jr .endDir
.leftDirAttack
    ld bc, EnemyAAnimation.attackLeftAnimation
    jr .endDir

.endDir
    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret

/* Update for enemy type B
    Behavior:
        - Spin to win
        - moves and when player on same line (x/y axis), enemy spins after player
        - when in shell/spinning mode, enemy is invulnerable to bullets 
    Parameters:
    - hl: the starting address of the enemy
*/
UpdateEnemyB:
    ; need to make sure player is on same line before using spin attack
    ; if player on same line, and within screen

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
    ; if more than ENEMY_TYPEB_ATTACK_STATE_FRAME its in attack mode
    ld de, Character_UpdateFrameCounter
    add hl, de
    ld a, [hl]
    add a, ENEMY_TYPEB_ANIMATION_UPDATE
    ld [hli], a
    jr nc, .endUpdateEnemyB

    ; update frames
    ld a, [hl] ; a = int part of UpdateFrameCounter
    adc a, 0
    ld d, a

    ; cp a, 1
    ; jr nz, .updateAnimationFrames

    ; if player not nearby, then just set the frame to 0
    ; if player is nearby, start couting frames baby, dont reset shit
    ; more than 0 then reset the frames, if not leave it

    ; check if player should go attack mode
    ; TODO:: set the direction to go towards -> towards where the player is
    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME
    jr nz, .checkAttackStop

    ld bc, VELOCITY_SLOW ; set the new velocity
    ld e, ENEMY_TYPEB_WALK_MAX_FRAMES
    jr .changeVelocityAndFrames

.checkAttackStop ; check if attack should stop -> go rest mode
    cp a, ENEMY_TYPEB_ATTACK_STATE_STOP_FRAME
    jr nz, .updateAnimationFrames

    ld d, ENEMY_TYPEB_REST_STATE_FRAME
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

.updateAnimationFrames
    ; d = int value of UpdateFrameCounter

    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    ld bc, Character_UpdateFrameCounter + 1
    add hl, bc
    ld a, d 
    ld [hli], a ; store updated value for UpdateFrameCounter

    ld a, [hli] ; get current frames
    inc a
    ld b, a ; b = curr frame

    ld a, [hl] ; get max frames 
    cp a, b
    jr nz, .continueUpdateAnimation ; check if reach max frame
    ld b, 0 ; reset curr frame if reach max frame

.continueUpdateAnimation
    ; b = curr frame
    dec hl
    ld a, b
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

    ld bc, Character_Direction
    add hl, bc 
    ld a, [hl] ; check direction of enemy and init sprite data
.upDir
    cp a, DIR_UP
    jr nz, .downDir

    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.upSprite

    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME ; check state and init proper animation
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
    ld de, EnemyASprites.downSprite

    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME  ; check state and init proper animation
    jr nc, .upDirAttack ; down have the same animation as up
    ld bc, EnemyAAnimation.upAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir

    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.rightSprite

    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .rightDirAttack
    ld bc, EnemyAAnimation.rightAnimation
    jr .endDir
.rightDirAttack
    ld bc, EnemyAAnimation.attackRightAnimation
    jr .endDir

.leftDir
    ld a, d ; a = updateFrameCounter
    ld de, EnemyASprites.leftSprite

    cp a, ENEMY_TYPEB_ATTACK_STATE_FRAME ; check state and init proper animation
    jr nc, .leftDirAttack
    ld bc, EnemyAAnimation.leftAnimation
    jr .endDir
.leftDirAttack
    ld bc, EnemyAAnimation.attackLeftAnimation
    jr .endDir

.endDir
    pop hl ; POP HL = enemy address
    call UpdateEnemySpriteOAM
    ret

/* Call this when enemy has been hit */
HitEnemy::
    ; should be passing in the address of the enemy here
    ; should also be passing the amount of damage dealth
    ; deduct health
    ; if health < 0, mens dead, set the variable to dead
    ret

/*  Attack 
    de - enemy address
    c - direction
*/
EnemyShoot::
    push af
    push bc
    push de
    push hl

    inc de ; skip flags
    inc de ; skip posYinterpolateTarget

    ; hl - address of bullet, de - address of enemy
    ld hl, w_BulletObjectPlayerEnd
    ld b, ENEMY_TYPEA_BULLET_NUM
    call GetInactiveBullet ; get bullet address, store in hl

    ld a, [hl] ; check if bullet is active
    bit BIT_FLAG_ACTIVE, a
    jr nz, .finishAttack ; if active, finish attack

    ; set the variables
    ld a, FLAG_ACTIVE | FLAG_ENEMY
    ld [hli], a ; its alive

    ld a, c ; a = c = dir
    ld [hli], a ; load direction

    ; TODO:: SET VELOCITY FOR BULLET BASED ON TYPE LATER
    ld a, $02
    ld [hli], a ; velocity
    xor a
    ld [hli], a ; second part of velocity

    ld a, [de]  ; pos Y
    ld [hli], a ; set first byte of pos Y for bullet
    inc de 

    ld a, [de]  ; pos Y second byte
    ld [hli], a ; set second byte of pos Y for bullet
    inc de ; go to next byte
    inc de ; skip PosXInterpolateTarget

    ld a, [de]  ; pos X first byte
    ld [hli], a ; set first byte of pos X for bullet
    inc de 

    ld a, [de]  ; pos X second byte
    ld [hl], a ; set second byte of pos X for bullet */

.finishAttack
    pop hl
    pop de
    pop bc
    pop af

    ret

/*  Render and set enemy OAM data and animation 
    Parameters:
        - hl: address of enemy
        - bc: address of enemy animation data
        - de: address of enemy sprite data
*/
UpdateEnemySpriteOAM::
    set_romx_bank 2 ; bank for sprites is in bank 2

    ; TODO:: HL NEEDS TO BE THE Y POS
    ;ld hl, wEnemy0_PosYInterpolateTarget
    push hl ; PUSH HL = enemy address

    push bc ; PUSH BC = temp push
    ld bc, Character_CurrAnimationFrame
    add hl, bc
    ld a, [hl] ; get curr frame
    pop bc ; POP BC = temp push
    
    pop hl ; POP HL = enemy address
    push af ; PUSH AF = curr animation frame

    inc hl ; skip flags
    inc hl ; skip PosYInterpolateTarget go to y pos

    push bc ; PUSH bc =  animation address data

    ; Convert position from world space to screen space.
    ld a, [wShadowSCData]
    ld b, a
    ld a, [hli] ; get Y pos
    sub a, b
    ld b, a ; store y screen pos at b

    inc hl ; skip second part of y pos
    inc hl ; skip the PosXInterpolateTarget

    ld a, [wShadowSCData + 1]
    ld c, a
    ld a, [hl] ; get x pos
    sub a, c
    ld c, a ; store x screen pos at c

    ; hl = shadow OAM 
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld a, [wCurrentShadowOAMPtr + 1]
    ld h, a
    push hl ; PUSH HL = starting address of shadow OAM 

    ; start initialising to shadow OAM
    ld a, [de] ; get the sprite offset y
    add b 
    ld [hli], a ; init screen y Pos
    inc de ; inc to get x pos

    ld a, [de] ; get the sprite offset x
    add c
    ld [hli], a ; init screen x pos
    inc de ; inc to get flags

    inc hl ; skip the sprite ID first

    ld a, [de] ; get flags
    ld [hli], a
    inc de

    ; Init second half of enemy sprite to shadow OAM
    ld a, [de] ; get the sprite offset y
    add b
    ld [hli], a ; init screen y Pos
    inc de
    
    ld a, [de] ; get the sprite offset x
    add c
    ld [hli], a ; init screen x pos
    inc de

    inc hl ; skip the sprite id first

    ld a, [de] ; get flags
    ld [hli], a

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ld a, h
    ld a, [wCurrentShadowOAMPtr + 1]
    
    ; update animation
    pop hl ; POP hl = starting address of shadow OAM 
    pop bc ; POP bc = animation address data
    pop af ; POP af = curr animation frame

    sla a ; curr animation frame x 2
    add a, c
    ld c, a
    ld a, 0 ; a = 0
    adc a, b ; add offset to animation address: bc + a
    ld b, a

    ld de, 2
    add hl, de ; ; offset by 2 to go to the sprite ID address
    ld a, [bc]
    ld [hl], a ; store first sprite ID
    inc bc

    ld e, 4
    add hl, de ; ; offset by 4 to go to the sprite ID address
    ld a, [bc]
    ld [hl], a ; store second sprite ID

    ret 
