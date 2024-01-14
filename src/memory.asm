INCLUDE "ext/hardware.inc"

SECTION "Memory", ROM0

; Copies a block of data from one memory range to another.
;
; Registers:
; * bc - Size of the source data. Must not be 0.
; * de - Pointer to the source data.
; * hl - Pointer to the destination data.
MemCopy::
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, MemCopy
    ld a, b
    cp a, 0
    ret z
    dec b
    jr MemCopy


; Copies data from one memory range to another, duplicating each byte along
; the way. This is useful for converting 1bpp tile data to 2bpp tile data.
;
; Registers:
; * bc - Size of the source data. Must not be 0.
; * de - Pointer to the source data.
; * hl - Pointer to the destination data.
MemCopy2X::
    ld a, [de]
    ld [hli], a
    ld [hli], a
    inc de
    dec c
    jr nz, MemCopy2X
    ld a, b
    cp a, 0
    ret z
    dec b
    jr MemCopy2X
