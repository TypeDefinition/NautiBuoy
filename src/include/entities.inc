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

        Direction:
        Bit 0-1: direction entity is moving/facing
        Bit 4-7 is when direction of where the entity will shoot is different with direction its facing
        Bit 4: shoot upwards
        Bit 5: shoot downwards
        Bit 6: shoot right
        Bit 7: Shoot left
    */
    struct Character
        bytes 1, Flags
        bytes 1, PosYInterpolateTarget ; the next target tile pos 
        words 1, PosY ; The 1st byte of PosY represents the integer portion. The 2nd byte of PosY represents the fractional portion.
        bytes 1, PosXInterpolateTarget ; the next target tile pos 
        words 1, PosX ; The 1st byte of PosX represents the integer portion. The 2nd byte of Posx represents the fractional portion.
        bytes 1, Direction 
        bytes 1, HP
        words 1, Velocity
        words 1, UpdateFrameCounter ; Little endian, helps keep track of frames for states. 1st half is the fraction, 2nd half is int
        bytes 1, CurrAnimationFrame
        bytes 1, CurrStateMaxAnimFrame  ; Update this based on states
        words 1, FlickerEffect ; top half byte for interger portion, bottom half byte for fractional portion
        words 1, SpawnPosition ; top half is posY, bottom half is posX
    end_struct

    /*  Flags:
        Bit 0: Inactive/Active
        Bit 1: Player/Enemy
    */
    struct Bullet
        bytes 1, Flags
        bytes 1, Direction
        words 1, Velocity
        words 1, PosY ; The 1st byte of PosY represents the integer portion. The 2nd byte of PosY represents the fractional portion.
        words 1, PosX ; The 1st byte of PosX represents the integer portion. The 2nd byte of PosX represents the fractional portion.
    end_struct

    struct PlayerCamera    
        words 1, PosY ; The 1st byte of PosY represents the integer portion. The 2nd byte of PosY represents the fractional portion.
        words 1, PosX ; The 1st byte of PosY represents the integer portion. The 2nd byte of PosX represents the fractional portion.
    end_struct

    /*  Flags:
        Bit 0: Inactive/active
        Bit 2, 3 & 4: Power Up Type
    */
    struct PowerUps
        bytes 1, Flags
        bytes 1, PosY
        bytes 1, PosX
        bytes 1, SpriteID
    end_struct

    ENDC ; ENTITIES_INC