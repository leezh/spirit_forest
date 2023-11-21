INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]

ShadowOAM::
    ds 4 * OAM_COUNT


SECTION "Video", ROM0

ResetScreen::
    ld a, 0
    ld [rLCDC], a
    ld [rSCX], a
    ld [rSCY], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    memSet _SCRN0, $FF, $400
    memSet _ShadowOAM, $00, $FF
    ret


SECTION "InitVideo", ROMX, BANK[1]

InitVideo::
    call ResetScreen
    memLoad DMATransfer, DMATransferRoutine
    memSet _VRAM, $00, $2000
    memCopy2X _VRAM + $200, Font
    ret


Font:
    INCBIN "font.1bpp"
.end


DMATransferRoutine:
    LOAD "DMATransfer", HRAM
DMATransfer::
    di
    ld a, HIGH(ShadowOAM)
    ld [rDMA], a
    ld a, OAM_COUNT
:
    dec a
    jr nz, :-
    ei
    ret
.end
    ENDL
