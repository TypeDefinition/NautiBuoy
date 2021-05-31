
INCLUDE "./src/include/definitions.inc"


/*  Stores the data on where and what type of enemy should be place on the level 
    Data for enemies:
        - Enemy type
        - Grid pos y * 8 pixels
        - Grid pos x * 8 pixels
        - Direction maybe?
        - health
        - velocity
*/
SECTION "Enemies Level Data", ROMX, BANK[2]
LevelOneEnemyData::
    db 1 ; number of enemies in level
.enemyOne
    db TYPE_ENEMYA | FLAG_ENEMY | FLAG_ACTIVE   
    db 10 * 8 ; y 
    db 6 * 8 ; x
    db DIR_UP
    db ENEMY_TYPEA_HEALTH
    dw VELOCITY_SLOW
.endLevelOneEnemyData::
