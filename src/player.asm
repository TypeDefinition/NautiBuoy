INCLUDE "./src/hardware.inc"
INCLUDE "./src/structs.inc"
INCLUDE "./src/entities.inc"

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

    ld a, $01
    ld [wPlayer_Active], a
    ld a, TAG_PLAYER
    ld [wPlayer_Tag], a
    ld a, TYPE_PLAYER
    ld [wPlayer_Type], a
    ld a, 96
    ld [wPlayer_PosY], a
    ld [wPlayer_PosX], a
    xor a
    ld [wPlayer_Direction], a
    ld a, 8
    ld [wPlayer_Velocity], a
    ld [wPlayer_ColSize], a
    ld a, 3
    ld [wPlayer_HP], a

    ; TODO: Make const variables for the initial HP, posX and posY, and velocity

    pop af
    ret

; Move the player based on user input.
UpdatePlayerMovement::
    ; TODO:: Manage the sprite to show here too in the sprite ID
    push af
    push bc
    push hl

    ld a, [wCurrentInputKeys]
    ld b, a ; store the input keys into b
    ld hl, wPlayer_Velocity

    ; Vertical Movement
    ld a, [wPlayer_PosY]
.up
    bit PADB_UP, b
    jr z, .down
    sub a, [hl]
.down
    bit PADB_DOWN, b
    jr z, .verticalEnd
    add a, [hl]
.verticalEnd
    ld [wPlayer_PosY], a

    ; Horizontal Movement
    ld a, [wPlayer_PosX]
.right
    bit PADB_RIGHT, b
    jr z, .left
    add a, [hl]
.left
    bit PADB_LEFT, b
    jr z, .horizontalEnd
    sub a, [hl]
.horizontalEnd
    ld [wPlayer_PosX], a

.exit
    pop hl
    pop bc
    pop af
    ret

UpdatePlayerAttack::
    ret

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
    hl - shadowOAM address where the player is
*/
UpdatePlayerShadowOAM::
    ; TODO:: properly convert the position to screen position instead
    ; TEMP CODES, WILL INCLUDE META SPRITES SOON
    push af
    push bc
    push hl

    ; Convert player position from world space to screen space.
    ld a, [rSCY]
    ld b, a
    ld a, [wPlayer_PosY]
    sub a, b
    ld [hli], a ; init screen y Pos
    
    ld a, [rSCX]
    ld b, a
    ld a, [wPlayer_PosX]
    sub a, b
    ld [hli], a ; init screen x pos
    
    xor a
    ld [hli], a ; sprite ID, for now it'll just be this
    ld [hli], a  ; TEMP flags for sprite

    pop hl
    pop bc
    pop af
    ret