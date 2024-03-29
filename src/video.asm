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
.tileOffset::
    ds 1

SECTION "Video", ROM0

; Turns off the LCD, clears the BG/WIN tiles and sets video parameters to
; sensible defaults.
ResetScreen::
    ld a, 0
    ldh [rLCDC], a
    ldh [rSCX], a
    ldh [rSCY], a
    ldh [rWX], a
    ld a, WX_OFS
    ldh [rWY], a

    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    ldh [rOBP1], a

    memSet _SCRN0, $FF, $400
    memSet _ShadowOAM, $00, $FF
    ret

; Transfers tiles to the specified tilemap.
;
; Registers:
; * de - Pointer to tile indices to read from
; * hl - Pointer to tilemap to write to
;
;
; WRAM Variables Used:
; * DrawBox.x
; * DrawBox.y
; * DrawBox.width
; * DrawBox.height
; * DrawBox.tileOffset
BlitTiles::
    ld a, [DrawBox.height]
    cp a, 0
    ret z

    ld bc, SCRN_VX_B
    ld a, [DrawBox.y]
    cp a, 0
.moveY
    jr z, .moveX
    add hl, bc
    dec a
    jr .moveY
.moveX
    ld a, [DrawBox.x]
    ld c, a
    add hl, bc
.drawRow
    ld a, [DrawBox.width]
    cp a, 0
    ret z
    ld c, a
    ld a, [DrawBox.tileOffset]
    ld b, a
.drawTile
    ld a, [de]
    inc de
    add a, b
    ld [hli], a
    dec c
    jr nz, .drawTile

    ld a, [DrawBox.height]
    dec a
    ret z
    ld [DrawBox.height], a

    ld a, [DrawBox.width]
    ld b, a
    ld a, SCRN_VX_B
    sub b
    ld b, 0
    ld c, a
    add hl, bc
    jr .drawRow


; Draws a window frame in the BG/WIN tilemap. Should be at least 3 tiles wide
; and at least 3 tiles high.
;
; Registers:
; * hl - Pointer to tilemap to write to
;
; WRAM Variables Used:
; * DrawBox.x
; * DrawBox.y
; * DrawBox.width
; * DrawBox.height
; * WindowFrameTiles.topLeft
; * WindowFrameTiles.topRight
; * WindowFrameTiles.bottomLeft
; * WindowFrameTiles.bottomRight
; * WindowFrameTiles.horizontal
; * WindowFrameTiles.vertical
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
.moveY
    jr z, .moveX
    add hl, bc
    dec a
    jr .moveY
.moveX
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
.topEdge
    ld [hli], a
    dec d
    jr nz, .topEdge
.topRight
    ld a, [WindowFrameTiles.topRight]
    ld [hl], a

    ld a, [DrawBox.height]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.vertical]
    add hl, bc
.rightEdge
    ld [hl], a
    add hl, bc
    dec d
    jr nz, .rightEdge

    ld a, [WindowFrameTiles.bottomRight]
    ld [hld], a

    ld a, [DrawBox.width]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.horizontal]
.bottomEdge
    ld [hld], a
    dec d
    jr nz, .bottomEdge

    ld a, [WindowFrameTiles.bottomLeft]
    ld [hl], a

    pop hl
    ld a, [DrawBox.height]
    sub a, 2
    ld d, a
    ld a, [WindowFrameTiles.vertical]
.leftEdge
    add hl, bc
    ld [hl], a
    dec d
    jr nz, .leftEdge

    ret


; Waits until screen blank
WaitVBlank::
    ld a, [rLY]
    cp a, SCRN_Y
    ret z
    jr WaitVBlank


; Waits until screen blank ends
WaitVBlankEnd::
    ld a, [rLY]
    cp a, SCRN_Y
    ret nz
    jr WaitVBlankEnd


; Waits for the specified number of frames to pass
;
; Registers:
; * a - The number of frames to wait
WaitFrames::
    ld b, a
    cp a, 0
.loop
    ret z
.waitVBlankEnd
    ld a, [rLY]
    cp a, SCRN_Y
    jr nz, .waitVBlankEnd
.waitVBlank
    ld a, [rLY]
    cp a, SCRN_Y
    jr z, .waitVBlank
    dec b
    jr .loop


; Runs a 15-frame screen fading animation using palette shifting. Shifts from
; standard to white.
FadeOut::
    ld a, %10010000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ld a, %01000000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ld a, %00000000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ret


; Runs a 15-frame screen fading animation using palette shifting. Shifts from
; white to standard.
FadeIn::
    ld a, %01000000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ld a, %10010000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, 5
    call WaitFrames
    ret


SECTION "InitVideo", ROMX, BANK[1]

; Clears the video memory and uploads video font maps and the OAM transfer
; routine.
InitVideo::
    call ResetScreen

    ld bc, DMATransfer.end - DMATransfer
    ld de, DMATransferRoutine
    ld hl, DMATransfer
    call MemCopy

    memSet _VRAM, $00, $2000

    ld bc, Font.end - Font
    ld de, Font
    ld hl, _VRAM + $1200
    call MemCopy2X

    ld bc, $8
    ld de, Font + ("~" - " ") * $8
    ld hl, _VRAM + CursorTile * $10
    call MemCopy2X

    ld bc, defaultWindowFrameTiles.end - defaultWindowFrameTiles
    ld de, defaultWindowFrameTiles
    ld hl, WindowFrameTiles
    call MemCopy

    ret


defaultWindowFrameTiles:
    db "[]\{\}\\|"
.end


Font:
    INCBIN "data/images/font.1bpp"
.end


DMATransferRoutine:
    LOAD "DMATransfer", HRAM

; Uploads the contents of the ShadowOAM to the GameBoy's internal sprite memory
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
