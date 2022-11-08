;;KERNEL
;;
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x02
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
    cmp al, 'F'         ;file table command
    je file_browser
    cmp al, 'R'    
    je reboot          ;'warm' reboot
    cmp al, 'N'         ;cpu halt
    je end_program
    mov si, error
    call print_string
    jmp get_input

file_browser:
    ;;Reset screen
    ;;Set video mode
    mov ah, 0x00
    mov al, 0x02
    int 0x10
    ;;Set/Change Color
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x01
    int 0x10

    mov si, file_table_header
    call print_string

    xor cx, cx
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x0e    

file_table_loop:
    inc bx
    mov al, [ES:BX]
    cmp al, '}'
    je stop
    cmp al, '-'
    je section_number_loop
    cmp al, ','
    je next_element
    inc cx
    int 0x10
    jmp file_table_loop

section_number_loop:
    cmp cx, 21
    je file_table_loop
    mov al, ' '
    int 0x10
    inc cx
    jmp section_number_loop

next_element:
    xor cx, cx
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    jmp file_table_loop

stop:
    hlt

reboot:
    jmp 0xFFFF:0x0000

end_program:
    ;;end_pgm
    cli         ;clear interrups
    hlt         ;halt cpu == better than jmp $

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

menu_string:    db '<--------------->', 0xA, 0xD,'Welcome to bitOS!', 0xA, 0xD,0xA, 0xD, 0xA, 0xD, 0xA, 0xD, \
                'F> File Browser', 0xA, 0xD, \
                'R> Reboot', 0xA, 0xD, 0

success:        db 0xA, 0xD,'command executed successfully', 0xA, 0xD, 0

error:          db 0xA, 0xD,'command not found', 0xA, 0xD, 0

file_table_header:  db '------------       ------',0xA, 0xD,\
                    'File\Program       Sector', 0xA, 0xD, \
                    '------------       ------', 0xA, 0xD, 0
cmd_string:     db ''


    times 510-($-$$) db 0