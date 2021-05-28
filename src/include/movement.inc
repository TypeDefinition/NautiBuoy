    IF !DEF(MOVEMENT_INC)
DEF MOVEMENT_INC EQU 1

/*  Interpolate the position of an entity decreasingly.
    \1 - Entity PosY Address
    \2 - Entity PosYFrac Address
    \3 - Entity Velocity */
MACRO interpolate_pos_dec
    push af
    push bc
    push hl
    
    ld bc, -\3

    ld a, [\1]
    ld h, a
    ld a, [\2]
    ld l, a

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
    \1 - Entity PosY Address
    \2 - Entity PosYFrac Address
    \3 - Entity Velocity */
MACRO interpolate_pos_inc
    push af
    push bc
    push hl

    ld bc, \3

    ld a, [\1]
    ld h, a
    ld a, [\2]
    ld l, a

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