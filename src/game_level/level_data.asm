
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
Stage0PlayerData::
    db 20 * 8 ; spawn y pos
    db 3 * 8 ; spawn x pos
    db 3 ; starting health for level

Stage1PlayerData::
    db 21 * 8 ; spawn y pos
    db 5 * 8 ; spawn x pos
    db 3 ; starting health for level

Stage2PlayerData::
    db 20 * 8 ; spawn y pos
    db 3 * 8 ; spawn x pos
    db 3 ; starting health for level

Stage3PlayerData::
    db 20 * 8 ; spawn y pos
    db 3 * 8 ; spawn x pos
    db 3 ; starting health for level

Stage4PlayerData::
    db 20 * 8 ; spawn y pos
    db 3 * 8 ; spawn x pos
    db 3 ; starting health for level


Stage0EnemyData::
    db 5 ; number of enemies in level
.enemyOne ; top in the bush
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 7 * 8 ; y 
    db 10 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyTwo ; on the right, not moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 12 * 8 ; y 
    db 17 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyThree ; very right, moving up and down
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 12 * 8 ; y 
    db 22 * 8 ; x
    db DIR_UP
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyFour ; at the water area
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 2 * 8 ; y 
    db 24 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyFive ; ON THE very top, moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 2 * 8 ; y 
    db 2 * 8 ; x
    db DIR_LEFT
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.endStage0EnemyData:

Stage1EnemyData::
    db 7 ; number of enemies in level
.enemyOne ; left at the start
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 12 * 8 ; y 
    db 2 * 8 ; x
    db DIR_RIGHT
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyTwo ; turtle in the middle
    db TYPE_ENEMYB | FLAG_ENEMY | FLAG_ACTIVE   
    db 15 * 8 ; y 
    db 15 * 8 ; x
    db DIR_RIGHT
    db ENEMY_TYPEB_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEB_WALK_MAX_FRAMES
.enemyThree ; very top
    db TYPE_ENEMYB | FLAG_ENEMY | FLAG_ACTIVE
    db 4 * 8 ; y 
    db 2 * 8 ; x
    db DIR_RIGHT
    db ENEMY_TYPEB_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEB_WALK_MAX_FRAMES
.enemyFour ; squid, little bit on the top right, not moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 7 * 8 ; y 
    db 21 * 8 ; x
    db DIR_DOWN
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemyFive ; squid, little bit on the top, moving
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 2 * 8 ; y 
    db 16 * 8 ; x
    db DIR_RIGHT
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.enemySix ; turtle, on the right corner
    db TYPE_ENEMYB | FLAG_ENEMY | FLAG_ACTIVE   
    db 12 * 8 ; y 
    db 26 * 8 ; x
    db DIR_UP
    db ENEMY_TYPEB_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEB_WALK_MAX_FRAMES
.enemySeven ; squid, bottom right corner
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 21 * 8 ; y 
    db 19 * 8 ; x
    db DIR_UP
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_VSLOW ; cpu allocate and auto store in little endian
    db ENEMY_TYPEA_WALK_FRAMES
.endStage1EnemyData:

Stage2EnemyData::
    db 1 ; number of enemies in level
.endStage2EnemyData:

Stage3EnemyData::
    db 1 ; number of enemies in level
.endStage3EnemyData:

Stage4EnemyData::
    db 1 ; number of enemies in level
.endStage4EnemyData:

Stage5EnemyData::
    db 1 ; number of enemies in level
.endStage5EnemyData:

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

/* Powerup information and data for level 1 */
Level0PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 15 * 8 ; y 
    db 9 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpTwo
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 2 * 8 ; y 
    db 17 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpThree
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 20 * 8 ; y 
    db 24 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.powerUpFour
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 3 * 8 ; y 
    db 9 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.endPowerUp0

Level1PowerUpData::
    db 6 ; number of powerups in level
.powerUpOne
    db TYPE_DAMAGE_POWERUP | FLAG_ACTIVE
    db 20 * 8 ; y 
    db 8 * 8 ; x
    db DAMAGE_POWERUP_SPRITE_ID
.powerUpTwo ; at the very top
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 3 * 8 ; y 
    db 10 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.powerUpThree ; in the plants
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 9 * 8 ; y 
    db 4 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpFour ; next to the turtle in the middle
    db TYPE_DAMAGE_POWERUP | FLAG_ACTIVE
    db 14 * 8 ; y 
    db 21 * 8 ; x
    db DAMAGE_POWERUP_SPRITE_ID
.powerUpFive ; at the top near the water
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 5 * 8 ; y 
    db 15 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.powerUpSix ; at the very right
    db TYPE_TIME_POWERUP | FLAG_ACTIVE
    db 18 * 8 ; y 
    db 26 * 8 ; x
    db TIME_POWERUP_SPRITE_ID
.endPowerUp1

Level2PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 15 * 8 ; y 
    db 9 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.endPowerUp2

Level3PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 20 * 8 ; y 
    db 7 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.endPowerUp3

Level4PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 15 * 8 ; y 
    db 9 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.endPowerUp4

Level5PowerUpData::
    db 4 ; number of powerups in level
.powerUpOne
    db TYPE_HEALTH_POWERUP | FLAG_ACTIVE
    db 15 * 8 ; y 
    db 9 * 8 ; x
    db HEART_POWERUP_SPRITE_ID
.endPowerUp5

