# start of generated code
	.section		.rodata	
.LC0:
	.string	"fib(%lld) = %lld \n"
	.text	
	.globl	fib
	.type	fib, @function
fib:
	pushq	 %rbp
	movq	%rsp, %rbp
	pushq	 %rbx
	pushq	 %r10
	pushq	 %r11
	pushq	 %r12
	pushq	 %r13
	pushq	 %r14
	pushq	 %r15
	subq	$8, %rsp
	movq	%rdi, -64(%rbp)
	subq	$8, %rsp
	movq	$2, %rax
	movq	%rax, -72(%rbp)
	subq	$8, %rsp
	movq	-64(%rbp), %rax
	movq	-72(%rbp), %rdx
	cmpq	%rdx, %rax
	jle	 .POS2
	movq	$0, %rax
	jmp	 .POS3
.POS2:
	movq	$1, %rax
.POS3:
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %rax
	testq	%rax, %rax
	jz	 .POS0
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -88(%rbp)
	movq	-88(%rbp), %rax
	popq	 %r15
	popq	 %r14
	popq	 %r13
	popq	 %r12
	popq	 %r11
	popq	 %r10
	popq	 %rbx
	leave	
	ret	
	jmp	 .POS1
.POS0:
.POS1:
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -96(%rbp)
	subq	$8, %rsp
	movq	-64(%rbp), %rbx
	movq	-96(%rbp), %r10
	subq	%r10, %rbx
	movq	%rbx, -104(%rbp)
	movq	-104(%rbp), %rdi
	call	 fib
	subq	$8, %rsp
	movq	%rax, -112(%rbp)
	subq	$8, %rsp
	movq	$2, %rax
	movq	%rax, -120(%rbp)
	subq	$8, %rsp
	movq	-64(%rbp), %rbx
	movq	-120(%rbp), %r10
	subq	%r10, %rbx
	movq	%rbx, -128(%rbp)
	movq	-128(%rbp), %rdi
	call	 fib
	subq	$8, %rsp
	movq	%rax, -136(%rbp)
	subq	$8, %rsp
	movq	-112(%rbp), %rbx
	movq	-136(%rbp), %r10
	addq	%rbx, %r10
	movq	%r10, -144(%rbp)
	movq	-144(%rbp), %rax
	popq	 %r15
	popq	 %r14
	popq	 %r13
	popq	 %r12
	popq	 %r11
	popq	 %r10
	popq	 %rbx
	leave	
	ret	
	.size	fib, .-fib
	.globl	main
	.type	main, @function
main:
	pushq	 %rbp
	movq	%rsp, %rbp
	pushq	 %rbx
	pushq	 %r10
	pushq	 %r11
	pushq	 %r12
	pushq	 %r13
	pushq	 %r14
	pushq	 %r15
	subq	$8, %rsp
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
.POS4:
	subq	$8, %rsp
	movq	$15, %rax
	movq	%rax, -24(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rdx
	cmpq	%rdx, %rax
	jl	 .POS7
	movq	$0, %rax
	jmp	 .POS8
.POS7:
	movq	$1, %rax
.POS8:
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	testq	%rax, %rax
	jz	 .POS6
	subq	$8, %rsp
	movq	$.LC0, %rax
	movq	%rax, -40(%rbp)
	movq	-8(%rbp), %rdi
	call	 fib
	subq	$8, %rsp
	movq	%rax, -48(%rbp)
	movq	-40(%rbp), %rdi
	movq	-8(%rbp), %rsi
	movq	-48(%rbp), %rdx
	subq	$8, %rsp
	movl	$0, %eax
	call	 printf
.POS5:
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -64(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %rbx
	movq	-64(%rbp), %r10
	addq	%rbx, %r10
	movq	%r10, -72(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, -8(%rbp)
	jmp	 .POS4
.POS6:
	popq	 %r15
	popq	 %r14
	popq	 %r13
	popq	 %r12
	popq	 %r11
	popq	 %r10
	popq	 %rbx
	leave	
	ret	
	.size	main, .-main

# end of generated code
