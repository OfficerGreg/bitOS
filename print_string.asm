print_string:
    pusha	;; store all register values onto stack               

print_char:
	mov al, [bx]
    cmp al, 0
    je end_print
    int 0x10
    add bx, 1
    jmp print_char

    
end_print:
    popa	;; restore register from the stack before returning
	ret
