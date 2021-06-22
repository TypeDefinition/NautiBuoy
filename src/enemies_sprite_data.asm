INCLUDE "./src/include/hardware.inc"

SECTION "Enemy Sprite Data", ROMX, BANK[2]

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

/* Animation, sprite IDs for the enemy C*/
EnemyCAnimation::
.upAnimation:: ; up and down has the same frames
    ; frame 1
    db $42
    db OAMF_PAL0
    db $44
    db OAMF_PAL0

    ; frame 2
    db $46
    db OAMF_PAL0
    db $48
    db OAMF_PAL0
.rightAnimation::
    ; frame 1
    db $3C
    db OAMF_PAL0
    db $3C
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $3E
    db OAMF_PAL0
    db $3E
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; frame 1
    db $40
    db OAMF_PAL0
    db $40
    db OAMF_PAL0 | OAMF_XFLIP

/* Animation for enemy D */
EnemyDAnimation::
.sleepAnimation::
    ; frame 1
    db $4E
    db OAMF_PAL0
    db $50
    db OAMF_PAL0

    ; frame 2
    db $52
    db OAMF_PAL0
    db $54
    db OAMF_PAL0
.upAnimation:: ; up and down has the same frames
    ; frame 1
    db $52
    db OAMF_PAL0
    db $56
    db OAMF_PAL0

    ; frame 2
    db $58
    db OAMF_PAL0
    db $5A
    db OAMF_PAL0
.downAnimation:: ; up and down has the same frames
    ; frame 1
    db $52
    db OAMF_PAL0 | OAMF_YFLIP
    db $56
    db OAMF_PAL0 | OAMF_YFLIP

    ; frame 2
    db $58
    db OAMF_PAL0 | OAMF_YFLIP
    db $5A
    db OAMF_PAL0 | OAMF_YFLIP
.rightAnimation::
    ; frame 1
    db $60
    db OAMF_PAL0
    db $62
    db OAMF_PAL0

    ; frame 2
    db $5C
    db OAMF_PAL0
    db $5E
    db OAMF_PAL0
.leftAnimation::
    ; frame 1
    db $62
    db OAMF_PAL0 | OAMF_XFLIP
    db $60
    db OAMF_PAL0 | OAMF_XFLIP

    ; frame 2
    db $5E
    db OAMF_PAL0 | OAMF_XFLIP
    db $5C
    db OAMF_PAL0 | OAMF_XFLIP