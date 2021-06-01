    IF !DEF(MOVEMENT_INC)
DEF MOVEMENT_INC EQU 1

/*  Interpolate the position of an entity decreasingly.
    \1 - Entity Pos Address
    \2 - Entity Velocity Address */
MACRO interpolate_pos_dec
    push af
    push bc
    push hl
    
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

    pop hl
    pop bc
    pop af
ENDM

/*  Interpolate the position of an entity decreasingly.
    Parameters are registers instead
    hl - Pos starting address
    bc - Value of velocity */
    
MACRO interpolate_pos_dec_reg
    push af
    push de
    push hl
    
   ; Get -Velocity
    ld a, c
    cpl
    add a, $01
    ld c, a

    ld a, b
    cpl
    adc a, $00
    ld b, a 

    ; Get Pos
 /*   push hl
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 
    ld e, a

    ; Pos - Velocity
    ld h, d ; transfer the position de to hl
    ld l, e
    add hl, bc

    ld a, h ; transfer hl to ae
    ld e, l 
    pop hl

    ld [hli], a
    ld a, e
    ld [hl], a */


    ; what if i do add and then put over the carry bits?
    push hl
    
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 

    ; Pos - Velocity
    add c ; add second part of pos with second part of velocity
    ld e, a
    ld a, d
    adc b ; add with the first part of velocity

    pop hl
    ld [hli], a
    ld a, e
    ld [hl], a 

    pop hl
    pop de
    pop af
ENDM

/*  Interpolate the position of an entity increasingly.
    \1 - Entity Pos Address
    \2 - Entity Velocity Address */
MACRO interpolate_pos_inc
    push af
    push bc
    push hl

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

    pop hl
    pop bc
    pop af
ENDM

/*  Interpolate the position of an entity increasingly.
    hl - position starting address
    bc - Entity Velocity value */
MACRO interpolate_pos_inc_reg
    push af
    push de
    push hl

    ; Get Pos
   /* push hl
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 
    ld e, a

    ; Pos + Velocity
    ld h, d ; transfer the position de to hl
    ld l, e
    add hl, bc

    ld a, h ; transfer hl to ae
    ld e, l 
    pop hl

    ld [hli], a
    ld a, e
    ld [hl], a */

    ; what if i do add and then put over the carry bits?
    push hl
    
    ld a, [hli] ; get first byte of pos 
    ld d, a
    ld a, [hl] ; get second byte of pos 

    ; Pos + Velocity
    add c ; add second part of pos with second part of velocity
    ld e, a
    ld a, d
    adc b ; add with the first part of velocity

    pop hl
    ld [hli], a
    ld a, e
    ld [hl], a 


    pop hl
    pop de
    pop af
ENDM


    ENDC ; MOVEMENT_INC