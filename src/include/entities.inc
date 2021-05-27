INCLUDE "./src/include/structs.inc"

    IF !DEF(ENTITIES_INC)
DEF ENTITIES_INC EQU 1

    struct Character
        bytes 1, Active
        bytes 1, Flags
        bytes 1, PosYInterpolateTarget
        bytes 1, PosY
        bytes 1, PosYFrac
        bytes 1, PosXInterpolateTarget
        bytes 1, PosX
        bytes 1, PosXFrac
        bytes 1, Velocity
        bytes 1, Direction
        bytes 1, HP
        bytes 1, CurrAnimationFrame
        bytes 1, CurrStateMaxAnimFrame  ; Update this based on states
    end_struct

    struct Bullet
        bytes 1, Active
        bytes 1, PosY
        bytes 1, PosX
        bytes 1, Velocity
        bytes 1, Direction
        bytes 1, Tag
        bytes 1, Type
        bytes 1, Damage
    end_struct

    ENDC ; ENTITIES_INC