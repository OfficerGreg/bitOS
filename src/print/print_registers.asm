;;Print hex values in registers to screen

print_registers:
    mov si, reg_string
    call print_string
    call print_hex          ;dx

    mov byte [reg_string+2], 'a'
    call print_string
    mov dx, ax
    call print_hex          ;ax

    mov byte [reg_string+2], 'b'
    call print_string
    mov dx, bx
    call print_hex          ;bx

    mov byte [reg_string+2], 'c'
    call print_string
    mov dx, cx
    call print_hex          ;cx

    mov word [reg_string+2], 'si'
    call print_string
    mov dx, si
    call print_hex          ;si

    mov byte [reg_string+2], 'd'
    call print_string
    mov dx, di
    call print_hex          ;di

    mov word [reg_string+2], 'cs'
    call print_string
    mov dx, cs
    call print_hex          ;cs

    mov byte [reg_string+2], 'd'
    call print_string
    mov dx, ds
    call print_hex          ;ds

    mov byte [reg_string+2], 'e'
    call print_string
    mov dx, es
    call print_hex          ;es

    ret

reg_string: db 0xA, 0xD, 'dx           ',0