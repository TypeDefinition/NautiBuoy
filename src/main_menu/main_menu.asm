INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

; Title Options
RSRESET
DEF opt_title_CONTINUE RB
DEF opt_title_NEWGAME RB

; Tile Screen Cursor Tile Indices
DEF CTI_TITLE_OPT_CONTINUE EQU $0163
DEF CTI_TITLE_OPT_NEWGAME EQU $01A3

; New Game Options
RSRESET
DEF opt_newgame_NO RB
DEF opt_newgame_YES RB

; New Game Screen Cursor Tile Indices
DEF CTI_NEWGAME_OPT_NO EQU $0163
DEF CTI_NEWGAME_OPT_YES EQU $01A3

/*  Add a Tile Index to wCursorTileIndices.
    ld hl, wCursorTileIndices should be invoked right before
    the first invokation of this macro.
    @param \1 Tile Index
    @destroy af, bc, hl */
MACRO add_cti
    ld bc, \1
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
ENDM

SECTION "Main Menu WRAM", WRAM0
wSelectedOption:
    ds 1
wCursorTileIndices:
    ds 4*2 ; Stores 4 tile indices. Each tile index is 2 bytes.

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
JumpLoadNewGameScreen:
    jp LoadNewGameScreen
JumpUpdateNewGameScreen:
    jp UpdateNewGameScreen
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

; Get the cursor tile index.
; @return bc Cursor Tile Index
GetCursorTileIndex:
    push af
    push hl

    ld h, 0
    ld a, [wSelectedOption]
    ld l, a
    ld bc, wCursorTileIndices

    add hl, hl
    add hl, bc
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a

    pop hl
    pop af
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
INCLUDE "./src/main_menu/new_game_screen.asm_part"
INCLUDE "./src/main_menu/stage_select_screen.asm_part"