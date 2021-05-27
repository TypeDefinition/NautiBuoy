    IF !DEF(MOVEMENT_INC)
DEF MOVEMENT_INC EQU 1

/*  Interpolate the position of an entity decreasingly.
    \1 - Entity PosY Address
    \2 - Entity PosYFrac Address
    \3 - Entity Velocity */
MACRO interpolate_pos_dec
    push af
    ld a, [\2]
    add a, (\3 * 64)
    ld [\2], a
    ld a, [\1]
    sbc a, $00
    ld [\1], a
    pop af
ENDM

/*  Interpolate the position of an entity increasingly.
    \1 - Entity PosY Address
    \2 - Entity PosYFrac Address
    \3 - Entity Velocity */
MACRO interpolate_pos_inc
    push af
    ld a, [\2]
    add a, (\3 * 64)
    ld [\2], a
    ld a, [\1]
    adc a, $00
    ld [\1], a
    pop af
ENDM

    ENDC ; MOVEMENT_INC