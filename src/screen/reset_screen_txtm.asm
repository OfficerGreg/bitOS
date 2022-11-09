 reset_text_screen:
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x03    ;size
    int 0x10
    ;;Set/Change Color
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    ret