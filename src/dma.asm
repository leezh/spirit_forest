INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"

SECTION "InitDMATransfer", ROM0
InitDMATransfer::
    memCopy DMATransfer, DMATransferRoutine, DMATransfer.end - DMATransfer
    ret


DMATransferRoutine:
    LOAD "DMATransfer", HRAM
DMATransfer::
    di
    ld a, $C1
    ld [rDMA], a
    ld a, OAM_COUNT
:
    dec a
    jr nz, :-
    ei
    ret
.end
    ENDL
