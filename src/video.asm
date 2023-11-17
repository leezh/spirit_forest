INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]
ShadowOAM::
    ds 4 * OAM_COUNT


SECTION "InitVideo", ROM0
InitVideo::
    memLoad DMATransfer, DMATransferRoutine
    memSet _VRAM, $00, $2000
ResetScreen::
    ld a, 0
    ld [rLCDC], a
    ld [rSCX], a
    ld [rSCY], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    memSet _SCRN0, $00, $400
    memSet _ShadowOAM, $00, $FF
    ret


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
