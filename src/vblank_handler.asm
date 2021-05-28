INCLUDE "./src/include/hardware.inc"

SECTION "Wait VBlank", ROM0
/*  Loop until the LCD is in VBlank state.
    Registers Used: a */
WaitVBlank::
    ld a, [rLY] ; rLY is address $FF44, we getting the LCDC Y-Coordinate here to see the current state of the LCDC drawing
    cp 144 ; Check if the LCD is past VBlank, values between 144 - 153 is VBlank period
    jr c, WaitVBlank ; We need wait for Vblank before we can turn off the LCD
    ret

SECTION "VBlank Handler", ROM0
VBlankHandler::
    call ResetOAM
    call hOAMDMA ; Update OAM

    ; TODO:: scrolling or any tile updates here
    ; TODO:: camera stuff here, just fix with player being in center of it
    ; TODO:: any UI stuff here too

    ; get back old state
    pop hl
    pop de
    pop bc
    pop af

    reti