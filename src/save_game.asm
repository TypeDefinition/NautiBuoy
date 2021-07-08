INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

DEF MAX_STAGES EQU 16

/*  The save data consists of a 4-Byte validation string
    to check for data corruption, followed by 4 bytes for each
    game stage.

    The game stage save data consists of the follwing:
    Stage Locked/Unlock - 1 Byte (Locked = 0, Unlocked & Incomplete = 1, Unlocked & Complete = 2)
    Best Time Left - 2 Bytes
    Number of Stars - 1 Byte */
SECTION "Save Game SRAM", SRAM
sChecksum::
    ds 2 ; Validation Checksum
sSaveData::
    ds 4*MAX_STAGES ; Save data for stages.
.end::

SECTION "Save Game WRAM", WRAM0
wRWIndex::
    ds 1
wRWData::
    ds 4
.end::

SECTION "Save Game", ROM0
EnableSRAM:
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ret

DisableSRAM:
    xor a
    ld [rRAMG], a
    ret

GenerateChecksum:
    ld b, sSaveData.end - sSaveData
    ld hl, sSaveData

    ; Calculate checksum.
    ld de, $0000 ; de = checksum
.loop
    ld a, [hli]
    add a, e
    ld e, a
    ld a, d
    adc a, $00
    ld d, a

    dec b
    jr nz, .loop

    ; Write checksum to SRAM.
    ld d, a
    ld [sChecksum], a
    ld e, a
    ld [sChecksum+1], a
    ret

; Validate the save data checksum.
; @return Z Flag (Valid = Z, Invalid = NZ)
ValidateChecksum:
    ld b, sSaveData.end - sSaveData
    ld hl, sSaveData

    ; Calculate checksum. de = checksum
    ld de, $0000
.loop
    ld a, [hli]
    add a, e
    ld e, a
    ld a, d
    adc a, $00
    ld d, a

    dec b
    jr nz, .loop

    ; Get SRAM checksum. hl = SRAM checksum.
    ld a, [sChecksum]
    ld h, a
    ld a, [sChecksum+1]
    ld l, a

    ; Check that hl == de.
    ld a, l
    cp e
    ret nz
    ld a, h
    cp d
    ret

GenerateDefaultSaveGame:
    ; Lock all stages.
    mem_set_small sSaveData, $00, sSaveData.end - (sSaveData+1)
    ; Unlock stage 1
    ld a, $01
    ld [sSaveData], a
    ret

SaveGame::
    call EnableSRAM

    ; Set hl to the write memory address.
    ld bc, sSaveData
    ld h, $00
    ld a, [wRWIndex]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc
    
    ; Write to SRAM
    ld a, [wRWData]
    ld [hli], a
    ld a, [wRWData+1]
    ld [hli], a
    ld a, [wRWData+2]
    ld [hli], a
    ld a, [wRWData+3]
    ld [hl], a

    call GenerateChecksum
    call DisableSRAM
    ret

LoadGame::
    call EnableSRAM

    call ValidateChecksum
    call nz, GenerateDefaultSaveGame

    ; Set hl to the write memory address.
    ld bc, sSaveData
    ld h, $00
    ld a, [wRWIndex]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc

    ; Read from SRAM
FOR N, wRWData.end - wRWData
    ld a, [hli]
    ld [wRWData+N], a
ENDR

    call DisableSRAM
    ret