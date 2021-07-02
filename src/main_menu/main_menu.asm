INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

DEF MAINMENU_STATE_TITLE EQU $01
DEF MAINMENU_STATE_CONTINUE EQU $02
DEF MAINMENU_STATE_NEWGAME EQU $03

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

    ; Set Default Cursor Pos
    xor a
    ld [wCursorPos], a

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

UpdateMainMenu:
    ; Update Sound
    set_romx_bank BANK(CombatBGM)
    call _hUGE_dosound

    rst $0010 ; Wait VBlank

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
    push bc
    push de
    push hl

    ld hl, _SCRN0
    ld bc, $0163
    add hl, bc
    ld [hl], 27

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti

SECTION "Main Menu WRAM", WRAM0
wMainMenuState::
    ds 1
wSelection::
    ds 1
wCursorPos::
    ds 2