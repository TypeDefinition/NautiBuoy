INCLUDE "src/include/definitions.inc"

    IF !DEF(TILE_COLLISION_INC)
DEF TILE_COLLISION_INC EQU 1

/*  Check for entity collision with tiles (up) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - True Jump Address
    \5 - False Jump Address */
MACRO tile_collision_check_up
    ; Top Left Corner Collision Check
    push bc
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld b, a
    ld a, [\2]
    sub a, \3
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    ; Top Right Corner Collision Check
    push bc
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld b, a
    ld a, [\2]
    add a, \3 - 1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    jp \5
ENDM

/*  Check for entity collision with tiles (down) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - True Jump Address
    \5 - False Jump Address */
MACRO tile_collision_check_down
    ; Bottom Left Corner Collision Check
    push bc
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld b, a
    ld a, [\2]
    sub a, \3
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    ; Bottom Right Corner Collision Check
    push bc
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld b, a
    ld a, [\2]
    add a, \3 - 1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    jp \5
ENDM

/*  Check for entity collision with tiles (left) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - True Jump Address
    \5 - False Jump Address */
MACRO tile_collision_check_left
    ; Top Left Corner Collision Check
    push bc
    ld a, [\1]
    sub a, \3
    ld b, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    ; Bottom Left Corner Collision Check
    push bc
    ld a, [\1]
    add a, \3 - 1
    ld b, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    jp \5
ENDM

/*  Check for entity collision with tiles (right)
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - True Jump Address
    \5 - False Jump Address */
MACRO tile_collision_check_right
    ; Top Right Corner Collision Check
    push bc
    ld a, [\1]
    sub a, \3
    ld b, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    ; Bottom Right Corner Collision Check
    push bc
    ld a, [\1]
    add a, \3 - 1
    ld b, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \4

    jp \5
ENDM



/* REG VERSION */

/*  Check for entity collision with tiles (up) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - True Jump Address */
MACRO tile_collision_check_up_reg
    ; Top Left Corner Collision Check
    push bc
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld b, a
    ld a, [de]
    sub a, \1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ; Top Right Corner Collision Check
    push bc
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld b, a
    ld a, [de]
    add a, \1 - 1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ;jp \3
ENDM

/*  Check for entity collision with tiles (down) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - True Jump Address */
MACRO tile_collision_check_down_reg
    ; Bottom Left Corner Collision Check
    push bc
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld b, a
    ld a, [de]
    sub a, \1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ; Bottom Right Corner Collision Check
    push bc
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld b, a
    ld a, [de]
    add a, \1 - 1
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ;jp \3
ENDM

/*  Check for entity collision with tiles (left) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - True Jump Address */
MACRO tile_collision_check_left_reg
    ; Top Left Corner Collision Check
    push bc
    ld a, [hl]
    sub a, \1
    ld b, a
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ; Bottom Left Corner Collision Check
    push bc
    ld a, [hl]
    add a, \1 - 1
    ld b, a
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2
ENDM

/*  Check for entity collision with tiles (right)
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - True Jump Address */
MACRO tile_collision_check_right_reg
    ; Top Right Corner Collision Check
    push bc
    ld a, [hl]
    sub a, \1
    ld b, a
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ; Bottom Right Corner Collision Check
    push bc
    ld a, [hl]
    add a, \1 - 1
    ld b, a
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld c, a
    call GetTileValue
    pop bc
    cp a, COLLIDABLE_TILES
    jp c, \2

    ;jp \3
ENDM


    ENDC ; TILE_COLLISION_INC