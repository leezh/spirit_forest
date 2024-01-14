; Sets each byte in a memory range to a specified value.
;
; Args:
; * pDest - Pointer to the destination data.
; * value - Value to fill the data with.
; * size  - Size of the data to fill in bytes.
MACRO memSet
    ASSERT \3 > 0
    ld hl, \1
    ld a, \2
    IF \3 > $FF
        ld bc, \3
    ELSE
        ld b, \3
    ENDC
.memSetLoop\@
    ld [hli], a
    IF \3 > $FF
        dec c
        jr nz, .memSetLoop\@
    ENDC
    dec b
    jr nz, .memSetLoop\@
ENDM
