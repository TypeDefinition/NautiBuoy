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

.detection::
    ; ld a, [.srcPosX]
    ; ld b, a
    ; ld a, [.tgtPosX]
    ; sub a, b
    ; ld b, a

    ; ld a, [.srcPosY]
    ; ld c, a
    ; ld a, [.tgtPosY]
    ; sub a, c
    ; ld c, a