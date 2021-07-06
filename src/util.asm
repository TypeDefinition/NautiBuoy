INCLUDE "./src/include/hardware.inc"

SECTION "Util", ROM0
/*  Copy data from one memory address to another, byte by byte.
    @param de Source address
    @param bc number of bytes to fill
    @param hl destination address
    @destroy af, bc, de, hl */
MemCopy::
    push af
.loop
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl, hli is just increment hl.
    inc de ; Move to next byte.
    dec bc ; Decrement count.
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags.
    or c ; If b and c are 0, when u or them it'll give 0 also.
    jr nz, .loop ; Check if not zero.
    pop af
    ret

; Burn 10 CPU cycles with a "call" and a "ret".
BurnCycles::
    ret

; Multiply the value in the hl register by 8.
; @param hl The value to multiply by 8.
; @return hl The multiplication result.
Mult8::
REPT 3
    add hl, hl
ENDR
    ret

; Multiply the value in the hl register by 16.
; @param hl The value to multiply by 16.
; @return hl The multiplication result.
Mult16::
REPT 4
    add hl, hl
ENDR
    ret

; Multiply the value in the hl register by 32.
; @param hl The value to multiply by 32.
; @return hl The multiplication result.
Mult32::
REPT 5
    add hl, hl
ENDR
    ret

; Divides c by d.
; @param c The dividend.
; @param d The denominator.
; @return a The remainder.
; @return c The quotient.
; @destroy b, f
CDivD::
    ld b, 8 ; We want to loop 8 times since there's 8 bits.
    xor a

:   sla c
    rla
    cp d
    jr c, :+
    inc c
    sub d
:   dec b
    jr nz, :--

    ret