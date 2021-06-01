INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

DEF NUM_COLS EQU $20
DEF NUM_ROWS EQU $20

DEF MAX_DIRTY_TILES EQU $10

; Collidable Tiles: A tile is assumed to be collidable if it's value is less than 16.
DEF CHARACTER_COLLIDABLE_TILES EQU $10

SECTION "Game Level Tiles", WRAM0
GameLevelTiles::
    ds 1024
.end::

SECTION "Dirty Tiles", WRAM0[$C000]
/* Contains an array of tiles to update in the VRAM.
    Each tile to update is represented using 4 bytes.
    Tile Index: 2 bytes
    Tile Value: 1 byte
    Padding: 1 byte

    4 bytes is used so that the memory address of each dirty tile
    can be calculated by doing DirtyTiles + Offset, where Offset can be
    calculated by DirtyTilesCounter << 2. This cannot be done using 3 bytes. */
DirtyTilesCounter:
    ds 1
DirtyTiles:
    ds (MAX_DIRTY_TILES << 2)
.end

SECTION "Tile Functions", ROM0
ResetDirtyTiles::
    mem_set_small DirtyTilesCounter, 0, 1
    mem_set_small DirtyTiles, 0, DirtyTiles.end - DirtyTiles
    ret

; Get the index of the tile, given a Y and X position.
; @ bc: Return Value
; @ d: PosY
; @ e: PosX
GetTileIndex::
    push af
    push de

; Row = PosY/8
; Col = PosX/8
    srl d
    srl d
    srl d
    srl e
    srl e
    srl e

; bc = Col + Row * NUM_COLS.
    ld b, 0
    ld c, e
.loop ; adding row * NUM_COLS to bc
    ld a, d
    cp a, $00
    jr z, .end

    ld a, c
    add a, NUM_COLS
    ld c, a

    ld a, b
    adc a, $00
    ld b, a

    dec d
    jr .loop
.end
    pop de
    pop af
    ret

; Get the value of the tile, given a Y and X position.
; @ a: Return Value
; @ bc: TileIndex
GetTileValue::
    push hl

    ld hl, GameLevelTiles
    add hl, bc
    ld a, [hl]

    pop hl
    ret

; @ a: New Tile Value
; @ bc: Tile Index
AddDirtyTile::
    push af
    push de
    push hl

    ld hl, DirtyTiles
    ld d, a ; d = New Tile Value

    ; Offset = [DirtyTilesCounter] << 2
    ld a, [DirtyTilesCounter]
    sla a
    sla a
    
    ; hl = DirtyTiles + Offset
    add a, l
    ld l, a
    ld a, h
    adc a, $00
    ld h, a

    ; Set Tile Index
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a

    ; Set New Tile Value
    ld a, d
    ld [hl], a

    ; Increament DirtyTilesCounter
    ld a, [DirtyTilesCounter]
    inc a
    ld [DirtyTilesCounter], a

    pop hl
    pop de
    pop af
    ret

UpdateDirtyTiles::
    push af
    push bc
    push de
    push hl

    ld hl, DirtyTiles
    
    ; d = Num Dirty Tiles
    ld a, [DirtyTilesCounter]
    ld d, a
.loop
    ld a, d
    cp a, $00
    jp z, .end

    ; bc = Dirty Tile Index
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ; a = New Tile Value
    ld a, [hli]
    inc hl

    ; Load new tile value
    push hl
    ld hl, _SCRN0
    add hl, bc
    ld [hl], a
    pop hl

    dec d
    jp .loop
.end
    xor a
    ld [DirtyTilesCounter], a

    pop hl
    pop de
    pop bc
    pop af
    ret

; @ a: New Tile Value
; @ bc: Tile Index
SetTile::
    push af
    push hl
    ld hl, GameLevelTiles
    add hl, bc
    ld [hl], a
    pop hl
    pop af
    call AddDirtyTile
    ret