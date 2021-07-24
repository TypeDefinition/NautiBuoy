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

wMapSizeY::
    ds 2
wMapSizeX::
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
JumpUpdatePausedGameLevel:
    jp UpdatePausedGameLevel

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
    ld b, $00
    ld c, $01
    call hUGE_mute_channel

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

    ; Check for pause.
    ld a, [wNewlyInputKeys]
    ld b, a
    bit PADB_START, b
    call nz, PauseGame

    ret

UpdatePausedGameLevel:
    ; Check for resume
    call UpdateInput
    ld a, [wNewlyInputKeys]
    ld b, a
    bit PADB_START, b
    call nz, ResumeGame
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

PauseGame::
    ; Set STAT interrupt flags.
    ld a, PAUSE_VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a
    call PauseUI
    ld hl, JumpUpdatePausedGameLevel
    call SetProgramLoopCallback
    call SoundOff
    ret

ResumeGame::
    ; Set STAT interrupt flags.
    ld a, VIEWPORT_SIZE_Y
    ldh [rLYC], a
    ld a, STATF_LYC
    ldh [rSTAT], a
    call ResumeUI
    ld hl, JumpUpdateGameLevel
    call SetProgramLoopCallback
    call SoundOn
    ret

SaveCurrentScore::
    ; Load Previous Save Data
    ld a, [wSelectedStage]
    ld [wRWIndex], a
    call LoadGame

    ; bc = -current time.
    ld a, [wGameTimer]
    cpl
    ld b, a
    ld a, [wGameTimer+1]
    cpl
    ld c, a
    inc bc

    ; Has this stage been cleared before? If no, overwrite new data. Otherwise, compare to see if old score is better.
    ld a, [wRWBuffer]
    cp a, STAGE_UNLOCKED_CLEARED ; Only possible states should be STAGE_UNLOCKED_NOT_CLEARED or STAGE_UNLOCKED_CLEARED. Should never be STAGE_LOCKED.
    jr nz, .overwrite

    ; If previous time < current time (hl < bc), overwrite it. Else, do not overwrite data.
    ; hl = previous time.
    ld a, [wRWBuffer+1]
    ld h, a
    ld a, [wRWBuffer+2]
    ld l, a
    add hl, bc
    jr c, .end

.overwrite
    ; Set stage as cleared.
    ld a, STAGE_UNLOCKED_CLEARED
    ld [wRWBuffer], a

    ; Overwrite Time
    ld a, [wGameTimer]
    ld [wRWBuffer+1], a
    ld a, [wGameTimer+1]
    ld [wRWBuffer+2], a

    ; If 3 stars time <= current time, 3 stars.
    ld a, [w3StarsTime]
    ld h, a
    ld a, [w3StarsTime+1]
    ld l, a
    dec hl ; add hl, bc does not set the Z flag, so we can't check for hl <= bc. Instead, we check for (hl-1)<bc
    add hl, bc
    jr nc, .threeStars

    ; If 2 stars time <= current time, 2 stars.
    ld a, [w2StarsTime]
    ld h, a
    ld a, [w2StarsTime+1]
    ld l, a
    dec hl ; add hl, bc does not set the Z flag, so we can't check for hl <= bc. Instead, we check for (hl-1)<bc
    add hl, bc
    jr nc, .twoStars

    ; Else, 1 star
    ld a, 1
    jr .save

.threeStars
    ld a, 3
    jr .save
.twoStars
    ld a, 2
.save
    ld [wRWBuffer+3], a
    call SaveGame

.end
    ret