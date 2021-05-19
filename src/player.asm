INCLUDE "./src/hardware.inc"
INCLUDE "./src/structs.inc"
INCLUDE "./src/game_structs.inc"

PLAYER_SPEED EQU $8

/* Any logic/behavior/function related to player here */
SECTION "Player", ROM0

InitPlayer::
    ld a, 90
    ld [wPlayer_YPos], a
    ld [wPlayer_XPos], a
    ret

/* handles player input */ 
HandlePlayerInput::
    ; TODO:: Manage the sprite to show here too in the sprite ID
    
    ld a, [wCurrentInputKeys]
    ld b, a ; store the input keys into b

    ld a, [wPlayer_YPos]
.upMovement
    bit PADB_UP, b
    jr z, .downMovement
    sub PLAYER_SPEED

    jr .rightMovement

.downMovement
    bit PADB_DOWN, b
    jr z, .rightMovement
    add PLAYER_SPEED

.rightMovement
    ; write the y pos
    ld [wPlayer_YPos], a
    ld a, [wPlayer_XPos]

    bit PADB_RIGHT, b
    jr z, .leftMovement
    add PLAYER_SPEED

    jr .endMovement

.leftMovement
    bit PADB_LEFT, b
    jr z, .endMovement
    sub PLAYER_SPEED

.endMovement
    ld [wPlayer_XPos], a
    ret


/*  Update shadow OAM for player
    hl - shadowOAM address where the player is
*/
UpdatePlayerShadowOAM::
    ; TODO:: properly convert the position to screen position instead
    ; TEMP CODES, WILL INCLUDE META SPRITES SOON

    ld a, [wPlayer_YPos]
    ld [hli], a
    ld a, [wPlayer_XPos]
    ld [hli], a
    xor a
    ld [hli], a ; sprite ID, for now it'll just be this
    ld [hli], a  ; TEMP flags

    ret

SECTION "Player variables", WRAM0
wPlayerData::
    dstruct Player, wPlayer 
