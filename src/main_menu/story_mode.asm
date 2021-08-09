INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

; MAX_TEXT_ROWS*MAX_TEXT_COLS MUST BE SMALLER THAN UPDATE_QUEUE_SIZE!
DEF MAX_TEXT_ROWS EQU 9
DEF MAX_TEXT_COLS EQU 18

; UI Tile Index
DEF UTI_TEXT_START EQU 8*32+1

SECTION "Story Mode WRAM", WRAM0
wTextBuffer:
    ds 2048
wTextPointer:
    ds 2
wTextPointerEnd:
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
    ld [wTextPointer], a
    ld a, LOW(wTextBuffer)
    ld [wTextPointer+1], a

    xor a
    ld [wWordLength], a
    ld [wRow], a
    ld [wCol], a

    ld a, [wSelectedStage]
FOR N, 1, MAX_STAGES
:   dec a
    jr nz, :+


    IF DEF(LANGUAGE_EN)
    mem_copy StoryEN{u:N}, wTextBuffer, StoryEN{u:N}.end-StoryEN{u:N}
    ld a, HIGH(wTextBuffer+(StoryEN{u:N}.end-StoryEN{u:N}))
    ld [wTextPointerEnd], a
    ld a, LOW(wTextBuffer+(StoryEN{u:N}.end-StoryEN{u:N}))
    ENDC

    IF DEF(LANGUAGE_JP)
    mem_copy StoryJP{u:N}, wTextBuffer, StoryJP{u:N}.end-StoryJP{u:N}
    ld a, HIGH(wTextBuffer+(StoryJP{u:N}.end-StoryJP{u:N}))
    ld [wTextPointerEnd], a
    ld a, LOW(wTextBuffer+(StoryJP{u:N}.end-StoryJP{u:N}))
    ENDC

    ld [wTextPointerEnd+1], a
    jp .end
ENDR

    ; Default
    IF DEF(LANGUAGE_EN)
:   mem_copy StoryEN0, wTextBuffer, StoryEN0.end-StoryEN0
    ld a, HIGH(wTextBuffer+(StoryEN0.end-StoryEN0))
    ld [wTextPointerEnd], a
    ld a, LOW(wTextBuffer+(StoryEN0.end-StoryEN0))
    ld [wTextPointerEnd+1], a
    ENDC

    IF DEF(LANGUAGE_JP)
:   mem_copy StoryJP0, wTextBuffer, StoryJP0.end-StoryJP0
    ld a, HIGH(wTextBuffer+(StoryJP0.end-StoryJP0))
    ld [wTextPointerEnd], a
    ld a, LOW(wTextBuffer+(StoryJP0.end-StoryJP0))
    ld [wTextPointerEnd+1], a
    ENDC

.end
    ret

LoadStoryMode:
    di ; Disable Interrupts

    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback

    ld hl, JumpUpdateStoryMode
    call SetProgramLoopCallback

    IF DEF(LANGUAGE_EN)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataEN)
    mem_copy FontTileDataEN, _VRAM9200, FontTileDataEN.end-FontTileDataEN
    ENDC

    IF DEF(LANGUAGE_JP)
    ; Copy font tile data into VRAM.
    set_romx_bank BANK(FontTileDataJP)
    mem_copy FontTileDataJP, _VRAM9200, FontTileDataJP.end-FontTileDataJP
    ENDC

    ; Copy tile data into VRAM.
    set_romx_bank BANK(StoryModeTileData)
    mem_copy StoryModeTileData, _VRAM8800, StoryModeTileData.end-StoryModeTileData


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
    ; Update Sound
    set_romx_bank BANK(MainMenuBGM)
    call _hUGE_dosound

    ; Update Input
    call UpdateInput

    ld a, [wTextPointer]
    ld h, a
    ld a, [wTextPointer+1]
    ld l, a

    ld a, [wTextPointerEnd]
    ld b, a
    ld a, [wTextPointerEnd+1]
    ld c, a

    ; If wTextPointer == wTextPointerEnd && wWordLength == 0, we have reached the end of the story text.
    ; If we do not check for wWordLength, the last word may not be printed if it is on a new line.
.checkReachedEnd
    call BCCompareHL
    jr nz, .checkLastRow
    ld a, [wWordLength]
    cp a, $00
    jr z, .goToGame

    ; If wRow >= MAX_TEXT_ROWS, show the next chunk.
.checkLastRow
    ld a, [wRow]
    cp a, MAX_TEXT_ROWS
    jr z, .getNextChunk

    call PrintLine

.getNextChunk
    ld a, [wNewlyInputKeys]
    bit PADB_A, a
    jr z, .end

    call ClearChunk

    ; Update wCol & wRow
    xor a
    ld [wCol], a
    ld [wRow], a
    ; Update wTileIndex
    ld a, HIGH(UTI_TEXT_START)
    ld [wTileIndex], a
    ld a, LOW(UTI_TEXT_START)
    ld [wTileIndex+1], a
    jr .end

.goToGame
    ld a, [wNewlyInputKeys]
    bit PADB_A, a
    jr z, .end

    ld hl, JumpLoadGameLevel
    call SetProgramLoopCallback

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

ClearChunk:
    ld bc, UTI_TEXT_START

    ld d, MAX_TEXT_ROWS
.outerLoop
    push bc

    ; Inner Loop Start
    ld e, MAX_TEXT_COLS
.innerLoop
    ld a, " "
    call QueueBGTile
    inc bc
    dec e
    jr nz, .innerLoop
    ; Inner Loop End

    pop bc

    ld hl, $0020
    add hl, bc
    ld b, h
    ld c, l

    ; Update VRAM
    push af
    push bc
    push de
    push hl
    call UpdateBGWindow
    pop hl
    pop de
    pop bc
    pop af

    dec d
    jr nz, .outerLoop
    ret

GetNextWord:
    ; DE = wWordBuffer
    ld de, wWordBuffer

    ; BC = wTextPointerEnd
    ld a, [wTextPointerEnd]
    ld b, a
    ld a, [wTextPointerEnd+1]
    ld c, a

    ; HL = wTextPointer
    ld a, [wTextPointer]
    ld h, a
    ld a, [wTextPointer+1]
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
    ; Update wTextPointer
    ld a, h
    ld [wTextPointer], a
    ld a, l
    ld [wTextPointer+1], a

    ret

PrintWord:
    ; hl = wWordBuffer
    ld hl, wWordBuffer
    ; d = wWordLength
    ld a, [wWordLength]
    ld d, a

    ; bc = wTileIndex
    ld a, [wTileIndex]
    ld b, a
    ld a, [wTileIndex+1]
    ld c, a

    ; While d != 0
.loop
    ld a, [hli]
    call QueueBGTile
    inc bc
    dec d
    jr nz, .loop

    ; Update wTileIndex
    ld a, b
    ld [wTileIndex], a
    ld a, c
    ld [wTileIndex+1], a

    ; Update wCol
    ld a, [wWordLength]
    ld d, a
    ld a, [wCol]
    add a, d
    ld [wCol], a

    ; Set wWordLength = 0. This signals that there is nothing in wWordBuffer to be printed.
    xor a
    ld [wWordLength], a

    ret

PrintLine:
    ; If wWordLength != 0, there was a word that the previous line could not fit.
    ld a, [wWordLength]
    cp a, $00
    jr z, .loop
    call PrintWord
    ret

.loop
    ; Get next word, and check if it can still fit on the same line.
    call GetNextWord

    ; If next word has length 0, we have reached the end.
    ld a, [wWordLength]
    ld b, a
    cp a, $00
    ret z

    ; If the next word cannot fit on the same line. Go to next line.
    ld a, [wCol]
    add a, b
    cp a, MAX_TEXT_COLS
    jr nc, .nextRow
    call PrintWord
    jr .loop

    ; Go to next row.
.nextRow
    ; Update Col & Row
    xor a
    ld [wCol], a
    ld a, [wRow]
    inc a
    ld [wRow], a
    
    ; Update Tile Index
    ld bc, UTI_TEXT_START
    ld de, $0020
    ld hl, $0000
.multHL ; HL *= A
    add hl, de
    dec a
    jr nz, .multHL
    add hl, bc
    ld a, h
    ld [wTileIndex], a
    ld a, l
    ld [wTileIndex+1], a

    ret