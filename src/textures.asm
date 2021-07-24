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

.upWindProjectileSprite::
    db $CA ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
    db $CE ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP
.downWindProjectileSprite
    db $CA ; sprite ID
    db OAMF_PAL0 
    db $CE ; sprite ID
    db OAMF_PAL0 
.leftWindProjectileSprite
    db $C8 ; sprite ID
    db OAMF_PAL0
    db $CC ; sprite ID
    db OAMF_PAL0
.rightWindProjectileSprite
    db $CC ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP
    db $C8 ; sprite ID
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
.upAnimation:: 
    ; Frame 1
    db $10
    db OAMF_PAL0 | OAMF_PRI
    db $12
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_PRI
    db $16
    db OAMF_PAL0 | OAMF_PRI
.downAnimation 
    ; Frame 1
    db $10
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $12
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $16
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

.leftAnimation
    ; Frame 1
    db $1C
    db OAMF_PAL0 | OAMF_PRI
    db $1E
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $20
    db OAMF_PAL0 | OAMF_PRI
    db $22
    db OAMF_PAL0 | OAMF_PRI
.rightAnimation
    ; Frame 1
    db $1E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $22
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $20
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

.attackUpAnimation::
    ; Frame 1
    db $18
    db OAMF_PAL0 | OAMF_PRI
    db $1A
    db OAMF_PAL0 | OAMF_PRI
    
    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_PRI
    db $16
    db OAMF_PAL0 | OAMF_PRI
.attackDownAnimation
    ; Frame 1
    db $18
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $1A
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $14
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $16
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
.attackLeftAnimation
    ; Frame 1
    db $1C
    db OAMF_PAL0 | OAMF_PRI
    db $24
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $20
    db OAMF_PAL0 | OAMF_PRI
    db $22
    db OAMF_PAL0 | OAMF_PRI
.attackRightAnimation
    ; Frame 1
    db $24
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $1C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $22
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $20
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

/* Enemy B sprite animation */
EnemyBAnimation::
.upAnimation:: ; up and down has the same frames
    ; Frame 1
    db $26
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $26
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $28
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $28
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP | OAMF_PRI
.downAnimation:: ; up and down has the same frames
    ; Frame 1
    db $26
    db OAMF_PAL0 | OAMF_PRI
    db $26
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $28
    db OAMF_PAL0 | OAMF_PRI
    db $28
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
.rightAnimation::
    ; Frame 1
    db $2E
    db OAMF_PAL0 | OAMF_PRI
    db $30
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $32
    db OAMF_PAL0 | OAMF_PRI
    db $34
    db OAMF_PAL0 | OAMF_PRI
.leftAnimation::
    ; Frame 1
    db $30
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $2E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $34
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $32
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
.attackUpAnimation:: ; up and down same animation
    ; Frame 1, up
    db $2C
    db OAMF_PAL0 | OAMF_PRI
    db $2C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2, right
    db $2A
    db OAMF_PAL0 | OAMF_PRI
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

.attackRightAnimation::
    ; Frame 2, right
    db $2A
    db OAMF_PAL0 | OAMF_PRI
    db $2A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    
    ; Frame 1, up
    db $2C
    db OAMF_PAL0 | OAMF_PRI
    db $2C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
.hideInShellUpAnimation::
    ; Frame 1
    db $36
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $36
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $38
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $38
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP | OAMF_PRI
.hideInShellDownAnimation::
    ; Frame 1
    db $36
    db OAMF_PAL0 | OAMF_PRI
    db $36
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $38
    db OAMF_PAL0 | OAMF_PRI
    db $38
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
.hideInShellRightAnimation::
    ; Frame 1
    db $3A
    db OAMF_PAL0 | OAMF_PRI
    db $3C
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $3E
    db OAMF_PAL0 | OAMF_PRI
    db $40
    db OAMF_PAL0 | OAMF_PRI
.hideInShellLeftAnimation::
    ; Frame 1
    db $3C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $3A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $40
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $3E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

/* Animation, sprite IDs for the enemy C*/
EnemyCAnimation::
.upAnimation:: 
    ; Frame 1
    db $58
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $5A
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $5C
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $5E
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
.downAnimation:: 
    ; Frame 1
    db $58
    db OAMF_PAL0 | OAMF_PRI
    db $5A
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $5C
    db OAMF_PAL0 | OAMF_PRI
    db $5E
    db OAMF_PAL0 | OAMF_PRI
.rightAnimation::
    ; Frame 1
    db $6C
    db OAMF_PAL0 | OAMF_PRI
    db $6E
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $70
    db OAMF_PAL0 | OAMF_PRI
    db $72
    db OAMF_PAL0 | OAMF_PRI
.leftAnimation::
    ; Frame 1
    db $6E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $6C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 2
    db $72
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $70
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
.attackUpAnimation::
    ; Frame 1
    db $60
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $66
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 3
    db $60
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 4, SHOOT
    db $68
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $6A
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $66
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI

    ; Frame 2
    db $60
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_PRI
.attackDownAnimation::
    ; Frame 1
    db $60
    db OAMF_PAL0 | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_PRI
    db $66
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 3
    db $60
    db OAMF_PAL0 | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 4, SHOOT
    db $68
    db OAMF_PAL0 | OAMF_PRI
    db $6A
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $64
    db OAMF_PAL0 | OAMF_PRI
    db $66
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 2
    db $60
    db OAMF_PAL0 | OAMF_PRI
    db $62
    db OAMF_PAL0 | OAMF_PRI
.attackRightAnimation::
    ; Frame 1
    db $74
    db OAMF_PAL0 | OAMF_PRI
    db $76
    db OAMF_PAL0 | OAMF_PRI

    db $78
    db OAMF_PAL0 | OAMF_PRI
    db $7A
    db OAMF_PAL0 | OAMF_PRI

    db $74
    db OAMF_PAL0 | OAMF_PRI
    db $76
    db OAMF_PAL0 | OAMF_PRI

    ; Frame 4, SHOOT
    db $7C
    db OAMF_PAL0 | OAMF_PRI
    db $7E
    db OAMF_PAL0 | OAMF_PRI

    db $78
    db OAMF_PAL0 | OAMF_PRI
    db $7A
    db OAMF_PAL0 | OAMF_PRI

    db $74
    db OAMF_PAL0 | OAMF_PRI
    db $76
    db OAMF_PAL0 | OAMF_PRI
.attackLeftAnimation::
    ; Frame 1 
    db $76
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $74
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    db $7A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $78
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    db $76
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $74
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    ; Frame 4, SHOOT
    db $7E
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $7C
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    db $7A
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $78
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

    db $76
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI
    db $74
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_PRI

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
.upAnimation::
    ; first frame
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP

    ; second frame
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP

.downAnimation::
    ; first frame
    db $A8 ; top left
    db OAMF_PAL0 
    db $AA ; bottom left
    db OAMF_PAL0
    db $AC ; top middle left
    db OAMF_PAL0
    db $AE ; bottom middle left
    db OAMF_PAL0
    db $B0 ; top middle right
    db OAMF_PAL0
    db $B2 ; bottom middle right
    db OAMF_PAL0
    db $B4 ; top right
    db OAMF_PAL0
    db $B6 ; bottom right
    db OAMF_PAL0

    ; first frame
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

.leftAnimation::
    ; FIRST FRAME
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

    ; SECOND FRAME
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.rightAnimation::
    ; FIRST FRAME
    db $B8 ; top left
    db OAMF_PAL0
    db $BA ; bottom left
    db OAMF_PAL0
    db $BC ; middle top left
    db OAMF_PAL0
    db $BE ; middle bottom left
    db OAMF_PAL0
    db $C0 ; middle top right
    db OAMF_PAL0
    db $C2 ; middle bottom right
    db OAMF_PAL0
    db $C4 ; top right
    db OAMF_PAL0
    db $C6 ; bottom right
    db OAMF_PAL0

    ; second frame
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP

.upAnimationDefaultFire::
    ; first frame
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP

    ; second frame
    db $B6 ; bottom right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $B4 ; top right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP

.downAnimationDefaultFire::
    ; first frame
    db $A8 ; top left
    db OAMF_PAL0 
    db $AA ; bottom left
    db OAMF_PAL0
    db $AC ; top middle left
    db OAMF_PAL0
    db $AE ; bottom middle left
    db OAMF_PAL0
    db $B0 ; top middle right
    db OAMF_PAL0
    db $B2 ; bottom middle right
    db OAMF_PAL0
    db $B4 ; top right
    db OAMF_PAL0
    db $B6 ; bottom right
    db OAMF_PAL0

    ; first frame
    db $B4 ; top right
    db OAMF_PAL1 | OAMF_XFLIP
    db $B6 ; bottom right
    db OAMF_PAL1 | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL1 | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL1 | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL1 | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL1 | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL1 | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL1 | OAMF_XFLIP

.leftAnimationDefaultFire::
    ; FIRST FRAME
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

    ; SECOND FRAME
    db $C6 ; bottom right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $BA ; bottom left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP

.rightAnimationDefaultFire::
    ; FIRST FRAME
    db $B8 ; top left
    db OAMF_PAL0
    db $BA ; bottom left
    db OAMF_PAL0
    db $BC ; middle top left
    db OAMF_PAL0
    db $BE ; middle bottom left
    db OAMF_PAL0
    db $C0 ; middle top right
    db OAMF_PAL0
    db $C2 ; middle bottom right
    db OAMF_PAL0
    db $C4 ; top right
    db OAMF_PAL0
    db $C6 ; bottom right
    db OAMF_PAL0

    ; second frame
    db $BA ; bottom left
    db OAMF_PAL1 | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL1 | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL1 | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL1 | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL1 | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL1 | OAMF_YFLIP
    db $C6 ; bottom right
    db OAMF_PAL1 | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL1 | OAMF_YFLIP

.chargeAnimationUp::
    ; first frame
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP

    ; second frame
    db $D2 ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D0 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D4 ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $DA ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $D8 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DE ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DC ; top right
    db OAMF_PAL0 | OAMF_YFLIP

.chargeAnimationDown::
    ; first frame
    db $B4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B0 ; top middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $B2 ; bottom middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $AC ; top middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $AE ; bottom middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $A8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $AA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

    ; second frame
    db $D0 ; top left
    db OAMF_PAL0 
    db $D2 ; bottom left
    db OAMF_PAL0
    db $D4 ; top middle left
    db OAMF_PAL0
    db $D6 ; bottom middle left
    db OAMF_PAL0
    db $D8 ; top middle right
    db OAMF_PAL0
    db $DA ; bottom middle right
    db OAMF_PAL0
    db $DC ; top right
    db OAMF_PAL0
    db $DE ; bottom right
    db OAMF_PAL0
    
.chargeAnimationLeft::
    ; SECOND FRAME
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

    ; SECOND FRAME
    db $EC ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EE ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E8 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EA ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E4 ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E0 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E2 ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

.chargeAnimationRight::
    ; first frame
    db $BA ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $B8 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $BE ; middle bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $BC ; middle top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $C2 ; middle bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C0 ; middle top right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C6 ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $C4 ; top right
    db OAMF_PAL0 | OAMF_YFLIP
    
    ; SECOND FRAME
    db $E0 ; top left
    db OAMF_PAL0
    db $E2 ; bottom left
    db OAMF_PAL0
    db $E4 ; middle top left
    db OAMF_PAL0
    db $E6 ; middle bottom left
    db OAMF_PAL0
    db $E8 ; middle top right
    db OAMF_PAL0
    db $EA ; middle bottom right
    db OAMF_PAL0
    db $EC ; top right
    db OAMF_PAL0
    db $EE ; bottom right
    db OAMF_PAL0

.ramUp::
    ; first frame
    db $D2 ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D0 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D4 ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $DA ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $D8 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DE ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DC ; top right
    db OAMF_PAL0 | OAMF_YFLIP

    ; second frame
    db $DE ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $DC ; top right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $DA ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $D8 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $D4 ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $D2 ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP
    db $D0 ; top left
    db OAMF_PAL0 | OAMF_YFLIP | OAMF_XFLIP

.ramDown::
    ; first frame
    db $D0 ; top left
    db OAMF_PAL0 
    db $D2 ; bottom left
    db OAMF_PAL0
    db $D4 ; top middle left
    db OAMF_PAL0
    db $D6 ; bottom middle left
    db OAMF_PAL0
    db $D8 ; top middle right
    db OAMF_PAL0
    db $DA ; bottom middle right
    db OAMF_PAL0
    db $DC ; top right
    db OAMF_PAL0
    db $DE ; bottom right
    db OAMF_PAL0

    ; second frame
    db $DC ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $DE ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $D8 ; top middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $DA ; bottom middle right
    db OAMF_PAL0 | OAMF_XFLIP
    db $D4 ; top middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL0 | OAMF_XFLIP
    db $D0 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $D2 ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

.ramLeft::
    ; first FRAME
    db $EC ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EE ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E8 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EA ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E4 ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E0 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E2 ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

    ; second FRAME
    db $EE ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $EC ; top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $EA ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $E8 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $E4 ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $E2 ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP
    db $E0 ; top left
    db OAMF_PAL0 | OAMF_XFLIP | OAMF_YFLIP

.ramRight::
    ; first FRAME
    db $E0 ; top left
    db OAMF_PAL0
    db $E2 ; bottom left
    db OAMF_PAL0
    db $E4 ; middle top left
    db OAMF_PAL0
    db $E6 ; middle bottom left
    db OAMF_PAL0
    db $E8 ; middle top right
    db OAMF_PAL0
    db $EA ; middle bottom right
    db OAMF_PAL0
    db $EC ; top right
    db OAMF_PAL0
    db $EE ; bottom right
    db OAMF_PAL0
    
    ; second frame
    db $E2 ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $E0 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $E4 ; middle top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $EA ; middle bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $E8 ; middle top right
    db OAMF_PAL0 | OAMF_YFLIP
    db $EE ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $EC ; top right
    db OAMF_PAL0 | OAMF_YFLIP

.projectileBarrageUp::
    ; first frame
    db $D2 ; bottom left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D0 ; top left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $D4 ; top middle left
    db OAMF_PAL0 | OAMF_YFLIP
    db $DA ; bottom middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $D8 ; top middle right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DE ; bottom right
    db OAMF_PAL0 | OAMF_YFLIP
    db $DC ; top right
    db OAMF_PAL0 | OAMF_YFLIP

    ; second frame
    db $DE ; bottom right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $DC ; top right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $DA ; bottom middle right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $D8 ; top middle right
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $D4 ; top middle left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $D2 ; bottom left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP
    db $D0 ; top left
    db OAMF_PAL1 | OAMF_YFLIP | OAMF_XFLIP

.projectileBarrageDown
    ; first frame
    db $D0 ; top left
    db OAMF_PAL0 
    db $D2 ; bottom left
    db OAMF_PAL0
    db $D4 ; top middle left
    db OAMF_PAL0
    db $D6 ; bottom middle left
    db OAMF_PAL0
    db $D8 ; top middle right
    db OAMF_PAL0
    db $DA ; bottom middle right
    db OAMF_PAL0
    db $DC ; top right
    db OAMF_PAL0
    db $DE ; bottom right
    db OAMF_PAL0

    ; second frame
    db $DC ; top right
    db OAMF_PAL1 | OAMF_XFLIP
    db $DE ; bottom right
    db OAMF_PAL1 | OAMF_XFLIP
    db $D8 ; top middle right
    db OAMF_PAL1 | OAMF_XFLIP
    db $DA ; bottom middle right
    db OAMF_PAL1 | OAMF_XFLIP
    db $D4 ; top middle left
    db OAMF_PAL1 | OAMF_XFLIP
    db $D6 ; bottom middle left
    db OAMF_PAL1 | OAMF_XFLIP
    db $D0 ; top left
    db OAMF_PAL1 | OAMF_XFLIP
    db $D2 ; bottom left
    db OAMF_PAL1 | OAMF_XFLIP

.projectileBarrageLeft
    ; first FRAME
    db $EC ; top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EE ; bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E8 ; middle top right
    db OAMF_PAL0 | OAMF_XFLIP
    db $EA ; middle bottom right
    db OAMF_PAL0 | OAMF_XFLIP
    db $E4 ; middle top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E0 ; top left
    db OAMF_PAL0 | OAMF_XFLIP
    db $E2 ; bottom left
    db OAMF_PAL0 | OAMF_XFLIP

    ; second FRAME
    db $EE ; bottom right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $EC ; top right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $EA ; middle bottom right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $E8 ; middle top right
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $E4 ; middle top left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $E2 ; bottom left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP
    db $E0 ; top left
    db OAMF_PAL1 | OAMF_XFLIP | OAMF_YFLIP

.projectileBarrageRight
    ; first FRAME
    db $E0 ; top left
    db OAMF_PAL0
    db $E2 ; bottom left
    db OAMF_PAL0
    db $E4 ; middle top left
    db OAMF_PAL0
    db $E6 ; middle bottom left
    db OAMF_PAL0
    db $E8 ; middle top right
    db OAMF_PAL0
    db $EA ; middle bottom right
    db OAMF_PAL0
    db $EC ; top right
    db OAMF_PAL0
    db $EE ; bottom right
    db OAMF_PAL0
    
    ; second frame
    db $E2 ; bottom left
    db OAMF_PAL1 | OAMF_YFLIP
    db $E0 ; top left
    db OAMF_PAL1 | OAMF_YFLIP
    db $E6 ; middle bottom left
    db OAMF_PAL1 | OAMF_YFLIP
    db $E4 ; middle top left
    db OAMF_PAL1 | OAMF_YFLIP
    db $EA ; middle bottom right
    db OAMF_PAL1 | OAMF_YFLIP
    db $E8 ; middle top right
    db OAMF_PAL1 | OAMF_YFLIP
    db $EE ; bottom right
    db OAMF_PAL1 | OAMF_YFLIP
    db $EC ; top right
    db OAMF_PAL1 | OAMF_YFLIP



