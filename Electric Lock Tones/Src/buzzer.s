	.syntax unified
	.cpu cortex-m4
	.thumb
	.section .text

	.equ RCC_BASE, 0x40023800
	.equ RCC_APB1ENR, 0x40
	.equ RCC_TIM2EN, 1<<0

	.equ TIM2_BASE, 0x40000000
	.equ TIM_CR1, 0x00
	.equ TIM_SR, 0x10
	.equ TIM_CNT, 0x24
	.equ TIM_ARR, 0x2C

.section .text

TimerInit:

	push {r0-r1}

	ldr r0, =RCC_BASE
	ldr r1, [r0, #RCC_APB1ENR]
	orr r1, #RCC_TIM2EN
	str r1, [r0, #RCC_APB1ENR]

	pop {r0-r1}
	bx lr
