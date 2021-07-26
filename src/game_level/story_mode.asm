INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

DEF MAX_TEXT_ROWS EQU 9
DEF MAX_TEXT_COLS EQU 18
DEF UTI_TEXT_START EQU 8*32+1

SECTION "Story Mode WRAM", WRAM0
wTextBuffer:
    ds 2048
wPointer:
    ds 2
wPointerEnd:
    ds 2

wTileIndex:
    ds 2

wWordBuffer:
    ds 64
wWordLength:
    ds 1
wRow:
    ds 1
wCol:
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
    ld a, HIGH(UTI_TEXT_START)
    ld [wTileIndex], a
    ld a, LOW(UTI_TEXT_START)
    ld [wTileIndex+1], a

    ld a, HIGH(wTextBuffer)
    ld [wPointer], a
    ld a, LOW(wTextBuffer)
    ld [wPointer+1], a

    xor a
    ld [wWordLength], a
    ld [wRow], a
    ld [wCol], a

    mem_copy Story0, wTextBuffer, Story0.end-Story0
    ld a, HIGH(wTextBuffer+(Story0.end-Story0))
    ld [wPointerEnd], a
    ld a, LOW(wTextBuffer+(Story0.end-Story0))
    ld [wPointerEnd+1], a

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
    ld a, [wPointer]
    ld h, a
    ld a, [wPointer+1]
    ld l, a

    ld a, [wPointerEnd]
    ld b, a
    ld a, [wPointerEnd+1]
    ld c, a

    call BCCompareHL
    jr z, .end

    ld a, [wRow]
    cp a, MAX_TEXT_ROWS
    jr z, .end

    call PrintLine

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

GetNextWord:
    push af
    push bc
    push de
    push hl

    ; DE = wWordBuffer
    ld de, wWordBuffer

    ; BC = wPointerEnd
    ld a, [wPointerEnd]
    ld b, a
    ld a, [wPointerEnd+1]
    ld c, a

    ; HL = wPointer
    ld a, [wPointer]
    ld h, a
    ld a, [wPointer+1]
    ld l, a

    ; Set wWordLength = 0
    xor a
    ld [wWordLength], a

.loop
    ; If BC == HL, return.
    call BCCompareHL
    jr z, .end

    ; wWordLength += 1
    ld a, [wWordLength]
    inc a
    ld [wWordLength], a

    ; Copy character into wWordBuffer.
    ld a, [hli]
    ld [de], a
    inc de
    cp a, " "
    jr nz, .loop

.end
    ; Update wPointer
    ld a, h
    ld [wPointer], a
    ld a, l
    ld [wPointer+1], a

    pop hl
    pop de
    pop bc
    pop af
    ret

PrintWord:
    push af
    push bc
    push de
    push hl

    ld a, [wWordLength]
    ld d, a
    ld hl, wWordBuffer

    ld a, [wTileIndex]
    ld b, a
    ld a, [wTileIndex+1]
    ld c, a

.loop
    ld a, [hli]
    call QueueBGTile
    inc bc
    dec d
    jr nz, .loop

    ld a, b
    ld [wTileIndex], a
    ld a, c
    ld [wTileIndex+1], a

    ld a, [wWordLength]
    ld d, a
    ld a, [wCol]
    add a, d
    ld [wCol], a

    pop hl
    pop de
    pop bc
    pop af
    ret

PrintLine:
    call GetNextWord
    call PrintWord
    ret