INCLUDE "./src/include/entities.inc"

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
.end
wTotalLevelPowerupNo:: ds 1 ; total number of powerups intialised on map

SECTION "Powerup Manager", ROM0

/*  Read data on where powerups should be and its type
    Initialise the powerups
*/
InitPowerupsAndPlaceOnMap::
    mem_set_small wPowerupData, 0, wPowerupData.end - wPowerupData ; reset all enemy data

    ld hl, wPowerupData
    ld bc, LevelOnePowerUpData ; TODO:: make sure address if proper level's enemy data
    ld a, [bc]
    ld d, a

    ld [wTotalLevelPowerupNo], a

    ; d = loopCounter
.startLoop
    ld a, [bc]
    ld [hli], a ; store flag
    inc bc

    ld a, [bc]
    ld [hli], a ; store y pos

    ld a, [bc]
    ld [hli], a ; store y pos

    dec d
    jr nz, .startLoop

.endLoop
    ret

; make a function to check for collision
; if collide run the proper behavior
; also able to render the powerup


RenderPowerUp::
    ret
