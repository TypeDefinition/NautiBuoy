INCLUDE "./src/structs.inc"

    IF !DEF(GS_INC)
DEF GS_INC EQU 1

    struct Player
        bytes 1, IsAlive
        bytes 1, XPos
        bytes 1, YPos
        bytes 1, ColliderSize
        bytes 1, Direction
        bytes 4, MetaSpriteID
    end_struct

    ENDC ; GS_INC