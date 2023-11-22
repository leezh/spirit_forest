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
    and a, $F
    xor a, $F
    ld b, a

    ; Get DPad states
    ld a, P1F_GET_DPAD
    ld [rP1], a
    REPT 5
        ld a, [rP1]
    ENDR
    and a, $F
    xor a, $F
    swap a
    or a, b
    ld b, a

    ; Calculate and write state
    ld a, [GamepadPressed]
    xor a, b
    ld c, a
    and a, b
    ld [GamepadJustPressed], a
    ld a, b
    ld [GamepadPressed], a
    xor $FF
    and a, c
    ld [GamepadJustReleased], a
    ret
