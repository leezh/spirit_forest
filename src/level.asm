INCLUDE "ext/hardware.inc"
INCLUDE "memory.inc"
INCLUDE "video.inc"


SECTION "Level Variables", WRAM0

LevelAddress::
    dw

PlayerPosition:
.x::
    dw
.y::
    dw

SECTION "Level", ROM0

LoadLevel::
    call ResetScreen

    ld a, BANK(TestLevel)
    ld [rROMB0], a
    ld bc, OverworldTileset.end - OverworldTileset - 2
    ld de, OverworldTileset
    ld a, [de]
    inc de
    ld c, a
    ld a, [de]
    inc de
    ld b, a
    ld hl, _VRAM + $800
    call MemCopy

    call DMATransfer
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a

.loop:
    call WaitVBlankEnd
    call WaitVBlank
    call UpdateGamepad

    call DMATransfer
    jr .loop

LevelRegistry::
    db BANK("TestLevel")

SECTION "TestLevel", ROMX, BANK[2]

TestLevel::
    db 32
    db 32

SECTION "Overworld Tileset", ROMX, BANK[2]
OverworldTileset::
    dw .end - OverworldTileset - 3
    INCBIN "overworld.2bpp"
.end