INCLUDE "./src/include/hardware.inc"

DEF MAX_STAGES EQU 16

/*  The save data consists of a 4-Byte validation string
    to check for data corruption, followed by 4 bytes for each
    game stage.

    The game stage save data consists of the follwing:
    Stage Locked/Unlock - 1 Byte (Locked = 0, Unlocked = 1)
    Best Time Left - 2 Bytes
    Number of Stars - 1 Byte */
SECTION "Save Data SRAM", SRAM
SaveData::
    ds 4 ; Validation string.
    ds 4*MAX_STAGES ; Save data for stages.
.end::

SECTION "Save Data WRAM", WRAM0
wWriteStageData::
    ds 4

SECTION "Save Data", ROM0
SaveDataValidationString::
    db "L", "E", "Q", "A"
.end::

EnableSaveData::
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ret

DisableSaveData::
    xor a
    ld [rRAMG], a
    ret