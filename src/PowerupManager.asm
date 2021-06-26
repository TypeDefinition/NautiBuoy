INCLUDE "./src/include/entities.inc"
include "./src/include/util.inc"

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

; make a function to check for collision
; if collide run the proper behavior
; also able to render the powerup


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
    ld [wCurrentShadowOAMPtr], a

    ret
