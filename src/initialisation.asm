INCLUDE "./src/hardware.inc"
INCLUDE "./src/util.inc"

SECTION "Initialisation", ROM0
Initialise::
    ld sp, $E000 ; Initialise our stack pointer to the end of the work RAM.

    call CopyDMARoutine ; init the copy of the DMA handler func from RAM to HRAM

    ; Wait for VBlank before shutting off the LCD.
    WAIT_VBLANK

    /*  The LCDC register ($FF40) is the LCD Control register.
        Bit 0: Background & Window Display (0 = Off, 1 = On)
        Bit 1: Sprite Display (0 = Off, 1 = On)
        Bit 2: Sprite Pixel Size (0 = 8*8, 1 = 8*16)
        Bit 3: Background Tile Map Display Select (0 = $9800 - $9BFF, 1 = $9C00 - $9FFF)
        Bit 4: Background & Window Tile Data Select (0 = $8800 - $97FF, 1 = $8000 - $8FFF)
        Bit 5: Window Display (0 = Off, 1 = On)
        Bit 6: Window Tile Map Display Select (0 = $9800 - $9BFF, 1 = $9C00 - $9FFF)
        Bit 7: LCD Control Operation (0 = Off, 1 = On) */

    ; Shut off the LCD.
    xor a; ld a, 0
    ld [rLCDC], a

    call ResetOAM

    ; Copy background tile data into VRAM.
    SET_ROMX_BANK 2 ; Our tile data is in Bank 2, so we load that into ROMX.
    MEM_COPY BackgroundTiles, _VRAM9000, BackgroundTiles.end-BackgroundTiles
    MEM_COPY TestSprite, _VRAM8000, TestSprite.end-TestSprite

    ; Copy tile map into VRAM.
    SET_ROMX_BANK 3 ; Our tile maps are in Bank 3, so we load that into ROMX.
    MEM_COPY Level0, _SCRN0, Level0.end-Level0

    ; Temporary code.
    ld hl, wShadowOAM
    call InitPlayer
    call UpdatePlayerShadowOAM
 
    call hOAMDMA ; transfer sprite data to OAM

    ; Init display registersm and turn on display
    ld a, %11100100 ; setting the color palette
    ld [rBGP], a ; render it out

    xor a ; ld a, 0
    ld [rSCY], a ; make the screen for scroll X and Y start at 0
    ld [rSCX], a
    
    ; Shut sound down
    ld [rNR52], a
    
    ; Turn screen on, display background
    ld a, %10000011 ; we want to set back LCDC bit 7 to 1
    ld [rLCDC], a ; turn on the screen


    ld a, IEF_VBLANK ; turn on vblank
    ldh [rIE], a
    xor a ; clean up work
    ei ; enable intrupts

    jp MainGameLoop ; Go to main game loop