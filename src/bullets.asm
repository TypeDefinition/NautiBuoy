INCLUDE "./src/hardware.inc"
INCLUDE "./src/structs.inc"
INCLUDE "./src/entities.inc"

DEF BULLET_DATA_SIZE = 8 

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
    ld b, wBulletObjectEnd - wBulletObjects
    push bc ; store counter in reg b

.startLoop
    pop bc
    ld a, b
    cp 0 ; check if end of loop
    jr z, .end

    dec b ; dec counter
    push bc

    ld a, [hl]
    cp a, IS_ALIVE ; check if alive
    jr z, .bulletMovement 

    ; bullet not alive
    ld b, 0
    ld c, BULLET_DATA_SIZE ; based on number of bytes the bullet has
    add hl, bc ; offset to get the next bullet
    jr .startLoop
   
/* Check its direction and update pos */
.bulletMovement
    push hl ; for updating bullet info later

    inc hl

    ; pos stored in register de for later calculatations
    ld a, [hli] ; pos Y
    ld d, a ; put posY in d
    ld a, [hli] ; pos X
    ld e, a ; posX in e

    ld a, [hli] ; get velocity
    ld b, a ; store velocity into b

    ld a, [hli] ; get direction
    
.dirUp
    cp a, PADB_UP
    jr nz, .dirDown
    ld a, d ; get posY
    sub b ; add the velocity
    ld d, a
    jr .endUpdateDir
.dirDown
    cp a, PADB_DOWN
    jr nz, .dirRight
    ld a, d ; get posY
    add b ; add the velocity
    ld d, a
    jr .endUpdateDir
.dirRight
    cp a, PADB_RIGHT
    jr nz, .dirLeft
    ld a, e ; get posX
    add e ; add the velocity
    ld e, a
    jr .endUpdateDir
.dirLeft
    cp a, PADB_DOWN
    jr nz, .endUpdateDir
    ld a, e ; get posX
    sub e ; add the velocity
    ld e, a
.endUpdateDir ; reg d stores Y coord, reg e stores X coord
    
    ; update the bullet data
    pop hl ; get the original starting address of this bullet
    push hl

    inc hl ; TEMP SKIP IS ALIVE var FOR NOW
    ld a, d
    ld [hli], a ; store new y pos
    ld a, e
    ld [hli], a ; store new x pos

    pop hl ; get the original starting address again
    ld b, 0
    ld c, BULLET_DATA_SIZE ; based on number of bytes the bullet has
    jr .startLoop
.end
    ret


/*
    hl - shadow OAM address to start for the bullets
*/
UpdateBulletsShadowOAM::
    ; y, x; tile id, flags




    ret