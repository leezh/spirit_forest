INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"

SECTION "Header", ROM0[$0100]
    jp Main
    ds $150 - @, 0

SECTION "Main", ROM0
Main:
    di
    ld a, 0
    ldh [rNR52], a
    ldh [rLCDC], a
    ldh [GamepadPressed], a
    ldh [GamepadJustPressed], a
    ldh [GamepadJustReleased], a
    ld a, BANK(InitVideo)
    ld [rROMB0], a
    memSet _RAM, $FF, $2000
    call InitVideo
    ei
    jp TitleScreen
