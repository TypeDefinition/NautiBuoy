INCLUDE "./src/include/hardware.inc"

SECTION "Title Tile Data", ROMX, BANK[1]
TitleTiles::
.end::

SECTION "Game Tile Data", ROMX, BANK[2]
BGWindowTiles::
    INCBIN "./tile_data/background_and_ui.2bpp" ; INCBIN copies the binary file contents directly into the ROM.
.end::

TestSprite::
    INCBIN "./tile_data/tempPlayer.2bpp"
.end::

EnemyTurtleSprite::
    INCBIN "./tile_data/turtleEnemy.2bpp"
.end::

EnemyCSprite::
    INCBIN "./tile_data/enemyShootOneDir.2bpp"
.end::

EnemyDSprite::
    INCBIN "./tile_data/ghostEnemy.2bpp"
.end::