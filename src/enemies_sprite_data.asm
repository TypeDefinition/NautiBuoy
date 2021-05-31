INCLUDE "./src/include/hardware.inc"

SECTION "Enemy Sprite Data", ROMX, BANK[2]
EnemySprites::
.upSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0
.downSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0
.rightSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0
.leftSprite::
    db 8 ; y
    db 0 ; x
    db OAMF_PAL0
