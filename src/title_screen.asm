INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"

SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]
Cursor:
.y
    ds 1
.x
    ds 1
.tile
    ds 1
.attr
    ds 1

SECTION UNION "TitleScreenData", WRAM0
MenuSelection:
    ds 1

SECTION "TitleScreen", ROMX, BANK[1]
TitleScreen::
    call ResetScreen
    memCopy _VRAM + $800, TitleBanner

    ld a, 3
    ld [DrawBox.x], a
    ld a, 6
    ld [DrawBox.y], a
    ld a, 14
    ld [DrawBox.width], a
    ld a, 3
    ld [DrawBox.height], a
    ld a, $80
    ld [DrawBox.tileOffset], a
    ld de, TitleBannerMap
    ld hl, _SCRN0
    call BlitTiles

    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    ld a, 8 * 8
    ld [rSCY], a
.animateIn:
    call WaitVBlankEnd
    call WaitVBlank
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    jr nz, .animateIn
.drawMenu:
    tileBlitRow _SCRN0, 6, 12, textContinue
    tileBlitRow _SCRN0, 6, 14, textNewGame

    ld a, 2
    ld [DrawBox.x], a
    ld a, 10
    ld [DrawBox.y], a
    ld a, 16
    ld [DrawBox.width], a
    ld a, 7
    ld [DrawBox.height], a
    ld hl, _SCRN0
    call DrawWindowFrame

    ld a, OAM_X_OFS + 40
    ld [Cursor.x], a
    ld a, OAM_Y_OFS + 12 * 8
    ld [Cursor.y], a
    ld a, CursorTile
    ld [Cursor.tile], a
    ld a, 0
    ld [MenuSelection], a

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

.loop:
    call WaitVBlankEnd
    call WaitVBlank
    call UpdateGamepad

    ld a, [GamepadJustPressed]
    and PADF_UP
    jr z, :+
    ld a, [MenuSelection]
    cp a, 0
    jr z, :+
    dec a
    ld [MenuSelection], a
    ld a, [Cursor.y]
    sub 2 * 8
    ld [Cursor.y], a
:
    ld a, [GamepadJustPressed]
    and PADF_DOWN
    jr z, :+
    ld a, [MenuSelection]
    cp a, 1
    jr z, :+
    inc a
    ld [MenuSelection], a
    ld a, [Cursor.y]
    add 2 * 8
    ld [Cursor.y], a
:
    ld a, [GamepadJustPressed]
    and PADF_A

    call DMATransfer
    jp .loop

textContinue:
    db "Continue"
.end:

textNewGame:
    db "New Game"
.end:

TitleBanner:
    INCBIN "title.2bpp"
.end:

TitleBannerMap:
    INCBIN "title.tilemap"
.end: