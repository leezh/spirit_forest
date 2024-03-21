INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION "Level Variables", WRAM0

Level:
.address::
    dw
.width
    db
.height
    db
.dataAddress
    dw

Blockset:
.dataAddress
    dw
.drawX
    db
.drawY
    db

SECTION "Level", ROM0

LoadLevel::
    call ResetScreen

    ld a, [Level.address]
    ld c, a
    ld a, [Level.address + 1]
    ld b, a
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a

    inc bc
    ld a, [bc]
    ld [Level.height], a
    inc bc
    ld a, [bc]
    ld [Level.width], a
    inc bc
    ld a, c
    ld [Level.dataAddress], a
    ld a, b
    ld [Level.dataAddress + 1], a

    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, l
    ld [Blockset.dataAddress], a
    ld a, h
    ld [Blockset.dataAddress + 1], a

    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc de
    ld hl, _VRAM
    call MemCopy

    FOR X, 16
        FOR Y, 16
            ld a, X
            ld [Blockset.drawX], a
            ld a, Y
            ld [Blockset.drawY], a
            call DrawBlock
        ENDR
    ENDR

    call DMATransfer
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01 | LCDCF_OBJON
    ldh [rLCDC], a

.loop
    call WaitVBlankEnd
    call WaitVBlank
    call UpdateGamepad

    call DMATransfer
    jr .loop

DrawBlock:
    ld a, [Level.dataAddress]
    ld l, a
    ld a, [Level.dataAddress + 1]
    ld h, a

    ld a, [Level.width]
    ld c, a
    ld b, 0

    ld a, [Blockset.drawY]
    cp a, 0
.moveY
    jr z, .moveX
    add hl, bc
    dec a
    jr .moveY
.moveX
    ld a, [Blockset.drawX]
    ld c, a
    add hl, bc

    ld a, [hl]
    ld c, a
    sla c
    rl b
    sla c
    rl b

    ld a, [Blockset.dataAddress]
    ld l, a
    ld a, [Blockset.dataAddress + 1]
    ld h, a
    add hl, bc
    ld e, l
    ld d, h

    ld hl, _SCRN0
    ld a, [Blockset.drawX]
    sla a
    and a, 31
    ld [DrawBox.x], a
    ld a, [Blockset.drawY]
    sla a
    and a, 31
    ld [DrawBox.y], a
    ld a, 2
    ld [DrawBox.width], a
    ld [DrawBox.height], a
    ld a, 0
    ld [DrawBox.tileOffset], a
    call BlitTiles
    ret

SECTION "MapBank1", ROMX

TestLevel::
    dw OverworldBlockset
    INCBIN "data/levels/test_level.lvl"

OverworldBlockset:
    dw OverworldTileset
    INCBIN "data/tilesets/overworld.blk"

OverworldTileset:
    dw .end - OverworldTileset - 2
    INCBIN "data/images/overworld.2bpp"
.end