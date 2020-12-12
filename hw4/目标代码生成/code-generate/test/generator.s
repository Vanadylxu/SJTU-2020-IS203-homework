# start of generated code
	.section		.rodata	
.LC0:
	.string	"ind(%lld) = %lld \n"
	.text	
	.globl	ind
	.type	ind, @function
ind:
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
	movq	%rsi, -72(%rbp)
	subq	$8, %rsp
	subq	$8, %rsp
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -96(%rbp)
	movq	-96(%rbp), %rax
	movq	%rax, -80(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, -88(%rbp)
.POS0:
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -104(%rbp)
	subq	$8, %rsp
	movq	-88(%rbp), %rax
	movq	-104(%rbp), %rdx
	cmpq	%rdx, %rax
	jne	 .POS2
	movq	$0, %rax
	jmp	 .POS3
.POS2:
	movq	$1, %rax
.POS3:
	movq	%rax, -112(%rbp)
	movq	-112(%rbp), %rax
	testq	%rax, %rax
	jz	 .POS1
	subq	$8, %rsp
	movq	-88(%rbp), %rbx
	movq	-64(%rbp), %r10
	imulq	%r10, %rbx
	movq	%rbx, -120(%rbp)
	subq	$8, %rsp
	movq	-120(%rbp), %rax
	cqto	
	movq	-72(%rbp), %rbx
	idivq	%rbx
	movq	%rdx, -128(%rbp)
	movq	-128(%rbp), %rax
	movq	%rax, -88(%rbp)
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -136(%rbp)
	subq	$8, %rsp
	movq	-80(%rbp), %rbx
	movq	-136(%rbp), %r10
	addq	%rbx, %r10
	movq	%r10, -144(%rbp)
	movq	-144(%rbp), %rax
	movq	%rax, -80(%rbp)
	jmp	 .POS0
.POS1:
	movq	-80(%rbp), %rax
	popq	 %r15
	popq	 %r14
	popq	 %r13
	popq	 %r12
	popq	 %r11
	popq	 %r10
	popq	 %rbx
	leave	
	ret	
	.size	ind, .-ind
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
	movq	$23, %rax
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
	subq	$8, %rsp
	movq	$23, %rax
	movq	%rax, -48(%rbp)
	movq	-8(%rbp), %rdi
	movq	-48(%rbp), %rsi
	call	 ind
	subq	$8, %rsp
	movq	%rax, -56(%rbp)
	movq	-40(%rbp), %rdi
	movq	-8(%rbp), %rsi
	movq	-56(%rbp), %rdx
	subq	$8, %rsp
	movl	$0, %eax
	call	 printf
.POS5:
	subq	$8, %rsp
	movq	$1, %rax
	movq	%rax, -72(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %rbx
	movq	-72(%rbp), %r10
	addq	%rbx, %r10
	movq	%r10, -80(%rbp)
	movq	-80(%rbp), %rax
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
