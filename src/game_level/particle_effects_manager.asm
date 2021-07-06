INCLUDE "./src/include/entities.inc"
INCLUDE "./src/include/definitions.inc"

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
UpdateParticleEffect::
    ; update its update_frame thing, 
    ; once it reaches a certain time period destroy it
    ; check its type and update accordingly

    ; render it properly based on the animation
    ; if it does not have animation check its flags?
    ret