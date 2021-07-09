INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

; Cursor Tile Value
DEF CURSOR_TILE_VALUE EQU $10

; Reset Screen Cursor Tile Index
DEF CTI_OPT_NO EQU $01E2
DEF CTI_OPT_YES EQU $01ED

; Stage Select Screen UI Tile Index
DEF UTI_STAGE_NAME EQU 76
DEF UTI_STAGE_TIME EQU 142
DEF UTI_STARS1_TIME EQU 334
DEF UTI_STARS2_TIME EQU 398
DEF UTI_STARS3_TIME EQU 462
DEF UTI_YOUR_TIME EQU $00
DEF UTI_YOUR_STARS EQU $00

SECTION "Main Menu WRAM", WRAM0
; Global Variables
wMainMenuDefaultJump::
    ds 2
wSelectedStage::
    ds 1

; Local Variables
wResetOption:
    ds 1

SECTION "Main Menu", ROM0
; Global Jumps
JumpLoadMainMenu::
    jp LoadMainMenu
JumpLoadTitleScreen::
    jp LoadTitleScreen
JumpLoadResetScreen::
    jp LoadResetScreen
JumpLoadUnlockedStageScreen::
    jp LoadUnlockedStageScreen

; Local Jumps
JumpVBlankHandler:
    jp VBlankHandler
JumpUpdateTitleScreen:
    jp UpdateTitleScreen
JumpUpdateResetScreen:
    jp UpdateResetScreen
JumpUpdateUnlockedStageScreen:
    jp UpdateUnlockedStageScreen

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

    ld a, [wMainMenuDefaultJump]
    ld h, a
    ld a, [wMainMenuDefaultJump+1]
    ld l, a
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