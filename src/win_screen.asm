INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

SECTION "Win Screen", ROM0
; Global Jumps
JumpLoadWinScreen::
    jp LoadWinScreen

; Local Jumps
JumpUpdateWinScreen:
    jp UpdateWinScreen
JumpVBlankHandler:
    jp VBlankHandler

LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
    ld [rLCDC], a
    ret

LoadWinScreen:
    di
    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback

    ld hl, JumpUpdateWinScreen
    call SetProgramLoopCallback

    ; Copy tile map into VRAM.
    set_romx_bank BANK(WinScreenTileMap)
    mem_copy WinScreenTileMap, _SCRN0, WinScreenTileMap.end-WinScreenTileMap

    ; Reset SCY & SCX.
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call ResetBGWindowUpdateQueue

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(MainMenuBGM)
    ld hl, MainMenuBGM
    call hUGE_init

    ei

    ret

UpdateWinScreen:
    call UpdateInput

    ; Update Sound
    set_romx_bank BANK(MainMenuBGM)
    call _hUGE_dosound

    ; Get Input
    ld a, [wNewlyInputKeys]
    ld b, a
.onB
    bit PADB_B, b
    jr z, .end
    ld a, HIGH(JumpLoadStageSelectScreen)
    ld [wMainMenuDefaultJump], a
    ld a, LOW(JumpLoadStageSelectScreen)
    ld [wMainMenuDefaultJump+1], a
    ld hl, JumpLoadMainMenu
    call SetProgramLoopCallback
    jr .end
.end
    call UpdateBGWindow

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