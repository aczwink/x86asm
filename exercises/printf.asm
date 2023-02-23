extern printf

section .data
fmt: db "%d,%d", 10


section .text
global main

main:
	mov rsi, 50 ;first integer arg
	mov rdx, 20 ;second integer arg
	mov rdi, fmt
	mov rax, 0 ;no xmm register used
	call printf
	
	mov rax, 0 ;set exit code
	ret
	
	
	
	
;System V AMD64 ABI calling convention
;first six int arguments are passed in rdi, rsi, rdx, rcx, r8, r9
;floating point args in xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
;additional args on stack
;return value in rax

;rbp, rbx, r12, r13, r14, r15 values must be preserved by a called function
