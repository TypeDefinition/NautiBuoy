INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

DEF UPDATE_QUEUE_SIZE EQU 64 ; Unlikely to ever need to update more than 64 tiles in 1 frame.

SECTION "BGWindow WRAM", WRAM0
/*  Contains an array of tiles to be updated in VRAM.
    Each tile to update is represented using 4 bytes.
    Tile Index: 2 bytes
    Tile Value: 1 byte
    BG/Window Flag: 1 byte (BG = 0, Window = 1)
*/
wUpdateQueue:
    ds 4*UPDATE_QUEUE_SIZE
wUpdateCounter:
    ds 1

SECTION "BGWindow", ROM0
; Get the index of the tile, given a Y and X position.
; @param d PosY
; @param e PosX
; @return bc Tile Index
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

; Reset background & windows tiles to be updated.
; @destroy af
ResetBGWindowUpdateQueue::
    xor a
    ld [wUpdateCounter], a
    ret

; Queue a background tile to be updated in VRAM.
; @param a New Tile Value
; @param bc Tile Index
QueueBGTile::
    push af
    push de
    push hl

    ld d, a
    ld a, [wUpdateCounter]
    ld e, a
    ld hl, wUpdateQueue

    sla a
    sla a
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
    ld [hli], a
    ; Set BG Flag
    xor a
    ld [hl], a

    ; wBGUpdateCounter += 1
    ld a, e
    inc a
    ld [wUpdateCounter], a

    pop hl
    pop de
    pop af
    ret

; Queue a window tile to be updated in VRAM.
; @param a New Tile Value
; @param bc Tile Index
QueueWindowTile::
    push af
    push de
    push hl

    ld d, a
    ld a, [wUpdateCounter]
    ld e, a
    ld hl, wUpdateQueue

    sla a
    sla a
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
    ld [hli], a
    ; Set Window Flag
    ld a, $01
    ld [hl], a

    ; wBGUpdateCounter += 1
    ld a, e
    inc a
    ld [wUpdateCounter], a

    pop hl
    pop de
    pop af
    ret

; Run through the list of tiles, and update them into VRAM during HBlank or VBlank.
; @destroy af, bc, de, hl
UpdateBGWindow::
    ld a, [wUpdateCounter]
    ld e, a
    ld hl, wUpdateQueue

.loop
    xor a
    cp e
    jr z, .end

    ; bc = Dirty Tile Index
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ; d = New Tile Value
    ld a, [hli]
    ld d, a
    ; a = BG/Window Flag
    ld a, [hli]

    ; Load new tile value into VRAM.
    push hl

    ; bc = Tile Address in VRAM
    ld hl, _SCRN0 ; _SCRN0 stores the BG Tile Map
    dec a
    jr nz, :+
    ld hl, _SCRN1 ; _SCRN0 stores the Window Tile Map
:   add hl, bc
    ld b, h
    ld c, l

    ; a = New Tile Value
    ld a, d
    
    ; Wait for HBlank/VBlank
    ld hl, rSTAT
.waitVRAM
    bit 1, [hl]
    jr nz, .waitVRAM

    ; Write to VRAM.
    ld [bc], a

    pop hl

    ; Next loop
    dec e
    jr .loop

.end
    xor a
    ld [wUpdateCounter], a
    ret