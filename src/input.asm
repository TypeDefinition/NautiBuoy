INCLUDE "./src/hardware.inc"

P1F_NONE     EQU $30 ; 0011 0000, used to release the controller
P1F_BUTTONS  EQU $10 ; 0001 0000, select button, set bit 4 high, rest low
P1F_DPAD     EQU $20 ; 0010 0000, select Dpad by setting bit 5 to high and bit 4 low

/*
    Variables to keep track of the input keys

    first 4 bits: down(7), up(6), left(5), rigjt(4)
    last 4 bits: start(3), select(2), B(1), A(0)

    How to use: 
    ld a, [wCurrentInputKeys/wNewlyInputKeys] ; get current/new inputs
    bit PADB_START, a ; check if bit n of register a is not z, so can use nz or z flag to check 
*/
SECTION "Input Variables", WRAM0
wCurrentInputKeys:: ds 1   ; the input currently initialised, stores all current inputs regardless if pressed previously or not
wNewlyInputKeys:: ds 1     ; inputs that was not pressed previously, but pressed this time


/* Logic to handle and update input */
SECTION "Input Handler", ROM0

/*  For updating input, 
    rP1 ($FF00), is the register for reading joy pad info
*/
UpdateInput::

    ; get the d-pad inputs
    ld a, P1F_BUTTONS
    call .readInput
    ld b, a ; Store the button inputs in b first

    ; get the button inputs
    ld a, P1F_DPAD
    call .readInput
    swap a ; Move the lower 4 bits (d pad input) to the first 4 bits
    xor b  ; Merge the button and d-pad input to a. Cause 0 means press, 1 means not pressed. XOR will make the press button to 1, and unpress to 0
    ld b, a 

    ; release the controller
    ld a, P1F_NONE
    ldh [rP1], a

    ; Handle and inputs
    ld a, [wCurrentInputKeys]
    xor b    ; keys that were pressed currently and previously becomes 0
    and b    ; keys that is currently pressed is kept, prev input becomes 0
    ld [wNewlyInputKeys], a
    ld a, b  ; load the values currently pressed
    ld [wCurrentInputKeys], a

    ret

/* Function to handle stablization and debouncing inputs before getting the correct one */
.readInput:
    ldh [rP1], a     ; switch the key matrix

    ; Need some cycles before writing to P1 and reading the result, need wait for it to stabalize
    call .burnCycles  ; burn 10 cycles with a call

    ; debouncing
    ldh a, [rP1]     ; ignore value while waiting for the key matrix to settle
    ldh a, [rP1]
    ldh a, [rP1]     ; store this read

    or $F0   ; We only want the last 4 bits. input returned: 0 means pressed, 1 means not press. 
.burnCycles:
    ret