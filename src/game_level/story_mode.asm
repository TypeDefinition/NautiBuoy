INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

DEF NUM_TEXT_ROWS EQU 6
DEF NUM_TEXT_COLS EQU 18
DEF MAX_TEXT_CHUNK EQU NUM_TEXT_ROWS*NUM_TEXT_COLS
DEF UTI_TEXT_START EQU 8*32+1

SECTION "Story Mode WRAM", WRAM0
wText:
    ds 2048
wCharRemaining:
    ds 2
wCurrentCharAddress:
    ds 2
wCurrentCharTileIndex:
    ds 2
wCurrentCharCol:
    ds 1

SECTION "Story Mode", ROM0
; Global Jumps
JumpLoadStoryMode::
    jp LoadStoryMode

; Local Jumps
JumpVBlankHandler:
    jp VBlankHandler

JumpUpdateStoryMode:
    jp UpdateStoryMode

LCDOn:
    ; Set LCDC Flags
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
    ld [hLCDC], a
    ld [rLCDC], a
    ret

InitStoryText:
    ld a, HIGH(wText)
    ld [wCurrentCharAddress], a
    ld a, LOW(wText)
    ld [wCurrentCharAddress+1], a

    ld a, HIGH(UTI_TEXT_START)
    ld [wCurrentCharTileIndex], a
    ld a, LOW(UTI_TEXT_START)
    ld [wCurrentCharTileIndex+1], a

    xor a
    ld [wCurrentCharCol], a

    ld a, [wSelectedStage]
    ld b, a

    dec b
    jr nz, :+
    mem_copy Story1, wText, Story1.end-Story1
    ld hl, Story1.end-Story1
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a
    jp .end

:   dec b
    jr nz, :+
    mem_copy Story2, wText, Story2.end-Story2
    ld hl, Story2.end-Story2
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a
    jp .end

:   dec b
    jr nz, :+
    mem_copy Story3, wText, Story3.end-Story3
    ld hl, Story3.end-Story3
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a
    jp .end

:   dec b
    jr nz, :+
    mem_copy Story4, wText, Story4.end-Story4
    ld hl, Story4.end-Story4
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a
    jp .end

:   dec b
    jr nz, :+
    mem_copy Story5, wText, Story5.end-Story5
    ld hl, Story5.end-Story5
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a
    jp .end

    ; Default
:   mem_copy Story0, wText, Story0.end-Story0
    ld hl, Story0.end-Story0
    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a

.end
:   ret

LoadStoryMode:
    di ; Disable Interrupts

    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback

    ld hl, JumpUpdateStoryMode
    call SetProgramLoopCallback

    ; Copy tile data into VRAM.
    set_romx_bank BANK(TitleScreenTileData)
    mem_copy TitleScreenTileData, _VRAM9000, TitleScreenTileData.end-TitleScreenTileData

    ; Copy tile map into VRAM.
    set_romx_bank BANK(StoryModeTileMap)
    mem_copy StoryModeTileMap, _SCRN0, StoryModeTileMap.end-StoryModeTileMap

    call InitStoryText

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

UpdateStoryMode:
    ; Decrement wCharRemaining
    ld a, [wCharRemaining]
    ld h, a
    ld a, [wCharRemaining+1]
    ld l, a

    ld bc, -$0001
    add hl, bc
    jr nc, .end

    ld a, h
    ld [wCharRemaining], a
    ld a, l
    ld [wCharRemaining+1], a

    ; Get the current tile index.
    ld a, [wCurrentCharTileIndex]
    ld b, a
    ld a, [wCurrentCharTileIndex+1]
    ld c, a

    ; Get the current character.
    ld a, [wCurrentCharAddress]
    ld h, a
    ld a, [wCurrentCharAddress+1]
    ld l, a
    ld a, [hl]

    call QueueBGTile

    inc hl
    ld a, h
    ld [wCurrentCharAddress], a
    ld a, l
    ld [wCurrentCharAddress+1], a

    inc bc
    ld a, b
    ld [wCurrentCharTileIndex], a
    ld a, c
    ld [wCurrentCharTileIndex+1], a

    ; Go To Next Line
    ld a, [wCurrentCharCol]
    inc a
    ld [wCurrentCharCol], a

    cp a, NUM_TEXT_COLS
    jr nz, .end
    xor a
    ld [wCurrentCharCol], a
    ld h, b
    ld l, c
    ld bc, $000E
    add hl, bc
    ld a, h
    ld [wCurrentCharTileIndex], a
    ld a, l
    ld [wCurrentCharTileIndex+1], a
    
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