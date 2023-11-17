INCLUDE "ext/hardware.inc"
INCLUDE "ext/ibmpc1.inc"
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
    memCopy2X _VRAM + $200, Font
    jp TitleScreen


Font:
    chr_IBMPC1 2,4
.end
