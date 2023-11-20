DEF _ShadowOAM EQU $CF00

; Waits until screen blank
MACRO waitVBlank
:
    ld a, [rLY]
    cp a, SCRN_Y
    jr c, :-
ENDM


; Waits until screen blank ends
MACRO waitVBlankEnd
:
    ld a, [rLY]
    cp a, SCRN_Y
    jr nc, :-
ENDM


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
        ld b, \4 + $0101
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


DEF WindowTopLeft = "["
DEF WindowTopRight = "]"
DEF WindowBottomLeft = "\{"
DEF WindowBottomRight = "\}"
DEF WindowHorizontal = "\\"
DEF WindowVertical = "|"

; Draws a window frame using the built-in bitmap font.
;
; Args:
; * pSCRN  - Pointer to the tilemap to blit to.
; * x      - The x-coordinate of the top-left corner.
; * y      - The y-coordinate of the top-right corner.
; * w      - Width of the window.
; * h      - Height of the window.
;
; Specify the tiles used by redefining these:
; * WindowTopLeft
; * WindowTopRight
; * WindowBottomLeft
; * WindowBottomLeft
; * WindowHorizontal
; * WindowVertical
MACRO drawWindowFrame
    ld de, \1 + SCRN_VX_B * \3 + \2
    ld a, WindowTopLeft
    ld [de], a
    ld a, WindowHorizontal
    REPT \4 - 2
        inc de
        ld [de], a
    ENDR
    ld de, \1 + SCRN_VX_B * \3 +  (\2 + \4 - 1)
    ld a, WindowTopRight
    ld [de], a

    ld de, \1 + SCRN_VX_B * (\3 + \5 - 1) + \2
    ld a, WindowBottomLeft
    ld [de], a
    ld a, WindowHorizontal
    REPT \4 - 2
        inc de
        ld [de], a
    ENDR
    ld de, \1 + SCRN_VX_B * (\3 + \5 - 1) + (\2 + \4 - 1)
    ld a, WindowBottomRight
    ld [de], a

    ld a, WindowVertical
    FOR V, \3 + 1, \3 + \5 - 1
        ld de, \1 + SCRN_VX_B * V + \2
        ld [de], a
        ld de, \1 + SCRN_VX_B * V + (\2 + \4 - 1)
        ld [de], a
    ENDR
ENDM
