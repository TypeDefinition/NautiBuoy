INCLUDE "./src/definitions/definitions.inc"

    IF !DEF(TILE_COLLISION_INC)
DEF TILE_COLLISION_INC EQU 1

/*  Check for entity collision with tiles (up) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address */
MACRO tile_collision_check_up_immd
    ; Top Left Corner Collision Check
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld d, a
    ld a, [\2]
    sub a, \3
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

    ; Top Right Corner Collision Check
    ld a, [\1]
    sub a, (TILE_SIZE + \3)
    ld d, a
    ld a, [\2]
    add a, \3 - 1
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5
ENDM

/*  Check for entity collision with tiles (down) 
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address */
MACRO tile_collision_check_down_immd
    ; Bottom Left Corner Collision Check
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld d, a
    ld a, [\2]
    sub a, \3
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

    ; Bottom Right Corner Collision Check
    ld a, [\1]
    add a, (TILE_SIZE + \3 - 1)
    ld d, a
    ld a, [\2]
    add a, \3 - 1
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

ENDM

/*  Check for entity collision with tiles (left)
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address */
MACRO tile_collision_check_left_immd
    ; Top Left Corner Collision Check
    ld a, [\1]
    sub a, \3
    ld d, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

    ; Bottom Left Corner Collision Check
    ld a, [\1]
    add a, \3 - 1
    ld d, a
    ld a, [\2]
    sub a, (TILE_SIZE + \3)
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

ENDM

/*  Check for entity collision with tiles (right)
    \1 - Entity PosY Address
    \2 - Entity PosX Address
    \3 - Collider Size
    \4 - Collidable Tiles
    \5 - True Jump Address */
MACRO tile_collision_check_right_immd
    ; Top Right Corner Collision Check
    ld a, [\1]
    sub a, \3
    ld d, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

    ; Bottom Right Corner Collision Check
    ld a, [\1]
    add a, \3 - 1
    ld d, a
    ld a, [\2]
    add a, (TILE_SIZE + \3 - 1)
    ld e, a
    call GetTileIndex
    call GetGameLevelTileValue
    cp a, \4
    jp c, \5

ENDM

/*  Check for entity collision with tiles (up) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address 
    
    Registers change:
    - AF
    - BC
    - DE
*/
MACRO tile_collision_check_up_reg
    ; Top Left Corner Collision Check
    push de
    ld a, [de]
    sub a, \1
    ld e, a
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3

    ; Top Right Corner Collision Check
    push de
    ld a, [de]
    add a, \1 - 1
    ld e, a
    ld a, [hl]
    sub a, (TILE_SIZE + \1)
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3
ENDM

/*  Check for entity collision with tiles (down) 
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address */
MACRO tile_collision_check_down_reg
    ; Bottom Left Corner Collision Check
    push de
    ld a, [de]
    sub a, \1
    ld e, a
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Right Corner Collision Check
    push de
    ld a, [de]
    add a, \1 - 1
    ld e, a
    ld a, [hl]
    add a, (TILE_SIZE + \1 - 1)
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3
ENDM

/*  Check for entity collision with tiles (left)
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address */
MACRO tile_collision_check_left_reg
    ; Top Left Corner Collision Check
    push de
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld e, a
    ld a, [hl]
    sub a, \1
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Left Corner Collision Check
    push de
    ld a, [de]
    sub a, (TILE_SIZE + \1)
    ld e, a
    ld a, [hl]
    add a, \1 - 1
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3
ENDM

/*  Check for entity collision with tiles (right)
    hl - Entity PosY Address
    de - Entity PosX Address
    \1 - Collider Size
    \2 - Collidable Tiles
    \3 - True Jump Address */
MACRO tile_collision_check_right_reg
    ; Top Right Corner Collision Check
    push de
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld e, a
    ld a, [hl]
    sub a, \1
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3

    ; Bottom Right Corner Collision Check
    push de
    ld a, [de]
    add a, (TILE_SIZE + \1 - 1)
    ld e, a
    ld a, [hl]
    add a, \1 - 1
    ld d, a
    call GetTileIndex
    call GetGameLevelTileValue
    pop de
    cp a, \2
    jp c, \3
ENDM

    ENDC ; TILE_COLLISION_INC