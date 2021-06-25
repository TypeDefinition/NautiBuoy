INCLUDE "./src/include/hardware.inc"

/*
    SPRITE INFO

    We are making the top left of the screen (0,0) (there is extra 16 pixels in y and 8 pixels in x on both sides)
    Thus, the original 8x16 sprite, pivot point is bottom right
    We want to make the centre of our sprite (0,0)
*/


/* All of player sprite data, store in ROMX since only need to read */
SECTION "Player Sprite Data", ROMX, BANK[2]

/*
variables to store for animation:
    - the different sprite ID used in animation, in order
*/
PlayerAnimation::
.upAnimation::
    ; frame 1
    db 0
    db OAMF_PAL0
    db 0
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db 2
    db OAMF_PAL0
    db 2
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 3
    db 4
    db OAMF_PAL0
    db 4
    db OAMF_PAL0 | OAMF_XFLIP

.downAnimation::
    db 0
    db OAMF_PAL0 | OAMF_YFLIP
    db 0
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 2
    db 2
    db OAMF_PAL0 | OAMF_YFLIP
    db 2
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 3
    db 4
    db OAMF_PAL0 | OAMF_YFLIP
    db 4
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.rightAnimation::
    db 6
    db OAMF_PAL0
    db 8
    db OAMF_PAL0

    ; frame 2
    db 10
    db OAMF_PAL0
    db 12
    db OAMF_PAL0

    ; frame 3
    db 14
    db OAMF_PAL0
    db 16
    db OAMF_PAL0

.leftAnimation::
    db 8
    db OAMF_PAL0 | OAMF_XFLIP
    db 6
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db 12
    db OAMF_PAL0 | OAMF_XFLIP
    db 10
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 3
    db 16
    db OAMF_PAL0 | OAMF_XFLIP
    db 14
    db OAMF_PAL0 | OAMF_XFLIP
