INCLUDE "./src/include/hardware.inc"

SECTION "Background & Window Tiles", ROMX
BGWindowTileData::
    INCBIN "./tile_data/background_and_ui.2bpp" ; INCBIN copies the binary file contents directly into the ROM.
.end::

SECTION "Sprites", ROMX
Sprites::
    INCBIN "./tile_data/player.2bpp"
    INCBIN "./tile_data/squidEnemy.2bpp"
    INCBIN "./tile_data/turtleEnemy.2bpp"
    INCBIN "./tile_data/ghostEnemy.2bpp"
    INCBIN "./tile_data/puffleFishEnemy.2bpp"
    INCBIN "./tile_data/Powerups.2bpp"
    INCBIN "./tile_data/ParticleEffects.2bpp"
.end::

ParticleEffectSprites::
.smallExplosion::
    db $6E ; sprite ID
    db OAMF_PAL0 
    db $70 ; sprite ID
    db OAMF_PAL0 
.mediumExplosion::
    db $72 ; sprite ID
    db OAMF_PAL0 
    db $74 ; sprite ID
    db OAMF_PAL0 
.bigExplosion
    db $76 ; sprite ID
    db OAMF_PAL0 
    db $78 ; sprite ID
    db OAMF_PAL0

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
    db OAMF_PAL0 | OAMF_PRI | OAMF_YFLIP
    db 2
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db 4
    db OAMF_PAL0 | OAMF_PRI | OAMF_YFLIP
    db 6
    db OAMF_PAL0 | OAMF_PRI | OAMF_YFLIP

.downAnimation::
    ; Frame 1
    db 0
    db OAMF_PAL0 | OAMF_PRI 
    db 2
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db 4
    db OAMF_PAL0 | OAMF_PRI 
    db 6
    db OAMF_PAL0 | OAMF_PRI

.rightAnimation::
    db 8
    db OAMF_PAL0 | OAMF_PRI
    db 10
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db 12
    db OAMF_PAL0 | OAMF_PRI
    db 14
    db OAMF_PAL0 | OAMF_PRI

.leftAnimation::
    db 10
    db OAMF_PAL0 | OAMF_PRI | OAMF_XFLIP
    db 8
    db OAMF_PAL0 | OAMF_PRI | OAMF_XFLIP

    ; Frame 2
    db 14
    db OAMF_PAL0 | OAMF_PRI | OAMF_XFLIP
    db 12
    db OAMF_PAL0 | OAMF_PRI | OAMF_XFLIP

/* Animation, sprite IDs for the enemy*/
EnemyAAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $10
    db OAMF_PAL0 | OAMF_YFLIP
    db $12
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_YFLIP
    db $16
    db OAMF_PAL0 | OAMF_YFLIP
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $10
    db OAMF_PAL0
    db $12
    db OAMF_PAL0 

    ; Frame 2
    db $14
    db OAMF_PAL0
    db $16
    db OAMF_PAL0
.rightAnimation::
    ; Frame 1
    db $1C
    db OAMF_PAL0
    db $1E
    db OAMF_PAL0

    ; Frame 2
    db $20
    db OAMF_PAL0
    db $22
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $1E
    db OAMF_PAL0 | OAMF_XFLIP
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $22
    db OAMF_PAL0 | OAMF_XFLIP
    db $20
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; Frame 1
    db $18
    db OAMF_PAL0 | OAMF_YFLIP
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_YFLIP
    db $16
    db OAMF_PAL0 | OAMF_YFLIP
.attackDownAnimation::
    ; Frame 1
    db $18
    db OAMF_PAL0 
    db $1A
    db OAMF_PAL0
    
    ; Frame 2
    db $14
    db OAMF_PAL0
    db $16
    db OAMF_PAL0

.attackRightAnimation::
    ; Frame 1
    db $1C
    db OAMF_PAL0
    db $24
    db OAMF_PAL0

    ; Frame 2
    db $20
    db OAMF_PAL0
    db $22
    db OAMF_PAL0

.attackLeftAnimation::
    ; Frame 1
    db $24
    db OAMF_PAL0 | OAMF_XFLIP
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $22
    db OAMF_PAL0 | OAMF_XFLIP
    db $20
    db OAMF_PAL0 | OAMF_XFLIP


/* Enemy B sprite animation */
EnemyBAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $26
    db OAMF_PAL0 | OAMF_YFLIP
    db $26
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP

    ; Frame 2
    db $28
    db OAMF_PAL0 | OAMF_YFLIP
    db $28
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $26
    db OAMF_PAL0
    db $26
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $28
    db OAMF_PAL0
    db $28
    db OAMF_PAL0 | OAMF_XFLIP
.rightAnimation::
    ; Frame 1
    db $2E
    db OAMF_PAL0
    db $30
    db OAMF_PAL0

    ; Frame 2
    db $32
    db OAMF_PAL0
    db $34
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $30
    db OAMF_PAL0 | OAMF_XFLIP
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $34
    db OAMF_PAL0 | OAMF_XFLIP
    db $32
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation:: ; up and down same animation
    ; Frame 1, up
    db $2C
    db OAMF_PAL0
    db $2C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2, right
    db $2A
    db OAMF_PAL0
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP

.attackRightAnimation::
    ; Frame 2, right
    db $2A
    db OAMF_PAL0
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP
    
    ; Frame 1, up
    db $2C
    db OAMF_PAL0
    db $2C
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
    db $36
    db OAMF_PAL0
    db $38
    db OAMF_PAL0

    ; Frame 2
    db $3A
    db OAMF_PAL0
    db $3C
    db OAMF_PAL0
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $3A
    db OAMF_PAL0
    db $3E
    db OAMF_PAL0

    ; Frame 2
    db $40
    db OAMF_PAL0
    db $42
    db OAMF_PAL0 
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $3A
    db OAMF_PAL0 | OAMF_YFLIP
    db $3E
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $40
    db OAMF_PAL0 | OAMF_YFLIP
    db $42
    db OAMF_PAL0 | OAMF_YFLIP
.rightAnimation::
    ; Frame 1
    db $44
    db OAMF_PAL0
    db $46
    db OAMF_PAL0

    ; Frame 2
    db $48
    db OAMF_PAL0
    db $4A
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $46
    db OAMF_PAL0 | OAMF_XFLIP
    db $44
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $4A
    db OAMF_PAL0 | OAMF_XFLIP
    db $48
    db OAMF_PAL0 | OAMF_XFLIP