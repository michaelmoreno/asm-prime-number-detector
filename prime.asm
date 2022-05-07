; Prime Number Detector written in x86 Assembly

%macro read 1
    mov rax, 0 ; sys read
    mov rdi, 0 ; stdin
    mov rsi, %1 ; buffer address
    mov rdx, 64 ; buffer size
    syscall
%endmacro

%macro write 1
    mov rax, 1 ; sys write
    mov rdi, 1 ; stdout
    mov rsi, %1 ; buffer address
    call _getLength ; get length of string and sets rdx to it (buffer size)
    syscall
%endmacro

section .data
    WELC db "Welcome to the Perfect Square Detector!",10,0
    PROMPT db "Enter an integer: ",0
    ERROR_NONINT db "Only positive integers are allowed!",10,0
    ERROR_TOOBIG db "Number too big! Please input a between 0 and 9999!",10,0
    NOT_PRIME db "Not a prime number!",10,0
    IS_PRIME db "Is a prime number!",10,0
    total dq 0
    
section .bss
    NUMBER resb 4 ; reserve 4 bytes for input number

section .text
    global _start
    
_start:
    call _welcome
    call _promptUser
    call _getInput
    call _validateInput
    call _atoi
    call _determinePrime

_welcome:
    write WELC
    ret

_promptUser:
    write PROMPT
    ret

_getInput:
    read NUMBER
    ret

_validateInput:
    mov rcx, 4 ; rcx will tell validateInt how many times to loop
    mov rsi, NUMBER ; set rsi to address NUMBER label (beginning of input)
    call _getLength
    sub rdx, 2 ; omit newline and null terminator
    mov rcx, rdx ; set rcx to length of input which validateInt will use to loop
    call _validateInt ; validate that the input is an integer
    call _validateByteSize ; validate that the input is between 0 and 9999
    ret

_validateByteSize:
    xor rax, rax ; reset rax to 0
    mov rsi, NUMBER ; set rsi to address NUMBER label (beginning of input)
    call _getLength ; get the length of input
    mov al, byte [NUMBER] ; get the first byte
    cmp rdx, 6 ; compare input length to 6 (4 digits + 1 newline + 1 null terminator)
    jg _errTooBig ; if input length is greater than 6, jump to _errTooBig
    ret

_errTooBig:
    write ERROR_TOOBIG
    jmp _restartPrompt


_validateInt:
    mov al, [rsi] ; get byte at rsi
    cmp al, 48 ; 48 is the ascii value for 0
    jl _errNotInt ; if less than 0 then jump to _errNotInt
    cmp al, 57 ; 57 is the ascii value for 9
    jg _errNotInt ; if greater than 9 then jump to _errNotInt
    inc rsi ; increment rsi to the next byte
    loop _validateInt ; loop back to _validateInt
    ret

_errNotInt:
    write ERROR_NONINT
    jmp _restartPrompt

_writeInput:
    write NUMBER
    jmp _restartPrompt

_restartPrompt:
    mov qword [NUMBER], 0 ; reset NUMBER string to 0
    mov byte [total], 0 ; reset total to 0
    call _promptUser
    call _getInput
    call _validateInput
    call _atoi
    call _determinePrime


_getLength:
    push rsi ; save base address of input for later
    mov rdx, 1 ; start rdx at 1

_getLengthLoop:
    cmp byte [rsi], 0 
    je _getLengthEnd ; if rsi is at the end of the string, jump to _getLengthEnd
    inc rdx ; increment rdx to count number of bytes
    inc rsi ; increment rsi to point to next byte
    jmp _getLengthLoop

_getLengthEnd:
    pop rsi ; restore rsi to buffer address
    ret

_atoi:
    mov rsi, NUMBER ; set rsi to address NUMBER label (beginning of input)
    call _getLength
    sub rdx, 2 ; omit \n and 0
    mov rcx, rdx ; loop looks to rcx, so store rdx in rcx to loop "rdx times"
    ; push rcx ; save count 
    mov r11, rcx
    ; dec rcx ; decrement count variable for proper exponentiation
    dec r11;
    mov rax, 0

_atoiLoop:
    xor rax, rax ; reset rax to 0
    mov al, byte [rsi] ; al is current character 

    sub al, 48 ; converted to int
    mov r9, 10 ; base
    mov r8, r11 ; exponent

    call _exponentLoop
    mov r10, [total] ; r10 will be end result integer.
    add r10, rax; add exponentiation result to total
    mov [total], r10

    dec r11 ; decrement
    inc rsi ; increment pointer
    loop _atoiLoop
    
    ret

_exponentLoop:
    cmp r8, 0 ; compare exponent to 0
    je _exponentEnd ; if exponent is 0, end loop
    mul r9 ; multiply al by 10
    dec r8 ; decrement exponent
    jmp _exponentLoop ; loop again


_exponentEnd:
    ret


_determinePrime:
    xor rax, rax ; can remove this, leftover from last routine
    mov rax, [total]
    mov rcx, rax  ; loop looks to rcx, so store rax in rcx to loop "rax times"
    dec rcx ; start loop at n-1
_primeLoop:
    xor rdx, rdx; reset rdx
    mov rax, [total] ; get value of total to be divided
    cmp rax, 1 ; compare rax to 1
    je _primeEnd ; if rax is 1, end loop to avoid dividing by 0.
    div rcx ; divide by current number

    cmp rdx, 0 ; compare remainder register to 0
    ; cmp rax, 0 ; if remainder is 0, not prime
    je _notPrime ; composite number confirmed
    cmp rcx, 2 ; compare current number to 1
    je _primeEnd ; prime number confirmed
    loop _primeLoop ; loop again

_notPrime:
    write NOT_PRIME
    jmp _restartPrompt
    
_primeEnd:
    write IS_PRIME
    jmp _restartPrompt
    
_exit:
    mov rax, 60 ; sys exit
    mov rdi, 0 ; exit status
    syscall
    ret 