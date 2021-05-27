INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

/*
    These are where the declaration of OAM variables in memory will be
    Call them Shadow OAM vars and they are found in RAM
    Have to be copied to OAM using the HRAM during DMA transfer
    "Shadow X" means "a copy of X in RAM that has to be copied to the real thing"
    
    OAM is at $FE00 to $FE9F, each sprite is 4 bytes, can only contain 40 sprites
    160 bytes in total

    Y pos, X pos, sprite ID, flags
*/

; NOTE: ALIGN[8] will cause RGBDS to help allocate in memory to an address that is 256 aligned (like $c100, $C000)
; address for VAR needs to be 256-bytes aligned for easier access to OAM later on
; If Align[8] causes problem, change to a fix address instead
SECTION "Shadow OAM Vars", WRAM0, ALIGN[8] 

wShadowOAM::
    ds 4 * 40 ; This is the buffer we'll write sprite data to, reserve 4*40 bytes for it
.end

/* Move codes from RAM to HRAM */
SECTION "OAM DMA Routine", ROM0

; We want to copy our DMARoutine function from ROM to HRAM, since writing to OAM can only happen at HRAM
CopyDMARoutine::
    ld  hl, DMARoutine ; Starting address to start copying from
    ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
    ld  c, LOW(hOAMDMA) ; bottom half bits of the destination address, pad the top with Fs when ldh [c]. HRAM is located at FF80-FFFE, save one register since use 8 bits
.copy
    ld  a, [hli]  ; Start copying and then increment
    ldh [c], a ; put inside HRAM
    inc c
    dec b
    jr  nz, .copy
    ret

; DMA transfer allows the shadow OAM variables (edited during runtime) to be transfered to OAM so sprites can be updated
DMARoutine:
    ld  a, HIGH(wShadowOAM) ; Get the first half bits in the address of wShadowOAM, pad the bottom half bits with 0s
    ldh [rDMA], a ; start DMA transfer, writing to rDMA($FF46), allows for DMA transfer, tell it to copy data from wShadowOAM
    
    ld  a, 40 
.wait ; delay it for 160 microseconds since DMA transfer takes that amount of time
    dec a
    jr  nz, .wait
    ret
DMARoutineEnd:


SECTION "Clear OAM", ROM0
/* Reset OAM and shadow OAM values, Use during VBLANK */
ResetOAM::
    mem_set_small _OAMRAM, 0, wShadowOAM.end - wShadowOAM
    ret
/* Clean up shadowOAM data, can be used anytime, best to use when needing to reinitialise OAM values */
ResetShawdowOAM::
    mem_set_small wShadowOAM, 0, wShadowOAM.end - wShadowOAM
    ret

SECTION "OAM DMA", HRAM
/*  This func contains the DMA transfer to transfer shadow OAM data to actual OAM
    Call this func to update OAM
    Call during VBLank cause when OAM DMA transfer is in progress, no sprites displayed
*/ 
hOAMDMA::
    ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to