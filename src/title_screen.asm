INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"

SECTION UNION "ShadowOAM", WRAM0[_ShadowOAM]

Cursor:
    structOAM

SECTION UNION "TitleScreenData", WRAM0

MenuSelection:
    ds 1

SECTION "TitleScreen", ROMX, BANK[1]

TitleScreen::
    call ResetScreen

.drawBackground
    ld bc, TitleBanner.end - TitleBanner
    ld de, TitleBanner
    ld hl, _VRAM + $800
    call MemCopy

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
    ldh [rLCDC], a
    ld a, 8 * 8
    ld [rSCY], a

.animateIn
    call WaitVBlankEnd
    call WaitVBlank
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    jr nz, .animateIn

.drawMenu
    ld a, 6
    ld [DrawBox.x], a
    ld a, 12
    ld [DrawBox.y], a
    ld a, $0
    ld [DrawBox.tileOffset], a
    ld hl, _SCRN0
    staticPrint "Continue"
    call BlitTiles

    ld a, 14
    ld [DrawBox.y], a
    ld hl, _SCRN0
    staticPrint "New Game"
    call BlitTiles

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

    call DMATransfer
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a

.loop
    call WaitVBlankEnd
    call WaitVBlank
    call UpdateGamepad

    ldh a, [GamepadJustPressed]
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
    ldh a, [GamepadJustPressed]
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
    ldh a, [GamepadJustPressed]
    and PADF_A
    ld c, 3
    jr nz, .animateOut

    call DMATransfer
    jr .loop

.animateOut
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a
    ld a, 8
    call WaitFrames
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a
    ld a, 8
    call WaitFrames
    dec c
    jr nz, .animateOut

    call FadeOut

    ld a, LOW(TestLevel)
    ld [Level.address], a
    ld a, HIGH(TestLevel)
    ld [Level.address + 1], a
    ld a, BANK(TestLevel)
    ld [rROMB0], a
    jp LoadLevel

TitleBanner:
    INCBIN "data/images/title.2bpp"
.end

TitleBannerMap:
    INCBIN "data/images/title.tmap"
.end
