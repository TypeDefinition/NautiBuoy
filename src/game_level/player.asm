INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/tile_collision.inc"
INCLUDE "./src/include/movement.inc"

SECTION "Player Data", WRAM0
    dstruct Character, wPlayer
    dstruct PlayerEffects, wPlayerEffects
wPlayerFireRate:: ds 2 ; first half is fraction, second half is int
    
SECTION "Player Camera Data", WRAM0
    dstruct PlayerCamera, wPlayerCamera

/* Any logic/behavior/function related to player here 
    parameters:
        - hl, player data address
*/
SECTION "Player", ROM0
InitialisePlayer::
    push af

    ld a, FLAG_ACTIVE | FLAG_PLAYER
    ld [wPlayer_Flags], a
    
    ; Set Position
    ld a, [hli] ; get y pos
    ld [wPlayer_PosYInterpolateTarget], a
    ld [wPlayer_PosY], a
    ld [wPlayer_SpawnPosition], a
    
    ld a, [hli] ; get x pos
    ld [wPlayer_PosX], a
    ld [wPlayer_PosXInterpolateTarget], a
    ld [wPlayer_SpawnPosition + 1], a
    
    xor a
    ld [wPlayer_PosY + 1], a
    ld [wPlayer_PosX + 1], a
    ; Set Direction
    ld a, DIR_UP
    ld [wPlayer_Direction], a
    ; Set HP
    ld a, [hl] ; get hp
    ld [wPlayer_HP], a
    ; Set Velocity
    ld hl, PLAYER_DEFAULT_VELOCITY
    ld a, h
    ld [wPlayer_Velocity], a
    ld a, l
    ld [wPlayer_Velocity + 1], a
    ; Set Animation
    xor a
    ld [wPlayer_CurrAnimationFrame], a
    ld [wPlayer_FlickerEffect], a
    ld [wPlayer_FlickerEffect + 1], a
    ld a, PLAYER_WALK_FRAMES
    ld [wPlayer_CurrStateMaxAnimFrame], a

    xor a
    ld hl, wPlayerEffects
    ld [hli], a
    ld [hli], a ; speed power up timer = 0
    ld [hli], a
    ld [hli], a ; invincibility power up
    ld [hli], a ; bullet power up
    ld [hli], a
    ld [hli], a ; damage invincibility power up

    ld hl, wPlayerFireRate
    ld [hli], a
    ld [hli], a

    call UpdatePlayerHPUI

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
    ld a, [wPlayer_Flags]
    and a, FLICKER_EFFECT_FLAG ; flicker belongs to the invincibility frames
    jr nz, .updateMovement

    call PlayerSpriteCollisionCheck ; have to check here, in case enemy moves into player instead

.updateMovement
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
    jr .advancePlayerAnimation
.interpolatePosition
    call InterpolatePlayerPosition

    ; to check power up collision
    ld a, [wPlayer_PosY]
    ld b, a 
    ld a, [wPlayer_PosX]
    ld c, a 
    call CheckPowerUpCollision

.advancePlayerAnimation
    ld a, [wPlayer_UpdateFrameCounter]
    add a, PLAYER_ANIMATION_UPDATE_SPEED
    ld [wPlayer_UpdateFrameCounter], a
    jr nc, .end

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
    call UpdatePlayerEffects
    
    ret

/*  For checking player inputs that allow them to attack
    Current attacks:
    - Shooting (press A)
*/
UpdatePlayerAttack::
    ld hl, wPlayerFireRate + 1
    ld a, [hl]
    and a, a
    jr z, .startShooting ; have yet to reach the firerate

    ld b, a ; b = int portion

    dec hl
    ld a, [hl]
    add a, FIRE_RATE_UPDATE_SPEED
    ld [hli], a

    ld a, b
    sbc a, 0
    ld [hl], a
    jr nz, .finishAttack

.startShooting ; SHOOTING
    ld a, [wNewlyInputKeys]
    bit PADB_A, a
    jr z, .finishAttack ; if player doesnt PRESS A

    ; update the fire rate
    ld a, FIRE_RATE
    ld [hl], a 
    dec hl
    xor a
    ld [hl], a

    ; init bullets
    ld hl, wBulletObjects
    ld b, PLAYER_BULLET_NUMBER
    call GetInactiveBullet
    
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a
    jr nz, .finishAttack ; if active, finish attack

    ld a, [wPlayerEffects_BulletPowerUpCounter]
    and a, a ; check if a = 0, if 0 means default
    jr z, .initBullet

    dec a
    ld [wPlayerEffects_BulletPowerUpCounter], a ; reduce the bullet
    ld a, TYPE_BULLET_POWER_UP ; set type
    call z, DisableTorpedoPowerUpUI

.initBullet ; set the variables
    or a, FLAG_ACTIVE | FLAG_PLAYER
    ld [hli], a ; its alive

    ld a, [wPlayer_Direction]
    ld [hli], a ; direction
 
    ld a, BULLET_VELOCITY
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
    
    call PlayerShootSFX

.finishAttack
    ret

/*  Player has been hit by enemy/projectile 

    WARNING: this is assuming health < 127. Want to prevent underflow, we defined bit 7 to be for -ve
*/
PlayerIsHit::
    ld a, [wPlayer_HP]

    ; deduct health 
    dec a
    ld [wPlayer_HP], a

    call UpdatePlayerHPUI

    and a ; check health <= 0
    jr z, .dead

.damageEffect ; not dead, set damage flicker effect and teleport to spawn    
    ld a, DAMAGE_INVINCIBILITY_EFFECT
    ld [wPlayerEffects_DamageInvincibilityTimer], a

    ld a, [wPlayer_SpawnPosition]
    ld [wPlayer_PosYInterpolateTarget], a
    ld [wPlayer_PosY], a

    ld a, [wPlayer_SpawnPosition + 1]
    ld [wPlayer_PosXInterpolateTarget], a
    ld [wPlayer_PosX], a 

    xor a
    ld [wPlayer_PosY + 1], a
    ld [wPlayer_PosX + 1], a
    ld [wPlayer_FlickerEffect], a
    ld [wPlayer_FlickerEffect + 1], a 

    ; remove possible powerups and reset things properly
    ld [wPlayerEffects_SpeedPowerUpTimer], a
    ld bc, PLAYER_DEFAULT_VELOCITY
    ld a, b
    ld [wPlayer_Velocity], a
    ld a, c
    ld [wPlayer_Velocity + 1], a

    ld a, [wPlayer_Flags]
    and a, BIT_MASK_TYPE_REMOVE ; remove any effects on player
    or a, FLICKER_EFFECT_FLAG ; add flicker effect
    ld [wPlayer_Flags], a 

    call PlayerGetsHitEnemyBehavior ; update enemy behavior for getting hit
    ret

.dead
    ld a, LOSE_REASON_HP
    ld [wLoseReason], a
    ld hl, JumpLoadLoseScreen
    call SetProgramLoopCallback
    ret

/*  Player check collision with enemy sprites */
PlayerSpriteCollisionCheck:
    ld a, [wPlayer_PosY]
    ld b, a
    ld a, [wPlayer_PosX]
    ld c, a

    ld d, PLAYER_ENEMY_COLLIDER_SIZE
 
    call CheckEnemyCollisionLoop
    and a, a
    call nz, PlayerIsHit

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
    sub a, VIEWPORT_SIZE_Y/2
    ld d, a
    jr nc, .maxY
    xor a
    ld d, a
.maxY
    ; Get the pixel size of the map. We have to use 16bit because the max size is 256. 1 fucking pixel more than 8 bit can store.
    ld a, [wMapSizeY]
    ld h, a
    ld a, [wMapSizeY+1]
    ld l, a
    ; Get the max position of the viewport. This will be a 8bit number, so h will be 0.
    ld bc, -VIEWPORT_SIZE_Y
    add hl, bc

    ld a, d
    cp a, l
    jr c, .verticalEnd
    ld a, l
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
    sub a, VIEWPORT_SIZE_X/2
    ld d, a
    jr nc, .maxX
    xor a
    ld d, a
.maxX
    ; Get the pixel size of the map. We have to use 16bit because the max size is 256. 1 fucking pixel more than 8 bit can store.
    ld a, [wMapSizeX]
    ld h, a
    ld a, [wMapSizeX+1]
    ld l, a
    ; Get the max position of the viewport. This will be a 8bit number, so h will be 0.
    ld bc, -VIEWPORT_SIZE_X
    add hl, bc

    ld a, d
    cp a, l
    jr c, .horizontalEnd
    ld a, l
.horizontalEnd
    ld [wShadowSCData + 1], a

    ret


UpdatePlayerEffects:

.damageInvincibility
    ld a, [wPlayerEffects_DamageInvincibilityTimer]
    and a, a
    jr z, .invincibilityPowerUp

    ld b, a ; b = the int portion of the timer
    ld a, [wPlayerEffects_DamageInvincibilityTimer + 1]
    add a, DAMAGE_INVINCIBILITY_UPDATE_SPEED
    ld [wPlayerEffects_DamageInvincibilityTimer + 1], a
    jr nc, .endUpdatePlayerEffects

    dec b
    ld a, b
    ld [wPlayerEffects_DamageInvincibilityTimer], a ; update the new value
    
    jr nz, .endUpdatePlayerEffects
    ld a, [wPlayer_Flags] ; reset the effect flags
    xor a, FLICKER_EFFECT_FLAG
    ld [wPlayer_Flags], a
    
    jr .endUpdatePlayerEffects

.invincibilityPowerUp
    ld a, [wPlayerEffects_InvincibilityPowerUpTimer]
    and a, a
    jr z, .speedPowerUp

    ; update the value
    ld b, a ; b = the int portion of the timer
    ld a, [wPlayerEffects_InvincibilityPowerUpTimer + 1]
    add a, DAMAGE_INVINCIBILITY_UPDATE_SPEED
    ld [wPlayerEffects_InvincibilityPowerUpTimer + 1], a
    jr nc, .speedPowerUp

    dec b
    ld a, b
    ld [wPlayerEffects_InvincibilityPowerUpTimer], a ; update the new value
    jr nz, .speedPowerUp

    ld a, [wPlayer_Flags] ; reset the effect flags
    xor a, FLICKER_EFFECT_FLAG
    ld [wPlayer_Flags], a

    call DisableInvincibilityPowerUpUI
    
.speedPowerUp
    ld a, [wPlayerEffects_SpeedPowerUpTimer]
    and a, a
    jr z, .endUpdatePlayerEffects

    ; update the value
    ld b, a ; b = the int portion of the timer
    ld a, [wPlayerEffects_SpeedPowerUpTimer + 1]
    add a, SPEED_POWER_UP_UPDATE_SPEED
    ld [wPlayerEffects_SpeedPowerUpTimer + 1], a
    jr nc, .endUpdatePlayerEffects

    dec b
    ld a, b
    ld [wPlayerEffects_SpeedPowerUpTimer], a ; update the new value
    jr nz, .endUpdatePlayerEffects

    ; reset velocity as effect is gone
    ld hl, PLAYER_DEFAULT_VELOCITY
    ld a, h
    ld [wPlayer_Velocity], a
    ld a, l
    ld [wPlayer_Velocity + 1], a

    call DisableSpeedPowerUpUI

.endUpdatePlayerEffects
    ret

/*  Update shadow OAM for player
    Update sprite ID according to current frame of animation and direction
*/
UpdatePlayerShadowOAM::
    ld a, [wPlayer]
    and a, FLICKER_EFFECT_FLAG ; check if flicker flag is on
    jr z, .startUpdateOAM
    
    ld a, [wPlayerEffects_InvincibilityPowerUpTimer]
    and a, a
    jr nz, .invincibilityFlicker

.damageFlicker
    ld a, [wPlayer_FlickerEffect + 1]
    add a, PLAYER_FLICKER_UPDATE_SPEED
    ld [wPlayer_FlickerEffect + 1], a

    ld a, [wPlayer_FlickerEffect]
    adc a, 0
    ld [wPlayer_FlickerEffect], a ; update new interger portion value

    and a, FLICKER_BITMASK ; every alternate update we dont render
    jr z, .startUpdateOAM

    ret ; early return 

.invincibilityFlicker
    ; a = InvincibilityPowerUpTimer amount
    cp a, INVINCIBILITY_POWER_UP_FLICKER_SLOW_EFFECT

    ld a, [wPlayer_FlickerEffect + 1]
    ld b, PLAYER_FLICKER_UPDATE_SPEED
    jr nc, .continueInvincibilityFlicker

    ld b, PLAYER_FLICKER_SLOW_UPDATE_SPEED

.continueInvincibilityFlicker
    ; b = flicker speed
    add a, b
    ld [wPlayer_FlickerEffect + 1], a

    ld a, [wPlayer_FlickerEffect]
    adc a, 0
    ld [wPlayer_FlickerEffect], a ; update new interger portion value

    and a, FLICKER_BITMASK ; every alternate update we dont render
    jr z, .startUpdateOAM

    ld a, OAMF_PAL1

.startUpdateOAM
    ; a = power up flag
    push af ; PUSH AF = power up flag

    ld a, [wPlayer_Direction]

    ; do a dir check for sprite
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
    add a, 8 ; y sprite offset = 8
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
    ld [hli], a ; init screen y Pos, first sprite y offset 8
    
    ld a, c 
    ld [hli], a ; init screen x pos, first sprite x offset 0

    ld a, [de] ; get sprite ID
    ld [hli], a
    inc de

    pop af ; POP AF = power up flag
    push af ; PUSH AF = power up flag
    push hl ; push hl = sprite oam address
    ld h, d
    ld l, e
    or a, [hl]
    pop hl ; POP hl = sprite oam address
    ld [hli], a ; flags
    inc de

    ; Init second half of player sprite to shadow OAM
    ld a, b
    ld [hli], a ; init screen y Pos, second sprite y offset 8
    
    ld a, c 
    add a, 8
    ld [hli], a ; init screen x pos, second sprite x offset 8

    ld a, [de] ; get sprite ID
    ld [hli], a
    inc de

    pop af ; POP AF = power up flag
    push hl ; push hl = sprite oam address
    ld h, d
    ld l, e
    or a, [hl] ; add the other palette
    pop hl ; POP hl = sprite oam address
    ld [hli], a ; flags

    ; update the current address of from hl to the wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a
.end
    ret