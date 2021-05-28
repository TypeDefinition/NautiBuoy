INCLUDE "./src/include/structs.inc"

    IF !DEF(ENTITIES_INC)
DEF ENTITIES_INC EQU 1

    /*  Flags:
        Bit 0: Inactive/Active
        Bit 1: Player/Enemy
        Bit 2, 3 & 4: Power Up Type / Enemy Type
            000 - Power Up A / Enemy A
            001 - Power Up B / Enemy B
            010 - Power Up C / Enemy C
            011 - Power Up D / Enemy D
            100 - Power Up E / Enemy E
            101 - Power Up F / Enemy F
            110 - Power Up G / Enemy G
            111 - Power Up H / Enemy H
        Bit 5: TBC
        Bit 6: TBC
        Bit 7: TBC
    */
    struct Character
        bytes 1, Flags
        bytes 1, PosYInterpolateTarget
        bytes 1, PosY
        bytes 1, PosYFrac
        bytes 1, PosXInterpolateTarget
        bytes 1, PosX
        bytes 1, PosXFrac
        bytes 1, Direction
        bytes 1, HP
        bytes 1, CurrAnimationFrame
        bytes 1, CurrStateMaxAnimFrame  ; Update this based on states
    end_struct

    /*  Flags:
        Bit 0: Inactive/Active
        Bit 1: Player/Enemy
    */
    struct Bullet
        bytes 1, Flags
        bytes 1, PosY
        bytes 1, PosYFrac
        bytes 1, PosX
        bytes 1, PosXFrac
        bytes 1, Direction
    end_struct

    ENDC ; ENTITIES_INC