INCLUDE "./src/definitions/definitions.inc"
INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

/*  The save data consists of a 4-Byte validation string
    to check for data corruption, followed by 4 bytes for each
    game stage.

    The game stage save data consists of the follwing:
    Stage Locked/Unlock - 1 Byte (Locked = 0, Unlocked & Not Cleared = 1, Unlocked & Cleared = 2)
    Best Time Left - 2 Bytes
    Number of Stars - 1 Byte */
SECTION "Save Game SRAM", SRAM
sChecksum:
    ds 2 ; Validation Checksum
sSaveData:
    ds 4*MAX_STAGES ; Save data for stages.
.end
; When a stage is complete, the save data of the next stage will be written to to unlock it.
; Rather than check for the last stage, and not write to a non-existent next stage, I'll just add 4 bytes here that can have anything written to it and be ignored.
sEndBuffer:
    ds 4
.end

SECTION "Save Game WRAM", WRAM0
wRWIndex::
    ds 1
wRWBuffer::
    ds 4
.end::

SECTION "Save Game", ROM0
EnableSRAM:
    ; RAM Enable
    ld a, $0A
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
    ld a, d
    ld [sChecksum], a
    ld a, e
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

GenerateDefaultSave:
    ; Lock all stages except stage 0.
    ld a, (sSaveData.end - sSaveData)
    ld b, a
    ld hl, sSaveData
    xor a
.loop
    ld [hli], a
    dec b
    jr nz, .loop
    
    ld a, STAGE_UNLOCKED_NOT_CLEARED
    ld [sSaveData], a

    ; TEMP UNLOCK BOSS
    ld a, STAGE_UNLOCKED_NOT_CLEARED
    ld [sSaveData+5*4], a

    call GenerateChecksum
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
    ld a, [wRWBuffer]
    ld [hli], a
    ld a, [wRWBuffer+1]
    ld [hli], a
    ld a, [wRWBuffer+2]
    ld [hli], a
    ld a, [wRWBuffer+3]
    ld [hl], a

    call GenerateChecksum
    call DisableSRAM
    ret

LoadGame::
    call EnableSRAM

    call ValidateChecksum
    call nz, GenerateDefaultSave

    ; Set hl to the write memory address.
    ld bc, sSaveData
    ld h, $00
    ld a, [wRWIndex]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc

    ; Read from SRAM
FOR N, wRWBuffer.end - wRWBuffer
    ld a, [hli]
    ld [wRWBuffer+N], a
ENDR

    call DisableSRAM
    ret

ResetGame::
    call EnableSRAM
    call nz, GenerateDefaultSave
    call DisableSRAM
    ret

UnlockStage::
    call LoadGame

    ld a, [wRWBuffer]
    cp a, STAGE_LOCKED
    jr nz, .end ; If the level is already unlocked, do nothing.

    ld a, STAGE_UNLOCKED_NOT_CLEARED
    ld [wRWBuffer], a
    xor a
    ld [wRWBuffer+1], a
    ld [wRWBuffer+2], a
    ld [wRWBuffer+3], a

    call SaveGame
.end
    ret