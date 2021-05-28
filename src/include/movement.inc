    IF !DEF(MOVEMENT_INC)
DEF MOVEMENT_INC EQU 1

/*  Interpolate the position of an entity decreasingly.
    \1 - Entity Pos Address
    \2 - Entity Pos Frac Address
    \3 - Entity Velocity Address */
MACRO interpolate_pos_dec
    push af
    push bc
    push hl
    
    ; Get -Velocity
    ld a, [\3 + 1]
    cpl
    add a, $01
    ld c, a

    ld a, [\3]
    cpl
    adc a, $00
    ld b, a
    
    ; Get Pos
    ld a, [\1]
    ld h, a
    ld a, [\2]
    ld l, a

    ; Pos - Velocity
    add hl, bc
    ld a, h
    ld [\1], a
    ld a, l
    ld [\2], a

    pop hl
    pop bc
    pop af
ENDM

/*  Interpolate the position of an entity increasingly.
    \1 - Entity Pos Address
    \2 - Entity Pos Frac Address
    \3 - Entity Velocity Address */
MACRO interpolate_pos_inc
    push af
    push bc
    push hl

    ld bc, \3

    ; Get Velocity
    ld a, [\3]
    ld b, a
    ld a, [\3 + 1]
    ld c, a

    ; Get Pos
    ld a, [\1]
    ld h, a
    ld a, [\2]
    ld l, a

    ; Pos + Velocity
    add hl, bc
    ld a, h
    ld [\1], a
    ld a, l
    ld [\2], a

    pop hl
    pop bc
    pop af
ENDM

    ENDC ; MOVEMENT_INC