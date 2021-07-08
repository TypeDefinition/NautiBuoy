INCLUDE "./src/include/hardware.inc"

DEF MAX_STAGES EQU 16

/*  The save data consists of a 4-Byte validation string
    to check for data corruption, followed by 4 bytes for each
    game stage.

    The game stage save data consists of the follwing:
    Stage Locked/Unlock - 1 Byte (Locked = 0, Unlocked = 1)
    Best Time Left - 2 Bytes
    Number of Stars - 1 Byte */
SECTION "Save Game SRAM", SRAM
sSaveData::
    ds 4 ; Validation string.
    ds 4*MAX_STAGES ; Save data for stages.
.end::

SECTION "Save Game WRAM", WRAM0
wSaveStageNumber::
    ds 1
wSaveStageData::
    ds 4

SECTION "Save Game", ROM0
SaveValidationString::
    db "L", "E", "Q", "A"
.end::

EnableSRAM::
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ret

DisableSRAM::
    xor a
    ld [rRAMG], a
    ret

SaveGame::
    call EnableSRAM

    ; Write to validation string.
    ld a, [SaveValidationString]
    ld [sSaveData], a
    ld a, [SaveValidationString+1]
    ld [sSaveData+1], a
    ld a, [SaveValidationString+2]
    ld [sSaveData+2], a
    ld a, [SaveValidationString+3]
    ld [sSaveData+3], a

    ; Set hl to the write memory address.
    ld bc, sSaveData
    ld a, [wSaveStageNumber]
    inc a
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, bc
    
    ; Write to SRAM
    ld a, [wSaveStageData]
    ld [hli], a
    ld a, [wSaveStageData+1]
    ld [hli], a
    ld a, [wSaveStageData+2]
    ld [hli], a
    ld a, [wSaveStageData+3]
    ld [hl], a

    call DisableSRAM
    ret

LoadGame::
    ret