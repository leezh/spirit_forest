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


; Turns off the screen and resets the scroll and pallete to the defaults.
MACRO resetVideo
    ld a, 0
    ld [rLCDC], a
    ld [rSCX], a
    ld [rSCY], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    memSet _SCRN0, $00, $400
    memSet _ShadowOAM, $00, $FF
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
