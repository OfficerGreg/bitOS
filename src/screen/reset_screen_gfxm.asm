reset_graphics_screen:
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x13    ;320x200 / 256 Colors gfx mode
    int 0x10

    ret