INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"

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
    add hl, bc

    dec b
    jr nz, .startLoop

.endLoop
    ret


/* Spawn particle effect, look for particle effects that are available
    Parameters:
    - d: y pos
    - e: x pos
    - b: type of effect
    - c: time before effect dispawn
    Register change:
    - af
    - bc
    - de
    - hl
*/
SpawnParticleEffect::
    ld hl, wParticleEffectsData
    ld a, PARTICLE_EFFECT_NO

.startLoop
    ld a, [hl]
    and a, a ; check if alive
    ;jr z, .end ; not alive can end loop

    ; GO TO NEXT LOOP
    
.end
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
    
.startLoop
    ld a, [hl]
    and a, a ; check active
    ret z ; TODO:: GO TO NEXT LOOP
    ;jr z, .nextLoop

    push hl ; PUSH HL = particle effect address

    ld b, a ; b = flags

    inc hl
    ld a, [hl]
    add a, TILE_UPDATE_FRAME_TIME
    ld [hli], a
    jr nc, .updateSprite

    ld a, [hl]
    dec a
    jr nz, .continueUpdateParticle

    ; set it inactive
    pop hl ; POP HL = particle effect address
    xor a 
    ld [hl], a
    ret
    ;jr .nextLoop

.continueUpdateParticle
    ld [hli], a

    ld a, b
    and a, FLAG_PARTICLE_EFFECT_ANIMATION
    jr z, .updateSprite ; check if need update animation

    ; animation
    ld a, [hl] 
    inc a
    ld [hli], a  ; make sure to clamp the animation

.updateSprite
    pop hl
    push hl
    call UpdateParticleEffectsShadowOAM

    pop hl ; POP HL = particle effect address

.nextLoop
    ; add to hl to go next

    ;jr .startLoop

.endLoop
    ret

/*  Update particle effects for shadown oam */
UpdateParticleEffectsShadowOAM::
    ; check got animation or not

    ; check type 
    ; TODO:: IF GOT ANIMATION, later need add by the offset
    inc hl ; skip flags
    inc hl ; skip 
    inc hl

    ; use flags to check type
    ld bc, ParticleEffectSprites.smallExplosion

    ; add animation here
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

    cp a, $0A
    jr nz, .test

    ld d, a

.test

    ld a, [wShadowSCData + 1]
    ld e, a
    ld a, [hl] ; pos x
    sub a, e ; decrease by screen offset
    ld e, a

    ; get the current address of shadow OAM to hl
    ld a, [wCurrentShadowOAMPtr]
    ld l, a
    ld h, HIGH(wShadowOAM)

    ; TODO:: INIT THE SHADOW OAM STUFF PROPERLY
    ld a, d
    ld [hli], a ; update y pos

    ld a, e
    ld [hli], a ; update x pos

    ld a, $6E
    ld [hli], a

    ld a, OAMF_PAL0
    ld [hli], a

    ld a, d
    ld [hli], a ; update y pos

    ld a, e
    add a, 8 ; offset by 8
    ld [hli], a ; update x pos

    ld a, $70
    ld [hli], a

    ld a, OAMF_PAL0
    ld [hli], a

    ; update current address from hl to wCurrentShadowOAMPtr
    ld a, l
    ld [wCurrentShadowOAMPtr], a

    ret