INCLUDE "src/include/definitions.inc"

    IF !DEF(TILE_COLLISION_INC)
DEF TILE_COLLISION_INC EQU 1

/*  Check for entity collision with tiles (up) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address
    \6 - False Jump Address */
MACRO tile_collision_check_up_immd
    ; Top Left Corner Collision Check
    push de
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld d, a
    ld a, [\2]
    sub a, \3
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    ; Top Right Corner Collision Check
    push de
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld d, a
    ld a, [\2]
    add a, \3 - 1
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    jp \6
ENDM

/*  Check for entity collision with tiles (down) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address
    \6 - False Jump Address */
MACRO tile_collision_check_down_immd
    ; Bottom Left Corner Collision Check
    push de
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld d, a
    ld a, [\2]
    sub a, \3
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    ; Bottom Right Corner Collision Check
    push de
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld d, a
    ld a, [\2]
    add a, \3 - 1
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    jp \6
ENDM

/*  Check for entity collision with tiles (left)
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address
    \6 - False Jump Address */
MACRO tile_collision_check_left_immd
    ; Top Left Corner Collision Check
    push de
    ld a, [\1]
    sub a, \3
    ld d, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    ; Bottom Left Corner Collision Check
    push de
    ld a, [\1]
    add a, \3 - 1
    ld d, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    jp \6
ENDM

/*  Check for entity collision with tiles (right)
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address
    \6 - False Jump Address */
MACRO tile_collision_check_right_immd
    ; Top Right Corner Collision Check
    push de
    ld a, [\1]
    sub a, \3
    ld d, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    ; Bottom Right Corner Collision Check
    push de
    ld a, [\1]
    add a, \3 - 1
    ld d, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld e, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \4
    jp c, \5

    jp \6
ENDM

/*  Check for entity collision with tiles
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Bullet Destructible Tiles
    \3 - Bullet Destructible Tile True Jump Address
    \4 - Bullet Collidable Tiles
    \5 - Bullet Collidable Tile True Jump Address */
MACRO bullet_tile_collision_check_up
    ; Check Top Left
    ld a, [de]
    push de
    sub a, BULLET_COLLIDER_SIZE
    ld e, a
    ld a, [hl]
    sub a, BULLET_COLLIDER_SIZE
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5

    ; Check Top Right
    ld a, [de]
    push de
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    ld a, [hl]
    sub a, BULLET_COLLIDER_SIZE
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5
ENDM

/*  Check for entity collision with tiles
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Bullet Destructible Tiles
    \3 - Bullet Destructible Tile True Jump Address
    \4 - Bullet Collidable Tiles
    \5 - Bullet Collidable Tile True Jump Address */
MACRO bullet_tile_collision_check_down
    ; Check Bottom Left
    ld a, [de]
    push de
    sub a, BULLET_COLLIDER_SIZE
    ld e, a
    ld a, [hl]
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5

    ; Check Bottom Right
    ld a, [de]
    push de
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    ld a, [hl]
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5
ENDM

/*  Check for entity collision with tiles
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Bullet Destructible Tiles
    \3 - Bullet Destructible Tile True Jump Address
    \4 - Bullet Collidable Tiles
    \5 - Bullet Collidable Tile True Jump Address */
MACRO bullet_tile_collision_check_left
    ; Check Top Left
    ld a, [de]
    push de
    sub a, BULLET_COLLIDER_SIZE
    ld e, a
    ld a, [hl]
    sub a, BULLET_COLLIDER_SIZE
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5

    ; Check Bottom Left
    ld a, [de]
    push de
    sub a, BULLET_COLLIDER_SIZE
    ld e, a
    ld a, [hl]
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5
ENDM

/*  Check for entity collision with tiles
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Bullet Destructible Tiles
    \3 - Bullet Destructible Tile True Jump Address
    \4 - Bullet Collidable Tiles
    \5 - Bullet Collidable Tile True Jump Address */
MACRO bullet_tile_collision_check_right
    ; Check Top Right
    ld a, [de]
    push de
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    ld a, [hl]
    sub a, BULLET_COLLIDER_SIZE
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5

    ; Check Bottom Right
    ld a, [de]
    push de
    add a, BULLET_COLLIDER_SIZE - 1
    ld e, a
    ld a, [hl]
    add a, BULLET_COLLIDER_SIZE - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop de
    cp a, \2
    jp c, \3
    cp a, \4
    jp c, \5
ENDM

/*  Check for entity collision with tiles (up) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address
    \4 - False Jump Address */
MACRO tile_collision_check_up_reg
    ; Top Left Corner Collision Check
    push de
    push bc
    ld a, [de]
    sub a, \1
    ld e, a
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    ; Top Right Corner Collision Check
    push de
    push bc
    ld a, [de]
    add a, \1 - 1
    ld e, a
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    jp \4
ENDM

/*  Check for entity collision with tiles (down) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address
    \4 - False Jump Address */
MACRO tile_collision_check_down_reg
    ; Bottom Left Corner Collision Check
    push de
    push bc
    ld a, [de]
    sub a, \1
    ld e, a
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Right Corner Collision Check
    push de
    push bc
    ld a, [de]
    add a, \1 - 1
    ld e, a
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    jp \4
ENDM

/*  Check for entity collision with tiles (left)
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address
    \6 - False Jump Address */
MACRO tile_collision_check_left_reg
    ; Top Left Corner Collision Check
    push de
    push bc
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld e, a
    ld a, [hl]
    sub a, \1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Left Corner Collision Check
    push de
    push bc
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld e, a
    ld a, [hl]
    add a, \1 - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    jp \4
ENDM

/*  Check for entity collision with tiles (right)
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address
    \4 - False Jump Address */
MACRO tile_collision_check_right_reg
    ; Top Right Corner Collision Check
    push de
    push bc
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld e, a
    ld a, [hl]
    sub a, \1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Right Corner Collision Check
    push de
    push bc
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld e, a
    ld a, [hl]
    add a, \1 - 1
    ld d, a
    call GetTileIndex
    call GetTileValue
    pop bc
    pop de
    cp a, \2
    jp c, \3

    jp \4
ENDM

    ENDC ; TILE_COLLISION_INC