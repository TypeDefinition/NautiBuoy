INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Main Menu", ROM0
LoadMainMenu::
    di ; Disable Interrupts

    call LCDOff

    ; Reset hVBlankFlag.
    xor a
    ld [hVBlankFlag], a

    ; Reset SCY & SCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Copy textures into VRAM.
    set_romx_bank BANK(BGWindowTiles)
    mem_copy BGWindowTiles, _VRAM9000, BGWindowTiles.end-BGWindowTiles

    ; Copy tile map into VRAM.
    set_romx_bank BANK(MainMenuTileMap)
    mem_copy MainMenuTileMap, _SCRN0, MainMenuTileMap.end-MainMenuTileMap

    call LCDOn

    ; Set BGM
    set_romx_bank BANK(CombatBGM)
    ld hl, CombatBGM
    call hUGE_init

    ; Set Interrupt Flags
    ld a, IEF_VBLANK
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    jp UpdateMainMenu

UpdateMainMenu::
    jr UpdateMainMenu