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

    ASSERT DIR_UP == 0
    and a, a ; cp a, 0
    jr z, .upStart
    ASSERT DIR_DOWN == 1
    dec a
    jr z, .downStart
    ASSERT DIR_LEFT == 2
    dec a
    jr z, .leftStart
    ASSERT DIR_RIGHT > 2

.rightStart
    interpolate_pos_inc_immd wPlayer_PosX, wPlayer_Velocity
    jp .end
.upStart
    interpolate_pos_dec_immd wPlayer_PosY, wPlayer_Velocity
    jp .end
.downStart
    interpolate_pos_inc_immd wPlayer_PosY, wPlayer_Velocity
    jp .end
.leftStart
    interpolate_pos_dec_immd wPlayer_PosX, wPlayer_Velocity

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
    tile_collision_check_up_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end
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
    tile_collision_check_down_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end
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
    tile_collision_check_left_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end
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
    tile_collision_check_right_immd wPlayer_PosY, wPlayer_PosX, PLAYER_COLLIDER_SIZE, CHARACTER_COLLIDABLE_TILES, .end
.setRightPosTarget
    ; Update Interpolation Target Position
    ld a, [wPlayer_PosXInterpolateTarget]
    add a, TILE_SIZE
    ld [wPlayer_PosXInterpolateTarget], a
.rightEnd

.end
    ret

/* Update Player Movement */
UpdatePlayerMovement::
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

.advancePlayerAnimation
    ld a, [wPlayer_CurrStateMaxAnimFrame]
    ld b, a ; store max frames into b
    
    ld a, [wPlayer_CurrAnimationFrame]
    inc a ; Advance the animation frame by 1.
    cp a, b
    jr nz, .endAnimation
    xor a
.endAnimation
    ld [wPlayer_CurrAnimationFrame], a

.end
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
    ; deduct health first
    ld a, [wPlayer_HP]
    sub a, BULLET_DAMAGE
    ld [wPlayer_HP], a

    ; check health <= 0
    and a
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
    ret


/*  Player check collision with enemy sprite */
PlayerSpriteCollisionCheck:
    ld a, [wPlayer_PosY]
    ld b, a
    ld a, [wPlayer_PosX]
    ld c, a

    ld d, PLAYER_COLLIDER_SIZE
    ld e, ENEMY_PLAYER_COLLIDER_SIZE
 
    call CheckEnemyCollisionLoop
    and a, a
    jr z, .end

    call PlayerIsHit

.end
    ret

; Resets the Player Camera back to (0, 0)
ResetPlayerCamera::
    mem_set_small wPlayerCamera, 0, sizeof_PlayerCamera
    ret

/*  Update camera pos based on player pos
    Player in middle of camera
    When borders are reached, camera stops
*/
UpdatePlayerCamera::
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
    ld bc, -VELOCITY_FAST
    add hl, bc

    ; If camera "overshot" player, snap camera to player.
    cp a, h ; We want playerPos <= cameraPos.
    jr c, .updateCameraY
    ld h, a
    ld l, 0
    jr .updateCameraY

.addVelocityY
    ld bc, VELOCITY_FAST
    add hl, bc
    
    ; If camera "overshot" player, snap camera to player.
    cp a, h ; We want playerPos <= cameraPos.
    jr nc, .updateCameraY
    ld h, a
    ld l, 0

.updateCameraY
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
    ld bc, -VELOCITY_FAST
    add hl, bc

    ; If camera "overshot" player, snap camera to player.
    cp a, h ; We want playerPos <= cameraPos.
    jr c, .updateCameraX
    ld h, a
    ld l, 0
    jr .updateCameraX

.addVelocityX
    ld bc, VELOCITY_FAST
    add hl, bc
    
    ; If camera "overshot" player, snap camera to player.
    cp a, h ; We want playerPos <= cameraPos.
    jr nc, .updateCameraX
    ld h, a
    ld l, 0

.updateCameraX
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

    ret


/*  Update shadow OAM for player
    Update sprite ID according to current frame of animation and direction
*/
UpdatePlayerShadowOAM::
    ld a, [wPlayer_DamageFlickerEffect]
    and a, a
    jr z, .startUpdateOAM

    ld b, a ; b = DamageFlickerEffect int portion
    ld a, [wPlayer_DamageFlickerEffect + 1]
    add a, DAMAGE_FLICKER_UPDATE_SPEED
    ld [wPlayer_DamageFlickerEffect + 1], a
    jr nc, .updateFlickerEffect

    dec b
    ld a, b
    ld [wPlayer_DamageFlickerEffect], a ; update new interger portion value

.updateFlickerEffect
    ; b = DamageFlickerEffect int portion
    ld a, b
    and a, DAMAGE_FLICKER_BITMASK
    cp a, DAMAGE_FLICKER_VALUE
    jp z, .end 

.startUpdateOAM
    ; do a dir check for sprite
    ld a, [wPlayer_Direction]

    ASSERT DIR_UP == 0
    and a, a ; cp a, 0
    jr z, .upSprite
    ASSERT DIR_DOWN == 1
    dec a
    jr z, .downSprite
    ASSERT DIR_LEFT == 2
    dec a
    jr z, .leftSprite
    ASSERT DIR_RIGHT > 2

.rightSprite
    ld de, PlayerAnimation.rightAnimation
    jr .endSpriteDir
.upSprite
    ld de, PlayerAnimation.upAnimation
    jr .endSpriteDir
.downSprite
    ld de, PlayerAnimation.downAnimation
    jr .endSpriteDir
.leftSprite
    ld de, PlayerAnimation.leftAnimation

.endSpriteDir
    ld a, [wPlayer_CurrAnimationFrame]
    sla a ; curr animation frame x 4
    sla a

    add a, e 
    ld e, a 
    ld a, d 
    adc a, 0
    ld d, a ; offset animation address de
    
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
    ; b = pos Y, c = pos X, de = animation address

    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld a, b
    add a, 8
    ld [hli], a ; init screen y Pos, first sprite y offset 8
    
    ld a, c 
    ld [hli], a ; init screen x pos, first sprite x offset 0

    ld a, [de] ; get sprite ID
    ld [hli], a
    inc de

    ld a, [de] ; get flags
    ld [hli], a
    inc de

    ; Init second half of player sprite to shadow OAM
    ld a, b
    add a, 8
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, c 
    add a, 8
    ld [hli], a ; init screen x pos, second sprite x offset 8

    ld a, [de] ; get sprite ID
    ld [hli], a
    inc de

    ld a, [de] ; get flags
    ld [hli], a

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
    ld a, h
    ld [wCurrentShadowOAMPtr + 1], a

.end
    ret