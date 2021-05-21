INCLUDE "./src/hardware.inc"

/* All of player sprite data, store in ROMX since only need to read */
SECTION "Player Sprite Data", ROMX, BANK[2]

PlayerSprites::
.upSprite::
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the player
    db -8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP

.downSprite::
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_YFLIP

    ; right sprite of the player
    db -8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.rightSprite::
    db 0 ; y
    db 0 ; x
    db OAMF_PAL0

    ; bottom sprite of the player
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_YFLIP
    
.leftSprite::
    db 0 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_XFLIP

    ; bottom sprite of the player
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

/*
variables to store for each sprite for every direction:
    - address of animation frame to get sprite ID
    - number of animation frames
    - x, y offset
    - flags

variables to store for animation:
    - the different sprite ID used in animation, in order
*/

PlayerAnimation::
.upAnimation::
    db 0
    db 2

.downAnimation::
    db 0
    db 2

.rightAnimation::
    db 0
    db 2

.leftAnimation::
    db 0
    db 2
