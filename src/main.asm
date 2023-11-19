INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"

SECTION "Header", ROM0[$0100]
    jp Main
    ds $150 - @, 0

SECTION "Main", ROM0
Main:
    ld a, 0
    ld [rNR52], a
    call InitVideo
    memSet _RAM, $00, $2000
    jp TitleScreen

