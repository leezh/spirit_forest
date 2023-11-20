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
    ld [rNR52], a
    ld a, BANK(InitVideo)
    ld [rROMB0], a
    call InitVideo
    memSet _RAM, $00, $2000
    ei
    jp TitleScreen

