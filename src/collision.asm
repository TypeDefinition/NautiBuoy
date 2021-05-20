SECTION "Collision Args", WRAM0
wCollisionArgs::
.srcPosX::
    ds 1
.srcPosY::
    ds 1
.srcColSize::
    ds 1
.tgtPosX::
    ds 1
.tgtPosY::
    ds 1
.tgtColSize::
    ds 1
.result::
    ds 1

SECTION "Collision Check", ROM0
CollisionCheck::
/*  Collision detection using AABB.
    IMPORTANT: This function is working under the assumption
    that the collider size will be something reasonable where
    srcColSize + tgtColSize will not cause an overflow.
    
    Registers Used: a, b, c, d, f */

    ; Save the register values.
    push af
    push bc
    push de

    ; Set result to 0.
    xor a
    ld [wCollisionArgs.result], a

    ; srcPosX - tgtPosX
    ld a, [wCollisionArgs.srcPosX]
    ld b, a
    ld a, [wCollisionArgs.tgtPosX]
    sub a, b

    ; If tgtPosX < srcPosX, an underflow will happen.
    jr nc, .noUnderflowX
    ; Negate the value via 2's complement.
    xor a, $FF
    add a, $01
.noUnderflowX

    ld b, a ; Register b contains Abs(srcPosX - tgtPosX)

    ; srcPosY - tgtPosY
    ld a, [wCollisionArgs.srcPosY]
    ld c, a
    ld a, [wCollisionArgs.tgtPosY]
    sub a, c

    ; If tgtPosY < srcPosY, an underflow will happen.
    jr nc, .noUnderflowY
    ; Negate the value via 2's complement.
    xor a, $FF
    add a, $01
.noUnderflowY

    ld c, a ; Register c contains Abs(srcPosY - tgtPosY)

    ; srcColSize + tgtColSize
    ld a, [wCollisionArgs.srcColSize]
    ld d, a
    ld a, [wCollisionArgs.tgtColSize]
    add a, d ; Register a contains srcColSize + tgtColSize

    ; Is (srcColSize + tgtColSize) > Abs(srcPosX - tgtPosX)?
    cp a, b
    jr c, .exit

    ; Is (srcColSize + tgtColSize) > Abs(srcPosY - tgtPosY)?
    cp a, c
    jr c, .exit
    ld a, $01
    ld [wCollisionArgs.result], a

.exit
    ; Restore the register values.
    pop de
    pop bc
    pop af

    ret