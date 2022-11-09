;Print string in SI register
print_string:
    pusha           
    mov ah, 0x0e    ;BIOS teletype output
    mov bh, 0x0     
    mov bl, 0x07    ;color

print_char:
    lodsb
    cmp al, 0
    je end_print
    int 0x10
    jmp print_char

end_print:
    popa
    ret