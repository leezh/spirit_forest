INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]

ShadowOAM::
    ds 4 * OAM_COUNT


SECTION "Video Parameters", WRAM0

WindowFrameTiles::
.topLeft::
    ds 1
.topRight::
    ds 1
.bottomLeft::
    ds 1
.bottomRight::
    ds 1
.horizontal::
    ds 1
.vertical::
    ds 1

DrawBox::
.x::
    ds 1
.y::
    ds 1
.width::
    ds 1
.height::
    ds 1

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

DrawWindowFrame::
    ld a, [DrawBox.width]
    cp a, 3
    ret c
    ld a, [DrawBox.height]
    cp a, 3
    ret c

    ld bc, SCRN_VX_B
    ld a, [DrawBox.y]
    cp a, 0
:
    jr z, :+
    add hl, bc
    dec a
    jr :-
:
    ld a, [DrawBox.x]
    ld d, 0
    ld e, a
    add hl, de
    push hl
    ld a, [WindowFrameTiles.topLeft]
    ld [hli], a

    ld a, [DrawBox.width]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.horizontal]
:
    ld [hli], a
    dec d
    jr nz, :-

    ld a, [WindowFrameTiles.topRight]
    ld [hl], a

    ld a, [DrawBox.height]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.vertical]
    add hl, bc
:
    ld [hl], a
    add hl, bc
    dec d
    jr nz, :-

    ld a, [WindowFrameTiles.bottomRight]
    ld [hld], a

    ld a, [DrawBox.width]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.horizontal]
:
    ld [hld], a
    dec d
    jr nz, :-

    ld a, [WindowFrameTiles.bottomLeft]
    ld [hl], a

    pop hl
    ld a, [DrawBox.height]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.vertical]
:
    add hl, bc
    ld [hl], a
    dec d
    jr nz, :-

    ret

SECTION "InitVideo", ROMX, BANK[1]

InitVideo::
    call ResetScreen
    memLoad DMATransfer, DMATransferRoutine
    memSet _VRAM, $00, $2000
    memCopy2X _VRAM + $1200, Font
    memCopy2X _VRAM + CursorTile * $10, Font + ("~" - " ") * $8, $8
    memCopySmall WindowFrameTiles, defaultWindowFrameTiles
    ret


defaultWindowFrameTiles:
    db "[]\{\}\\|"
.end


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
