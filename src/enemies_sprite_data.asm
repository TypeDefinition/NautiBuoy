INCLUDE "./src/include/hardware.inc"

SECTION "Enemy Sprite Data", ROMX, BANK[2]

/* Data for enemy sprites, */
EnemySpriteData::
.enemyASpriteData::
    db 8 ; y
    db 0 ; x

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x
.enemyBSpriteData::
    db 8 ; y
    db 0 ; x

    ; right sprite of the enemy
    db 8 ; y
    db 8 ; x


/* Animation, sprite IDs for the enemy*/
EnemyAAnimation::
.upAnimation:: ; up and down has the same frames
    ; frame 1
    db $16
    db OAMF_PAL0
    db $16
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $18
    db OAMF_PAL0
    db $18
    db OAMF_PAL0 | OAMF_XFLIP
.downAnimation:: ; up and down has the same frames
    ; frame 1
    db $16
    db OAMF_PAL0 | OAMF_YFLIP
    db $16
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 2
    db $18
    db OAMF_PAL0 | OAMF_YFLIP
    db $18
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.rightAnimation::
    ; frame 1
    db $1E
    db OAMF_PAL0
    db $20
    db OAMF_PAL0

    ; frame 2
    db $22
    db OAMF_PAL0
    db $24
    db OAMF_PAL0
.leftAnimation::
    ; frame 1
    db $20
    db OAMF_PAL0 | OAMF_XFLIP
    db $1E
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $24
    db OAMF_PAL0 | OAMF_XFLIP
    db $22
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; frame 1
    db $1A
    db OAMF_PAL0
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $1C
    db OAMF_PAL0
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 3
    db $1A
    db OAMF_PAL0
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP
.attackDownAnimation::
    ; frame 1
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 2
    db $1C
    db OAMF_PAL0 | OAMF_YFLIP
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 3
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.attackRightAnimation::
    ; frame 1
    db $26
    db OAMF_PAL0
    db $28
    db OAMF_PAL0

    ; frame 2
    db $2A
    db OAMF_PAL0
    db $2C
    db OAMF_PAL0

    ; frame 3
    db $26
    db OAMF_PAL0
    db $28
    db OAMF_PAL0
.attackLeftAnimation::
    ; frame 1
    db $28
    db OAMF_PAL0 | OAMF_XFLIP
    db $26
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $2C
    db OAMF_PAL0 | OAMF_XFLIP
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 1
    db $28
    db OAMF_PAL0 | OAMF_XFLIP
    db $26
    db OAMF_PAL0 | OAMF_XFLIP


/* Enemy B sprite animation */
EnemyBAnimation::
.upAnimation:: ; up and down has the same frames
    ; frame 1
    db $2E
    db OAMF_PAL0
    db $30
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $30
    db OAMF_PAL0
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP
.downAnimation:: ; up and down has the same frames
    ; frame 1
    db $2E
    db OAMF_PAL0 | OAMF_YFLIP
    db $30
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 2
    db $30
    db OAMF_PAL0 | OAMF_YFLIP
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.rightAnimation::
    ; frame 1
    db $32
    db OAMF_PAL0
    db $34
    db OAMF_PAL0

    ; frame 2
    db $32
    db OAMF_PAL0 | OAMF_YFLIP
    db $34
    db OAMF_PAL0 | OAMF_YFLIP
.leftAnimation::
    ; frame 1
    db $34
    db OAMF_PAL0 | OAMF_XFLIP
    db $32
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $34
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $32
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.attackUpAnimation:: ; up and down same animation
    ; frame 1, up
    db $36
    db OAMF_PAL0
    db $36
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2, right
    db $38
    db OAMF_PAL0
    db $3A
    db OAMF_PAL0

    ; frame 3, down
    db $36
    db OAMF_PAL0 | OAMF_YFLIP
    db $36
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 2, left
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP
    db $38
    db OAMF_PAL0 | OAMF_XFLIP
.attackRightAnimation::
    ; frame 1, right
    db $38
    db OAMF_PAL0
    db $3A
    db OAMF_PAL0
    
    ; frame 2, down
    db $36
    db OAMF_PAL0 | OAMF_YFLIP
    db $36
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; frame 3, left
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP
    db $38
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 4, up
    db $36
    db OAMF_PAL0
    db $36
    db OAMF_PAL0 | OAMF_XFLIP