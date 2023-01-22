// Josh Grant
// CE2801 Section 11
// 10/25/2022
//
// randomTimer.s
// A file containing subroutines to grab a random number
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	//RCC register locations
	.equ RCC_BASE, 0x40023800
	.equ RCC_APB1ENR, 0x40
	.equ RCC_TIM5EN, 1<<3

	//Timer register locations
	.equ TIM5_BASE, 0x40000C00
	.equ TIM_CR1, 0x00
	.equ TIM_SR, 0x10
	.equ TIM_CNT, 0x24
	.equ TIM_ARR, 0x2C
	.equ TIM_PSC, 0x28
	.equ TIM_EGR, 0x14

	//Timer status and control bits
	.equ CEN, 1<<0
	.equ URS, 1<<2
	.equ UIF, 1<<0
	.equ UG, 1<<0

	//Time tracking constants
	.equ PSC_MS_COUNT, (16000-1)
	.equ PSC_US_COUNT, (16-1)
	.equ MS_IN_S, 1000
	.equ BUSY_DELAY, 3

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// A method to initialize the timer
// r0 - the max value of the random numbers (range of 0-r0)
// Return - nothing
.global RandomNumberInit
RandomNumberInit:
// r0 - Random number range input register
// r1 - Initialization value register
// r2 - RCC & TIM base address register

	//Preserve registers
	push {r0-r2}

	//Initialize the clock
	ldr r2, =RCC_BASE
	ldr r1, [r2, #RCC_APB1ENR]

	//Enable the timer
	orr r1, #RCC_TIM5EN
	str r1, [r2, #RCC_APB1ENR]

	//Load the timer base pointer
	ldr r2, =TIM5_BASE

	//Populate the ARR with method parameters
	str r0, [r2,#TIM_ARR]

	//Enable the counter
	mov r1, #(URS|CEN)
	str r1, [r2,#TIM_CR1]

	//branch back
	pop {r0-r2}
	bx lr

// A method to get a "random" number
// Return - a "random" number based upon the timer count value
.global GetRandomNumber
GetRandomNumber:
// r0 - Randum number return register

	//Load the timer base pointer
	ldr r0, =TIM5_BASE

	//Grab the current value on the counter
	ldr r0, [r0, #TIM_CNT]

	//branch back
	bx lr
