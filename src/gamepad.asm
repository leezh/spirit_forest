INCLUDE "ext/hardware.inc"

SECTION "Gamepad WRAM variables", WRAM0

; Bitfield of currently pressed buttons.
GamepadPressed::
    ds 1

; Bitfield of buttons pressed since last update.
GamepadJustPressed::
    ds 1

; Bitfield of buttons released since last update.
GamepadJustReleased::
    ds 1

SECTION "Gamepad", ROM0

; Reads the gamepad state and saves it to the following locations in WRAM:
; * GamepadPressed      - Bitfield of currently pressed buttons.
; * GamepadJustPressed  - Bitfield of buttons pressed since last update.
; * GamepadJustReleased - Bitfield of buttons released since last update.
;
; You can use bitwise AND with PADF_* constants to check individual buttons.
UpdateGamepad::
    ; Get ABStartSelect states
    ld a, P1F_GET_BTN
    ld [rP1], a
    REPT 5
        ld a, [rP1]
    ENDR
    ld a, [rP1]
    and $F
    xor $F
    ld b, a

    ; Get DPad states
    ld a, P1F_GET_DPAD
    ld [rP1], a
    REPT 5
        ld a, [rP1]
    ENDR
    REPT 4
        sla a
    ENDR
    xor $F0
    or b
    ld b, a

    ; Calculate and write state
    ld a, [GamepadPressed]
    xor b
    ld c, a
    and b
    ld [GamepadJustPressed], a
    ld a, b
    ld [GamepadPressed], a
    xor $FF
    and c
    ld [GamepadJustReleased], a
