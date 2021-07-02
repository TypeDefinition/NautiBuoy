INCLUDE "./src/include/hardware.inc"

; $0000 - $003F: Restart Commands (RST)
/*  Restart Commands, or "rst" commands, jumps to an address and execute code until encountering a return command.
    They are only capable of going to a few preset addresses.
    Those addresses are $0000, $0008, $0010, $0018, $0020, $0028, $0030 and $0038. */
SECTION "RST $0000", ROM0[$0000]
    ret

/*  Set data in memory to a certain value.
    For small data sets, up to size 256.
    @param a Value to set to.
    @param b Number of bytes to set. (MUST BE 1 OR GREATER!)
    @param hl Destination address.
    @destroy af, b, hl */
SECTION "RST $0008", ROM0[$0008]
MemSetSmall::
    ld [hli], a
    dec b
    jr nz, MemSetSmall
    ret

; Waits for the next VBlank beginning.
; Requires the VBlank handler to be able to trigger, otherwise will loop infinitely.
; This means IME should be set, the VBlank interrupt should be selected in IE, and the LCD should be turned on.
; WARNING: Be careful if calling this with IME reset (`di`), if this was compiled
; with the `-h` flag, then a hardware bug is very likely to cause this routine to go horribly wrong.
; Note: the VBlank handler recognizes being called from this function (through `hVBlankFlag`),
; and does not try to save registers if so. To be safe, consider all registers to be destroyed.
; @destroy af, bc, de, hl (The VBlank handler stops preserving anything when executed from this function.)
SECTION "RST $0010", ROM0[$0010]
WaitVBlank::
    ld a, $01
    ldh [hWaitVBlankFlag], a
.wait
    halt
    jr .wait

SECTION "RST $0018", ROM0[$0018]
    ret

SECTION "RST $0020", ROM0[$0020]
    ret

SECTION "RST $0028", ROM0[$0028]
    ret

SECTION "RST $0030", ROM0[$0030]
    ret

SECTION "RST $0038", ROM0[$0038]
    ret