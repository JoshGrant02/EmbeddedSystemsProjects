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
	.equ RCC_TIM4EN, 1<<2

	//Timer register locations
	.equ TIM4_BASE, 0x40000800
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
	.equ REALLY_LONG_TIME, 0xFFFFFF

//////////////////////////////
//Globally exposed functions//
//////////////////////////////

// A method to initialize the general timer
// Return - nothing
.global GeneralTimerInit
GeneralTimerInit:
// r0 - Random number range input register
// r1 - Initialization value register
// r2 - RCC & TIM base address register

	//Preserve registers
	push {r0-r1}

	//Initialize the clock
	ldr r0, =RCC_BASE
	ldr r1, [r0, #RCC_APB1ENR]

	//Enable the timer
	orr r1, #RCC_TIM4EN
	str r1, [r0, #RCC_APB1ENR]

	//Load the timer base pointer
	ldr r0, =TIM4_BASE

	//Populate the PSC with 1ms time
	//Populate the ARR with a really long time
	ldr r1, =PSC_MS_COUNT
	str r1, [r0,#TIM_PSC]
	ldr r1, =REALLY_LONG_TIME //about 16,000 seconds
	str r1, [r0,#TIM_ARR]

	//Trigger an update generation to update the prescaler and reset the count
	mov r1, #UG
	str r1, [r0,#TIM_EGR]

	//Clear the status register
	mov r1, #0
	str r1, [r0,#TIM_SR]

	//Branch back
	pop {r0-r1}
	bx lr


// A method to restart the general timer
.global RestartGeneralTimer
RestartGeneralTimer:
// r0 - Timer address register
// r1 - Timer interaction value register

	//Preserve registers
	push {r0-r1}

	//Load the timer base pointer
	ldr r0, =TIM4_BASE

	//Reset the counter count value
	mov r1, #0
	str r1, [r0,#TIM_CNT]

	//Enable the counter
	mov r1, #(URS|CEN)
	str r1, [r0,#TIM_CR1]

	//Preserve registers
	pop {r0-r1}
	bx lr


// A method to get a the current time from the timer
// Return - the time, in ms
.global GetTimerTime
GetTimerTime:
// r0 - Randum number return register

	//Load the timer base pointer
	ldr r0, =TIM4_BASE

	//Grab the current value on the counter
	ldr r0, [r0, #TIM_CNT]

	//branch back
	bx lr
