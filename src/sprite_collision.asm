SECTION "Collision Check", ROM0
/*  Collision detection using AABB.
    IMPORTANT: This function is working under the assumption
    that the collider size will be something reasonable where
    srcColSize + tgtColSize will not cause an overflow.
    
    Params:
    @ b: Source PosY
    @ c: Source PosX
    @ d: Target PosY
    @ e: Target PosX
    @ h: Source Collider Size
    @ l: Target Collider Size
    Return:
    @ a: False (0)/True (1) */
SpriteCollisionCheck::
    ; Save the register values.
    push bc
    push de
    push hl

    ; h = Source Collider Size + Target Collider Size
    ld a, h
    add a, l
    ld h, a

    ; Y Axis
    ; srcPosY - tgtPosY
    ld a, b
    sub a, d
    ; If srcPos < tgtPos, an underflow will happen.
    jr nc, .noUnderflowY
    ; Negate the value via 2's complement.
    xor a, $FF
    add a, $01
.noUnderflowY
    ; If ((srcPos - tgtPos) >= srcColliderSize + tgtColliderSize): False
    cp a, h
    jp nc, .false

    ; X Axis
    ; srcPosX - tgtPosX
    ld a, c
    sub a, e
    ; If srcPos < tgtPos, an underflow will happen.
    jr nc, .noUnderflowX
    ; Negate the value via 2's complement.
    xor a, $FF
    add a, $01
.noUnderflowX
    ; If ((srcPos - tgtPos) >= srcColliderSize + tgtColliderSize): False
    cp a, h
    jp nc, .false

.true
    ld a, $01
    jr .end
.false
    xor a
.end
    ; Restore the register values.
    pop hl
    pop de
    pop bc

    ret