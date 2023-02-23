extern printf

section .data
fmt: db "sqrt(%d) = %f", 10


section .text
global main

;i in rbx
main:
	; build stackframe, printf needs correct rbp
	push rbp
	mov rbp, rsp
	
	mov rbx, 0 ;i = 0
condition:
	cmp rbx, 100
	jg endloop ;if i > 100 jump out
	
	;calc sqrt(i)
	cvtsi2sd xmm0, rbx ;store (double)i in xmm0 ;convert signed int to single precision
	sqrtpd xmm0, xmm0 ;xmm0 = sqrt(xmm0) ;double, 2 64bit values values
	
	;print result
	mov rdi, fmt
	mov rsi, rbx ;copy i to first arg
	mov rax, 1 ;float value is in xmm0
	call printf
	
	inc rbx ;i++
	jmp condition ;continue loop
endloop:

	leave ;destroy stackframe
	
	mov rax, 0 ;set exit code
	ret
