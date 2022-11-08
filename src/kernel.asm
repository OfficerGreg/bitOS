;;KERNEL
;;
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x01
    int 0x10
    ;;Set/Change Color
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    ;;Print menu heading
    mov si, menu_string  ;hex num to print
    call print_string

    ;;Get user input
    push di             ;store si on stack

get_input:
    mov di, cmd_string

keyloop:
    mov ax, 0x00
    int 0x16              ;BIOS keystroke

    mov ah, 0x0e
    cmp al, 0xD         ;did user press enter?
    je exec_command 
    int 0x10
    mov [di], al
    inc di
    jmp keyloop         ;loop for next char
    
exec_command:
    mov byte [di], 0
    mov al, [cmd_string]
    cmp al, 'F'       ;file table command
    jne not_found
    cmp al, 'N'
    je end_program
    mov si, success
    call print_string
    jmp get_input

not_found:
    mov si, error
    call print_string
    jmp get_input


print_string:
    mov ah, 0x0e
    mov bh, 0x0
    mov bl, 0x07

print_char:
    mov al, [si]
    cmp al, 0
    je end_print
    int 0x10
    inc si
    jmp print_char

end_print:
    ret

end_program:
    ;;end_pgm
    cli         ;clear interrups
    hlt         ;halt cpu == better than jmp $
menu_string:    db '<--------------->', 0xA, 0xD,'Welcome to bitOS!', 0xA, 0xD,0xA, 0xD, 0xA, 0xD, 0xA, 0xD, \
                'F> File Browser', 0xA, 0xD, 0
success:        db 0xA, 0xD,'command executed successfully', 0xA, 0xD,0
error:          db 0xA, 0xD,'command not found', 0xA, 0xD, 0
cmd_string:     db ''
    times 510-($-$$) db 0