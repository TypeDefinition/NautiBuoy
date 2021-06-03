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
    db $16
    db $16

    ; frame 2
    db $18
    db $18
.rightAnimation::
    ; frame 1
    db $1E
    db $20

    ; frame 2
    db $22
    db $24
.leftAnimation::
    ; frame 1
    db $20
    db $1E

    ; frame 2
    db $24
    db $22
.attackUpAnimation::
    ; frame 1
    db $1A
    db $1A

    ; frame 2
    db $1C
    db $1C

    ; frame 3
    db $1A
    db $1A
.attackRightAnimation::
    ; frame 1
    db $26
    db $28

    ; frame 2
    db $2A
    db $2C

    ; frame 3
    db $26
    db $28
.attackLeftAnimation::
    ; frame 1
    db $28
    db $26

    ; frame 2
    db $2C
    db $2A

    ; frame 1
    db $28
    db $26

