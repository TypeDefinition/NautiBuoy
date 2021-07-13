INCLUDE "./src/include/hardware.inc"

SECTION "SFX", ROM0
ExplosionSFX::
    ; Channel 1
    ld a, %11110010
    ld [rNR10], a ; Sweep Register
    
    ld a, %11000000
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110010
    ld [rNR12], a ; Volume Envelope

    ld a, $9F
    ld [rNR13], a ; Frequency Lo

    ld a, %11000010
    ld [rNR14], a ; Frequency Hi

    ret

PlayerShootSFX::
    ; Channel 1
    ld a, %01001100
    ld [rNR10], a ; Sweep Register
    
    ld a, %10100100
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110110
    ld [rNR12], a ; Volume Envelope

    ld a, $EE
    ld [rNR13], a ; Frequency Lo

    ld a, %11000101
    ld [rNR14], a ; Frequency Hi

    ret

TakePowerUpSFX::
    ; Channel 1
    ld a, %01011101
    ld [rNR10], a ; Sweep Register
    
    ld a, %01001100 
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110010
    ld [rNR12], a ; Volume Envelope

    ld a, $FF
    ld [rNR13], a ; Frequency Lo

    ld a, %11000111
    ld [rNR14], a ; Frequency Hi

    ret

PlayerDeathSFX::
    ; Channel 1
    ld a, %01100110
    ld [rNR10], a ; Sweep Register
    
    ld a, %01001100 
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110010
    ld [rNR12], a ; Volume Envelope

    ld a, $11
    ld [rNR13], a ; Frequency Lo

    ld a, %11000010
    ld [rNR14], a ; Frequency Hi

    ret

EnemyDeathSFX::
    ; Channel 1
    ld a, %00100111
    ld [rNR10], a ; Sweep Register
    
    ld a, %01001100 
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110010
    ld [rNR12], a ; Volume Envelope

    ld a, $44
    ld [rNR13], a ; Frequency Lo

    ld a, %11000110
    ld [rNR14], a ; Frequency Hi

    ret

PlaceholderSFX0::
    ; Channel 1
    ld a, %00000111
    ld [rNR10], a ; Sweep Register
    
    ld a, %01001100 
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11110010
    ld [rNR12], a ; Volume Envelope

    ld a, $FF
    ld [rNR13], a ; Frequency Lo

    ld a, %11000110
    ld [rNR14], a ; Frequency Hi

    ret