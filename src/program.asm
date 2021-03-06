INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "LCD", ROM0
; Turn off the LCD.
; @destroy af
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
; Disable sound.
; @destroy af
SoundOff::
    xor a
    ld [rAUDENA], a
    ret

; Enable sound.
; @destroy af
SoundOn::
    ld a, $80
    ld [rAUDENA], a
    ld a, $FF
    ld [rAUDTERM], a
    ld a, $77
    ld [rAUDVOL], a
    ret

; Set VBlankCallback. The callback instruction must be 3 bytes, such as a "jp Immd" instruction.
; @param hl The address of the 3 bytes callback instruction.
SetVBlankCallback::
    ld  c, LOW(hVBlankCallback)
REPT 3
    ld  a, [hli]
    ldh [c], a
    inc c
ENDR
    ret

; Set ProgramLoopCallback. The callback instruction must be 3 bytes, such as a "jp Immd" instruction.
; @param hl The address of the 3 bytes callback instruction.
SetProgramLoopCallback::
    ld  c, LOW(hProgramLoopCallback)
REPT 3
    ld  a, [hli]
    ldh [c], a
    inc c
ENDR
    ret

SECTION "Entry Point", ROM0[$0100]
    di ; Disable interrupts until we have finish initialisation.
    jp RunProgram ; Leave this tiny space.

SECTION "Program", ROM0
RunProgram:
    ld sp, wStackBottom ; Initialise our stack pointer to the end of the allocation of WRAM.

    call LCDOff
    call SoundOff
    call CopyDMARoutine ; Copy DMARoutine from ROM to HRAM.

    ; Reset hWaitVBlankFlag.
    xor a
    ld [hWaitVBlankFlag], a

    ; Set Colour Palettes
    ld a, %11100100
    ld [rBGP], a ; Set Background Palette
    ld [rOBP0], a ; Set Object Palette 0
    ld a, %00011011
    ld [rOBP1], a ; Set Object Palette 1

    ; Set Selected Stage
    xor a
    ld [wSelectedStage], a
    ; Set Default Menu Scene
    ld a, HIGH(JumpLoadTitleScreen)
    ld [wMainMenuDefaultJump], a
    ld a, LOW(JumpLoadTitleScreen)
    ld [wMainMenuDefaultJump+1], a
    ld hl, JumpLoadMainMenu
    call SetProgramLoopCallback

.loop
    call hProgramLoopCallback
    rst $0010 ; Wait for VBlank
    jr .loop

SECTION "Program HRAM", HRAM
; LCD
hLCDC::
    ds 1

; VBlank
hWaitVBlankFlag::
    ds 1
hVBlankCallback::
    ds 3 ; Reserve just enough space for a "jp Immd" instruction.

; Program Loop
hProgramLoopCallback::
    ds 3 ; Reserve just enough space for a "jp Immd" instruction.

SECTION "Stack", WRAM0
wStack:
    ds STACK_SIZE
wStackBottom: