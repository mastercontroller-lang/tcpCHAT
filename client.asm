section .data
    ip_address db '127.0.0.1', 0        ; Server IP address (localhost)
    port dw 12345                        ; Port to connect to
    message db 'Client: Sending a file!', 0x0A
    file_name db 'file_to_send.png', 0   ; File to send (can be any file, e.g., PNG)
    buffer resb 1024                     ; Buffer for sending file chunks

section .text
    global _start

_start:
    ; Create a socket (AF_INET, SOCK_STREAM, 0)
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

    ; Connect to server (connect())
    mov rdi, rsi                        ; Socket descriptor
    lea rsi, [sockaddr_in]              ; sockaddr_in structure
    mov rax, 42                         ; Syscall number for connect()
    syscall

    ; Open the file to send (open())
    lea rdi, [file_name]                ; File path
    mov rsi, 0                          ; O_RDONLY flag (read only)
    mov rdx, 0                          ; No special flags
    mov rax, 2                          ; Syscall number for open()
    syscall

    ; Save file descriptor
    mov rbx, rax

    ; Read the file in chunks and send it to the server (send())
send_file_loop:
    ; Read the next chunk of the file
    lea rdi, [buffer]                   ; Buffer to store file chunk
    mov rsi, 1024                       ; Read 1024 bytes
    mov rax, 0                          ; Syscall number for read()
    syscall

    ; If end of file, exit the loop
    test rax, rax
    jz done_sending_file

    ; Send the chunk to the server (send())
    mov rdi, rsi                        ; Socket descriptor
    lea rsi, [buffer]                   ; Buffer containing the chunk
    mov rdx, rax                        ; Length of the chunk
    mov rax, 44                         ; Syscall number for send()
    syscall

    jmp send_file_loop

done_sending_file:
    ; Close the file (close())
    mov rdi, rbx                        ; File descriptor
    mov rax, 57                         ; Syscall number for close()
    syscall

    ; Close the socket (close())
    mov rdi, rsi                        ; Socket descriptor
    mov rax, 57                         ; Syscall number for close()
    syscall

    ; Exit the program
    mov rax, 60                         ; Exit syscall
    xor rdi, rdi                        ; Exit code 0
    syscall

sockaddr_in:
    resb 16  ; Space for the sockaddr_in structure
