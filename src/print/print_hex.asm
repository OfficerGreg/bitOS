;;Prints hexadecimal values using register DX
;;ASCII '0' -'9' = HEX '0x30'-'0x39'
;;ASCII 'A' - 'F' = HEX '0x41' - '0x46'

print_hex:
    pusha           ;save all registers
    mov cx, 0   

hex_loop:
    cmp cx, 4       ;
    je end_hex_loop
    ;;Convert DX HEX to ASCII
    mov ax, dx
    and ax, 0x000F
    add al, 0x30
    cmp al, 0x39    ;is hex value 0-9?
    jle move_intoBX
    add al, 0x7

move_intoBX:
    mov bx, hexString + 5
    sub bx, cx
    mov [bx], al
    ror dx, 4               ;rotate right 4 bits

    add cx, 1
    jmp hex_loop            ;loop next digit

end_hex_loop:
    mov bx, hexString
    call print_string

    popa            ;restore all registers
    ret             ;return to caler

    ;;Data
hexString:  db '0x0000', 0