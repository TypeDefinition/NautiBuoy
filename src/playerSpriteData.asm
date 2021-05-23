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
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the player
    db -8 ; y
    db 8 ; x
    db OAMF_PAL0
    
.leftSprite::
    db -8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_XFLIP

    ; right sprite of the player
    db -8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP

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
    ; frame 1
    db 0
    db 0

    ; frame 2
    db 2
    db 2

.downAnimation::
    db 0
    db 0

.rightAnimation::
    db 2
    db 4

.leftAnimation::
    db 4
    db 2
