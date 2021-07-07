INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

; Cursor Tile Value
DEF CURSOR_TILE_VALUE EQU $10

; Cursor Tile Index
DEF CTI_OPT_NO EQU $01E2
DEF CTI_OPT_YES EQU $01ED

SECTION "Main Menu WRAM", WRAM0
wSelectedOption:
    ds 1

SECTION "Main Menu", ROM0
; Global Jumps
JumpLoadMainMenu::
    jp LoadMainMenu
; Local Jumps
JumpVBlankHandler:
    jp VBlankHandler
JumpLoadTitleScreen:
    jp LoadTitleScreen
JumpUpdateTitleScreen:
    jp UpdateTitleScreen
JumpLoadResetScreen:
    jp LoadResetScreen
JumpUpdateResetScreen:
    jp UpdateResetScreen
JumpLoadStageSelectScreen:
    jp LoadStageSelectScreen
JumpUpdateStageSelectScreen:
    jp UpdateStageSelectScreen

LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
    ld [rLCDC], a
    ret

LoadMainMenu::
    di ; Disable Interrupts

    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback
    ld hl, JumpLoadTitleScreen
    call SetProgramLoopCallback

    ; Copy tile data into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(MainMenuBGM)
    ld hl, MainMenuBGM
    call hUGE_init

    ; Set interrupt flags, clear pending interrupts, and enable master interrupt switch.
    ld a, IEF_VBLANK
    ldh [rIE], a
    xor a
    ldh [rIF], a
    ei

    ret

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

    ; Code Goes Here

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti

INCLUDE "./src/main_menu/title_screen.asm_part"
INCLUDE "./src/main_menu/reset_screen.asm_part"
INCLUDE "./src/main_menu/stage_select_screen.asm_part"