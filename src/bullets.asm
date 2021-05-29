INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"


DEF TOTAL_BULLET_ENTITY = 1

SECTION "Bullets Data", WRAM0
wBulletObjects::
    dstruct Bullet, wBullet0
    dstruct Bullet, wBullet1
    dstruct Bullet, wBullet2
w_BulletObjectPlayerEnd:: ; reserve the first 3 bullets just for the player
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

/*  Searches and returns a non-active bullet within a certain limit

    hl - starting address
    b - number of bullets

    return hl - starting address of available bullet, if no available bullets, return the last bullet
    WARNING: after calling this function, need to check if active anyway, there's no null check...
*/
GetNonActiveBullet:
.startLoop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .endLoop ; found one, end loop
    
    ld b, 0
    ld c, sizeof_Bullet

    add hl, bc ; go to next bullet address

    dec b ; decrement and check
    ld a, b
    cp a, 0
    jr nz, .startLoop

.endLoop
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
    push hl ; for getting back the original startiong address info
    
    inc hl ; skip the flag

    ld a, [hli] ; get direction
    push af ; to get the dir again later
    
    ; get velocity, store in register bc
    ld a, [hli] ; get first part of velocity
    ld b, a
    ld a, [hli] ; get second part of velocity
    ld c, a

    ; store the address of posX here
    ld d, h
    ld e, l
    inc de
    inc de ; incerement by 2 to get the pos x

    pop af ; get back the direction

.dirUp
    cp a, DIR_UP
    jr nz, .dirDown
    tile_collision_check_up_reg 0, .collided, .updateUpPos ; hl address of posy, de address of posX
.updateUpPos
    interpolate_pos_dec_reg
    jp .endUpdateDir

.dirDown
    cp a, DIR_DOWN
    jr nz, .dirRight
    tile_collision_check_down_reg 0, .collided , .updateDownPos ; hl address of posy, de address of posX
.updateDownPos
    interpolate_pos_inc_reg
    jp .endUpdateDir

.dirRight
    cp a, DIR_RIGHT
    jr nz, .dirLeft
    tile_collision_check_right_reg 0, .collided , .updateRightPos
.updateRightPos
    inc hl
    inc hl ; go to pos X address in hl
    interpolate_pos_inc_reg
    jr .endUpdateDir

.dirLeft ; only direction, no need do dir check
    tile_collision_check_left_reg 0, .collided , .updateLeftPos
.updateLeftPos
    inc hl
    inc hl ; go to pos X address in hl
    interpolate_pos_dec_reg
    jr nz, .endUpdateDir

.collided
    ; TEMP CODES
    pop hl
    push hl
    ld [hl], FLAG_INACTIVE


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