    IF !DEF(MOVEMENT_INC)
DEF MOVEMENT_INC EQU 1

/*  Interpolate the position of an entity decreasingly.
    \1 - Entity Pos Address
    \2 - Entity Velocity Address */
MACRO interpolate_pos_dec_immd
    ; Get -Velocity
    ld a, [\2 + 1]
    cpl
    add a, $01
    ld c, a

    ld a, [\2]
    cpl
    adc a, $00
    ld b, a
    
    ; Get Pos
    ld a, [\1]
    ld h, a
    ld a, [\1 + 1]
    ld l, a

    ; Pos - Velocity
    add hl, bc
    ld a, h
    ld [\1], a
    ld a, l
    ld [\1 + 1], a
ENDM

/*  Interpolate the position of an entity increasingly.
    \1 - Entity Pos Address
    \2 - Entity Velocity Address */
MACRO interpolate_pos_inc_immd
    ld bc, \2

    ; Get Velocity
    ld a, [\2]
    ld b, a
    ld a, [\2 + 1]
    ld c, a

    ; Get Pos
    ld a, [\1]
    ld h, a
    ld a, [\1 + 1]
    ld l, a

    ; Pos + Velocity
    add hl, bc
    ld a, h
    ld [\1], a
    ld a, l
    ld [\1 + 1], a
ENDM

/*  Interpolate the position of an entity decreasingly.
    Parameters are registers instead
    hl - Pos starting address
    bc - Value of velocity 
    
    Registers change:
        - AF
        - BC
        - DE
        - hl
*/
    
MACRO interpolate_pos_dec_reg
    ; Get -Velocity
    ld a, c
    cpl
    add a, $01
    ld c, a

    ld a, b
    cpl
    adc a, $00
    ld b, a 
    
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 

    ; Pos - Velocity
    add c ; add second part of pos with second part of velocity
    ld e, a
    ld a, d
    adc b ; add with the first part of velocity

    dec hl
    
    ld [hli], a
    ld a, e
    ld [hl], a 
ENDM

/*  Interpolate the position of an entity increasingly.
    hl - position starting address
    bc - Entity Velocity value 
    
    Registers changed:
        - af
        - de
        - hl
*/
MACRO interpolate_pos_inc_reg
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 

    ; Pos + Velocity
    add a, c ; add second part of pos with second part of velocity
    ld e, a
    ld a, d
    adc a, b ; add with the first part of velocity

    dec hl

    ld [hli], a
    ld a, e
    ld [hl], a 
ENDM


    ENDC ; MOVEMENT_INC