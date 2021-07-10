INCLUDE "./src/include/entities.inc"
INCLUDE "./src/definitions/definitions.inc"

DEF PARTICLE_EFFECT_NO EQU 6

SECTION "Particle Effect Data", WRAM0
wParticleEffectsData::
    dstruct ParticleEffect, wParticleEffect0
    dstruct ParticleEffect, wParticleEffect1
    dstruct ParticleEffect, wParticleEffect2
    dstruct ParticleEffect, wParticleEffect3
    dstruct ParticleEffect, wParticleEffect4
    dstruct ParticleEffect, wParticleEffect5
wParticleEffectsDataEnd::

SECTION "Particle Effects Manager", ROM0
/*  Init particle Effect Data */
InitParticleEffects::
    ld hl, wParticleEffectsData
    ld b, PARTICLE_EFFECT_NO

.startLoop
    xor a
    ld [hl], a ; just make it inactive

    ld de, sizeof_ParticleEffect
    add hl, de

    dec b
    jr nz, .startLoop

.endLoop
    ret


/* Spawn particle effect, look for particle effects that are available
    Parameters:
    - d: y pos
    - e: x pos
    - b: type of effect
    - c: time before effect despawn
    Register change:
    - af
    - bc
    - de
    - hl
*/
SpawnParticleEffect::
    ld hl, wParticleEffectsData
    ld a, PARTICLE_EFFECT_NO

    push bc ; PUSH BC = type of effect and time
    push de ; PUSH DE = pos Y and X
    ld b, a
    ld de, sizeof_ParticleEffect
.startLoop
    ; b = counter, hl = particle effect address
    ld a, [hl]
    and a, a ; check if alive
    jr z, .endLoop ; not alive can end loop

    ; GO TO NEXT LOOP
    add hl, de

    dec b
    jr nz, .startLoop

    pop de ; POP de  = pos Y and X
    pop bc ; POP BC = type of effect and time
    ret ; no effects

.endLoop
    pop de ; POP de  = pos Y and X
    pop bc ; POP BC = type of effect and time

    ld a, b
    ld b, FLAG_ACTIVE
    cp a, TYPE_PARTICLE_KILL_ENEMY ; check type for animation
    jr c, .initData

    ld b, FLAG_ACTIVE | FLAG_PARTICLE_EFFECT_ANIMATION

.initData
    or a, b
    ld [hli], a ; init flags

    xor a 
    ld [hli], a ; reset UpdateTimer
    ld a, c 
    ld [hli], a 
    
    xor a
    ld [hli], a ; reset animation for now
    
    ld a, d
    ld [hli], a ; init y pos

    ld a, e
    ld [hl], a ; init x pos

    ret


/* Update particle effects */
UpdateParticleEffect::
    ld hl, wParticleEffectsData
    ld a, PARTICLE_EFFECT_NO
    ld b, a
    
.startLoop
    push bc ; PUSH BC = loop counter

    ld a, [hl]
    and a, a ; check active
    jr z, .nextLoop

    push hl ; PUSH HL = particle effect address
    ld b, a ; b = flags

    inc hl
    ld a, [hl]
    add a, PARTICLE_UPDATE_FRAME_TIME
    ld [hli], a
    jr nc, .updateSprite

    ld a, [hl]
    dec a
    jr nz, .continueUpdateParticle ; check if alive time is over

    pop hl ; POP HL = particle effect address
    xor a
    ld [hl], a ; set it inactive
    jr .nextLoop

.continueUpdateParticle
    ; b = flags

    ld [hli], a

    ld a, b
    and a, FLAG_PARTICLE_EFFECT_ANIMATION
    jr z, .updateSprite ; check if need update animation

    ; animation
    ld a, b
    and a, BIT_MASK_TYPE
.smallExplosion
    cp a, TYPE_PARTICLE_KILL_ENEMY
    jr nz, .bigExplosion

    ld b, PARTICLE_KILL_ENEMY_MAX_FRAMES
    jr .initAnimation
    
.bigExplosion
    ld b, PARTICLE_POWER_KILL_ENEMY_MAX_FRAMES
    
.initAnimation
    ; b = max frames
    ld a, [hl] 
    inc a
    cp a, b
    jr nz, .updateAnimation

    xor a
.updateAnimation
    ; a = curr anim frame
    ld [hli], a  

.updateSprite
    pop hl ; POP HL = particle effect address
    push hl ; PUSH HL = particle effect address
    call UpdateParticleEffectsShadowOAM

    pop hl ; POP HL = particle effect address

.nextLoop
    ; hl = starting address of particle 
    ld de, sizeof_ParticleEffect
    add hl, de

    pop bc ; POP BC = loop counter
    dec b
    jr nz, .startLoop

.endLoop
    ret


/*  Update particle effects for shadown oam 
    parameters:
        - hl = particle effect address
    registers changed:
        - af
        - bc
        - de
        - hl
*/
UpdateParticleEffectsShadowOAM::
    ld a, [hli] ; get flags

    inc hl ; skip update frame counter
    inc hl

    and a, BIT_MASK_TYPE ; check type

.powerDestroySprite
    cp a, TYPE_PARTICLE_DESTROY_POWER_COLLISION
    jr nz, .defaultExplosionSprite
    
    ld bc, ParticleEffectSprites.mediumExplosion
    jr .initAnimation

.defaultExplosionSprite
    ld bc, ParticleEffectSprites.smallExplosion

.initAnimation
    ld a, [hli] ; get current animation frame
    sla a ; add a
    sla a 

    add a, c
    ld c, a
    ld a, b
    adc a, 0 ; add offset to animation address: bc + a
    ld b, a

    ; check type
    ld a, [wShadowSCData]
    ld d, a
    ld a, [hli] ; pos y
    sub a, d ; decrease by screen offset
    add a, 8 ; sprite y offset = 8
    ld d, a

;    cp a, $0A
;    jr nz, .test
;
;    ld d, a
;
;.test

    ld a, [wShadowSCData + 1]
    ld e, a
    ld a, [hl] ; pos x
    sub a, e ; decrease by screen offset
    ld e, a

.initShadowOAM
    ; d = pos y, e = pos x, bc = sprite address
    ld a, [wCurrentShadowOAMPtr]  ; get the current address of shadow OAM to hl
    ld l, a
    ld h, HIGH(wShadowOAM)

    ld a, d
    ld [hli], a ; update y pos

    ld a, e
    ld [hli], a ; update x pos

    ld a, [bc]
    ld [hli], a
    inc bc

    ld a, [bc]
    ld [hli], a
    inc bc

    ld a, d
    ld [hli], a ; update y pos

    ld a, e
    add a, 8 ; offset by 8
    ld [hli], a ; update x pos

    ld a, [bc]
    ld [hli], a
    inc bc

    ld a, [bc]
    ld [hli], a

    ; update current address from hl to wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a

    ret