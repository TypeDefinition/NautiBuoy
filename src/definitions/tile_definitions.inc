; Tile Size
DEF TILE_SIZE EQU $08

; Tile Collision
DEF CHARACTER_COLLIDABLE_TILES EQU $0F ; Collidable Tiles: A tile is assumed to be collidable by characters if it's value is less than 16.
DEF BULLET_COLLIDABLE_TILES EQU $09 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 9.
DEF BULLET_DESTRUCTIBLE_TILES EQU $01 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 1.
DEF POWER_BULLET_DESTRUCTIBLE_TILES EQU $02 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 2.

; Tile Values
DEF EMPTY_TILE_VALUE EQU $20
DEF CURSOR_TILE_VALUE EQU $10
DEF EMPTY_STAR_TILE_VALUE EQU $11
DEF FILLED_STAR_TILE_VALUE EQU $12
DEF TORPEDO_POWERUP_TILE_VALUE EQU $1A
DEF SPEED_POWERUP_TILE_VALUE EQU $1B
DEF INVINCIBILITY_POWERUP_TILE_VALUE EQU $1C