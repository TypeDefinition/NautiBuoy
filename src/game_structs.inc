INCLUDE "./src/structs.inc"

    IF !DEF(GS_INC)
DEF GS_INC EQU 1

    ; Tags
    DEF TAG_PLAYER EQU 0
    DEF TAG_ENEMY EQU 1

    ; Types
    DEF TYPE_PLAYER EQU 0
    
    DEF TYPE_ENEMY0 EQU 1
    DEF TYPE_ENEMY1 EQU 2
    DEF TYPE_ENEMY2 EQU 3
    
    DEF TYPE_BULLET1 EQU 4
    DEF TYPE_BULLET2 EQU 5
    DEF TYPE_BULLET3 EQU 6

    struct Character
        bytes 1, Active
        bytes 1, Tag
        bytes 1, Type
        bytes 1, XPos
        bytes 1, YPos
        bytes 1, Direction
        bytes 1, ColliderSize
        bytes 4, SpriteIDs
        bytes 1, HP
    end_struct

    struct Bullet
        bytes 1, Active
        bytes 1, Tag
        bytes 1, Type
        bytes 1, XPos
        bytes 1, YPos
        bytes 1, Direction
        bytes 1, SpriteID
        bytes 1, Damage
    end_struct

    struct Player
        bytes 1, IsAlive
        bytes 1, XPos
        bytes 1, YPos
        bytes 1, ColliderSize
        bytes 1, Direction
        bytes 4, MetaSpriteID
    end_struct

    ENDC ; GS_INC