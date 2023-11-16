INCLUDE "ext/hardware.inc"
INCLUDE "ext/ibmpc1.inc"
INCLUDE "video.inc"
INCLUDE "memory.inc"

SECTION "Header", ROM0[$0100]
    jp Main
    ds $150 - @, 0

SECTION "Main", ROM0
Main:
    di
    ld a, 0
    ld [rLCDC], a
    ld [rNR52], a
    ld [rSCX], a
    ld [rSCY], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    memSet _RAM, $00, $2000
    memSet _VRAM, $00, $2000
    call InitDMATransfer

    memCopy2X $9200, Font
    memSet _SCRN0, $FF, $800
    tileBlitRow _SCRN0, 4, 8, Title

    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    ei

GameLoop:
    waitVBlank
    call UpdateGamepad
    call DMATransfer
    jp GameLoop


Font:
    chr_IBMPC1 2,4
.end


Title:
    db "Hello World!"
.end:
