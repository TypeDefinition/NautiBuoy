INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

; Main Menu States
DEF MAINMENU_STATE_TITLE EQU $00
DEF MAINMENU_STATE_STAGESELECT EQU $01
DEF MAINMENU_STATE_NEWGAME EQU $02

SECTION "Main Menu WRAM", WRAM0
wMainMenuStatePrevious:
    ds 1
wMainMenuStateCurrent:
    ds 1
wSelection:
    ds 1

SECTION "Main Menu", ROM0
LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
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

    ; Set Default Main Menu State
    ld a, MAINMENU_STATE_TITLE
    ld [wMainMenuStateCurrent], a
    inc a ; Trigger a load on the first update loop.
    ld [wMainMenuStatePrevious], a

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
    call UpdateInput

    ; Update Sound
    set_romx_bank BANK(CombatBGM)
    call _hUGE_dosound

    ; Update Screen
.updateBranch
    ld a, [wMainMenuStatePrevious]
    ld b, a
    ld a, [wMainMenuStateCurrent]
    ASSERT MAINMENU_STATE_TITLE == 0
    and a, a
    jr z, .updateTitleScreen
    ASSERT MAINMENU_STATE_STAGESELECT == 1
    dec a
    dec b
    jr z, .updateStageSelectScreen
    ASSERT MAINMENU_STATE_NEWGAME > 1
.updateNewGameScreen
    xor a, b
    call nz, LoadNewGameScreen
    call UpdateNewGameScreen
    jr .updateMainMenuStatePrevious
.updateTitleScreen
    xor a, b
    call nz, LoadTitleScreen
    call UpdateTitleScreen
    jr .updateMainMenuStatePrevious
.updateStageSelectScreen
    xor a, b
    call nz, LoadStageSelectScreen
    call UpdateStageSelectScreen
.updateMainMenuStatePrevious
    ld a, [wMainMenuStateCurrent]
    ld [wMainMenuStatePrevious], a

.waitVBlank
    rst $0010

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
    ld a, [wSelection]
    add a, "0"
    ld [hl], a

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti

INCLUDE "./src/main_menu/title_screen.asm_part"
INCLUDE "./src/main_menu/new_game_screen.asm_part"
INCLUDE "./src/main_menu/stage_select_screen.asm_part"