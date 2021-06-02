INCLUDE "./src/include/hardware.inc"

SECTION "Enemy Sprite Data", ROMX, BANK[2]

/* Data for enemy sprites, not inclusive of sprite ID */
EnemySprites::
.upSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP

.downSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_YFLIP

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.rightSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0

.leftSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0 | OAMF_XFLIP

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x
    db OAMF_PAL0 | OAMF_XFLIP


/* Animation, sprite IDs for the enemy*/
EnemyAnimation::
.upAnimation:: ; up and down has the same frames
    ; frame 1
    db 0
    db 0

    ; frame 2
    db 2
    db 2

    ; frame 3
    db 4
    db 4
.rightAnimation::
    ; frame 1
    db 6
    db 8

    ; frame 2
    db 10
    db 12

    ; frame 3
    db 14
    db 16
.leftAnimation::
    ; frame 1
    db 8
    db 6

    ; frame 2
    db 12
    db 10

    ; frame 3
    db 16
    db 14
.attackUpAnimation::
    ; frame 1
    db 8
    db 6

    ; frame 2
    db 12
    db 10

    ; frame 3
    db 16
    db 14

