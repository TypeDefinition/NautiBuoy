INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Main Menu", ROM0
LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

OverridehVBlankHandler:
    ld  hl, .override
    ld  c, LOW(hVBlankHandler)
REPT 3 ; The "jp VBlankHandler" instruction is 3 bytes.
    ld  a, [hli]
    ldh [c], a
    inc c
ENDR
    ret
.override
    jp VBlankHandler

LoadMainMenu::
    di ; Disable Interrupts

    call LCDOff
    call OverridehVBlankHandler

    ; Reset hWaitVBlankFlag.
    xor a
    ld [hWaitVBlankFlag], a

    ; Copy tile data into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData

    ; Copy tile map into VRAM.
    set_romx_bank BANK(MainMenuTileMap)
    mem_copy MainMenuTileMap, _SCRN0, MainMenuTileMap.end-MainMenuTileMap

    ; Reset SCY & SCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call LCDOn

    ; Set BGM
    set_romx_bank BANK(CombatBGM)
    ld hl, CombatBGM
    call hUGE_init

    ; Set Interrupt Flags
    ld a, IEF_VBLANK
    xor a
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    jp UpdateMainMenu

UpdateMainMenu:
    ; Update Sound
    set_romx_bank BANK(CombatBGM)
    call _hUGE_dosound

    jr UpdateMainMenu

VBlankHandler:
    push af
    ; Check for lag frame.
    ldh a, [hWaitVBlankFlag]
	and a
	jr z, .lagFrame
    ; Reset hWaitVBlankFlag
	xor a
	ldh [hWaitVBlankFlag], a
    pop af
.lagFrame
    pop af
    reti