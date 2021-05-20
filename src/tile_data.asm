INCLUDE "./src/hardware.inc"

SECTION "Title Tile Data", ROMX, BANK[1]
TitleTiles::
.end::

SECTION "Game Tile Data", ROMX, BANK[2]
BackgroundTiles::
    INCBIN "./tile_data/background.2bpp" ; INCBIN copies the binary file contents directly into the ROM.
.end::

TestSprite::
    INCBIN "./tile_data/test_sprite.2bpp"
.end::