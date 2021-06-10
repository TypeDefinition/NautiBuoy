INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/tile_collision.inc"
INCLUDE "./src/include/movement.inc"

SECTION "Player Data", WRAM0
    dstruct Character, wPlayer

SECTION "Player Camera Data", WRAM0
    dstruct PlayerCamera, wPlayerCamera

/* Any logic/behavior/function related to player here */
SECTION "Player", ROM0
PlayAttackSFX:
    ; Channel 1
    ld a, %01000010
    ld [rNR10], a

    ld a, %01001100
    ld [rNR11], a

    ld a, %11111010
    ld [rNR12], a

    ld a, $FF
    ld [rNR13], a

    ld a, %11000011
    ld [rNR14], a

    ret

InitialisePlayer::
    push af

    ; TODO: Make const variables for the initial HP, posX and posY, and velocity
    ld a, FLAG_ACTIVE | FLAG_PLAYER
    ld [wPlayer_Flags], a
    ; Set Position
    ld a, 128
    ld [wPlayer_PosYInterpolateTarget], a
    ld [wPlayer_PosXInterpolateTarget], a
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a
    xor a
    ld [wPlayer_PosY + 1], a
    ld [wPlayer_PosX + 1], a
    ; Set Direction
    ld a, DIR_UP
    ld [wPlayer_Direction], a
    ; Set HP
    ld a, PLAYER_HEALTH
    ld [wPlayer_HP], a
    ; Set Velocity
    ld hl, VELOCITY_NORMAL
    ld a, h
    ld [wPlayer_Velocity], a
    ld a, l
    ld [wPlayer_Velocity + 1], a
    ; Set Animation
    xor a
    ld [wPlayer_CurrAnimationFrame], a
    ld [wPlayer_DamageFlickerEffect], a
    ld [wPlayer_DamageFlickerEffect + 1], a
    ld a, PLAYER_WALK_FRAMES
    ld [wPlayer_CurrStateMaxAnimFrame], a

    pop af
    ret

/* For interpolating player position to the next tile */
InterpolatePlayerPosition::
    ld a, [wPlayer_Direction]
.upStart
    cp a, DIR_UP
    jr nz, .upEnd
    interpolate_pos_dec_immd wPlayer_PosY, wPlayer_Velocity
    jp .end
.upEnd
.downStart
    cp a, DIR_DOWN
    jr nz, .downEnd
    interpolate_pos_inc_immd wPlayer_PosY, wPlayer_Velocity
    jp .end
.downEnd
.leftStart
    cp a, DIR_LEFT
    jr nz, .leftEnd
    interpolate_pos_dec_immd wPlayer_PosX, wPlayer_Velocity
    jp .end
.leftEnd
.rightStart
    cp a, DIR_RIGHT
    jr nz, .rightEnd
    interpolate_pos_inc_immd wPlayer_PosX, wPlayer_Velocity
    jp .end
.rightEnd
.end
    ret

/* Get User input for moving */
GetUserInput::
    ld a, [wCurrentInputKeys]
    ld b, a ; b = Input Key

.upStart
    bit PADB_UP, b
    jp z, .upEnd
    ld a, DIR_UP
    ld [wPlayer_Direction], a
    tile_collision_check_up_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end, .setUpPosTarget
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
    tile_collision_check_down_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end, .setDownPosTarget
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
    tile_collision_check_left_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end, .setLeftPosTarget
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
    tile_collision_check_right_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end, .setRightPosTarget
.setRightPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosXInterpolateTarget]
    add a, TILE_SIZE
    ld [wPlayer_PosXInterpolateTarget], a
    jp .end
.rightEnd

.end
    ret

/* To update Player animation frame */
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

/* Update Player Movement */
UpdatePlayerMovement::
    push af
    push bc

    call PlayerSpriteCollisionCheck

    ; If the player is still interpolating, do not check for input.
    ld a, [wPlayer_PosY]
    ld b, a
    ld a, [wPlayer_PosYInterpolateTarget]
    cp a, b
    jr nz, .interpolatePosition ; player hasnt reached the interpolate target yet
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
*/
    ld hl, wBulletObjects
    ld b, PLAYER_BULLET_NUMBER
    call GetInactiveBullet
    
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a
    jr nz, .finishAttack ; if active, finish attack

    ; set the variables
    ld a, FLAG_ACTIVE | FLAG_PLAYER
    ld [hli], a ; its alive

    ld a, [wPlayer_Direction]
    ld [hli], a ; direction
 
    ; TODO:: SET VELOCITY FOR BULLET BASED ON TYPE LATER
    ld a, $02
    ld [hli], a ; velocity
    xor a
    ld [hli], a ; second part of velocity

    ld a, [wPlayer_PosY] 
    ld [hli], a ; pos Y
    
    ld a, [wPlayer_PosY + 1] 
    ld [hli], a ; load the other half of posY

    ld a, [wPlayer_PosX]
    ld [hli], a ; pos x

    ld a, [wPlayer_PosX + 1] 
    ld [hli], a ; load the other half of posX
    
    call PlayAttackSFX

.finishAttack
    ret

/*  Player has been hit by enemy/projectile 
    TODO:: get proper damage

    WARNING: this is assuming health < 127. Want to prevent underflow, we defined bit 7 to be for -ve
*/
PlayerIsHit::
    push af
    push bc
    push de
    push hl

    ; deduct health first
    ld a, [wPlayer_HP]
    sub a, BULLET_DAMAGE
    ld [wPlayer_HP], a

    ; check health <= 0
    cp a, 0
    jr z, .dead
    cp a, 127
    jr nc, .dead ; value underflowed, go to dead 

.damageEffect ; not dead, set damage flicker effect and teleport to spawn
    
    ld a, DAMAGE_FLICKER_EFFECT
    ld [wPlayer_DamageFlickerEffect], a
    xor a
    ld [wPlayer_DamageFlickerEffect + 1], a 

    ; TODO:: teleport back to spawn
    ; TODO:: have variable of spawn location in level to teleport
    ld a, 128
    ld [wPlayer_PosYInterpolateTarget], a
    ld [wPlayer_PosXInterpolateTarget], a
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a 

    jr .end
.dead
    /* TODO:: if dead, put gameover screen or something */

.end
    pop hl
    pop de
    pop bc
    pop af

    ret


/*  Player check collision with enemy sprite */
PlayerSpriteCollisionCheck:
    push af
    push bc
    push de
    push hl

    ld a, [wPlayer_PosY]
    ld b, a
    ld a, [wPlayer_PosX]
    ld c, a

    ld d, PLAYER_COLLIDER_SIZE
    ld e, ENEMY_PLAYER_COLLIDER_SIZE
 
    call CheckEnemyCollisionLoop
    cp a, 0
    jr z, .end

    call PlayerIsHit

.end
    pop hl
    pop de
    pop bc
    pop af

    ret


/*  Update camera pos based on player pos
    Player in middle of camera
    When borders are reached, camera stops
*/
UpdatePlayerCamera::
    push af
    push bc
    push hl

.vertical
    ; Make the camera "chase" the player.
    ld a, [wPlayerCamera_PosY]
    ld h, a
    ld a, [wPlayerCamera_PosY + 1]
    ld l, a

    ; Compare the player and camera position.
    ld a, [wPlayer_PosY]
    cp a, h
    ; If playerPos == cameraPos, no need to do anything.
    jr z, .minY
    ; If playerPos > cameraPos
    jr nc, .addVelocityY
    ; If playerPos < cameraPos
.subVelocityY
    ld bc, -VELOCITY_NORMAL
    jr .translateCameraY
.addVelocityY
    ld bc, VELOCITY_NORMAL
.translateCameraY
    add hl, bc
    ld a, l
    ld [wPlayerCamera_PosY + 1], a
    ld a, h
    ld [wPlayerCamera_PosY], a

    ; Offset the camera so that the player is in the centre of the screen.
.minY
    sub a, VIEWPORT_SIZE_Y
    jr nc, .maxY
    xor a
.maxY
    cp a, VIEWPORT_MAX_Y
    jr c, .verticalEnd
    ld a, VIEWPORT_MAX_Y
.verticalEnd
    ld [wShadowSCData], a

.horizontal
    ; Make the camera "chase" the player.
    ld a, [wPlayerCamera_PosX]
    ld h, a
    ld a, [wPlayerCamera_PosX + 1]
    ld l, a

    ; Compare the player and camera position.
    ld a, [wPlayer_PosX]
    cp a, h
    ; If playerPos == cameraPos, no need to do anything.
    jr z, .minX
    ; If playerPos > cameraPos
    jr nc, .addVelocityX
    ; If playerPos < cameraPos
.subVelocityX
    ld bc, -VELOCITY_NORMAL
    jr .translateCameraX
.addVelocityX
    ld bc, VELOCITY_NORMAL
.translateCameraX
    add hl, bc
    ld a, l
    ld [wPlayerCamera_PosX + 1], a
    ld a, h
    ld [wPlayerCamera_PosX], a

.minX
    sub a, VIEWPORT_SIZE_X
    jr nc, .maxX
    xor a
.maxX
    cp a, VIEWPORT_MAX_X
    jr c, .horizontalEnd
    ld a, VIEWPORT_MAX_X
.horizontalEnd
    ld [wShadowSCData + 1], a

    pop hl
    pop bc
    pop af
    ret


/*  Update shadow OAM for player
    Update sprite ID according to current frame of animation and direction
*/
UpdatePlayerShadowOAM::
    push af
    push bc
    push de

    ld a, [wPlayer_DamageFlickerEffect]
    cp a, 0
    jr z, .startUpdateOAM

    ld b, a ; b = DamageFlickerEffect int portion
    ld a, [wPlayer_DamageFlickerEffect + 1]
    add a, DAMAGE_FLICKER_UPDATE_SPEED
    ld [wPlayer_DamageFlickerEffect + 1], a
    jr nc, .updateFlickerEffect

    ld a, b ; Got carry, sub 1 from int portion
    sub a, 1
    ld b, a

    ld [wPlayer_DamageFlickerEffect], a ; update new interger portion value

.updateFlickerEffect
    ; b = DamageFlickerEffect int portion
    ld a, b
    and a, DAMAGE_FLICKER_BITMASK
    cp a, DAMAGE_FLICKER_VALUE
    jp z, .end 

.startUpdateOAM
    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld a, [wCurrentShadowOAMPtr + 1]
    ld h, a

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

    ; Convert player position from world space to screen space.
    ld a, [wShadowSCData]
    ld b, a
    ld a, [wPlayer_PosY]
    sub a, b
    ld b, a ; store y screen pos at b

    ld a, [wShadowSCData + 1]
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

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ld a, h
    ld a, [wCurrentShadowOAMPtr + 1]

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
    ld de, 2
    add hl, de ; offset by 2 to go to the sprite ID address
    ld [hl], b

    ld e, 4
    add hl, de ; offset by 4 to go to the second half sprite ID address
    ld [hl], c

.end
    pop de
    pop bc
    pop af

    ret