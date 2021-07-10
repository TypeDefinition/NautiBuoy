INCLUDE "./src/include/entities.inc"
include "./src/include/util.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Powerup Data", WRAM0
wPowerupData::
    dstruct PowerUps, wPowerup0
    dstruct PowerUps, wPowerup1
    dstruct PowerUps, wPowerup2
    dstruct PowerUps, wPowerup3
    dstruct PowerUps, wPowerup4
    dstruct PowerUps, wPowerup5
    dstruct PowerUps, wPowerup6
    dstruct PowerUps, wPowerup7
wPowerupDataEnd::
wTotalLevelPowerupNo:: ds 1 ; total number of powerups intialised on map

SECTION "Powerup Manager", ROM0

/*  Read data on where powerups should be and its type
    Initialise the powerups
*/
InitPowerupsAndPlaceOnMap::
    mem_set_small wPowerupData, 0, wPowerupDataEnd - wPowerupData ; reset all enemy data

    ld hl, wPowerupData
    ld bc, LevelOnePowerUpData ; TODO:: make sure address if proper level's enemy data
    ld a, [bc]
    ld d, a
    inc bc

    ld [wTotalLevelPowerupNo], a
    
    ; d = loopCounter, bc = LevelOnePowerUpData
.startLoop
    ld a, [bc]
    ld [hli], a ; store flag

    inc bc
    ld a, [bc]
    ld [hli], a ; store y pos

    inc bc
    ld a, [bc]
    ld [hli], a ; store y pos

    inc bc
    ld a, [bc]
    ld [hli], a ; store sprite ID

    inc bc
    dec d
    jr nz, .startLoop

.endLoop
    ret

/*  Check whether if collided with a power up
    When collided with the powerup, the powerup will take care of the correct action

    b - entity pos y
    c - entity pos x

    registers changed:
    - af
    - de
    - hl
*/
CheckPowerUpCollision::
    ld hl, wPowerupData
    ld a, [wTotalLevelPowerupNo]

.startLoop
    push af ; PUSH AF = loop counter

    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if power up alive
    jr z, .nextLoop

.checkCollided
    push hl ; PUSH HL = power up address
    inc hl

    ld a, [hli]
    ld d, a ; get power up pos y

    ld a, [hli]
    ld e, a ; get power up pos x

    ld h, PLAYER_COLLIDER_SIZE
    ld l, POWERUP_COLLIDER_SIZE

    call SpriteCollisionCheck
    pop hl ; POP HL = power up address
    and a, a ; check if collided
    jr z, .nextLoop

    pop af ; POP AF = loop counter
    call PowerUpCollisionBehaviour
    jr .endLoop

.nextLoop
    inc hl ; next power up address
    inc hl  
    inc hl
    inc hl

    pop af ; POP AF = loop counter
    dec a
    jr nz, .startLoop

.endLoop
    ret

/*  Powerup collision behavior
    hl - power up address
*/ 
PowerUpCollisionBehaviour:
    ld a, [hl] ; get the flags
    and a, BIT_MASK_TYPE
    
.healthPowerup
    cp a, TYPE_HEALTH_POWERUP
    jr nz, .invincibilityPowerup

    ld a, [wPlayer_HP]
    inc a
    ld [wPlayer_HP], a

    call UpdatePlayerHPUI

    jr .end
.invincibilityPowerup
    cp a, TYPE_INVINCIBILITY_POWERUP
    jr nz, .timePowerup

    ld a, INVINCIBILITY_POWER_UP_EFFECT
    ld [wPlayerEffects_InvincibilityPowerUpTimer], a

    ld a, [wPlayer_Flags]
    or a, FLICKER_EFFECT_FLAG ; add flicker effect
    ld [wPlayer_Flags], a 

    call EnableInvincibilityPowerUpUI

    jr .end
.timePowerup
    cp a, TYPE_TIME_POWERUP
    jr nz, .speedPowerup

    ld a, [wGameTimer + 1]
    add a, TIMER_POWER_UP_INC_AMT
    ld [wGameTimer + 1], a

    jr .end
.speedPowerup
    cp a, TYPE_SPEED_POWERUP
    jr nz, .damagePowerup

    ld a, SPEED_POWER_UP_EFFECT
    ld [wPlayerEffects_SpeedPowerUpTimer], a

    ; init new speed
    ld bc, PLAYER_INCREASED_VELOCITY
    ld a, b
    ld [wPlayer_Velocity], a
    ld a, c
    ld [wPlayer_Velocity + 1], a

    call EnableSpeedPowerUpUI
    
    jr .end
.damagePowerup
    ; give player a number of increased damage bullets
    ld a, [wPlayerEffects_BulletPowerUpCounter]
    add a, BULLET_POWER_UP_NUMBER
    ld [wPlayerEffects_BulletPowerUpCounter], a

    call EnableTorpedoPowerUpUI

    jr .end
.end
    xor a
    ld [hl], a ; make the powerup inactive

    ret

/*  Update shadow OAM info for powerups 
    Registers changed:
    - af
    - bc
    - de
    - hl
*/
UpdatePowerUpShadowOAM::
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld bc, wPowerupData

    ld a, [wShadowSCData] ; for pos Y
    ld d, a
    ld a, [wShadowSCData + 1] ; for pos X
    ld e, a

    ld a, [wTotalLevelPowerupNo]

    ; d = screen pos Y, e = screen pos X, bc = power up address, hl = shadowOAM address
.startLoop
    push af ; PUSH AF = loop counter
    
    ld a, [bc]
    bit BIT_FLAG_ACTIVE, a ; check if power up alive
    jr nz, .shadowOAMInit

    inc bc ; next power up address
    inc bc
    inc bc
    inc bc

    jr .nextLoop

.shadowOAMInit
    inc bc
    ld a, [bc]
    sub a, d
    add a, 8 ; bullet sprite y offset = 8
    ld [hli], a ; y pos

    inc bc
    ld a, [bc]
    sub a, e
    add a, 4 ; bullet sprite x offset = 4
    ld [hli], a ; x pos

    inc bc
    ld a, [bc]
    ld [hli], a ; sprite ID

    ld a, OAMF_PAL0
    ld [hli], a ; flags

    inc bc ; next sprite ID address

.nextLoop
    ; bc next sprite address
    pop af ; POP AF = loop counter
    dec a
    jr nz, .startLoop

.endLoop
    ld a, l
    ld [wCurrentShadowOAMPtr], a ; update the shadowOAM pointer

    ret
