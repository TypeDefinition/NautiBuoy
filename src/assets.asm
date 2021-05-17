SECTION "Assets", ROM0

FontTiles::
    INCBIN "./src/tileset.ts" ; INCBIN copies the file contents directly into the ROM 
FontTilesEnd::

TESTSPRITE::
    INCBIN "./src/2bppFormat/TestSprite.png.2bpp"
.end

HelloWorldStr::
    db "Angie is awesome!"
    ds 15
    db "Next line."
    ds 22
    db $01, $01, $01, $01, $FF
    