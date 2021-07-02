INCLUDE "./src/include/hardware.inc"

SECTION "Util Functions", ROM0
/*  Copy data from one memory address to another, byte by byte.
    de - Source address
    bc - number of bytes to fill
    hl - destination address
    
    Registers Used: a, b, c, d, e, h, l */
MemCopy::
    push af

.loop
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl, hli is just increment hl.
    inc de ; Move to next byte.
    dec bc ; Decrement count.
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags.
    or c ; if b and c are 0, when u or them it'll give 0 also.
    jr nz, .loop ; check if not zero.

    pop af

    ret

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