extern printf

section .data
fmt: db "%d", 10


section .text
global main

;fak(n) = n!
fak:
	cmp rdi, 0 ;check if n is 0
	jnz fak1ton ;if not jump away
	;n = 0
	mov rax, 1
	ret
fak1ton:
	push rdi ;save n on stack
	sub rdi, 1 ; n = n - 1
	call fak ;recursive call
	pop rdi
	mul rdi ;multiplicate rax with n
	ret

main:
	mov rdi, 10
	call fak
	
	;print result
	mov rsi, rax ;copy return value from fak
	mov rdi, fmt
	mov rax, 0 ;no xmm register used
	call printf
	
	mov rax, 0 ;set exit code
	ret
