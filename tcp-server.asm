section .data
    ip_address db '127.0.0.1', 0        ; Server IP address (localhost)
    port dw 12345                        ; Port to listen on
    buffer resb 1024                     ; Buffer for receiving data
    output_file db 'received_file.png', 0 ; Output file name to save received data

section .text
    global _start

_start:
    ; Create socket (AF_INET, SOCK_STREAM, 0)
    mov rdi, 2                          ; AF_INET (IPv4)
    mov rsi, 1                          ; SOCK_STREAM (TCP)
    mov rdx, 0                          ; Protocol 0 (default, IP)
    mov rax, 41                         ; Syscall number for socket()
    syscall

    ; Save socket descriptor
    mov rsi, rax

    ; Set up sockaddr_in structure (AF_INET, port 12345, 127.0.0.1)
    lea rdi, [sockaddr_in]
    mov word [rdi], 2                   ; AF_INET
    mov word [rdi + 2], port            ; Port number
    lea rsi, [ip_address]               ; IP address
    call ip_to_bin
    mov [rdi + 4], rax                  ; Store IP in sockaddr_in

    ; Bind socket to address (bind())
    mov rax, 49                         ; Syscall number for bind()
    syscall

    ; Listen on socket (listen())
    mov rax, 50                         ; Syscall number for listen()
    mov rdi, rsi                        ; Socket descriptor
    mov rsi, 5                          ; Backlog (5 connections)
    syscall

    ; Accept incoming connections (accept())
accept_loop:
    mov rax, 43                         ; Syscall number for accept()
    syscall

    ; Check if we got a valid connection (child process)
    test rax, rax
    jz accept_loop                      ; If accept() failed, keep accepting

    ; Receive message from client (recv())
    lea rdi, [buffer]                   ; Buffer for receiving data
    mov rsi, 1024                       ; Receive 1024 bytes
    mov rax, 45                         ; Syscall number for recv()
    syscall

    ; Check if it's a message or a file transfer
    ; For simplicity, assume text messages are always smaller than 1024 bytes
    ; If it's larger, it's likely a file
    ; Write the received data to stdout or save it as a file
    test rax, rax
    jz done_receiving

    ; If it's text, print the message
    lea rdi,
