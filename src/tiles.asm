DEF NUM_COLS EQU $20
DEF NUM_ROWS EQU $20

; Collidable Tiles: A tile is assumed to be collidable if it's value is less than 16.
DEF CHARACTER_COLLIDABLE_TILES EQU $10

SECTION "Game Level Tiles", WRAM0
GameLevelTiles::
    ds 1024
.end::

SECTION "Tile Functions", ROM0
; Get the value of the tile, given a Y and X position.
; @ b: PosY
; @ c: PoxX
; @ a: Return Value
GetTileValue::
    push bc
    push de
    push hl

; Row = PosY/8
; Col = PosX/8
    srl b
    srl b
    srl b
    srl c
    srl c
    srl c

; de = Col + Row * NUM_COLS.
    ld d, 0
    ld e, c
.loopStart ; adding row * num_cols to de = col
    ld a, b 
    cp a, $00
    jr z, .loopEnd

    ld a, e
    add a, NUM_COLS
    ld e, a

    ld a, d
    adc a, $00
    ld d, a

    dec b
    jr .loopStart
.loopEnd

; hl = de + GameLevelTiles
    ld hl, GameLevelTiles
    add hl, de

    ld a, [hl]

    pop hl
    pop de
    pop bc
    ret