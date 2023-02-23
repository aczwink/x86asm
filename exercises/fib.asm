extern printf

section .data
fmt: db "%d", 10


section .text
global main

;fib(0) = 0
;fib(1) = 1
;fib(n) = fib(n-1) + fib(n-2)
fib:
	test rdi, rdi
	jle fib0
	sub rdi, 1 ; n = n - 1, sets possibly zero flag
	jz fib1 ;check if that caused n == 0, if so then n was 1 before
	;n > 1
	push rdi ;save it!
	call fib
	pop rdi ;get our saved, previously decremented n
	push rax ;save fib(n-1)
	dec rdi ;decrement n again
	call fib
	pop rsi ;get the result of fib(n-1)
	add rax, rsi
	ret
fib0:
	;n <= 0
	xor rax, rax ; <---- definetely faster!
	ret
fib1:
	;n == 1, but rdi is not anymore
	mov rax, 1
	ret

main:
	mov rdi, 40
	call fib
	
	;print result
	mov rsi, rax ;copy return value from fak
	mov rdi, fmt
	mov rax, 0 ;no xmm register used
	call printf
	
	mov rax, 0 ;set exit code
	ret
