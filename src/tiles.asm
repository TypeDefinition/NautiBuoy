INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

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
    calculated by NumDirtyTiles << 2. This cannot be done using 3 bytes. */
NumDirtyTiles:
    ds 1
DirtyTiles:
    ds (MAX_DIRTY_TILES << 2)
.end

SECTION "Tile Functions", ROM0
ResetDirtyTiles::
    mem_set_small NumDirtyTiles, 0, 1
    mem_set_small DirtyTiles, 0, DirtyTiles.end - DirtyTiles
    ret

; Get the index of the tile, given a Y and X position.
; @ bc: Return Value
; @ d: PosY
; @ e: PosX
GetTileIndex::
    push af
    push de
    push hl

    ; Row = PosY/8
    ; Col = PosX/8
    ; Index = Row * 32 + Col
    
    ; Calculate Row * 32
    ld a, d
    and a, %11111000 ; Equal to Row * 8
    ld h, 0
    ld l, a
    add hl, hl ; Equal to Row * 16
    add hl, hl ; Equal to Row * 32

    ; Add Col
    ld d, 0
    srl e
    srl e
    srl e
    add hl, de
    ld b, h
    ld c, l

    pop hl
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

    ; Offset = [NumDirtyTiles] << 2
    ld a, [NumDirtyTiles]
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

    ; NumDirtyTiles += 1
    ld a, [NumDirtyTiles]
    inc a
    ld [NumDirtyTiles], a
    
.end
    pop hl
    pop de
    pop af
    ret

; Run through the list of dirty tiles, and update them into VRAM.
; As of now, this is operating during HBlank because we don't even have enough cycles in VBlank.
UpdateDirtyTiles::
    ; d = NumDirtyTiles
    ld a, [NumDirtyTiles]
    ld d, a

    ; hl = Memory Address of Tile 0
    ld hl, DirtyTiles

.loop
    ld a, d
    cp a, $00
    jr z, .end

    ; bc = Dirty Tile Index
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ; a = New Tile Value
    ld a, [hli]
    inc hl

    ; Load new tile value into VRAM.
    push hl

    ; bc = Tile Address in VRAM
    ld hl, _SCRN0
    add hl, bc
    ld b, h
    ld c, l
    
    ld hl, rSTAT
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM
    ld [bc], a

    pop hl

    ; Next loop
    dec d
    jr .loop
.end
    xor a
    ld [NumDirtyTiles], a
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