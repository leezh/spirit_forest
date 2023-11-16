INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"

SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]
CursorLeft:
    ds 4
CursorRight:
    ds 4

SECTION UNION "TitleScreenData", WRAM0
MenuSelection:
    ds 1

SECTION "TitleScreen", ROMX, BANK[1]
TitleScreen::
    resetVideo
    tileBlitRow _SCRN0, 4, 8, textTitle
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
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01 | LCDCF_OBJON
    ld [rLCDC], a

    ld a, OAM_X_OFS + 4 * 8
    ld [CursorLeft + 1], a
    ld a, "["
    ld [CursorLeft + 2], a
    ld a, SCRN_X - 4 * 8
    ld [CursorRight + 1], a
    ld a, "]"
    ld [CursorRight + 2], a
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
    ld a, OAM_Y_OFS + 12 * 8
    :
    add 16
    dec b
    jr nz, :-
    sub 16
    ld [CursorLeft], a
    ld [CursorRight], a

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