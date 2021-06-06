    IF !DEF(DEFINITIONS_INC)
DEF DEFINITIONS_INC EQU 1

; Types
DEF TYPE_PLAYER EQU 0

; Enemy type
DEF TYPE_ENEMYA EQU 0 ; bit 2, 3 & 4, %000 000 00
DEF TYPE_ENEMYB EQU 4 ; bit 2, 3 & 4, %000 001 00
DEF TYPE_ENEMYC EQU 8 ; bit 2, 3 & 4, %000 010 00

DEF TYPE_BULLET1 EQU 4
DEF TYPE_BULLET2 EQU 5
DEF TYPE_BULLET3 EQU 6

; Collider Size
DEF PLAYER_COLLIDER_SIZE EQU $08
DEF ENEMY_COLLIDER_SIZE EQU $00
DEF BULLET_COLLIDER_SIZE EQU $02

; States
DEF FLAG_INACTIVE EQU $00
DEF FLAG_ACTIVE EQU $01

DEF FLAG_PLAYER EQU $00 ; bit 1, %0000 00 0 0
DEF FLAG_ENEMY EQU $02  ; bit 1, %0000 00 1 0

; definitions for the bit flags
DEF BIT_FLAG_ACTIVE EQU $0 ; 0 bit
DEF BIT_FLAG_PLAYER EQU $1 ; 01 bit

DEF BIT_MASK_TYPE EQU %00011100 ; to do bit masking for power up type/enemy type


; Directions
; can use cp to compare, takes reg A, but takes only 1 cycle and 1 byte
DEF DIR_UP EQU 0
DEF DIR_DOWN EQU 1
DEF DIR_LEFT EQU 2
DEF DIR_RIGHT EQU 3
DEF DIR_BIT_MASK EQU %00000011

; Shoot directions, use bit to compare
; for when the direction of shooting is different with direction entity is facing
DEF SHOOT_DIR_UP EQU %00010000 ; bit 4 true
DEF SHOOT_DIR_DOWN EQU %00100000 ; bit 5 tru
DEF SHOOT_DIR_LEFT EQU %01000000 ; bit 6 true
DEF SHOOT_DIR_RIGHT EQU %10000000 ; bit 7 true

; Tiles
DEF TILE_SIZE EQU $08
DEF EMPTY_TILE EQU $20
DEF CHARACTER_COLLIDABLE_TILES EQU $10 ; Collidable Tiles: A tile is assumed to be collidable by characters if it's value is less than 16.
DEF BULLET_COLLIDABLE_TILES EQU $09 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 9.
DEF BULLET_DESTRUCTIBLE_TILES EQU $01 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 1.
DEF BOMB_DESTRUCTIBLE_TILES EQU $02 ; Collidable Tiles: A tile is assumed to be collidable by bullets if it's value is less than 2.

; Velocity
DEF VELOCITY_VSLOW EQU $0040
DEF VELOCITY_SLOW EQU $0080
DEF VELOCITY_NORMAL EQU $0100
DEF VELOCITY_FAST EQU $0200
DEF VELOCITY_VFAST EQU $0400

; For Animation Frames
DEF PLAYER_WALK_FRAMES EQU 3

; PLAYER DATA
DEF PLAYER_BULLET_NUMBER EQU 3

; Enemy DATA
DEF ENEMY_TYPEA_BULLET_NUM EQU 1
DEF ENEMY_TYPEA_HEALTH EQU 30
DEF ENEMY_TYPEA_WALK_FRAMES EQU 2
DEF ENEMY_TYPEA_ATTACK_ANIM_MAX_FRAMES EQU 3
DEF ENEMY_TYPEA_ANIMATION_UPDATE_SPEED EQU $08 ; 16, takes 16 frames for next animation frame, abt 4fps
DEF ENEMY_TYPEA_ATTACK_STATE_FRAME EQU 7 ; frame to start playing attack anim
DEF ENEMY_TYPEA_ATTACK_FRAME EQU 8 ; frame to shoot
DEF ENEMY_TYPEA_ATTACK_ANIM_OFFSET EQU 12 ; offset from normal anim data to attack anim data

; Enemy B Data
DEF ENEMY_TYPEB_ANIMATION_UPDATE EQU $10
; attack duration = ENEMY_TYPEB_ATTACK_STATE_STOP_FRAME - ENEMY_TYPEB_ATTACK_STATE_FRAME
; as long frame >= ENEMY_TYPEB_ATTACK_STATE_FRAME, its attack state
DEF ENEMY_TYPEB_ATTACK_STATE_FRAME EQU 3 ; frame to go attack state after enemy senses player on same line
DEF ENEMY_TYPEB_ATTACK_STATE_STOP_FRAME EQU 17; frame to stop attack state. 
DEF ENEMY_TYPEB_REST_STATE_FRAME EQU 3 ; number of frames to rest after attack state
DEF ENEMY_TYPEB_WALK_MAX_FRAMES EQU 2
DEF ENEMY_TYPEB_ATTACK_ANIM_MAX_FRAMES EQU 4


    ENDC ; DEFINITIONS_INC
