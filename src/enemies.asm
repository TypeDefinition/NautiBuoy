INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/structs.inc"
INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"


SECTION "Enemies Data", WRAM0
EnemiesData::
    dstruct Character, wEnemy0
    dstruct Character, wEnemy1
    dstruct Character, wEnemy2
    dstruct Character, wEnemy3
    dstruct Character, wEnemy4
    dstruct Character, wEnemy5
    dstruct Character, wEnemy6
    dstruct Character, wEnemy7


; just make it shoot/attack first?
; and make it so if it got hit by bullet gets destroyed
; and can be rendered
; and aninmated
; make it be able to shoot first

; if got hit by bullet, bullet should check whether hit enemy
; if enemy has been hit, make it dead
; should no longer be rendered

SECTION "Enemies", ROM0
UpdateAllEnemies::
    ld hl, EnemiesData

    ; TODO:: make update loop
    ; check enemies type and then call the correct update

.startOfLoop
    ld a, [hl]
    bit BIT_FLAG_ACTIVE, a ; check if alive
    jr nz, .updateEnemy ; if not alive, redo loop

.updateEnemy
    and a, BIT_MASK_TYPE
    
.enemyTypeA
    cp a, TYPE_ENEMYA
    jr nz, .enemyTypeB
    call UpdateEnemyA ; call correct update for enemy
.enemyTypeB
    call UpdateEnemyB ; call correct update for enemy
    
.endOfLoop
    ret


/*  Update for enemy type A 
    Parameters:
    - hl: the starting address of the enemy
*/
UpdateEnemyA:
    ret

/* Update for enemy type B */
UpdateEnemyB:
    ret


/* Call this when enemy has been hit */
HitEnemy::
    ; should be passing in the address of the enemy here
    ; should also be passing the amount of damage dealth
    ; deduct health
    ; if health < 0, mens dead, set the variable to dead
    ret
