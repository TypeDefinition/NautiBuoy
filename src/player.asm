INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/tile_collision.inc"
INCLUDE "./src/include/movement.inc"

DEF VIEWPORT_SIZE_Y EQU 72
DEF VIEWPORT_SIZE_X EQU 80
DEF VIEWPORT_MAX_Y EQU 112 ; 256pixels - 144pixels
DEF VIEWPORT_MAX_X EQU 96 ; 256pixels - 160pixels

SECTION "Player Data", WRAM0
    dstruct Character, wPlayer

/* Any logic/behavior/function related to player here */
SECTION "Player", ROM0
InitialisePlayer::
    push af

    ; TODO: Make const variables for the initial HP, posX and posY, and velocity
    ld a, $01
    ld [wPlayer_Active], a
    ; Set Position
    ld a, 128
    ld [wPlayer_PosYInterpolateTarget], a
    ld [wPlayer_PosXInterpolateTarget], a
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a
    xor a
    ld [wPlayer_PosYFrac], a
    ld [wPlayer_PosXFrac], a
    ; Set Direction
    ld a, DIR_UP
    ld [wPlayer_Direction], a
    ; Set HP
    ld a, 3
    ld [wPlayer_HP], a
    ; Set Animation
    xor a
    ld [wPlayer_CurrAnimationFrame], a
    ld a, PLAYER_WALK_FRAMES
    ld [wPlayer_CurrStateMaxAnimFrame], a

    pop af
    ret

InterpolatePlayerPosition::
    ld a, [wPlayer_Direction]
.upStart
    cp a, DIR_UP
    jr nz, .upEnd
    interpolate_pos_dec wPlayer_PosY, wPlayer_PosYFrac, VELOCITY_NORMAL
    jp .end
.upEnd
.downStart
    cp a, DIR_DOWN
    jr nz, .downEnd
    interpolate_pos_inc wPlayer_PosY, wPlayer_PosYFrac, VELOCITY_NORMAL
    jp .end
.downEnd
.leftStart
    cp a, DIR_LEFT
    jr nz, .leftEnd
    interpolate_pos_dec wPlayer_PosX, wPlayer_PosXFrac, VELOCITY_NORMAL
    jp .end
.leftEnd
.rightStart
    cp a, DIR_RIGHT
    jr nz, .rightEnd
    interpolate_pos_inc wPlayer_PosX, wPlayer_PosXFrac, VELOCITY_NORMAL
    jp .end
.rightEnd
.end
    ret

GetUserInput::
    ld a, [wCurrentInputKeys]
    ld b, a ; b = Input Key

.upStart
    bit PADB_UP, b
    jp z, .upEnd
    ld a, DIR_UP
    ld [wPlayer_Direction], a
    tile_collision_check_up wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, .end, .setUpPosTarget
.setUpPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosYInterpolateTarget]
    sub a, TILE_SIZE
    ld [wPlayer_PosYInterpolateTarget], a
    jp .end
.upEnd

.downStart
    bit PADB_DOWN, b
    jp z, .downEnd
    ld a, DIR_DOWN
    ld [wPlayer_Direction], a
    tile_collision_check_down wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, .end, .setDownPosTarget
.setDownPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosYInterpolateTarget]
    add a, TILE_SIZE
    ld [wPlayer_PosYInterpolateTarget], a
    jp .end
.downEnd

.leftStart
    bit PADB_LEFT, b
    jp z, .leftEnd
    ld a, DIR_LEFT
    ld [wPlayer_Direction], a
    tile_collision_check_left wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, .end, .setLeftPosTarget
.setLeftPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosXInterpolateTarget]
    sub a, TILE_SIZE
    ld [wPlayer_PosXInterpolateTarget], a
    jp .end
.leftEnd

.rightStart
    bit PADB_RIGHT, b
    jp z, .rightEnd
    ld a, DIR_RIGHT
    ld [wPlayer_Direction], a
    tile_collision_check_right wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, .end, .setRightPosTarget
.setRightPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosXInterpolateTarget]
    add a, TILE_SIZE
    ld [wPlayer_PosXInterpolateTarget], a
    jp .end
.rightEnd

.end
    ret

AdvancePlayerAnimation::
    ld a, [wPlayer_CurrStateMaxAnimFrame]
    ld b, a ; store max frames into b
    
    ld a, [wPlayer_CurrAnimationFrame]
    inc a ; Advance the animation frame by 1.
    cp a, b
    jr nz, .end
    xor a
.end
    ld [wPlayer_CurrAnimationFrame], a
    ret

UpdatePlayerMovement::
    push af
    push bc

    ; If the player is still interpolating, do not check for input.
    ld a, [wPlayer_PosY]
    ld b, a
    ld a, [wPlayer_PosYInterpolateTarget]
    cp a, b
    jr nz, .interpolatePosition
    ld a, [wPlayer_PosX]
    ld b, a
    ld a, [wPlayer_PosXInterpolateTarget]
    cp a, b
    jr nz, .interpolatePosition
    jr .getUserInput

.getUserInput
    call GetUserInput
    jr .end
.interpolatePosition
    call InterpolatePlayerPosition
    call AdvancePlayerAnimation

.end
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
    ld hl, wBulletObjects
    ld a, ACTIVE
    ld [hli], a ; its alive

    ld a, [wPlayer_PosY] 
    ld [hli], a ; pos Y
    ld a, [wPlayer_PosX]
    ld [hli], a ; pos x
    
    ld a, 1 ; TEMP VARIABLE
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

    push hl ; for sprite ID intialisation later, store another copy of the original hl

    ; do a dir check for sprite
    ld a, [wPlayer_Direction]

.upSprite
    cp DIR_UP
    jr nz, .downSprite
    ld de, PlayerSprites.upSprite
    ld bc, PlayerAnimation.upAnimation
.downSprite
    cp DIR_DOWN
    jr nz, .rightSprite
    ld de, PlayerSprites.downSprite
    ld bc, PlayerAnimation.downAnimation
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

    ld e, 2
    add hl, de ; offset by 2 to reach the next entity y pos

    ; end
    pop de
    pop bc
    pop af

    ret