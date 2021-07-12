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
    INCBIN "./tile_data/projectiles.2bpp"
    INCBIN "./tile_data/ParticleEffects.2bpp"
    INCBIN "./tile_data/BossEnemy.2bpp"
.end::

ParticleEffectSprites::
.smallExplosion::
    db $98 ; sprite ID
    db OAMF_PAL0 
    db $9A ; sprite ID
    db OAMF_PAL0 
.mediumExplosion::
    db $9C ; sprite ID
    db OAMF_PAL0 
    db $9E ; sprite ID
    db OAMF_PAL0 
.bigExplosion
    db $A0 ; sprite ID
    db OAMF_PAL0 
    db $A2 ; sprite ID
    db OAMF_PAL0

BulletSprites::
.upDefaultSprite::
    db $96 ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.downDefaultSprite::
    db $96 ; sprite ID
    db OAMF_PAL0 
.rightDefaultSprite::
    db $94 ; sprite ID
    db OAMF_PAL0
.leftDefaultSprite::
    db $94 ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP

.upPowerUpBulletSprite
    db $92 ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.downPowerUpBulletDefaultSprite
    db $92 ; sprite ID
    db OAMF_PAL0 
.rightPowerUpBulletDefaultSprite
    db $88 ; sprite ID
    db OAMF_PAL0
.leftPowerUpBulletDefaultSprite
    db $88 ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP

.upSpikeProjectileSprite
    db $8C ; sprite ID
    db OAMF_PAL0 
.downSpikeProjectileSprite
    db $8C ; sprite ID
    db OAMF_PAL0 
.rightSpikeProjectileSprite
    db $8A ; sprite ID
    db OAMF_PAL0
.leftSpikeProjectileSprite
    db $8A ; sprite ID
    db OAMF_PAL0 

.upInkProjectileSprite
    db $90 ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.downInkProjectileSprite
    db $90 ; sprite ID
    db OAMF_PAL0 
.rightInkProjectileSprite
    db $8E ; sprite ID
    db OAMF_PAL0
.leftInkProjectileSprite
    db $8E ; sprite ID
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
.hideInShellUpAnimation::
    ; Frame 1
    db $36
    db OAMF_PAL0 | OAMF_YFLIP
    db $36
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP

    ; Frame 2
    db $38
    db OAMF_PAL0 | OAMF_YFLIP
    db $38
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
.hideInShellDownAnimation::
    ; Frame 1
    db $36
    db OAMF_PAL0
    db $36
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $38
    db OAMF_PAL0
    db $38
    db OAMF_PAL0 | OAMF_XFLIP
.hideInShellRightAnimation::
    ; Frame 1
    db $3A
    db OAMF_PAL0
    db $3C
    db OAMF_PAL0 

    ; Frame 2
    db $3E
    db OAMF_PAL0
    db $40
    db OAMF_PAL0 
.hideInShellLeftAnimation::
    ; Frame 1
    db $3C
    db OAMF_PAL0 | OAMF_XFLIP
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $40
    db OAMF_PAL0 | OAMF_XFLIP
    db $3E
    db OAMF_PAL0 | OAMF_XFLIP

/* Animation, sprite IDs for the enemy C*/
EnemyCAnimation::
.upAnimation:: 
    ; Frame 1
    db $58
    db OAMF_PAL0 | OAMF_YFLIP
    db $5A
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $5C
    db OAMF_PAL0 | OAMF_YFLIP
    db $5E
    db OAMF_PAL0 | OAMF_YFLIP
.downAnimation:: 
    ; Frame 1
    db $58
    db OAMF_PAL0 
    db $5A
    db OAMF_PAL0 

    ; Frame 2
    db $5C
    db OAMF_PAL0
    db $5E
    db OAMF_PAL0
.rightAnimation::
    ; Frame 1
    db $6C
    db OAMF_PAL0
    db $6E
    db OAMF_PAL0

    ; Frame 2
    db $70
    db OAMF_PAL0
    db $72
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $6E
    db OAMF_PAL0 | OAMF_XFLIP
    db $6C
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $72
    db OAMF_PAL0 | OAMF_XFLIP
    db $70
    db OAMF_PAL0 | OAMF_XFLIP
.attackUpAnimation::
    ; Frame 1
    db $60
    db OAMF_PAL0 | OAMF_YFLIP
    db $62
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_YFLIP
    db $66
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 3
    db $60
    db OAMF_PAL0 | OAMF_YFLIP
    db $62
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 4, SHOOT
    db $68
    db OAMF_PAL0 | OAMF_YFLIP
    db $6A
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_YFLIP
    db $66
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $60
    db OAMF_PAL0 | OAMF_YFLIP
    db $62
    db OAMF_PAL0 | OAMF_YFLIP
.attackDownAnimation::
    ; Frame 1
    db $60
    db OAMF_PAL0 
    db $62
    db OAMF_PAL0 

    ; Frame 2
    db $64
    db OAMF_PAL0 
    db $66
    db OAMF_PAL0 

    ; Frame 3
    db $60
    db OAMF_PAL0 
    db $62
    db OAMF_PAL0 

    ; Frame 4, SHOOT
    db $68
    db OAMF_PAL0 
    db $6A
    db OAMF_PAL0 

    ; Frame 2
    db $64
    db OAMF_PAL0 
    db $66
    db OAMF_PAL0 

    ; Frame 2
    db $60
    db OAMF_PAL0 
    db $62
    db OAMF_PAL0 
.attackRightAnimation::
    ; Frame 1
    db $74
    db OAMF_PAL0
    db $76
    db OAMF_PAL0

    db $78
    db OAMF_PAL0
    db $7A
    db OAMF_PAL0

    db $74
    db OAMF_PAL0
    db $76
    db OAMF_PAL0

    ; Frame 4, SHOOT
    db $7C
    db OAMF_PAL0
    db $7E
    db OAMF_PAL0

    db $78
    db OAMF_PAL0
    db $7A
    db OAMF_PAL0

    db $74
    db OAMF_PAL0
    db $76
    db OAMF_PAL0
.attackLeftAnimation::
    ; Frame 1 
    db $76
    db OAMF_PAL0 | OAMF_XFLIP
    db $74
    db OAMF_PAL0 | OAMF_XFLIP

    db $7A
    db OAMF_PAL0 | OAMF_XFLIP
    db $78
    db OAMF_PAL0 | OAMF_XFLIP

    db $76
    db OAMF_PAL0 | OAMF_XFLIP
    db $74
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 4, SHOOT
    db $7E
    db OAMF_PAL0 | OAMF_XFLIP  
    db $7C
    db OAMF_PAL0 | OAMF_XFLIP

    db $7A
    db OAMF_PAL0 | OAMF_XFLIP
    db $78
    db OAMF_PAL0 | OAMF_XFLIP

    db $76
    db OAMF_PAL0 | OAMF_XFLIP
    db $74
    db OAMF_PAL0 | OAMF_XFLIP

/* Animation for enemy D */
EnemyDAnimation::
.sleepAnimation::
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
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $46
    db OAMF_PAL0
    db $4A
    db OAMF_PAL0

    ; Frame 2
    db $4C
    db OAMF_PAL0
    db $4E
    db OAMF_PAL0 
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $46
    db OAMF_PAL0 | OAMF_YFLIP
    db $4A
    db OAMF_PAL0 | OAMF_YFLIP

    ; Frame 2
    db $4C
    db OAMF_PAL0 | OAMF_YFLIP
    db $4E
    db OAMF_PAL0 | OAMF_YFLIP
.rightAnimation::
    ; Frame 1
    db $50
    db OAMF_PAL0
    db $52
    db OAMF_PAL0

    ; Frame 2
    db $54
    db OAMF_PAL0
    db $56
    db OAMF_PAL0
.leftAnimation::
    ; Frame 1
    db $52
    db OAMF_PAL0 | OAMF_XFLIP
    db $50
    db OAMF_PAL0 | OAMF_XFLIP

    ; Frame 2
    db $56
    db OAMF_PAL0 | OAMF_XFLIP
    db $54
    db OAMF_PAL0 | OAMF_XFLIP

BossEnemyAnimation::
.upAnimation
.downAnimation
.rightAnimation
.leftAnimation