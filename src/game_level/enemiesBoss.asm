INCLUDE "./src/include/entities.inc"
INCLUDE "./src/definitions/definitions.inc"
INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"

SECTION "Boss Data", WRAM0
wBossStateTracker:: ds 1 ; helps keep track of the boss current states and behavior
wPlayerLastPosTracker:: ds 2 ; first half is pos Y, second half is pos X

SECTION "Boss Enemy", ROM0

/*  Update for the boss behavior 
    parameters:
        - hl: enemy address
*/
UpdateEnemyBoss::
    push hl ; PUSH HL = enemy address

    ; once health is lower than a certain value, it will keep doing the berserk behavior
    ; berserk behavior will switch between ramming the player and shooting out the sparks

    ld de, Character_Direction
    add hl, de
    ld a, [hli] ; get direction
    ld c, a

    ld a, [hli] ; get health
    ld b, a ; b = health

    inc hl
    inc hl

    ld a, [hl] ; get fraction part of updateFrameCounter
    add a, ENEMY_BOSS_ANIMATION_UPDATE_SPEED
    ld [hli], a
    
    ; need update animation and updateframecounter int portion
    ld a, [hli] ; get int portion of updateFrameCounter
    ld e, a
    jr nc, .checkHealth

    inc e
    ld a, [hli] ; get curr frame
    inc a
    ld d, a ; d = curr frame

    ld a, [hl] ; get max frames
    cp a, d
    jr nz, .updateCurrFrame

    ld d, 0 ; reset curr frame

.updateCurrFrame
    ; d = curr frame, e = int part of updateFrameCounter, b = health, c = direction
    ld a, d
    dec hl
    ld [hl], a ; update curr frame

.checkHealth
    ld a, b ; get health
    cp a, ENEMY_BOSS_HEALTH_BERSERK
    jr c, .berserkBehavior ; if less than a certain amount, go berserk mode

.defaultBehavior ; Just follow player and shoot
    ; c = direction, e = int part of updateFrameCounter, hl = curr frame address
    ld a, e
    cp a, ENEMY_BOSS_DEFAULT_SHOOT_FRAME
    jr nz, .updateDefaultBehavior

    pop de ; pop de = enemy address
    push de ; push de = enemy address
    push hl ; push hl = int part of updateFrameCounter
    call EnemyShoot
    pop hl ; pop hl = int part of updateFrameCounter
    xor a

.updateDefaultBehavior 
    ; a = int part of updateFrameCounter, hl = int part of updateFrameCounter address
    dec hl
    ld [hl], a ; update int part of updateFrameCounter

    pop hl
    push hl
    call FindPlayerDirectionFromBossAndMove

    pop hl
    push hl
    ;call EnemyMoveBasedOnDir
    jr .end

.berserkBehavior
    ; c = direction, e = int part of updateFrameCounter, hl = curr frame address
    ld a, e
    dec hl
    ld [hl], a ; update int part of updateFrameCounter

    ; check current state
    ld a, [wBossStateTracker]
    cp a, ENEMY_BOSS_STATES_PROJECTILE_BARRAGE
    jr nc, .projectileBarrage
    ;jr .projectileBarrage

.checkRam
    ; c = direction, e = int part of updateFrameCounter, hl = update frame counter address
    pop hl ; POP hl = enemy address
    push hl ; PUSH hl = enemy address

    ld a, e
    cp a, ENEMY_BOSS_START_RAM_FRAME
    jr nc, .ram

    call FindPlayerDirectionFromBossAndMove ; face the player

    ; take note of player last y and x pos
    ld a, [wPlayer_PosYInterpolateTarget]
    ld [wPlayerLastPosTracker], a

    ld a, [wPlayer_PosXInterpolateTarget]
    ld [wPlayerLastPosTracker + 1], a

    jr .end

.ram ; charge in one direction at fast speeds
    call RamMovement
    jr .end

.projectileBarrage
    ; e = int part of updateFrameCounter, hl = update frame counter address
    ld a, e
    cp a, ENEMY_BOSS_BARRAGE_SHOOT_FRAME
    jr nz, .end

    pop de ; pop DE = enemy address
    push de ; push de = enemy address
    push hl ; push hl = update frame counter address
    call EnemyShootDir
    pop hl ; pop hl = update frame counter address

    ld a, ENEMY_BOSS_BARRAGE_SHOOT_FRAME_RESET
    ld [hl], a ; reset updateFrameCounter with the frame resetter amt

    ; add to the state, if the state is more than x amt, change
    ld a, [wBossStateTracker]
    inc a
    cp a, ENEMY_BOSS_RESET_BERSERK
    jr nz, .endProjectileBarrage
    xor a

    ; TODO, REMEMBER TO RESET THE ANIMATION AND UPDATE FRAME COUNTER AMT

.endProjectileBarrage
    ld [wBossStateTracker], a

.end
    pop hl ; POP hl = enemy address
    call UpdateEnemyBossShadowOAM
    ret


/*  Behavior for moving in ram mode
    Paramaters:
        - hl, enemy starting address
*/
RamMovement:
    push hl ; PUSH hl = enemy starting address

    ld b, ENEMY_BOSS_RAM_SPEED
    xor a
    ld c, a
    
    ; hl = pos y address, de = pos x address
    inc hl
    inc hl 

    ld d, h
    ld e, l
    inc de
    inc de
    inc de 
    
    inc de
    inc de
    ld a, [de] ; get direction
    and a, DIR_BIT_MASK ; only want the first 2 bits for move direction
    dec de
    dec de

    ASSERT DIR_UP == 0
    and a, a ; cp a, 0
    jr z, .upDir
    ASSERT DIR_DOWN == 1
    dec a
    jp z, .downDir
    ASSERT DIR_LEFT == 2
    dec a
    jp z, .leftDir
    ASSERT DIR_RIGHT > 2

    ; bc = velocity, hl = pos y address, de = pos x address
.rightDir
    push bc ; PUSH BC = velocity
    tile_collision_check_right_reg BOSS_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    ld h, d
    ld l, e
    interpolate_pos_inc_reg

    ; check if reach up stop pos
    dec hl
    ld a, [hl] ; get x pos
    ld b, a
    ld a, [wPlayerLastPosTracker + 1]
    add a, ENEMY_BOSS_STOP_DIST_OFFSET 
    cp a, b
    jp c, .stopRam

    pop hl ; POP hl = enemy starting address
    ret

.upDir
    push bc ; PUSH BC = velocity
    tile_collision_check_up_reg BOSS_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity

    interpolate_pos_dec_reg

    ; check if reach up stop pos
    dec hl
    ld a, [hl] ; get y pos
    ld b, a
    ld a, [wPlayerLastPosTracker]
    sub a, ENEMY_BOSS_STOP_DIST_OFFSET 
    cp a, b
    jp nc, .stopRam

    pop hl ; POP hl = enemy starting address
    ret

.downDir
    push bc ; PUSH BC = velocity
    tile_collision_check_down_reg BOSS_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    interpolate_pos_inc_reg

    ; check if reach down stop pos
    dec hl
    ld a, [hl] ; get y pos
    ld b, a
    ld a, [wPlayerLastPosTracker]
    add a, ENEMY_BOSS_STOP_DIST_OFFSET 
    cp a, b
    jp c, .stopRam

    pop hl ; POP hl = enemy starting address
    ret

.leftDir
    push bc ; PUSH BC = velocity
    tile_collision_check_left_reg BOSS_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .collideOnWall
    pop bc ; POP BC = velocity
    ld h, d
    ld l, e
    interpolate_pos_dec_reg
    
    ; check if reach left stop pos
    dec hl
    ld a, [hl] ; get x pos
    ld b, a
    ld a, [wPlayerLastPosTracker + 1]
    sub a, ENEMY_BOSS_STOP_DIST_OFFSET 
    cp a, b
    jr nc, .stopRam

    pop hl ; POP hl = enemy starting address
    ret

.collideOnWall
    pop bc ; POP BC = velocity

.stopRam ; reset ram, make it charge again
    pop hl ; POP hl = enemy starting address
    ld de, Character_UpdateFrameCounter + 1
    add hl, de
    ld a, ENEMY_BOSS_RESET_RAM_FRAME
    ld [hl], a ; reset int part of update frame counter

    ; add to the state, if the state is more than x amt, change
    ld a, [wBossStateTracker]
    inc a
    ld [wBossStateTracker], a

   ret



/*  Finds which direction the player is in from the boss and init new direction
    Parameter:
        - hl, starting enemy address
    Register changes:
        - hl
        - af
        - bc
        - de
    Return:
        - a, direction player is in from boss
*/
FindPlayerDirectionFromBossAndMove:
    ; bc = player pos y and x, de = enemy pos y and x
    ld a, [wPlayer_PosYInterpolateTarget]
    ld b, a
    ld a, [wPlayer_PosXInterpolateTarget]
    ld c, a

    inc hl
    inc hl ; offset address to get posY

    ld a, [hli]
    and a, %11111000
    ld d, a
    inc hl
    inc hl ; get x pos
    ld a, [hli]
    and a, %11111000
    ld e, a

    ; prevent prioritizing of vertical, d - b, e - c, then compare which one is larger
    sub a, c ; get x offset
    jr nc, .compareY

    cpl ; invert the value as it underflowed
    inc a
    
.compareY
    push hl
    ld h, a ; h = x offset

    ld a, d ; a = enemy pos y
    sub a, b ; get y offset
    jr nc, .compareOffset

    cpl ; invert the value as it underflowed
    inc a

.compareOffset
    ld l, a ; l = y offset

    sub a, h ; y offset - x offset 
    jr nc, .checkOffset

    cpl ; invert the value as it underflowed
    inc a

.checkOffset
    ld a, l
    cp a, h ; y offset - x offset:
    pop hl
    jr c, .checkHorizontal ; move in the direction with the biggest offset dist 

.checkVertical 
    ld a, d ; a = enemy pos y
    cp a, b
    jr z, .checkHorizontal
    ld a, DIR_DOWN
    jr c, .finishFindingPlayer ; player is below enemy
    ld a, DIR_UP
    jr .finishFindingPlayer

.checkHorizontal 
    ; c = player pos x, e = enemy pos x
    ld a, e
    cp a, c
    ld a, DIR_RIGHT
    jr c, .finishFindingPlayer ; player on right of enemy
    ld a, DIR_LEFT
    jr z, .end

.finishFindingPlayer
    inc hl
    
    ld e, a
    ld a, [hl]
    and a, DIR_BIT_MASK_RMV
    or a, e
    ld [hl], a ; init new direction

.end
    ret



/*  Draws the enemyboss
    It is a 32 x 32 sprite,. requires 8 sprites in OAM
    Parameters:
        - hl, enemy address
*/
UpdateEnemyBossShadowOAM:
    ;push hl ; PUSH HL = enemy address

    inc hl
    inc hl

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
    ld a, [hli] ; get x pos
    sub a, e
    ld e, a ; store x screen pos at c

    inc hl

    ld a, [hli] ; check direction of enemy and init sprite data
    push af ; PUSH AF = direction

    ; TODO FIX THIS HERE
    ld a, [hli] ; get health
    inc hl
    inc hl
    inc hl
    ld a, [hli] ; get updateframecounter int part

    pop af ; pop af = direction
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
    ld bc, BossEnemyAnimation.rightAnimation
    jr .getAnimation
.upDir
    ld bc, BossEnemyAnimation.upAnimation
    jr .getAnimation
.downDir
    ld bc, BossEnemyAnimation.downAnimation
    jr .getAnimation
.leftDir
    ld bc, BossEnemyAnimation.leftAnimation

.getAnimation
    ; hl = curr frame address

    ld a, [hl] ; get curr frame

    sla a 
    sla a 
    sla a
    sla a ; curr animation frame x 16
    add a, c
    ld c, a
    ld a, b
    adc a, 0 ; add offset to animation address: bc + a
    ld b, a


.startUpdateOAM
    ; hl = shadow OAM, d = pos y, e = pos x
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ; top left
    ld a, d
    ld [hli], a ; init screen y Pos

    ld a, e
    sub a, 8
    ld [hli], a ; init screen x pos, first sprite x offset 0

    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; bottom left
    ld a, d
    add a, 16
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    sub a, 8
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; middle top left
    ld a, d
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; middle bottom left
    ld a, d
    add a, 16
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; middle top right
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
    inc bc

    ; middle bottom right
    ld a, d
    add a, 16
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    add a, 8
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; top right
    ld a, d
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    add a, 16
    ld [hli], a ; init screen x pos, second sprite x offset 8
    
    ld a, [bc] ; get sprite ID
    ld [hli], a
    inc bc

    ld a, [bc] ; get flags
    ld [hli], a
    inc bc

    ; bottom right
    ld a, d
    add a, 16
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, e
    add a, 16
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