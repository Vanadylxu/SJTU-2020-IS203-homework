# start of generated code
	.section		.rodata	
.LC0:
	.string	"gcd(23398, 14567) = %lld \n "
	.text	
	.globl	euclidean
	.type	euclidean, @function
euclidean:
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
	movq	-64(%rbp), %rax
	movq	-72(%rbp), %rdx
	cmpq	%rdx, %rax
	jl	 .POS2
	movq	$0, %rax
	jmp	 .POS3
.POS2:
	movq	$1, %rax
.POS3:
	movq	%rax, -88(%rbp)
	movq	-88(%rbp), %rax
	testq	%rax, %rax
	jz	 .POS0
	movq	-64(%rbp), %rax
	movq	%rax, -80(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-80(%rbp), %rax
	movq	%rax, -72(%rbp)
	jmp	 .POS1
.POS0:
.POS1:
.POS4:
	subq	$8, %rsp
	movq	-64(%rbp), %rax
	cqto	
	movq	-72(%rbp), %rbx
	idivq	%rbx
	movq	%rdx, -96(%rbp)
	subq	$8, %rsp
	movq	$0, %rax
	movq	%rax, -104(%rbp)
	subq	$8, %rsp
	movq	-96(%rbp), %rax
	movq	-104(%rbp), %rdx
	cmpq	%rdx, %rax
	jne	 .POS6
	movq	$0, %rax
	jmp	 .POS7
.POS6:
	movq	$1, %rax
.POS7:
	movq	%rax, -112(%rbp)
	movq	-112(%rbp), %rax
	testq	%rax, %rax
	jz	 .POS5
	movq	-72(%rbp), %rax
	movq	%rax, -80(%rbp)
	subq	$8, %rsp
	movq	-64(%rbp), %rax
	cqto	
	movq	-72(%rbp), %rbx
	idivq	%rbx
	movq	%rdx, -120(%rbp)
	movq	-120(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	-80(%rbp), %rax
	movq	%rax, -64(%rbp)
	jmp	 .POS4
.POS5:
	movq	-72(%rbp), %rax
	popq	 %r15
	popq	 %r14
	popq	 %r13
	popq	 %r12
	popq	 %r11
	popq	 %r10
	popq	 %rbx
	leave	
	ret	
	.size	euclidean, .-euclidean
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
	subq	$8, %rsp
	movq	$23398, %rax
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -8(%rbp)
	subq	$8, %rsp
	movq	$14567, %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, -16(%rbp)
	subq	$8, %rsp
	movq	$.LC0, %rax
	movq	%rax, -40(%rbp)
	movq	-8(%rbp), %rdi
	movq	-16(%rbp), %rsi
	call	 euclidean
	subq	$8, %rsp
	movq	%rax, -48(%rbp)
	movq	-40(%rbp), %rdi
	movq	-48(%rbp), %rsi
	subq	$8, %rsp
	movl	$0, %eax
	call	 printf
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
