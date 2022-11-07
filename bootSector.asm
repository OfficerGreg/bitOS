;;BASIC BOOT SECTOR 

    org 0x7c00  ;Boot Code origin
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x01
    int 0x10
    ;;Set/Change Color
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    mov ah, 0x0e
    mov bx, msg1

    call print_string
    mov bx, msg2
    call print_string
    
    ;;end_pgm
    jmp $
    ;;Include
    include 'print_string.asm'
	include 'print_hex.asm'

msg1:   db 'WHO IS THE IMPOSTOR????????', 0xA, 0xD, 0
msg2:   db 'THE IMPOSTOR IS', 0xA, 0xD, 0



    times 510-($-$$) db 0

    dw 0xaa55
