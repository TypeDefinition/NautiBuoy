INCLUDE "./src/include/hardware.inc"

SECTION "Tile Maps", ROMX, BANK[3]
GameplayUI::
    db 31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31
    db 28,30,32,32,29,30,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.end::

StageEnd::
    db 31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,83,84,65,71,69,32,35,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,84,73,77,73,78,71,58,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,67,111,110,116,105,110,117,101,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,82,101,116,114,121,32,76,101,118,101,108,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,69,120,105,116,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.end::

Level0::
    db 2,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,3
    db 7,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,9,11,12,12,11,12,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,11,9,12,11,11,12,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,8,8,8,8,8,8,0,32,32,32,32,32,32,32,32,32,32,0,8,8,8,8,8,8,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,1,1,1,1,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,0,0,1,32,32,1,0,0,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,0,20,20,20,20,20,0,32,32,32,0,32,32,32,32,32,32,0,32,32,32,0,20,20,20,20,20,0,32,7
    db 7,32,0,20,20,20,20,20,0,32,32,32,32,32,32,16,17,32,32,32,32,32,32,0,20,20,20,20,20,0,32,7
    db 7,32,0,20,20,20,20,20,0,32,32,32,32,32,32,18,19,32,32,32,32,32,32,0,20,20,20,20,20,0,32,7
    db 7,32,0,20,20,20,20,20,0,32,32,32,0,32,32,32,32,32,32,0,32,32,32,0,20,20,20,20,20,0,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,0,0,1,32,32,1,0,0,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,1,1,1,1,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,8,8,8,8,8,8,0,32,32,32,32,32,32,32,32,32,32,0,8,8,8,8,8,8,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,32,32,32,32,32,32,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,9,11,12,12,11,12,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,0,32,32,32,32,32,32,0,32,32,11,9,12,11,11,12,32,32,0,32,32,32,32,32,32,0,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,7
    db 7,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,7
    db 4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,5
.end::