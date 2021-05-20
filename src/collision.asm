SECTION "Collision", ROM0
Collision::
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

/*  Collision detection using AABB.
    IMPORTANT: This function is working under the assumption
    that the collider size will be something reasonable where
    srcColSize + tgtColSize will not cause an overflow.
    
    Registers Used: a, b, c, d */
.detection::
    ; Set result to 0.
    xor a
    ld [.result], a

    ; srcPosX - tgtPosX
    ld a, [.srcPosX]
    ld b, a
    ld a, [.tgtPosX]
    sub a, b

    ; If tgtPosX > srcPosX, an underflow will happen.
    jr nc, .noUnderflowX
    ld [Negate.src], a
    call Negate.calculate
    ld a, [Negate.result]
.noUnderflowX

    ld b, a ; Register b contains Abs(srcPosX - tgtPosX)

    ; srcPosY - tgtPosY
    ld a, [.srcPosY]
    ld c, a
    ld a, [.tgtPosY]
    sub a, c

    ; If tgtPosY > srcPosY, an underflow will happen.
    jr nc, .noUnderflowY
    ld [Negate.src], a
    call Negate.calculate
    ld a, [Negate.result]
.noUnderflowY

    ld c, a ; Register c contains Abs(srcPosY - tgtPosY)

    ; srcColSize + tgtColSize
    ld a, [.srcColSize]
    ld d, a
    ld a, [.tgtColSize]
    add a, d ; Register a contains srcColSize + tgtColSize

    ; Is (srcColSize + tgtColSize) > Abs(srcPosX - tgtPosX)?
    cp a, b
    jr c, .exit

    ; Is (srcColSize + tgtColSize) > Abs(srcPosY - tgtPosY)?
    cp a, c
    jr c, .exit
    ld a, $01
    ld [.result], a

.exit
    ret