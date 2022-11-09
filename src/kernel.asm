;;KERNEL
;;

    ;;Print menu heading
main_menu:
    call reset_text_screen

    mov si, menu_string  ;hex num to print
    call print_string

    ;;Get user input
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
    cmp al, 'R'         ;'warm' reboot
    je reboot     
    cmp al, 'P'         ;print register value
    je print_register
    cmp al, 'G'
    je graphics_test
    cmp al, 'N'         ;cpu halt
    je end_program
    mov si, error
    call print_string
    jmp get_input

file_browser:
    ;;Reset screen
    call reset_text_screen

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
    mov si, go_back
    call print_string

    mov ah, 0x00
    int 0x16        ; get keystroke
    jmp main_menu

reboot:
    jmp 0xFFFF:0x0000

print_register:
    call reset_text_screen
    ;;print register values
    mov si, register_header
    call print_string

    call print_registers

    mov si, go_back
    call print_string
    mov ah, 0x00
    int 0x16
    jmp main_menu
 
 ;;graphics mode test
graphics_test:
    call reset_graphics_screen

    ;;Square
    mov ah, 0x0C    ;gfx pixel
    mov al, 0x01    ;color
    mov bh, 0x00    ;page nr.

    mov cx, 100    ;column
    mov dx, 100   ;row
    int 0x10

square_loop:
    inc cx
    int 0x10
    cmp cx, 150
    jne square_loop

    ;Go down 1 row
    inc dx
    int 0x10
    mov cx, 99
    cmp dx, 150
    jne square_loop

    mov ah, 0x00
    int 0x16
    jmp main_menu

end_program:
    ;;end_pgm
    cli         ;clear interrups
    hlt         ;halt cpu == better than jmp $

;;Include
    include './print/print_string.asm'
    include './print/print_hex.asm'
    include './print/print_registers.asm'
    include './screen/reset_screen_txtm.asm'
    include './screen/reset_screen_gfxm.asm'

;; Strings
menu_string:    db '<--------------->', 0xA, 0xD,'Welcome to bitOS!', 0xA, 0xD, 0xA, 0xD, 0xA, 0xD,\
                'Commands:',0xA, 0xD, 0xA, 0xD, \
                'F> File Browser', 0xA, 0xD, \
                'R> Reboot', 0xA, 0xD,\
                'G> Graphics test', 0xA, 0xD,\
                'P> Print Register Values', 0xA, 0xD, \
                'N> Halt CPU', 0xA, 0xD, 0

success:        db 0xA, 0xD,'command executed successfully', 0xA, 0xD, 0

error:          db 0xA, 0xD,'command not found', 0xA, 0xD, 0

file_table_header:  db '------------       ------',0xA, 0xD,\
                    'File\Program       Sector', 0xA, 0xD, \
                    '------------       ------', 0xA, 0xD, 0

register_header:    db '-------- ---------------', 0xA, 0xD, \
                    'Register Memory location', 0xA, 0xD, \
                    '-------- ---------------', 0xA, 0xD, 0

go_back:        db 0xA, 0xD, 0xA, 0xD,'Press any key to go back..',0xA, 0xD, 0xA, 0xD, 0

cmd_string:     db ''

;; Fill-out
    times 1024-($-$$) db 0