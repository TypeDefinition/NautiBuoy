INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"

DEF ENEMY_DATA_DIR_OFFSET EQU 6 ; offset from PosYInterpolateTarget to Direction
DEF ENEMY_DATA_UPDATE_FRAME_OFFSET EQU 10 ; offset from PosYInterpolateTarget to UpdateFrameCounter

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
    inc hl ; no need the flags

.enemyTypeA
    cp a, TYPE_ENEMYA
    jr nz, .enemyTypeB
    call UpdateEnemyA ; call correct update for enemy
.enemyTypeB
    cp a, TYPE_ENEMYB
    jr nz, .endOfLoop
    call UpdateEnemyB ; call correct update for enemy

.endOfLoop
    ret


/*  Update for enemy type A 
    Behavior:
        - Stays in 1 spot and shoot based on direction
        - mostly based on animation
    Parameters:
    - hl: the starting address of the enemy from PosYInterpolateTarget onwards
*/
UpdateEnemyA:
    push hl ; keep a copy of the address from PosYInterpolateTarget

    ld bc, ENEMY_DATA_UPDATE_FRAME_OFFSET
    add hl, bc ; offset hl get updateFrameCounter

    ld a, [hl] ; get first part of updateFrameCounter
    add a, ENEMY_TYPEA_ANIMATION_UPDATE
    ld [hli], a ; store the new value
    jr nc, .initSpriteDir ; no carry, means no need update the frames, just go update variables for OAM

    push hl ; store address of updateFrameCounter
    ld a, [hli] ; get second part of updateFrameCounter
    adc a, 0 ; add the carry
    cp a, ENEMY_TYPEA_ATTACK_FRAME
    ld d, a ; reg d = updateFrameCounter
    jr nz, .updateAnimationFrames

    ; reach attack state, update variables
    ld a, ENEMY_TYPEA_ATTACK_ANIM_FRAMES
    inc hl ; skip curr frame
    ld [hl], a ; init max frame to be the attack frames

.updateAnimationFrames
    ld a, [hli] ; get curr animation frame
    inc a ; go next frame
    ld b, a ; b stores curr frame

    ld a, [hl] ; get max frames 
    cp a, b
    jr nz, .continueAnimation ; check if reach max frame

    xor a
    ld b, a ; reset curr frame if reach max frame
    
    ; check if in attack mode
    ld a, d
    cp a, ENEMY_TYPEA_ATTACK_FRAME
    jr nc, .continueAnimation ; if < than just continue

    ld a, ENEMY_TYPEA_WALK_FRAMES
    ld [hl], a ; reset back to idling
    ld d, 0 ; updateFrameCounter = 0

.continueAnimation
    ; d = updateFrameCounter, b = currFrame, e = animation offset
    pop hl ; get updateFrameCounter
    ld a, d 
    ld [hli], a

    ld a, b
    ld [hl], a ; store curr frame

.initSpriteDir
    pop hl ; get the original address
    push hl

    ld bc, ENEMY_DATA_DIR_OFFSET
    add hl, bc ; offset hl by 6 to get the direction
    ld a, [hl] ; check direction of enemy and init sprite data
.upDir
    cp a, DIR_UP
    jr nz, .downDir
    ld de, EnemySprites.upSprite
    ld bc, EnemyAnimation.upAnimation
    jr .endDir

.downDir
    cp a, DIR_DOWN
    jr nz, .rightDir
    ld de, EnemySprites.downSprite
    ld bc, EnemyAnimation.downAnimation
    jr .endDir

.rightDir
    cp a, DIR_RIGHT
    jr nz, .leftDir
    ld de, EnemySprites.rightSprite
    ld bc, EnemyAnimation.rightAnimation
    jr .endDir

.leftDir
    ld de, EnemySprites.leftSprite
    ld bc, EnemyAnimation.leftAnimation

.endDir 


    call UpdateEnemySpriteOAM



;.finishAttack 
    ; after updating curranimation frame, x2 and add to animation address de
    ; push de the animation address
    ; use the hl address of enemy to get x and y first, init to de
    ; hl used for the wshadowOAM instead
    ; after putting value of de to pos x and y and add the bc offset
    ; then initialise the last part flag, and do it again for the other sprite part
    ; pop back de
    ; get the tile id, init it to the correct addresses
    

.endUpdateEnemyA
    pop hl
    ret

/* Update for enemy type B */
UpdateEnemyB:
    ret


/* Call this when enemy has been hit */
HitEnemy::
    ; should be passing in the address of the enemy here
    ; should also be passing the amount of damage dealth
    ; deduct health
    ; if health < 0, mens dead, set the variable to dead
    ret

EnemyShoot::
    ;.attack
    /* TODO:: TEMP CODES:: HL = starting address of PosYInterpolateTarget */
 /*   inc hl ; skip PosYInterpolateTarget
    ld d, h
    ld e, l ; transfer hl, address of enemy to de

    ; hl - address of bullet
    ; de - address of enemy

    ld hl, w_BulletObjectPlayerEnd
    ld b, ENEMY_TYPEA_BULLET_NUM
    call GetInactiveBullet ; get bullet address, store in hl

    ld a, [hl] ; check if bullet is active
    bit BIT_FLAG_ACTIVE, a
    jr nz, .finishAttack ; if active, finish attack

    ; set the variables
    ld a, FLAG_ACTIVE | FLAG_ENEMY
    ld [hli], a ; its alive

    ld a, DIR_UP ; TODO:: change this, reg c is available
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
    ret

/*  Render and set enemy OAM data and animation 
    Parameters:
        - hl: address of enemy pos Y
        - bc: address of enemy animation data
        - de: address of enemy sprite data
*/
UpdateEnemySpriteOAM::
    set_romx_bank 2 ; bank for sprites is in bank 2

    ; TODO:: HL NEEDS TO BE THE Y POS
    ld hl, wEnemy0_PosY

    ; TODO:: bc stores animation address, de stores sprite info address
    ;ld de, EnemySprites.upSprite
    ld bc, EnemyAnimation.upAnimation
    push bc

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

    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld a, [wCurrentShadowOAMPtr + 1]
    ld h, a

    ; start initialising to shadow OAM
    ld a, [de] ; get the sprite offset y
    add b 
    ld [hli], a ; init screen y Pos
    inc de ; inc to get x pos

    ld a, [de] ; get the sprite offset x
    add c
    ld [hli], a ; init screen x pos
    inc de ; inc to get flags

    ld a, 0
    ld [hli], a ; TODO, sprite ID
    ;inc hl ; skip the sprite ID first

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

    ld a, 0
    ld [hli], a ; TODO, sprite ID
    ;inc hl ; skip the sprite id first

    ld a, [de] ; get flags
    ld [hli], a

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ld a, h
    ld a, [wCurrentShadowOAMPtr + 1]
    
    ; update animation
    pop bc
    ret 

/*
EnemyShoot:
    
    ret */
