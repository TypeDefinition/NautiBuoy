INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

; $0100 - $0103: Entry Point
SECTION "Game Level", ROM0[$0100]
LoadGameLevel::
    di ; Disable Interrupts

    ; Set STAT interrupt flags.
    ld a, VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a

    ; Reset hVBlankFlag before waiting for VBlank.
    xor a
    ld [hVBlankFlag], a

    call LCDOff

    ; Reset OAM & Shadow OAM
    call ResetOAM
    mem_set_small wShadowOAM, 0, wShadowOAM.end - wShadowOAM
    xor a
    ld [wCurrentShadowOAMPtr], a

    ; Copy background tile data into VRAM.
    set_romx_bank BANK(BGWindowTiles)
    mem_copy BGWindowTiles, _VRAM9000, BGWindowTiles.end-BGWindowTiles

    set_romx_bank BANK(PlayerSprite)
    mem_copy PlayerSprite, _VRAM8000, PlayerSprite.end-PlayerSprite

    set_romx_bank BANK(EnemyTurtleSprite)
    mem_copy EnemyTurtleSprite, _VRAM8000 + PlayerSprite.end - PlayerSprite, EnemyTurtleSprite.end - EnemyTurtleSprite
    
    set_romx_bank BANK(EnemyTurretSprite)
    mem_copy EnemyTurretSprite, _VRAM8000 + (PlayerSprite.end - PlayerSprite) + (EnemyTurtleSprite.end - EnemyTurtleSprite), EnemyTurretSprite.end - EnemyTurretSprite

    set_romx_bank BANK(EnemyGhostSprite)
    mem_copy EnemyGhostSprite, _VRAM8000 + (PlayerSprite.end - PlayerSprite) + (EnemyTurtleSprite.end - EnemyTurtleSprite) + (EnemyTurretSprite.end - EnemyTurretSprite), EnemyGhostSprite.end - EnemyGhostSprite

    set_romx_bank BANK(PowerUpSprites)
    mem_copy PowerUpSprites, _VRAM8000 + (PlayerSprite.end - PlayerSprite) + (EnemyTurtleSprite.end - EnemyTurtleSprite) + (EnemyTurretSprite.end - EnemyTurretSprite) + (EnemyGhostSprite.end - EnemyGhostSprite), PowerUpSprites.end - PowerUpSprites

    ; Copy tile map into VRAM.
    set_romx_bank 3 ; Our tile maps are in Bank 3, so we load that into ROMX.
    mem_copy Level0, GameLevelTiles, Level0.end-Level0
    mem_copy GameLevelTiles, _SCRN0, GameLevelTiles.end-GameLevelTiles

    call LoadGameplayUI

    ; TEMP: Temporary code.
    set_romx_bank 2
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM

    call ResetPlayerCamera
    call ResetAllBullets
    call ResetDirtyTiles
    call InitEnemiesAndPlaceOnMap
    call InitPowerupsAndPlaceOnMap

    call hOAMDMA ; transfer sprite data to OAM

    ; Initialise BGM
    set_romx_bank 5
    ld hl, CombatBGM
    call hUGE_init

    xor a
    ld [rSCY], a ; make the screen for scroll X and Y start at 0
    ld [rSCX], a

    call LCDOn
    call SoundOn

    ; Set Interrupt Flags
    ld a, IEF_VBLANK | IEF_STAT ; Enable Interrupts
    ldh [rIE], a
    xor a ; Clear Pending Interrupts
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    jp UpdateGameLevel

    ret

UpdateGameLevel::
.loop
    jr .loop
    ret