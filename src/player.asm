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
    ld a, 80
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a
    ld a, 8
    ld [wPlayer_Velocity], a
    ld [wPlayer_ColSize], a
    ld a, 3
    ld [wPlayer_HP], a

    ; variables for animation
    ld a, DIR_DOWN ; make the sprite look upwards at first
    ld [wPlayer_Direction], a
    xor a
    ld [wPlayer_CurrAnimationFrame], a

    ld a, PLAYER_WALK_FRAMES
    ld [wPlayer_CurrStateMaxAnimFrame], a

    pop af
    ret

/* Move the player based on user input, update sprite dir and animation frame accordingly */
UpdatePlayerMovement::
    push af
    push bc
    push de
    push hl

    ld a, [wCurrentInputKeys]
    ld b, a ; store the input keys into b
    ld a, [wPlayer_Velocity]
    ld c, a ; store player velocity into c

    ; Vertical Movement
    ld a, [wPlayer_PosY]
    ld d, a ; store original y pos
    ld e, 0 ; init the animation frame addition to 0

.up
    bit PADB_UP, b
    jr z, .down
    sub a, c
.down
    bit PADB_DOWN, b
    jr z, .verticalEnd
    add a, c
.verticalEnd
    ld [wPlayer_PosY], a ; update pos Y

    cp d ; compare a with the original y pos to know the final dir moved
    jr z, .right ; if they are the same go to horizontal movement
    ld a, DIR_UP
    jr c, .verticalSpriteDirEnd; there's a carry, means player went up. a < original y pos
    ld a, DIR_DOWN

.verticalSpriteDirEnd
    ld [wPlayer_Direction], a 
    
    ld e, 1 ; add 1 frame in animation
.right
    ; Horizontal Movement
    ld a, [wPlayer_PosX]
    ld d, a ; store original x pos

    bit PADB_RIGHT, b
    jr z, .left
    add a, c
.left
    bit PADB_LEFT, b
    jr z, .horizontalEnd
    sub a, c

.horizontalEnd
    ld [wPlayer_PosX], a ; update pos X

    cp d ; compare a with the original x pos to know the final dir moved
    jr z, .updateAnimationFrame ; if they are the same, go to end
    ld a, DIR_LEFT
    jr c, .horizontalSpriteDirEnd; there's a carry, means player went left. a < original x pos
    ld a, DIR_RIGHT

.horizontalSpriteDirEnd
    ld [wPlayer_Direction], a 
    
    ld e, 1 ; add 1 frame in animation

.updateAnimationFrame ; Animation update frames here
    ld a, [wPlayer_CurrStateMaxAnimFrame]
    ld b, a ; store max frames into b

    xor a
    cp e ; if e (animation frames added) is 0 it means it didnt add anything
    jr z, .exit
    ld a, [wPlayer_CurrAnimationFrame]
    add e ; add the numbner of animation frame

    cp b ; check current animation frame no. with max Frames
    jr nz, .noResetAnimationCounter
    ; if reach limit reset curren Animation counter
    xor a

.noResetAnimationCounter
    ld [wPlayer_CurrAnimationFrame], a

.exit
    pop hl
    pop de
    pop bc
    pop af
    ret


/*  For checking player inputs that allow them to attack
    Current attacks:
    - Shooting (press A)
    - Bombs maybe?
*/
UpdatePlayerAttack::
    ; SHOOTING
    ld a, [wNewlyInputKeys]
    bit PADB_A, a
    jr z, .finishAttack ; if player doesnt PRESS A

/*
    Over here we only want to initialise the bullets
    Make it alive, set pos x, pos y

    TODO:: make a fire rate or something
    TODO:: check if bullet is alive first LOL
    TODO:: bullet spawn pos should have an offset from player
    TODO:: discuss with terry abt whether the velocity and damage should be by player or bullet type
*/
    ld hl, BulletsObjects
    ld a, IS_ALIVE
    ld [hli], a ; its alive

    ld a, [wPlayer_PosY] 
    ld [hli], a ; pos Y
    ld a, [wPlayer_PosX]
    ld [hli], a ; pos x
    
    ld a, 3 ; TEMP VARIABLE
    ld [hli], a ; velocity
    ld a, [wPlayer_Direction]
    ld [hli], a ; direction

    ld a, TAG_PLAYER
    ld [hli], a ; tag
    ld a, TYPE_BULLET1
    ld [hli], a ; type
    ld a, [wPlayer_Direction]
    ld a, 1 ; TEMP VARIABLE
    ld [hli], a ; set damage?

.finishAttack
    ret

/*  Update camera pos based on player pos
    Player in middle of camera
    When borders are reached, camera stops
*/
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
    Update sprite ID according to current frame of animation and direction

    hl - shadowOAM address where the player is
*/
UpdatePlayerShadowOAM::
    push af
    push bc
    push de
    push hl

    push hl ; for sprite ID intialisation later, store another copy of the original hl

    ; do a dir check for sprite
    ld a, [wPlayer_Direction]

.upSprite
    cp DIR_UP
    jr nz, .downSprite
    ld de, PlayerSprites.upSprite
    ld bc, PlayerAnimation.upAnimation
    jr .endSpriteDir ; save 6 cycles. original 9 cycles, jr 3 cycles

.downSprite
    cp DIR_DOWN
    jr nz, .rightSprite
    ld de, PlayerSprites.downSprite
    ld bc, PlayerAnimation.downAnimation
    jr .endSpriteDir ; original 6 cycles, save 3 cycles

.rightSprite
    cp DIR_RIGHT
    jr nz, .leftSprite
    ld de, PlayerSprites.rightSprite
    ld bc, PlayerAnimation.rightAnimation

.leftSprite
    cp DIR_LEFT
    jr nz, .endSpriteDir
    ld de, PlayerSprites.leftSprite
    ld bc, PlayerAnimation.leftAnimation

.endSpriteDir
    push bc ; to be used later for animation
    set_romx_bank 2 ; bank for sprites is in bank 2

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
    ld c, a ; store x screen pos at c

.initShadowOAMVariables ; init the sprites shadow OAM, for y, x and flags, sprite ID later
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

.updateSpriteID
    ; grab the sprite ID from the current animation frame to render
    ld a, [wPlayer_CurrAnimationFrame]
    sla a ; curr animation frame x 2
    
    ld b, 0
    ld c, a ; load curr animation frame

    ld hl, 0 ; make hl to 0 so can add the animation address
    add hl, bc ; init the offset to hl

    pop bc ; get the animation sprite address
    add hl, bc ; add the address to the offset

    ld a, [hli] ; grab the first half of the sprite
    ld b, a
    ld a, [hl] ; get the second half of the sprite
    ld c, a

    ; update sprite ID to OAM
    pop hl ; get the original hl from the shadowOAM
    ld d, 0
    ld e, 2
    add hl, de ; offset by 2 to go to the sprite ID address
    ld [hl], b

    ld e, 4
    add hl, de ; offset by 4 to go to the second half sprite ID address
    ld [hl], c

    ; end
    pop hl
    pop de
    pop bc
    pop af

    ret