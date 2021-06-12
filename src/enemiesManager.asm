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
wTotalLevelEnemiesNo:: ds 1 ; original number of enemies in the level
wCurrLevelEnemiesNo:: ds 1 ; curr enemy level


SECTION "Enemies Manager", ROM0

/*  Read data on where enemy should be and its type
    Initialise the enemy
*/
InitEnemiesAndPlaceOnMap::
    mem_set_small wEnemiesData, 0, wEnemiesDataEnd - wEnemiesData ; reset all enemy data

    ld hl, wEnemiesData
    ld bc, LevelOneEnemyData ; TODO:: make sure address if proper level's enemy data
    ld a, [bc] ; get number of enemies in level
    ld d, a ; transfer the numbner of enemies to d
    
    ld [wTotalLevelEnemiesNo], a
    ld [wCurrLevelEnemiesNo], a

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

    ld a, [bc]
    ld [hli], a ; set CurrStateMaxAnimFrame
    inc bc

    inc hl 
    inc hl ; skip DamageFlickerEffect

    dec d
    jr nz, .loop
.endloop
    ret


UpdateAllEnemies::
    ld hl, wEnemiesData
    
    ld a, [wTotalLevelEnemiesNo] ; get number of enemies in level
    ld d, a

.startOfLoop
    push hl ; PUSH HL = enemy address
    push de ; push DE = loop counter

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .nextLoop

.updateEnemy
    and a, BIT_MASK_TYPE ; get the type only

.enemyTypeA ; turret
    cp a, TYPE_ENEMYA
    jr nz, .enemyTypeB
    call UpdateEnemyA ; call correct update for enemy
.enemyTypeB ; turtle
    cp a, TYPE_ENEMYB
    jr nz, .enemyTypeC
    call UpdateEnemyB ; call correct update for enemy
.enemyTypeC
    cp a, TYPE_ENEMYC
    jr nz, .enemyTypeD
    call UpdateEnemyC
.enemyTypeD ; ghost
    cp a, TYPE_ENEMYD
    jr nz, .nextLoop
    call UpdateEnemyD

.nextLoop
    pop de ; POP de = loop counter
    pop hl ; POP HL = enemy address
    
    dec d
    jr z, .endOfLoop

    ld bc, sizeof_Character
    add hl, bc
    jr .startOfLoop

.endOfLoop
    ret

/*  For enemies shooting in directions it is not facing
    hl - enemy address    
*/
EnemyShootDir::
    push bc
    push de
    push hl

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
    call EnemyShoot
.shootDown
    bit BIT_SHOOT_DOWN_CMP, a
    jr z, .shootRight
    ld c, DIR_DOWN
    call EnemyShoot
.shootRight
    bit BIT_SHOOT_RIGHT_CMP, a
    jr z, .shootLeft
    ld c, DIR_RIGHT
    call EnemyShoot
.shootLeft
    bit BIT_SHOOT_LEFT_CMP, a
    jr z, .end
    ld c, DIR_LEFT
    call EnemyShoot 

.end
    pop hl
    pop de
    pop bc
    
    ret

/*  Attack 
    de - enemy address
    c - direction the bullet will travel
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
    ld [hl], a ; set second byte of pos X for bullet 

.finishAttack
    pop hl
    pop de
    pop bc
    pop af 

    ret


/*  Movement where you move in a direction and when hit wall, move the other way 
    hl: enemy starting address
*/
EnemyBounceOnWallMovement::
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
    and a, DIR_BIT_MASK ; only want the first 2 bits for move direction

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
    jp .end

.downDirMove
    cp a, DIR_DOWN
    jr nz, .rightDirMove
    tile_collision_check_down_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveDown
.moveDown
    interpolate_pos_inc_reg
    jp .end

.rightDirMove
    cp a, DIR_RIGHT
    jr nz, .leftDirMove
    tile_collision_check_right_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveRight
.moveRight
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_inc_reg
    jr .end

.leftDirMove
    tile_collision_check_left_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall, .moveLeft
.moveLeft
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_dec_reg
    jr .end

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
.end
    pop hl ; POP HL = enemy starting address
    ret


/*  Enemy just moves in direction set, no collision */ 
EnemyMoveBasedOnDir::
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
    and a, DIR_BIT_MASK ; only want the first 2 bits for move direction

    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address
    ld de, Character_PosY
    add hl, de ; hl = pos Y address

    ; bc = velocity, hl = posY address
.upDirMove
    cp a, DIR_UP
    jr nz, .downDirMove
    interpolate_pos_dec_reg
    jp .end

.downDirMove
    cp a, DIR_DOWN
    jr nz, .rightDirMove
    interpolate_pos_inc_reg
    jp .end

.rightDirMove
    inc hl
    inc hl
    inc hl
    cp a, DIR_RIGHT
    jr nz, .leftDirMove
    interpolate_pos_inc_reg
    jr .end

.leftDirMove
    interpolate_pos_dec_reg

.end
    pop hl ; POP HL = enemy starting address
    ret

/*  Render and set enemy OAM data and animation 
    Parameters:
        - hl: address of enemy
        - bc: address of enemy animation data
*/
UpdateEnemySpriteOAM::
    push hl ; PUSH HL = enemy address

    ; check if should render this frame
    ld de, Character_DamageFlickerEffect
    add hl, de
    ld a, [hli]
    and a
    jr z, .startUpdateOAM 

    ld d, a ; b = DamageFlickerEffect int portion
    ld a, [hl] ; get fractional portion
    add a, DAMAGE_FLICKER_UPDATE_SPEED
    ld [hl], a ; update fractional portion
    jr nc, .updateFlickerEffect

    dec d
    ld a, d

    dec hl
    ld [hl], a ; update new interger portion value

.updateFlickerEffect
    ; d = DamageFlickerEffect int portion
    ld a, d
    and a, DAMAGE_FLICKER_BITMASK
    cp a, DAMAGE_FLICKER_VALUE
    pop hl ; POP HL = enemy address
    jr z, .end 

    push hl ; PUSH HL = enemy address

.startUpdateOAM
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address

    ld de, Character_CurrAnimationFrame
    add hl, de
    ld a, [hl] ; get curr frame

    sla a 
    sla a ; curr animation frame x 4
    add a, c
    ld c, a
    ld a, b
    adc a, 0 ; add offset to animation address: bc + a
    ld b, a
    
    pop hl ; POP HL = enemy address

    inc hl ; skip flags
    inc hl ; skip PosYInterpolateTarget go to y pos

    ; Convert position from world space to screen space.
    ld a, [wShadowSCData]
    ld d, a
    ld a, [hli] ; get Y pos
    sub a, d
    ld d, a ; store y screen pos at b

    inc hl ; skip second part of y pos
    inc hl ; skip the PosXInterpolateTarget

    ld a, [wShadowSCData + 1]
    ld e, a
    ld a, [hl] ; get x pos
    sub a, e
    ld e, a ; store x screen pos at c

    ; hl = shadow OAM 
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ; start initialising to shadow OAM
    ld a, d
    add a, 8
    ld [hli], a ; init screen y Pos,  first sprite y offset 8

    ld a, e
    ld [hli], a ; init screen x pos, first sprite x offset 0

    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; Init second half of enemy sprite to shadow OAM
    ld a, d
    add a, 8
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    add a, 8
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a

.end
    ret 


/*
    Call to loop through whether an entity collided with any enemies
    b - entity pos Y
    c - entity pos X
    d - entity collider size
    e - enemy collider size
    return value:
        a  : if more than 0, means collided
        hl : enemy collided address
*/
CheckEnemyCollisionLoop::
    ld hl, wEnemy0
    ld a, [wTotalLevelEnemiesNo]

.startOfEnemyLoop
    push af ; PUSH AF = loop counter

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if enemy alive
    jr z, .nextEnemyLoop

    push hl ; PUSH HL = enemy starting address

    inc hl 
    inc hl

    push de ; PUSH DE = collider size for enemy and other entity

    ld a, [hli] ; get enemy pos Y
    ld d, a
    inc hl
    inc hl
    ld a, [hl] ; get enemy pos X
    ld e, a ; d = enemy pos Y, e = enemy position X

    pop hl ; POP HL = collider size for enemy and other entity

    call SpriteCollisionCheck
    cp a, 0
    ld d, h
    ld e, l ; de = collider size for enemy and other entity
    pop hl ; POP HL = enemy starting address 
    jr z, .nextEnemyLoop

    pop af ; POP AF = loop counter
    jr .end

.nextEnemyLoop
    pop af ; POP AF = loop counter
    dec a
    jr z, .end

    push bc ; PUSH BC = player y and x pos
    ld bc, sizeof_Character
    add hl, bc
    pop bc ; POP BC = player y and x pos
    jr .startOfEnemyLoop

.end
    ret


/*  Call this when enemy has been hit 
    hl - enemy address
    TODO:: pass in the amount of damage 

    WARNING: this is assuming health < 127. Want to prevent underflow, we defined bit 7 to be for -ve
*/
HitEnemy::
    push af
    push bc
    push de
    push hl
    
    ; TODO, check which enemy it is, and whether u can shoot it or not

    ld de, Character_HP
    add hl, de
    ld a, [hl]
    sub a, BULLET_DAMAGE ; deduct health
    ld [hl], a ; update hp

    ; check health <= 0
    cp a, 0
    jr z, .dead
    cp a, 127
    jr nc, .dead ; value underflowed, go to dead


.damageFlickerEffect ; not dead, set damage flicker effect
    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address
    
    ld a, DAMAGE_FLICKER_EFFECT
    ld de, Character_DamageFlickerEffect
    add hl, de
    ld [hli], a ; set the integer portion
    xor a
    ld [hl], a ; reset the fractional portion

    pop hl ; POP HL = enemy address
    jr .end

.dead ; dead, turn it inactive
    pop hl ; POP HL = enemy address
    ld a, FLAG_INACTIVE
    ld [hl], a

.end
    pop de
    pop bc
    pop af

    ret


