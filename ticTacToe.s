
.extern printf
.extern getch
.extern GetStdHandle
.extern SetConsoleCursorPosition


.section .data
char_space:
    .asciz " "
char_cross:
    .asciz "X"
char_circle:
    .asciz "O"
format:
    .asciz "%s"
skip_line:
    .ascii " \n-----------\n "
text_finish_tie:
    .asciz "Game ended in a tie.\nWell done to both of you though!\n\nThanks for playing my game!\nFor another party press any key.\n"
text_finish_cross:
    .asciz "Game finished.\nWell done to the crosses!\n\nThanks for playing my game!\nFor another party press any key.\n"
text_finish_circle:
    .asciz "Game finished.\nWell done to the circles!\n\nThanks for playing my game!\nFor another party press any key.\n"
clear_line:
    .ascii "                                                                                                    \0"
winning_combos:
    .byte 0,1,2
    .byte 3,4,5
    .byte 6,7,8
    .byte 0,3,6
    .byte 1,4,7
    .byte 2,5,8
    .byte 0,4,8
    .byte 2,4,6


.section .bss
buffer:
    .space 64   # I need somthing like 60 characters but I put 64 because it's exactly 2^6 and I have leftovers but whatever...


.section .text
.globl main
main:
    mov $0b0, %r15d     # I'm adding the player variable after the coordinates, so either a 0 or a 1, only 1 bit required
    shl $8, %r15d       # There's no use to shift it but it's to point out that the player variable it's at the 9th bit

    jmp init
init:
    and $0x00000100, %r15d

    mov $0, %ecx   # We are saving all our coordinates of X, Y and previous X and Y in this very register because they're all 2 bits long
    mov $0b01010101, %ecx  # Computers are optimized to work on 32 or 64 bits so even if I only need 8 bits, I'm using the 32 lowest
    and $0xffffff00, %r15d
    or %ecx, %r15d

    mov $0b000000000000000000, %ecx
    shl $9, %ecx
    or %ecx, %r15d      # I'm saving the map on 18 bits, 2 per boxes and since it's a morpion of 3 by 3, there's 9 boxes

    call clear_console

    mov $0, %rcx
    mov $3, %rdx
    call gotoxy

    jmp build_map

build_map:
    leaq buffer(%rip), %rdi
    mov $0, %eax
    mov %rdi, %rbx

    movb $' ', (%rbx)
    inc %rbx

    jmp put_char

start_line:
    leaq skip_line(%rip), %rsi
    mov %rbx, %rdi
    mov $15, %ecx
    cld
    rep movsb
    add $15, %rbx

put_char:
    mov %r15d, %edx
    shr $9, %edx    # Because all the 9 first values are used for something else, and I want the others
    mov %eax, %ecx
    imul $2, %ecx
    shr %cl, %edx      # Because I need to shift 2 bits each boxes because the information is stored on 2 bits, so I shift right 2 times
    and $0b11, %edx

    cmp $0, %edx
    je put_space
    cmp $2, %edx
    je put_cross
    cmp $3, %edx
    je put_circle

put_space:
    movb $' ', (%rbx)
    jmp after_char
put_cross:
    movb $'X', (%rbx)
    jmp after_char
put_circle:
    movb $'O', (%rbx)
    jmp after_char

after_char:
    inc %rbx

    cmp $2, %eax
    je last_case
    cmp $5, %eax
    je last_case
    cmp $8, %eax
    je last_case

    movb $' ', (%rbx)
    inc %rbx
    movb $'|', (%rbx)
    inc %rbx
    movb $' ', (%rbx)
    inc %rbx

last_case:
    inc %eax

    cmp $3, %eax
    je start_line
    cmp $6, %eax
    je start_line
    cmp $9, %eax
    je end_map

    jmp put_char

end_map:
    # Will be executed only if we are at the 8th character, which is our last character
    movb $' ', (%rbx)
    inc %rbx
    movb $'\n', (%rbx)
    inc %rbx

    leaq format(%rip), %rcx
    leaq buffer(%rip), %rdx

    sub $8, %rsp
    xor %eax, %eax
    call printf
    add $8, %rsp

    jmp continue

loop:
    sub $8, %rsp

    call getch
    movzx %al, %esi

    add $8, %rsp

    cmp $0, %esi
    je special_key
    cmp $0xE0, %esi
    je special_key

    jmp normal_key

special_key:
    call getch
    movzx %al, %esi

    cmp $72, %esi
    je press_up
    cmp $75, %esi
    je press_left
    cmp $80, %esi
    je press_down
    cmp $77, %esi
    je press_right

    jmp loop

normal_key:
    cmp $122, %esi
    je press_up
    cmp $113, %esi
    je press_left
    cmp $115, %esi
    je press_down
    cmp $100, %esi
    je press_right

    cmp $13, %esi
    je press_enter
    cmp $32, %esi
    je press_enter

    cmp $27, %esi
    je press_escape

    jmp loop

press_up:
    mov %r15d, %eax
    and $0b11, %eax

    cmp $0, %eax
    jle loop

    call update_previous_coord

    dec %eax

    and $0xfffffffc, %r15d
    or %eax, %r15d

    jmp continue

press_left:
    mov %r15d, %eax
    shr $2, %eax
    and $0b11, %eax

    cmp $0, %eax
    jle loop

    call update_previous_coord

    dec %eax

    and $0xfffffff3, %r15d
    shl $2, %eax
    or %eax, %r15d

    jmp continue

press_down:
    mov %r15d, %eax
    and $0b11, %eax

    cmp $2, %eax
    jge loop

    call update_previous_coord

    inc %eax

    and $0xfffffffc, %r15d
    or %eax, %r15d

    jmp continue

press_right:
    mov %r15d, %eax
    shr $2, %eax
    and $0b11, %eax

    cmp $2, %eax
    jge loop

    call update_previous_coord

    inc %eax

    and $0xfffffff3, %r15d
    shl $2, %eax
    or %eax, %r15d

    jmp continue

press_enter:
    call getpos

    mov %r15d, %ebx
    shr $9, %ebx
    shr %cl, %ebx
    and $0b11, %ebx
    cmp $0b10, %ebx
    je loop
    cmp $0b11, %ebx
    je loop

    mov %r15d, %ecx
    shr $8, %ecx
    and $0b1, %ecx

    mov $1, %ebx
    sub %ecx, %ebx
    shl $8, %ebx
    and $0xfffffeff, %r15d
    or %ebx, %r15d

    cmp $0, %ecx
    je add_cross
    cmp $1, %ecx
    je add_circle
add_cross:
    call getpos

    mov $0b10, %eax
    shl $9, %eax
    shl %cl, %eax
    or %eax, %r15d

    movabs $char_cross, %rcx
    jmp display_box
add_circle:
    call getpos

    mov $0b11, %eax
    shl $9, %eax
    shl %cl, %eax
    or %eax, %r15d

    movabs $char_circle, %rcx
    jmp display_box
display_box:
    sub $8, %rsp
    xor %eax, %eax
    call printf
    add $8, %rsp

    jmp check_victory

check_victory:
    mov $8, %r11d
    lea winning_combos(%rip), %rsi
check_next_combo:
    movzbl 0(%rsi), %eax
    call get_case_value
    mov %eax, %r8d

    movzbl 1(%rsi), %eax
    call get_case_value
    mov %eax, %r9d

    movzbl 2(%rsi), %eax
    call get_case_value
    mov %eax, %r10d

    test %r8d, %r8d
    jz not_this_combo
    cmp %r8d, %r9d
    jne not_this_combo
    cmp %r8d, %r10d
    jne not_this_combo

    cmp $2, %r8d
    je victory_cross
    cmp $3, %r8d
    je victory_circle
not_this_combo:
    add $3, %rsi
    dec %r11d
    jnz check_next_combo

    mov $0, %ecx
    jmp is_finished_tie     # If we didn't find any wins we check if the game is just simply finished
get_case_value:
    mov %r15d, %edx
    mov %eax, %ecx
    imul $2, %ecx
    add $9, %ecx
    shr %cl, %edx
    and $0b11, %edx
    mov %edx, %eax
    ret
victory_circle:
    call wait

    call clear_console

    mov $0, %rcx
    mov $3, %rdx
    call gotoxy

    sub $40, %rsp

    movabs $text_finish_circle, %rcx
    xor %eax, %eax
    call printf

    call getch

    add $40, %rsp

    jmp init
victory_cross:
    call wait

    call clear_console

    mov $0, %rcx
    mov $3, %rdx
    call gotoxy

    sub $40, %rsp

    movabs $text_finish_cross, %rcx
    xor %eax, %eax
    call printf

    call getch

    add $40, %rsp

    jmp init

is_finished_tie:
    mov %r15d, %ebx
    shr $9, %ebx
    shr %cl, %ebx

    add $2, %ecx

    and $0b11, %ebx
    cmp $0b00, %ebx
    je continue

    cmp $18, %ecx
    jl is_finished_tie

    jmp finished_tie

press_escape:
    ret

continue:
    # Allowed me to go to the previous coordinates to erase the box but after all that's unecessary.
    # Since it would cost me more to remake everything without this system I'm keeping it for History...
    # # Get Previous Y
    # mov %r15d, %eax
    # shr $4, %eax
    # and $0b11, %eax
    # # Push it into rdx for the gotoxy
    # imul $2, %eax
    # mov %eax, %edx
    # add $3, %edx
    # 
    # # Get Previous X
    # mov %r15d, %eax
    # shr $6, %eax
    # and $0b11, %eax
    # # Push it into rcx for the gotoxy
    # imul $4, %eax
    # mov %eax, %ecx
    # add $1, %ecx
    # 
    # call gotoxy

    # Get Y
    mov %r15d, %eax
    and $0b11, %eax
    # Push it into rdx for the gotoxy
    imul $2, %eax
    mov %eax, %edx
    add $3, %edx

    # Get X
    mov %r15d, %eax
    shr $2, %eax
    and $0b11, %eax
    # Push it into rcx for the gotoxy
    imul $4, %eax
    mov %eax, %ecx
    add $1, %ecx

    call gotoxy

    mov %ecx, %ebx      # Don't know what that is for but it must be important...

    jmp loop

finished_tie:
    call wait

    call clear_console

    mov $0, %rcx
    mov $3, %rdx
    call gotoxy

    sub $40, %rsp

    movabs $text_finish_tie, %rcx
    xor %eax, %eax
    call printf

    call getch

    add $40, %rsp

    jmp init


update_previous_coord:
    sub $16, %rsp

    mov %r15d, %ecx
    and $0b1111, %ecx

    shl $4, %ecx

    and $0xffffff0f, %r15d
    or %ecx, %r15d

    add $16, %rsp
    ret

gotoxy:
    sub $16, %rsp

    mov %rcx, %r8   # X value
    mov %rdx, %r9   # Y value

    mov $-11, %ecx
    call GetStdHandle
    mov %rax, %rbx

    mov %r9, %rax
    shl $16, %rax
    mov %r8w, %ax

    mov %rbx, %rcx
    mov %rax, %rdx
    call SetConsoleCursorPosition

    add $16, %rsp
    ret

getpos:
    mov %r15d, %eax
    and $0b1111, %eax
    mov %eax, %ebx
    shr $2, %eax
    and $0b11, %ebx

    mov %eax, %ecx
    imul $3, %ebx
    add %ebx, %ecx

    imul $2, %ecx

    ret

clear_console:
    mov $2, %rbp    # I'm using rbp because, strangely enough, rbx doesn't work and doesn't seem to be persistent...
clear_loop:
    mov $0, %rcx
    mov %rbp, %rdx
    call gotoxy

    sub $32, %rsp
    movabs $clear_line, %rcx
    mov $0, %rdx
    xor %eax, %eax
    call printf
    add $32, %rsp

    inc %rbp
    cmp $8, %rbp
    jle clear_loop

    ret

wait:
    mov $0x8fffffff, %rcx
wait_loop:
    dec %rcx
    jnz wait_loop
    ret
