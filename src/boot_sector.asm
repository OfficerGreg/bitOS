;;basic boot loader(INT 13)FASM
    org 0x7c00          ;Boot Code origin
    
    ;;Read file table into memory

    ;;ES:BX setup
    mov bx, 0x1000
    mov es, bx
    mov bx, 0x0
    
    mov dh, 0x0
    mov dl, 0x0
    mov ch, 0x0
    mov cl, 0x02

read_disk1:
    mov ah, 0x02
    mov al, 0x01
    int 0x13

    jc read_disk1

    mov bx, 0x2000
    mov es, bx
    mov bx, 0x0

    ;;Disk read
    mov dh, 0x0
    mov dl, 0x0
    mov ch, 0x0
    mov cl, 0x03

read_disk2:
    mov ah, 0x02
    mov al, 0x01
    int 0x13

    jc read_disk2

    ;;Read kernel into memory

    mov ax, 0x2000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x2000:0x0

    times 510-($-$$) db 0

    dw 0xaa55