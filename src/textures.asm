INCLUDE "./src/include/hardware.inc"

SECTION "Background & Window Tiles", ROMX
BGWindowTileData::
    INCBIN "./tile_data/background_and_ui.2bpp" ; INCBIN copies the binary file contents directly into the ROM.
.end::

SECTION "Sprites", ROMX
Sprites::
    INCBIN "./tile_data/tempPlayer.2bpp"
    INCBIN "./tile_data/turtleEnemy.2bpp"
    INCBIN "./tile_data/enemyShootOneDir.2bpp"
    INCBIN "./tile_data/ghostEnemy.2bpp"
    INCBIN "./tile_data/Powerups.2bpp"
.end::

BulletSprites::
.upDefaultSprite::
    db 18 ; sprite ID
    db OAMF_PAL0 
.downDefaultSprite::
    db 18 ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.rightDefaultSprite::
    db 20 ; sprite ID
    db OAMF_PAL0
.leftDefaultSprite::
    db 20 ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP

.upPowerUpBulletSprite
    db $6C ; sprite ID
    db OAMF_PAL0 
.downPowerUpBulletDefaultSprite
    db $6C ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.rightPowerUpBulletDefaultSprite
    db $6C ; sprite ID
    db OAMF_PAL0
.leftPowerUpBulletDefaultSprite
    db $6C ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP

PlayerAnimation::
.upAnimation::
    ; Frame 1
    db 0
    db OAMF_PAL0 | OAMF_PRI
    db 0
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db 2
    db OAMF_PAL0 | OAMF_PRI
    db 2
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 3
    db 4
    db OAMF_PAL0 | OAMF_PRI
    db 4
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

.downAnimation::
    ; Frame 1
    db 0
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db 0
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db 2
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db 2
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP | OAMF_PRI

    ; Frame 3
    db 4
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db 4
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP | OAMF_PRI

.rightAnimation::
    db 6
    db OAMF_PAL0 | OAMF_PRI
    db 8
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db 10
    db OAMF_PAL0 | OAMF_PRI
    db 12
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 3
    db 14
    db OAMF_PAL0 | OAMF_PRI
    db 16
    db OAMF_PAL0 | OAMF_PRI

.leftAnimation::
    db 8
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db 6
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db 12
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db 10
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 3
    db 16
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db 14
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

/* Animation, sprite IDs for the enemy*/
EnemyAAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $16
    db OAMF_PAL0
    db $16
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $18
    db OAMF_PAL0
    db $18
    db OAMF_PAL0 | OAMF_XFLIP
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $16
    db OAMF_PAL0 | OAMF_YFLIP
    db $16
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 2
    db $18
    db OAMF_PAL0 | OAMF_YFLIP
    db $18
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.rightAnimation::
    ; Frame 1
    db $1E
    db OAMF_PAL0
    db $20
    db OAMF_PAL0

    ; Frame 2
    db $22
    db OAMF_PAL0
    db $24
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $20
    db OAMF_PAL0 | OAMF_XFLIP
    db $1E
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $24
    db OAMF_PAL0 | OAMF_XFLIP
    db $22
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; Frame 1
    db $1A
    db OAMF_PAL0
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $1C
    db OAMF_PAL0
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 3
    db $1A
    db OAMF_PAL0
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP
.attackDownAnimation::
    ; Frame 1
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 2
    db $1C
    db OAMF_PAL0 | OAMF_YFLIP
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 3
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP
    db $1A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.attackRightAnimation::
    ; Frame 1
    db $26
    db OAMF_PAL0
    db $28
    db OAMF_PAL0

    ; Frame 2
    db $2A
    db OAMF_PAL0
    db $2C
    db OAMF_PAL0

    ; Frame 3
    db $26
    db OAMF_PAL0
    db $28
    db OAMF_PAL0
.attackLeftAnimation::
    ; Frame 1
    db $28
    db OAMF_PAL0 | OAMF_XFLIP
    db $26
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $2C
    db OAMF_PAL0 | OAMF_XFLIP
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 1
    db $28
    db OAMF_PAL0 | OAMF_XFLIP
    db $26
    db OAMF_PAL0 | OAMF_XFLIP


/* Enemy B sprite animation */
EnemyBAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $2E
    db OAMF_PAL0
    db $30
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $30
    db OAMF_PAL0
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $2E
    db OAMF_PAL0 | OAMF_YFLIP
    db $30
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 2
    db $30
    db OAMF_PAL0 | OAMF_YFLIP
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.rightAnimation::
    ; Frame 1
    db $32
    db OAMF_PAL0
    db $34
    db OAMF_PAL0

    ; Frame 2
    db $32
    db OAMF_PAL0 | OAMF_YFLIP
    db $34
    db OAMF_PAL0 | OAMF_YFLIP
.leftAnimation::
    ; Frame 1
    db $34
    db OAMF_PAL0 | OAMF_XFLIP
    db $32
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $34
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $32
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
.attackUpAnimation:: ; up and down same animation
    ; Frame 1, up
    db $36
    db OAMF_PAL0
    db $36
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2, right
    db $38
    db OAMF_PAL0
    db $3A
    db OAMF_PAL0

    ; Frame 3, down
    db $36
    db OAMF_PAL0 | OAMF_YFLIP
    db $36
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 2, left
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP
    db $38
    db OAMF_PAL0 | OAMF_XFLIP
.attackRightAnimation::
    ; Frame 1, right
    db $38
    db OAMF_PAL0
    db $3A
    db OAMF_PAL0
    
    ; Frame 2, down
    db $36
    db OAMF_PAL0 | OAMF_YFLIP
    db $36
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; Frame 3, left
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP
    db $38
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 4, up
    db $36
    db OAMF_PAL0
    db $36
    db OAMF_PAL0 | OAMF_XFLIP

/* Animation, sprite IDs for the enemy C*/
EnemyCAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $42
    db OAMF_PAL0
    db $44
    db OAMF_PAL0

    ; Frame 2
    db $46
    db OAMF_PAL0
    db $48
    db OAMF_PAL0
.rightAnimation::
    ; Frame 1
    db $3C
    db OAMF_PAL0
    db $3C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $3E
    db OAMF_PAL0
    db $3E
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; Frame 1
    db $40
    db OAMF_PAL0
    db $40
    db OAMF_PAL0 | OAMF_XFLIP

/* Animation for enemy D */
EnemyDAnimation::
.sleepAnimation::
    ; Frame 1
    db $4E
    db OAMF_PAL0
    db $50
    db OAMF_PAL0

    ; Frame 2
    db $52
    db OAMF_PAL0
    db $54
    db OAMF_PAL0
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $52
    db OAMF_PAL0
    db $56
    db OAMF_PAL0

    ; Frame 2
    db $58
    db OAMF_PAL0
    db $5A
    db OAMF_PAL0
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $52
    db OAMF_PAL0 | OAMF_YFLIP
    db $56
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $58
    db OAMF_PAL0 | OAMF_YFLIP
    db $5A
    db OAMF_PAL0 | OAMF_YFLIP
.rightAnimation::
    ; Frame 1
    db $60
    db OAMF_PAL0
    db $62
    db OAMF_PAL0

    ; Frame 2
    db $5C
    db OAMF_PAL0
    db $5E
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $62
    db OAMF_PAL0 | OAMF_XFLIP
    db $60
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $5E
    db OAMF_PAL0 | OAMF_XFLIP
    db $5C
    db OAMF_PAL0 | OAMF_XFLIP