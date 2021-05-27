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
    
    ; Collidable Tiles: A tile is assumed to be collidable if it's value is between 0 to 15 inclusive.
    DEF COLLIDABLE_TILES EQU $0F
    DEF COLLIDER_SIZE EQU $08

    ; For animation frames
    DEF PLAYER_WALK_FRAMES EQU 3

    ; states
    DEF IS_ALIVE EQU 1
    DEF IS_DEAD EQU 0

    ; Directions
    ; can use bit to compare, frees up reg A, but takes 2 cycles and 2 bytes
    ; can use cp to compare, takes reg A, but takes only 1 cycle and 1 byte
    DEF DIR_DOWN EQU %10000000
    DEF DIR_UP EQU %01000000
    DEF DIR_LEFT EQU %00100000
    DEF DIR_RIGHT EQU %00010000

    struct Character
        bytes 1, Active
        bytes 1, Tag
        bytes 1, Type
        bytes 1, PosYInterpolateTarget
        bytes 1, PosY
        bytes 1, PosYFrac
        bytes 1, PosXInterpolateTarget
        bytes 1, PosX
        bytes 1, PosXFrac
        bytes 1, Velocity
        bytes 1, Direction
        bytes 1, CurrAnimationFrame
        bytes 1, CurrStateMaxAnimFrame  ; Update this based on states
        bytes 1, HP
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