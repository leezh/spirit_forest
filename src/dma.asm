INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]
ShadowOAM::
    ds 4 * OAM_COUNT


SECTION "InitDMATransfer", ROM0
InitDMATransfer::
    memLoad DMATransfer, DMATransferRoutine
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
