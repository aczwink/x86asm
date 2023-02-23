extern printf
extern malloc
extern free

section .data
fmt: db "Done", 10, 0
fmt2: db "%d", 10, 0
pProbeSize: dq 1000000000 ;10mb


section .text
global main

build_random_mem:
	mov rdi, [pProbeSize]
	call malloc
	
	;pointer is in rax
	
	;fill the mem with probe_size random values
	mov rcx, [pProbeSize] ;counter is in rcx
	mov rdi, rax ;current pointer in rdi
	
	;loop
continue_build_random_mem_loop:
	mov [rdi], dl
	inc rdi
	dec rcx
	jnz continue_build_random_mem_loop
	
	ret
	
memcopy:
	;rdi = source pointer
	;rsi = destination pointer
	;rdx = size
	
memcopyloop:
	test rdx, 3
	jz memcopyloop4
	
	mov al, [rdi]
	mov [rsi], al
	
	dec rdx
	inc rdi
	inc rsi
	jmp memcopyloop
	
memcopyloop4:
	test rdx, 7
	jz memcopyfinish
	
	mov eax, [rdi]
	mov [rsi], eax
	
	sub rdx, 4
	add rdi, 4
	add rsi, 4
	
memcopyloop8: ;it seems that 8 byte aligned is slower than 4 on my laptop
	test rdx, rdx
	jz memcopyfinish
	
	mov rax, [rdi]
	mov [rsi], rax
	
	sub rdx, 8
	add rdi, 8
	add rsi, 8
	
memcopyfinish:
	ret

main:
	; build stackframe, printf needs correct rbp
	push rbp
	mov rbp, rsp
	
	call build_random_mem
	mov r12, rax ;keep source in r12
	
	;create second mem
	mov rdi, [pProbeSize]
	call malloc
	mov r13, rax ;keep destination in r13
	
	;call the memcopy
	mov rdi, r12
	mov rsi, r13
	mov rdx, [pProbeSize]
	call memcopy	
	
	;free both mems
	mov rdi, r12
	call free
	mov rdi, r13
	call free
	
	;print result
	mov rdi, fmt
	mov rax, 0 ;no xmm register used
	call printf
	
	mov rax, 0 ;set exit code
	leave
	ret
