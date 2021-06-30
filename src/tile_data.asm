INCLUDE "./src/include/hardware.inc"

SECTION "Background & Window Tiles", ROMX
BGWindowTiles::
    INCBIN "./tile_data/background_and_ui.2bpp" ; INCBIN copies the binary file contents directly into the ROM.
.end::

SECTION "Sprites", ROMX
PlayerSprite::
    INCBIN "./tile_data/tempPlayer.2bpp"
.end::

EnemyTurtleSprite::
    INCBIN "./tile_data/turtleEnemy.2bpp"
.end::

EnemyTurretSprite::
    INCBIN "./tile_data/enemyShootOneDir.2bpp"
.end::

EnemyGhostSprite::
    INCBIN "./tile_data/ghostEnemy.2bpp"
.end::

PowerUpSprites::
    INCBIN "./tile_data/Powerups.2bpp"
.end::