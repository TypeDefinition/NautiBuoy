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



    pop hl ; POP hl = enemy address
    call UpdateEnemyBossShadowOAM
    ret

InitEnemyBossSprite:
    ret 

/*  Draws the enemyboss
    It is a 32 x 32 sprite,. requires 8 sprites in OAM
*/
UpdateEnemyBossShadowOAM:
    push hl ; PUSH HL = enemy address


.getAnimation
    ;dec hl
    ;dec hl
    ld de, Character_CurrAnimationFrame
    add hl, de
    ld a, [hl] ; get curr frame

    ;sla a 
    ;sla a ; curr animation frame x 4
    ;add a, c
    ;ld c, a
    ;ld a, b
    ;adc a, 0 ; add offset to animation address: bc + a
    ;ld b, a 
    
    ld bc, BossEnemyAnimation.upAnimation


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

.startUpdateOAM
    ; hl = shadow OAM 
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