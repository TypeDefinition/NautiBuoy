INCLUDE "./src/include/hardware.inc"

SECTION "SFX", ROM0
PlayerShootSFX::
    ; Channel 1
    ld a, %01000010
    ld [rNR10], a ; Sweep Register
    
    ld a, %01001100 
    ld [rNR11], a ; Set Sound Length/Wave Pattern Duty

    ld a, %11111010
    ld [rNR12], a ; Volume Envelope

    ld a, $FF
    ld [rNR13], a ; Frequency Lo

    ld a, %11000011
    ld [rNR14], a ; Frequency Hi

    ret