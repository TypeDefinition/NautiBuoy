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
BulletDestroyTile:
    push af
    cp a, BULLET_DESTRUCTIBLE_TILES
    ld a, EMPTY_TILE
    call c, SetTile
    pop af
    ret

; Check for bullet collision with a tile.
; If collided with BULLET_DESTRUCTIBLE_TILES, the tile is destroyed.
; If collided with BULLET_COLLIDABLE_TILES, the bullet is destroyed.
; @ hl: Bullet Memory Address
BulletTileCollisionCheck:
    push af
    push bc
    push de
    push hl

    ; d = PosY
    ; e = PosX
    ld de, Bullet_PosY
    add hl, de
    ld a, [hli]
    ld d, a
    inc hl
    ld a, [hl]
    ld e, a

    ; h = Destroy Bullet Flag.
    ld h, 0

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
    cp a, $00
    jr z, .bulletNotDestroyed
    ld [hl], FLAG_INACTIVE
.bulletNotDestroyed
    pop de
    pop bc
    pop af
    ret

; Translate a bullet.
; @ bc: Velocity
; @ hl: Bullet Memory Address
TranslateBulletUp:
    ; hl = PosY
    push hl
    push de
    ld de, Bullet_PosY
    add hl, de
    interpolate_pos_dec_reg
    pop de
    pop hl
    ret

; Translate a bullet.
; @ bc: Velocity
; @ hl: Bullet Memory Address
TranslateBulletDown:
    ; hl = PosY
    push hl
    push de
    ld de, Bullet_PosY
    add hl, de
    interpolate_pos_inc_reg
    pop de
    pop hl
    ret

; Translate a bullet.
; @ bc: Velocity
; @ hl: Bullet Memory Address
TranslateBulletLeft:
    ; hl = PosX
    push hl
    push de
    ld de, Bullet_PosX
    add hl, de
    interpolate_pos_dec_reg
    pop de
    pop hl
    ret

; Translate a bullet.
; @ bc: Velocity
; @ hl: Bullet Memory Address
TranslateBulletRight:
    ; hl = PosX
    push hl
    push de
    ld de, Bullet_PosX
    add hl, de
    interpolate_pos_inc_reg
    pop de
    pop hl
    ret

; Update Bullet Shadow OAM
; @ bc: Bullet Sprite
; @ hl: Bullet Memory Address
UpdateBulletShadowOAM:
    push af
    push bc
    push de
    push hl

    ld d, 0
    ld e, 4
    add hl, de ; offset hl by 4
    
    ; translate to screen pos
    ld a, [wShadowSCData]
    ld d, a
    ld a, [hli] ; bullet y pos
    sub a, d ; decrease by screen offset
    ld d, a
    
    inc hl

    ld a, [wShadowSCData + 1]
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

    pop hl
    pop de
    pop bc
    pop af

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
*/
GetInactiveBullet::
    push de

.loop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .end ; if not alive return and end loop
    
    dec b ; decrement and check
    ld a, b
    cp a, 0
    jr z, .end

    ld de, sizeof_Bullet
    add hl, de ; go to next bullet address

    jr .loop
.end
    pop de
    ret

; Update all alive bullets movement and collision.
UpdateBullets::
    push af
    push bc
    push de
    push hl

    ld b, NUM_BULLETS
    ld hl, wBulletObjects
    
.loopStart
    ld a, b
    cp a, 0 ; check if end of loop
    jp z, .end

    push bc ; push bc = loop counter

    ; Collision
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .loopEnd
    call BulletTileCollisionCheck
    call CheckBulletSpriteCollision

    ; Translation
.translationStart
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive after collision
    jr z, .loopEnd

    ; bc = Velocity
    push hl ; PUSH HL = bullet address
    push de ; push DE = value before
    ld de, Bullet_Velocity
    add hl, de
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    pop de ; pop DE = value before
    pop hl ; pop HL = bullet address

    ; a = Direction
    push hl ; push HL = bullet address
    inc hl
    ld a, [hl]
    pop hl ; pop HL = bullet address

    push bc ; push bc = velocity
.translateUp
    cp a, DIR_UP
    jr nz, .translateDown
    call TranslateBulletUp
    ld bc, BulletSprites.upSprite
    jr .translationEnd
.translateDown
    cp a, DIR_DOWN
    jr nz, .translateLeft
    call TranslateBulletDown
    ld bc, BulletSprites.downSprite
    jr .translationEnd
.translateLeft
    cp a, DIR_LEFT
    jr nz, .translateRight
    call TranslateBulletLeft
    ld bc, BulletSprites.leftSprite
    jr .translationEnd
.translateRight
    call TranslateBulletRight
    ld bc, BulletSprites.rightSprite
.translationEnd
    call UpdateBulletShadowOAM
    pop bc ; pop bc = velocity

.loopEnd
    ld de, sizeof_Bullet ; based on number of bytes the bullet has
    add hl, de ; offset to get the next bullet
    pop bc ; pop bc = loop counter
    dec b ; dec counter
    jr .loopStart

.end
    pop hl
    pop de
    pop bc
    pop af
    ret


/*  Check if the bullet collided with any sprite
    hl - starting bullet address 
*/
CheckBulletSpriteCollision:
    push af
    push bc
    push de
    push hl


    /*
        check what type it is first
        if it belongs to enemy, check against player
        if belongs to player, check against enemy

        if collide, turn the bullet inactive
        call the correct function to deal with player and enemy
    */
    ;push hl ; PUSH HL = bullet address

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
    ld a, [wPlayer_PosYInterpolateTarget]
    ld d, a
    ld a, [wPlayer_PosXInterpolateTarget]
    ld e, a ; d = player pos Y, e = player position X

    ld h, BULLET_COLLIDER_SIZE
    ld l, PLAYER_COLLIDER_SIZE

    call SpriteCollisionCheck
    cp a, 0
    jr z, .end

    pop hl  ; POP HL = bullet address
    push hl ; Push HL = bullet address
    ld a, FLAG_INACTIVE ; bullet collision behavior
    ld [hl], a

    call PlayerIsHit ; player collision behavior
    jr .end
    
.checkCollisionWithEnemy ; bullet belongs to player
    ; b = bullet posY, c = bullet pos X

    ld hl, wEnemy0
    ld a, [LevelOneEnemyData]
    ld d, a

.startOfEnemyLoop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr z, .nextEnemyLoop

    push de ; PUSH DE = enemy counter
    push hl ; PUSH HL = enemy starting address

    inc hl 
    inc hl

    ld a, [hli] ; get enemy pos Y
    ld d, a
    inc hl
    inc hl
    ld a, [hl] ; get enemy pos X
    ld e, a ; d = enemy pos Y, e = enemy position X

    ld h, BULLET_COLLIDER_SIZE
    ld l, ENEMY_BULLET_COLLIDER_SIZE

    call SpriteCollisionCheck
    cp a, 0
    pop hl ; POP HL = enemy starting address
    pop de ; POP DE = enemy counter
    jr z, .nextEnemyLoop

    call HitEnemy
    
    pop hl  ; POP HL = bullet address
    push hl ; Push HL = bullet address
    ld a, FLAG_INACTIVE ; bullet collision behavior
    ld [hl], a

    jr .end

.nextEnemyLoop
    dec d
    ld a, d
    cp a, 0
    jr z, .end

    push bc ; PUSH BC = projectile y and x pos
    ld bc, sizeof_Character
    add hl, bc
    pop bc ; POP BC = projectile y and x pos
    jr .startOfEnemyLoop

.end
    pop hl
    pop de
    pop bc
    pop af

    ret

