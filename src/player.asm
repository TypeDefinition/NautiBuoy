INCLUDE "./src/hardware.inc"
INCLUDE "./src/structs.inc"
INCLUDE "./src/entities.inc"
INCLUDE "./src/util.inc"

DEF VIEWPORT_SIZE_Y EQU 72
DEF VIEWPORT_SIZE_X EQU 80
DEF VIEWPORT_MAX_Y EQU 112 ; 256pixels - 144pixels
DEF VIEWPORT_MAX_X EQU 96 ; 256pixels - 160pixels

SECTION "Player Data", WRAM0
    dstruct Character, wPlayer

/* Any logic/behavior/function related to player here */
SECTION "Player", ROM0
InitPlayer::
    push af

    ; TODO: Make const variables for the initial HP, posX and posY, and velocity
    ld a, $01
    ld [wPlayer_Active], a
    ld a, TAG_PLAYER
    ld [wPlayer_Tag], a
    ld a, TYPE_PLAYER
    ld [wPlayer_Type], a
    ld a, 0
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a
    ld a, 8
    ld [wPlayer_Velocity], a
    ld [wPlayer_ColSize], a
    ld a, 3
    ld [wPlayer_HP], a

    ; variables for animation
    xor a
    ld [wPlayer_Direction], a
    ld [wPlayer_CurrAnimationFrame], a

    ld a, PLAYER_WALK_FRAMES
    ld [wPlayer_CurrStateMaxAnimFrame], a

    pop af
    ret

; Move the player based on user input.
UpdatePlayerMovement::
    push af
    push bc
    push hl

    ld a, [wCurrentInputKeys]
    ld b, a ; store the input keys into b
    ld a, [wPlayer_Velocity]
    ld c, a ; store player velocity into c

    ; Vertical Movement
    ld a, [wPlayer_PosY]
.up
    bit PADB_UP, b
    jr z, .down
    sub a, c
.down
    bit PADB_DOWN, b
    jr z, .verticalEnd
    add a, c
.verticalEnd
    ld [wPlayer_PosY], a

    ; Horizontal Movement
    ld a, [wPlayer_PosX]
.right
    bit PADB_RIGHT, b
    jr z, .left
    add a, c
.left
    bit PADB_LEFT, b
    jr z, .horizontalEnd
    sub a, c
.horizontalEnd
    ld [wPlayer_PosX], a

.exit
    pop hl
    pop bc
    pop af
    ret

UpdatePlayerAttack::
    ret

UpdatePlayerCamera::
    push af

.vertical
    ld a, [wPlayer_PosY]
.minY
    sub a, VIEWPORT_SIZE_Y
    jr nc, .maxY
    xor a
.maxY
    cp a, VIEWPORT_MAX_Y
    jr c, .verticalEnd
    ld a, VIEWPORT_MAX_Y
.verticalEnd
    ld [rSCY], a

.horizontal
    ld a, [wPlayer_PosX]
    
.minX
    sub a, VIEWPORT_SIZE_X
    jr nc, .maxX
    xor a
.maxX
    cp a, VIEWPORT_MAX_X
    jr c, .horizontalEnd
    ld a, VIEWPORT_MAX_X
.horizontalEnd
    ld [rSCX], a

    pop af
    ret

/*  Update shadow OAM for player
    hl - shadowOAM address where the player is
*/
UpdatePlayerShadowOAM::
    ; TODO:: properly convert the position to screen position instead
    ; TODO:: Manage the sprite to show here too in the sprite ID

    push af
    push bc
    push de
    push hl

    push hl ; this is for the sprite ID intialisation later, store a copy of the original hl

    ; TODO:: do it based on direction of sprite
    ; init the sprites shadow OAM, for y, x and flags, sprite ID later
    set_romx_bank 2 ; bank for sprites is in bank 2

    ; TODO:: do a check here, store the animation in hl and push, pop it later
    ld de, PlayerSprites.upSprite
    
    ; Convert player position from world space to screen space.
    ld a, [rSCY]
    ld b, a
    ld a, [wPlayer_PosY]
    sub a, b
    ld b, a ; store y screen pos at b

    ld a, [rSCX]
    ld c, a
    ld a, [wPlayer_PosX]
    sub a, c
    ld c, a ; store x screen pos at x

    ; Init sprites to shadow OAM
    ld a, [de] ; get the sprite offset y
    add b
    ld [hli], a ; init screen y Pos
    inc de ; inc to get x pos
    
    ld a, [de] ; get the sprite offset x
    add c
    ld [hli], a ; init screen x pos
    inc de ; inc to get flags

    inc hl ; skip the sprite id first

    ld a, [de] ; get flags
    ld [hli], a
    inc de

    ; Init second half of player sprite to shadow OAM
    ld a, [de] ; get the sprite offset y
    add b
    ld [hli], a ; init screen y Pos
    inc de
    
    ld a, [de] ; get the sprite offset x
    add c
    ld [hli], a ; init screen x pos
    inc de

    inc hl ; skip the sprite id first

    ld a, [de] ; get flags
    ld [hli], a
    

    ; grab the sprite ID from the current animation frame to render
    ld hl, PlayerAnimation.upAnimation
    ld a, [wPlayer_CurrAnimationFrame]

    ; TODO:: while loop here to add the offset?
    ld b, 0
    ld c, a ; load curr animation frame
    add hl, bc ; add the offset to the address

    ld a, [hli] ; grab the first half of the sprite
    ld b, a
    ld a, [hl] ; get the second half of the sprite
    ld c, a

    pop hl ; get the original hl from the shadowOAM
    ld d, 0
    ld e, 2
    add hl, de ; offset by 2 to go to the sprite ID address
    ld [hl], b

    ld e, 4
    add hl, de ; offset by 3 to go to the second half sprite ID address
    ld [hl], c

    pop hl
    pop de
    pop bc
    pop af

    ret
/*
    i check the current direction, based on it init the address pointing to the correct data

    i grab the sprite from the animation counter
    if counter is more than the frames, then loop it
    TODO::if i move, remember to update the animation counter
    TODO:: maybe, if animation needed make sure to reset counter

    update the address (+ 3)
    update the y,x in OAM, tile ID and flags for the two sprites
*/

/* TEMP CODES FOR ANIMATION 
    ld hl, PlayerAnimation.upAnimation
    ; check animation frame
    ;ld a, [wPlayer_CurrStateMaxAnimFrame]
    ;ld d, a
    ld a, [wPlayer_CurrAnimationFrame]
    ;cp d ;check current animation frame no. with max Frames
    ;jr nz, .noResetAnimationCounter

    ; if reach limit reset curren Animation counter
    ;xor a
    ;ld [wPlayer_CurrAnimationFrame], a

;.noResetAnimationCounter
    ld d, 0
    ld e, a ; load curr animation frame
    add hl, de ; add the offset to the address
    ld a, [hl]
*/