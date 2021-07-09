INCLUDE "./src/include/hardware.inc"

SECTION "Stage Info", ROM0
StageInfo::
    ; Stage 1
    db "01"  ; 2-Byte stage name.
    db $01, $20 ; Stage Time in BCD format. (Yes this is in Big Endian. No, I'm not changing it. All my shit are done in Big Endian and I'm too fucking tired to give a shit anymore.)
    db $00, $00 ; Time (in BCD) to get 1 Star.
    db $00, $50 ; Time (in BCD) to get 2 Stars.
    db $00, $90 ; Time (in BCD) to get 3 Stars.
    ; Stage 2
    db "02"
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 3
    db "03"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 4
    db "04"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 5
    db "05"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 6
    db "06"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 7
    db "07"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90
    ; Stage 8
    db "08"  
    db $01, $20
    db $00, $00
    db $00, $50
    db $00, $90