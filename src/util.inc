INCLUDE "./src/hardware.inc"

; If all of these are already defined, don't do it again.

    IF !DEF(UTIL_INC)
DEF UTIL_INC EQU 1

MACRO WAIT_VBLANK
    call WaitVBlank
ENDM

; Copy data from one memory address to another, byte by byte.
; \1 - Source Address
; \2 - Destination Address
; \3 - Number of Bytes
MACRO MEM_COPY
    ld de, \1
    ld hl, \2
    ld bc, \3
    call MemCopy
ENDM

; Set the memory bank that is placed into ROMX.
MACRO SET_ROMX_BANK
    ld a, \1
    ld [rROMB0], a
ENDM

/*  Initialise data in memory to a certain value.
    For small data sets, up to size 256.
    \1 - Destination Address
    \2 - Value
    \3 - Number of Bytes */
MACRO MEMSET_SMALL
    ld hl, \1
    ld a, \2
    ld b, \3
    rst MemSetSmall ; Here uses rst instead
ENDM

    ENDC ; UTIL_INC