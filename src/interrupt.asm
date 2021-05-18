INCLUDE "./src/hardware.inc"

; $0040 - $0067: Interrupts
/*  Interrupts are used to call a given function when certain conditions are met.

    Interrupts & Handler Address:
    1. VBlank (Handler Address: $0040, Highest Priority)
    2. STAT (Handler Address: $0048)
    3. Timer (Handler Address: $0050)
    4. Serial (Handler Address: $0058)
    5. Joypad (Handler Address: $0060, Lowest Priority)

    Before every instruction, the CPU checks if an interrupt needs to be handled.
    If there is an interrupt, the CPU will call the instruction at certain predetermined memory addresses.
    So if there is an Timer interrupt, the CPU would essentially do "call $0050". */
SECTION "VBlank Interrupt", ROM0[$0040]
VBlankInterrupt::
    reti

SECTION "STAT Interrupt", ROM0[$0048]
STATInterrupt::
    reti

SECTION "Timer Interrupt", ROM0[$0050]
TimerInterrupt::
    reti

SECTION "Serial Interrupt", ROM0[$0058]
SerialInterrupt::
    reti

SECTION "Joypad Interrupt", ROM0[$0060]
JoypadInterrupt::
    reti