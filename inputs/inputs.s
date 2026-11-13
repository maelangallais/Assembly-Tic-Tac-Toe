
.extern getch
.extern printf

.section .data
.section .data
fmt_normal:  .asciz "Touche ASCII: %d\n"
fmt_special: .asciz "Touche speciale: %d\n"

.section .text
.globl main
main:
    mov $0, %r15d

main_loop:
    sub $8, %rsp

    call getch
    movzx %al, %edx

    cmp $0, %edx
    je special_key
    cmp $0xE0, %edx
    je special_key

    leaq fmt_normal(%rip), %rcx
    xor %eax, %eax
    call printf
    jmp end

special_key:
    call getch
    movzx %al, %edx
    leaq fmt_special(%rip), %rcx
    xor %eax, %eax
    call printf

end:
    add $8, %rsp

    inc %r15d
    cmp $5, %r15d
    jl main_loop

    mov $0, %eax
    ret
