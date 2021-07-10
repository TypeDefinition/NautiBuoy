INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"
INCLUDE "./src/include/hUGE.inc"
INCLUDE "./src/definitions/definitions.inc"

DEF GAME_TIMER_INCREMENT EQU $04

SECTION "Game Level WRAM", WRAM0
wGameLevelTileMap::
    ds 1024 ; Every game level is made of 1024 tiles.
.end::

wGameTimer::
    ds 2 ; Store the timer as Binary-Coded-Decimals (BCD) in Big-Endian
wGameTimerFrac::
    ds 1
w2StarsTime::
    ds 2
w3StarsTime::
    ds 2

wShadowSCData::
    ds 2 ; y pos, then x pos

SECTION "Game Level", ROM0
; Global Jumps
JumpLoadGameLevel::
    jp LoadGameLevel
; Local Jumps
JumpVBlankHandler:
    jp VBlankHandler
JumpUpdateGameLevel:
    jp UpdateGameLevel

LCDOn:
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [hLCDC], a ; Store a copy of the flags in HRAM.
    ld [rLCDC], a
    ret

InitStageParam:
    ; Set Game Timer Frac
    xor a
    ld [wGameTimerFrac], a

    call GetSelectedStageParamAddr
    inc hl
    inc hl

    ; Set Game Timer
    ld a, [hli]
    ld [wGameTimer], a
    ld a, [hli]
    ld [wGameTimer+1], a

    ; Set 2-Stars time.
    ld a, [hli]
    ld [w2StarsTime], a
    ld a, [hli]
    ld [w2StarsTime+1], a

    ; Set 3-Stars time.
    ld a, [hli]
    ld [w3StarsTime], a
    ld a, [hli]
    ld [w3StarsTime+1], a

    ret

InitStage:
    ld a, [wSelectedStage]

    dec a
    jp z, InitStage1
    dec a
    jp z, InitStage2
    dec a
    jp z, InitStage3
    dec a
    jp z, InitStage4
    dec a
    jp z, InitStage5
    dec a
    jp z, InitStage6
    dec a
    jp z, InitStage7

    ; Default
    jp InitStage0

LoadGameLevel:
    di ; Disable Interrupts

    call LCDOff
    call SoundOff

    ld hl, JumpVBlankHandler
    call SetVBlankCallback
    ld hl, JumpUpdateGameLevel
    call SetProgramLoopCallback

    ; Copy background tile data into VRAM.
    set_romx_bank BANK(BGWindowTileData)
    mem_copy BGWindowTileData, _VRAM9000, BGWindowTileData.end-BGWindowTileData

    ; Load Sprites into VRAM.
    set_romx_bank BANK(Sprites)
    mem_copy Sprites, _VRAM8000, Sprites.end-Sprites
    ; Reset OAM & Shadow OAM.
    call ResetOAM
    mem_set_small wShadowOAM, 0, wShadowOAM.end - wShadowOAM
    xor a
    ld [wCurrentShadowOAMPtr], a
    ; Transfer sprite data to OAM.
    call hOAMDMA

    call ResetPlayerCamera
    call ResetAllBullets

    ; Reset rSCY & rSCX
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Initalise Stage Specific Stuff
    call InitStageParam
    call InitStage

    ; Initialise UI (Needs to be called after InitStageParam.)
    call ResetBGWindowUpdateQueue
    call LoadGameLevelUI
    call UpdateGameTimerUI
    call UpdatePlayerHPUI
    call UpdateEnemyCounterUI

    call LCDOn

    ; Set BGM
    call SoundOn
    set_romx_bank BANK(GameLevelBGM)
    ld hl, GameLevelBGM
    call hUGE_init

    ; Set STAT interrupt flags.
    ld a, VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a
    ; Set Interrupt Flags
    ld a, IEF_VBLANK | IEF_STAT
    ldh [rIE], a
    ; Clear Pending Interrupts
    xor a
    ldh [rIF], a
    ei ; Enable Master Interrupt Switch

    ret

UpdateGameLevel:
    call UpdateInput

    set_romx_bank BANK(Sprites)
    call ResetShadowOAM

    ; insert game logic here and update shadow OAM data
    call UpdateGameLevelTimer ; update timer
    call UpdateParticleEffect
    
    call UpdatePlayerMovement
    call UpdatePlayerAttack
    call UpdatePlayerCamera
    call UpdatePlayerShadowOAM

    call UpdateAllEnemies    
    call UpdateBullets
    call UpdatePowerUpShadowOAM

    ; Dirty tiles get updated during HBlank.
    call UpdateBGWindow

    ; Update Sound
    set_romx_bank BANK(GameLevelBGM)
    call _hUGE_dosound

    ret

VBlankHandler:
    push af
    ; If VBlankHandler was called without waiting for VBlank, the frame lagged.
    ld a, [hWaitVBlankFlag]
    and a
    jr z, .lagFrame
    ; Reset hWaitVBlankFlag
    xor a
    ld [hWaitVBlankFlag], a
    push bc
    push de
    push hl

    ; Enable Sprite Rendering
    ldh a, [hLCDC]
    ldh [rLCDC], a
    
    call hOAMDMA ; Update OAM

    ; Update Camera Position
    ld a, [wShadowSCData]
    ld [rSCY], a
    ld a, [wShadowSCData + 1]
    ld [rSCX], a 

    pop hl
    pop de
    pop bc
    pop af
.lagFrame
    pop af
    reti

; Get the value of the tile, given a tile index.
; @param bc TileIndex
; @return a Tile Value
GetGameLevelTileValue::
    push hl

    ld hl, wGameLevelTileMap
    add hl, bc
    ld a, [hl]

    pop hl
    ret

; Set a tile to be updated.
; @param a New Tile Value
; @param bc Tile Index
SetGameLevelTile::
    push af
    push hl
    ld hl, wGameLevelTileMap
    add hl, bc
    ld [hl], a
    pop hl
    pop af
    call QueueBGTile
    ret

UpdateGameLevelTimer:
    ; Update timer
    ld a, [wGameTimerFrac]
    add a, GAME_TIMER_INCREMENT
    ld [wGameTimerFrac], a
    ret nc

    ; Load game timer value into hl.
    ld a, [wGameTimer]
    ld h, a
    ld a, [wGameTimer+1]
    ld l, a

    ; hl - 1
    sub a, $01
    daa
    ld l, a
    ld a, h
    sbc a, $00
    daa
    ld h, a

    ; Save new game timer value.
    ld a, h
    ld [wGameTimer], a
    ld a, l
    ld [wGameTimer+1], a

    call UpdateGameTimerUI

    ; If h == l == 0, HP == 0. If HP == 0, lose.
    ld a, h
    or a, l
    jr nz, .end
    ld a, LOSE_REASON_TIME
    ld [wLoseReason], a
    ld hl, JumpLoadLoseScreen
    call SetProgramLoopCallback

.end
    ret