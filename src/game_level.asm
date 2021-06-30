INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/include/definitions.inc"

SECTION "Game Level Tiles", WRAM0
GameLevelTiles::
    ds 1024
.end::

SECTION "Game Level", ROM0
LoadGameLevel::
    di ; Disable Interrupts

    call LCDOff
    call SoundOff

    ; Set STAT interrupt flags.
    ld a, VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a

    ; Reset hVBlankFlag.
    xor a
    ld [hVBlankFlag], a

    ; Reset OAM & Shadow OAM
    call ResetOAM
    mem_set_small wShadowOAM, 0, wShadowOAM.end - wShadowOAM
    xor a
    ld [wCurrentShadowOAMPtr], a

    ; Copy textures into VRAM.
    set_romx_bank BANK(BGWindowTiles)
    mem_copy BGWindowTiles, _VRAM9000, BGWindowTiles.end-BGWindowTiles
    set_romx_bank BANK(Sprites)
    mem_copy Sprites, _VRAM8000, Sprites.end-Sprites

    ; Copy tile map into VRAM.
    set_romx_bank BANK(Level0TileMap)
    mem_copy Level0TileMap, GameLevelTiles, Level0TileMap.end-Level0TileMap
    mem_copy GameLevelTiles, _SCRN0, GameLevelTiles.end-GameLevelTiles

    call LoadGameplayUI

    ; TEMP: Temporary code.
    set_romx_bank BANK(Sprites)
    ld hl, wShadowOAM
    call InitialisePlayer
    call UpdatePlayerShadowOAM

    call ResetPlayerCamera
    call ResetAllBullets
    call ResetDirtyTiles
    call InitEnemiesAndPlaceOnMap
    call InitPowerupsAndPlaceOnMap

    call hOAMDMA ; transfer sprite data to OAM

    ; Reset SCY & SCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    call LCDOn

    ; Turn on BGM
    call SoundOn
    set_romx_bank BANK(CombatBGM)
    ld hl, CombatBGM
    call hUGE_init

    ; Set Interrupt Flags
    ld a, IEF_VBLANK | IEF_STAT
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    jp UpdateGameLevel

UpdateGameLevel::
    set_romx_bank BANK(Sprites) ; player, enemy and bullet sprite data is in rombank 2
    ;ld a, BANK(LevelOneEnemyData)
    ;ld [rROMB0], a
    call UpdateInput

    call ResetShadowOAM

    ; insert game logic here and update shadow OAM data
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera
    call UpdatePlayerShadowOAM

    call UpdateAllEnemies    
    call UpdateBullets
    call UpdatePowerUpShadowOAM

    ; Dirty tiles get updated during HBlank.
    call UpdateDirtyTiles

    ; Update Sound
    set_romx_bank BANK(CombatBGM)
    call _hUGE_dosound

    rst $0010 ; Wait VBlank

    jr UpdateGameLevel