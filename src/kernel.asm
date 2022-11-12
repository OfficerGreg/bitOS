;;
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
    je get_program
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

get_program:
    mov ah, 0x0e    ;newline
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10
    mov di, cmd_string
    mov byte [cmd_length], 0

program_name_loop:  ;get next char until user presses enter key
    mov ax, 0x00
    int 0x16              ;BIOS keystroke

    mov ah, 0x0e
    cmp al, 0xD         ;did user press enter?
    je start_search

    inc byte [cmd_length]
    mov [di], al
    inc di
    int 0x10
    jmp program_name_loop


start_search:
    mov di, cmd_string
    xor bx, bx

check_next_char:
    mov al, [ES:BX]   ; di points to file table
    cmp al, '}'
    je program_not_found    ;1 == not found

    cmp al, [di]            ;does user input match? 
    je start_compare

    inc bx
    jmp check_next_char

start_compare:
    push bx
    mov byte cl, [cmd_length]

compare_loop:
    mov al, [ES:BX]
    inc bx
    cmp al, [di]
    jne restart_search

    dec cl
    jz program_found    
    inc di
    jmp compare_loop

restart_search:
    mov di, cmd_string
    pop bx
    inc bx
    jmp check_next_char

program_not_found:
    mov si, not_found_string
    call print_string
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 'Y'
    je file_browser
    jmp file_table_end

program_found:
    inc bx
    mov cl, 10              ; use to get sector number
    xor al, al   

next_sector_number:
    mov dl, [ES:BX]         ; checking next byte of file table
    inc bx                  
    cmp dl, ','             ; at end of sector number?
    je program_load        ; if so, load program from that sector
    cmp dl, 48              ; else, check if al is '0'-'9' in ascii
    jl sector_not_found     ; before '0', not a number
    cmp dl, 57              
    jg sector_not_found     ; after '9', not a number
    sub dl, 48              ; convert ascii char to integer
    mul cl                  ; al * cl (al * 10), result in AH/AL (AX)
    add al, dl              ; al = al + dl
    jmp next_sector_number

sector_not_found:
    mov si, sector_not_found; did not find program name in file table
    call print_string
    mov ah, 0x00            ; get keystroke, print to screen
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 'Y'
    je file_browser          ; reload file browser screen to search again
    jmp file_table_end       ; else go back to main menu

program_load:
    mov cl, al              ; cl = sector # to start loading/reading at

    mov ah, 0x00            ; int 13h ah 0 = reset disk system
    mov dl, 0x00
    int 0x13

    mov ax, 0x8000          ; memory location to load pgm to
    mov es, ax
    xor bx, bx              ; ES:BX -> 0x8000:0x0000

    mov ah, 0x02            ; int 13 ah 02 = read disk sectors to memory
    mov al, 0x01            ; # of sectors to read
    mov ch, 0x00            ; track #
    mov dh, 0x00            ; head #
    mov dl, 0x00            ; drive #

    int 0x13
    jnc program_loaded       ; carry flag not set, success

    mov si, not_loaded       ; else error, program did not load correctly
    call print_string
    mov ah, 0x00
    int 0x16
    jmp file_browser         ; reload file table

program_loaded:
    mov ax, 0x8000          ; program loaded, set segment registers to location
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x8000:0x0000        ; far jump to prog

file_table_end:       ;loop for next char
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

success:        db 0xA, 0xD,'Program found', 0xA, 0xD, 0

error:          db 0xA, 0xD,'command not found', 0xA, 0xD, 0

not_loaded:     db 0xA, 0xD, 'Error! Program not loaded, Try Again', 0xA, 0xD, 0

file_table_header:  db '------------       ------',0xA, 0xD,\
                    'File\Program       Sector', 0xA, 0xD, \
                    '------------       ------', 0xA, 0xD, 0

register_header:    db '-------- ---------------', 0xA, 0xD, \
                    'Register Memory location', 0xA, 0xD, \
                    '-------- ---------------', 0xA, 0xD, 0

not_found_string:   db 0xA,0xD,'program not found!, try again? (Y)', 0xA, 0xD, 0

not_found_sector:   db 0xA,0xD,'sector not found!, try again? (Y)',0xA,0xD, 0

cmd_length: db 0

go_back:        db 0xA, 0xD, 0xA, 0xD,'Press any key to go back..',0xA, 0xD, 0xA, 0xD, 0

dbg_test:       db 'Test', 0

cmd_string:     db '',0

;; Fill-out
    times 1536-($-$$) db 0