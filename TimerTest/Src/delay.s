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
	.equ TIM_PSC, 0x28
	.equ TIM_EGR, 0x14


	.equ CEN, 1<<0
	.equ URS, 1<<2
	.equ UIF, 1<<0
	.equ UG, 1<<0

	.equ PSC_S_COUNT, (16000000-1)
	.equ PSC_MS_COUNT, (16000-1)
	.equ PSC_US_COUNT, (16-1)

.section .text

.global main
main:
	bl TimerInit
	mov r0, #4000
	bl DelayMs

	mov r0, #0
end:bal end


.global TimerInit
TimerInit:

	push {r0-r1}

	ldr r0, =RCC_BASE
	ldr r1, [r0, #RCC_APB1ENR]
	orr r1, #RCC_TIM2EN
	str r1, [r0, #RCC_APB1ENR]

	pop {r0-r1}
	bx lr

// A method to delay an inputted number of seconds
// r0 - the number of seconds to delay
// Return - nothing
.global DelayS
DelayS:
	push {r1, lr}

	ldr r1, =PSC_S_COUNT
	bl delayTimeFactor

	pop {r1, pc}


// A method to delay an inputted number of milliseconds
// r0 - the number of milliseconds to delay
// Return - nothing
.global DelayMs
DelayMs:
	push {r1, lr}

	ldr r1, =PSC_MS_COUNT
	bl delayTimeFactor

	pop {r1, pc}

// A method to delay an inputted number of microseconds
// r0 - the number of microseconds to delay
// Return - nothing
.global DelayUs
DelayUs:
	push {r1, lr}

	ldr r1, =PSC_US_COUNT
	bl delayTimeFactor

	pop {r1, pc}


// A method to delay a given an inputted ARR value and PSC value
// r0 - the number to store in the ARR
// r1 - the number to store in the PSC
// Return - nothing
delayTimeFactor:

	push {r0-r2}

	ldr r2, =TIM2_BASE

	str r0, [r2,#TIM_ARR]
	str r1, [r2,#TIM_PSC]

	mov r1, #0
	str r1, [r2,#TIM_CNT]

	mov r1, #UG
	str r1, [r2,#TIM_EGR]

	mov r0, #30
1:	subs r0, #1
	bne 1b

	mov r1, #0
	str r1, [r2,#TIM_SR]

	mov r1, #(URS|CEN)
	str r1, [r2,#TIM_CR1]

1:
	ldrb r1, [r2,#TIM_SR]
	ands r1, #UIF
	beq 1b

	//Stop the timer
	mov r1, #0
	str r1, [r2,#TIM_CR1]

	//Done counting
	//clear the flag
	ldrb r1, [r2,#TIM_SR]
	bic r1, #UIF
	strb r1, [r2,#TIM_SR]



	//Branch back
	pop {r0-r2}
	bx lr
