INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"


DEF TOTAL_BULLET_ENTITY = 16

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
    tile_collision_check_up_reg 0, .collided ; hl address of posy, de address of posX
    ; update up pos
    interpolate_pos_dec_reg
    ld bc, BulletSprites.upSprite
    jp .updateShadowOAM

.dirDown
    cp a, DIR_DOWN
    jr nz, .dirRight
    tile_collision_check_down_reg 0, .collided ; hl address of posy, de address of posX
    ; update down pos
    interpolate_pos_inc_reg
    ld bc, BulletSprites.downSprite
    jp .updateShadowOAM

.dirRight
    cp a, DIR_RIGHT
    jr nz, .dirLeft
    tile_collision_check_right_reg 0, .collided
    ; update the right pos
    ld h, d ; de stored the address of posX, transfer it
    ld l, e
    interpolate_pos_inc_reg
    ld bc, BulletSprites.rightSprite
    jr .updateShadowOAM

.dirLeft ; only direction, no need do dir check
    tile_collision_check_left_reg 0, .collided
    ; update the left pos
    ld h, d ; de stored the address of posX, transfer it
    ld l, e
    interpolate_pos_dec_reg
    ld bc, BulletSprites.leftSprite
    jr .updateShadowOAM

.collided ; when collided, make it inactive, go next loop
    pop hl
    ld [hl], FLAG_INACTIVE
    jr .endUpdateDir

.updateShadowOAM
    pop hl ; get starting address
    push hl

    ld d, 0
    ld e, 4
    add hl, de ; offset hl by 4
    
    ; translate to screen pos
    ld a, [rSCY]
    ld d, a
    ld a, [hli] ; bullet y pos
    sub a, d ; decrease by screen offset
    ld d, a
    
    inc hl

    ld a, [rSCX]
    ld e, a
    ld a, [hl] ; bullet x pos
    sub a, e ; decrease by screen offset
    ld e, a

    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld a, [wCurrentShadowOAMPtr + 1]
    ld h, a

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

    ; update the current address from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ld a, h
    ld a, [wCurrentShadowOAMPtr + 1]

    pop hl ; go back to original hl

.endUpdateDir
    ; go to next loop
    ld b, 0
    ld c, sizeof_Bullet ; based on number of bytes the bullet has
    add hl, bc ; add the offset to get the next bullet
    jp .startLoop ; have to use jump, address out of reach

.end
    ret