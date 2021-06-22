INCLUDE "./src/include/hardware.inc"
INCLUDE "./src/include/util.inc"

SECTION "Game UI", ROM0
InitialiseGameUI::
    set_romx_bank 3
    mem_copy UI, _SCRN1, UI.end-UI
    ld a, 7
    ld [rWX], a
    ld a, 120
    ld [rWY], a
    ret