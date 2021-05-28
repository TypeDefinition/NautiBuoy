INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"

DEF BULLET_DATA_SIZE = 8 
DEF TOTAL_BULLET_ENTITY = 1

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
    jr z, .end

    ld b, 0
    dec c ; dec counter
    push bc

    ld a, [hl]
    cp a, ACTIVE ; check if alive
    jr z, .bulletMovement 

    ; bullet not alive
    ld c, BULLET_DATA_SIZE ; based on number of bytes the bullet has
    add hl, bc ; offset to get the next bullet
    jr .startLoop
   
/* Check its direction and update pos */
.bulletMovement
    push hl ; for updating bullet info later
    inc hl ; skip the isAlive var

    ; pos stored in register de for later calculatations
    ld a, [hli] ; pos Y
    ld d, a ; put posY in d
    ld a, [hli] ; pos X
    ld e, a ; posX in e

    ld a, [hli] ; get velocity
    ld b, a ; store velocity into b

    ld a, [hli] ; get direction
    
.dirUp
    cp a, DIR_UP
    jr nz, .dirDown
    ld a, d ; get posY
    sub b ; add the velocity
    ld d, a
    jr .endUpdateDir
.dirDown
    cp a, DIR_DOWN
    jr nz, .dirRight
    ld a, d ; get posY
    add b ; add the velocity
    ld d, a
    jr .endUpdateDir
.dirRight
    cp a, DIR_RIGHT
    jr nz, .dirLeft
    ld a, e ; get posX
    add b ; add the velocity
    ld e, a
    jr .endUpdateDir
.dirLeft
    cp a, DIR_LEFT
    jr nz, .endUpdateDir
    ld a, e ; get posX
    sub b ; add the velocity
    ld e, a
.endUpdateDir ; reg d stores Y coord, reg e stores X coord
    ; update the bullet data
    pop hl ; get the original starting address of this bullet
    push hl ; push again to keep a copy of original starting address

    inc hl ; TEMP:: SKIP ACTIVE var FOR NOW
    ld a, d
    ld [hli], a ; store new y pos
    ld a, e
    ld [hli], a ; store new x pos


    ; TODO:: Check collision here

    
    ; go to next loop
    pop hl ; get the original starting address again
    ld b, 0
    ld c, BULLET_DATA_SIZE ; based on number of bytes the bullet has
    add hl, bc ; add the offset to get the next bullet
    jr .startLoop

.end
    ret


/*
    TODO:: may want to consider moving into UpdateBullet loop
    hl - shadow OAM address to start for the bullets
*/
UpdateBulletsShadowOAM::
    ; y, x; tile id, flags
    ld bc, wBulletObjects ; get the address
    
    ; TODO:: Check collision here
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
    cp a, ACTIVE
    jr z, .showOnScreen

    ; bullet not alive
    ; TODO:: go to next bullet
    jr .endLoop


.showOnScreen
    inc bc

    ; translate to screen pos
    ld a, [rSCY]
    ld d, a
    ld a, [bc] ; bullet y pos
    sub a, d ; decrease by screen offset
    ld d, a
    
    inc bc

    ld a, [rSCX]
    ld e, a
    ld a, [bc] ; bullet x pos
    sub a, e ; decrease by screen offset
    ld e, a

    inc bc ; velocity
    inc bc ; direction of bullet
    
    ld a, [bc] ; get direction

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