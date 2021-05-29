INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/movement.inc"


DEF TOTAL_BULLET_ENTITY = 16

SECTION "Bullets Data", WRAM0
wBulletObjects::
    dstruct Bullet, wBullet0
    dstruct Bullet, wBullet1
    dstruct Bullet, wBullet2
    dstruct Bullet, wBullet3
    dstruct Bullet, wBullet4
    dstruct Bullet, wBullet5
    dstruct Bullet, wBullet6
    dstruct Bullet, wBullet7
    dstruct Bullet, wBullet8
    dstruct Bullet, wBullet9
    dstruct Bullet, wBullet10
    dstruct Bullet, wBullet11
    dstruct Bullet, wBullet12
    dstruct Bullet, wBullet13
    dstruct Bullet, wBullet14
    dstruct Bullet, wBullet15
wBulletObjectEnd:


SECTION "Bullets", ROM0

/* reset all bullet data */
ResetAllBullets::
    mem_set_small wBulletObjects, 0, wBulletObjectEnd - wBulletObjects
    ret


/*  Update all alive bullets movement and collision */
UpdateBullets::
    ld hl, wBulletObjects
    ld b, 0
    ld c, TOTAL_BULLET_ENTITY
    push bc ; store counter in reg b

.startLoop
    pop bc
    ld a, c
    cp 0 ; check if end of loop
    jp z, .end

    ld b, 0
    dec c ; dec counter
    push bc

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr nz, .bulletMovement

    ; bullet not alive
    ld c, sizeof_Bullet ; based on number of bytes the bullet has
    add hl, bc ; offset to get the next bullet
    jr .startLoop
   
/* Check its direction and update pos */
.bulletMovement
    push hl ; for updating bullet info later
    
    inc hl ; skip the flag

    ld a, [hli] ; get direction
    ld d, a
    
    ; get velocity, store in register bc
    ld a, [hli] ; get first part of velocity
    ld b, a
    ld a, [hli] ; get second part of velocity
    ld c, a

    ld a, d
.dirUp
    cp a, DIR_UP
    jr nz, .dirDown
    interpolate_pos_dec_reg
    jr .endUpdateDir
.dirDown
    cp a, DIR_DOWN
    jr nz, .dirRight
    interpolate_pos_inc_reg
    jr .endUpdateDir
.dirRight
    inc hl
    inc hl ; go to address of pos X

    cp a, DIR_RIGHT
    jr nz, .dirLeft
    interpolate_pos_inc_reg
    jr .endUpdateDir
.dirLeft
    cp a, DIR_LEFT
    interpolate_pos_dec_reg
    jr nz, .endUpdateDir
.endUpdateDir 
    ; go to next loop
    pop hl ; get the original starting address again
    ld b, 0
    ld c, sizeof_Bullet ; based on number of bytes the bullet has
    add hl, bc ; add the offset to get the next bullet

    jp .startLoop ; have to use jump, address out of reach

.end
    ret


/*
    TODO:: may want to consider moving into UpdateBullet loop
    hl - shadow OAM address to start for the bullets
*/
UpdateBulletsShadowOAM::
    ; y, x; tile id, flags
    ld bc, wBulletObjects ; get the address
    
 /*   ld d, 0
    ld e, TOTAL_BULLET_ENTITY
    push de ; store counter in reg b */

.startLoop
  /*  pop de
    ld a, e
    cp 0 ; check if end of loop
    jr z, .end

    ld d, 0
    dec e ; dec counter
    push de */

    ; check if alive first
    ld a, [bc] ; alive
    bit BIT_FLAG_ACTIVE, a
    jr nz, .showOnScreen

    ; bullet not alive
    ; TODO:: go to next bullet
    jr .endLoop


.showOnScreen
    inc bc

    ld a, [bc] ; get direction
    push af
    inc bc

    inc bc
    inc bc

    ; translate to screen pos
    ld a, [rSCY]
    ld d, a
    ld a, [bc] ; bullet y pos
    sub a, d ; decrease by screen offset
    ld d, a
    
    inc bc ;TEMP
    inc bc

    ld a, [rSCX]
    ld e, a
    ld a, [bc] ; bullet x pos
    sub a, e ; decrease by screen offset
    ld e, a

    inc bc ; last part of posX

    ;inc bc ; direction of bullet
    
    pop af
.upSprite
    cp a, DIR_UP
    jr nz, .downSprite
    ld bc, BulletSprites.upSprite
.downSprite
    cp a, DIR_DOWN
    jr nz, .rightSprite
    ld bc, BulletSprites.downSprite
.rightSprite
    cp a, DIR_RIGHT
    jr nz, .leftSprite
    ld bc, BulletSprites.rightSprite
.leftSprite
    cp a, DIR_LEFT
    jr nz, .endSpriteDir
    ld bc, BulletSprites.leftSprite
.endSpriteDir

    ld a, [bc] ; y offset
    add a, d
    ld [hli], a ; update y pos

    inc bc
    ld a, [bc] ; x offset
    add a, e
    ld [hli], a ; update x pos

    inc bc
    ld a, [bc] ; sprite ID
    ld [hli], a 

    inc bc
    ld a, [bc] ; flags
    ld [hli], a ; flags

.endLoop
    ret