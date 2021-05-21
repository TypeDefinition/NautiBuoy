INCLUDE "./src/structs.inc"

    IF !DEF(ENTITIES_INC)
DEF ENTITIES_INC EQU 1

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

    ; For animation frames
    DEF PLAYER_WALK_FRAMES EQU 2

    struct Character
        bytes 1, Active
        bytes 1, Tag
        bytes 1, Type
        bytes 1, PosX
        bytes 1, PosY
        bytes 1, Direction
        bytes 1, Velocity
        bytes 1, ColSize
        bytes 1, CurrAnimationFrame
        bytes 1, CurrStateMaxAnimFrame  ; Update this based on states
        bytes 1, HP
    end_struct

    struct Bullet
        bytes 1, Active
        bytes 1, Tag
        bytes 1, Type
        bytes 1, PosX
        bytes 1, PosY
        bytes 1, Direction
        bytes 1, Velocity
        bytes 1, SpriteID
        bytes 1, Damage
    end_struct

    ENDC ; ENTITIES_INC