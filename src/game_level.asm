DEF NUM_COLS EQU $20
DEF NUM_ROWS EQU $20

SECTION "Game Level Data", WRAM0
GameLevelData::
    ds 1024
.end::

SECTION "Gameplay Functions", ROM0
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
.loopStart
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

; hl = de + GameLevelData
    ld hl, GameLevelData
    add hl, de

    ld a, [hl]

    pop hl
    pop de
    pop bc
    ret