INCLUDE "./src/include/entities.inc"
include "./src/include/util.inc"
INCLUDE "./src/include/definitions.inc"

DEF HEART_POWERUP_SPRITE_ID EQU $68
DEF INVINCIBILITY_POWERUP_SPRITE_ID EQU $64
DEF TIME_POWERUP_SPRITE_ID EQU $66

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

.startLoop
    ld a, [hli]
    bit BIT_FLAG_ACTIVE, a ; check if power up alive
    jr nz, .checkCollided

    ;inc hl  ; check next power up
    ;inc hl
    ;jr .startLoop
    jr .endLoop

.checkCollided
    ld a, [hli]
    ld d, a ; get power up pos y

    ld a, [hli]
    ld e, a ; get power up pos x

    push hl ; PUSH HL = power up address
    ld h, PLAYER_COLLIDER_SIZE
    ld l, POWERUP_COLLIDER_SIZE

    call SpriteCollisionCheck
    pop hl ; POP HL = power up address
    and a, a ; check if collided
    jr z, .endLoop

    ; TODO:: set powerup inactive and run the corresponding behaviors of the powerup
    dec hl
    dec hl
    dec hl ; get back flag address
    call PowerUpCollisionBehaviour

.endLoop
    ret

/*  Powerup collision behavior
    hl - power up address
*/ 
PowerUpCollisionBehaviour:
    ld a, [hl] ; get the flags
    and a, BIT_MASK_TYPE
    
.healthPowerup
    and a, a ; TYPE_HEALTH_POWERUP = 0
    jr nz, .invincibilityPowerup

    ld a, [wPlayer_HP]
    inc a
    ld [wPlayer_HP], a

    jr .end
.invincibilityPowerup
    cp a, TYPE_INVINCIBILITY_POWERUP
    jr nz, .timePowerup
.timePowerup
    cp a, TYPE_TIME_POWERUP
    jr nz, .speedPowerup
.speedPowerup
    cp a, TYPE_SPEED_POWERUP
    jr nz, .damagePowerup
.damagePowerup

.end
    xor a
    ld [hl], a ; make the powerup inactive

    ret

/*  Update shadow OAM info for powerups */
UpdatePowerUpShadowOAM::
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld bc, wPowerupData

    ld a, [wShadowSCData] ; for pos Y
    ld d, a
    ld a, [wShadowSCData + 1] ; for pos X
    ld e, a

    ; d = screen pos Y, e = screen pos X, bc = power up address, hl = shadowOAM address
.startLoop
    ld a, [bc]
    bit BIT_FLAG_ACTIVE, a ; check if power up alive
    jr z, .endLoop

    ; TODO check if the powerup is active first
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

    ; TODO:: check power up type
    ld a, HEART_POWERUP_SPRITE_ID
    ld [hli], a ; sprite ID

    ld a, OAMF_PAL0
    ld [hli], a ; flags 

.endLoop
    ld a, l
    ld [wCurrentShadowOAMPtr], a ; update the shadowOAM pointer

    ret
