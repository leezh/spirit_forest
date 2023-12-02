DEF _ShadowOAM EQU $CF00
DEF CursorTile = $FE

MACRO staticPrint
    jr .strEnd\@
.str\@
    db \1
.strEnd\@
    ld a, STRLEN(\1)
    ld [DrawBox.width], a
    ld a, 1
    ld [DrawBox.height], a
    ld de, .str\@
ENDM

MACRO structOAM
.y
    db
.x
    db
.tile
    db
.attr
    db
ENDM
