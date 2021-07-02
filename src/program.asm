INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "LCD HRAM", HRAM
hLCDC::
    ds 1

SECTION "LCD", ROM0
LCDOff::
    ; If the LCD is already off, exit.
    ld a, [rLCDC]
    bit 7, a
    ret z
    ; Wait for VBlank before shutting off the LCD.
.waitVBlank::
    ld a, [rLY] ; rLY is address $FF44, we getting the LCDC Y-Coordinate here to see the current state of the LCDC drawing
    cp 144 ; Check if the LCD is past VBlank, values between 144 - 153 is VBlank period
    jr c, .waitVBlank ; We need wait for Vblank before we can turn off the LCD
    xor a; ld a, 0
    ld [rLCDC], a
    ret

SECTION "Sound", ROM0
SoundOn::
    ld a, $80
    ld [rAUDENA], a
    ld a, $FF
    ld [rAUDTERM], a
    ld a, $77
    ld [rAUDVOL], a
    ret

; $0100 - $0103: Entry Point
SECTION "Entry Point", ROM0[$0100]
/*  After booting, the CPU jumps to the actual main program in the cartridge, which is $0100.
    Usually this 4 byte area contains a NOP instruction, followed by an instruction to jump to $0150. But not always.
    The reason for the jump is that while the entry point is $100, the header of the game spans from $0104 to $014F.
    So there's only 4 bytes in which we can run any code before the header. So we use these 4 bytes to jump to after the header. */
    di ; Disable interrupts until we have finish initialisation.
    jp LoadProgram ; Leave this tiny space.

SECTION "Program", ROM0
LoadProgram::
    ld sp, $E000 ; Initialise our stack pointer to the end of WRAM.

    call LCDOff
    call SoundOn
    call CopyDMARoutine ; Copy DMARoutine from ROM to HRAM.

    ; Reset hWaitVBlankFlag.
    xor a
    ld [hWaitVBlankFlag], a

    ; Set Colour Palettes
    ld a, %11100100
    ld [rBGP], a ; Set Background Palette
    ld [rOBP0], a ; Set Object Palette 0
    ld a, %01001011
    ld [rOBP1], a ; Set Object Palette 1

    ; jp LoadMainMenu
    jp LoadGameLevel

SECTION "VBlank HRAM", HRAM
hWaitVBlankFlag::
    ds 1
; Reserve just enough space for a "jp Immd" instruction.
hVBlankHandler::
    ds 3