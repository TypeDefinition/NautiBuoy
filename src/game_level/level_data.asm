
INCLUDE "./src/definitions/definitions.inc"


/*  Stores the data on where and what type of enemy should be place on the level 
    Data for enemies:
        - Enemy type
        - Grid pos y * 8 pixels
        - Grid pos x * 8 pixels
        - Direction of movement and shoot direction
        - health
        - velocity
        - initial max animation frame
*/
SECTION "Level Data", ROMX
Stage0EnemyData::
    db 5 ; number of enemies in level
.enemyOne ; top in the bush
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 16 * 8 ; y 
    db 8 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyTwo ; on the left, not moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 23 * 8 ; y 
    db 17 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyThree ; very left, moving up and down
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 21 * 8 ; y 
    db 22 * 8 ; x
    db DIR_UP
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyFour ; at the water area
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 12 * 8 ; y 
    db 24 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyFive ; ON THE very top, moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 11 * 8 ; y 
    db 2 * 8 ; x
    db DIR_LEFT
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.endStage0EnemyData:

/* Powerup information and data for level 1 */
Level0PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 24 * 8 ; y 
    db 8 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpTwo
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 11 * 8 ; y 
    db 17 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpThree
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 29 * 8 ; y 
    db 24 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.powerUpFour
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 12 * 8 ; y 
    db 9 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.endPowerUp0

/* Final level data */
StageXXEnemyData::
    db 1 ; number of enemies in level
.enemyOne
    db TYPE_ENEMY_BOSS | FLAG_ENEMY | FLAG_ACTIVE   
    db 11 * 8 ; y 
    db 12 * 8 ; x
    db DIR_LEFT | SHOOT_DIR_DOWN | SHOOT_DIR_RIGHT | SHOOT_DIR_UP | SHOOT_DIR_LEFT
    db ENEMY_BOSS_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.endStageXXEnemyData:
