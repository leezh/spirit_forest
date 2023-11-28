DEF _ShadowOAM EQU $CF00

; Transfers one row of data to the specified tilemap. Useful for printing text.
;
; Args:
; * pSCRN   - Pointer to the tilemap to blit to.
; * x       - The x-coordinate of the text.
; * y       - The y-coordinate of the text.
; * w       - (Optional) Width of the source data. If empty we would assume
;             that `pSource` is a label and there is a local label `.end` to
;             mark the end of the data. Should be at most 20 tiles in length.
; * pSource - Pointer to the start of the data.
MACRO tileBlitRow
    ld de, \1 + SCRN_VX_B * \3 + \2
    IF _NARG == 5
        ld hl, \5
        ld b, \4 + $01
    ELSE
        ld hl, \4
        ld b, \4.end - \4 + $01
    ENDC
    jr :++
:
    ld a, [hli]
    ld [de], a
    inc de
:
    dec b
    jr nz, :--
ENDM


; Transfers data to the specified tilemap.
;
; Args:
; * pSCRN   - Pointer to the tilemap to blit to.
; * x       - The x-coordinate of the text.
; * y       - The y-coordinate of the text.
; * w       - Width of the source data
; * h       - Height of the source data.
; * pSource - Pointer to the start of the data.
; * offset  - Tile index offset
MACRO tileBlit
    ld de, \1 + SCRN_VX_B * \3 + \2
    ld b, \4 + $1
    ld hl, \6
    ld c, \5
    jr :++
:
    ld a, [hli]
    add a, \7
    ld [de], a
    inc de
:
    dec b
    jr nz, :--
    ld b, \4
    ld a, e
    add a, 32 - \4
    ld e, a
    jr nc, :+
    inc d
:
    dec c
    jr nz, :---
ENDM

DEF CursorTile = $FE
