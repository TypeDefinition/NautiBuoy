INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/movement.inc"
INCLUDE "./src/include/tile_collision.inc"


DEF NUM_BULLETS EQU $10

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
/* Local Functions */
; Destroy A Tile
; @ bc: Tile Index
; @ l: bullet destrutable tile type
BulletDestroyTile:
    push af
    cp a, l
    ld a, EMPTY_TILE
    call c, SetTile
    pop af
    ret

; Check for bullet collision with a tile.
; If collided with BULLET_DESTRUCTIBLE_TILES, the tile is destroyed.
; If collided with BULLET_COLLIDABLE_TILES, the bullet is destroyed.
; @ hl: Bullet Memory Address
BulletTileCollisionCheck:
    push hl

    ; d = PosY
    ; e = PosX
    ld a, [hli] ; get flags
    and a, BIT_MASK_TYPE
    ld b, BULLET_DESTRUCTIBLE_TILES
    jr z, .initInfo

    ld b, POWER_BULLET_DESTRUCTIBLE_TILES ; it is a power bullet

.initInfo
    inc hl
    inc hl
    inc hl

    ld a, [hli]
    ld d, a
    inc hl
    ld a, [hl]
    ld e, a

    ; h = Destroy Bullet Flag.
    ld h, 0
    ld l, b ; l = bullet type

.topLeft
    push de

    ld a, d
    sub a, BULLET_COLLIDER_SIZE
    ld d, a

    ld a, e
    sub a, BULLET_COLLIDER_SIZE
    ld e, a

    call GetTileIndex
    call GetTileValue
    call BulletDestroyTile

    pop de

    cp a, BULLET_COLLIDABLE_TILES
    jr nc, .bottomLeft
    inc h
 .bottomLeft
    push de

    ld a, d
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a

    ld a, e
    sub a, BULLET_COLLIDER_SIZE
    ld e, a

    call GetTileIndex
    call GetTileValue
    call BulletDestroyTile

    pop de

    cp a, BULLET_COLLIDABLE_TILES
    jr nc, .topRight
    inc h
.topRight
    push de

    ld a, d
    sub a, BULLET_COLLIDER_SIZE
    ld d, a

    ld a, e
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    
    call GetTileIndex
    call GetTileValue
    call BulletDestroyTile

    pop de

    cp a, BULLET_COLLIDABLE_TILES
    jr nc, .bottomRight
    inc h
.bottomRight
    push de
    
    ld a, d
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a

    ld a, e
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    
    call GetTileIndex
    call GetTileValue
    call BulletDestroyTile

    pop de

    cp a, BULLET_COLLIDABLE_TILES
    jr nc, .end
    inc h
    ; Destroy the bullet if the bullet destoyed flag is set.
.end
    ld a, h
    pop hl
    and a
    jr z, .bulletNotDestroyed
    ld [hl], FLAG_INACTIVE
.bulletNotDestroyed
    ret


; Update Bullet Shadow OAM
; @ bc: Bullet Sprite address
; @ hl: Bullet Memory Address
; Register change:
;   - AF
;   - BC
;   - DE
;   - HL
UpdateBulletShadowOAM:
    ld a, [hl]
    and a, BIT_MASK_TYPE ; get the type of bullet
    sla a ; shift left by 1, we want a multiple of 8
    ld d, a 

    ld a, c ; offset the bullet sprite address
    add a, d
    ld c, a
    ld a, b
    adc a, 0
    ld b, a 

    ld de, Bullet_PosY
    add hl, de ; offset hl by 4
    
    ; translate to screen pos
    ld a, [wShadowSCData]
    ld d, a
    ld a, [hli] ; bullet y pos
    sub a, d ; decrease by screen offset
    add a, 8 ; bullet sprite y offset = 8
    ld d, a
    
    inc hl

    ld a, [wShadowSCData + 1]
    ld e, a
    ld a, [hl] ; bullet x pos
    sub a, e ; decrease by screen offset
    add a, 4 ; bullet sprite y offset = 4
    ld e, a

    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld a, d
    ld [hli], a ; update y pos

    ld a, e
    ld [hli], a ; update x pos

    ld a, [bc] ; sprite ID
    ld [hli], a 

    inc bc
    ld a, [bc] ; flags
    ld [hli], a ; flags

    ; update the current address from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ret

/* Global Functions */
; Reset all bullet data.
ResetAllBullets::
    mem_set_small wBulletObjects, 0, wBulletObjectEnd - wBulletObjects
    ret

/*  Searches and returns the memory address of an inactive bullet.
    @ hl: Memory Address of 1st Bullet
    @ b: Number of Bullets to Search
    @ hl: Return 
    return hl - starting address of available bullet, if no available bullets, return the last bullet
    WARNING: after calling this function, need to check if active anyway, there's no null check...

    Registers change:
        - AF
        - BC
        - DE
        - HL
*/
GetInactiveBullet::
    push de

.loop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .end ; if not alive return and end loop
    
    dec b ; decrement and check
    ld a, b
    and a
    jr z, .end

    ld de, sizeof_Bullet
    add hl, de ; go to next bullet address

    jr .loop
.end
    pop de
    ret

; Update all alive bullets movement and collision.
UpdateBullets::
    ld b, NUM_BULLETS
    ld hl, wBulletObjects
    
.loopStart
    push bc ; push bc = loop counter

    ; Collision
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jp z, .loopEnd
    call BulletTileCollisionCheck

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive after collision
    jp z, .loopEnd
    call BulletSpriteCollisionCheck

    ; Translation
.translationStart
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive after sprite collision
    jp z, .loopEnd

    push hl ; PUSH HL = bullet address
    inc hl
    ld a, [hli] ; get direction
    ld d, a

    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a ; bc = Velocity

    ; hl = y pos address, d = direction, bc = velocity
    ld a, d

    ASSERT DIR_UP == 0
    and a, a ; cp a, 0
    jr z, .translateUp
    ASSERT DIR_DOWN == 1
    dec a
    jr z, .translateDown
    ASSERT DIR_LEFT == 2
    dec a
    jr z, .translateLeft
    ASSERT DIR_RIGHT > 2
.translateRight
    inc hl
    inc hl
    interpolate_pos_inc_reg
    ld bc, BulletSprites.rightDefaultSprite
    jr .translationEnd
.translateUp
    interpolate_pos_dec_reg
    ld bc, BulletSprites.upDefaultSprite
    jr .translationEnd
.translateDown
    interpolate_pos_inc_reg
    ld bc, BulletSprites.downDefaultSprite
    jr .translationEnd
.translateLeft
    inc hl
    inc hl
    interpolate_pos_dec_reg
    ld bc, BulletSprites.leftDefaultSprite
.translationEnd
    pop hl ; POP HL = bullet address
    push hl ; PUSH HL = bullet address
    call UpdateBulletShadowOAM
    pop hl ; POP HL = bullet address

.loopEnd
    ; hl = bullet starting address
    ld de, sizeof_Bullet ; based on number of bytes the bullet has
    add hl, de ; offset to get the next bullet
    pop bc ; pop bc = loop counter
    dec b ; dec counter
    jp nz, .loopStart

.end
    ret


/*  Check if the bullet collided with any sprite
    hl - starting bullet address 
*/
BulletSpriteCollisionCheck:
    push hl

    ; b = bullet posY, c = bullet pos X
    ld de, Bullet_PosY 
    add hl, de
    ld a, [hli]
    ld b, a
    inc hl
    ld a, [hl]
    ld c, a

    pop hl ; POP HL = bullet address
    push hl ; Push HL = bullet address
    ld a, [hl]
    bit BIT_FLAG_PLAYER, a ; check first bit, 0 = player, 1 = enemy
    jr z, .checkCollisionWithEnemy

.checkCollisionWithPlayer ; bullet belongs to enemy
    ; b = bullet posY, c = bullet pos X
    ld a, [wPlayer_Flags]
    and a, FLICKER_EFFECT_FLAG ; check if got invincibility frame on
    jr nz, .end

    ld a, [wPlayer_PosYInterpolateTarget]
    ld d, a
    ld a, [wPlayer_PosXInterpolateTarget]
    ld e, a ; d = player pos Y, e = player position X

    ld h, BULLET_COLLIDER_SIZE
    ld l, PLAYER_COLLIDER_SIZE

    call SpriteCollisionCheck
    and a
    jr z, .end

    pop hl  ; POP HL = bullet address
    push hl ; Push HL = bullet address
    ld a, FLAG_INACTIVE ; bullet collision behavior
    ld [hl], a

    call PlayerIsHit ; player collision behavior
    jr .end
    
.checkCollisionWithEnemy ; bullet belongs to player
    ; b = bullet posY, c = bullet pos X

    ld d, BULLET_COLLIDER_SIZE
    ld e, ENEMY_BULLET_COLLIDER_SIZE

    call CheckEnemyCollisionLoop
    and a
    jr z, .end

    call HitEnemy
    
    pop hl  ; POP HL = bullet address
    push hl ; Push HL = bullet address
    ld a, FLAG_INACTIVE ; bullet collision behavior
    ld [hl], a

.end
    pop hl

    ret

