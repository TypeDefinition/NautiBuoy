INCLUDE "./src/include/entities.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Boss Enemy", ROM0

/*  Update for the boss behavior 
    parameters:
        - hl: enemy address
*/
UpdateEnemyBoss::
    push hl ; PUSH HL = enemy address

    ; check health and determine which behavior from there?
    ; followPlayer and shoot, only change direction if theres a difference of x amt?


.defaultBehavior ; Just follow player and shoot 
    pop hl
    push hl
    call FindPlayerDirectionFromBossAndMove

    pop hl
    push hl
    call EnemyMoveBasedOnDir





    pop hl ; POP hl = enemy address
    call UpdateEnemyBossShadowOAM
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
    ld [hl], a ; init new direction

.end
    ret



/*  Draws the enemyboss
    It is a 32 x 32 sprite,. requires 8 sprites in OAM
    Parameters:
        - hl, enemy address
*/
UpdateEnemyBossShadowOAM:
    push hl ; PUSH HL = enemy address

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

    pop hl ; POP HL = enemy address
    ;ld de, Character_CurrAnimationFrame
    ;add hl, de
    ;ld a, [hl] ; get curr frame

    ;sla a 
    ;sla a ; curr animation frame x 4
    ;add a, c
    ;ld c, a
    ;ld a, b
    ;adc a, 0 ; add offset to animation address: bc + a
    ;ld b, a 


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