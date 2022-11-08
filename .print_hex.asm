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
    shr ax, 4


end_hex_loop:
    popa            ;restore all registers
    ret             ;return to caler

    ;;Data
hexString:  dx '0x0000', 0