INCLUDE "./src/hardware.inc"

/*
    SPRITE INFO

    We are making the top left of the screen (0,0) (there is extra 16 pixels in y and 8 pixels in x on both sides)
    Thus, the original 8x16 sprite, pivot point is bottom right
    We want to make the centre of our sprite (0,0)
*/


/* All of player sprite data, store in ROMX since only need to read */
SECTION "Player Sprite Data", ROMX, BANK[2]

PlayerSprites::
.upSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the player
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP

.downSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_YFLIP

    ; right sprite of the player
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.rightSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the player
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0
    
.leftSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_XFLIP

    ; right sprite of the player
    db 8 ; y
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

    ; frame 3
    db 4
    db 4

.downAnimation::
    db 0
    db 0

    ; frame 2
    db 2
    db 2

    ; frame 3
    db 4
    db 4

.rightAnimation::
    db 6
    db 8

    ; frame 2
    db 10
    db 12

    ; frame 3
    db 14
    db 16

.leftAnimation::
    db 8
    db 6

    ; frame 2
    db 12
    db 10

    ; frame 3
    db 16
    db 14