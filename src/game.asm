SECTION "Main Game Loop", ROM0
MainGameLoop::
    ; for now it does nothing here
    jr MainGameLoop


SECTION "VBlank handler", ROM0

VBlankHandler::
    ; TODO:: scrolling or any tile updates here


    call ResetOAM ; clear the current OAM

    ; TODO:: update sprites for entities here


    call hOAMDMA ; Update OAM
    call ResetShawdowOAM ; clear shadow OAM

    ; get back old state
    pop hl
    pop de
    pop bc
    pop af

    reti
