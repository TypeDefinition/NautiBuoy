INCLUDE "./src/hardware.inc"

SECTION "WaitVBlank", ROM0
/*  Loop until the LCD is in VBlank state.
    Registers Used: a */
WaitVBlank::
    ld a, [rLY] ; rLY is address $FF44, we getting the LCDC Y-Coordinate here to see the current state of the LCDC drawing
    cp 144 ; Check if the LCD is past VBlank, values between 144 - 153 is VBlank period
    jr c, WaitVBlank ; We need wait for Vblank before we can turn off the LCD
    ret

/*  Copy data from one memory address to another, byte by byte.
    de - Source address
    bc - number of bytes to fill
    hl - destination address
    
    Registers Used: a, b, c, d, e, h, l */
SECTION "MemCopy", ROM0
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

SECTION "Negate Args", WRAM0
wNegateArgs::
    .src::
        ds 1
    .result::
        ds 1

/*  Negate a 8-bit value via 2's Complement.
    .src - Value to negate.
    .result - Function output

    Registers Used: a */
SECTION "Negate", ROM0
Negate::
    push af
    ld a, [wNegateArgs.src]
    xor a, $FF ; Invert the bits of a.
    add a, 1
    ld [wNegateArgs.result], a
    pop af
    ret