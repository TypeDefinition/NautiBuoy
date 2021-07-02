INCLUDE "./src/include/hardware.inc"

; If all of these are already defined, don't do it again.

    IF !DEF(UTIL_INC)
DEF UTIL_INC EQU 1

/*  Copy data from one memory address to another, byte by byte.
    @param \1 Source Address
    @param \2 Destination Address
    @param \3 Number of Bytes
    @destroy af, bc, de, hl */
MACRO mem_copy
    ld de, \1
    ld hl, \2
    ld bc, \3
    call MemCopy
ENDM

; Set the memory bank that is placed into ROMX.
; @param \1 ROMX Bank
; @destroy a
MACRO set_romx_bank
    ld a, \1
    ld [rROMB0], a
ENDM

/*  Set data in memory to a certain value.
    For small data sets, up to size 256.
    @param \1 Destination address.
    @param \2 Value to set to.
    @param \3 Number of bytes to set. (MUST BE 1 OR GREATER!)
    @destroy af, b, hl */
MACRO mem_set_small
    ld hl, \1
    ld a, \2
    ld b, \3
    rst $0008 ; Here uses rst instead
ENDM

    ENDC ; UTIL_INC