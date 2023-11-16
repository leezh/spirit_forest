; Sets each byte in a memory range to a specified value.
;
; Args:
; * pDest - Pointer to the destination data.
; * value - Value to fill the data with.
; * size  - Size of the data to fill in bytes.
MACRO memSet
    ld hl, \1
    ld a, \2
    IF \3 > $FE
        ld bc, \3 + $101
    ELSE
        ld b, \3 + $1
    ENDC
    jr :++
:
    ld [hli], a
:
    IF \3 > $FE
        dec c
        jr nz, :--
    ENDC
    dec b
    jr nz, :--
ENDM


; Copies a block of data from one memory range to another.
;
; Args:
; * pDest   - Pointer to the destination data.
; * pSource - Pointer to the source data.
; * size    - (Optional) Size of the source data. If empty we would assume that
;             `pSource` is a label and there is a local label `.end` to mark
;             the end of the data.
MACRO memCopy
    ld de, \1
    ld hl, \2
    IF _NARG == 3
        ld bc, \3 + $101
    ELSE
        ld bc, \2.end - \2 + $101
    ENDC
    jr :++
:
    ld a, [hli]
    ld [de], a
    inc de
:
    dec c
    jr nz, :--
    dec b
    jr nz, :--
ENDM


; Copies a block of data from one memory range to another.
;
; Args:
; * pDest   - Pointer to the destination data.
; * pSource - Pointer to the source data.
; * size    - (Optional) Size of the source data. If empty we would assume that
;             `pSource` is a label and there is a local label `.end` to mark
;             the end of the data.
MACRO memCopySmall
    ld de, \1
    ld hl, \2
    IF _NARG == 3
        ld b, \3 + $1
    ELSE
        ld b, \2.end - \2 + $1
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


; Copies data from one memory range to another, duplicating each byte along
; the way. This is useful for converting 1bpp tile data to 2bpp tile data.
;
; Args:
; * pSource - Pointer to the source data.
; * pDest   - Pointer to the destination data.
; * size    - (Optional) Size of the source data. If empty we would assume that
;             `pSource` is a label and there is a local label `.end` to mark
;             the end of the data.
MACRO memCopy2X
    ld de, \1
    ld hl, \2
    IF _NARG == 3
        ld bc, \3 + $0101
    ELSE
        ld bc, \2.end - \2 + $0101
    ENDC
    jr :++
:
    ld a, [hli]
    ld [de], a
    inc de
    ld [de], a
    inc de
:
    dec c
    jr nz, :--
    dec b
    jr nz, :--
ENDM


; Loads a block of data from one memory range to another. Mainly for use in
; conjunction with labels and the `LOAD` assembly directive, e.g.:
; ```
;     SECTION "InitFunction", ROM0
;     InitFunction::
;         memLoad Function, FunctionData
;         ret
;     FunctionData:
;         LOAD "Function", HRAM
;     Function::
;         ; Code here
;     .end
;         ENDL
; ```
;
; Args:
; * pDest   - Pointer to the destination data. Should have a local label `.end`
;             to mark the end of the data
; * pSource - Pointer to the source data.
MACRO memLoad
    ld de, \1
    ld hl, \2
    ld bc, \1.end - \1 + $101
    jr :++
:
    ld a, [hli]
    ld [de], a
    inc de
:
    dec c
    jr nz, :--
    dec b
    jr nz, :--
ENDM
