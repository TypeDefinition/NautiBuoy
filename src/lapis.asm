INCLUDE "./src/hardware.inc"

; $0000 - $00FF: Boot ROM
/*  During boot-up, this area is reserved for the Boot ROM located in the Game Boy's CPU.
    After boot-up, the normal memory in our ROM is then loaded in. */

; $0000 - $003F: Restart Commands (RST)
/*  Restart Commands, or "rst" commands, jumps to an address and execute code until encountering a return command.
    RST is more like call, it will put the prev instruction address in the stack
    They are only capable of going to a few preset addresses.
    Those addresses are $0000, $0008, $0010, $0018, $0020, $0028, $0030 and $0038. */
SECTION "RST $0000", ROM0[$0000]
    ret

SECTION "RST $0008", ROM0[$0008]
/*  Initialise data in memory to a certain value
    For small data sets, up to size 256

    a - value to init to
    b - size
    hl - destination address
*/
Memset_Small::
    ld [hli], a
    dec b
    jr nz, Memset_Small
    
    ret

SECTION "RST $0010", ROM0[$0010]
    ret

SECTION "RST $0018", ROM0[$0018]
    ret

SECTION "RST $0020", ROM0[$0020]
    ret

SECTION "RST $0028", ROM0[$0028]
    ret

SECTION "RST $0030", ROM0[$0030]
    ret

SECTION "RST $0038", ROM0[$0038]
    ret

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
VBlankInterrupt:
    reti

SECTION "STAT Interrupt", ROM0[$0048]
STATInterrupt:
    reti

SECTION "Timer Interrupt", ROM0[$0050]
TimerInterrupt:
    reti

SECTION "Serial Interrupt", ROM0[$0058]
SerialInterrupt:
    reti

SECTION "Joypad Interrupt", ROM0[$0060]
JoypadInterrupt:
    reti

; $0100 - $0103: Entry Point
SECTION "Entry Point", ROM0[$0100]
/*  After booting, the CPU jumps to the actual main program in the cartridge, which is $0100.
    Usually this 4 byte area contains a NOP instruction, followed by an instruction to jump to $0150. But not always.
    The reason for the jump is that while the entry point is $100, the header of the game spans from $0104 to $014F.
    So there's only 4 bytes in which we can run any code before the header. So we use these 4 bytes to jump to after the header. */
EntryPoint: ; This is where execution begins.
    di ; Disable interrupts until we have finish setting up our game.
    jp Start ; Leave this tiny space.

; $0104 - $014F: Header
SECTION "Header", ROM0[$0104]
    ; $0104 - $0133: Nintendo Logo.
    /*  This Nintendo logo will be compared against a copy stored in the Boot ROM. If they do no match, the cartridge won't boot.
        This is done for copyright and legal reasons so that Nintendo could control the games sold for the Game Boy.
        If the logo is not included, the cartridge won't boot on the Game Boy. If the logo is included, the cartridge contains
        Nintendo's trademark and therefore require Nintendo's permission to be sold. */
    db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
    db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
    db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

    ; $0134 - $013E: Game Title
    /*  Title of the game in UPPER CASE ASCII. Originally the title was 16 bytes.
        When the CGB was released, it was reduced to 15 bytes, and some months later they had the fantastic idea to reduce it to 11 bytes only.
        The remaining bytes were later on used to represent other things. */
    db "LAPIS" ; A title of length n.
    ds 6 ; The ds instruction is used to pad the remaining 11-n bytes with zero.

    ; $013F - $0142: Manufacturer Code
    /*  In older cartridges this area was part of the title.
        In newer cartridges this area contains an 4 character uppercase manufacturer code. Purpose and Deeper Meaning unknown.
        Lots of emulators will display this as part of the title, which is undesirable, so here it’s just filled with 0 values. */
    ds 4

    ; $0143: CGB Flag
    /*  In older cartridges this area was part of the title.
        In CGB catridges the upper bit is used to enable CGB functions. This is required, otherwise the CGB switches itself into Non-CGB-Mode.
        Values:
        $00 = GB Only
        $C0 = CGB Only
        $80 = GB + CGB */
    db $00

    ; $0144 - $0145: New Licensee Code
    /*  Specifies a two character ASCII licensee code, indicating the company or publisher of the game.
        These two bytes are used in newer games only (games that have been released after the SGB has been invented).
        Older games are using the header entry at 014B instead. A list of licensee code can be found online.
        Since we're most likely none of those licensees, we'll use the code $0000 which represents "none". */
    dw $0000

    ; $0146: SGB Flag
    /*  Specifies whether the game supports SGB functions.
        Values:
        $00 = No SGB functions (Normal Gameboy or CGB only game)
        $03 = Game supports SGB functions */
    db $00

    ; $0147: Catridge Type
    /*  Specifies which Memory Bank Controller (if any) is used in the catridge, and if further hardware exists in the cartridge.
        Values:
        $00 = ROM ONLY
        $01 = MBC1
        $02 = MBC1+RAM
        $03 = MBC1+RAM+BATTERY
        $05 = MBC2
        $06 = MBC2+BATTERY
        $08 = ROM+RAM
        $09 = ROM+RAM+BATTERY
        $0B = MMM01
        $0C = MMM01+RAM
        $0D = MMM01+RAM+BATTERY
        $0F = MBC3+TIMER+BATTERY
        $10 = MBC3+TIMER+RAM+BATTERY
        $11 = MBC3
        $12 = MBC3+RAM
        $13 = MBC3+RAM+BATTERY
        $19 = MBC5 
        $1A = MBC5+RAM
        $1B = MBC5+RAM+BATTERY
        $1C = MBC5+RUMBLE
        $1D = MBC5+RUMBLE+RAM
        $1E = MBC5+RUMBLE+RAM+BATTERY
        $20 = MBC6
        $22 = MBC7+SENSOR+RUMBLE+RAM+BATTERY
        $FC = POCKET CAMERA
        $FD = BANDAI TAMA5
        $FE = HuC3
        $FF = HuC1+RAM+BATTERY */
    db $00

    ; $0148: ROM Size
    /* Specifies the ROM Size of the cartridge. Typically calculated as "32KB shl N".
        $00 = 32KB (no ROM banking)
        $01 = 64KB (4 banks)
        $02 = 128KB (8 banks)
        $03 = 256KB (16 banks)
        $04 = 512KB (32 banks)
        $05 = 1MB (64 banks) - only 63 banks used by MBC1
        $06 = 2MB (128 banks) - only 125 banks used by MBC1
        $07 = 4MB (256 banks)
        $08 = 8MB (512 banks)
        $52 = 1.1MB (72 banks)
        $53 = 1.2MB (80 banks)
        $54 = 1.5MB (96 banks) */
    db $00

    ; $0149: RAM Size
    /*  Specifies the size of the external RAM in the cartridge (if any).
        $00 = None
        $01 = 2KB
        $02 = 8KB
        $03 = 32KB (4 banks of 8KB each)
        $04 = 128KB (16 banks of 8KB each)
        $05 = 64KB (8 banks of 8KB each) */
    db $00

    ; $014A: Destination Code
    /* Specifies if this version of the game is supposed to be sold in Japan, or anywhere else. Only two values are defined.
        $00 = Japanese
        $01 = Non-Japanese */
    db $01

    ; $014B: Old Licensee Code
    /* Specifies the games company/publisher code in range $00 - $FF.
        A value of $33 signalizes that the New License Code in header bytes $0144 - $0145 is used instead.
        Super GameBoy functions won't work if this value is not $33. */
    db $33

    ; $014C: Mask ROM Version Number
    ; Specifies the version number of the game. This is usually $00.
    db $00

    ; $014D: Header Checksum
    /*  Contains an 8-bit checksum across the cartridge header bytes $0134 - $014C.
        The lower 8 bits of the result must be the same than the value in this entry.
        The GAME WON'T WORK if this checksum is incorrect.
        The checksum is calculated as follows: x=0: FOR i=$0134 TO $014C: x=x-MEM[i]-1: NEXT
        We'll use RGBFIX to generate this so let's not worry too much about it. */
    db $00

    ; $014E - $014F: Global Checksum
    /*  Contains a 16-bit checksum (upper byte first) across the whole cartridge ROM.
        Produced by adding all bytes of the cartridge (except for the two checksum bytes).
        The Game Boy doesn't verify this checksum. */
    dw $0000

SECTION "Game Code", ROM0
Start:
.init
    ld sp, $E000 ; Initialise our stack pointer to the end of the work RAM.
    ei ; Enable Interrupts

    call CopyDMARoutine ; init the copy of the DMA handler func from RAM to HRAM

    ; Turn off the LCD
.waitVBlank
    ld a, [rLY] ; rLY is address $FF44, we getting the LCDC Y-Coordinate here to see the current state of the LCDC drawing
    cp 144 ; Check if the LCD is past VBlank, values between 144 - 153 is VBlank period
    jr c, .waitVBlank ; We need wait for Vblank before we can turn off the LCD

    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We do this to the LCDC cause we want to turn off the control operation by making bit 7 0, but the rest for now dont matter
    ; We will have to write to LCDC again later, so it's not a bother, really.

    call ResetOAM

    ;once the LCD is turned off, we can access VRAM, so copy the font to VRAM
    ld hl, _VRAM9000 ; pattern 0 lies at $9000, tilemap data address, set from the LCDC bits
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call MemCopy ; copy tiles to VRAM

    ; Init sprites
    ld hl, _VRAM8000
    ld de, TESTSPRITE
    ld bc, TESTSPRITE.end - TESTSPRITE
    call MemCopy ; copy tiles to VRAM

    ld hl, _SCRN0 ; This will print the string at the top-left corner of the screen, 9800 is the window tilemap display select
    ld de, HelloWorldStr

    call CopyToTileMap ; set up tilemap


        ; temp code
    ld hl, wShadowOAM
    ld a, 90
    ld [hli], a ; set x coor
    ld a, 100
    ld [hli], a ;set y coord
    ld a, 0
    ld [hl], a

    call hOAMDMA ; transfer sprite data to OAM

    ; Init display registersm and turn on display
    ld a, %11100100 ; setting the color palette
    ld [rBGP], a ; render it out

    xor a ; ld a, 0
    ld [rSCY], a ; make the screen for scroll X and Y start at 0
    ld [rSCX], a
    
    ; Shut sound down
    ld [rNR52], a
    
    ; Turn screen on, display background
    ld a, %10000011 ; we want to set back LCDC bit 7 to 1
    ld [rLCDC], a ; turn on the screen

; Lock up
.lockup
    jr .lockup


/* Copy data to memory */
MemCopy:
    ; de - Source address
    ; bc - number of bytes to fill
    ; hl - destination address

    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl, hli is just increment hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c ; if b and c are 0, when u or them it'll give 0 also
    jr nz, MemCopy ; check if not zero
    
    ret


/* write to tilemap */
CopyToTileMap:
    ; de - Source address
    ; hl - destination address

    ld a, [de]
    ld [hli], a
    inc de
    cp $FF ; Check if the byte we just copied is 0xFF
    jr c, CopyToTileMap ; Continue if it's not, c will be set if 0xFF is bigger
    
    ret