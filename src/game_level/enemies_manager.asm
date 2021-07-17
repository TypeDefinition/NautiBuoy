INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/definitions/definitions.inc"
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
    Parameters:
        - bc: EnemyStageData address
*/
InitEnemiesAndPlaceOnMap::
    push bc
    mem_set_small wEnemiesData, 0, wEnemiesDataEnd - wEnemiesData ; reset all enemy data
    pop bc

    ld hl, wEnemiesData
    ld a, [bc] ; get number of enemies in level
    ld d, a ; transfer the numbner of enemies to d
    
    ld [wTotalLevelEnemiesNo], a
    ld [wCurrLevelEnemiesNo], a

    inc bc
.loop
    push de ; PUSH DE = loop counter

    ld a, [bc]
    ld [hli], a ; store flag
    inc bc

    inc hl ; skip PosYInterpolateTarget, since init to 0 abv

    ld a, [bc]
    ld d, a
    ld [hli], a ; set first byte of pos y
    inc bc

    inc hl ; skip second byte of pos y = 0
    inc hl ; skip PosXInterpolateTarget = 0

    ld a, [bc]
    ld e, a
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
    inc hl ; skip FlickerEffect

    ; d = pos y, e = pos x
    ld a, d
    ld [hli], a ; spawn pos Y 
    ld a, e
    ld [hli], a ; spawn pos X

    pop de ; POP DE = loop counter

    dec d
    jr nz, .loop
.endloop
    call UpdateEnemyCounterUI
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
    jr .nextLoop
.enemyTypeB ; turtle
    cp a, TYPE_ENEMYB
    jr nz, .enemyTypeC
    call UpdateEnemyB ; call correct update for enemy
    jr .nextLoop
.enemyTypeC
    cp a, TYPE_ENEMYC
    jr nz, .enemyTypeD
    call UpdateEnemyC
    jr .nextLoop
.enemyTypeD ; ghost
    cp a, TYPE_ENEMYD
    jr nz, .enemyBoss
    call UpdateEnemyD
    jr .nextLoop
.enemyBoss
    cp a, TYPE_ENEMY_BOSS
    jr nz, .nextLoop
    call UpdateEnemyBoss
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
    de - enemy address   
    
    registers changed:
    - AF
    - BC
    - DE
    - HL
*/
EnemyShootDir::
    push de ; PUSH DE = enemy address

    ld a, e
    add a, Character_Direction
    ld e, a
    ld a, d
    adc a, 0
    ld d, a

    ld a, [de] ; get direction
    and a, SHOOT_DIR_BIT_MASK 

.shootUp
    bit BIT_SHOOT_UP_CMP, a
    jr z, .shootDown
    ld c, DIR_UP
    pop de ; POP DE = enemy address
    push de ; PUSH DE = enemy address
    push af ; PUSH AF = dir
    call EnemyShoot
    pop af ; POP AF = dir
.shootDown
    bit BIT_SHOOT_DOWN_CMP, a
    jr z, .shootRight
    ld c, DIR_DOWN
    pop de ; POP DE = enemy address
    push de ; PUSH DE = enemy address
    push af ; PUSH AF = dir
    call EnemyShoot
    pop af ; POP AF = dir
.shootRight
    bit BIT_SHOOT_RIGHT_CMP, a
    jr z, .shootLeft
    ld c, DIR_RIGHT
    pop de ; POP DE = enemy address
    push de ; PUSH DE = enemy address
    push af ; PUSH AF = dir
    call EnemyShoot
    pop af ; POP AF = dir
.shootLeft
    bit BIT_SHOOT_LEFT_CMP, a
    jr z, .end
    ld c, DIR_LEFT
    pop de ; POP DE = enemy address
    call EnemyShoot

    ret
.end
    pop de ; POP DE = enemy address
    ret

/*  Attack 
    de - enemy address
    c - direction the bullet will travel

    registers changed:
        - AF
        - BC
        - DE
        - HL

*/
EnemyShoot::
    ; hl - address of bullet, de - address of enemy
    ld hl, w_BulletObjectPlayerEnd
    ld b, ENEMY_BULLET_NUM
    call GetInactiveBullet ; get bullet address, store in hl

    ld a, [hl] ; check if bullet is active
    bit BIT_FLAG_ACTIVE, a
    jr nz, .finishAttack ; if active, finish attack

    ; check what projectile type it should be
    ld a, [de] ; get flags
    and a, BIT_MASK_TYPE

.checkType
    cp a, TYPE_ENEMYA ; check if the squid
    jr nz, .spikeBullet
    ld a, TYPE_BULLET_INK
    jr .initProjectile
    
.spikeBullet
    cp a, TYPE_ENEMYC ; check if the blowfish
    jr nz, .windProjectile
    ld a, TYPE_BULLET_SPIKE
    jr .initProjectile

.windProjectile
    ld a, TYPE_BULLET_WIND

.initProjectile ; set the variables
    ; a = type, de = enemy address, c = dir
    or a, FLAG_ACTIVE | FLAG_ENEMY
    ld [hli], a ; its alive

    ld a, c ; a = c = dir
    ld [hli], a ; load direction

    ld a, BULLET_VELOCITY
    ld [hli], a ; velocity
    xor a
    ld [hli], a ; second part of velocity

    inc de
    inc de ; skip posYinterpolateTarget
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
    
    dec hl
    dec hl
    dec hl

    ld a, [hl]
    and a, DIR_BIT_MASK ; only want the first 2 bits for move direction

    dec hl 
    dec hl

    ld d, h ; de = posX address
    ld e, l

    dec hl ; pos y second half
    dec hl
    dec hl

    ; bc = velocity, hl = posY address, de = posX address
.upDirMove
    cp a, DIR_UP
    jr nz, .downDirMove
    push bc ; PUSH BC = velocity
    tile_collision_check_up_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    interpolate_pos_dec_reg
    jp .end

.downDirMove
    cp a, DIR_DOWN
    jr nz, .rightDirMove
    push bc ; PUSH BC = velocity
    tile_collision_check_down_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    interpolate_pos_inc_reg
    jp .end

.rightDirMove
    cp a, DIR_RIGHT
    jr nz, .leftDirMove
    push bc ; PUSH BC = velocity
    tile_collision_check_right_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_inc_reg
    jr .end

.leftDirMove
    push bc ; PUSH BC = velocity
    tile_collision_check_left_reg ENEMY_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    ld h, d 
    ld l, e ; hl = posX address
    interpolate_pos_dec_reg
    jr .end

.collideOnWall ; move the opposite direction
    pop bc ; POP BC = velocity
    pop hl ; POP HL = enemy starting address
    push hl ; PUSH HL = enemy starting address

    ld de, Character_Direction
    add hl, de
    ld a, [hl]
    xor a, %00000001 ; invert last bit, get opposite direction
    
    ld [hl], a 
.end
    pop hl ; POP HL = enemy starting address
    ret


/*  Enemy just moves in direction set, no collision 
    hl - enemy starting address

    Register changes:
        - af
        - de
        - hl
*/ 
EnemyMoveBasedOnDir::
    ld de, Character_Velocity + 1
    add hl, de
    ld a, [hl]
    ld b, a
    dec hl
    ld a, [hl]
    ld c, a ; bc = velocity, note the velocity in data is stored in little endian
    
    dec hl
    dec hl
    
    ld a, [hl]

    dec hl
    dec hl
    and a, DIR_BIT_MASK ; only want the first 2 bits for move direction

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

    ; bc = velocity, hl = posX address
.rightDir
    interpolate_pos_inc_reg
    jr .end
.upDir
    dec hl
    dec hl
    dec hl
    interpolate_pos_dec_reg
    jr .end
.downDir
    dec hl
    dec hl
    dec hl
    interpolate_pos_inc_reg
    jr .end
.leftDir
    interpolate_pos_dec_reg

.end
    ret


/*  Update the flicker effect in enemy 
    Parameters:
        - hl: address of enemy
    Registers changed:
        - af
        - de
        - hl
    Return:
        - hl: flicker effect int address
*/
UpdateEnemyEffects::
    ld de, Character_FlickerEffect
    add hl, de
    ld a, [hli]
    and a, a
    jr z, .end
    
    ld d, a ; b = FlickerEffect int portion
    ld a, [hl] ; get fractional portion
    add a, ENEMY_FLICKER_UPDATE_SPEED
    ld [hl], a ; update fractional portion
    dec hl
    jr nc, .end

    dec d
    ld a, d
    ld [hl], a ; update new interger portion value

.end
    ret


/*  Render and set enemy OAM data and animation 
    Parameters:
        - hl: address of enemy
        - bc: address of enemy animation data
*/
UpdateEnemySpriteOAM::
    push hl ; PUSH HL = enemy address

    ; check if should render this frame
    ld de, Character_FlickerEffect
    add hl, de
    ld a, [hl]

    and a, FLICKER_BITMASK
    jr z, .startUpdateOAM

    pop hl
    ret

.startUpdateOAM
    dec hl
    dec hl
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
    add a, 8
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
    
    ld e, ENEMY_BULLET_COLLIDER_SIZE
    and a, BIT_MASK_TYPE ; check type
    cp a, TYPE_ENEMY_BOSS
    jr nz, .checkCollision

    ld e, BOSS_ENEMY_COLLIDER_SIZE

.checkCollision
    push de ; PUSH DE = collider size for enemy and other entity

    ld a, [hli] ; get enemy pos Y
    ld d, a
    inc hl
    inc hl
    ld a, [hl] ; get enemy pos X
    ld e, a ; d = enemy pos Y, e = enemy position X

    pop hl ; POP HL = collider size for enemy and other entity

    call SpriteCollisionCheck
    and a ; check if a = 0
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
    b - bullet damage

    WARNING: this is assuming health < 127. Want to prevent underflow, we defined bit 7 to be for -ve

    Registers changed:
    - af
    - de
    - hl
*/
HitEnemy::
    push hl ; PUSH hl = enemy address
    
    ld a, b
    cp a, BULLET_POWER_UP_DAMAGE ; if its powerup damage, can hit regardless
    jr z, .hitEnemy

    ld a, [hl] ; get enemy flags
    and a, BIT_MASK_TYPE
    cp a, TYPE_ENEMYB ; check which enemy it is, and whether u can shoot it or not
    jr nz, .hitEnemy

.checkCanHit
    ld de, Character_UpdateFrameCounter + 1
    add hl, de
    ld a, [hl]
    add a, ENEMY_TYPEB_REST_STATE_FRAME
    cp a, ENEMY_TYPEB_REST_STATE_FRAME + ENEMY_TYPEB_ATTACK_STATE_FRAME

    pop hl ; POP hl = enemy address
    jr nc, .end ; enemy B is in attack mode

    push hl ; PUSH hl = enemy address

.hitEnemy
    ; b = deduct health
    ld a, [hl] ; get flags
    and a, BIT_MASK_TYPE
    ld c, a

    ld de, Character_HP
    add hl, de
    ld a, [hl]
    sub a, b ; deduct health
    ld [hl], a ; update hp

    ; check health <= 0
    and a
    jr z, .dead
    cp a, 127
    jr nc, .dead ; value underflowed, go to dead

    ld b, a ; b = health
    ld a, c
    cp a, TYPE_ENEMY_BOSS

    pop hl ; POP HL = enemy address
    push hl ; PUSH HL = enemy address
    call z, BossCheckHealth

.flickerEffect ; not dead, set damage flicker effect
    pop hl ; POP HL = enemy address
    
    ld a, DAMAGE_FLICKER_EFFECT
    ld de, Character_FlickerEffect
    add hl, de
    ld [hli], a ; set the integer portion
    xor a
    ld [hl], a ; reset the fractional portion

    ret

.dead ; dead, turn it inactive
    pop hl ; POP HL = enemy address
    ld a, FLAG_INACTIVE
    ld [hli], a

    ; reduce enemy counter by 1
    ld a, [wCurrLevelEnemiesNo]
    dec a
    jr z, .win
    ld [wCurrLevelEnemiesNo], a

    ; spawn particle effects
    inc hl
    ld a, [hli] ; get y pos
    ld d, a

    inc hl
    inc hl
    ld a, [hl] ; get x pos
    ld e, a

    ld a, b ; a = bullet damage
    ld b, TYPE_PARTICLE_KILL_ENEMY
    ld c, PARTICLE_KILL_ENEMY_ALIVE_TIME
    
    cp a, BULLET_POWER_UP_DAMAGE ; check bullet type from here based on its damage
    jr nz, .continueUpdate

    ld b, TYPE_PARTICLE_POWER_KILL_ENEMY
    ld c, PARTICLE_POWER_KILL_ENEMY_ALIVE_TIME

.continueUpdate
    call SpawnParticleEffect
    call UpdateEnemyCounterUI
    ret
    
.win ; If win, go to win screen.
    call SaveCurrentScore
    
    ; Unlock next stage.
    ld a, [wSelectedStage]
    inc a
    ld [wRWIndex], a
    call UnlockStage

    ld hl, JumpLoadWinScreen
    call SetProgramLoopCallback

.end
    ret

/*  To be called when player gets hit, update things for enemies 
    registers changed:
    - af
    - bc
    - de    
    - hl

*/
PlayerGetsHitEnemyBehavior::
    push hl ; Please don't remove this. This breaks everything. Took me hours to find this. I really want to cry now.
    ; loop through enemy, check type, then call the correct function
    ld hl, wEnemy0
    ld a, [wTotalLevelEnemiesNo]

.startOfEnemyLoop
    push af ; PUSH AF = loop counter

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if enemy alive
    jr z, .nextEnemyLoop

    ; get enemy type and check if got the reset
    and a, BIT_MASK_TYPE

.enemyTypeD ; ghost
    cp a, TYPE_ENEMYD
    jr nz, .nextEnemyLoop
    push hl ; PUSH hl = enemy address
    call ResetEnemyD
    pop hl ; POP hl = enemy address

.nextEnemyLoop
    pop af ; POP AF = loop counter
    dec a
    jr z, .end

    ld bc, sizeof_Character
    add hl, bc
    jr .startOfEnemyLoop

.end
    pop hl
    ret

/*  Checks if enemy is on screen 
    hl - enemy address
    Return value: 
    - a = 0/1 for false and true
    - hl = pos X address
    
    Registers changed:
    - af
    - de
    - hl
*/
CheckEnemyInScreen::
    ld e, 0

    ld a, [wShadowSCData] ; get screen pos y
    ld d, a

    inc hl
    inc hl ; offset address to get posY

    ld a, [hli] ; get enemy pos Y
    add a, SCREEN_UPPER_OFFSET_Y
    sub a, d ; enemy y pos - camera pos y
    jr c, .endCheck

.checkWithinYAxis
    cp a, VIEWPORT_SIZE_Y + SCREEN_UPPER_OFFSET_Y * 1 ; check if enemy pos is within y screen pos
    jr nc, .endCheck

.checkXOffset
    ld a, [wShadowSCData + 1] ; get screen pos x
    ld d, a

    inc hl
    inc hl ; offset address to get posX

    ld a, [hl]
    add a, SCREEN_LEFT_OFFSET_X
    sub a, d ; enemy x pos - camera pos x
    jr c, .endCheck

.checkWithinXAxis
    cp a, VIEWPORT_SIZE_X + SCREEN_LEFT_OFFSET_X * 2
    jr nc, .endCheck

    ld e, 1 ; is within screen

.endCheck
    ; e = whether on screen or not
    ld a, e
    ret

