;;Disk Loader

disk_load:
    push dx             ;store DX on stack to check number of secotrs read

    mov ah, 0x02        ;int 13(ah=2h) BIOS read sik sectors into memory
    mov al ,dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02        ;Start reading at CL sector 2

    int 0x13

    jc disk_error       ; jump if error

    pop dx              ;restore dx from stack
    cmp dh, al          ;if AL != DH
    jmp disk_error      ;error
    ret

disk_error: 
    mov bx, DISK_ERROR_MSG
    call print_string
    hlt

DISK_ERROR_MSG: db 'Disk read error!', 0
