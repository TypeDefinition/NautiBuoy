INCLUDE "./src/hardware.inc"

; $0000 - $003F: Restart Commands (RST)
/*  Restart Commands, or "rst" commands, jumps to an address and execute code until encountering a return command.
    They are only capable of going to a few preset addresses.
    Those addresses are $0000, $0008, $0010, $0018, $0020, $0028, $0030 and $0038. */
SECTION "RST $0000", ROM0[$0000]
    ret

/*  Initialise data in memory to a certain value.
    For small data sets, up to size 256.
    a - Value to init to
    b - Number of bytes (MUST BE 1 OR MORE)
    hl - Destination address
    
    Registers Used: a, b, h, l */
SECTION "RST $0008", ROM0[$0008]
MemSetSmall::
    ld [hli], a
    dec b
    jr nz, MemSetSmall
    ret

SECTION "RST $0010", ROM0[$0010]
    ret

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