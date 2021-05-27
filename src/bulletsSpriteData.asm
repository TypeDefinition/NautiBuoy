INCLUDE "./src/include/hardware.inc"

SECTION "Bullet Sprite Data", ROMX, BANK[2]

/*  Bullet sprite data
    Any sprite offset put here too
*/
BulletSprites::
.upSprite::
    db 8 ; y
    db 4 ; x
    db 18 ; sprite ID
    db OAMF_PAL0 

.downSprite::
    db 8 ; y
    db 4 ; x
    db 18 ; sprite ID
    db OAMF_PAL0 | OAMF_YFLIP

.rightSprite::
    db 8 ; y
    db 0 ; x
    db 20 ; sprite ID
    db OAMF_PAL0
    
.leftSprite::
    db 8 ; y
    db 0 ; x
    db 20 ; sprite ID
    db OAMF_PAL0 | OAMF_XFLIP
