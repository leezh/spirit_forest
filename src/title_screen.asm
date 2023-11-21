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
    tileBlit _SCRN0, 3, 6, 14, 3, TitleBannerMap, $80
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01
    ld [rLCDC], a
    ld a, 8 * 8
    ld [rSCY], a
.animateIn:
    waitVBlankEnd
    waitVBlank
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    jr nz, .animateIn
    
    tileBlitRow _SCRN0, 6, 12, textNewGame
    tileBlitRow _SCRN0, 6, 14, textContinue
    drawWindowFrame _SCRN0, 2, 10, 16, 7
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01 | LCDCF_OBJON
    ld [rLCDC], a

    ld a, OAM_X_OFS + 40
    ld [Cursor.x], a
    ld a, "~"
    ld [Cursor.tile], a
    ld a, 1
    ld [MenuSelection], a

.loop:
    call UpdateGamepad

    ld a, [GamepadJustPressed]
    and PADF_UP
    jr z, :+
    ld a, [MenuSelection]
    cp a, 1
    jr z, :+
    dec a
    ld [MenuSelection], a
    :
    ld a, [GamepadJustPressed]
    and PADF_DOWN
    jr z, :+
    ld a, [MenuSelection]
    cp a, 2
    jr z, :+
    inc a
    ld [MenuSelection], a
    :
    ld a, [MenuSelection]
    ld b, a
    ld a, OAM_Y_OFS + (12 - 2) * 8
    :
    add 2 * 8
    dec b
    jr nz, :-
    ld [Cursor.y], a

    waitVBlank
    call DMATransfer
    jp .loop


textTitle:
    db "SpiritForest"
.end:

textNewGame:
    db "New Game"
.end:

textContinue:
    db "Continue"
.end:

TitleBanner:
    INCBIN "title.2bpp"
.end:

TitleBannerMap:
    INCBIN "title.tilemap"
.end: