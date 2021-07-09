INCLUDE "./src/include/hardware.inc"

SECTION "Stage Info", ROM0
StageInfo::
    ; Stage 0
    db "00"     ; 2-Byte stage name.
    db $01, $20 ; Stage Time in BCD format. (Yes this is in Big Endian. No, I'm not changing it. All my shit are done in Big Endian and I'm too fucking tired to give a shit anymore.)
    db $00, $50 ; Time (in BCD) to get 2 Stars. (Player gets 1 star as long as they complete the stage.)
    db $00, $90 ; Time (in BCD) to get 3 Stars.

    ; Stage 1
    db "01"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 2
    db "02"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 3
    db "03"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 4
    db "04"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 5
    db "05"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 6
    db "06"
    db $01, $20
    db $00, $50
    db $00, $90
    
    ; Stage 7
    db "XX"
    db $01, $20
    db $00, $50
    db $00, $90