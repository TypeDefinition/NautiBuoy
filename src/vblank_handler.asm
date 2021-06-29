INCLUDE "./src/include/hardware.inc"

SECTION "VBlank Data", WRAM0
wShadowSCData::
    ds 2 ; y pos, then x pos

SECTION "VBlank Handler", ROM0
VBlankHandler::
    ; Enable Sprite Rendering
    ldh a, [hLCDC]
    ldh [rLCDC], a
    
    call hOAMDMA ; Update OAM

    ; update registers for camera
    ld a, [wShadowSCData]
    ld [rSCY], a
    ld a, [wShadowSCData + 1]
    ld [rSCX], a 

    ; get back old state
    pop hl
    pop de
    pop bc

    ; TODO: Clean this up. Very temp code.
    ldh a, [hVBlankFlag]
	and a
	jr z, .lagFrame
	xor a
	ldh [hVBlankFlag], a
    pop af
.lagFrame

    pop af

    reti